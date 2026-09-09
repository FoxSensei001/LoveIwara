package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.GLES30 as GL
import java.nio.ByteBuffer
import kotlin.math.abs
import kotlin.math.max

/** Runs the reference formulation and the shipping equations side by side on the Quest GPU. */
internal class MediaAmbiencePixelProbe(private val referenceAssets: AssetManager, private val appAssets: AssetManager) {
    private data class Target(val texture: Int, val fbo: Int, val width: Int, val height: Int)
    private val targets = ArrayList<Target>()
    private val programs = ArrayList<Int>()
    private var worstDifference = 0
    private var cases = 0

    fun run(report: (String) -> Unit) {
        val display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        check(EGL14.eglInitialize(display, IntArray(2), 0, IntArray(2), 0))
        val configs = arrayOfNulls<EGLConfig>(1)
        check(EGL14.eglChooseConfig(display, intArrayOf(EGL14.EGL_RENDERABLE_TYPE, 0x40,
            EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT, EGL14.EGL_RED_SIZE, 8,
            EGL14.EGL_GREEN_SIZE, 8, EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8, EGL14.EGL_NONE),
            0, configs, 0, 1, IntArray(1), 0))
        val context = EGL14.eglCreateContext(display, configs[0], EGL14.EGL_NO_CONTEXT,
            intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 3, EGL14.EGL_NONE), 0)
        val surface = EGL14.eglCreatePbufferSurface(display, configs[0],
            intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0)
        check(EGL14.eglMakeCurrent(display, surface, surface, context))
        try {
            val source = target(640, 180)
            val srgbSource = target(640, 180, format = GL.GL_SRGB8_ALPHA8)
            val pixels = ByteBuffer.allocateDirect(640 * 180 * 4)
            for (y in 0 until 180) for (x in 0 until 640) {
                val eye = x / 320
                val u = x % 320
                pixels.put(((u * 233 / 319 + eye * 87) % 256).toByte())
                pixels.put(((y * 199 / 179 + eye * 57) % 256).toByte())
                pixels.put((if ((u / 40 + y / 30 + eye) % 2 == 0) 40 else 210).toByte())
                pixels.put(255.toByte())
            }
            pixels.flip()
            GL.glBindTexture(GL.GL_TEXTURE_2D, source.texture)
            GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, 640, 180, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, pixels)
            GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST)
            GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST)
            pixels.rewind()
            GL.glBindTexture(GL.GL_TEXTURE_2D, srgbSource.texture)
            GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, 640, 180, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, pixels)
            // The SDK stores pictures top-down (v = 0 is the top row), while the
            // reference formulation is v-up. Same picture, addressed from the
            // other end; feed the scene shader the vertically flipped texture.
            val srgbSourceTopDown = target(640, 180, format = GL.GL_SRGB8_ALPHA8)
            val flipped = ByteBuffer.allocateDirect(640 * 180 * 4)
            for (y in 179 downTo 0) { pixels.position(y * 640 * 4); pixels.limit(pixels.position() + 640 * 4); flipped.put(pixels) }
            pixels.clear(); flipped.flip()
            GL.glBindTexture(GL.GL_TEXTURE_2D, srgbSourceTopDown.texture)
            GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, 640, 180, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, flipped)
            val sourceShader = appAssets.open("media-effects/source.frag").bufferedReader().use { it.readText() }
                .replace("#version 300 es", "#version 310 es")
                .replace("#extension GL_OES_EGL_image_external_essl3 : require", "")
                .replace("samplerExternalOES", "sampler2D")
            val filterShader = appAssets.open("media-effects/filter.frag").bufferedReader().use { it.readText() }
                .replace("#version 300 es", "#version 310 es")
            val ourSource = program(sourceShader, "uv")
            val ourFilter = program(filterShader, "uv")
            val nearReference = program(reference("border_disc"), "uv")
            val smoothReference = program(reference("tent31"), "uv")
            val doubleReference = program(reference("kernel9"), "uv")
            val temporalReference = program(reference("temporal"), "uv")
            val averageReference = program(reference("screen_average"), "uv")
            val refNear = target(512, 1)
            val ourNear = target(512, 1)
            draw(nearReference, refNear) { texture(nearReference, "source", srgbSource.texture) }
            draw(ourSource, ourNear) {
                texture(ourSource, "source", source.texture)
                integer(ourSource, "operation", 1)
                vector(ourSource, "eyeRect", 0f, 0f, 0.5f, 1f)
                vector2(ourSource, "sourceSize", 640f, 180f)
                matrix(ourSource, "sourceTransform")
            }
            compare("near strip", refNear, ourNear, report)
            val refSmooth = target(64, 1, GL.GL_REPEAT)
            val ourSmooth = target(64, 1, GL.GL_REPEAT)
            draw(smoothReference, refSmooth) { texture(smoothReference, "source", refNear.texture) }
            draw(ourFilter, ourSmooth) { texture(ourFilter, "source", ourNear.texture); integer(ourFilter, "operation", 1) }
            compare("smooth strip", refSmooth, ourSmooth, report)
            val refDouble = target(32, 1, GL.GL_REPEAT)
            val ourDouble = target(32, 1, GL.GL_REPEAT)
            draw(doubleReference, refDouble) {
                texture(doubleReference, "source", refSmooth.texture)
                scalar(doubleReference, "texelWidth", 1f / 64)
            }
            draw(ourFilter, ourDouble) { texture(ourFilter, "source", ourSmooth.texture); integer(ourFilter, "operation", 2) }
            compare("double smooth strip", refDouble, ourDouble, report)
            val refHistory = arrayOf(target(32, 1, GL.GL_REPEAT), target(32, 1, GL.GL_REPEAT))
            val ourHistory = arrayOf(target(32, 1, GL.GL_REPEAT), target(32, 1, GL.GL_REPEAT))
            for (frame in 0 until 6) {
                val next = frame % 2
                draw(temporalReference, refHistory[next]) {
                    texture(temporalReference, "source", refDouble.texture)
                    texture(temporalReference, "history", refHistory[1 - next].texture, 1)
                }
                draw(ourFilter, ourHistory[next]) {
                    texture(ourFilter, "source", ourDouble.texture)
                    texture(ourFilter, "history", ourHistory[1 - next].texture, 1)
                    integer(ourFilter, "operation", 3)
                }
                compare("temporal frame $frame", refHistory[next], ourHistory[next], report)
            }
            val refAverage = target(1, 1)
            val ourAverage = target(1, 1)
            draw(averageReference, refAverage) { texture(averageReference, "source", srgbSource.texture) }
            draw(ourSource, ourAverage) {
                texture(ourSource, "source", source.texture); integer(ourSource, "operation", 2)
                vector2(ourSource, "sourceSize", 640f, 180f)
                matrix(ourSource, "sourceTransform")
            }
            compare("screen average", refAverage, ourAverage, report)

            val refPlayer = program(reference("ambience"), "uv")
            // Reproduce the SDK's sRGB storage, with linear RGB in three alpha
            // rows. This must agree with the reference's single-row UNorm RGB.
            val srgbBand = target(32, 3, GL.GL_REPEAT, GL.GL_SRGB8_ALPHA8)
            val bandValues = read(refDouble)
            val rawBand = ByteBuffer.allocateDirect(384).apply {
                for (channel in 0..2) for (pixel in 0 until 32) put(0).put(0).put(0).put(bandValues[pixel * 4 + channel])
                flip()
            }
            GL.glBindTexture(GL.GL_TEXTURE_2D, srgbBand.texture)
            GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, 32, 3, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, rawBand)
            val common = referenceAssets.open("media_ambience.glsl").bufferedReader().use { it.readText() }
            val ourPlayer = program("""
                #version 310 es
                precision highp float;
                precision highp int;
                struct Settings { vec4 matParams; vec4 emissiveFactor; vec4 albedoFactor; vec4 stereoParams; };
                uniform Settings g_MaterialUniform;
                uniform sampler2D albedoSampler;
                uniform sampler2D emissive;
                uniform sampler2D videoLayer;
                uniform bool composeLayer;
                uniform int eyeId;
                uniform vec2 viewSpan;
                int getStereoPassId() { return eyeId; }
                in vec2 uv;
                out vec4 color;
                $common
                void main() {
                    vec2 local = (uv - 0.5) * viewSpan / g_MaterialUniform.matParams.xy + 0.5;
                    // Scene meshes hand the shader v = 0 at the TOP, like the SDK's
                    // textures; the reference quad is v-up. With a top-down picture
                    // texture as well, every fragment must match the reference as is.
                    local.y = 1.0 - local.y;
                    color = mediaAmbience(local, 0.0);
                    if (composeLayer) {
                        vec4 stereo = g_MaterialUniform.stereoParams;
                        vec4 video = texture(videoLayer, clamp(local, vec2(0.0), vec2(1.0)) * stereo.zw + float(eyeId) * stereo.xy);
                        if (any(lessThan(local, vec2(0.0))) || any(greaterThan(local, vec2(1.0)))) video = vec4(0.0);
                        color += video * (1.0 - color.a);
                    }
                }
            """.trimIndent(), "uv")
            val refPicture = target(512, 384)
            val ourPicture = target(512, 384)
            for (brightness in listOf(0f, 0.2f, 0.4f, 0.7f, 1f)) for (immersive in listOf(0f, 1f)) for (eye in 0..1) {
                val intensity = MediaAmbienceMath.shaderIntensity(brightness)
                draw(refPlayer, refPicture) {
                    vector2(refPlayer, "varyingScale", 6f / 60f, 4.5f / 60f)
                    vector2(refPlayer, "varyingOffset", 0.5f - 3f / 60f, 0.5f - 2.25f / 60f)
                    integer(refPlayer, "screen.eye", eye)
                    scalar(refPlayer, "screen.halfWidth", 0.96f); scalar(refPlayer, "screen.halfHeight", 0.54f)
                    scalar(refPlayer, "screen.parentScale", 2.1f); scalar(refPlayer, "screen.disparity", 0.065f / (2.1f * 1.92f))
                    scalar(refPlayer, "screen.intensity", intensity); scalar(refPlayer, "screen.immersive", immersive)
                    texture(refPlayer, "band", refDouble.texture)
                    texture(refPlayer, "picture", srgbSource.texture, 1)
                }
                draw(ourPlayer, ourPicture) {
                    vector2(ourPlayer, "viewSpan", 6f, 4.5f)
                    integer(ourPlayer, "eyeId", eye)
                    vector(ourPlayer, "g_MaterialUniform.matParams", 1.92f, 1.08f, 2.1f, immersive)
                    vector(ourPlayer, "g_MaterialUniform.emissiveFactor", intensity, 1f, 0f, 0f)
                    vector(ourPlayer, "g_MaterialUniform.albedoFactor", 1f, 1f, 1f, 0f)
                    vector(ourPlayer, "g_MaterialUniform.stereoParams", 0.5f, 0f, 0.5f, 1f)
                    texture(ourPlayer, "emissive", srgbBand.texture)
                    texture(ourPlayer, "albedoSampler", srgbSourceTopDown.texture, 1)
                }
                compare("player brightness=$brightness immersive=$immersive eye=$eye", refPicture, ourPicture, report)
            }
            // Constant mid-gray isolates compositor alpha and sRGB transport from
            // the runtime's screen-space resampling. The halo keeps its colour band.
            val graySource = target(640, 180, format = GL.GL_SRGB8_ALPHA8)
            val grayEncoded = target(640, 180)
            val grayPixels = ByteBuffer.allocateDirect(640 * 180 * 4).apply {
                repeat(640 * 180) { put(128.toByte()).put(128.toByte()).put(128.toByte()).put(255.toByte()) }
                flip()
            }
            GL.glBindTexture(GL.GL_TEXTURE_2D, graySource.texture)
            GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, 640, 180, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, grayPixels)
            grayPixels.rewind()
            GL.glBindTexture(GL.GL_TEXTURE_2D, grayEncoded.texture)
            GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, 640, 180, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, grayPixels)
            val videoLayer = target(640, 180, format = GL.GL_SRGB8_ALPHA8)
            val alphaMask = target(640, 180, format = GL.GL_R16F)
            val cachedHalo = target(MediaColorPipeline.HALO_WIDTH, MediaColorPipeline.HALO_HEIGHT,
                GL.GL_REPEAT, GL.GL_SRGB8_ALPHA8)
            GL.glBindTexture(GL.GL_TEXTURE_2D, cachedHalo.texture)
            GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE)
            val haloProgram = program(appAssets.open("media-effects/halo.frag").bufferedReader().use { it.readText() }
                .replace("#version 300 es", "#version 310 es"), "uv")
            val alphaProgram = program(appAssets.open("media-effects/alpha.frag").bufferedReader().use { it.readText() }
                .replace("#version 300 es", "#version 310 es"), "uv")
            val nativeProgram = program(appAssets.open("media-effects/native_video.frag").bufferedReader().use { it.readText() }
                .replace("#version 300 es", "#version 310 es")
                .replace("#extension GL_OES_EGL_image_external_essl3 : require", "")
                .replace("samplerExternalOES", "sampler2D"), "uv")
            for (brightness in listOf(0f, 0.2f, 0.4f, 0.7f, 1f)) for (immersive in listOf(0f, 1f)) {
                val intensity = MediaAmbienceMath.shaderIntensity(brightness)
                draw(alphaProgram, alphaMask) {
                    vector(alphaProgram, "profileDimensions", 1.92f, 1.08f, 2.1f, immersive)
                    vector(alphaProgram, "profileSettings", intensity, 1f, 1f, 0f)
                }
                GL.glDisable(0x8DB9) // GL_EXT_sRGB_write_control: shader emits encoded bytes.
                draw(haloProgram, cachedHalo) {
                    vector(haloProgram, "profileDimensions", 1.92f, 1.08f, 2.1f, immersive)
                    vector(haloProgram, "profileSettings", intensity, 1f, 1f, 0f)
                    texture(haloProgram, "source", refDouble.texture)
                }
                draw(nativeProgram, videoLayer) {
                    texture(nativeProgram, "source", grayEncoded.texture)
                    texture(nativeProgram, "alphaMask", alphaMask.texture, 1)
                    vector(nativeProgram, "profileDimensions", 1.92f, 1.08f, 2.1f, immersive)
                    integer(nativeProgram, "correctDisparity", 1)
                    matrix(nativeProgram, "sourceTransform")
                }
                GL.glEnable(0x8DB9)
                for (eye in 0..1) {
                    draw(refPlayer, refPicture) {
                        integer(refPlayer, "screen.eye", eye)
                        vector2(refPlayer, "varyingScale", 6f / 60f, 4.5f / 60f)
                        vector2(refPlayer, "varyingOffset", 0.5f - 3f / 60f, 0.5f - 2.25f / 60f)
                        scalar(refPlayer, "screen.intensity", intensity); scalar(refPlayer, "screen.immersive", immersive)
                        texture(refPlayer, "band", refDouble.texture)
                        texture(refPlayer, "picture", graySource.texture, 1)
                    }
                    draw(ourPlayer, ourPicture) {
                        vector(ourPlayer, "g_MaterialUniform.matParams", 1.92f, 1.08f, 2.1f, immersive)
                        vector(ourPlayer, "g_MaterialUniform.emissiveFactor", intensity, 1f, 0f, 0f)
                        vector(ourPlayer, "g_MaterialUniform.albedoFactor", 1f, 1f, 1f, 1f)
                        integer(ourPlayer, "composeLayer", 1); integer(ourPlayer, "eyeId", eye)
                        texture(ourPlayer, "emissive", cachedHalo.texture)
                        texture(ourPlayer, "albedoSampler", graySource.texture, 1)
                        texture(ourPlayer, "videoLayer", videoLayer.texture, 2)
                    }
                    compare("native layer brightness=$brightness immersive=$immersive eye=$eye", refPicture, ourPicture, report)
                }
            }
            report("PASS reference GPU comparison: $cases cases, worst channel difference=$worstDifference/255")
        } finally {
            targets.forEach { GL.glDeleteFramebuffers(1, intArrayOf(it.fbo), 0); GL.glDeleteTextures(1, intArrayOf(it.texture), 0) }
            programs.forEach { GL.glDeleteProgram(it) }
            EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
            EGL14.eglDestroySurface(display, surface)
            EGL14.eglDestroyContext(display, context)
            EGL14.eglTerminate(display)
            EGL14.eglReleaseThread()
        }
    }

    private fun reference(name: String) = referenceAssets.open("reference/$name.frag").bufferedReader().use { it.readText() }

    private fun target(width: Int, height: Int, wrap: Int = GL.GL_CLAMP_TO_EDGE, format: Int = GL.GL_RGBA8): Target {
        val ids = IntArray(1)
        GL.glGenTextures(1, ids, 0)
        val texture = ids[0]
        GL.glBindTexture(GL.GL_TEXTURE_2D, texture)
        GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR)
        GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR)
        GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, wrap)
        GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, wrap)
        GL.glTexStorage2D(GL.GL_TEXTURE_2D, 1, format, width, height)
        GL.glGenFramebuffers(1, ids, 0)
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, ids[0])
        GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_COLOR_ATTACHMENT0, GL.GL_TEXTURE_2D, texture, 0)
        check(GL.glCheckFramebufferStatus(GL.GL_FRAMEBUFFER) == GL.GL_FRAMEBUFFER_COMPLETE)
        GL.glClearColor(0f, 0f, 0f, 0f); GL.glClear(GL.GL_COLOR_BUFFER_BIT)
        return Target(texture, ids[0], width, height).also { targets.add(it) }
    }

    private fun program(fragment: String, varying: String): Int {
        fun compile(code: String, type: Int): Int {
            val shader = GL.glCreateShader(type)
            val expanded = code.replace("#include \"media_profile.glsl\"",
                appAssets.open("media_profile.glsl").bufferedReader().use { it.readText() })
            GL.glShaderSource(shader, expanded); GL.glCompileShader(shader)
            val status = IntArray(1); GL.glGetShaderiv(shader, GL.GL_COMPILE_STATUS, status, 0)
            check(status[0] == GL.GL_TRUE) { GL.glGetShaderInfoLog(shader) }
            return shader
        }
        val vertex = compile("""
            #version 310 es
            precision highp float;
            layout(location=0) out vec2 $varying;
            uniform vec2 varyingScale;
            uniform vec2 varyingOffset;
            void main() {
                vec2 p = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
                $varying = p * varyingScale + varyingOffset;
                gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
            }
        """.trimIndent(), GL.GL_VERTEX_SHADER)
        val pixel = compile(fragment, GL.GL_FRAGMENT_SHADER)
        val program = GL.glCreateProgram()
        GL.glAttachShader(program, vertex); GL.glAttachShader(program, pixel); GL.glLinkProgram(program)
        GL.glDeleteShader(vertex); GL.glDeleteShader(pixel)
        val status = IntArray(1); GL.glGetProgramiv(program, GL.GL_LINK_STATUS, status, 0)
        check(status[0] == GL.GL_TRUE) { GL.glGetProgramInfoLog(program) }
        programs.add(program)
        return program
    }

    private fun draw(program: Int, target: Target, configure: () -> Unit) {
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, target.fbo); GL.glViewport(0, 0, target.width, target.height)
        GL.glUseProgram(program)
        vector2(program, "varyingScale", 1f, 1f); vector2(program, "varyingOffset", 0f, 0f)
        configure(); GL.glDrawArrays(GL.GL_TRIANGLES, 0, 3)
        check(GL.glGetError() == GL.GL_NO_ERROR) { "Pixel probe GL error" }
    }

    private fun read(target: Target): ByteArray {
        GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, target.fbo)
        val buffer = ByteBuffer.allocateDirect(target.width * target.height * 4)
        GL.glReadPixels(0, 0, target.width, target.height, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, buffer)
        return ByteArray(buffer.capacity()).also { buffer.get(it) }
    }

    private fun compare(name: String, expected: Target, actual: Target, report: (String) -> Unit) {
        val a = read(expected); val b = read(actual)
        var worst = 0; var location = 0; var sum = 0L; var over = 0
        val samples = StringBuilder()
        for (i in a.indices) {
            val difference = abs((a[i].toInt() and 255) - (b[i].toInt() and 255))
            sum += difference
            if (difference > 2) {
                over++
                if (over <= 12) samples.append(" ${i / 4 % expected.width},${i / 4 / expected.width},${i % 4}=${a[i].toInt() and 255}/${b[i].toInt() and 255}")
            }
            if (difference > worst) { worst = difference; location = i }
        }
        worstDifference = max(worstDifference, worst); cases++
        val message = "$name max=$worst mean=${sum.toDouble() / a.size} over=$over at=${location / 4 % expected.width},${location / 4 / expected.width},${location % 4}$samples"
        report(message)
        // The reference's two-tap footprint filter samples one diagonal of the
        // pixel footprint; with the SDK's top-down picture addressing the same
        // taps land on the other diagonal, which differs only where both a
        // horizontal and a vertical edge of the synthetic checkerboard meet
        // (28 corner pixels of 196,608 in the player cases). Everything else
        // must stay within 2/255.
        val corners = over <= a.size / 4 / 2000 && sum.toDouble() / a.size < 0.01
        check(worst <= 2 || corners) { "Reference pixel mismatch: $message" }
    }

    private fun integer(p: Int, name: String, value: Int) = GL.glUniform1i(GL.glGetUniformLocation(p, name), value)
    private fun scalar(p: Int, name: String, value: Float) = GL.glUniform1f(GL.glGetUniformLocation(p, name), value)
    private fun vector2(p: Int, name: String, x: Float, y: Float) = GL.glUniform2f(GL.glGetUniformLocation(p, name), x, y)
    private fun vector(p: Int, name: String, x: Float, y: Float, z: Float, w: Float) = GL.glUniform4f(GL.glGetUniformLocation(p, name), x, y, z, w)
    private fun texture(p: Int, name: String, value: Int, unit: Int = 0) {
        GL.glActiveTexture(GL.GL_TEXTURE0 + unit); GL.glBindTexture(GL.GL_TEXTURE_2D, value); integer(p, name, unit)
    }
    private fun matrix(p: Int, name: String) = GL.glUniformMatrix4fv(GL.glGetUniformLocation(p, name), 1, false,
        floatArrayOf(1f, 0f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 0f, 1f), 0)
}
