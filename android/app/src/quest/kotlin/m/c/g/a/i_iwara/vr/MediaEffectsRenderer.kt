package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import android.graphics.Color
import android.view.Surface
import com.meta.spatial.runtime.AddressMode
import com.meta.spatial.runtime.Filter
import com.meta.spatial.runtime.MaterialSidedness
import com.meta.spatial.runtime.PanelSurface
import com.meta.spatial.runtime.SamplerConfig
import java.nio.ByteBuffer
import com.meta.spatial.core.Lut
import com.meta.spatial.core.Pose
import com.meta.spatial.core.SpatialSDKExperimentalAPI
import com.meta.spatial.core.Vector3
import com.meta.spatial.core.Vector4
import com.meta.spatial.runtime.AlphaMode
import com.meta.spatial.runtime.BlendFactor
import com.meta.spatial.runtime.LayerAlphaBlend
import com.meta.spatial.runtime.DepthWrite
import com.meta.spatial.runtime.PanelConfigOptions
import com.meta.spatial.runtime.PanelSceneObject
import com.meta.spatial.runtime.Scene
import com.meta.spatial.runtime.SceneMaterial
import com.meta.spatial.runtime.SceneMesh
import com.meta.spatial.runtime.SceneObject
import com.meta.spatial.runtime.SceneTexture
import com.meta.spatial.runtime.SortOrder
import com.meta.spatial.runtime.StereoMode
import com.meta.spatial.toolkit.PanelStyleOptions
import m.c.g.a.i_iwara.questui.MediaEffectsSettings
import m.c.g.a.i_iwara.questui.Projection
import m.c.g.a.i_iwara.questui.StereoPacking
import m.c.g.a.i_iwara.questui.VideoFormat
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin

/**
 * Videos use an alpha-processed native compositor layer; the scene draws its
 * halo above it. The two alphas factor the reference's continuous RGBA exactly.
 * Gallery frames share one mesh with their halo, preserving PNG/crossfade alpha.
 * The video halo is cached in angle/distance coordinates, so its broad tail
 * requires one lookup per scene fragment instead of repeated colour/profile math.
 *
 * The panel owns its texture. Detach the glow BEFORE destroying/replacing that panel.
 */
@OptIn(SpatialSDKExperimentalAPI::class)
internal class MediaEffectsRenderer(private val scene: Scene, private val assets: AssetManager) {
    private var sourcePanel: PanelSceneObject? = null
    private var glowObject: SceneObject? = null
    private var glowMesh: SceneMesh? = null
    private var glowMaterial: SceneMaterial? = null
    private var geometry: GlowGeometry? = null
    private var materialState: MaterialState? = null
    private var objectPose: Pose? = null
    private var objectVisible: Boolean? = null
    private var objectScale: Float? = null
    private var pipeline: MediaColorPipeline? = null
    private var decoderSurface: Surface? = null
    private var borrowedPanelSurface: PanelSurface? = null
    private var originalPanelSurface: Surface? = null
    private var bandTexture: SceneTexture? = null
    private var bandBuffer = ByteBuffer.allocateDirect(0)
    private var lastColourSequence = -1L
    private var lastUploadedBand: ByteArray? = null
    private var lastUploadedProfile: MediaColorPipeline.Profile? = null
    private var roomTarget = floatArrayOf(1f, 1f, 1f)
    private var roomTargetStrength = Float.NaN
    private val roomSmoothed = floatArrayOf(1f, 1f, 1f)
    private var immersive = 0f
    private var immersiveTarget = 0f
    private var lastTickAt = 0L
    private var ambienceActive = false

    private var passthroughEnabled = false
    val isPassthroughEnabled: Boolean get() = passthroughEnabled
    private var background = 0f
    private var backgroundFrom = 0f
    private var backgroundTarget = 0f
    private var backgroundStartedAt = 0L
    private var backgroundLevel = -1

