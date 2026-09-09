package m.c.g.a.i_iwara.vr

import android.app.Instrumentation
import android.content.Intent
import android.os.Bundle
import android.os.SystemClock
import com.meta.spatial.core.Pose
import com.meta.spatial.core.Vector2
import com.meta.spatial.runtime.PanelSceneObject
import com.meta.spatial.runtime.SceneObject
import m.c.g.a.i_iwara.questui.SceneKind
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState

/**
 * Interactive device driver for eyeballing the media ambience while the
 * headset sits unattended. Started through the generated runner with
 * `am instrument -e mode visual [-e video x.mp4] [-e curve flat] [-e scene void]`.
 * It launches the player, then polls `cache/media-probe-cmd` for one command
 * per line and applies it on the main thread, so screenshots can be taken
 * between steps from the host:
 *
 *   width <metres>     drag-style resize (commit=false), like the corner handles
 *   commit <metres>    resize with commit=true
 *   drag <metres>      resize + frame reshape, like WindowManipulator.updateSession
 *   dragend <metres>   the same with commit=true (release)
 *   frame <lit|off>    light the screen frame's handles
 *   dragseq <w0> <w1> <n>  frame-by-frame drag from w0 to w1 in n steps, committed at the end
 *   frames             log the manipulator's frame bookkeeping for the screen
 *   curve <FLAT|SLIGHT|MEDIUM|DEEP>
 *   scene <VOID|PASSTHROUGH>
 *   glow <0..1>        brightness slider
 *   feather <0..1>
 *   effects <true|false>
 *   playpause          toggle playback (static picture: no band uploads)
 *   halo <true|false>  show/hide only the halo scene object (draw-cost isolation)
 *   pipeline <true|false>  false idles the GL colour worker (measurement only; leaks on detach)
 *   quit
 *
 * Never packaged in the application APK.
 */
internal class MediaEffectsVisualProbe(private val instrumentation: Instrumentation, arguments: Bundle?) {
    private val videoName = arguments?.getString("video") ?: "probe2.mp4"
    private val curve = arguments?.getString("curve") ?: "flat"
    private val scene = arguments?.getString("scene") ?: "void"

