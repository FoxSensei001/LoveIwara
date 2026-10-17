package m.c.g.a.i_iwara

import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.util.Rational
import androidx.activity.ComponentActivity
import androidx.core.app.PictureInPictureModeChangedInfo
import androidx.core.util.Consumer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 画中画（小窗）的原生那半，Dart 那半见 `lib/utils/android_pip.dart`。
 *
 * 取代原来的 `floating` 插件，原因有三：
 * - 插件把「进入失败」的两种形态都丢给了调用方：`enterPictureInPictureMode` 返回 false
 *   只变成一个没人看的返回值；抛 IllegalStateException（「Activity must be resumed」）
 *   则变成 Dart 侧一个没人 await 的异常。用户看到的就是「点了没反应」，日志里也没有原因。
 *   这里把失败原因、当时的 Activity 生命周期一并回传。
 * - 插件没有状态回调，只能轮询 `isInPictureInPictureMode`；这里转发系统的进出事件。
 *   用 androidx 的监听器而不是重写 `onPictureInPictureModeChanged(Boolean, Configuration)`：
 *   后者 API 26 才有，Android 7.x 上永远不会被调用；监听器两种回调都转、还去重。
 * - 宽高比超出系统允许的 1:2.39 ~ 2.39:1 时插件直接抛异常；这里夹到边界上。
 */
class PipBridge(private val activity: ComponentActivity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, CHANNEL)
    private val modeListener = Consumer<PictureInPictureModeChangedInfo> { info ->
        channel.invokeMethod("onPipModeChanged", info.isInPictureInPictureMode)
    }

    /** Android 11 及以下没有 setAutoEnterEnabled，离开应用时由 [onUserLeaveHint] 代办。 */
    private var legacyAutoEnterRatio: Rational? = null

    init {
        channel.setMethodCallHandler(::onMethodCall)
        activity.addOnPictureInPictureModeChangedListener(modeListener)
    }

    fun dispose() {
        activity.removeOnPictureInPictureModeChangedListener(modeListener)
        channel.setMethodCallHandler(null)
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(isSupported())
            "isInPip" -> result.success(
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.N &&
                    activity.isInPictureInPictureMode
            )
            "enter" -> result.success(enter(ratioOf(call)))
            "setAutoEnter" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                result.success(setAutoEnter(if (enabled) ratioOf(call) else null))
            }
            else -> result.notImplemented()
        }
    }

    private fun isSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.N &&
            activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun enter(ratio: Rational): Map<String, Any?> {
        val lifecycle = activity.lifecycle.currentState.name
        val sdk = Build.VERSION.SDK_INT
        if (!isSupported()) {
            return mapOf(
                "entered" to false,
                "reason" to "unsupported",
                "lifecycle" to lifecycle,
                "sdk" to sdk,
            )
        }
        return try {
            val entered = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity.enterPictureInPictureMode(paramsOf(ratio, autoEnter = null))
            } else {
                @Suppress("DEPRECATION")
                activity.enterPictureInPictureMode()
                true
            }
            if (!entered) Log.w(TAG, "系统拒绝进入画中画，lifecycle=$lifecycle")
            mapOf(
                "entered" to entered,
                "reason" to if (entered) null else "refused",
                "lifecycle" to lifecycle,
                "sdk" to sdk,
            )
        } catch (e: IllegalStateException) {
            // 服务端校验（不支持画中画、窗口不可见）抛的也是 IllegalStateException，
            // 只有客户端闸门那条才算 notResumed。
            //
            // 客户端闸门 mCanEnterPictureInPicture 在 stop 时置 false、restart 时置回，回桌面
            // 一趟就会重置——和「从小窗展开后换一条视频按钮没反应，回桌面一趟又好了」的
            // 报障形状一致。但按 AOSP，Activity 在 resumed 时不该处于这个状态，所以这只是
            // 嫌疑（可能是 OEM 改过的行为），没在真机抓到过；原因原样回传给 Dart 记日志。
            val notResumed = e.message?.contains("must be resumed") == true
            Log.w(TAG, "进入画中画被拒，lifecycle=$lifecycle", e)
            mapOf(
                "entered" to false,
                "reason" to if (notResumed) "notResumed" else "error",
                "message" to "${e.javaClass.simpleName}: ${e.message}",
                "lifecycle" to lifecycle,
                "sdk" to sdk,
            )
        } catch (e: RuntimeException) {
            Log.w(TAG, "进入画中画失败，lifecycle=$lifecycle", e)
            mapOf(
                "entered" to false,
                "reason" to "error",
                "message" to "${e.javaClass.simpleName}: ${e.message}",
                "lifecycle" to lifecycle,
                "sdk" to sdk,
            )
        }
    }

    /**
     * 离开应用（回桌面 / 切走）时自动进入小窗。传 null 撤销。
     *
     * Android 12+ 交给系统的 setAutoEnterEnabled，切走的动画就是缩成小窗；更早的版本在
     * [onUserLeaveHint] 里手动进入。返回值表示这次设置是否生效。
     */
    private fun setAutoEnter(ratio: Rational?): Boolean {
        if (!isSupported()) return false
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                activity.setPictureInPictureParams(
                    if (ratio == null) {
                        PictureInPictureParams.Builder().setAutoEnterEnabled(false).build()
                    } else {
                        paramsOf(ratio, autoEnter = true)
                    }
                )
            } else {
                legacyAutoEnterRatio = ratio
            }
            true
        } catch (e: RuntimeException) {
            Log.w(TAG, "设置离开时自动画中画失败", e)
            false
        }
    }

    /**
     * MainActivity.onUserLeaveHint 转进来。只服务 Android 11 及以下。
     *
     * ⛔ 这里走的仍是客户端闸门：当场进入已经因为 notResumed 失败的话，这里照样失败。
     * 所以 Dart 侧「当场失败 → 改设离开时自动进入」的兜底只在 Android 12+ 启用。
     */
    fun onUserLeaveHint() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) return
        val ratio = legacyAutoEnterRatio ?: return
        enter(ratio)
    }

    private fun paramsOf(ratio: Rational, autoEnter: Boolean?): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder().setAspectRatio(ratio)
        if (autoEnter != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(autoEnter)
        }
        return builder.build()
    }

    /** 系统只接受 1:2.39 ~ 2.39:1（含边界），超出直接抛 IllegalArgumentException。 */
    private fun ratioOf(call: MethodCall): Rational {
        val width = call.argument<Int>("width") ?: 16
        val height = call.argument<Int>("height") ?: 9
        if (width <= 0 || height <= 0) return Rational(16, 9)
        val value = width.toDouble() / height
        return when {
            value > MAX_RATIO -> Rational(239, 100)
            value < 1 / MAX_RATIO -> Rational(100, 239)
            else -> Rational(width, height)
        }
    }

    companion object {
        private const val CHANNEL = "i_iwara/pip"
        private const val TAG = "PipBridge"
        private const val MAX_RATIO = 2.39
    }
}