    fun style(image: Boolean): PanelStyleOptions =
        object : PanelStyleOptions() {
            override fun applyTo(options: PanelConfigOptions) {
                super.applyTo(options)
                options.mips = MEDIA_TEXTURE_MIPS
                // Also work around ReadableMediaPanelRenderOptions creating a layer
                // for Mesh mode in SDK 0.13.2. Retain the SDK's geometry and input.
                if (image) options.layerConfig = null
                else checkNotNull(options.layerConfig).alphaBlend = LayerAlphaBlend(
                    BlendFactor.ONE, BlendFactor.ONE_MINUS_SOURCE_ALPHA,
                    BlendFactor.ONE, BlendFactor.ONE_MINUS_SOURCE_ALPHA,
                )
                options.forceSceneTexture = image
                options.effectShader = ""
                options.alphaMode = AlphaMode.PREMULTIPLIED
                options.panelShader = INPUT_SHADER
                val createMesh = options.generateSceneMeshCreator()
                options.sceneMeshCreator = { config, texture ->
                    createMesh(config, texture).also { mesh ->
                        mesh.getMaterial(0)?.let { material ->
                            material.setSortOrder(SortOrder.TRANSLUCENT)
                            material.setRenderOrder(-10)
                            // Retain input/resize geometry without an extra image
                            // pass; the compositor/ambience mesh owns the pixels.
                            material.setColorWrite(0)
                            material.setDepthWrite(DepthWrite.DISABLE)
                        }
                    }
                }
            }
        }

    fun sync(
        panel: PanelSceneObject?,
        settings: MediaEffectsSettings,
        format: VideoFormat,
        image: Boolean,
        forceMono: Boolean,
        width: Float,
        aspect: Float,
        arc: Float,
        pose: Pose,
        visible: Boolean,
    ) {
        if (panel == null) return
        val texture = panel.texture
        if (image && texture == null) return
        val stereo = if (image) StereoMode.None else ScreenGeometry.stereoMode(format, forceMono)
        if (sourcePanel !== panel) {
            if (sourcePanel != null) detach()
            sourcePanel = panel
            val textureWidth = if (image) 32 else MediaColorPipeline.HALO_WIDTH
            val textureHeight = if (image) 3 else MediaColorPipeline.HALO_HEIGHT
            bandBuffer = ByteBuffer.allocateDirect(textureWidth * textureHeight * 4)
            bandTexture = SceneTexture(textureWidth, textureHeight, 1, SamplerConfig(
                minFilter = Filter.LINEAR, magFilter = Filter.LINEAR,
                addressModeU = AddressMode.REPEAT, addressModeV = AddressMode.CLAMP_TO_EDGE,
            ), Color.valueOf(Color.TRANSPARENT))
            lastColourSequence = -1L
            if (image) attachGalleryPipeline(panel)
            // The SDK requires an albedo even when the video halo never samples it.
            glowMaterial = SceneMaterial(texture ?: checkNotNull(bandTexture), AlphaMode.PREMULTIPLIED, GLOW_SHADER).apply {
                setDepthWrite(DepthWrite.DISABLE)
                setSortOrder(SortOrder.TRANSLUCENT)
                setRenderOrder(-20)
                setUnlit(true)
                setSidedness(MaterialSidedness.DOUBLE_SIDED)
                setTexture("emissive", checkNotNull(bandTexture))
            }
        }
        pipeline?.failure?.let { throw IllegalStateException("Media colour pipeline failed", it) }
        ambienceActive = settings.enabled && visible
        val eye = when {
            image -> floatArrayOf(0f, 0f, 1f, 1f)
            format.packing == m.c.g.a.i_iwara.questui.StereoPacking.LEFT_RIGHT -> floatArrayOf(0f, 0f, 0.5f, 1f)
            format.packing == m.c.g.a.i_iwara.questui.StereoPacking.TOP_BOTTOM -> floatArrayOf(0f, 0f, 1f, 0.5f)
            else -> floatArrayOf(0f, 0f, 1f, 1f)
        }
        val height = width / aspect
        val parent = (width / MediaAmbienceMath.LOCAL_SCREEN_WIDTH).coerceAtLeast(0.001f)
        pipeline?.requestTick(eye, MediaColorPipeline.Profile(width / parent, height / parent, parent, immersive,
            MediaAmbienceMath.shaderIntensity(settings.glowStrength), settings.feather,
            when (format.packing) { StereoPacking.LEFT_RIGHT -> 1; StereoPacking.TOP_BOTTOM -> 2; else -> 0 },
            format.projection == Projection.PANORAMA_180, !image && stereo == StereoMode.LeftRight))
        pipeline?.colors?.let { colours ->
            if (colours.sequence != lastColourSequence) {
                // The halo lookup is a pure function of the 32-pixel band and the
                // profile it was baked with; deciding on those 128 bytes avoids
                // comparing (and re-uploading) the 512 KB lookup every other tick.
                val changed = lastUploadedBand?.contentEquals(colours.band) != true ||
                    (!image && lastUploadedProfile != colours.profile)
                if (changed) {
                    bandBuffer.clear()
                    if (image) {
                        // Gallery keeps the exact linear RGB band in three alpha rows.
                        for (channel in 0..2) for (pixel in 0 until 32) {
                            bandBuffer.put(0).put(0).put(0).put(colours.band[pixel * 4 + channel])
                        }
                    } else {
                        bandBuffer.put(checkNotNull(colours.halo))
                    }
                    bandBuffer.flip()
                    val textureWidth = if (image) 32 else MediaColorPipeline.HALO_WIDTH
                    val textureHeight = if (image) 3 else MediaColorPipeline.HALO_HEIGHT
                    val uploadStarted = System.nanoTime()
                    bandTexture?.update(bandBuffer, textureWidth, textureHeight, textureWidth * 4)
                    if (colours.sequence in 30L..34L)
                        android.util.Log.i("MediaGPU", "SDK upload CPU=${(System.nanoTime() - uploadStarted) / 1_000_000.0}ms")
                    // The pipeline recycles its band arrays: keep a private copy.
                    lastUploadedBand = colours.band.copyOf()
                    lastUploadedProfile = colours.profile
                }
                lastColourSequence = colours.sequence
                // Only a new readback (or the strength slider) can move the room colour.
                roomTarget = MediaAmbienceMath.roomColor(colours.average[0], colours.average[1], colours.average[2], settings.glowStrength)
                roomTargetStrength = settings.glowStrength
            } else if (roomTargetStrength != settings.glowStrength) {
                roomTarget = MediaAmbienceMath.roomColor(colours.average[0], colours.average[1], colours.average[2], settings.glowStrength)
                roomTargetStrength = settings.glowStrength
            }
        }
        val material = glowMaterial ?: return
        val hemisphere = format.projection == Projection.PANORAMA_180
        // The halo mesh is built for a 1 m wide picture and scaled to the real
        // width, exactly like the reference's parent-scaled 60 x 60 quad. So a
        // corner drag (aspect locked) never touches geometry. Only the arc, the
        // aspect and the 180 degree mode change the shape itself.
        val radius = if (format.isFlat) ScreenGeometry.radiusFor(arc, width) / width else 0f
        val next = GlowGeometry(1f / aspect, radius, hemisphere)
        if (geometry != next || glowObject == null) {
            // ⛔ SceneObject.setSceneMesh() does not replace what the runtime draws
            // (Quest 3, SDK 0.13.2): the old halo stayed on screen while the
            // picture resized. Recreate the object; creation always takes effect.
            glowObject?.destroy()
            glowObject = null
            glowMesh?.destroy()
            glowMesh = null
            val mesh = createAmbienceMesh(next, material)
            glowMesh = mesh
            glowObject = SceneObject(scene, mesh, "media_ambient_glow")
            objectPose = null
            objectVisible = null
            objectScale = null
            geometry = next
        }
        val outer = MediaAmbienceMath.LOCAL_GLOW_SIZE / MediaAmbienceMath.LOCAL_SCREEN_WIDTH
        configureMaterial(material, settings, format, image, width, height, outer, outer * aspect, stereo)
        glowObject?.let {
            if (objectVisible != visible) {
                it.setIsVisible(visible)
                objectVisible = visible
            }
            val scale = if (hemisphere) 1f else width
            if (objectScale != scale) {
                it.setScale(Vector3(scale, scale, scale))
                objectScale = scale
            }
            if (objectPose != pose) {
                it.setPosition(pose.t)
                it.setRotationQuat(pose.q)
                objectPose = pose
            }
        }
    }

