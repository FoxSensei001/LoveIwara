package m.c.g.a.i_iwara.questui

import androidx.annotation.StringRes
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateMapOf
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
    DISTANCE,
    VIDEO_TYPE,
    SCREEN_TYPE,
    PLAYLIST,
    SETTINGS,

    /**
     * 浏览态（幕布上没有片子，眼前只有那块 2D 应用面板）唯一的一页：面板远近 + 背景不透明度。
     *
     * ⛔ 它与其它页不是兄弟关系 —— 别的页都从播放页进、按返回回播放页，而浏览态根本没有播放页
     * （见 `ImmersiveActivity.popPanelOrHide`：这一页的「返回」就是收面板）。
     */
    BROWSE,
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
enum class ScreenCurve(@StringRes val labelRes: Int, val arcDegrees: Float) {
    FLAT(R.string.xr_curve_flat, 0f),
    SLIGHT(R.string.xr_curve_slight, 40f),
    MEDIUM(R.string.xr_curve_medium, 60f),
    DEEP(R.string.xr_curve_deep, 85f),
}

// ─────────────────────────────────────────────────────────── 视频类型

/** 视频类型面板顶部的四个 tab。 */
enum class FormatTab(@StringRes val labelRes: Int) {
    FLAT(R.string.xr_tab_flat),
    PANORAMA(R.string.xr_tab_panorama),
    EAC(R.string.xr_tab_eac),
    FISHEYE(R.string.xr_tab_fisheye),
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
    @StringRes val labelRes: Int,
    val projection: Projection,
    val packing: StereoPacking,
    /** 立体片每只眼占一整幅（FSBS / FOU）。单目片无意义。 */
    val fullFrame: Boolean,
    /** 鱼眼视场角；非鱼眼为 0。 */
    val fisheyeFov: Int = 0,
) {
    // ---- 平面视频 ----
    FLAT_2D(FormatTab.FLAT, R.string.xr_format_flat_2d, Projection.FLAT, StereoPacking.MONO, false),
    FLAT_3D_HSBS(FormatTab.FLAT, R.string.xr_format_flat_3d_hsbs, Projection.FLAT, StereoPacking.LEFT_RIGHT, false),
    FLAT_3D_FSBS(FormatTab.FLAT, R.string.xr_format_flat_3d_fsbs, Projection.FLAT, StereoPacking.LEFT_RIGHT, true),
    FLAT_3D_HOU(FormatTab.FLAT, R.string.xr_format_flat_3d_hou, Projection.FLAT, StereoPacking.TOP_BOTTOM, false),
    FLAT_3D_FOU(FormatTab.FLAT, R.string.xr_format_flat_3d_fou, Projection.FLAT, StereoPacking.TOP_BOTTOM, true),

    // ---- 普通全景 ----
    PANO_180_2D(FormatTab.PANORAMA, R.string.xr_format_pano_180_2d, Projection.PANORAMA_180, StereoPacking.MONO, false),
    PANO_180_3D_LR(FormatTab.PANORAMA, R.string.xr_format_pano_180_3d_lr, Projection.PANORAMA_180, StereoPacking.LEFT_RIGHT, false),
    PANO_180_3D_TB(FormatTab.PANORAMA, R.string.xr_format_pano_180_3d_tb, Projection.PANORAMA_180, StereoPacking.TOP_BOTTOM, false),
    PANO_360_2D(FormatTab.PANORAMA, R.string.xr_format_pano_360_2d, Projection.PANORAMA_360, StereoPacking.MONO, false),
    PANO_360_3D_LR(FormatTab.PANORAMA, R.string.xr_format_pano_360_3d_lr, Projection.PANORAMA_360, StereoPacking.LEFT_RIGHT, false),
    PANO_360_3D_TB(FormatTab.PANORAMA, R.string.xr_format_pano_360_3d_tb, Projection.PANORAMA_360, StereoPacking.TOP_BOTTOM, false),

    // ---- EAC（不支持） ----
    EAC_360_2D(FormatTab.EAC, R.string.xr_format_eac_360_2d, Projection.EAC, StereoPacking.MONO, false),
    EAC_360_3D(FormatTab.EAC, R.string.xr_format_eac_360_3d, Projection.EAC, StereoPacking.TOP_BOTTOM, false),

    // ---- 鱼眼（不支持） ----
    FISHEYE_2D(FormatTab.FISHEYE, R.string.xr_format_fisheye_2d, Projection.FISHEYE, StereoPacking.MONO, false, 180),
    FISHEYE_180_3D(FormatTab.FISHEYE, R.string.xr_format_fisheye_180_3d, Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 180),
    FISHEYE_190_3D(FormatTab.FISHEYE, R.string.xr_format_fisheye_190_3d, Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 190),
    FISHEYE_200_3D(FormatTab.FISHEYE, R.string.xr_format_fisheye_200_3d, Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 200),
    FISHEYE_220_3D(FormatTab.FISHEYE, R.string.xr_format_fisheye_220_3d, Projection.FISHEYE, StereoPacking.LEFT_RIGHT, false, 220),
    ;

    /** 本机能不能正确渲染。 */
    val supported: Boolean
        get() = projection == Projection.FLAT ||
            projection == Projection.PANORAMA_180 ||
            projection == Projection.PANORAMA_360

    val isStereo: Boolean get() = packing != StereoPacking.MONO

    /** 平面片（有「屏幕类型 / 屏幕尺寸」可言）；球幕片人在球心，弯的是整个世界。 */
    val isFlat: Boolean get() = projection == Projection.FLAT

    // 走带行那枚钮上的短标签（「平面 · 3D HSBS」）要取词，所以它是
    // [shortLabel] 这个 @Composable 扩展，不在这里 —— 本文件不放 Compose 代码。

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
enum class AspectPreset(@StringRes val labelRes: Int, val ratio: Float) {
    DEFAULT(R.string.xr_aspect_default, 0f),
    R_2_1(R.string.xr_aspect_2_1, 2f),
    R_16_9(R.string.xr_aspect_16_9, 16f / 9f),
    R_4_3(R.string.xr_aspect_4_3, 4f / 3f),
    R_9_16(R.string.xr_aspect_9_16, 9f / 16f),
    R_1_1(R.string.xr_aspect_1_1, 1f),
    R_12_5(R.string.xr_aspect_12_5, 12f / 5f),
}

// ─────────────────────────────────────────────────────────── 设置

/** 一集播完之后干什么。 */
enum class RepeatMode(@StringRes val labelRes: Int) {
    /** 单集循环。**默认**。 */
    ONE(R.string.xr_repeat_one),

    /** 播完自动放播放列表里的下一条。 */
    NEXT(R.string.xr_repeat_next),

    /** 播完就停。 */
    STOP(R.string.xr_repeat_stop),
}

/** 倍速档：0.5 / 0.75 / 1.0，然后以 0.25 为步进到 3.0（4XVR 实机同款）。 */
val PLAYBACK_SPEEDS: List<Float> = listOf(0.5f, 0.75f) + (4..12).map { it * 0.25f }

/**
 * 面板上那两枚「跳一小段」钮的步长（秒）。
 *
 * 与 `:app` 侧摇杆刚推上去那一格（`ImmersiveActivity.SCRUB_TAP_MS`）同口径 ——
 * 两处都是「点一下走一小步」，用户 2026-09-08 把它从 10s 收到 5s。
 */
const val SEEK_STEP_SECONDS = 5

fun speedLabel(speed: Float): String =
    if (speed == speed.toInt().toFloat()) "${speed.toInt()}.0×" else "${speed}×"

// ─────────────────────────────────────────────────────────── 播放列表

/**
 * 「接着看」里的一条。数据来自详情页正在用的视频池，由 Dart 侧一次性推过来。
 */
data class PlaylistEntry(
    val id: String,
    val title: String,
    val author: String,
    val durationText: String,
    /** 封面地址；空串表示没有。 */
    val thumbnailUrl: String,
    /** 0..1。已看完的按满格。 */
    val progressRatio: Float,
    val watched: Boolean,
    /** 站外视频（youtube 一类的嵌入）放不了，列出来但点不动。 */
    val playable: Boolean,
    /** 本机有下载完成的文件。 */
    val downloaded: Boolean = false,
)

/**
 * 「接着看」来源目录的一个分组（= 2D 抽屉第一级：来源 / 订阅 / 我的播放列表 / 最爱 / 本地收藏 /
 * 已下载 / 稍后再看 / 作者的视频 / 作者的播放列表 / 他人的播放列表）。
 *
 * 只有一个 [choices] 的分组点了直接选那个池；多个的（播放列表 / 收藏夹 / 下载分类 / 稍后再看筛选）
 * 点了展开第二行让用户挑。选项对应的池还没开（没有同 id 的 [PlaylistSection]）时
 * 走 [VideoControlsCallbacks.onOpenQueue]。
 */
data class PlaylistGroup(
    val id: String,
    val title: String,
    /** 作者名一类的副标题；空串没有。 */
    val subtitle: String,
    /** 清单还在拉。 */
    val loading: Boolean,
    val choices: List<PlaylistChoice>,
)

/** 分组里的一个选项，对应一个池；[count] < 0 表示没有计数。 */
data class PlaylistChoice(val queueId: String, val title: String, val count: Int)

/**
 * 一档清晰度；[local] = 本机下载完成的文件。
 *
 * ⛔ [label] 是身份（`Source` / `1080`……，回传 Dart 存偏好用），**面板上要画的是 [display]** ——
 * 那是 Dart 按应用内语言算好的显示名（`Source` → 原画 / Source / …），与 2D 播放器底栏同一套。
 */
data class SourceOption(
    val label: String,
    val url: String,
    val local: Boolean,
    val display: String = label,
)

/**
 * 「接着看」的一个分区 = 详情页里的一个视频池（来源 / 播放列表 / 稍后再看 / 作者作品 …）。
 *
 * 详情页里的「接着看」抽屉就是按池分 tab 的，沉浸面板照搬同一套，用户在两边看到的是同一份东西
 * （用户 2026-09-05：「把详情页里接着看的那些信息带进去」）。
 *
 * @property queueId 池的稳定标识，选片时原样带回 Dart。
 * @property hasMore 池还有下一页。卡片流滚到末尾会请 Dart 翻一页
 *   （[VideoControlsCallbacks.onLoadMorePlaylist]），与应用里列表的无限滚动同一份数据。
 */
data class PlaylistSection(
    val queueId: String,
    val title: String,
    val entries: List<PlaylistEntry>,
    val hasMore: Boolean,
    /** 池正在拉第一页 / 翻页（Dart 的 `isLoading`，或还没装过任何一页）。空列表 + loading 画转圈而不是空态。 */
    val loading: Boolean = false,
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

    /**
     * 作者名；空串 = 不知道（本地文件 / 外部地址）。标题下面那一行小字。
     *
     * 图集页早就有「标题 + 作者」两行了，播放页却只有标题 —— 两块幕布同一个位置显示的东西
     * 不该不一样（用户 2026-09-06）。
     */
    var author by mutableStateOf("")

    /** 系统时间，例如「18:24」。由 `:app` 每分钟刷一次。 */
    var clockText by mutableStateOf("")

    /** 头显电量 0..100；-1 表示还没读到。 */
    var batteryPercent by mutableStateOf(-1)
    var batteryCharging by mutableStateOf(false)

    // ---- 播放 ----
    var isPlaying by mutableStateOf(false)
    var progress by mutableStateOf(0f)

    /**
     * 已缓冲到哪（0..1，与 [progress] 同一条轨道）。网络片子在进度条上画出「往前还能放到多少」，
     * 换片 / 卡顿时看得见缓冲区在爬（用户 2026-09-06）。本地文件恒为 1。
     */
    var buffered by mutableStateOf(0f)
    var positionText by mutableStateOf("00:00")
    var durationText by mutableStateOf("00:00")

    /** 拖动进度条时预览的时间点（例如「01:23:45」），不拖时为 null。 */
    var seekPreviewText by mutableStateOf<String?>(null)

    var speed by mutableStateOf(1.0f)

    /** 正在缓冲 / 正在换片。缓冲期间面板不自动收起，进度条上显示缓冲态。 */
    var buffering by mutableStateOf(false)

    /**
     * 正在换片（[switchingToId] 非空）：老片已暂停，播放 / 暂停、±10 秒、进度条三样**禁用**，
     * 面板整体进 Loading 态 —— 用户 2026-09-05：「避免用户看到视频仍在播放或误操作进度」。
     */
    val switching: Boolean get() = switchingToId != null

    // ---- 音量 ----

    /**
     * **系统**音量，0..1（Horizon OS 上就是 `STREAM_MUSIC`：头显物理音量键、通用菜单那根滑杆
     * 调的同一个值）。沉浸态每帧读一次系统真值写进这里，所以它永远是「系统现在多大声」，
     * 不是「用户上次把手指停在哪」。系统只有十几档，百分比会有台阶 —— 那是真相。
     */
    var volume by mutableStateOf(1f)

    /** 静音 —— ⛔ 只静**本应用**（官方媒体应用指引：system-wide mute is prohibited）。 */
    var muted by mutableStateOf(false)

    /**
     * 系统音量一共几段（档数 − 1）。Quest 3 实测 `STREAM_MUSIC` Max 15 ⇒ 这里是 15、共 16 档。
     * 音量条按它画刻度点 —— 音量本来就是跳档的，画出来比让用户以为「拖不顺」诚实。
     */
    var volumeSteps by mutableStateOf(15)

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
    var mediaEffects by mutableStateOf(MediaEffectsSettings())

    /** 观看距离（米）。 */
    var screenDistance by mutableStateOf(1.6f)

    /**
     * 那块 2D 应用面板此刻离眼睛多远（米）。只在 [ControlsRoute.BROWSE] 那一页显示，
     * 由 `:app` 在开面板与每次调距之后写回 —— 用户按一下就看得见数字在动。
     */
    var uiPanelDistance by mutableStateOf(1.8f)

    /** 幕心相对静息眼高的偏移（米），正数往上。 */
    var screenOffset by mutableStateOf(0f)

    /** 幕宽（米）。平面片为弧长 / 边长；球幕片无意义。 */
    var screenWidth by mutableStateOf(2.2f)

    // ---- 屏幕尺寸（设置页） ----
    var aspectPreset by mutableStateOf(AspectPreset.DEFAULT)

    /** 视频宽比 / 长比：在比例之上再各自乘一个系数，0.5..2.0。 */
    var widthRatio by mutableStateOf(1f)
    var heightRatio by mutableStateOf(1f)

    /**
     * 换片时把**屏幕尺寸（宽高比 / 宽比 / 长比）与倍速**沿用给下一条。
     *
     * **默认关**（用户 2026-09-05 的临时措施）：关着时每换一条片子这四项都回默认值
     * （[AspectPreset.DEFAULT] / 1× / 1× / 1.0×），跨会话也不从偏好里恢复它们。
     * 幕布的距离 / 偏移 / 幕宽与屏幕类型是「房间摆设」，不在此列，始终沿用。
     */
    var carryOverToNextVideo by mutableStateOf(false)

    /** 把受 [carryOverToNextVideo] 管的四项回默认。 */
    fun resetPerVideoSettings() {
        aspectPreset = AspectPreset.DEFAULT
        widthRatio = 1f
        heightRatio = 1f
        speed = 1f
    }

    // ---- 清晰度 ----
    val sources = mutableStateListOf<SourceOption>()

    /** 正在放的那一档的**身份**标签；空串 = 没有清单。⛔ 显示请用 [sourceDisplayLabel]。 */
    var sourceLabel by mutableStateOf("")

    /** 走带行那枚清晰度钮上要写的字：清单里找得到就用它的显示名，找不到退回身份标签。 */
    val sourceDisplayLabel: String
        get() = sources.firstOrNull { it.label == sourceLabel }?.display ?: sourceLabel

    /** 已从历史进度续播的提示文案（例如「已从 12:34 继续播放」）；null = 不显示。 */
    var resumeTipText by mutableStateOf<String?>(null)

    // ---- 播放列表 ----
    val playlistSections = mutableStateListOf<PlaylistSection>()

    /** 来源目录（分组 → 选项）。 */
    val playlistGroups = mutableStateListOf<PlaylistGroup>()

    /** 用户展开了哪个多选项分组；null = 看分组行。 */
    var expandedGroupId by mutableStateOf<String?>(null)

    /** 当前选中的分区（= 详情页的当前池）。null 时取第一个。 */
    var activeQueueId by mutableStateOf<String?>(null)
    var nowPlayingId by mutableStateOf<String?>(null)
    var playlistLoading by mutableStateOf(false)

    /** 正在向 Dart 要下一页的那个池（同一时刻只会有一个）。null = 没在翻页。 */
    var playlistLoadingMoreQueueId by mutableStateOf<String?>(null)

    /** 正在等 Dart 开出来的那个池（分组行上那枚药丸画转圈）。null = 没在开。 */
    var playlistPendingQueueId by mutableStateOf<String?>(null)

    /**
     * 点了卡片、正在后台加载的那条视频 id。老片照常放，那张卡转圈，新片就绪后整个换上来
     * （用户 2026-09-05：「卡片先 loading，准备好了再替换播放器」）。null = 没在换。
     */
    var switchingToId by mutableStateOf<String?>(null)

    /**
     * 当前分区。⛔ 选中的池还没推过来时返回 **null**，而不是退回第一个分区——
     * 否则「点了我的播放列表，卡片流却还画着稍后再看」这种状态错位就会出现（用户 2026-09-05）。
     */
    val activeSection: PlaylistSection?
        get() = when {
            activeQueueId == null -> playlistSections.firstOrNull()
            else -> playlistSections.firstOrNull { it.queueId == activeQueueId }
        }

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

    // ---- 空间画廊 ----
    /**
     * 非空 = 幕布上放的是一本**图库**而不是一条视频（见 [GalleryState]）。
     * 播放页那一路由此换成图集页；场景 / 屏幕类型 / 设置三页原样共用（它们调的是幕布几何）。
     */
    var gallery by mutableStateOf<GalleryState?>(null)
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

    // ---- 音量 ----

    /** 拖音量条：[value] 0..1，落到**系统**音量上（会被落到最近一档）。 */
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
    fun onMediaEffects(settings: MediaEffectsSettings)
    fun onScreenDistance(meters: Float)
    /** -1 = nearer, +1 = farther. Releasing or cancelling must stop immediately. */
    fun onViewDistanceHold(direction: Int, pressed: Boolean)
    fun onViewDistanceStep(direction: Int)
    fun onResetViewDistance()

    // ---- 2D 应用面板的远近（只有 [ControlsRoute.BROWSE] 那一页会调） ----

    /** -1 = 拉近，+1 = 拉远。按住连走，松开 / 取消必须立刻停。 */
    fun onUiPanelDistanceHold(direction: Int, pressed: Boolean)
    fun onUiPanelDistanceStep(direction: Int)

    /** 回默认档并摆回当前视线的正前方。 */
    fun onResetUiPanelDistance()

    fun onScreenOffset(meters: Float)
    fun onScreenWidth(meters: Float)
    fun onResetScreenGeometry()
    fun onRecenter()

    // ---- 屏幕尺寸 ----
    fun onPickAspect(preset: AspectPreset)
    fun onWidthRatio(ratio: Float)
    fun onHeightRatio(ratio: Float)
    fun onResetAspect()

    /** 「沿用到下一条视频」开关（屏幕尺寸 + 倍速）。 */
    fun onToggleCarryOver()

    // ---- 播放列表 ----

    /** 点了 [queueId] 这个池里的 [id]。Dart 会把详情页换成那条视频，并重新 present。 */
    fun onPlayEntry(queueId: String, id: String)
    fun onPickPlaylistSection(queueId: String)
    fun onPlayAdjacent(forward: Boolean)
    fun onRefreshPlaylist()

    /** 卡片流滚到了 [queueId] 这个池的末尾且它还有下一页：请 Dart 翻一页再整套推回来。 */
    fun onLoadMorePlaylist(queueId: String)

    /** 目录里选了一个还没开的池。 */
    fun onOpenQueue(queueId: String)

    /** 展开 / 收起一个多选项分组（null = 回到分组行）。 */
    fun onExpandPlaylistGroup(groupId: String?)

    // ---- 清晰度 / 续播 ----
    fun onPickSource(label: String)

    /** 「从头开始」：放弃这次历史进度。 */
    fun onRestartFromBeginning()

    fun onDismissResumeTip()

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

    /**
     * 任何一次面板上的指针事件（**含悬停移动**）都会报，只用来续「空闲自动收起」的倒计时。
     * ⛔ 别拿它判「这次操作落在面板上」—— 射线扫过就一直在报，见 [onPanelPressed]。
     */
    fun onPanelTouched()

    /**
     * 面板上**按下**了（一次按压只报一次，按住期间不重复）。
     * 这才是「这一次点击落在面板上」的证据，`:app` 的「面板外点一下显隐 toggle」只认它。
     */
    fun onPanelPressed()

    /** 收起控制面板。实现方**必须真的销毁面板实体**（0-alpha 照样付钱）。 */
    fun onHidePanel()

    /** 退出播放，把幕布收起、UI 面板还回来。⛔ 官方 Requirement：应用内必须自带返回。 */
    fun onBackToApp()

    // ---- 空间画廊（只在 [VideoControlsState.gallery] 非空时会被调到） ----

    /** 胶片上点了第 [index] 项。 */
    fun onGalleryShow(index: Int)

    /** 幻灯片开 / 关。 */
    fun onGalleryToggleSlideshow()

    /** 幻灯片间隔（秒）。 */
    fun onGallerySlideshowSeconds(seconds: Int)

    /** 图片画质：`standard` / `original`（与 2D 大图页同一份偏好）。 */
    fun onGalleryPickQuality(quality: String)

    /** 视频项：单条循环开关。 */
    fun onGalleryToggleLoop()
}

// ─────────────────────────────────────────────────────────── 空间画廊

/**
 * 图库里的一项。数据由 Dart 在 `presentGallery` 时一次性推来；文件本体不在这里 ——
 * 原生按需向 Dart 要**本地缓存路径**（[GalleryState.resolvedPath]），Dart 走自己的图片缓存
 * （带应用内代理）下载，原生只解码。
 *
 * @property thumbPath Dart 手里已有缓存的缩略图文件路径；空串 = 没有，胶片退回 [thumbUrl] 走网络。
 */
data class GalleryItem(
    val id: String,
    val isVideo: Boolean,
    // ⛔ 这里原先有个 `name`（文件名）给头部副标题用，已删：Iwara 的图片文件名是 UUID，
    // 摆在面板上就是「一堆 ID」（用户 2026-09-06）。
    val thumbUrl: String,
    val thumbPath: String,
    val width: Int,
    val height: Int,
)

/** 幻灯片间隔可选档（秒）。 */
val SLIDESHOW_SECONDS: List<Int> = listOf(3, 5, 10, 20)

/** 图片画质两档的身份字符串（与 Dart 的 `galleryImageQualityStandard/Original` 同字面）。 */
const val GALLERY_QUALITY_STANDARD = "standard"
const val GALLERY_QUALITY_ORIGINAL = "original"

/**
 * 空间画廊的面板状态：一本图库、当前停在哪一项、幻灯片、画质。
 *
 * 与 [VideoControlsState] 同一套约定：对外普通属性、内部 `mutableStateOf`。
 * 视频项的播放 / 进度 / 音量沿用 [VideoControlsState] 原有字段（幕布上放的仍是那台播放器）。
 */
class GalleryState {
    var galleryId by mutableStateOf("")
    var title by mutableStateOf("")

    /** 作者名；空串没有。 */
    var author by mutableStateOf("")

    val items = mutableStateListOf<GalleryItem>()
    var index by mutableStateOf(0)

    /** 当前项的文件还在等 Dart 下载 / 还在解码。幕布上压转圈，胶片那格也压转圈。 */
    var loading by mutableStateOf(false)

    /** 当前项解码失败的一行说明；null = 正常。 */
    var error by mutableStateOf<String?>(null)

    var slideshow by mutableStateOf(false)
    var slideshowSeconds by mutableStateOf(5)

    /** [GALLERY_QUALITY_STANDARD] / [GALLERY_QUALITY_ORIGINAL]。 */
    var quality by mutableStateOf(GALLERY_QUALITY_STANDARD)

    /** 视频项单条循环（幻灯片开着时无效：播完就翻）。 */
    var loopVideo by mutableStateOf(true)

    /**
     * id → 本地文件路径：Dart 已经交来的那些。胶片优先用它（比缩略图清晰、也不走网络）。
     * ⛔ 这是 Compose 状态 map：`:app` 往里放一条，正显示那格就会自己刷新。
     */
    val resolvedPath = mutableStateMapOf<String, String>()

    val current: GalleryItem? get() = items.getOrNull(index)
    val hasPrevious: Boolean get() = index > 0
    val hasNext: Boolean get() = index < items.size - 1
}
