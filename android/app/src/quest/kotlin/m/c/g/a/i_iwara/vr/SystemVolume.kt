package m.c.g.a.i_iwara.vr

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.util.Log
import kotlin.math.roundToInt

/**
 * 系统音量。Horizon OS 上就是 Android 的 `STREAM_MUSIC`：头显侧边的物理音量键、通用菜单里
 * 那根滑杆、我们面板上的音量条，调的是同一个值。
 *
 * 两件事：
 * - **读**：[level] 把系统的整数档位折算成 0..1。[poll] 每帧来一次（自带节流），
 *   所以用户按了物理音量键、或在通用菜单里改了，面板上的百分比会跟着动。
 *   ⛔ 不走 `ContentObserver`：Horizon OS 是否把音量写进 `Settings.System` 没有任何文档保证，
 *   而沉浸态本来就有每帧的 `ImmersiveActivity.onSceneTick`，轮询是唯一不依赖未公开行为的做法。
 * - **写**：[setLevel] 落到最近的一档，并把**落档后的真实值**还回来 —— 面板显示的百分比
 *   永远是系统真的在用的那个，不是手指停在哪。
 *
 * 系统只有 [steps] + 1 档 —— Quest 3 实测 `STREAM_MUSIC` 是 **Min 0 / Max 15，即 16 档**
 * （档数仍按运行时读到的值算，不写死）。滑杆因此有台阶感：那是真相，不该拿插值糊掉，
 * 糊了就不叫「反映真实系统音量」。
 *
 * ⭐ 音量是**按输出设备各记一份**的（实测同一时刻 speaker 4 / headphone 7 / usb_headset 11），
 * `getStreamVolume` 给的是当前在用的那个 —— 戴上耳机数值会跳，照实反映即可。
 */
class SystemVolume(context: Context) {

    private val audio =
        context.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    private val minIndex: Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            runCatching { audio.getStreamMinVolume(STREAM) }.getOrDefault(0)
        } else 0

    private val maxIndex: Int =
        runCatching { audio.getStreamMaxVolume(STREAM) }.getOrDefault(DEFAULT_MAX)
            .coerceAtLeast(minIndex + 1)

    /** 系统音量一共几段（档数 − 1）。0% 与 100% 之间就是这么多步。 */
    val steps: Int = maxIndex - minIndex

    private var lastPollAt = 0L

    /** 上一次报给面板的值。−1 = 还没报过，第一次 [poll] 必定回调一次真值。 */
    private var lastLevel = -1f

    /** 当前系统音量，0..1。 */
    fun level(): Float = levelOf(index())

    private fun index(): Int =
        runCatching { audio.getStreamVolume(STREAM) }.getOrDefault(minIndex)
            .coerceIn(minIndex, maxIndex)

    private fun levelOf(index: Int): Float = (index - minIndex).toFloat() / steps

    /**
     * 把系统音量设到离 [level] 最近的一档。
     *
     * @return 落档后的真实音量（0..1）；写不进去时返回 null —— 勿扰模式下
     *   `setStreamVolume` 会抛 `SecurityException`（要 `ACCESS_NOTIFICATION_POLICY` 才放行），
     *   调用方该去出一句提示，而不是假装调成功了。
     */
    fun setLevel(level: Float): Float? {
        val target = minIndex + (level.coerceIn(0f, 1f) * steps).roundToInt()
        if (target != index()) {
            val ok = runCatching { audio.setStreamVolume(STREAM, target, 0) }
                .onFailure { Log.w(TAG, "IMMERSIVE 系统音量写不进去 target=$target", it) }
                .isSuccess
            if (!ok) return null
        }
        // 读回来而不是拿 target 直接用：系统有权不完全听话（限幅、安全音量上限）。
        val applied = level()
        lastLevel = applied
        return applied
    }

    /**
     * 每帧调一次，[POLL_MS] 内只真读一次。系统音量与上次报的不一样就回调新值（0..1）。
     * 自己写进去的那次不会回调（[setLevel] 已经把值同步过了）。
     */
    fun poll(now: Long, onChanged: (Float) -> Unit) {
        if (lastLevel >= 0f && now - lastPollAt < POLL_MS) return
        lastPollAt = now
        val level = level()
        if (level == lastLevel) return
        lastLevel = level
        onChanged(level)
    }

    private companion object {
        const val TAG = ImmersiveActivity.TAG
        const val STREAM = AudioManager.STREAM_MUSIC

        /** `getStreamMaxVolume` 读不到时的兜底档数，按普通 Android 常见的 15 算。 */
        const val DEFAULT_MAX = 15

        /** 轮询间隔：5 Hz。一次 `getStreamVolume` 是一次 binder 调用，这个频率下开销可忽略。 */
        const val POLL_MS = 200L
    }
}