    fun run(report: (String) -> Unit) {
        val targetContext = instrumentation.targetContext
        val video = targetContext.cacheDir.resolve(videoName)
        check(video.exists()) { "Missing ${video.path}" }
        val intent = Intent(targetContext, ImmersiveActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            .putExtra("url", "file://$video")
            .putExtra("shape", "flat").putExtra("stereo", "none")
            .putExtra("curve", curve).putExtra("scene", scene)
            .putExtra("mute", true).putExtra("title", "Visual probe")
        val activity = instrumentation.startActivitySync(intent) as ImmersiveActivity
        var panel: PanelSceneObject? = null
        val deadline = SystemClock.uptimeMillis() + 20_000L
        while (panel == null && SystemClock.uptimeMillis() < deadline) {
            instrumentation.runOnMainSync { panel = field(activity, "screenPanel") as? PanelSceneObject }
            SystemClock.sleep(100L)
        }
        check(panel != null) { "Media panel did not become ready" }
        report("READY")
        val commandFile = targetContext.cacheDir.resolve("media-probe-cmd")
        val callbacks = field(activity, "controlsCallbacks") as VideoControlsCallbacks
        val state = field(activity, "controls") as VideoControlsState
        while (true) {
            if (!commandFile.exists()) { SystemClock.sleep(200L); continue }
            val lines = commandFile.readLines().map { it.trim() }.filter { it.isNotEmpty() }
            commandFile.delete()
            var stop = false
            for (line in lines) {
                val parts = line.split(" ")
                var failure: Throwable? = null
                instrumentation.runOnMainSync {
                    try {
                        when (parts[0]) {
                            "width", "commit" -> {
                                val host = field(activity, "screenHost") as WindowHost
                                val size = host.size()
                                val width = parts[1].toFloat()
                                val pose = host.surfacePose() ?: activity.javaClass
                                    .getDeclaredMethod("screenSurfacePose").apply { isAccessible = true }
                                    .invoke(activity) as Pose
                                host.resizeTo(Vector2(width, width * size.y / size.x), pose, parts[0] == "commit")
                            }
                            "drag", "dragend" -> {
                                // The real corner drag: resize, then the manipulator reshapes its frame.
                                val host = field(activity, "screenHost") as WindowHost
                                val size = host.size()
                                val width = parts[1].toFloat()
                                val pose = host.surfacePose() ?: activity.javaClass
                                    .getDeclaredMethod("screenSurfacePose").apply { isAccessible = true }
                                    .invoke(activity) as Pose
                                host.resizeTo(Vector2(width, width * size.y / size.x), pose, parts[0] == "dragend")
                                (field(activity, "manipulator") as WindowManipulator).syncFrame(WindowKind.SCREEN)
                            }
                            "dragseq" -> {
                                // Frame-by-frame corner drag like a real session: from w0 to w1 in n steps,
                                // one step per ~11 ms on the main thread, then a commit at the end.
                                val w0 = parts[1].toFloat(); val w1 = parts[2].toFloat(); val n = parts[3].toInt()
                                val host = field(activity, "screenHost") as WindowHost
                                val manipulator = field(activity, "manipulator") as WindowManipulator
                                val handler = android.os.Handler(android.os.Looper.getMainLooper())
                                fun step(i: Int) {
                                    val size = host.size()
                                    val width = w0 + (w1 - w0) * i / n
                                    val pose = host.surfacePose() ?: activity.javaClass
                                        .getDeclaredMethod("screenSurfacePose").apply { isAccessible = true }
                                        .invoke(activity) as Pose
                                    host.resizeTo(Vector2(width, width * size.y / size.x), pose, i == n)
                                    manipulator.syncFrame(WindowKind.SCREEN)
                                    if (i < n) handler.postDelayed({ step(i + 1) }, 11L)
                                }
                                step(0)
                            }
                            "frames" -> {
                                val manipulator = field(activity, "manipulator") as WindowManipulator
                                @Suppress("UNCHECKED_CAST")
                                val slots = field(manipulator, "slots") as Map<*, *>
                                val doomed = field(manipulator, "doomed") as List<*>
                                val slot = slots[WindowKind.SCREEN]
                                val panel = slot?.let { field(it, "framePanel") as? PanelSceneObject }
                                android.util.Log.i("MediaProbe", "FRAMES slots=${slots.keys} doomed=${doomed.size} " +
                                    "frameSize=${slot?.let { field(it, "frameSize") }} mesh=${panel?.mesh?.computeCombinedBounds()?.size()} " +
                                    "layer=${panel?.layer}")
                            }
                            "frame" -> {
                                // Light the screen frame's handles as if a ray hovered a corner.
                                val manipulator = field(activity, "manipulator") as WindowManipulator
                                @Suppress("UNCHECKED_CAST")
                                val states = field(manipulator, "states") as Map<WindowKind, m.c.g.a.i_iwara.questui.WindowFrameState>
                                val lit = parts[1] == "lit"
                                // pointerZone/nearEdge are rewritten by the hit loop every tick;
                                // activeZone (a grab in progress) is only touched by sessions.
                                states.getValue(WindowKind.SCREEN).activeZone =
                                    if (lit) m.c.g.a.i_iwara.questui.WindowFrameZone.CORNER_BR else m.c.g.a.i_iwara.questui.WindowFrameZone.NONE
                            }
                            "curve" -> callbacks.onPickCurve(ScreenCurve.valueOf(parts[1]))
                            "scene" -> callbacks.onPickScene(SceneKind.valueOf(parts[1]))
                            "glow" -> callbacks.onMediaEffects(state.mediaEffects.copy(glowStrength = parts[1].toFloat()))
                            "feather" -> callbacks.onMediaEffects(state.mediaEffects.copy(edgeFeather = parts[1].toFloat()))
                            "effects" -> callbacks.onMediaEffects(state.mediaEffects.copy(enabled = parts[1].toBoolean()))
                            "playpause" -> callbacks.onPlayPause()
                            "pipeline" -> {
                                // Idle the colour worker (no further ticks); measurement only.
                                val renderer = activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity)
                                val pipeline = checkNotNull(field(renderer, "pipeline"))
                                pipeline.javaClass.getDeclaredField("closed").apply { isAccessible = true }.set(pipeline, !parts[1].toBoolean())
                            }
                            "halo" -> {
                                // Hide only the halo scene object: isolates its draw cost.
                                val renderer = activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity)
                                (field(renderer, "glowObject") as? SceneObject)?.setIsVisible(parts[1].toBoolean())
                            }
                            "quit" -> stop = true
                            else -> error("Unknown command $line")
                        }
                    } catch (error: Throwable) { failure = error }
                }
                failure?.let { throw it }
                SystemClock.sleep(600L)
                var status = ""
                instrumentation.runOnMainSync {
                    val host = field(activity, "screenHost") as WindowHost
                    val current = field(activity, "screenPanel") as? PanelSceneObject
                    val mesh = current?.mesh?.computeCombinedBounds()?.size()
                    val renderer = activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity)
                    val glow = (field(renderer, "glowObject") as? SceneObject)?.mesh?.computeCombinedBounds()?.size()
                    val pipeline = field(renderer, "pipeline") as? MediaColorPipeline
                    status = "frame=${host.size()} arc=${host.arcDegrees()} panelMesh=$mesh haloMesh=$glow " +
                        "geometry=${field(renderer, "geometry")} failed=${field(activity, "mediaEffectsFailed")} " +
                        "copiedFrames=${pipeline?.copiedFrames} colourSequence=${pipeline?.colors?.sequence}"
                }
                report("DONE $line :: $status")
                if (stop) break
            }
            if (stop) break
        }
        report("PASS visual probe")
    }

    private fun field(target: Any, name: String): Any? =
        target.javaClass.getDeclaredField(name).apply { isAccessible = true }.get(target)
}
