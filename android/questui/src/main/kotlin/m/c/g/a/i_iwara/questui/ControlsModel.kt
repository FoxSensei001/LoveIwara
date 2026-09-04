package m.c.g.a.i_iwara.questui

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

/**
 * 空间控制面板的**数据层**：状态、动作、以及所有跨模块共享的枚举。
 *
 * ⭐ 这个文件里**一个 `@Composable` 都没有**，这是刻意的：`:app` 模块（沉浸
 * Activity 所在处）要直接读写这些类型，而它**没有也不能有** Compose 编译器插件
 * （加到 `:app` 上会让 standard 变体直接编不过，见 `questui/build.gradle` 顶部）。
 * 对外它们只是普通的 Kotlin 属性；`mutableStateOf` 只是内部实现细节。
 */

// ─────────────────────────────────────────────────────────── 路由

/**
 * 面板当前显示哪一页。
 *
 * ⛔ **只有一块面板**，页面是在它内部换的，不是弹出更多浮窗。
 * 官方 `comfort` 原文：「try to keep the main controls in a **single UI panel**,
 * as opposed to having multiple windows floating around」。
 * 参考软件也是这么做的 —— 点「场景」时整块窗换成场景选择，而不是再飘一个窗出来。
 */
enum class ControlsRoute {
    PLAYER,
    SCENE,
    VIDEO_TYPE,
    SCREEN_TYPE,
    PLAYLIST,
    SETTINGS,
}

// ─────────────────────────────────────────────────────────── 场景

/**
 * 环境场景。⛔ 只做两种（用户 2026-08-29 定的）。
 *
 * 参考软件有 MAX影院 / 太空 / 热气球 等一堆 3D 场景，我们不做 —— 每个都是一份
 * 要打进包里的 glTF 资产，而收益是装饰性的。
 */
enum class SceneKind {
    /** 虚空：什么都不画的纯黑空间。**默认档**。 */
    VOID,

    /** 透视：开 passthrough，看得见真实房间。 */
    PASSTHROUGH,
}

// ─────────────────────────────────────────────────────────── 屏幕类型

/**
 * 幕布的弯曲程度（参考软件的「屏幕类型」：直面屏 / 微曲面 / 中曲面 / 重曲面）。
 *
 * 弧幕的价值在设计文档 §6.6 已论证过：曲率半径 = 观看距离时每个像素到眼等距，
 * 无梯形畸变、无边缘离焦，这就是 IMAX 的环抱感。
 *
 * ⚠️ **`CylinderShapeOptions` 能不能承载视频，是本设计最大的单点未知**
 * （文档 §6.6-5：类型系统上 `CylinderShapeOptions : MediaPanelShapeOptions` 合法，
 * 但官方媒体面板文档列的形状只有 Quad / Equirect180 / Equirect360）。
 * 所以 [FLAT] 永远走 `QuadShapeOptions`，是保证能用的那一档；三档曲面是要在
 * 真机上验的东西。验不过就把三档隐藏，不影响主路径。
 *
 * @property arcDegrees 水平弧度。半径固定取观看距离，弧长 = 半径 × 弧度。
 */
enum class ScreenCurve(val label: String, val arcDegrees: Float) {
    FLAT("直面屏", 0f),
    SLIGHT("微曲面", 40f),
    MEDIUM("中曲面", 60f),
    DEEP("重曲面", 85f),
}

// ─────────────────────────────────────────────────────────── 视频类型

/**
 * 片源投影。与 Dart 侧的 `VrProjection` 一一对应，多出 [EAC] 一档。
 *
 * ⛔ [EAC] 与 [FISHEYE] **我们放不了**，但**照样列出来**：
 * Spatial SDK 的面板形状只有 Quad / Equirect180 / Equirect360 / Cylinder
 * （官方 API reference 逐字确认），这两种投影都没有，要自建 mesh + 着色器。
 * 列出来并如实标「不支持 · 用其他应用打开」，比装作没有这回事强 ——
 * 用户手上真有这种片子，看到歪画面时得知道为什么。
 */