    private fun configureMaterial(material: SceneMaterial, settings: MediaEffectsSettings, format: VideoFormat,
        image: Boolean, width: Float, height: Float, outerX: Float, outerY: Float, stereo: StereoMode) {
        val next = MaterialState(settings, format, image, width, height, outerX, outerY, stereo, immersive)
        if (materialState == next) return
        val previous = materialState
        val parent = (width / MediaAmbienceMath.LOCAL_SCREEN_WIDTH).coerceAtLeast(0.001f)
        if (previous?.stereo != stereo) material.setStereoMode(stereo)
        material.setAttribute("matParams", Vector4(width / parent, height / parent, parent, immersive))
        material.setAttribute("emissiveFactor", Vector4(MediaAmbienceMath.shaderIntensity(settings.glowStrength), settings.feather,
            if (image) 1f else 0f, if (format.projection == Projection.PANORAMA_180) 1f else 0f))
        material.setAttribute("albedoFactor", Vector4(outerX, outerY,
            if (!image && stereo == StereoMode.LeftRight) 1f else 0f, if (image) 0f else 1f))
        materialState = next
    }

    /** Unit geometry: the picture is 1 m wide; [sync] scales the object to the real width. */
    private fun createAmbienceMesh(shape: GlowGeometry, material: SceneMaterial): SceneMesh {
        if (shape.hemisphere) return SceneMesh.equirectSurface(ScreenGeometry.SPHERE_RADIUS, (2.0 * PI).toFloat(),
            (PI / 2).toFloat(), (-PI / 2).toFloat(), material)
        val width = 1f
        val outer = MediaAmbienceMath.LOCAL_GLOW_SIZE / MediaAmbienceMath.LOCAL_SCREEN_WIDTH
        // Concentrate vertices in the visible picture. Beyond each curved edge,
        // continue along its tangent instead of winding a huge halo around the
        // cylinder and back through the viewer. UVs remain in physical arc units.
        val columns = if (shape.radius > 0f) {
            listOf(-outer / 2f) + (0..64).map { width * (it / 64f - 0.5f) } + listOf(outer / 2f)
        } else listOf(-outer / 2f, outer / 2f)
        val positions = FloatArray(columns.size * 6)
        val normals = FloatArray(positions.size)
        val uvs = FloatArray(columns.size * 4)
        for ((column, x) in columns.withIndex()) {
            val edge = x.coerceIn(-width / 2f, width / 2f)
            val angle = if (shape.radius > 0f) edge / shape.radius else 0f
            val worldX = if (shape.radius > 0f) shape.radius * sin(angle) + (x - edge) * cos(angle) else x
            val worldZ = if (shape.radius > 0f) shape.radius * cos(angle) - (x - edge) * sin(angle) else 0f
            for (row in 0..1) {
                val vertex = column * 2 + row
                positions[vertex * 3] = worldX
                positions[vertex * 3 + 1] = (row - 0.5f) * outer
                positions[vertex * 3 + 2] = worldZ
                normals[vertex * 3] = sin(angle)
                normals[vertex * 3 + 2] = cos(angle)
                uvs[vertex * 2] = x / outer + 0.5f
                // v = 0 at the top, like the SDK's textures. media_ambience.glsl
                // mirrors p.y for the colour band walk because of this.
                uvs[vertex * 2 + 1] = 1f - row
            }
        }
        val indices = IntArray((columns.size - 1) * 6)
        for (column in 0 until columns.lastIndex) {
            val v = column * 2
            intArrayOf(v, v + 2, v + 3, v, v + 3, v + 1).copyInto(indices, column * 6)
        }
        return SceneMesh.meshWithMaterials(positions, normals, uvs, IntArray(columns.size * 2) { -1 },
            indices, intArrayOf(0, indices.size), arrayOf(material), false)
    }

