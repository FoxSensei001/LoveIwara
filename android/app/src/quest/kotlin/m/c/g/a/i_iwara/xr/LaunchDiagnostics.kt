package m.c.g.a.i_iwara.xr

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 「Quest 版打开是平面模式」的取证记录。
 *
 * 用户反馈的形状：同一台机器有时进空间版、重启 / 换个入口又变回一块孤零零的 2D 面板。
 * 平面形态 = [m.c.g.a.i_iwara.MainActivity] 被**顶层直接拉起**（落在显示 0），ImmersiveActivity
 * 根本没建；空间形态 = ImmersiveActivity 先起、再把 MainActivity 挂进面板（落在虚拟显示）。
 * 所以要回答「这次是哪种、为什么」只需要三样东西：
 *
 * 1. 这个进程里 ImmersiveActivity 有没有被建过、场景起没起来；
 * 2. MainActivity 落在哪块显示上、是被什么 intent / 谁拉起的（入口）；
 * 3. 装着的这个包里 LAUNCHER / VR_HOME_LAUNCHER 分别解析到谁（区分「老包没带入口修复」）。
 *
 * ⭐ 事件**落盘**（SharedPreferences 环形保留最近 [MAX_EVENTS] 条）：用户描述的是「上次是空间版、
 * 这次变平面」，只看本次进程说明不了跨启动的差异；而且出事那次用户多半没开日志开关，
 * 落盘后下一次开着日志启动就能把前几次的经过一并带出来。
 *
 * 由 Dart 的 `XrImmersiveService` 启动时经 `launchDiagnostics` 取走写进应用日志。
 */
object LaunchDiagnostics {

    private const val TAG = "IwaraLaunch"
    private const val PREFS = "xr_launch_diagnostics"
    private const val KEY_EVENTS = "events"
    private const val MAX_EVENTS = 80

    /** 本进程里 ImmersiveActivity 是否被创建过（onCreate 走到过就算，不管后来死没死）。 */
    @Volatile
    var immersiveCreatedInProcess = false
        private set

    /** 本进程里 MainActivity 最近一次挂上引擎时所在的显示；-1 = 还没挂过。0 = 顶层平面窗口。 */
    @Volatile
    var mainDisplayId = -1
        private set

    /** 本进程第一个被创建的 Activity（Immersive / Main），直接说明入口落到了谁身上。 */
    @Volatile
    var firstActivity: String? = null
        private set

    private val timeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US)

    fun onImmersiveCreated(activity: Activity, savedInstanceState: Bundle?) {
        immersiveCreatedInProcess = true
        if (firstActivity == null) firstActivity = "ImmersiveActivity"
        record(
            activity,
            "IMMERSIVE onCreate restored=${savedInstanceState != null} task=${activity.taskId} " +
                "${launchSource(activity)} intent={${describe(activity.intent)}}",
        )
    }

    fun onImmersiveEvent(context: Context, event: String) = record(context, "IMMERSIVE $event")

    /** MainActivity 挂引擎时调（configureFlutterEngine → XrBridge.attach）。 */
    fun onMainAttached(activity: Activity) {
        if (firstActivity == null) firstActivity = "MainActivity"
        mainDisplayId = displayIdOf(activity)
        record(
            activity,
            "MAIN attach display=$mainDisplayId taskRoot=${activity.isTaskRoot} task=${activity.taskId} " +
                "immersiveInProcess=$immersiveCreatedInProcess sceneAlive=${ImmersiveBridge.isSceneAlive} " +
                "${launchSource(activity)} intent={${describe(activity.intent)}}",
        )
    }

    fun onMainEvent(context: Context, event: String) = record(context, "MAIN $event")

    /** 当前形态的判定。字符串直接进日志，给人看的。 */
    fun verdict(): String = when {
        ImmersiveBridge.isSceneAlive -> "immersive"
        immersiveCreatedInProcess -> "immersive_scene_not_ready"
        mainDisplayId == 0 -> "flat_main_launched_directly"
        mainDisplayId > 0 -> "panel_without_immersive"
        else -> "unknown"
    }

    fun snapshot(context: Context): Map<String, Any?> = mapOf(
        "verdict" to verdict(),
        "firstActivity" to firstActivity,
        "immersiveCreatedInProcess" to immersiveCreatedInProcess,
        "sceneAlive" to ImmersiveBridge.isSceneAlive,
        "mainDisplayId" to mainDisplayId,
        "pid" to android.os.Process.myPid(),
        "package" to packageVersion(context),
        "launcherResolvesTo" to resolveEntry(context, Intent.CATEGORY_LAUNCHER),
        "vrHomeLauncherResolvesTo" to resolveEntry(context, "com.oculus.intent.category.VR_HOME_LAUNCHER"),
        "history" to history(context),
    )

    // ---------------------------------------------------------------- 内部

    private fun record(context: Context, event: String) {
        val line = "${timeFormat.format(Date())} pid=${android.os.Process.myPid()} $event"
        Log.i(TAG, line)
        runCatching {
            val prefs = context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            synchronized(this) {
                val lines = prefs.getString(KEY_EVENTS, "").orEmpty()
                    .split('\n').filter { it.isNotBlank() }
                    .takeLast(MAX_EVENTS - 1) + line
                prefs.edit().putString(KEY_EVENTS, lines.joinToString("\n")).apply()
            }
        }.onFailure { Log.w(TAG, "record failed", it) }
    }

    private fun history(context: Context): List<String> = runCatching {
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_EVENTS, "").orEmpty().split('\n').filter { it.isNotBlank() }
    }.getOrDefault(emptyList())

    private fun displayIdOf(activity: Activity): Int = runCatching {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.display?.displayId ?: -1
        } else {
            @Suppress("DEPRECATION")
            activity.windowManager.defaultDisplay.displayId
        }
    }.getOrDefault(-1)

    /** 谁把它拉起来的：referrer（主页启动器 / 安装器 / 系统恢复）+ API 34 起的 launchedFromPackage。 */
    private fun launchSource(activity: Activity): String {
        val referrer = runCatching { activity.referrer?.toString() }.getOrNull()
        val fromPackage = if (Build.VERSION.SDK_INT >= 34) {
            runCatching { activity.launchedFromPackage }.getOrNull()
        } else {
            null
        }
        return "referrer=$referrer fromPkg=$fromPackage"
    }

    private fun describe(intent: Intent?): String {
        intent ?: return "null"
        return "action=${intent.action} categories=${intent.categories?.sorted()} " +
            "component=${intent.component?.shortClassName} flags=0x${Integer.toHexString(intent.flags)} " +
            "fromHistory=${intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0}"
    }

    /** 装着的这个包里某个入口 category 解析到哪个 Activity；老包（入口还挂在 MainActivity 上）一眼可见。 */
    private fun resolveEntry(context: Context, category: String): List<String> = runCatching {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(category).setPackage(context.packageName)
        @Suppress("DEPRECATION")
        context.packageManager.queryIntentActivities(intent, 0)
            .map { it.activityInfo.name.substringAfterLast('.') }
    }.getOrElse { listOf("error: ${it.message}") }

    private fun packageVersion(context: Context): String = runCatching {
        @Suppress("DEPRECATION")
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        "${info.versionName}+$code"
    }.getOrElse { if (it is PackageManager.NameNotFoundException) "not_found" else "error" }
}
