package m.c.g.a.i_iwara.vr

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.Rect
import com.meta.spatial.core.Entity
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
import com.meta.spatial.toolkit.Equirect360ShapeOptions
import com.meta.spatial.toolkit.Hittable
import com.meta.spatial.toolkit.MediaPanelRenderOptions
import com.meta.spatial.toolkit.MediaPanelSettings
import com.meta.spatial.toolkit.MeshCollision
import com.meta.spatial.toolkit.PixelDisplayOptions
import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings
import java.util.concurrent.Executors

/**
 * A static, monoscopic compositor underlay shared by all media and the browse view.
 *
 * A sky mesh in the projection layer can obscure the native video underlays, even
 * at an enormous radius. This layer explicitly sits below the -1/0 media layers.
 * It has no Android View, decoder, frame loop, or interactive mesh. Only its fade
 * and translation change; rotation remains world-locked. Decode happens off the
 * scene thread and a Canvas frame is submitted only while VR is visible.
 *
 * Returning to passthrough destroys the layer after fading. An opaque 360 video
 * releases it immediately. Media switches must not otherwise detach this owner.
 */
@OptIn(SpatialSDKExperimentalAPI::class)
internal class DeepSpaceEnvironment(private val scene: Scene, private val assets: AssetManager) {
    private var settings = EnvironmentSettings()
    private var panel: PanelSceneObject? = null
    private var entity: Entity? = null
    private var position: Vector3? = null
    private val fade = EnvironmentFade()
    private var appliedAlpha = -1f
    private var appliedBrightness = -1f
    private var covered = false
    private var resumed = false
    private var passthroughVisible = true
    private var redrawOnResume = false
    private var enteredSpace = false
    private var failed = false
    private var failure: Throwable? = null
    private val loadLock = Any()
    private var pending: LoadedSky? = null
    private var executor: java.util.concurrent.ExecutorService? = null
    @Volatile private var closed = false

    var loading = false
        private set
    val ready: Boolean get() = panel != null
    // Keep the camera dark until a fading-out sky has actually been removed.
    val replacesRoom: Boolean get() = ready ||
        (settings.kind == EnvironmentKind.DEEP_SPACE && (covered || enteredSpace))

    fun setSettings(next: EnvironmentSettings, now: Long, immediate: Boolean = false) {
        if (closed) return
        if (next.kind != settings.kind) failed = false
        settings = next.normalized()
        if (settings.kind == EnvironmentKind.PASSTHROUGH) enteredSpace = false
        requestIfNeeded()
        fade.setVisible(wantsSky() && ready && !passthroughVisible, now, immediate)
    }

    fun setResumed(value: Boolean) {
        if (resumed == value || closed) return
        resumed = value
        // A runtime may recreate its Android consumer while the app is suspended.
        // Re-submit once on resume, never continuously redraw a static sky.
        if (value && ready) redrawOnResume = true
    }

    /** Returns true when readiness/coverage changes and passthrough must be reconsidered. */
    fun tick(now: Long, viewerPosition: Vector3?, fullyCovered: Boolean, passthroughEnabled: Boolean): Boolean {
        if (closed) return false
        passthroughVisible = passthroughEnabled
        var changed = covered != fullyCovered
        covered = fullyCovered
        if (covered && settings.kind == EnvironmentKind.DEEP_SPACE) enteredSpace = true
        if (covered && ready) {
            fade.setVisible(false, now, immediate = true)
            destroyLayer()
        }
        if (!resumed) return changed
        val loaded = synchronized(loadLock) { pending.also { pending = null } }
        if (loaded != null) {
            loading = false
            changed = true
            try {
                if (wantsSky()) {
                    loaded.error?.let { throw it }
                    upload(checkNotNull(loaded.bitmap))
                    enteredSpace = true
                    redrawOnResume = false
                }
            } catch (error: Throwable) {
                failed = true
                failure = error
                destroyLayer()
            } finally {
                loaded.bitmap?.recycle()
            }
        }
        requestIfNeeded()
        // Passthrough uses a colour LUT, not alpha. Fade through black rather
        // than depending on where the runtime orders its opaque camera layer.
        fade.setVisible(wantsSky() && ready && !passthroughVisible, now)
        val alpha = fade.valueAt(now)
        if (!wantsSky() && alpha == 0f && ready) {
            destroyLayer()
            changed = true
        }
        panel?.let { sky ->
            if (viewerPosition != null && viewerPosition.x.isFinite() && viewerPosition.y.isFinite() &&
                viewerPosition.z.isFinite() && viewerPosition != position) {
                // Translation only: distant stars have no walking parallax and never turn with the head.
                sky.setPosition(viewerPosition)
                position = viewerPosition
            }
            if (alpha != appliedAlpha || settings.spaceBrightness != appliedBrightness) {
                val light = settings.spaceBrightness * alpha
                checkNotNull(sky.layer).setColorScaleBias(Vector4(light, light, light, alpha), ZERO)
                appliedAlpha = alpha
                appliedBrightness = settings.spaceBrightness
            }
        }
        return changed
    }