    /** Video bypasses Android's full-resolution SurfaceView/VirtualDisplay copy. */
    fun prepareVideoSurface(output: Surface, width: Int, height: Int, onReady: (Surface) -> Unit) {
        pipeline?.close() // The caller has already detached the previous decoder surface.
        decoderSurface = null
        val next = MediaColorPipeline(assets, width, height, nativeVideoLayer = true)
        pipeline = next
        lastColourSequence = -1L
        next.prepare { input ->
            if (pipeline !== next) return@prepare
            decoderSurface = input
            next.attachOutput(output)
            onReady(input)
        }
    }

    private fun attachGalleryPipeline(panel: PanelSceneObject) {
        val display = checkNotNull(panel.display) { "Readable media has no Android display" }
        val surface = display.panelSurface
        val original = checkNotNull(surface.surface)
        borrowedPanelSurface = surface
        originalPanelSurface = original
        val next = MediaColorPipeline(assets, surface.widthInPx, surface.heightInPx)
        pipeline = next
        next.prepare { input ->
            if (pipeline !== next) return@prepare
            surface.surface = input
            // resize disconnects the old VirtualDisplay producer even at the same
            // resolution. EGL may only connect to it after that disconnect.
            display.resize(surface, surface.widthInPx, surface.heightInPx, display.surfaceDPI, {}, null)
            next.attachOutput(original)
        }
    }

