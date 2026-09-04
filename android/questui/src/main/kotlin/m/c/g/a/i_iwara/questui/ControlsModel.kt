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
 *
 * # 这份契约对应的产品形态
 *
 * 照 4XVR 播放场景重做（需求见 `docs/xr-v2/vr-explore.md` §9）：
 * 一块主面板 + 五个替换式子页（场景 / 视频类型 / 屏幕类型 / 播放列表 / 设置），
 * 面板外任意位置捏合或按扳机 = 显隐 toggle。这里只定义「面板能显示什么、能做什么」，
 * 几何与播放器全在 `:app` 的沉浸 Activity 里。
 */

// ─────────────────────────────────────────────────────────── 路由

/**
 * 面板当前显示哪一页。
 *
 * ⛔ **只有一块面板**，页面是在它内部换的，不是弹出更多浮窗
 * （官方 `comfort`：「keep the main controls in a **single UI panel**」；
 * 4XVR 的子面板也是**替换**主面板显示在同一位置）。
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

/** 环境场景。只做两种：虚空（默认）与透视。 */
enum class SceneKind(val label: String) {
    /** 虚空：什么都不画的纯黑空间。**默认档**。 */
    VOID("虚空"),

    /** 透视：开 passthrough，看得见真实房间。 */
    PASSTHROUGH("透视"),
}

// ─────────────────────────────────────────────────────────── 屏幕类型

/**
 * 幕布的弯曲程度（4XVR「屏幕类型」：直面屏 / 微曲面 / 中曲面 / 重曲面）。
 *
 * 几何模型：**幕宽是弧长**（用户滑块直接给），弧度档决定包多紧，
 * 于是 `radius = 弧长 / 弧度`。
 *
 * @property arcDegrees 水平弧度；0 表示平面 Quad。
 */
enum class ScreenCurve(val label: String, val arcDegrees: Float) {
    FLAT("直面屏", 0f),
    SLIGHT("微曲面", 40f),
    MEDIUM("中曲面", 60f),
    DEEP("重曲面", 85f),
}

// ─────────────────────────────────────────────────────────── 视频类型

/** 视频类型面板顶部的四个 tab。 */
enum class FormatTab(val label: String) {
    FLAT("平面视频"),
    PANORAMA("普通全景"),
    EAC("EAC"),
    FISHEYE("鱼眼格式"),
}

/** 片源投影几何。 */
enum class Projection { FLAT, PANORAMA_180, PANORAMA_360, EAC, FISHEYE }

/** 立体编排（画面里左右眼怎么排）。 */
enum class StereoPacking { MONO, LEFT_RIGHT, TOP_BOTTOM }

/**
 * 视频类型 = 投影 × 立体编排 × 半幅/全幅。**与 4XVR 视频类型面板逐格对应**。
 *
 * 半幅（HSBS/HOU）与全幅（FSBS/FOU）的区别只在**单眼画面的宽高比**：
 * HSBS 把两眼各压进半幅，单眼比例 = 整帧比例；FSBS 两眼各占一整幅，
 * 单眼比例 = (宽/2)/高。SDK 的 `StereoMode.LeftRight` 两种都是「左半给左眼」，
 * 所以差别全在幕布几何，由 `:app` 侧按 [fullFrame] 算。
 *
 * ⛔ [EAC] 与 [FISHEYE] 两个 tab **本机渲染不了**（Spatial SDK 的面板形状只有
 * Quad / Cylinder / Equirect180 / Equirect360），照样列出来、标 `supported = false`，
 * 选中时面板如实提示并给「用其他应用打开」出口。
 */
