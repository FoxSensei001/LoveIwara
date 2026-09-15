package m.c.g.a.i_iwara.vr

import android.app.Instrumentation
import android.content.Intent
import android.os.SystemClock
import com.meta.spatial.runtime.PanelSceneObject
import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoFormat

/** Real compositor/lifecycle regression; only enters the device-test APK. */
internal class EnvironmentDeviceProbe(private val instrumentation: Instrumentation) {
    fun run(report: (String) -> Unit) {
        val target = instrumentation.targetContext
        val video = target.cacheDir.resolve("media-effects-probe.mp4")
        instrumentation.context.assets.open(video.name).use { input -> video.outputStream().use { input.copyTo(it) } }
        val activity = instrumentation.startActivitySync(
            Intent(target, ImmersiveActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .putExtra("url", "file://$video").putExtra("shape", "flat")
                .putExtra("stereo", "none").putExtra("mute", true)
                .putExtra("environment", "passthrough").putExtra("background", .81f)
                .putExtra("title", "Environment regression"),
        ) as ImmersiveActivity
        await("scene ready") { field(activity, "backgroundEnvironment") != null && field(activity, "screenPanel") != null }
        val state = main { field(activity, "controls") as VideoControlsState }
        val callbacks = main { field(activity, "controlsCallbacks") as VideoControlsCallbacks }
        val owner = main { field(activity, "backgroundEnvironment") as BackgroundEnvironment }
        fun currentPanel() = field(owner, "panel") as? PanelSceneObject
        fun select(kind: EnvironmentKind, dynamic: Boolean = true) = main {
            callbacks.onEnvironment(EnvironmentSettings(kind, .65f, dynamicSpace = dynamic))
        }
        fun settled(kind: EnvironmentKind) = await("$kind settled") {
            check(!state.environmentLoadFailed) { "Environment failed: ${state.environment}" }
            val dark = !mediaEffects(activity).isPassthroughEnabled
            state.environment.kind == kind && !state.environmentLoading &&
                if (kind.hasPanorama) {
                    owner.ready && dark && field(owner, "displayedAsset") == environmentAsset(state.environment) &&
                        (field(owner, "fade") as EnvironmentFade).valueAt(SystemClock.uptimeMillis()) == 1f
                } else currentPanel() == null && (kind != EnvironmentKind.VOID || dark)
        }

        var reused: PanelSceneObject? = null
        for (kind in listOf(EnvironmentKind.AURORA, EnvironmentKind.SUNSET, EnvironmentKind.MIST, EnvironmentKind.DEEP_SPACE)) {
            select(kind, dynamic = kind != EnvironmentKind.DEEP_SPACE)
            settled(kind)
            main {
                val panel = checkNotNull(currentPanel())
                check(panel.layer != null && panel.texture == null && panel.display == null) { "Background lost direct compositor ownership" }
                if (reused != null) check(panel === reused) { "Switching worlds recreated the layer" }
                reused = panel
                check(field(owner, "orbital") == null) { "Remembered space motion leaked into a landscape" }
            }
            report("PASS environment $kind: ready, direct compositor, stable layer")
        }

        select(EnvironmentKind.SUNSET)
        settled(EnvironmentKind.SUNSET)
        for (brightness in listOf(0f, 1f, .31f)) {
            main { callbacks.onEnvironment(state.environment.copy(spaceBrightness = brightness)) }
            await("brightness $brightness") { field(owner, "appliedBrightness") == brightness }
            main { check(currentPanel() === reused && !mediaEffects(activity).isPassthroughEnabled) }
        }
        report("PASS environment brightness endpoints keep the room hidden")

        main {
            repeat(12) { i ->
                callbacks.onEnvironment(state.environment.copy(kind = if (i % 2 == 0) EnvironmentKind.MIST else EnvironmentKind.AURORA))
            }
            callbacks.onEnvironment(state.environment.copy(kind = EnvironmentKind.MIST))
        }
        settled(EnvironmentKind.MIST)
        main { check(currentPanel() === reused) }
        report("PASS rapid environment changes discard stale decodes")

        select(EnvironmentKind.DEEP_SPACE)
        settled(EnvironmentKind.DEEP_SPACE)
        val retiredBodies = main { checkNotNull(field(owner, "orbital")) }
        main {
            val gpu = checkNotNull(field(retiredBodies, "renderer"))
            // Reproduce the timeout path without a driver fault: queue a slow
            // GPU operation, then ensure its detached layer owner stays alive.
            (field(gpu, "handler") as android.os.Handler).post { SystemClock.sleep(4000L) }
        }
        select(EnvironmentKind.MIST)
        settled(EnvironmentKind.MIST)
        await("retired orbital surfaces released") { (field(retiredBodies, "targets") as List<*>).isEmpty() }
        report("PASS delayed GPU cleanup retains and releases hidden body layers")

        main { owner.setResumed(false) }
        select(EnvironmentKind.AURORA)
        main { check(field(owner, "skyLoading") == false) { "Paused background started a decode" } }
        main { owner.setResumed(true) }
        settled(EnvironmentKind.AURORA)
        report("PASS environment resume restores the selected panorama")

        main { callbacks.onPickFormat(VideoFormat.PANO_360_2D) }
        await("360 releases background") { currentPanel() == null && owner.replacesRoom && !mediaEffects(activity).isPassthroughEnabled }
        main { callbacks.onPickFormat(VideoFormat.FLAT_2D) }
        settled(EnvironmentKind.AURORA)
        report("PASS 360 coverage releases and restores the environment")

        main {
            activity.javaClass.getDeclaredMethod("backToApp").apply { isAccessible = true }.invoke(activity)
        }
        settled(EnvironmentKind.AURORA)
        main { check(field(activity, "backgroundEnvironment") === owner) }
        report("PASS leaving playback retains the same browse environment")

        select(EnvironmentKind.VOID)
        settled(EnvironmentKind.VOID)
        main { check(!owner.needsViewerPose && field(owner, "orbital") == null) }
        select(EnvironmentKind.PASSTHROUGH)
        settled(EnvironmentKind.PASSTHROUGH)
        await("room restored") { mediaEffects(activity).isPassthroughEnabled }
        main { check(state.mediaEffects.backgroundTransparency == .81f) }
        report("PASS black has no panorama allocation and passthrough retains its brightness")
    }

    private fun mediaEffects(activity: ImmersiveActivity): MediaEffectsRenderer =
        activity.javaClass.getDeclaredMethod("getMediaEffects").apply { isAccessible = true }.invoke(activity) as MediaEffectsRenderer

    private fun field(target: Any, name: String): Any? =
        target.javaClass.getDeclaredField(name).apply { isAccessible = true }.get(target)

    private fun <T> main(action: () -> T): T {
        var result: Result<T>? = null
        instrumentation.runOnMainSync { result = runCatching(action) }
        return checkNotNull(result).getOrThrow()
    }

    private fun await(label: String, ready: () -> Boolean) {
        val deadline = SystemClock.uptimeMillis() + 20_000L
        while (SystemClock.uptimeMillis() < deadline) {
            if (main(ready)) return
            SystemClock.sleep(50L)
        }
        error("Timed out: $label")
    }
}
