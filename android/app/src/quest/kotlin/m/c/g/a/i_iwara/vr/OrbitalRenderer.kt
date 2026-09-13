package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES30
import android.os.Handler
import android.os.HandlerThread
import android.os.Process
import android.util.Log
import android.view.Surface
import com.meta.spatial.core.Vector3
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/** GPU-only after uploading the visible bodies' maps. No View, video decoder, or pixel readback. */
internal class OrbitalRenderer(
    private val assets: AssetManager,
    private val bodies: List<OrbitalBody>,
    private val destinations: List<Surface>,
    initialFrame: Frame,
) {
    data class Frame(val left: Vector3, val right: Vector3, val forward: Vector3, val seconds: Float)
    @Volatile var ready = false
        private set
    @Volatile var failure: Throwable? = null
        private set
    @Volatile private var closed = false
    @Volatile private var enabled = true
    @Volatile private var initialized = false
    private val queued = AtomicBoolean(false)
    private val cleanupStarted = AtomicBoolean(false)
    private val cleanupFinished = CountDownLatch(1)
    private val worker = HandlerThread("QuestOrbitGPU", Process.THREAD_PRIORITY_DEFAULT).apply { start() }
    private val handler = Handler(worker.looper)
    private var display: EGLDisplay = EGL14.EGL_NO_DISPLAY
    private var context: EGLContext = EGL14.EGL_NO_CONTEXT
    private var pbuffer: EGLSurface = EGL14.EGL_NO_SURFACE
    private val outputs = ArrayList<EGLSurface>()
    private val textures = LinkedHashMap<String, Int>()
    private val locations = HashMap<String, Int>()
    private var program = 0
    private var frames = 0L
    private var submitNanos = 0L
    private var uploadBuffer: ByteBuffer? = null

    init { handler.post { guard {
        initialize()
        initialized = true
        if (enabled && render(initialFrame, warmup = true)) ready = true
    } } }

    fun setEnabled(value: Boolean) { enabled = value }

    fun request(frame: Frame): Boolean {
        if (closed || !initialized || !enabled || failure != null || !queued.compareAndSet(false, true)) return false
        if (!handler.post {
                try { guard { if (enabled && render(frame, warmup = !ready)) ready = true } } finally { queued.set(false) }
            }) { queued.set(false); return false }
        return true
    }

    private inline fun guard(action: () -> Unit) {
        if (closed || failure != null) return
        try { action() } catch (error: Throwable) { failure = error; Log.w("OrbitGPU", "Orbital renderer failed", error) }
    }

    private fun initialize() {
        display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        check(EGL14.eglInitialize(display, IntArray(2), 0, IntArray(2), 0))
        val configs = arrayOfNulls<EGLConfig>(1)
        val count = IntArray(1)
        check(EGL14.eglChooseConfig(display, intArrayOf(
            EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8, EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_DEPTH_SIZE, 0, EGL14.EGL_STENCIL_SIZE, 0, EGL14.EGL_SAMPLES, 0,
            EGL14.EGL_RENDERABLE_TYPE, 0x40, EGL14.EGL_SURFACE_TYPE, EGL14.EGL_WINDOW_BIT or EGL14.EGL_PBUFFER_BIT,
            EGL14.EGL_NONE), 0, configs, 0, 1, count, 0) && count[0] > 0)
        val config = checkNotNull(configs[0])
        context = EGL14.eglCreateContext(display, config, EGL14.EGL_NO_CONTEXT,
            intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 3, EGL14.EGL_NONE), 0)
        check(context != EGL14.EGL_NO_CONTEXT)
        pbuffer = EGL14.eglCreatePbufferSurface(display, config,
            intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0)
        check(pbuffer != EGL14.EGL_NO_SURFACE)
        makeCurrent(pbuffer)
        check(GLES30.glGetString(GLES30.GL_EXTENSIONS)?.contains("GL_EXT_sRGB_write_control") == true) {
            "Orbital surfaces require sRGB write control"
        }
        program = createProgram()
        for (name in listOf("surfaceMap", "cloudMap", "bodyCenter", "geoEast", "geoNorth", "geoMeridian",
            "bodyParameters", "earth", "leftEye", "rightEye", "planeRight", "planeUp", "planeSize")) {
            locations[name] = GLES30.glGetUniformLocation(program, name)
        }
        bodies.forEach { body -> texture(body.surface); body.clouds?.let { texture(it) } }
        uploadBuffer = null
        destinations.forEach { destination ->
            val output = EGL14.eglCreateWindowSurface(display, config, destination,
                intArrayOf(0x309D, 0x3089, EGL14.EGL_NONE), 0) // EGL_GL_COLORSPACE_KHR / SRGB_KHR
            check(output != EGL14.EGL_NO_SURFACE) { "Orbital surface: EGL ${EGL14.eglGetError()}" }
            outputs += output
            makeCurrent(output)
            EGL14.eglSwapInterval(display, 0)
        }
        makeCurrent(pbuffer)
        Log.i("OrbitGPU", "initialized renderer=${GLES30.glGetString(GLES30.GL_RENDERER)} textures=${textures.size} " +
            "eyePixels=${bodies.map { it.eyePixels }}; no recurring texture uploads/readbacks")
        checkGl()
    }

    private fun texture(file: String): Int = textures.getOrPut(file) {
        val bitmap = assets.open("environments/$file").use { stream ->
            BitmapFactory.decodeStream(stream, null, BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888; inScaled = false
            })
        } ?: error("Cannot decode orbital map $file")
        try {
            require(bitmap.width <= 2048 && bitmap.height <= 1024 && bitmap.config == Bitmap.Config.ARGB_8888)
            val id = IntArray(1).also { GLES30.glGenTextures(1, it, 0) }[0]
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, id)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR_MIPMAP_LINEAR)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_REPEAT)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)
            val bytes = bitmap.rowBytes * bitmap.height
            val pixels = uploadBuffer?.takeIf { it.capacity() >= bytes }
                ?: ByteBuffer.allocateDirect(bytes).also { uploadBuffer = it }
            pixels.clear(); bitmap.copyPixelsToBuffer(pixels); pixels.flip()
            GLES30.glPixelStorei(GLES30.GL_UNPACK_ROW_LENGTH, bitmap.rowBytes / 4)
            GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D, 0, GLES30.GL_SRGB8_ALPHA8, bitmap.width, bitmap.height,
                0, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, pixels)
            GLES30.glPixelStorei(GLES30.GL_UNPACK_ROW_LENGTH, 0)
            GLES30.glGenerateMipmap(GLES30.GL_TEXTURE_2D) // Once, while loading; never in render().
            id
        } finally { bitmap.recycle() }
    }

    private fun render(frame: Frame, warmup: Boolean = false): Boolean {
        val started = System.nanoTime()
        GLES30.glUseProgram(program)
        for ((index, body) in bodies.withIndex()) {
            if (closed || !enabled) return false
            if (!warmup && (body.center - (frame.left + frame.right) * 0.5f).normalize().dot(frame.forward) < -0.3f) continue
            makeCurrent(outputs[index])
            GLES30.glDisable(FRAMEBUFFER_SRGB_EXT)
            GLES30.glViewport(0, 0, body.eyePixels * 2, body.eyePixels)
            GLES30.glClearColor(0f, 0f, 0f, 0f)
            GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
            GLES30.glUseProgram(program)
            GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, checkNotNull(textures[body.surface]))
            GLES30.glUniform1i(location("surfaceMap"), 0)
            GLES30.glActiveTexture(GLES30.GL_TEXTURE1)
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, checkNotNull(textures[body.clouds ?: body.surface]))
            GLES30.glUniform1i(location("cloudMap"), 1)
            vector("bodyCenter", body.center); vector("geoEast", body.east); vector("geoNorth", body.north)
            vector("geoMeridian", body.meridian); vector("leftEye", frame.left); vector("rightEye", frame.right)
            vector("planeRight", body.frame.right()); vector("planeUp", body.frame.up())
            GLES30.glUniform1f(location("planeSize"), body.planeSize)
            GLES30.glUniform1i(location("earth"), if (body.name == "earth") 1 else 0)
            GLES30.glUniform4f(location("bodyParameters"), body.radius, body.longitude * OrbitalBody.RAD,
                ((frame.seconds * body.spin) % 360f) * OrbitalBody.RAD,
                ((frame.seconds * body.cloudSpin) % 360f) * OrbitalBody.RAD)
            GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 3)
            check(EGL14.eglSwapBuffers(display, outputs[index])) { "Orbital swap failed: EGL ${EGL14.eglGetError()}" }
        }
        makeCurrent(pbuffer)
        checkGl()
        frames++
        submitNanos += System.nanoTime() - started
        if (frames == 60L) Log.i("OrbitGPU", "frames=$frames mean submit CPU=${submitNanos / frames / 1_000_000.0}ms (not GPU time)")
        return true
    }

    private fun location(name: String) = checkNotNull(locations[name])
    private fun vector(name: String, v: Vector3) = GLES30.glUniform3f(location(name), v.x, v.y, v.z)

    private fun createProgram(): Int {
        fun shader(file: String, type: Int): Int {
            val source = assets.open("environments/$file").bufferedReader().use { it.readText() }
                .replace("#include \"orbital.glsl\"", assets.open("environments/orbital.glsl").bufferedReader().use { it.readText() })
            val id = GLES30.glCreateShader(type)
            GLES30.glShaderSource(id, source); GLES30.glCompileShader(id)
            val result = IntArray(1)
            GLES30.glGetShaderiv(id, GLES30.GL_COMPILE_STATUS, result, 0)
            check(result[0] == GLES30.GL_TRUE) { "$file: ${GLES30.glGetShaderInfoLog(id)}" }
            return id
        }
        val vertex = shader("orbital.vert", GLES30.GL_VERTEX_SHADER)
        val fragment = shader("orbital.frag", GLES30.GL_FRAGMENT_SHADER)
        val result = GLES30.glCreateProgram()
        GLES30.glAttachShader(result, vertex); GLES30.glAttachShader(result, fragment); GLES30.glLinkProgram(result)
        GLES30.glDeleteShader(vertex); GLES30.glDeleteShader(fragment)
        val status = IntArray(1)
        GLES30.glGetProgramiv(result, GLES30.GL_LINK_STATUS, status, 0)
        check(status[0] == GLES30.GL_TRUE) { GLES30.glGetProgramInfoLog(result) }
        return result
    }

    private fun makeCurrent(surface: EGLSurface) {
        check(EGL14.eglMakeCurrent(display, surface, surface, context)) { "Orbital EGL context lost" }
    }

    private fun checkGl() {
        val code = GLES30.glGetError()
        check(code == GLES30.GL_NO_ERROR) { "Orbital GL error 0x${code.toString(16)}" }
    }

    fun close() {
        closed = true
        enabled = false
        if (cleanupStarted.compareAndSet(false, true)) handler.post {
            fun attempt(label: String, operation: () -> Unit) {
                try { operation() } catch (error: Throwable) { Log.w("OrbitGPU", "Cleanup $label failed", error) }
            }
            try {
                // Context loss must not skip disconnecting the Android outputs.
                // A failed GL delete is harmless once its context is destroyed.
                if (context != EGL14.EGL_NO_CONTEXT && pbuffer != EGL14.EGL_NO_SURFACE) {
                    attempt("GL objects") {
                        makeCurrent(pbuffer)
                        if (program != 0) GLES30.glDeleteProgram(program)
                        if (textures.isNotEmpty()) GLES30.glDeleteTextures(textures.size, textures.values.toIntArray(), 0)
                    }
                }
                if (display != EGL14.EGL_NO_DISPLAY) {
                    attempt("unbind") { EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT) }
                    outputs.forEach { output -> attempt("window surface") { EGL14.eglDestroySurface(display, output) } }
                    if (pbuffer != EGL14.EGL_NO_SURFACE) attempt("pbuffer") { EGL14.eglDestroySurface(display, pbuffer) }
                    if (context != EGL14.EGL_NO_CONTEXT) attempt("context") { EGL14.eglDestroyContext(display, context) }
                    attempt("display") { EGL14.eglTerminate(display) }
                }
                attempt("thread") { EGL14.eglReleaseThread() }
            } finally { cleanupFinished.countDown(); worker.quitSafely() }
        }
        check(cleanupFinished.await(2, TimeUnit.SECONDS)) { "Orbital worker did not release its compositor surfaces" }
    }

    companion object { private const val FRAMEBUFFER_SRGB_EXT = 0x8DB9 }
}