enum class VideoFormat(
    val tab: FormatTab,
    val label: String,
    val projection: Projection,
    val packing: StereoPacking,
    /** 立体片每只眼占一整幅（FSBS / FOU）。单目片无意义。 */
    val fullFrame: Boolean,
    /** 鱼眼视场角；非鱼眼为 0。 */
    val fisheyeFov: Int = 0,
) {
    // ---- 平面视频 ----
    FLAT_2D(FormatTab.FLAT, "2D", Projection.FLAT, StereoPacking.MONO, false),
    FLAT_3D_HSBS(FormatTab.FLAT, "3D HSBS", Projection.FLAT, StereoPacking.LEFT_RIGHT, false),
    FLAT_3D_FSBS(FormatTab.FLAT, "3D FSBS", Projection.FLAT, StereoPacking.LEFT_RIGHT, true),
    FLAT_3D_HOU(FormatTab.FLAT, "3D HOU", Projection.FLAT, StereoPacking.TOP_BOTTOM, false),
    FLAT_3D_FOU(FormatTab.FLAT, "3D FOU", Projection.FLAT, StereoPacking.TOP_BOTTOM, true),

    // ---- 普通全景 ----
    PANO_180_2D(FormatTab.PANORAMA, "180 2D", Projection.PANORAMA_180, StereoPacking.MONO, false),
    PANO_180_3D_LR(FormatTab.PANORAMA, "180 3D 左右", Projection.PANORAMA_180, StereoPacking.LEFT_RIGHT, false),
    PANO_180_3D_TB(FormatTab.PANORAMA, "180 3D 上下", Projection.PANORAMA_180, StereoPacking.TOP_BOTTOM, false),
    PANO_360_2D(FormatTab.PANORAMA, "360 2D", Projection.PANORAMA_360, StereoPacking.MONO, false),
    PANO_360_3D_LR(FormatTab.PANORAMA, "360 3D 左右", Projection.PANORAMA_360, StereoPacking.LEFT_RIGHT, false),
    PANO_360_3D_TB(FormatTab.PANORAMA, "360 3D 上下", Projection.PANORAMA_360, StereoPacking.TOP_BOTTOM, false),

    // ---- EAC（不支持） ----
    EAC_360_2D(FormatTab.EAC, "360 2D", Projection.EAC, StereoPacking.MONO, false),
    EAC_360_3D(FormatTab.EAC, "360 3D", Projection.EAC, StereoPacking.TOP_BOTTOM, false),

    // ---- 鱼眼（不支持） ----
    FISHEYE_2D(FormatTab.FISHEYE, "2D", Projection.FISHEYE, StereoPacking.MONO, false, 180),
    FISHEYE_180_3D(FormatTab.FISHEYE, "180 3D", Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 180),
    FISHEYE_190_3D(FormatTab.FISHEYE, "190 3D", Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 190),
    FISHEYE_200_3D(FormatTab.FISHEYE, "200 3D", Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 200),
    FISHEYE_220_3D(FormatTab.FISHEYE, "220 3D", Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 220),
    ;

    /** 本机能不能正确渲染。 */
    val supported: Boolean
        get() = projection == Projection.FLAT ||
            projection == Projection.PANORAMA_180 ||
            projection == Projection.PANORAMA_360

    val isStereo: Boolean get() = packing != StereoPacking.MONO

    /** 平面片（有「屏幕类型 / 屏幕尺寸」可言）；球幕片人在球心，弯的是整个世界。 */
    val isFlat: Boolean get() = projection == Projection.FLAT

    /** 音量行右侧那枚钮上的短标签，例如「平面 · 3D HSBS」。 */
    val shortLabel: String
        get() = when (tab) {
            FormatTab.FLAT -> "平面 · $label"
            FormatTab.PANORAMA -> label
            FormatTab.EAC -> "EAC · $label"
            FormatTab.FISHEYE -> "鱼眼 · $label"
        }

    companion object {
        fun inTab(tab: FormatTab): List<VideoFormat> = entries.filter { it.tab == tab }
    }
}

// ─────────────────────────────────────────────────────────── 屏幕尺寸

/**
 * 4XVR 设置里的「屏幕尺寸」：强制一个宽高比，或者跟片源走（默认）。
 *
 * @property ratio 宽/高；0 表示按片源自身比例。
 */
