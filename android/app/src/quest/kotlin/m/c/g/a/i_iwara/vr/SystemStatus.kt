package m.c.g.a.i_iwara.vr

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 面板顶行要显示的系统信息：时钟与头显电量。
 *
 * 电量走 `ACTION_BATTERY_CHANGED` 的 sticky 广播（注册即得一次当前值），
 * 时钟由每帧调用方按分钟节流刷新 —— 两者都不需要额外线程。
 */
class SystemStatus(private val context: Context) {

    var batteryPercent: Int = -1
        private set
    var batteryCharging: Boolean = false
        private set

    var onChanged: (() -> Unit)? = null

    private var lastClockMinute = -1L
    private val clockFormat = SimpleDateFormat("HH:mm", Locale.getDefault())

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context, intent: Intent) {
            val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
            if (level >= 0 && scale > 0) batteryPercent = level * 100 / scale
            batteryCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL
            onChanged?.invoke()
        }
    }

    fun start() {
        runCatching {
            context.registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        }
    }

    fun stop() {
        runCatching { context.unregisterReceiver(receiver) }
    }

    /** 每帧调用；只有跨过分钟边界才返回新的时钟文本，其余时候返回 null。 */
    fun clockTextIfChanged(nowMs: Long): String? {
        val minute = nowMs / 60_000L
        if (minute == lastClockMinute) return null
        lastClockMinute = minute
        return clockFormat.format(Date(nowMs))
    }
}
