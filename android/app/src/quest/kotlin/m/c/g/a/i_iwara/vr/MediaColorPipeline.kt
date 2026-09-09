package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import android.graphics.SurfaceTexture
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES11Ext
import android.opengl.GLES30
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Process
import android.view.Surface
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Accepts the decoder directly, or the gallery's composed Android display.
 * The original full-resolution image stays on the GPU. A colour band and room
 * average, plus a compact video-halo lookup, cross back asynchronously.
 * GL resources belong exclusively to the worker. Close before the SDK panel.
 */
internal class MediaColorPipeline(
    private val assets: AssetManager,
    private val width: Int,
    private val height: Int,
    private val nativeVideoLayer: Boolean = false,
) {
    /**
     * [halo] and [band] are recycled between two readbacks: consume a [Colors]
     * before the next one arrives (the worker ticks once per scene tick).
     * [profile] is the shape the halo lookup was baked with.
     */
    data class Colors(val sequence: Long, val band: ByteArray, val average: FloatArray, val halo: ByteArray?, val profile: Profile?)
    data class Profile(val width: Float, val height: Float, val parent: Float, val immersive: Float,
        val intensity: Float, val feather: Float, val packing: Int, val hemisphere: Boolean, val disparity: Boolean)

    @Volatile var colors: Colors? = null
        private set
    @Volatile var failure: Throwable? = null
        private set
    @Volatile var copiedFrames: Long = 0
        private set
    @Volatile private var closed = false
    private val worker = HandlerThread("media-colour", Process.THREAD_PRIORITY_DISPLAY).apply { start() }
    private val handler = Handler(worker.looper)
    private val main = Handler(Looper.getMainLooper())
    private val tickQueued = AtomicBoolean(false)
    private var display: EGLDisplay = EGL14.EGL_NO_DISPLAY
    private var eglContext: EGLContext = EGL14.EGL_NO_CONTEXT
    private var pbuffer: EGLSurface = EGL14.EGL_NO_SURFACE
    private var output: EGLSurface = EGL14.EGL_NO_SURFACE
    private var outputDestination: Surface? = null
    private var config: EGLConfig? = null
    private var inputTexture: SurfaceTexture? = null
    private var inputSurface: Surface? = null
    private var oes = 0
    private var sourceProgram = 0
    private var filterProgram = 0
    private var nativeProgram = 0
    private var alphaProgram = 0
    private var haloProgram = 0
    private var framePending = false
    private var haveFrame = false
    private var eyeRect = floatArrayOf(0f, 0f, 1f, 1f)
    private var requestedEye = eyeRect
    private var profile: Profile? = null
    private var requestedProfile: Profile? = null
    private var alphaMask: Target? = null
    private var alphaProfile: Profile? = null
    private var halo: Target? = null
    private val readbackBytes = 132
    private val transform = FloatArray(16)
    private val targets = ArrayList<Target>()
    private lateinit var near: Target
    private lateinit var smooth: Target
    private lateinit var doubleSmooth: Target
    private lateinit var history: Array<Target>
    private lateinit var average: Target
    private var historyIndex = 0
    private var tick = 0L
    private var sequence = 0L
    private var readback = 0
    // Keep the small header independent of the 2D lookup. Packing both into one
    // PBO returned zero colour data on Quest; the live-frame probe catches this.
    private var haloReadback = 0
    private var fence = 0L
    private var queuedProfile: Profile? = null
    private val bandBuffers = arrayOf(ByteArray(128), ByteArray(128))
    private val haloBuffers = if (nativeVideoLayer) arrayOf(ByteArray(HALO_WIDTH * HALO_HEIGHT * 4), ByteArray(HALO_WIDTH * HALO_HEIGHT * 4)) else null
    private var readbackIndex = 0
    /** The callback runs on Android's main thread; detach the old producer there. */
    fun prepare(onInput: (Surface) -> Unit) {
        handler.post {
            guard {
                initialize()
                main.post { guard { onInput(checkNotNull(inputSurface)) } }
            }
        }
    }

    /** Call only AFTER the VirtualDisplay has disconnected from this surface. */
    fun attachOutput(surface: Surface) {
        handler.post {
            guard { outputDestination = surface }
        }
    }

    fun requestTick(crop: FloatArray, settings: Profile) {
        if (closed || failure != null || !tickQueued.compareAndSet(false, true)) return
        handler.post {
            try {
                guard {
                    requestedEye = crop
                    requestedProfile = settings
                    if (outputDestination != null) renderTick()
                }
            } finally { tickQueued.set(false) }
        }
    }

    private inline fun guard(block: () -> Unit) {
        if (closed || failure != null) return
        try { block() } catch (error: Throwable) { failure = error }
    }

    private inline fun <T> timed(label: String, block: () -> T): T {
        val started = System.nanoTime()
        return block().also {
            if (width >= 4096 && copiedFrames in 30L..34L)
                android.util.Log.i("MediaGPU", "$label CPU=${(System.nanoTime() - started) / 1_000_000.0}ms")
        }
    }

    private fun initialize() {
        display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        check(EGL14.eglInitialize(display, IntArray(2), 0, IntArray(2), 0)) { "EGL initialization failed" }
        val options = intArrayOf(
            EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8, EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_RENDERABLE_TYPE, 0x40, EGL14.EGL_SURFACE_TYPE, EGL14.EGL_WINDOW_BIT or EGL14.EGL_PBUFFER_BIT,
            EGL14.EGL_NONE,
        )
        val configs = arrayOfNulls<EGLConfig>(1)
        val count = IntArray(1)
        check(EGL14.eglChooseConfig(display, options, 0, configs, 0, 1, count, 0) && count[0] > 0)
        config = configs[0]
        eglContext = EGL14.eglCreateContext(display, config, EGL14.EGL_NO_CONTEXT,
            intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 3, EGL14.EGL_NONE), 0)
        check(eglContext != EGL14.EGL_NO_CONTEXT)
        pbuffer = EGL14.eglCreatePbufferSurface(display, config,
            intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0)
        makeCurrent(pbuffer)
        for (attribute in listOf(EGL14.EGL_SAMPLES, EGL14.EGL_DEPTH_SIZE, EGL14.EGL_STENCIL_SIZE, EGL14.EGL_CONFIG_ID)) {
            val value = IntArray(1)
            EGL14.eglGetConfigAttrib(display, config, attribute, value, 0)
            android.util.Log.i("MediaGPU", "EGL config $attribute=${value[0]}")
        }
        android.util.Log.i("MediaGPU", "renderer=${GLES30.glGetString(GLES30.GL_RENDERER)}")
        if (nativeVideoLayer) {
            check(GLES30.glGetString(GLES30.GL_EXTENSIONS).contains("GL_EXT_sRGB_write_control")) {
                "Native media output requires sRGB write control"
            }
            // The envelope is smooth over many pixels; a quarter-resolution mask
            // resampled bilinearly is indistinguishable and makes the per-drag
            // recompute (and the 16-bit storage) sixteen times cheaper at 4K.
            alphaMask = target((width / MASK_DIVISOR).coerceAtLeast(256), GLES30.GL_CLAMP_TO_EDGE,
                (height / MASK_DIVISOR).coerceAtLeast(144), GLES30.GL_R16F)
            nativeProgram = program("native_video.frag")
            alphaProgram = program("alpha.frag")
            haloProgram = program("halo.frag")
            halo = target(HALO_WIDTH, GLES30.GL_REPEAT, HALO_HEIGHT).also {
                GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, it.texture)
                GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)
            }
        }
        sourceProgram = program("source.frag")
        filterProgram = program("filter.frag")
        oes = generateTexture()
        GLES30.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, oes)
        parameters(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_CLAMP_TO_EDGE)
        GLES30.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_NEAREST)
        GLES30.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_NEAREST)
        inputTexture = SurfaceTexture(oes).apply {
            setDefaultBufferSize(width, height)
            setOnFrameAvailableListener({ framePending = true }, handler)
        }
        inputSurface = Surface(inputTexture)
        // Match the reference's RGBA8 UNorm intermediate targets, including its
        // clamped 512-pixel first strip and repeating subsequent colour strips.
        near = target(512, GLES30.GL_CLAMP_TO_EDGE)
        smooth = target(64, GLES30.GL_REPEAT)
        doubleSmooth = target(32, GLES30.GL_REPEAT)
        history = arrayOf(target(32, GLES30.GL_REPEAT), target(32, GLES30.GL_REPEAT))
        average = target(1, GLES30.GL_CLAMP_TO_EDGE)
        val ids = IntArray(1)
        GLES30.glGenBuffers(1, ids, 0)
        readback = ids[0]
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, readback)
        GLES30.glBufferData(GLES30.GL_PIXEL_PACK_BUFFER, readbackBytes, null, GLES30.GL_STREAM_READ)
        if (nativeVideoLayer) {
            GLES30.glGenBuffers(1, ids, 0)
            haloReadback = ids[0]
            GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, haloReadback)
            GLES30.glBufferData(GLES30.GL_PIXEL_PACK_BUFFER, HALO_WIDTH * HALO_HEIGHT * 4, null, GLES30.GL_STREAM_READ)
        }
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0)
        checkGl("initialize")
    }

    private fun renderTick() {
        timed("current pbuffer") { makeCurrent(pbuffer) }
        timed("receive") { receiveReadback() }
        val newFrame = framePending
        val cropChanged = !eyeRect.contentEquals(requestedEye)
        val profileChanged = profile != requestedProfile
        eyeRect = requestedEye
        profile = requestedProfile
        if (newFrame) {
            framePending = false
            timed("latch decoder") { inputTexture!!.updateTexImage() }
            inputTexture!!.getTransformMatrix(transform)
            haveFrame = true
        }
        if (!haveFrame) return
        if (nativeVideoLayer && alphaProfile != profile) {
            bind(checkNotNull(alphaMask))
            GLES30.glUseProgram(alphaProgram)
            configureProfile(alphaProgram)
            GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 3)
            alphaProfile = profile
        }
        if (newFrame || (nativeVideoLayer && profileChanged)) {
            if (output == EGL14.EGL_NO_SURFACE) {
                // VirtualDisplay.setSurface is a SurfaceFlinger transaction.
                // Its return does not mean the old producer has disconnected;
                // receiving the first frame on our input is the hand-off fence.
                val attributes = if (nativeVideoLayer) intArrayOf(0x309D, 0x3089, EGL14.EGL_NONE)
                    else intArrayOf(EGL14.EGL_NONE)
                output = EGL14.eglCreateWindowSurface(display, config, outputDestination, attributes, 0)
                check(output != EGL14.EGL_NO_SURFACE) { "Cannot connect media output after hand-off: EGL ${EGL14.eglGetError()}" }
            }
            timed("current output") { makeCurrent(output) }
            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, 0)
            if (copiedFrames == 0L) {
                val values = IntArray(1)
                GLES30.glGetIntegerv(GLES30.GL_SAMPLES, values, 0)
                android.util.Log.i("MediaGPU", "output samples=${values[0]}")
                for (attribute in listOf(EGL14.EGL_WIDTH, EGL14.EGL_HEIGHT, EGL14.EGL_SWAP_BEHAVIOR)) {
                    EGL14.eglQuerySurface(display, output, attribute, values, 0)
                    android.util.Log.i("MediaGPU", "EGL output $attribute=${values[0]}")
                }
                android.util.Log.i("MediaGPU", "decoder timestamp=${inputTexture!!.timestamp} wall=${System.nanoTime()}")
            }
            GLES30.glViewport(0, 0, width, height)
            // Tile GPUs otherwise load the previous full 8K surface before a
            // draw that overwrites every pixel. Mark it discardable with a clear.
            GLES30.glClearColor(0f, 0f, 0f, 0f)
            GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
            if (nativeVideoLayer) {
                GLES30.glDisable(FRAMEBUFFER_SRGB_EXT)
                timed("draw native") { drawNativeVideo() }
                GLES30.glEnable(FRAMEBUFFER_SRGB_EXT)
            } else drawSource(0)
            check(timed("swap output") { EGL14.eglSwapBuffers(display, output) }) { "Media output swap failed" }
            copiedFrames++
            makeCurrent(pbuffer)
        }
        if (newFrame || cropChanged) {
            bind(near); drawSource(1)
            bind(smooth); drawFilter(near.texture, 1)
            bind(doubleSmooth); drawFilter(smooth.texture, 2)
            bind(average); drawSource(2)
        }
        // The temporal band advances on every other frame.
        if (tick++ % 2L == 0L) {
            val previous = history[historyIndex]
            historyIndex = 1 - historyIndex
            bind(history[historyIndex])
            drawFilter(doubleSmooth.texture, 3, previous.texture)
            halo?.let {
                bind(it)
                GLES30.glUseProgram(haloProgram)
                configureProfile(haloProgram)
                GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
                GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, history[historyIndex].texture)
                GLES30.glUniform1i(GLES30.glGetUniformLocation(haloProgram, "source"), 0)
                GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 3)
            }
            if (fence == 0L) {
                queuedProfile = profile
                queueReadback()
            }
        }
        checkGl("filter")
    }

    private fun queueReadback() {
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, readback)
        bind(history[historyIndex])
        GLES30.glReadPixels(0, 0, 32, 1, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, 0)
        bind(average)
        GLES30.glReadPixels(0, 0, 1, 1, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, 128)
        halo?.let {
            bind(it)
            GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, haloReadback)
            GLES30.glReadPixels(0, 0, HALO_WIDTH, HALO_HEIGHT, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, 0)
        }
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0)
        fence = GLES30.glFenceSync(GLES30.GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
        GLES30.glFlush()
    }

    private fun receiveReadback() {
        if (fence == 0L) return
        when (GLES30.glClientWaitSync(fence, 0, 0L)) {
            GLES30.GL_TIMEOUT_EXPIRED -> return
            GLES30.GL_WAIT_FAILED -> error("Media colour readback fence failed")
        }
        GLES30.glDeleteSync(fence)
        fence = 0L
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, readback)
        val bytes = GLES30.glMapBufferRange(GLES30.GL_PIXEL_PACK_BUFFER, 0, readbackBytes, GLES30.GL_MAP_READ_BIT) as? ByteBuffer
        checkNotNull(bytes) { "Media colour readback unavailable" }
        readbackIndex = 1 - readbackIndex
        val band = bandBuffers[readbackIndex]
        bytes.get(band)
        val rgb = FloatArray(3) { (bytes.get().toInt() and 255) / 255f }
        check(GLES30.glUnmapBuffer(GLES30.GL_PIXEL_PACK_BUFFER))
        val haloBytes = haloBuffers?.get(readbackIndex)?.also {
            GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, haloReadback)
            val pixels = GLES30.glMapBufferRange(GLES30.GL_PIXEL_PACK_BUFFER, 0, it.size, GLES30.GL_MAP_READ_BIT) as? ByteBuffer
            checkNotNull(pixels).get(it)
            check(GLES30.glUnmapBuffer(GLES30.GL_PIXEL_PACK_BUFFER))
        }
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0)
        colors = Colors(++sequence, band, rgb, haloBytes, queuedProfile)
    }

    private fun drawSource(operation: Int) {
        GLES30.glUseProgram(sourceProgram)
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, oes)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(sourceProgram, "source"), 0)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(sourceProgram, "operation"), operation)
        GLES30.glUniformMatrix4fv(GLES30.glGetUniformLocation(sourceProgram, "sourceTransform"), 1, false, transform, 0)
        GLES30.glUniform4fv(GLES30.glGetUniformLocation(sourceProgram, "eyeRect"), 1, eyeRect, 0)
        GLES30.glUniform2f(GLES30.glGetUniformLocation(sourceProgram, "sourceSize"), width.toFloat(), height.toFloat())
        GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 3)
    }

    private fun configureProfile(program: Int) {
        profile?.let {
            GLES30.glUniform4f(GLES30.glGetUniformLocation(program, "profileDimensions"), it.width, it.height, it.parent, it.immersive)
            GLES30.glUniform4f(GLES30.glGetUniformLocation(program, "profileSettings"), it.intensity, it.feather,
                it.packing.toFloat(), if (it.hemisphere) 1f else 0f)
            GLES30.glUniform1i(GLES30.glGetUniformLocation(program, "correctDisparity"), if (it.disparity) 1 else 0)
        }
    }

    private fun drawNativeVideo() {
        GLES30.glUseProgram(nativeProgram)
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, oes)
        GLES30.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(nativeProgram, "source"), 0)
        GLES30.glUniformMatrix4fv(GLES30.glGetUniformLocation(nativeProgram, "sourceTransform"), 1, false, transform, 0)
        GLES30.glActiveTexture(GLES30.GL_TEXTURE1)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, checkNotNull(alphaMask).texture)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(nativeProgram, "alphaMask"), 1)
        configureProfile(nativeProgram)
        GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 3)
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_NEAREST)
        GLES30.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_NEAREST)
    }

    private fun drawFilter(texture: Int, operation: Int, previous: Int = texture) {
        GLES30.glUseProgram(filterProgram)
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, texture)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(filterProgram, "source"), 0)
        GLES30.glActiveTexture(GLES30.GL_TEXTURE1)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, previous)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(filterProgram, "history"), 1)
        GLES30.glUniform1i(GLES30.glGetUniformLocation(filterProgram, "operation"), operation)
        GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 3)
    }

    private data class Target(val texture: Int, val framebuffer: Int, val width: Int, val height: Int)
    private fun target(size: Int, wrap: Int, height: Int = 1, format: Int = GLES30.GL_RGBA8): Target {
        val texture = generateTexture()
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, texture)
        parameters(GLES30.GL_TEXTURE_2D, wrap)
        GLES30.glTexStorage2D(GLES30.GL_TEXTURE_2D, 1, format, size, height)
        val id = IntArray(1)
        GLES30.glGenFramebuffers(1, id, 0)
        val result = Target(texture, id[0], size, height)
        targets.add(result)
        bind(result)
        GLES30.glFramebufferTexture2D(GLES30.GL_FRAMEBUFFER, GLES30.GL_COLOR_ATTACHMENT0, GLES30.GL_TEXTURE_2D, texture, 0)
        check(GLES30.glCheckFramebufferStatus(GLES30.GL_FRAMEBUFFER) == GLES30.GL_FRAMEBUFFER_COMPLETE)
        GLES30.glClearColor(0f, 0f, 0f, 0f)
        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
        return result
    }

    private fun bind(target: Target) {
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, target.framebuffer)
        GLES30.glViewport(0, 0, target.width, target.height)
    }

    private fun parameters(target: Int, wrap: Int) {
        GLES30.glTexParameteri(target, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(target, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(target, GLES30.GL_TEXTURE_WRAP_S, wrap)
        GLES30.glTexParameteri(target, GLES30.GL_TEXTURE_WRAP_T, wrap)
    }

    private fun generateTexture(): Int = IntArray(1).also { GLES30.glGenTextures(1, it, 0) }[0]

    private fun program(fragment: String): Int {
        fun shader(file: String, kind: Int): Int {
            val handle = GLES30.glCreateShader(kind)
            val code = assets.open("media-effects/$file").bufferedReader().use { it.readText() }
                .replace("#include \"media_profile.glsl\"", assets.open("media_profile.glsl").bufferedReader().use { it.readText() })
            GLES30.glShaderSource(handle, code)
            GLES30.glCompileShader(handle)
            val status = IntArray(1)
            GLES30.glGetShaderiv(handle, GLES30.GL_COMPILE_STATUS, status, 0)
            check(status[0] == GLES30.GL_TRUE) { "$file: ${GLES30.glGetShaderInfoLog(handle)}" }
            return handle
        }
        val vertex = shader("fullscreen.vert", GLES30.GL_VERTEX_SHADER)
        val pixel = shader(fragment, GLES30.GL_FRAGMENT_SHADER)
        val program = GLES30.glCreateProgram()
        GLES30.glAttachShader(program, vertex)
        GLES30.glAttachShader(program, pixel)
        GLES30.glLinkProgram(program)
        GLES30.glDeleteShader(vertex)
        GLES30.glDeleteShader(pixel)
        val status = IntArray(1)
        GLES30.glGetProgramiv(program, GLES30.GL_LINK_STATUS, status, 0)
        check(status[0] == GLES30.GL_TRUE) { GLES30.glGetProgramInfoLog(program) }
        return program
    }

    private fun makeCurrent(surface: EGLSurface) {
        check(EGL14.eglMakeCurrent(display, surface, surface, eglContext)) { "Media EGL context lost" }
    }

    private fun checkGl(stage: String) {
        val error = GLES30.glGetError()
        check(error == GLES30.GL_NO_ERROR) { "Media GL $stage: 0x${error.toString(16)}" }
    }

    fun close() {
        if (closed) return
        closed = true
        val finished = CountDownLatch(1)
        handler.post {
            try {
                if (eglContext != EGL14.EGL_NO_CONTEXT && pbuffer != EGL14.EGL_NO_SURFACE) {
                    makeCurrent(pbuffer)
                    if (fence != 0L) GLES30.glDeleteSync(fence)
                    if (readback != 0) GLES30.glDeleteBuffers(1, intArrayOf(readback), 0)
                    if (haloReadback != 0) GLES30.glDeleteBuffers(1, intArrayOf(haloReadback), 0)
                    targets.forEach {
                        GLES30.glDeleteTextures(1, intArrayOf(it.texture), 0)
                        GLES30.glDeleteFramebuffers(1, intArrayOf(it.framebuffer), 0)
                    }
                    GLES30.glDeleteTextures(1, intArrayOf(oes), 0)
                    GLES30.glDeleteProgram(sourceProgram)
                    GLES30.glDeleteProgram(filterProgram)
                    GLES30.glDeleteProgram(nativeProgram)
                    GLES30.glDeleteProgram(alphaProgram)
                    GLES30.glDeleteProgram(haloProgram)
                    EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
                }
                if (output != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(display, output)
                if (pbuffer != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(display, pbuffer)
                if (eglContext != EGL14.EGL_NO_CONTEXT) EGL14.eglDestroyContext(display, eglContext)
                inputSurface?.release()
                inputTexture?.release()
                if (display != EGL14.EGL_NO_DISPLAY) EGL14.eglTerminate(display)
                EGL14.eglReleaseThread()
            } finally {
                finished.countDown()
                worker.quitSafely()
            }
        }
        check(finished.await(2, TimeUnit.SECONDS)) { "Media GPU worker did not release the panel output" }
    }

    companion object {
        // Four texels per band knot and about 70 rows across the feather: the
        // 512 KB version cost a 36 Hz upload for no visible gain.
        const val HALO_WIDTH = 128
        const val HALO_HEIGHT = 256
        private const val MASK_DIVISOR = 4
        private const val FRAMEBUFFER_SRGB_EXT = 0x8DB9
    }
}