enum class AspectPreset(val label: String, val ratio: Float) {
    DEFAULT("默认", 0f),
    R_2_1("2:1", 2f),
    R_16_9("16:9", 16f / 9f),
    R_4_3("4:3", 4f / 3f),
    R_9_16("9:16", 9f / 16f),
    R_1_1("1:1", 1f),
    R_12_5("12:5", 12f / 5f),
}

// ─────────────────────────────────────────────────────────── 设置

/** 一集播完之后干什么。 */
enum class RepeatMode(val label: String) {
    /** 单集循环。**默认**。 */
    ONE("单集循环"),

    /** 播完自动放播放列表里的下一条。 */
    NEXT("自动下一条"),

    /** 播完就停。 */
    STOP("播完停止"),
}

/** 倍速档：0.5 / 0.75 / 1.0，然后以 0.25 为步进到 3.0（4XVR 实机同款）。 */
val PLAYBACK_SPEEDS: List<Float> = listOf(0.5f, 0.75f) + (4..12).map { it * 0.25f }

fun speedLabel(speed: Float): String =
    if (speed == speed.toInt().toFloat()) "${speed.toInt()}.0×" else "${speed}×"

// ─────────────────────────────────────────────────────────── 播放列表

/**
 * 播放列表里的一条。数据来自应用已有的「稍后再看」，由 Dart 侧一次性推过来。
 * 只有文字没有缩略图（缩略图要往 `:questui` 引图片加载库，另一条线）。
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
 * 所以 `:app` 模块可以直接 `state.isPlaying = true` 地写它。
 */
class VideoControlsState {

    // ---- 路由 ----
    var route by mutableStateOf(ControlsRoute.PLAYER)

    // ---- 顶行：视频信息 + 系统信息 ----
    var title by mutableStateOf("")

    /** 系统时间，例如「18:24」。由 `:app` 每分钟刷一次。 */
    var clockText by mutableStateOf("")

    /** 头显电量 0..100；-1 表示还没读到。 */
    var batteryPercent by mutableStateOf(-1)
    var batteryCharging by mutableStateOf(false)

    // ---- 播放 ----
    var isPlaying by mutableStateOf(false)
    var progress by mutableStateOf(0f)
    var positionText by mutableStateOf("00:00")
    var durationText by mutableStateOf("00:00")

    /** 拖动进度条时预览的时间点（例如「01:23:45」），不拖时为 null。 */
    var seekPreviewText by mutableStateOf<String?>(null)

    var speed by mutableStateOf(1.0f)

    /** 正在缓冲 / 正在换片。缓冲期间面板不自动收起，进度条上显示缓冲态。 */
    var buffering by mutableStateOf(false)

    // ---- 音量（⛔ 只调应用音量，官方 Requirement） ----
    var volume by mutableStateOf(1f)
    var muted by mutableStateOf(false)

    /** 音量竖向滑杆是否弹出（点 🔊 打开，在别处点关闭）。 */
    var volumePopupOpen by mutableStateOf(false)

    // ---- 视频类型 ----
    var format by mutableStateOf(VideoFormat.FLAT_2D)

    /** 视频类型面板当前停在哪个 tab。切片时同步到 [format] 所在 tab。 */
    var formatTab by mutableStateOf(FormatTab.FLAT)

    /** 「自动识别时，180 全景当作 180 鱼眼」。本机放不了鱼眼，只作提示位。 */
    var treat180AsFisheye by mutableStateOf(false)

    // ---- 屏幕类型 ----
    var curve by mutableStateOf(ScreenCurve.SLIGHT)

    /** 「强制以 2D 方式显示 3D 视频」。 */
    var forceMono by mutableStateOf(false)

    // ---- 场景 ----
    var scene by mutableStateOf(SceneKind.VOID)

    /** 观看距离（米）。 */
    var screenDistance by mutableStateOf(2.5f)

    /** 幕心相对静息眼高的偏移（米），正数往上。 */
    var screenOffset by mutableStateOf(0f)