    /** Release the GL producer before the SDK releases its ImageReader/texture. */
    fun detach() {
        pipeline?.close()
        pipeline = null
        decoderSurface = null
        originalPanelSurface?.let { borrowedPanelSurface?.surface = it }
        borrowedPanelSurface = null
        originalPanelSurface = null
        glowObject?.destroy()
        glowObject = null
        glowMesh?.destroy()
        glowMesh = null
        glowMaterial?.destroy()
        glowMaterial = null
        bandTexture?.destroy()
        bandTexture = null
        lastUploadedBand = null
        lastUploadedProfile = null
        sourcePanel = null
        geometry = null
        materialState = null
        objectPose = null
        objectVisible = null
        objectScale = null
        ambienceActive = false
        roomTarget = floatArrayOf(1f, 1f, 1f)
        roomTargetStrength = Float.NaN
    }

    /**
     * 背景只有一条旋钮：[MediaEffectsSettings.backgroundTransparency]。
     *
     * ⛔ 这里曾经先看 `SceneKind`（虚空 → 恒 0、透视 → 读滑块），2026-09-09 删掉了那个
     * 枚举 —— 虚空就是滑块拖到 0 的那一端，两套并存只是让用户多选一次。
     *
     * `immersive` 是着色器那份「人在多黑的房间里」的连续量（光晕的铺开程度按它走，
     * 见 `media_profile.glsl` 的 `ambienceProfile`），此前是虚空/透视的 1/0 二值，
     * 现在直接取背景的补数：房间越暗，光晕铺得越开。
     */
    fun setBackground(settings: MediaEffectsSettings, now: Long, immediate: Boolean = false) {
        val target = settings.backgroundTransparency
        immersiveTarget = 1f - target
        if (!immediate && target == backgroundTarget) return
        backgroundFrom = background
        backgroundTarget = target
        backgroundStartedAt = now
        if (target > 0f && !passthroughEnabled) {
            // Configure the dark starting frame before enabling the camera layer.
            applyBackground(if (immediate) target else background)
            scene.enablePassthrough(true)
            passthroughEnabled = true
        }
        if (immediate) background = target
        tickBackground(now, immediate)
    }

    fun tickBackground(now: Long, immediate: Boolean = false) {
        val elapsed = if (lastTickAt == 0L) 14f else (now - lastTickAt).toFloat().coerceIn(0f, 100f)
        lastTickAt = now
        immersive += (immersiveTarget - immersive) * (elapsed * 0.003f).coerceIn(0f, 1f)
        for (i in 0..2) roomSmoothed[i] += ((if (ambienceActive) roomTarget[i] else 1f) - roomSmoothed[i]) * 0.1f
        val t = if (immediate) 1f else ((now - backgroundStartedAt) / 220f).coerceIn(0f, 1f)
        background = backgroundFrom + (backgroundTarget - backgroundFrom) * (t * t * (3f - 2f * t))
        applyBackground(background)
        if (t >= 1f && backgroundTarget == 0f && passthroughEnabled) {
            scene.enablePassthrough(false)
            passthroughEnabled = false
        }
    }

    private fun applyBackground(value: Float) {
        val levels = IntArray(3) { (value * roomSmoothed[it] * 255f).roundToInt().coerceIn(0, 255) }
        val key = (levels[0] shl 16) or (levels[1] shl 8) or levels[2]
        if (key == backgroundLevel) return
        val lut = Lut()
        for (r in 0..15) for (g in 0..15) for (b in 0..15) {
            lut.setMapping(r, g, b, (r * 17f * levels[0] / 255f).roundToInt(),
                (g * 17f * levels[1] / 255f).roundToInt(), (b * 17f * levels[2] / 255f).roundToInt())
        }
        scene.setPassthroughLUT(lut)
        backgroundLevel = key
    }

    companion object {
        // The video texture carries no mip chain; footprint filtering is two
        // taps in the picture shader instead. The old Gaussian prototype's eight
        // mip levels regenerated an entire 8K pyramid per frame.
        const val MEDIA_TEXTURE_MIPS = 1
        private const val INPUT_SHADER = "media_input"
        private const val GLOW_SHADER = "media_glow"

        fun hasBoundary(format: VideoFormat): Boolean = format.isFlat || format.projection == Projection.PANORAMA_180

        fun usesTextureEffects(settings: MediaEffectsSettings, format: VideoFormat): Boolean =
            settings.enabled && hasBoundary(format)


    }

    /** Shape of the unit halo mesh: picture height and cylinder radius per metre of width. */
    private data class GlowGeometry(val height: Float, val radius: Float, val hemisphere: Boolean)
    private data class MaterialState(val settings: MediaEffectsSettings, val format: VideoFormat, val image: Boolean,
        val width: Float, val height: Float, val outerX: Float, val outerY: Float, val stereo: StereoMode, val immersive: Float)
}