enum class VideoProjection(val label: String, val supported: Boolean) {
    FLAT("平面视频", true),
    PANORAMA_180("180° 全景", true),
    PANORAMA_360("360° 全景", true),
    EAC("EAC", false),
    FISHEYE("鱼眼", false),
}

/** 立体编排。与 Dart 侧 `VrStereoLayout` 一一对应。 */
enum class StereoLayout(val label: String) {
    MONO("2D 单目"),
    SIDE_BY_SIDE("3D 左右"),
    TOP_BOTTOM("3D 上下"),
}

// ─────────────────────────────────────────────────────────── 设置

/** 一集播完之后干什么。 */
enum class RepeatMode(val label: String) {
    /** 单集循环。**默认**，与此前硬编码的 `REPEAT_MODE_ONE` 一致。 */
    ONE("单集循环"),

    /** 播完自动放播放列表里的下一条。 */
    NEXT("自动下一条"),

    /** 播完就停。 */
    STOP("播完停止"),
}

// ─────────────────────────────────────────────────────────── 播放列表

/**
 * 播放列表里的一条。数据来自应用已有的「稍后再看」，由 Dart 侧一次性推过来。
 *
 * ⛔ **没有缩略图**，只有文字。理由是官方那条面板预算：video panel 3 个就掉出
 * 90FPS；缩略图若做成面板会直接吃预算（文档 §6.6「up-next 队列轨」已写明必须是
 * 静态图）。而要在 Compose 面板里贴网络图就得引入一个图片加载库 —— 那是另一条线，
 * 不在这一期。文字行同样能选片，先把能力打通。
 */
data class PlaylistEntry(
    val id: String,
    val title: String,
    val author: String,
    val durationText: String,
    /** 0..1。已看完的按满格。 */
    val progressRatio: Float,
    val watched: Boolean,
    /** 站外视频（youtube 一类的嵌入）放不了，列出来但点不动。 */
    val playable: Boolean,
)

// ─────────────────────────────────────────────────────────── 状态

/**
 * 控制面板的全部状态。
 *
 * **对外只是普通的 Kotlin 属性**（内部用 Compose 的 `mutableStateOf` 实现），
 * 所以 `:app` 模块可以直接 `state.isPlaying = true` 地写它，
 * 而不需要在自己那边应用 Compose 编译器插件。
 */
class VideoControlsState {

    // ---- 路由 ----
    var route by mutableStateOf(ControlsRoute.PLAYER)

    // ---- 播放 ----
    var title by mutableStateOf("")
    var isPlaying by mutableStateOf(false)
    var progress by mutableStateOf(0f)
    var positionText by mutableStateOf("0:00")
    var durationText by mutableStateOf("0:00")
    var speedText by mutableStateOf("1.0×")

    /**
     * 正在缓冲 / 正在换片。
     *
     * ⛔ 必须让用户看得见。真机反馈：换屏幕类型时「画面一黑就没了」，面板上却没有任何
     * 东西说明发生了什么 —— 黑屏 + 零反馈 = 像死机。缓冲期间面板也**不会自动收起**。
     */
    var buffering by mutableStateOf(false)

    // ---- 音量 ----
    //
    // ⛔ **只调应用自己的音量**。官方对媒体应用是 Requirement 级明文：
    // 「App must include a mute/unmute button that adjusts audio **for the app only**.
    //  Using system-wide volume and system-wide mute is **prohibited**.」
    // 参考软件实测会联动系统音量，我们**刻意不跟**（用户 2026-08-29 拍板）。
    var volume by mutableStateOf(1f)

    /** 静音开关。⛔ 这不是可选项，是官方 Requirement 里点名要有的按钮。 */
    var muted by mutableStateOf(false)

    // ---- 片源格式 ----
    var projection by mutableStateOf(VideoProjection.FLAT)
    var stereo by mutableStateOf(StereoLayout.MONO)