    fun takeFailure(): Throwable? = failure.also { failure = null }

    private fun wantsSky() = settings.kind == EnvironmentKind.DEEP_SPACE && !covered && !failed

    private fun requestIfNeeded() {
        if (closed || !wantsSky() || loading || (ready && !redrawOnResume)) return
        loading = true
        val loader = executor ?: Executors.newSingleThreadExecutor { task ->
            Thread(task, "QuestStarfieldLoader").apply { isDaemon = true }
        }.also { executor = it }
        loader.execute {
            val loaded = try {
                val bitmap = assets.open(ASSET).use {
                    BitmapFactory.decodeStream(it, null, BitmapFactory.Options().apply {
                        inPreferredConfig = Bitmap.Config.ARGB_8888
                        inScaled = false
                    })
                }
                checkNotNull(bitmap) { "Cannot decode $ASSET" }
                if (bitmap.width != WIDTH || bitmap.height != HEIGHT) {
                    bitmap.recycle()
                    error("Unexpected starfield dimensions")
                }
                LoadedSky(bitmap = bitmap)
            } catch (error: Throwable) {
                LoadedSky(error = error)
            }
            synchronized(loadLock) {
                if (closed) loaded.bitmap?.recycle() else pending = loaded
            }
        }
    }

    private fun upload(bitmap: Bitmap) {
        if (panel == null) {
            // The direct surface constructor uses these pixel dimensions without
            // an Activity/VirtualDisplay. Keep an initialized native pose object;
            // SceneObject(scene) alone has a zero native handle in SDK 0.13.2.
            val config = MediaPanelSettings(
                shape = Equirect360ShapeOptions(radius = 1000f),
                display = PixelDisplayOptions(WIDTH, HEIGHT),
                rendering = MediaPanelRenderOptions(
                    stereoMode = StereoMode.None,
                    zIndex = BACKGROUND_Z,
                    samplerConfig = SamplerConfig(
                        minFilter = Filter.LINEAR, magFilter = Filter.LINEAR,
                        addressModeU = AddressMode.REPEAT, addressModeV = AddressMode.CLAMP_TO_EDGE,
                    ),
                ),
            ).toPanelConfigOptions().apply {
                mips = 1
                forceSceneTexture = false
                val createMesh = generateSceneMeshCreator()
                sceneMeshCreator = { shape, texture ->
                    createMesh(shape, texture).also { mesh ->
                        mesh.getMaterial(0)?.apply {
                            // The compositor owns the pixels. Do not punch a
                            // sky-sized hole through gallery images or their glow.
                            setColorWrite(0)
                            setDepthWrite(DepthWrite.DISABLE)
                        }
                    }
                }
            }
            entity = Entity.create(listOf(Hittable(MeshCollision.NoCollision)))
            val sky = PanelSceneObject(scene, checkNotNull(entity), config)
            panel = sky // Own it before another SDK call can fail.
            sky.shouldFrustumCull(false)
            checkNotNull(sky.layer).apply {
                setZIndex(BACKGROUND_Z)
                setAlphaBlend(LayerAlphaBlend(
                    BlendFactor.ONE, BlendFactor.ONE_MINUS_SOURCE_ALPHA,
                    BlendFactor.ONE, BlendFactor.ONE_MINUS_SOURCE_ALPHA,
                ))
                setColorScaleBias(ZERO, ZERO)
            }
            appliedAlpha = -1f
            appliedBrightness = -1f
        }
        val surface = checkNotNull(panel?.surface)
        val canvas = surface.lockHardwareCanvas()
        try {
            // Hardware Canvas requires a complete frame, including on resume.
            canvas.drawColor(Color.BLACK, PorterDuff.Mode.SRC)
            canvas.drawBitmap(bitmap, null, Rect(0, 0, canvas.width, canvas.height), Paint(Paint.FILTER_BITMAP_FLAG))
        } finally {
            surface.unlockCanvasAndPost(canvas)
        }
    }

    private fun destroyLayer() {
        val oldPanel = panel
        val oldEntity = entity
        panel = null
        entity = null
        position = null
        try {
            oldPanel?.destroy() // owns the mesh, layer, swapchain and Surface
        } finally {
            oldEntity?.destroy()
        }
    }

    fun close() {
        synchronized(loadLock) {
            if (closed) return
            closed = true
            pending?.bitmap?.recycle()
            pending = null
        }
        executor?.shutdownNow()
        executor = null
        loading = false
        destroyLayer()
    }

    private data class LoadedSky(val bitmap: Bitmap? = null, val error: Throwable? = null)

    companion object {
        private const val ASSET = "environments/deep_space.png"
        private const val WIDTH = 4096
        private const val HEIGHT = 2048
        private const val BACKGROUND_Z = -100
        private val ZERO = Vector4(0f, 0f, 0f, 0f)
    }
}
