package m.c.g.a.i_iwara

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

/**
 * 有下载在跑时把进程托在前台（issue #136：熄屏 / 切到别的应用后下载停住）。
 *
 * 下载本身仍在 Dart 里跑，这只服务**什么都不下载**，它只做三件事：
 * - 以 dataSync 前台服务的身份挂一条进度常驻通知——进程从此不再是「缓存进程」，
 *   系统的缓存应用冻结器（cached apps freezer）不会把它冻住，Doze 也不断它的网；
 * - 持一把 PARTIAL_WAKE_LOCK，熄屏后 CPU 不睡；
 * - 持一把 WifiLock，熄屏后 Wi-Fi 不降到省电档。
 *
 * 只管「切走 / 熄屏」：用户从最近任务里划掉应用时 Activity 跟着销毁，Dart 引擎随之
 * 停掉，这只服务留着也没有意义，所以 [onTaskRemoved] 直接收摊。
 *
 * 启停全部由 Dart 侧 `DownloadKeepAlive` 决定（下载中 + 等待中是否为空），这里不做
 * 任何业务判断；进程被杀后也不重启（START_NOT_STICKY）——没有 Dart 的话没人下载。
 */
class DownloadKeepAliveService : Service() {

    /** 通知上显示的内容。由 Dart 传进来，原生侧不拼任何文案。 */
    data class Content(
            val channelName: String,
            val channelDescription: String,
            val title: String,
            val text: String,
            /** 0..[PROGRESS_MAX]；null 表示进度不确定（显示来回滚动的条）。 */
            val progress: Int?,
    )

    companion object {
        private const val TAG = "DownloadKeepAlive"
        private const val CHANNEL_ID = "download_progress"
        private const val NOTIFICATION_ID = 0x1D0A
        const val PROGRESS_MAX = 1000

        /** 锁的兜底超时：正常由 [stop] 释放，这只是防止哪条路径漏了释放把电耗光。 */
        private const val LOCK_TIMEOUT_MS = 6L * 60 * 60 * 1000

        @Volatile private var content: Content? = null

        /** 服务是否已经以前台身份跑起来（[onStartCommand] 里 startForeground 成功后置真）。 */
        @Volatile var isRunning = false
            private set

        /** 已经 startForegroundService、还没走到 [onStartCommand] 的那一小段。 */
        @Volatile private var startRequested = false

        /**
         * 请求起服务。返回 false 表示系统不让起（Android 12+ 从后台起前台服务会被拒，
         * 例如应用已在后台时自动重试的任务开跑）。被拒时下载照常进行，只是没有保活。
         */
        fun start(context: Context, next: Content): Boolean {
            content = next
            val app = context.applicationContext
            ensureChannel(app, next)
            if (isRunning) {
                notify(app, next)
                return true
            }
            return try {
                ContextCompat.startForegroundService(
                        app,
                        Intent(app, DownloadKeepAliveService::class.java)
                )
                startRequested = true
                true
            } catch (e: Exception) {
                Log.w(TAG, "起前台服务被拒: $e")
                false
            }
        }

        /**
         * 刷新通知内容。服务已经停了（例如到了系统时长上限）返回 false；还在起的路上
         * 只记下内容，[onStartCommand] 会用最新的那份。
         */
        fun update(context: Context, next: Content): Boolean {
            content = next
            if (!isRunning) return startRequested
            notify(context.applicationContext, next)
            return true
        }

        /**
         * 停服务。可以重复调，服务没在跑时什么都不发生——Dart 侧启动时会无条件调一次，
         * 收掉上一个引擎留下的孤儿服务。
         */
        fun stop(context: Context) {
            content = null
            if (startRequested && !isRunning) {
                // 已经 startForegroundService、onStartCommand 还没跑到：这时 stopService，
                // 系统会判「答应了前台却没兑现」直接让进程崩溃。交给 onStartCommand，
                // 它看到 content 为空会先挂上再撤掉。
                return
            }
            // 同步置假：onDestroy 要晚一拍才跑，这中间紧接着来的 start 不能被它骗成
            // 「已经在跑，只刷新通知」。
            isRunning = false
            val app = context.applicationContext
            app.stopService(Intent(app, DownloadKeepAliveService::class.java))
        }

        private fun ensureChannel(context: Context, c: Content) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val channel =
                    NotificationChannel(CHANNEL_ID, c.channelName, NotificationManager.IMPORTANCE_LOW)
                            .apply {
                                description = c.channelDescription
                                setShowBadge(false)
                            }
            // 同 id 重复创建只会更新名称 / 描述（随语言切换），不会重置用户改过的设置。
            context.getSystemService(NotificationManager::class.java)
                    ?.createNotificationChannel(channel)
        }

