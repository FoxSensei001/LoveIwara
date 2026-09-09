package m.c.g.a.i_iwara.vr

import android.app.Activity
import android.app.Instrumentation
import android.content.Intent
import android.os.Bundle
import android.os.SystemClock
import com.meta.spatial.core.Pose
import com.meta.spatial.core.Vector2
import com.meta.spatial.runtime.PanelSceneObject
import m.c.g.a.i_iwara.questui.GalleryItem
import m.c.g.a.i_iwara.questui.GalleryStageState
import m.c.g.a.i_iwara.questui.GalleryState
import m.c.g.a.i_iwara.questui.MediaEffectsSettings
import m.c.g.a.i_iwara.questui.Projection
import m.c.g.a.i_iwara.questui.SceneKind
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoFormat
import m.c.g.a.i_iwara.xr.ImmersiveGalleryItem
import kotlin.math.abs

/** Device-only regression probe. Never packaged in the application APK. */
class MediaEffectsProbe : Instrumentation() {
    private var arguments: Bundle? = null

    override fun onCreate(arguments: Bundle?) {
        super.onCreate(arguments)
        this.arguments = arguments
        start()
    }

    override fun onStart() {
        // `-e mode visual`: interactive driver instead of the regression run.
        if (arguments?.getString("mode") == "visual") {
            try {
                MediaEffectsVisualProbe(this, arguments).run { message ->
                    android.util.Log.i("MediaProbe", message)
                    sendStatus(0, Bundle().apply { putString("stream", "$message\n") })
                }
                finish(Activity.RESULT_OK, Bundle().apply { putString("stream", "PASS visual probe\n") })
            } catch (error: Throwable) {
                finish(Activity.RESULT_CANCELED, Bundle().apply { putString("stream", "FAIL ${error.stackTraceToString()}\n") })
            }
            return
        }
        try {
            MediaAmbiencePixelProbe(context.assets, targetContext.assets).run { message ->
                sendStatus(0, Bundle().apply { putString("stream", "$message\n") })
            }
            val video = targetContext.cacheDir.resolve("media-effects-probe.mp4")
            context.assets.open(video.name).use { input -> video.outputStream().use { input.copyTo(it) } }
            val intent = Intent(targetContext, ImmersiveActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .putExtra("url", "file://$video")
                .putExtra("w", 320).putExtra("h", 180)
                .putExtra("shape", "flat").putExtra("stereo", "none")
                .putExtra("curve", "flat").putExtra("scene", "passthrough")
                .putExtra("mute", true).putExtra("title", "Resize regression")
            val activity = startActivitySync(intent) as ImmersiveActivity
            var panel: PanelSceneObject? = null
            val deadline = SystemClock.uptimeMillis() + 20_000L
            while (panel == null && SystemClock.uptimeMillis() < deadline) {
                runOnMainSync { panel = field(activity, "screenPanel") as? PanelSceneObject }
                SystemClock.sleep(100L)
            }
            check(panel != null) { "Media panel did not become ready" }
            awaitLiveColours(activity)
            var original = Vector2(0f, 0f)
            var failure: Throwable? = null
            runOnMainSync {
                original = (field(activity, "screenHost") as WindowHost).size()
                (field(activity, "playback") as PlaybackEngine).setRepeatOne(true)
            }
            try {
                for (width in listOf(2.4f, 3.8f, 1.7f, 3.1f)) {
                    runOnMainSync {
                        try {
                            val host = field(activity, "screenHost") as WindowHost
                            // Geometry remains testable while the headset is unmounted;
                            // the normal pose function supplies its parked/fallback basis.
                            val pose = host.surfacePose() ?: activity.javaClass
                                .getDeclaredMethod("screenSurfacePose").apply { isAccessible = true }
                                .invoke(activity) as Pose
                            host.resizeTo(Vector2(width, width * original.y / original.x), pose, false)
                        } catch (error: Throwable) { failure = error }
                    }
                    failure?.let { throw it }
                    SystemClock.sleep(350L)
                    runOnMainSync {
                        try {
                            val current = field(activity, "screenPanel") as PanelSceneObject
                            val frame = (field(activity, "screenHost") as WindowHost).size()
                            val mesh = checkNotNull(current.mesh).computeCombinedBounds().size()
                            val decoder = field(activity, "playback") as PlaybackEngine
                            val renderer = activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity)
                            val input = field(renderer, "decoderSurface")
                            val correctSurface = input != null && field(decoder, "surface") === input
                            val message = "requested=$width frame=${frame.x} mesh=${mesh.x} decoderSurfaceCorrect=$correctSurface"
                            sendStatus(0, Bundle().apply { putString("stream", "$message\n") })
                            check(abs(frame.x - width) < 0.01f && abs(mesh.x - width) < 0.01f) { message }
                            check(correctSurface) { "Resize rebound the decoder away from the processor input: $message" }
                            check(current.display == null) { "Video acquired an unnecessary virtual-display copy" }
                            check(current.layer != null && current.texture == null) { "Video lost the native compositor path" }
                            val pipeline = livePipeline(activity)
                            check(pipeline.copiedFrames > 0 && pipeline.colors != null && pipeline.failure == null) {
                                "Resizing lost the live colour pipeline: ${pipeline.failure}"
                            }
                        } catch (error: Throwable) { failure = error }
                    }
                    failure?.let { throw it }
                }
            } finally {
                runOnMainSync {
                    val host = field(activity, "screenHost") as WindowHost
                    host.surfacePose()?.let { host.resizeTo(original, it, false) }
                }
            }
            checkModes(activity)
            checkGallery(activity)
            finish(Activity.RESULT_OK, Bundle().apply { putString("stream", "PASS media resize follows frame\n") })
        } catch (error: Throwable) {
            finish(Activity.RESULT_CANCELED, Bundle().apply { putString("stream", "FAIL ${error.stackTraceToString()}\n") })
        }
    }

