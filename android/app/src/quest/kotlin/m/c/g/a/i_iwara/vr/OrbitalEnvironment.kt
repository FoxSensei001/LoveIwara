package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import android.os.SystemClock
import com.meta.spatial.core.Entity
import com.meta.spatial.core.Pose
import com.meta.spatial.core.SpatialSDKExperimentalAPI
import com.meta.spatial.core.Vector3
import com.meta.spatial.core.Vector4
import com.meta.spatial.runtime.AddressMode
import com.meta.spatial.runtime.BlendFactor
import com.meta.spatial.runtime.DepthWrite
import com.meta.spatial.runtime.Filter
import com.meta.spatial.runtime.LayerAlphaBlend
import com.meta.spatial.runtime.PanelSceneObject
import com.meta.spatial.runtime.SamplerConfig
import com.meta.spatial.runtime.Scene
import com.meta.spatial.runtime.StereoMode
import com.meta.spatial.toolkit.Hittable
import com.meta.spatial.toolkit.MediaPanelRenderOptions
import com.meta.spatial.toolkit.MediaPanelSettings
import com.meta.spatial.toolkit.MeshCollision
import com.meta.spatial.toolkit.PixelDisplayOptions
import com.meta.spatial.toolkit.QuadShapeOptions

/**
 * Selected stereo sphere impostors, composited BELOW every video, image and UI layer.
 * The shader traces each eye's ray through a fixed world-space proxy plane into
 * the sphere. This includes surface depth, not just a flat stereo-offset disc.
 * Keeping the plane fixed also lets the compositor reproject between updates.
 */
@OptIn(SpatialSDKExperimentalAPI::class)
internal class OrbitalEnvironment(
    private val scene: Scene, assets: AssetManager, head: Pose,
    showEarth: Boolean, showMoon: Boolean,
    previousClock: OrbitalCadence? = null, previousAnchor: Vector3? = null,
) {
    private data class Target(val body: OrbitalBody, val panel: PanelSceneObject, val entity: Entity)
    private val spec = OrbitalScene.load(assets)
    private val bodies = spec.bodies.filter { (it.name == "earth" && showEarth) || (it.name == "moon" && showMoon) }
    val anchor = previousAnchor ?: Vector3(head.t.x, head.t.y, head.t.z)
    private val targets = ArrayList<Target>()
    val animationClock = previousClock ?: OrbitalCadence(spec.maxFps, spec.motionFps)
    private val cadence get() = animationClock
    private var renderer: OrbitalRenderer? = null
    private var submittedEye: Vector3? = null
    private var lastAlpha = -1f
    private var lastBrightness = -1f
    private var resumed = true
    private var closed = false
    val ready: Boolean get() = renderer?.ready == true
    val failure: Throwable? get() = renderer?.failure

    init {
        try {
            check(bodies.isNotEmpty()) { "An orbital renderer requires a visible body" }
            bodies.forEach { body ->
                val config = MediaPanelSettings(
                    shape = QuadShapeOptions(body.planeSize, body.planeSize),
                    display = PixelDisplayOptions(body.eyePixels * 2, body.eyePixels),
                    rendering = MediaPanelRenderOptions(stereoMode = StereoMode.LeftRight, zIndex = body.zIndex,
                        samplerConfig = SamplerConfig(minFilter = Filter.LINEAR, magFilter = Filter.LINEAR,
                            addressModeU = AddressMode.CLAMP_TO_EDGE, addressModeV = AddressMode.CLAMP_TO_EDGE)),
                ).toPanelConfigOptions().apply {
                    mips = 1
                    forceSceneTexture = false
                    val createMesh = generateSceneMeshCreator()
                    sceneMeshCreator = { shape, texture -> createMesh(shape, texture).also { mesh ->
                        mesh.getMaterial(0)?.apply { setColorWrite(0); setDepthWrite(DepthWrite.DISABLE) }
                    } }
                }
                val entity = Entity.create(listOf(Hittable(MeshCollision.NoCollision)))
                val panel = try { PanelSceneObject(scene, entity, config) } catch (error: Throwable) { entity.destroy(); throw error }
                targets += Target(body, panel, entity) // Own handles before subsequent SDK calls.
                panel.setPosition(anchor + body.center)
                panel.setRotationQuat(body.frame.q)
                panel.shouldFrustumCull(false)
                checkNotNull(panel.layer).apply {
                    setZIndex(body.zIndex)
                    setAlphaBlend(LayerAlphaBlend(BlendFactor.ONE, BlendFactor.ONE_MINUS_SOURCE_ALPHA,
                        BlendFactor.ONE, BlendFactor.ONE_MINUS_SOURCE_ALPHA))
                    setColorScaleBias(ZERO, ZERO)
                }
            }
            renderer = OrbitalRenderer(assets, bodies, targets.map { checkNotNull(it.panel.surface) }, frame(head))
        } catch (error: Throwable) {
            close()
            throw error
        }
    }

    private fun frame(head: Pose): OrbitalRenderer.Frame {
        val offsets = scene.getEyeOffsets()
        val left = head * offsets.first - anchor
        val right = head * offsets.second - anchor
        check(left.x.isFinite() && left.y.isFinite() && left.z.isFinite() && right.x.isFinite() && right.y.isFinite() && right.z.isFinite())
        return OrbitalRenderer.Frame(left, right, head.forward(), cadence.seconds)
    }

    fun setResumed(value: Boolean) {
        resumed = value
        if (!value) {
            cadence.tick(SystemClock.uptimeMillis(), false)
            targets.forEach { it.panel.layer?.setColorScaleBias(ZERO, ZERO) }
            lastAlpha = -1f
        }
        renderer?.setEnabled(value)
    }

    fun tick(now: Long, head: Pose?, alpha: Float, brightness: Float) {
        if (closed) return
        val active = resumed && alpha > 0f && brightness > 0f
        cadence.tick(now, active)
        renderer?.setEnabled(resumed && brightness > 0f)
        if (alpha != lastAlpha || brightness != lastBrightness) {
            val light = brightness * alpha
            val scale = Vector4(light, light, light, alpha)
            targets.forEach { it.panel.layer?.setColorScaleBias(scale, ZERO) }
            lastAlpha = alpha
            lastBrightness = brightness
        }
        if (!resumed || brightness <= 0f || head == null) return
        // Initialization can finish while the HMD is off. Resume warmup with
        // current eye poses, before the parent allows a fade-in.
        if (!ready) { renderer?.request(frame(head)); return }
        if (!active) return
        val eye = head.t - anchor
        val visible = bodies.any { (it.center - eye).normalize().dot(head.forward()) > -0.3f }
        val moved = submittedEye?.let { (eye - it).length() > 0.012f } ?: false
        if (cadence.request(now, visible, moved)) {
            if (renderer?.request(frame(head)) == true) submittedEye = eye
        }
    }

    fun close() {
        if (closed) return
        cadence.tick(SystemClock.uptimeMillis(), false)
        // Disconnect EGL before destroying the SDK swapchains that own Surfaces.
        renderer?.close()
        closed = true
        renderer = null
        targets.forEach { target -> try { target.panel.destroy() } finally { target.entity.destroy() } }
        targets.clear()
    }

    companion object { private val ZERO = Vector4(0f, 0f, 0f, 0f) }
}