    // ---- 幕布 ----
    var curve by mutableStateOf(ScreenCurve.FLAT)

    /** 球幕（180/360）没有「屏幕类型」可言 —— 人在球心，弯的是整个世界。 */
    var curveAvailable by mutableStateOf(true)

    /** 观看距离（米）。 */
    var screenDistance by mutableStateOf(2.5f)

    /** 幕心相对静息眼高（1.6m）的偏移，正数往上。 */
    var screenOffset by mutableStateOf(0f)

    /** 幕宽（米）。 */
    var screenWidth by mutableStateOf(2.4f)

    // ---- 场景 ----
    var scene by mutableStateOf(SceneKind.VOID)

    // ---- 播放列表 ----
    val playlist = mutableStateListOf<PlaylistEntry>()
    var nowPlayingId by mutableStateOf<String?>(null)
    var playlistLoading by mutableStateOf(false)

    // ---- 设置 ----
    var repeatMode by mutableStateOf(RepeatMode.ONE)

    /** 空闲自动隐藏控制面板。⛔ 隐藏 = 销毁实体，见 [VideoControlsCallbacks.onHidePanel]。 */
    var autoHide by mutableStateOf(true)
    var autoHideSeconds by mutableStateOf(12)

    /** 每次成功交互出一声。官方：「Hands have no haptics… This is not optional.」 */
    var clickSound by mutableStateOf(true)

    /** 唤出时把面板摆到当前头部朝向前方，而不是回到它原来的世界坐标。 */
    var summonInFront by mutableStateOf(true)

    // ---- 提示 ----
    /** 一行短提示（例如「EAC 片源本机放不了」），null 表示没有。 */
    var notice by mutableStateOf<String?>(null)
}

// ─────────────────────────────────────────────────────────── 动作

/** 控制面板上的全部动作。由 `:app` 侧的沉浸 Activity 实现。 */
interface VideoControlsCallbacks {

    // ---- 播放 ----
    fun onPlayPause()
    fun onSeek(value: Float)
    fun onSeekFinished()
    fun onSeekBy(seconds: Int)
    fun onCycleSpeed()

    // ---- 音量（⛔ 只影响本应用） ----
    fun onVolume(value: Float)
    fun onToggleMute()

    // ---- 片源格式 ----
    fun onPickProjection(projection: VideoProjection)
    fun onPickStereo(layout: StereoLayout)

    /** 这个片源我们放不了 —— 交给本机其它播放器。 */
    fun onHandOffToExternalPlayer()

    // ---- 幕布 ----
    fun onPickCurve(curve: ScreenCurve)
    fun onScreenDistance(meters: Float)
    fun onScreenOffset(meters: Float)
    fun onScreenWidth(meters: Float)
    fun onResetScreenGeometry()
    fun onRecenter()

    // ---- 场景 ----
    fun onPickScene(scene: SceneKind)

    // ---- 播放列表 ----
    fun onPlayEntry(id: String)
    fun onPlayAdjacent(forward: Boolean)
    fun onRefreshPlaylist()

    // ---- 设置 ----
    fun onPickRepeatMode(mode: RepeatMode)
    fun onToggleAutoHide()
    fun onAutoHideSeconds(seconds: Int)
    fun onToggleClickSound()
    fun onToggleSummonInFront()

    // ---- 面板自身 ----
    fun onRoute(route: ControlsRoute)

    /**
     * 收起控制面板。
     *
     * ⛔ 实现方**必须真的销毁面板实体**，不能只是设 `Visible(false)` 或把纹理调到
     * 0-alpha。官方原文：「It is common for app developers to create compositor layers,
     * and supply them with a **0-alpha texture rather than destroy** the compositor layer.
     * **Note that you will continue to pay the costs**」。
     */
    fun onHidePanel()

    /** 退出影院，把幕布收起、UI 面板还回来。⛔ 官方 Requirement：应用内必须自带返回。 */
    fun onBackToApp()
}