        private fun notify(context: Context, c: Content) {
            try {
                NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, build(context, c))
            } catch (e: SecurityException) {
                // Android 13+ 没给通知权限：前台服务照样有效，只是通知不显示。
                Log.w(TAG, "刷新进度通知失败: $e")
            }
        }

        private fun build(context: Context, c: Content): Notification {
            val launch =
                    context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    }
            val contentIntent =
                    launch?.let {
                        PendingIntent.getActivity(
                                context,
                                NOTIFICATION_ID,
                                it,
                                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                    }
            return NotificationCompat.Builder(context, CHANNEL_ID)
                    .setSmallIcon(android.R.drawable.stat_sys_download)
                    .setContentTitle(c.title)
                    .setContentText(c.text)
                    .setProgress(PROGRESS_MAX, c.progress ?: 0, c.progress == null)
                    .setContentIntent(contentIntent)
                    .setOngoing(true)
                    .setOnlyAlertOnce(true)
                    .setSilent(true)
                    .setShowWhen(false)
                    .setCategory(NotificationCompat.CATEGORY_PROGRESS)
                    .setPriority(NotificationCompat.PRIORITY_LOW)
                    // Android 12+ 默认把前台服务通知压 10 秒再显示；下载期间用户切走时就该
                    // 看得到「为什么还挂着一条通知」，所以立即显示。
                    .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                    .build()
        }
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startRequested = false
        val c = content
        if (c == null) {
            // 起服务的路上 Dart 已经喊停（见 stop()）。startForegroundService 之后必须
            // startForeground 一次，否则系统判崩溃——先挂上再立刻撤掉。
            enterForeground(fallbackContent())
            stopSelf()
            return START_NOT_STICKY
        }
        if (!enterForeground(c)) {
            stopSelf()
            return START_NOT_STICKY
        }
        isRunning = true
        acquireLocks()
        return START_NOT_STICKY
    }

    private fun enterForeground(c: Content): Boolean {
        return try {
            val notification = build(this, c)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            true
        } catch (e: Exception) {
            Log.w(TAG, "startForeground 失败: $e")
            false
        }
    }

    private fun fallbackContent() = Content(CHANNEL_ID, "", "", "", null)

    private fun acquireLocks() {
        if (wakeLock?.isHeld != true) {
            wakeLock =
                    getSystemService(PowerManager::class.java)
                            ?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "LoveIwara:download")
                            ?.apply {
                                setReferenceCounted(false)
                                acquire(LOCK_TIMEOUT_MS)
                            }
        }
        if (wifiLock?.isHeld != true) {
            try {
                @Suppress("DEPRECATION")
                wifiLock =
                        applicationContext
                                .getSystemService(WifiManager::class.java)
                                ?.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "LoveIwara:download")
                                ?.apply {
                                    setReferenceCounted(false)
                                    acquire()
                                }
            } catch (e: Exception) {
                Log.w(TAG, "WifiLock 获取失败: $e")
            }
        }
    }

    private fun releaseLocks() {
        try {
            wakeLock?.takeIf { it.isHeld }?.release()
        } catch (_: Exception) {}
        try {
            wifiLock?.takeIf { it.isHeld }?.release()
        } catch (_: Exception) {}
        wakeLock = null
        wifiLock = null
    }

    /** Android 15+：dataSync 前台服务每 24 小时累计最多 6 小时，到点必须自己停，否则系统判崩溃。 */
    override fun onTimeout(startId: Int, fgsType: Int) {
        Log.w(TAG, "dataSync 前台服务到达系统时长上限，停止保活")
        stopSelf()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        isRunning = false
        releaseLocks()
        super.onDestroy()
    }
}