    /** 幕宽（米）。平面片为弧长 / 边长；球幕片无意义。 */
    var screenWidth by mutableStateOf(2.4f)

    // ---- 屏幕尺寸（设置页） ----
    var aspectPreset by mutableStateOf(AspectPreset.DEFAULT)

    /** 视频宽比 / 长比：在比例之上再各自乘一个系数，0.5..2.0。 */
    var widthRatio by mutableStateOf(1f)
    var heightRatio by mutableStateOf(1f)

    // ---- 播放列表 ----
    val playlist = mutableStateListOf<PlaylistEntry>()
    var nowPlayingId by mutableStateOf<String?>(null)
    var playlistLoading by mutableStateOf(false)

    // ---- 设置 ----
    var repeatMode by mutableStateOf(RepeatMode.ONE)

    /** 空闲自动隐藏控制面板。隐藏 = 销毁实体。 */
    var autoHide by mutableStateOf(true)
    var autoHideSeconds by mutableStateOf(12)

    /** 每次成功交互出一声。官方：「Hands have no haptics… This is not optional.」 */
    var clickSound by mutableStateOf(true)

    /** 唤出时把面板摆到当前头部朝向前方，而不是回到它原来的世界坐标。 */
    var summonInFront by mutableStateOf(true)

    /** 手柄 A/X 单击 = 播放/暂停（4XVR 同名开关）。 */
    var controllerTapPlayPause by mutableStateOf(true)

    /** 系统菜单弹出 / 摘下头显时自动暂停。 */
    var pauseOnFocusLoss by mutableStateOf(true)

    // ---- 提示 ----
    /** 一行短提示（例如「EAC 片源本机放不了」），null 表示没有。 */
    var notice by mutableStateOf<String?>(null)
}

// ─────────────────────────────────────────────────────────── 动作

/** 控制面板上的全部动作。由 `:app` 侧的沉浸 Activity 实现。 */
interface VideoControlsCallbacks {

    // ---- 播放 ----
    fun onPlayPause()

    /** 拖动进度条中，每帧都会来。[value] 0..1。 */
    fun onSeek(value: Float)
    fun onSeekFinished()
    fun onSeekBy(seconds: Int)
    fun onPickSpeed(speed: Float)

    // ---- 音量（⛔ 只影响本应用） ----
    fun onVolume(value: Float)
    fun onToggleMute()
    fun onVolumePopup(open: Boolean)

    // ---- 视频类型 ----
    fun onPickFormat(format: VideoFormat)
    fun onPickFormatTab(tab: FormatTab)
    fun onAutoDetectFormat()
    fun onToggleTreat180AsFisheye()

    /** 这个片源我们放不了 —— 交给本机其它播放器。 */
    fun onHandOffToExternalPlayer()

    // ---- 屏幕类型 ----
    fun onPickCurve(curve: ScreenCurve)
    fun onToggleForceMono()

    // ---- 场景 ----
    fun onPickScene(scene: SceneKind)
    fun onScreenDistance(meters: Float)
    fun onScreenOffset(meters: Float)
    fun onScreenWidth(meters: Float)
    fun onResetScreenGeometry()
    fun onRecenter()

    // ---- 屏幕尺寸 ----
    fun onPickAspect(preset: AspectPreset)
    fun onWidthRatio(ratio: Float)
    fun onHeightRatio(ratio: Float)
    fun onResetAspect()

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
    fun onToggleControllerTapPlayPause()
    fun onTogglePauseOnFocusLoss()

    // ---- 面板自身 ----
    fun onRoute(route: ControlsRoute)

    /** 任何一次面板上的触碰（含拖动）都要报一次，用来续空闲计时与判定「捏合发生在面板上」。 */
    fun onPanelTouched()

    /** 收起控制面板。实现方**必须真的销毁面板实体**（0-alpha 照样付钱）。 */
    fun onHidePanel()

    /** 退出播放，把幕布收起、UI 面板还回来。⛔ 官方 Requirement：应用内必须自带返回。 */
    fun onBackToApp()
}