    private fun field(target: Any, name: String): Any? =
        target.javaClass.getDeclaredField(name).apply { isAccessible = true }.get(target)

    private fun livePipeline(activity: ImmersiveActivity): MediaColorPipeline {
        val renderer = activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity)
        return checkNotNull(field(renderer, "pipeline") as? MediaColorPipeline) { "Live media colour pipeline is absent" }
    }

    private fun awaitLiveColours(activity: ImmersiveActivity) {
        val deadline = SystemClock.uptimeMillis() + 12_000L
        var ready = false
        var error: Throwable? = null
        var frames = 0L
        var colours: MediaColorPipeline.Colors? = null
        while (!ready && SystemClock.uptimeMillis() < deadline) {
            runOnMainSync {
                try {
                    val pipeline = livePipeline(activity)
                    pipeline.failure?.let { throw it }
                    frames = pipeline.copiedFrames
                    colours = pipeline.colors
                    ready = frames >= 4 && pipeline.colors?.average?.sum()?.let { it > 0.05f } == true
                } catch (failure: Throwable) { error = failure }
            }
            if (!ready) SystemClock.sleep(100L)
        }
        check(ready) { "No moving, coloured frames reached the GPU pipeline: frames=$frames sequence=${colours?.sequence} average=${colours?.average?.toList()} error=$error" }
        sendStatus(0, Bundle().apply { putString("stream", "PASS live video colour pipeline: copiedFrames=$frames\n") })
    }

    private fun checkModes(activity: ImmersiveActivity) {
        val callbacks = field(activity, "controlsCallbacks") as VideoControlsCallbacks
        val state = field(activity, "controls") as VideoControlsState
        fun checkLive(label: String) {
            var failure: Throwable? = null
            runOnMainSync {
                try {
                    val pipeline = livePipeline(activity)
                    check(pipeline.copiedFrames > 0 && pipeline.colors != null && pipeline.failure == null) { "$label lost live colour" }
                } catch (error: Throwable) { failure = error }
            }
            failure?.let { throw it }
            sendStatus(0, Bundle().apply { putString("stream", "PASS $label\n") })
        }
        for (curve in ScreenCurve.entries) {
            runOnMainSync { callbacks.onPickCurve(curve) }
            SystemClock.sleep(800L)
            checkLive("curve $curve")
        }
        runOnMainSync { callbacks.onPickCurve(ScreenCurve.FLAT) }
        for (brightness in listOf(0f, 0.4f, 1f)) {
            runOnMainSync { callbacks.onMediaEffects(MediaEffectsSettings(glowStrength = brightness)) }
            SystemClock.sleep(400L)
            checkLive("brightness $brightness")
        }
        for (transparency in listOf(0f, 0.5f, 1f)) {
            runOnMainSync { callbacks.onMediaEffects(state.mediaEffects.copy(backgroundTransparency = transparency)) }
            SystemClock.sleep(400L)
            checkLive("background $transparency")
        }
        for (scene in SceneKind.entries) {
            runOnMainSync { callbacks.onPickScene(scene) }
            SystemClock.sleep(500L)
            checkLive("scene $scene")
        }
        runOnMainSync {
            callbacks.onPickScene(SceneKind.PASSTHROUGH)
            callbacks.onMediaEffects(state.mediaEffects.copy(enabled = false))
        }
        SystemClock.sleep(500L)
        runOnMainSync {
            check(field(activity, "screenUsesEffectMesh") == false) { "Effects off kept the processed surface" }
            callbacks.onMediaEffects(MediaEffectsSettings())
        }
        awaitLiveColours(activity)
        for (format in listOf(VideoFormat.FLAT_3D_HSBS, VideoFormat.FLAT_3D_HOU,
            VideoFormat.PANO_180_3D_LR, VideoFormat.PANO_180_3D_TB, VideoFormat.PANO_360_2D, VideoFormat.FLAT_2D)) {
            runOnMainSync { callbacks.onPickFormat(format) }
            SystemClock.sleep(850L)
            if (format.projection == Projection.PANORAMA_360) {
                runOnMainSync { check(field(activity, "screenUsesEffectMesh") == false) { "360 acquired a false edge" } }
            } else {
                checkLive("format $format")
                if (format.isStereo) {
                    runOnMainSync { callbacks.onToggleForceMono() }
                    SystemClock.sleep(250L)
                    checkLive("force mono $format")
                    runOnMainSync { callbacks.onToggleForceMono() }
                }
            }
        }
    }

    private fun checkGallery(activity: ImmersiveActivity) {
        val fixtures = listOf("png" to Vector2(320f, 180f), "gif" to Vector2(180f, 240f), "gray.png" to Vector2(256f, 256f))
        val items = fixtures.map { (extension, size) ->
            val file = targetContext.cacheDir.resolve("media-effects-probe.$extension")
            context.assets.open(file.name).use { input -> file.outputStream().use { input.copyTo(it) } }
            ImmersiveGalleryItem("probe-$extension", false, file.path, "", file.path, size.x.toInt(), size.y.toInt())
        }
        val gallery = GalleryState().apply {
            galleryId = "media-effects-probe"
            title = "Media effects regression"
            for (item in items) {
                this.items.add(GalleryItem(item.id, false, "", item.thumbPath, item.width, item.height))
                resolvedPath[item.id] = item.url
            }
        }
        var failure: Throwable? = null
        runOnMainSync {
            activity.javaClass.getDeclaredField("gallery").apply { isAccessible = true }.set(activity, gallery)
            activity.javaClass.getDeclaredField("galleryItems").apply { isAccessible = true }.set(activity, items)
            (field(activity, "controls") as VideoControlsState).gallery = gallery
        }
        for (index in items.indices) {
            runOnMainSync {
                activity.javaClass.getDeclaredMethod("showGalleryItem", Int::class.javaPrimitiveType)
                    .apply { isAccessible = true }.invoke(activity, index)
            }
            SystemClock.sleep(1600L)
            runOnMainSync {
                try {
                    val stage = field(activity, "stage") as GalleryStageState
                    val panel = field(activity, "screenPanel") as PanelSceneObject
                    check(stage.model == items[index].url && !gallery.loading && gallery.error == null) {
                        "Gallery fixture failed to decode: ${items[index].id}, ${gallery.error}"
                    }
                    check(panel.texture != null && panel.layer == null) { "Gallery lost its transparent texture path" }
                    val pipeline = livePipeline(activity)
                    check(pipeline.copiedFrames > 0 && pipeline.colors != null && pipeline.failure == null) {
                        "Gallery colour pipeline stopped: ${pipeline.failure}"
                    }
                    val host = field(activity, "screenHost") as WindowHost
                    val size = host.size()
                    val mesh = checkNotNull(panel.mesh).computeCombinedBounds().size()
                    check(abs(mesh.x - size.x) < 0.01f && abs(mesh.y - size.y) < 0.01f) { "Gallery bounds mismatch" }
                    sendStatus(0, Bundle().apply { putString("stream", "PASS gallery ${items[index].id} decoded, texture and geometry ready\n") })
                } catch (error: Throwable) { failure = error }
            }
            failure?.let { throw it }
            if (index == 2) {
                val picture = FloatArray(3)
                val band = FloatArray(3)
                repeat(8) {
                    runOnMainSync {
                        val panel = field(activity, "screenPanel") as PanelSceneObject
                        panel.texture?.readAverageColor(picture, 0)
                        val renderer = activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity)
                        (field(renderer, "bandTexture") as? com.meta.spatial.runtime.SceneTexture)?.readAverageColor(band, 0)
                    }
                    SystemClock.sleep(80L)
                }
                val pipeline = livePipeline(activity)
                val colours = checkNotNull(pipeline.colors)
                check(abs(picture[0] - 0.21586f) < 0.002f) { "Source sRGB interpretation changed" }
                check(abs((colours.band[0].toInt() and 255) - 55) <= 1) { "Band filtered encoded RGB instead of linear light" }
                check(abs(colours.average[0] - 123f / 255f) <= 1f / 255f) { "Room average was calculated in the wrong colour space" }
                sendStatus(0, Bundle().apply { putString("stream", "COLOUR SPACE gray128 picture=${picture.toList()} band=${band.toList()} filter=${pipeline.colors?.band?.take(3)?.map { it.toInt() and 255 }} average=${pipeline.colors?.average?.toList()}\n") })
            }
        }
    }
}
