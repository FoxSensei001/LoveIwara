package m.c.g.a.i_iwara.vr

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Debug
import android.os.SystemClock
import android.util.Log
import androidx.annotation.StringRes
import android.view.Surface
import com.meta.spatial.compose.ComposeFeature
import com.meta.spatial.compose.ComposeViewPanelRegistration
import com.meta.spatial.core.Entity
import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.SpatialFeature
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import com.meta.spatial.isdk.IsdkCurvedPanel
import com.meta.spatial.isdk.IsdkFeature
import com.meta.spatial.isdk.IsdkPanelDimensions
import com.meta.spatial.runtime.HitInfo
import com.meta.spatial.runtime.InputListener
import com.meta.spatial.runtime.PanelSceneObject
import com.meta.spatial.runtime.PanelShapeLayerBlendType
import com.meta.spatial.runtime.ReferenceSpace
import com.meta.spatial.runtime.SceneObject
import com.meta.spatial.toolkit.ActivityPanelRegistration
import com.meta.spatial.toolkit.AppSystemActivity
import com.meta.spatial.toolkit.CylinderShapeOptions
import com.meta.spatial.toolkit.DpDisplayOptions
import com.meta.spatial.toolkit.DpPerMeterDisplayOptions
import com.meta.spatial.toolkit.Hittable
import com.meta.spatial.toolkit.MeshCollision
import com.meta.spatial.toolkit.MediaPanelRenderOptions
import com.meta.spatial.toolkit.MediaPanelSettings
import com.meta.spatial.toolkit.Panel
import com.meta.spatial.toolkit.PanelRegistration
import com.meta.spatial.toolkit.PanelRenderMode
import com.meta.spatial.toolkit.PixelDisplayOptions
import com.meta.spatial.toolkit.PanelStyleOptions
import com.meta.spatial.toolkit.QuadShapeOptions
import com.meta.spatial.toolkit.Scale
import com.meta.spatial.toolkit.SceneObjectSystem
import com.meta.spatial.toolkit.Transform
import com.meta.spatial.toolkit.UIPanelRenderOptions
import com.meta.spatial.toolkit.UIPanelSettings
import com.meta.spatial.toolkit.UIPanelShapeOptions
import com.meta.spatial.toolkit.VideoSurfacePanelRegistration
import com.meta.spatial.toolkit.Visible
import com.meta.spatial.vr.LocomotionSystem
import com.meta.spatial.vr.VRFeature
import m.c.g.a.i_iwara.MainActivity
import m.c.g.a.i_iwara.R
import m.c.g.a.i_iwara.questui.AspectPreset
import m.c.g.a.i_iwara.questui.BUFFERING_ANIM_MS
import m.c.g.a.i_iwara.questui.BufferingState
import m.c.g.a.i_iwara.questui.ControlsRoute
import m.c.g.a.i_iwara.questui.FormatTab
import m.c.g.a.i_iwara.questui.GALLERY_QUALITY_STANDARD
import m.c.g.a.i_iwara.questui.GalleryItem
import m.c.g.a.i_iwara.questui.GalleryStageState
import m.c.g.a.i_iwara.questui.GalleryState
import m.c.g.a.i_iwara.questui.MediaEffectsSettings
import m.c.g.a.i_iwara.questui.PLAYBACK_SPEEDS
import m.c.g.a.i_iwara.questui.PanelLocale
import m.c.g.a.i_iwara.questui.PlaylistChoice
import m.c.g.a.i_iwara.questui.PlaylistEntry
import m.c.g.a.i_iwara.questui.PlaylistGroup
import m.c.g.a.i_iwara.questui.PlaylistSection
import m.c.g.a.i_iwara.questui.SourceOption
import m.c.g.a.i_iwara.questui.RepeatMode
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoFormat
import m.c.g.a.i_iwara.questui.createBufferingView
import m.c.g.a.i_iwara.questui.createGalleryStageView
import m.c.g.a.i_iwara.questui.createVideoControlsView
import m.c.g.a.i_iwara.questui.createWindowFrameView
import m.c.g.a.i_iwara.questui.R as UiR
import m.c.g.a.i_iwara.xr.ImmersiveBridge
import m.c.g.a.i_iwara.xr.ImmersiveGalleryItem
import m.c.g.a.i_iwara.xr.ImmersiveGalleryRequest
import m.c.g.a.i_iwara.xr.ImmersivePlaylistGroup
import m.c.g.a.i_iwara.xr.ImmersivePlaylistItem
import m.c.g.a.i_iwara.xr.ImmersivePlaylistSection
import m.c.g.a.i_iwara.xr.ImmersiveSourceOption
import m.c.g.a.i_iwara.xr.ImmersiveVideoRequest
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sqrt
import kotlin.math.tan

/**
 * Quest 沉浸式 Activity。**只存在于 quest 变体**，standard 包既不编译它、
 * 也不链接任何 Spatial SDK 的 `.aar`（硬约束：不把 48MB SDK 打进普通包、minSdk 不抬）。
 *
 * # 形态
 *
 * 应用常驻在这块自建的沉浸空间里：
 *
 * | 实体 | 是什么 | 生灭 |
 * |---|---|---|
 * | UI 面板 | 整个 Flutter 应用（`ActivityPanelRegistration` 挂 [MainActivity]） | 常在；看视频时藏起并停止出帧 |
 * | 幕布 | `VideoSurfacePanelRegistration` + ExoPlayer；平面走 Quad/Cylinder，VR 片走 Equirect | 有片源才建 |
 * | 控制面板 | 原生 Compose（`:questui` 模块），照 4XVR 重做 | 空闲即销毁，面板外「点一下」toggle |
 * | 缓冲指示 | 一块透明小面板，浮在幕布正中 | 只在缓冲期间存在 |
 * | 空间画廊 | 整本图库：幕布这块「窗」换成 Compose + Coil 的图片面板（`vr_image_panel`），视频项仍走 ExoPlayer 幕布，图 ↔ 视频切换时两块互换；面板主页换成图集页 | Dart `presentGallery` 起、回应用止；见「空间画廊」一节 |
 *
 * # 摆位相对进入时的视线，随后固定在空间中
 *
 * 此前按地面绝对高度摆（眼高 1.6m 的站姿假设），坐着/躺着都不对：面板偏上、竖得笔直。
 * 现在的规则：
 * - **锚点** [anchor]：等待有效头部追踪后捕获，保留俯仰与偏航、消除侧倾；接近垂直时平滑沿用头部 up。
 *   首次进入、系统 recenter 和「重新居中」重新捕获，浏览面板的旧位置不参与计算。
 * - 平幕中心在锚点视线下方 8°；操作栏放在更近、更低的位置，两者都朝向观看者。
 * - 抓住的第一帧不跳角，实际挪动时逐渐朝向人；重定位取消旧会话。几何规则见 [SpatialPlacement]。
 *
 * # 层序不靠深度
 *
 * 合成层的前后不是按曲面位置排的（中曲面把面板整个盖住、拉近幕布也会盖住 —— 真机反馈），
 * 所以三块层显式给 zIndex：球幕 −1 / 幕布 0 / 控制面板 20 / 缓冲指示 30。
 * 由此**不再**把面板往前拉去躲幕布（那正是「面板上移、变大」的原因）。
 *
 * # 「点一下」与「抓着拖」分家
 *
 * 捏合按下不再立即裁决：按下时记下手的位置，**松开**时若时间短、位移小、且不在面板上，
 * 才算「点一下」= 面板显隐 toggle；按在窗框上的捏合 / 扳机是抓窗（见下），不会到达 toggle。
 *
 * # 三块窗的抓、挪、缩放不走 ISDK
 *
 * ISDK 的面板抓取只认边缘抓条，光标在窗体上时抓握扳机没反应；四角缩放的外观也改不了。
 * 2026-09-05 起三块窗（2D 应用 / 控制面板 / 幕布）都摘掉 `Grabbable` / `IsdkPanelResize`，
 * 各自贴一块自绘窗框，抓握扳机按在窗体上就能拖 —— 全在 [WindowManipulator]，本类只提供三个
 * [WindowHost]（位姿怎么读、尺寸怎么落地）。
 *
 * # ⛔ 三条铁律
 *
 * 1. 控制面板**隐藏 = 真销毁**（0-alpha 照样付钱）；但先隐身、隔两帧再销毁，让 ISDK 清掉悬停态
 *    （否则光标会被一块不存在的面板挡住 —— 真机反馈）。
 * 2. 换形状**播放器不死**：能 `reshape()` 的连实体都不重建；过渡逐帧插值。
 * 3. 清理放 `onSpatialShutdown()`，**永远不 `finish()`** 挂着面板的 Activity。
 *
 * # adb 验证入口
 *
 * ```
 * adb shell am start -n <pkg>/m.c.g.a.i_iwara.vr.ImmersiveActivity \
 *   --es url "https://..." --es shape 180 --es stereo lr --ei w 4096 --ei h 2048
 * ```
 * `shape`: flat | 180 | 360   `stereo`: none | lr | tb   `--ez fullFrame`   `--ef background 0..1`
 * `--es curve flat|slight|medium|deep`。不带 url 的任何 intent（含主页点图标）一律回浏览态。
 */
class ImmersiveActivity : AppSystemActivity(), PlaybackEngine.Listener {

    private val controls = VideoControlsState()
    private lateinit var playback: PlaybackEngine
    private lateinit var prefs: PlayerPrefs
    private lateinit var status: SystemStatus
    private lateinit var input: SpatialInputPoller
    private lateinit var manipulator: WindowManipulator

    // ---------------------------------------------------------------- 实体

    private var screenEntity: Entity? = null
    private var screenPanel: PanelSceneObject? = null
    private val mediaEffects by lazy { MediaEffectsRenderer(scene, assets) }
    private var mediaEffectsFailed = false
    private var screenUsesEffectMesh = false
    private var screenUsesProcessedVideo = false
    private var processedVideoWidth = 1920
    private var processedVideoHeight = 1080

    private fun targetVideoWidth() = videoWidth.takeIf { it > 0 } ?: 1920
    private fun targetVideoHeight() = videoHeight.takeIf { it > 0 } ?: 1080

    private fun wantsEffectMesh(): Boolean = !mediaEffectsFailed &&
        MediaEffectsRenderer.usesTextureEffects(controls.mediaEffects, controls.format)

    /** 当前幕布实体是平幕（quad / cylinder）还是球幕。 */
    private var screenEntityIsFlat = true
    private var uiPanelEntity: Entity? = null
    private var uiPanel: PanelSceneObject? = null

    /** UI 面板此刻是露着的（不是停在脚下）；窗框只在它露面时跟着出现。 */
    private val uiPlacement = UiPanelPlacement()
    private var uiSurfacePose = PARKED_POSE

    /** UI 面板创建那一刻的基准尺寸（米），拉角只改相对它的 [uiScale]。 */
    private var uiBaseSize = Vector2(PlayerPrefs.DEFAULT_UI_PANEL_WIDTH_M, PlayerPrefs.DEFAULT_UI_PANEL_WIDTH_M * PlayerPrefs.UI_PANEL_ASPECT_H_OVER_W)
    private var uiScale = Vector2(1f, 1f)
    private var controlsEntity: Entity? = null
    private var controlsPanel: PanelSceneObject? = null

    /** 控制面板相对基准尺寸（1.2m 宽）的等比缩放；进偏好。 */
    private var controlsScale = 1f
    private var bufferingEntity: Entity? = null
    private var bufferingPanel: PanelSceneObject? = null
    private val bufferingState = BufferingState()

    /** 缓冲从什么时候开始的（uptime ms）；0 = 没在缓冲。超过 [BUFFERING_SHOW_DELAY_MS] 才露面，短抖不闪。 */
    private var bufferingSince = 0L

    /** 缓冲指示已隐身、等退场动画播完再销毁的时刻；0 = 没在等。 */
    private var bufferingDestroyAt = 0L

    /** 球幕时缓冲指示的位置在创建那一刻定死（跟着视线走会一直跳）。 */
    private var bufferingFrozenPose: Pose? = null

    /** 「接着看」向 Dart 要东西的超时时刻；0 = 没在等。到点就把在途态收掉。 */
    private var playlistWaitUntil = 0L

    /** 换片在途（点卡片 → Dart 换页 → 新片 present → 预加载就绪）的超时时刻；0 = 没在换。 */
    private var switchWaitUntil = 0L

    /**
     * 换片开始时老片在放、是我们把它暂停的。换片失败（预加载出错 / 超时）要把它放回去；
     * 成功时老播放器已释放，不用管。用户 2026-09-05：加载下一条期间「暂停当前视频播放」。
     */
    private var pausedForSwitch = false

    /** 等 Dart 送新地址（直链过期恢复）的超时时刻；0 = 没在等。 */
    private var sourceRefreshUntil = 0L

    /** 这条片子已经向 Dart 要过一次新地址：过期恢复只试一次，再错就如实报错。换片 / 换档时清。 */
    private var sourceRefreshRequested = false

    // ---- 摇杆拖动进度（按住越久越快，松开才 seek） ----

    /** 正在用摇杆左右拖进度。期间 [seeking] 为 true，进度条 / 面板预览 / 幕布上的叠层都显示目标点。 */
    private var scrubbing = false

    /** 当前推的方向（+1 右 / −1 左 / 0 还没推）；换方向从头加速。 */
    private var scrubDir = 0
    private var scrubDirSince = 0L
    private var scrubLastAt = 0L

    /** 开始拖时的位置与此刻的目标位置（ms）。 */
    private var scrubBaseMs = 0L
    private var scrubTargetMs = 0L

    /** 已隐身、等着销毁的控制面板实体（见 [hideControls]）。 */
    private var controlsDoomed: Entity? = null
    private var controlsDoomedTicks = 0

    // ---------------------------------------------------------------- 片源

    private var argUrl: String? = null
    private var videoId: String = ""
    private var videoWidth: Int = 1920
    private var videoHeight: Int = 1080
    private var pendingStartMs = 0L

    /** 仅供真机测量用：`--ez mute true` 静音起播（Quest 不接受 adb 改音量）。 */
    private var argMute: Boolean = false

    /** 把 Flutter 的 [MainActivity] 作为一块面板挂进本沉浸空间。默认开；`--ez uiPanel false` 只用于隔离排查。 */
    private var argUiPanel: Boolean = true

    // ---------------------------------------------------------------- 摆位

    /** 幕布的锚点：一帧去掉 roll 的头部位姿。null = 还没捕获过。 */
    private var anchor: Pose? = null
    private val headReadiness = HeadPoseReadiness()
    private var screenShown = false
    private var pendingShowControls = false
    private var inputSuspended = false
    private var viewDistanceDirection = 0

    /** 「面板远近」按住不放的方向（-1 拉近 / +1 拉远 / 0 没按着），只在浏览态那一页有效。 */
    private var uiPanelHoldDirection = 0

    /** 上一帧的时刻（算这一帧走多久）与这一按开始时的距离（松手记一笔用）。 */
    private var uiPanelHoldLastAt = 0L
    private var uiPanelHoldFrom = 0f
    private var lastMotionAt = 0L

    /**
     * 幕布**可见面中心**现在实际在哪（用户抓着挪过 / 拉过角）。重建后原位放回；距离/偏移滑块与重置会清掉它。
     *
     * ⛔ 记的是弧面中心而不是实体位姿：弧幕实体锚点在圆柱轴心（事实 2），半径随宽度 / 弧度变，
     * 记实体位姿的话一 reshape 就得清掉 —— 弧幕拖过之后换个曲面就弹回去。轴心由 [surfaceToEntityPose] 按当下半径算。
     */
    private var screenSurfaceOverride: Pose? = null

    /** 控制面板收起前在哪。唤出时优先放回原处。 */
    private var lastControlsPose: Pose? = null

    /**
     * 控制面板「本来该在」的位姿（唤出落点 / 用户拖到的地方）。实际摆的位置可能比它更近：
     * 幕布被拉到比面板还近时，面板要挪到幕布前面（见 [syncControlsDepth]）。
     */
    private var controlsBasePose: Pose? = null

    // ---- 球幕（180 / 360）的推远拉近与拖视角 ----

    /** 球心相对锚点沿球幕前向的偏移（米）：正 = 推远（正前方画面变远变小），负 = 拉近。锚点重捕获时清零。 */
    private var sphereOffsetM = 0f

    /** 用户抓着拖过视角之后球幕的前向（世界坐标）；null = 按锚点视线。锚点重捕获时清。 */
    private var sphereForwardOverride: Vector3? = null

    /** 正抓着拖球幕视角的那只手（−1 = 没在拖）与起始时的射线方向 / 球幕前向。 */
    private var sphereGrabHand = -1
    private var sphereGrabRay0 = Vector3(0f, 0f, -1f)
    private var sphereGrabForward0 = Vector3(0f, 0f, -1f)

    // ---------------------------------------------------------------- 形状过渡

    /** 当前实际生效的形状参数（过渡中是插值值）。 */
    private var curArc = 0f
    private var curWidth = 0f
    private var curAspect = 16f / 9f
    private var animFromArc = 0f
    private var animFromWidth = 0f
    private var animFromAspect = 0f
    private var animStartAt = 0L
    private var animDurationMs = 0L
    private var animating = false

    // ---------------------------------------------------------------- 交互态

    private var seeking = false
    private var lastInteractionAt = 0L

    /** 射线 / 手指此刻是否悬在控制面板上（由面板 SceneObject 的 InputListener 维护）。 */
    @Volatile
    private var controlsHovered = false

    /** 面板上最近一次触碰的时刻（Compose 侧上报 + SceneObject onClickDown）。 */
    @Volatile
    private var lastPanelTouchAt = 0L

    /** 正在进行中的「选择」：按下时刻与那只手的位置，松开时裁决是点还是拖。 */
    private val tapDownAt = LongArray(2)
    private val tapDownPos = arrayOfNulls<Vector3>(2)
    private val tapCandidate = BooleanArray(2)

    private var prefsDirty = false
    private var prefsFlushAt = 0L

    /** 被系统事件（系统菜单 / 摘下头显）暂停的，回来要续播。 */
    private var pausedBySystem = false

    private var playlistSections: List<ImmersivePlaylistSection> = emptyList()
    private var nowPlayingId: String? = null

    // ---- 空间画廊 ----

    /** 非空 = 幕布上放的是一本图库（面板主页随之换成图集页）。 */
    private var gallery: GalleryState? = null
    private var galleryItems: List<ImmersiveGalleryItem> = emptyList()

    /** 图片面板的内容状态（`vr_image_panel` 读它）。 */
    private val stage = GalleryStageState()

    /** 当前幕布实体是图片面板（`vr_image_panel`）还是视频幕布（`vr_video_panel`）。 */
    private var screenIsImage = false

    /**
     * 正在向 Dart 要本地文件的项 id（单飞）→ 起算时刻。
     *
     * ⛔ 带时刻而不是纯集合：`MethodChannel` 的回调**有可能不回来**（面板里的 Flutter 引擎重建、
     * 通道换了实例），而这个集合只在回调里摘除 —— 丢一次回调那一项就被**永久毒住**，
     * 之后再也发不出请求，用户看到的是「中间一直转圈，怎么点都没反应」，且没有任何出路。
     * 过了 [GALLERY_FILE_TIMEOUT_MS] 允许重发一次。
     */
    private val galleryResolving = HashMap<String, Long>()

    /** 幻灯片下一次翻页的时刻；0 = 还没起算（当前项还在读取 / 刚翻过）。 */
    private var slideshowNextAt = 0L

    /** 摇杆左右当前压着的方向（-1 / 0 / 1）与下一次连翻的时刻。 */
    private var galleryStepHeld = 0
    private var galleryStepNextAt = 0L

    /** 两手抓取缩放（双抓握扳机 / 双捏合按住）：起点手距与起点幕宽。 */
    private var twoHandScaling = false
    private var twoHandDist0 = 0f
    private var twoHandWidth0 = 0f
    private var twoHandBySelect = false

    /** 指针正按在图片幕布上：摇杆上下 = 缩放内容（不是推远拉近）。 */
    private var stagePressed = false

    /**
     * **视频**幕布上的横拖翻片：正在拖的那只手（-1 = 没有）、起点与上一帧的面内横坐标（米）、速度。
     *
     * ⛔ 只在视频幕布上跑。图片幕布是 Compose 面板、自己收得到指针事件（`GalleryStageView`），
     * 两条路一起跑就是一次拖动翻两张。判定与浮窗两边共用 `StageSwipeState`，这里只负责
     * 「把射线的位移换算成幕宽比例」。
     */
    private var stageSwipeHand = -1
    private var stageSwipeStartX = 0f
    private var stageSwipeLastX = 0f
    private var stageSwipeLastAt = 0L
    private var stageSwipeVelocity = 0f
    private var stageSwipeDragging = false

    private val inGallery: Boolean get() = gallery != null

    /** 幕布上有东西（视频或图库）。⛔ 判「有没有片源」一律用它，别再只看 argUrl：图片项没有 url。 */
    private val stageActive: Boolean get() = !argUrl.isNullOrBlank() || inGallery

    /** 续播提示什么时候自动收掉（uptime ms）；0 = 没在显示。 */
    private var resumeTipUntil = 0L

    private val activeSection: ImmersivePlaylistSection?
        get() = playlistSections.firstOrNull { it.queueId == controls.activeQueueId } ?: playlistSections.firstOrNull()

    // ================================================================ 生命周期

    override fun registerFeatures(): List<SpatialFeature> = listOf(
        VRFeature(this),
        IsdkFeature(this, spatial, systemManager),
        ComposeFeature(),
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "IMMERSIVE onCreate pid=${android.os.Process.myPid()}")
        logMemory("onCreate")
        playback = PlaybackEngine(this).also { it.listener = this }
        prefs = PlayerPrefs(this).also { it.load(controls) }
        status = SystemStatus(this).also {
            it.onChanged = {
                controls.batteryPercent = it.batteryPercent
                controls.batteryCharging = it.batteryCharging
            }
            it.start()
        }
        input = SpatialInputPoller(systemManager)
        controlsScale = prefs.controlsScale
        stage.onLoaded = { id, w, h -> runOnUiThread { onGalleryImageLoaded(id, w, h) } }
        stage.onFailed = { id, msg -> runOnUiThread { onGalleryImageFailed(id, msg) } }
        // 幕布上 1× 横拖 = 攒翻页幅度（画面不动，只在幕布上浮预示），松手过阈值才真翻页。
        stage.onSwipe = { forward -> runOnUiThread { touched(); galleryStep(forward) } }
        // 图片幕布上到头那句话说「张」（视频幕布用默认的「条」，见 StageSwipeState）。
        stage.swipe.noPreviousRes = UiR.string.xr_swipe_no_previous_image
        stage.swipe.noNextRes = UiR.string.xr_swipe_no_next_image
        stage.onPressChanged = { pressed, _, _ -> runOnUiThread { stagePressed = pressed } }
        // 幕布上捏合 / 双击缩放算一次交互（面板的空闲倒计时要续上）。
        // ⛔ 缩放倍数**不再镜像进面板**：面板上那组 −/%/+ 已按用户要求整组移除（2026-09-06）。
        stage.onZoomChanged = { _ -> runOnUiThread { lastInteractionAt = SystemClock.uptimeMillis() } }
        manipulator = WindowManipulator(
            systemManager,
            frameIds = mapOf(
                WindowKind.UI to R.id.vr_frame_ui_panel,
                WindowKind.CONTROLS to R.id.vr_frame_controls_panel,
                WindowKind.SCREEN to R.id.vr_frame_screen_panel,
            ),
            basisPose = { origin, forward ->
                frameAlong(origin, forward, trackedHeadPose()?.up() ?: Vector3(0f, 1f, 0f), dropDeg = 0f)
            },
            faceViewer = { position ->
                val head = trackedHeadPose()
                val dir = head?.let { position - it.t }
                if (head == null || dir == null || dir.length() < 0.2f) null
                else SpatialPlacement.facingSurface(Pose(position), head).q
            },
        )
        readIntent(intent)
    }

    override fun onNewIntent(newIntent: Intent) {
        super.onNewIntent(newIntent)
        val before = argUrl
        readIntent(newIntent)
        rebuildScreen(keepPlayback = argUrl != null && argUrl == before)
    }

    private fun readIntent(source: Intent?) {
        source ?: return
        // 片源只来自两处：adb 的 `--es url`（验证用）与 Dart 的 present（正式路径，不走 intent）。
        // 任何不带 url 的 intent 一律回浏览态 —— 主页点图标、系统拉起都不该把上一次的片子留在场景里。
        val urlExtra = source.getStringExtra("url")
        val nextUrl = urlExtra?.takeIf { it.isNotBlank() }
        if (argUrl != null && nextUrl != argUrl) notifyEnded()
        argUrl = nextUrl
        if (urlExtra != null) {
            controls.format = ScreenGeometry.formatOf(
                source.getStringExtra("shape") ?: "flat",
                source.getStringExtra("stereo") ?: "none",
                source.getBooleanExtra("fullFrame", false),
            )
            controls.formatTab = controls.format.tab
            videoWidth = source.getIntExtra("w", videoWidth)
            videoHeight = source.getIntExtra("h", videoHeight)
            controls.title = source.getStringExtra("title") ?: ""
            controls.author = source.getStringExtra("author") ?: ""
            videoId = source.getStringExtra("videoId") ?: ""
        }
        argMute = source.getBooleanExtra("mute", argMute)
        // 背景不透明度（0 = 纯黑虚空、1 = 真实房间）。排查用的直投口子，正常入口是场景页那条滑块。
        if (source.hasExtra("background")) {
            controls.mediaEffects = controls.mediaEffects
                .copy(backgroundTransparency = source.getFloatExtra("background", 1f))
                .normalized()
            applyScene()
        }
        source.getStringExtra("curve")?.let { name ->
            ScreenCurve.entries.firstOrNull { it.name.equals(name, ignoreCase = true) }?.let { controls.curve = it }
        }
        argUiPanel = source.getBooleanExtra("uiPanel", argUiPanel)
        Log.i(
            TAG,
            "IMMERSIVE args format=${controls.format} curve=${controls.curve} mute=$argMute uiPanel=$argUiPanel " +
                "dims=${videoWidth}x$videoHeight url=${argUrl?.take(120)}",
        )
    }

    override fun onSceneReady() {
        super.onSceneReady()
        scene.setReferenceSpace(ReferenceSpace.LOCAL_FLOOR)
        scene.setLightingEnvironment(
            ambientColor = Vector3(1.0f, 1.0f, 1.0f),
            sunColor = Vector3(0f, 0f, 0f),
            sunDirection = -Vector3(1.0f, 3.0f, 2.0f),
        )
        applyScene(immediate = true)
        // ⛔ 关掉 VRFeature 自带的 LocomotionSystem：它把摇杆前后当传送（射出抛物线）、左右当转向，
        // 只有光标悬在面板上时才让路 —— 用户 2026-09-05：「摇杆推完松手视角变了 / 手柄射出一道抛物线」。
        // 摇杆在本应用里全归自己（拖进度 / 推远拉近），视角由头部与球幕拖视角管，不需要任何移动交互。
        runCatching { systemManager.findSystem<LocomotionSystem>().enableLocomotion(false) }
            .onSuccess { Log.i(TAG, "IMMERSIVE locomotion disabled") }
            .onFailure { Log.w(TAG, "IMMERSIVE 关闭 LocomotionSystem 失败", it) }
        Log.i(TAG, "IMMERSIVE onSceneReady")
        logMemory("onSceneReady")
        manipulator.onSceneReady()
        rebuildScreen()
        ImmersiveBridge.attachScene(bridgeListener)
    }

    // ---- 系统事件（需求 §9.8：焦点丢失 / 摘下头显 / 重定向） ----

    override fun onVRPause() {
        super.onVRPause()
        Log.i(TAG, "IMMERSIVE onVRPause")
        pauseForSystem()
    }

    override fun onVRReady() {
        super.onVRReady()
        Log.i(TAG, "IMMERSIVE onVRReady")
        resumeAfterSystem()
    }

    override fun onHMDUnmounted() {
        super.onHMDUnmounted()
        Log.i(TAG, "IMMERSIVE onHMDUnmounted")
        pauseForSystem()
    }

    override fun onHMDMounted() {
        super.onHMDMounted()
        Log.i(TAG, "IMMERSIVE onHMDMounted")
        resumeAfterSystem()
    }

    /**
     * 系统重定向（长按 Meta 键 / 手掌朝向自己捏合）。视图原点变了，所有世界锚定的东西按新视线重摆：
     * 幕布沿新的视线方向、控制面板到面前。躺着重定向时视线朝上，面板就会出现在脸上方并朝下对着你。
     */
    override fun onRecenter(isUserInitiated: Boolean) {
        super.onRecenter(isUserInitiated)
        Log.i(TAG, "IMMERSIVE onRecenter user=$isUserInitiated")
        recenterEverything(waitForTracking = true)
    }

    private fun pauseForSystem() {
        inputSuspended = true
        cancelSpatialInteractions()
        if (!controls.pauseOnFocusLoss) return
        if (playback.isAlive && playback.isPlaying) {
            playback.setPlaying(false)
            controls.isPlaying = false
            pausedBySystem = true
        }
    }

    private fun resumeAfterSystem() {
        inputSuspended = false
        headReadiness.reset()
        lastMotionAt = 0L
        if (!pausedBySystem) return
        pausedBySystem = false
        if (playback.isAlive) {
            playback.setPlaying(true)
            controls.isPlaying = true
        }
    }

    override fun onSpatialShutdown() {
        Log.i(TAG, "IMMERSIVE onSpatialShutdown")
        logMemory("onSpatialShutdown")
        notifyEnded()
        gallery?.let { ImmersiveBridge.notifyGalleryEnded(it.galleryId, it.index) }
        ImmersiveBridge.detachScene()
        status.stop()
        if (prefsDirty) prefs.save(controls)
        manipulator.shutdown()
        playback.detachSurface()
        mediaEffects.detach()
        screenEntity?.destroy()
        screenEntity = null
        screenPanel = null
        uiPanelEntity?.destroy()
        uiPanelEntity = null
        uiPanel = null
        controlsEntity?.destroy()
        controlsEntity = null
        controlsPanel = null
        controlsDoomed?.destroy()
        controlsDoomed = null
        bufferingEntity?.destroy()
        bufferingEntity = null
        playback.release()
        super.onSpatialShutdown()
    }

    override fun onDestroy() {
        Log.i(TAG, "IMMERSIVE onDestroy")
        logMemory("onDestroy")
        playback.release()
        mediaEffects.detach()
        // The pause request is sticky now (see ImmersiveBridge); never leave the
        // panel's Flutter frozen after the scene that froze it is gone.
        ImmersiveBridge.setPanelRenderingPaused(false)
        super.onDestroy()
    }

    // ================================================================ Dart 通道

    private val bridgeListener = object : ImmersiveBridge.Listener {

        override fun onPresent(request: ImmersiveVideoRequest) {
            runOnUiThread {
                val freshPlacement = !stageActive || inGallery
                if (freshPlacement) resetStagePlacement()
                // 幕布上正放着图库：先收掉它（图片面板销毁、Dart 收 galleryEnded），下面按「没有片源」的路建视频幕布。
                if (inGallery) exitGallery()
                // 同一条片子（videoId 相同）再 present 不算换片：面板上换过清晰度之后 argUrl 已不是 Dart
                // 手里那个地址，按地址判会把它当成换片、从 Dart 的旧位置重新起播。同片不同地址 = 换源。
                val sameVideo = argUrl != null && request.videoId.isNotBlank() && request.videoId == videoId
                val switchingVideo = !sameVideo && request.url != argUrl
                Log.i(TAG, "IMMERSIVE present id=${request.videoId} switching=$switchingVideo alive=${playback.isAlive} pos=${request.positionMs}")
                if (switchingVideo && argUrl != null && playback.isAlive) {
                    // 老片暂停等着，新片后台预加载，就绪再换（见 commitSwitch）；失败把老片放回去。
                    beginSwitch(request.videoId.ifBlank { controls.switchingToId })
                    // 面板里的 Flutter 已经换好页了，立刻停掉它的出帧（正常路径由 rebuildScreen 做）。
                    ImmersiveBridge.setPanelRenderingPaused(true)
                    placeUiPanel(visible = false)
                    playback.preload(
                        url = request.url,
                        startPositionMs = request.positionMs,
                        onReady = { runOnUiThread { commitSwitch(request) } },
                        onError = { msg ->
                            runOnUiThread {
                                clearSwitchWait(resumeOldVideo = true)
                                controls.notice = text(UiR.string.xr_notice_next_failed_reason, msg)
                                showControls(summoned = true)
                            }
                        },
                    )
                    return@runOnUiThread
                }
                if (switchingVideo && argUrl != null) notifyEnded()
                val before = controls.format
                if (sameVideo && request.url != argUrl && playback.isAlive) {
                    playback.swapSource(request.url, muted = controls.muted, volume = controls.volume)
                }
                applyRequest(request, switchingVideo)
                if (!switchingVideo && screenEntity != null && ScreenGeometry.sameFamily(before, controls.format)) {
                    requestShape(0L)
                } else {
                    rebuildScreen(keepPlayback = !switchingVideo)
                }
            }
        }

        override fun onPresentGallery(request: ImmersiveGalleryRequest) {
            runOnUiThread { presentGallery(request) }
        }

        /** 通道已经在主线程上（见 [ImmersiveBridge.togglePanelControls]），直接办完回值。 */
        override fun onTogglePanelControls(): Boolean = togglePanelControls()

        override fun onDismiss() {
            runOnUiThread {
                Log.i(TAG, "IMMERSIVE dismiss")
                backToApp()
            }
        }

        /**
         * 面板里的 MainActivity 自己 finish 了（根级「再按一次退出」→ `SystemNavigator.pop()`）：
         * 整个应用一起退，否则沉浸场景还活着、面板却空了（用户 2026-09-05：「一直按 B 无法真正退出」）。
         */
        override fun onHostFinished() {
            runOnUiThread {
                if (isFinishing || isDestroyed) return@runOnUiThread
                Log.i(TAG, "IMMERSIVE host activity finished -> finish immersive")
                finishAndRemoveTask()
            }
        }

        override fun onAbortSwitch(id: String, reason: String) {
            runOnUiThread {
                val current = controls.switchingToId ?: return@runOnUiThread
                if (id.isNotBlank() && id != current) return@runOnUiThread
                Log.w(TAG, "IMMERSIVE switch aborted by Dart id=$id reason=$reason")
                playback.cancelPreload()
                clearSwitchWait(resumeOldVideo = true)
                controls.notice = if (reason.isBlank()) {
                    text(UiR.string.xr_notice_next_unavailable)
                } else {
                    text(UiR.string.xr_notice_next_unavailable_reason, reason)
                }
                showControls(summoned = true)
            }
        }

        /**
         * 同一条片子的清晰度清单换了新地址（Dart 到期前 5 分钟主动刷、或应我们 [sourceExpired] 之请刷）。
         * 正在放的那一档地址变了就接着当前位置换过去；本地文件那档不会过期，原样不动。
         */
        override fun onSources(id: String, sources: List<ImmersiveSourceOption>) {
            runOnUiThread {
                if (argUrl.isNullOrBlank() || id.isBlank() || id != videoId) {
                    Log.i(TAG, "IMMERSIVE sources ignored id=$id playing=$videoId")
                    return@runOnUiThread
                }
                controls.sources.clear()
                controls.sources.addAll(sources.map { SourceOption(it.label, it.url, it.local, it.display) })
                val refreshing = sourceRefreshUntil != 0L
                val current = sources.firstOrNull { it.label == controls.sourceLabel }
                val swapped = current != null && !current.local &&
                    playback.swapSource(current.url, muted = controls.muted, volume = controls.volume)
                if (swapped) {
                    argUrl = current!!.url
                    controls.buffering = true
                    if (refreshing) controls.notice = null
                    Log.i(TAG, "IMMERSIVE sources refreshed -> swapped ${current.label} refreshing=$refreshing")
                } else if (refreshing) {
                    // 要来的还是同一个地址（没到期却被拒）/ 清单里没有这一档：恢复失败，如实报错。
                    controls.buffering = false
                    controls.notice = text(UiR.string.xr_notice_url_expired_no_refresh)
                    showControls(summoned = true)
                    Log.w(TAG, "IMMERSIVE sources refreshed but nothing to swap label=${controls.sourceLabel}")
                }
                sourceRefreshUntil = 0L
            }
        }

        override fun onPlaylist(
            sections: List<ImmersivePlaylistSection>,
            groups: List<ImmersivePlaylistGroup>,
            activeQueueId: String?,
            playingId: String?,
        ) {
            runOnUiThread {
                playlistSections = sections
                if (playingId != null) nowPlayingId = playingId
                // 正在等的那个池推过来了、但第一页还在路上（Dart 在 adopt 那一刻就先推一次空池）：
                // 在途态不收，看门狗顺延，等第一页到了重推再收。
                val pending = controls.playlistPendingQueueId
                val pendingStillLoading = pending != null &&
                    sections.any { it.queueId == pending && it.loading && it.items.isEmpty() }
                if (pendingStillLoading) {
                    playlistWaitUntil = SystemClock.uptimeMillis() + PLAYLIST_WAIT_MS
                } else {
                    clearPlaylistWait()
                }
                controls.playlistLoadingMoreQueueId = null
                controls.nowPlayingId = nowPlayingId
                if (activeQueueId != null || controls.activeQueueId == null) controls.activeQueueId = activeQueueId
                controls.playlistSections.clear()
                controls.playlistSections.addAll(
                    sections.map { sec ->
                        PlaylistSection(
                            queueId = sec.queueId,
                            title = sec.title,
                            hasMore = sec.hasMore,
                            loading = sec.loading,
                            entries = sec.items.map {
                                PlaylistEntry(
                                    id = it.id, title = it.title, author = it.author, durationText = it.durationText,
                                    thumbnailUrl = it.thumbnailUrl, progressRatio = it.progress,
                                    watched = it.watched, playable = it.playable, downloaded = it.downloaded,
                                )
                            },
                        )
                    },
                )
                controls.playlistGroups.clear()
                controls.playlistGroups.addAll(
                    groups.map { g ->
                        PlaylistGroup(
                            id = g.id, title = g.title, subtitle = g.subtitle, loading = g.loading,
                            choices = g.choices.map { PlaylistChoice(it.queueId, it.title, it.count) },
                        )
                    },
                )
                // 展开着的分组已经不在了（例如他人的播放列表随池被顶掉）就收回分组行。
                if (controls.expandedGroupId != null && groups.none { it.id == controls.expandedGroupId }) {
                    controls.expandedGroupId = null
                }
            }
        }
    }

    /** 「接着看」向 Dart 发了请求：进在途态，超时自动收。 */
    private fun beginPlaylistWait(pendingQueueId: String? = null) {
        controls.playlistLoading = true
        controls.playlistPendingQueueId = pendingQueueId
        playlistWaitUntil = SystemClock.uptimeMillis() + PLAYLIST_WAIT_MS
    }

    private fun clearPlaylistWait() {
        controls.playlistLoading = false
        controls.playlistPendingQueueId = null
        playlistWaitUntil = 0L
    }

    private fun hideResumeTip() {
        resumeTipUntil = 0L
        controls.resumeTipText = null
    }

    /** 把一次 present 的字段落到状态上（不动幕布）。 */
    private fun applyRequest(request: ImmersiveVideoRequest, switchingVideo: Boolean) {
        argUrl = request.url
        videoId = request.videoId
        if (request.width > 0) videoWidth = request.width
        if (request.height > 0) videoHeight = request.height
        controls.format = ScreenGeometry.formatOf(request.shape, request.stereo, request.fullFrame)
        controls.formatTab = controls.format.tab
        controls.title = request.title
        controls.author = request.author
        controls.notice = if (!controls.format.supported || request.unsupportedProjection) {
            text(UiR.string.xr_notice_unsupported_projection)
        } else {
            null
        }
        controls.sources.clear()
        controls.sources.addAll(request.sources.map { SourceOption(it.label, it.url, it.local, it.display) })
        controls.sourceLabel = request.sourceLabel
        if (switchingVideo) {
            pendingStartMs = request.positionMs
            hideResumeTip()
            sourceRefreshRequested = false
            sourceRefreshUntil = 0L
            layoutAppliedForKey = null
            // 「沿用到下一条视频」关着：屏幕尺寸（宽高比 / 宽比 / 长比）与倍速回默认。
            // 要在起播 / 重塑幕布之前落下去：commitPreloaded 与 startPlayback 都直接读 controls.speed。
            if (!controls.carryOverToNextVideo) controls.resetPerVideoSettings()
        }
        nowPlayingId = request.videoId.ifBlank { null }
        controls.nowPlayingId = nowPlayingId
        Log.i(TAG, "IMMERSIVE apply format=${controls.format} dims=${videoWidth}x$videoHeight pos=${request.positionMs}")
    }

    /**
     * 预加载好了：这一刻才把老片换掉。
     *
     * 老片的最后位置先交回 Dart（回写历史），再让引擎把预加载的播放器接上 Surface；
     * 投影家族没变就原地 reshape（幕布实体不动、无黑屏），变了才重建幕布。
     */
    private fun commitSwitch(request: ImmersiveVideoRequest) {
        if (!playback.isPreloading) return
        cancelSpatialInteractions()
        notifyEnded()
        val before = controls.format
        val nextFormat = ScreenGeometry.formatOf(request.shape, request.stereo, request.fullFrame)
        // ⛔ 换片且前后有一方是球幕：锚点按**此刻**的视线重新捕获。看 360 时人会转身，
        // 沿用旧锚点的话 180 半球 / 平幕会落在转身前的方向上（「有时出现在右侧」）。
        if (!before.isFlat || !nextFormat.isFlat) {
            anchor = null
            screenSurfaceOverride = null
        }
        applyRequest(request, switchingVideo = true)
        val size = playback.commitPreloaded(
            muted = controls.muted, volume = controls.volume,
            speed = controls.speed, repeatOne = controls.repeatMode == RepeatMode.ONE,
        )
        if (size != null) {
            videoWidth = size.first
            videoHeight = size.second
        }
        applyLayoutForAspect()
        if (pendingStartMs >= RESUME_TIP_MIN_MS) {
            controls.resumeTipText = text(UiR.string.xr_notice_resumed_at, formatMs(pendingStartMs))
            resumeTipUntil = SystemClock.uptimeMillis() + RESUME_TIP_MS
        }
        pendingStartMs = 0L
        controls.isPlaying = true
        resetTrackUi()
        clearSwitchWait()
        if (screenEntity != null && ScreenGeometry.sameFamily(before, controls.format)) {
            requestShape(0L)
        } else {
            rebuildScreen(keepPlayback = true)
        }
        lastInteractionAt = SystemClock.uptimeMillis()
        Log.i(TAG, "IMMERSIVE switch committed id=$videoId")
    }

    /**
     * 进入换片在途态：那张卡转圈、面板进 Loading（播放 / 暂停、±10 秒、进度条禁用），
     * 老片**暂停**等着 —— 不能让用户看着它还在放、还能拖进度（用户 2026-09-05）。
     */
    private fun beginSwitch(id: String?) {
        cancelSpatialInteractions()
        controls.switchingToId = id
        switchWaitUntil = SystemClock.uptimeMillis() + SWITCH_WAIT_MS
        if (!pausedForSwitch && playback.isAlive && playback.isPlaying) {
            playback.setPlaying(false)
            pausedForSwitch = true
        }
        controls.isPlaying = false
        seeking = false
        controls.seekPreviewText = null
        lastInteractionAt = SystemClock.uptimeMillis()
    }

    /** @param resumeOldVideo 换片失败 / 超时：老片是我们暂停的就放回去；换成功时老播放器已释放，传 false。 */
    private fun clearSwitchWait(resumeOldVideo: Boolean = false) {
        controls.switchingToId = null
        switchWaitUntil = 0L
        val resume = pausedForSwitch && resumeOldVideo
        pausedForSwitch = false
        if (resume && playback.isAlive) {
            playback.setPlaying(true)
            controls.isPlaying = true
        }
    }

    /** 把最后的播放位置交还 Dart（回写观看历史）。只在真有片子时发一次。 */
    private fun notifyEnded() {
        if (argUrl.isNullOrBlank()) return
        val id = videoId
        if (id.isBlank()) return
        ImmersiveBridge.notifyImmersiveEnded(id, playback.positionMs, playback.durationMs)
    }

    // ================================================================ 头部 / 摆位

    /** Use the same world-space eyes as the SDK's FACE grab and default cursor. */
    private fun headPose(): Pose? = runCatching { scene.getViewerPose() }.getOrNull()

    /**
     * A non-null pose alone is not proof of tracking: the initial identity pose is at floor level.
     * Keep the readiness gate when reading the runtime viewer, just as for the former avatar pose.
     */
    private fun trackedHeadPose(): Pose? = headPose()?.takeIf(SpatialPlacement::isTracked)

    private fun headTrackingReady(): Boolean = headReadiness.ready
    private fun headSettleTimedOut(): Boolean = headReadiness.timedOut

    private fun frameAlong(origin: Vector3, forward: Vector3, headUp: Vector3, dropDeg: Float): Pose =
        SpatialPlacement.frame(origin, forward, headUp, dropDeg)

    /** 拿不到头部位姿时的兜底锚点：原点上方站姿眼高、朝 +Z。 */
    private fun fallbackFrame(): Pose = Pose(Vector3(0f, FALLBACK_EYE_HEIGHT_M, 0f), Quaternion(0f, 0f, 0f))

    private fun currentAnchor(): Pose = anchor ?: captureAnchor()

    private fun captureAnchor(): Pose {
        // Entry and recenter share the same tracking gate. Never inherit a moved/parked browsing panel.
        val head = trackedHeadPose()?.takeIf { headTrackingReady() }
        anchorIsFallback = head == null
        sphereForwardOverride = null
        sphereOffsetM = 0f
        return (head?.let(SpatialPlacement::viewFrame) ?: fallbackFrame()).also { anchor = it }
    }

    /** Authoritative visible-face pose, shared by rendering, hit testing, and distance changes. */
    private fun screenSurfacePose(): Pose = screenSurfaceOverride ?:
        SpatialPlacement.screenSurface(currentAnchor(), controls.screenDistance, controls.screenOffset)

    /**
     * 球幕：人在球心。朝向按锚点的视线：
     * - 视线接近水平（坐着）：只取偏航，内容的地平线保持水平；
     * - 视线明显仰起（躺着 / 半躺）：按整个视线摆，让 180 半球正对着人看的方向，
     *   否则躺着看到的只是半球的下沿。
     *
     * ⛔ 不再用 SDK 的 `removePitchAndRoll()`（走欧拉分解，仰角大时 yaw 抖动，
     * 「180 有时在右侧」的另一半原因）。
     */
    private fun spherePose(): Pose {
        val a = currentAnchor()
        val override = sphereForwardOverride
        // ⛔ 用户拖过的视角按**整个前向**摆（偏航 + 俯仰）。[sphereQuatFor] 那条「仰角 <30° 只取偏航」是给
        // 「进场时视线」用的（坐着看时地平线要水平），套在拖视角上就成了：先只能左右转，拖过 30° 才突然带上俯仰，
        // 拖回 30° 以内又弹回去（用户 2026-09-05 在 180 / 360 里都碰到）。
        val q = if (override != null) frameAlong(a.t, override, a.up(), dropDeg = 0f).q else sphereQuatFor(a.t, a.forward(), a.up())
        // 推远 / 拉近：球心沿球幕前向离开头部（用户 2026-09-05：全景片也要能前后推）。
        val forward = Pose(a.t, q).forward()
        return Pose(a.t + forward * sphereOffsetM, q)
    }

    /** 球幕的朝向：视线接近水平只取偏航（地平线保持水平）；仰得多（躺着）按整个前向。 */
    private fun sphereQuatFor(origin: Vector3, f: Vector3, headUp: Vector3): Quaternion {
        val horizontal = Vector3(f.x, 0f, f.z)
        return if (abs(f.normalize().y) < SPHERE_FOLLOW_PITCH_SIN && horizontal.length() > 0.05f) {
            frameAlong(origin, horizontal, Vector3(0f, 1f, 0f), dropDeg = 0f).q
        } else {
            frameAlong(origin, f, headUp, dropDeg = 0f).q
        }
    }

    private fun screenPose(): Pose = when {
        !controls.format.isFlat -> spherePose()
        else -> surfaceToEntityPose(screenSurfacePose())
    }

    /** 弧面中心 → 实体锚点（圆柱轴心在面后一个半径处；平面半径为 0 就是自己）。 */
    private fun surfaceToEntityPose(surface: Pose): Pose {
        val radius = ScreenGeometry.radiusFor(curArc, curWidth)
        return Pose(surface.t - surface.forward() * radius, surface.q)
    }

    /**
     * 距离/偏移/半径改了：只挪位置，不重建（无接缝）。
     *
     * ⛔ 位置要**同时**直接写到场景对象上：ECS 的 Transform 组件要到下一帧才由系统应用，
     * 而 `reshape()` 是立即生效的 —— 差这一帧就是「切曲面时画面猛进猛退、抖动」的根因
     * （每帧都先按新半径 + 旧位置画一次）。
     */
    private fun applyScreenTransform() {
        val pose = if (screenShown) screenPose() else PARKED_POSE
        screenEntity?.setComponent(Transform(pose))
        screenPanel?.let {
            it.setPosition(pose.t)
            it.setRotationQuat(pose.q)
        }
        syncMediaEffects()
        syncBufferingPose()
    }

    /** Main windows share the same lowered center and face the runtime viewer. */
    private fun uiPanelPose(): Pose {
        val frame = trackedHeadPose()?.let(SpatialPlacement::viewFrame) ?: fallbackFrame()
        return SpatialPlacement.screenSurface(frame, prefs.uiPanelDistance)
    }

    /** 面板此刻离眼睛多远（米）；头部还没跟踪到就用记着的那一份。 */
    private fun uiPanelDistanceNow(): Float {
        val viewer = trackedHeadPose() ?: return prefs.uiPanelDistance
        return (uiSurfacePose.t - viewer.t).length()
            .takeIf { it.isFinite() && it > 0.05f } ?: prefs.uiPanelDistance
    }

    /** 把面板当前的远近记成偏好（夹在允许范围内）。 */
    private fun rememberUiPanelDistance() {
        if (uiPanelEntity == null || !uiPlacement.shown) return
        prefs.uiPanelDistance = uiPanelDistanceNow()
            .coerceIn(PlayerPrefs.MIN_UI_PANEL_DISTANCE_M, PlayerPrefs.MAX_UI_PANEL_DISTANCE_M)
        markPrefsDirty()
    }

    /**
     * 把 2D 面板推到某个绝对距离（米）。
     *
     * 沿着**当前视线看过去的那条方位**推拉（[SpatialPlacement.atDistance]），而不是回到出生时的
     * 正前方 —— 挪到侧边的面板不会被这两条命令拽回中间。
     *
     * @return 夹取后的实际距离；面板此刻不在场（幕布占着场地 / 头部还没跟踪到）时 null。
     */
    private fun setUiPanelDistance(meters: Float): Float? {
        if (uiPanelEntity == null || !uiPlacement.shown) return null
        val viewer = trackedHeadPose() ?: return null
        val next = meters.coerceIn(PlayerPrefs.MIN_UI_PANEL_DISTANCE_M, PlayerPrefs.MAX_UI_PANEL_DISTANCE_M)
        prefs.uiPanelDistance = next
        markPrefsDirty()
        uiPlacement.moved()
        applyUiPanelPose(SpatialPlacement.atDistance(uiSurfacePose, viewer, next))
        manipulator.syncFrame(WindowKind.UI)
        controls.uiPanelDistance = next
        lastInteractionAt = SystemClock.uptimeMillis()
        return next
    }

    /**
     * 相对当前距离乘一个小系数（`+0.01` = 远 1%）。
     *
     * ⭐ **与幕布那条 [nudgeScreenDistance] 是同一个式子**：乘性、越远走得越快。用户 2026-09-09
     * 在真机上一按就发现了不对 ——「2D 主应用的长按变化幅度跟空间视频里的那种不一样」。当时
     * 面板走的是「0.25m 一格、按住每 130ms 跳一格」，幕布走的是逐帧连续的 [ViewDistanceMotion]，
     * 同一副长相的三枚钮、两种手感。现在两处共用 [ViewDistanceMotion.flatFactor]，
     * 点一下与按住的幅度都对得上。
     */
    private fun nudgeUiPanelDistance(relative: Float) {
        val distance = uiPanelDistanceNow()
        if (distance < 0.05f) return
        setUiPanelDistance(distance * (1f + relative))
    }

    /** 「重置位置」：距离回默认档，并按当前视线把面板摆回正前方。 */
    fun resetUiPanelPlacement(): Float? {
        if (uiPanelEntity == null || !uiPlacement.shown) return null
        prefs.uiPanelDistance = PlayerPrefs.DEFAULT_UI_PANEL_DISTANCE_M
        markPrefsDirty()
        uiPlacement.reset()
        placeUiPanel(visible = true)
        manipulator.syncFrame(WindowKind.UI)
        controls.uiPanelDistance = prefs.uiPanelDistance
        Log.i(TAG, "IMMERSIVE ui panel placement reset -> ${"%.2f".format(prefs.uiPanelDistance)}m")
        return prefs.uiPanelDistance
    }

    /**
     * 侧栏那枚「面板设置」钮（Dart → [ImmersiveBridge.togglePanelControls]）：把控制面板唤到
     * [ControlsRoute.BROWSE] 那一页，再按一下收起。
     *
     * ⛔ 只在浏览态：影院态里 2D 面板本来就让位藏起来了，那枚钮根本不在眼前，
     * 这时候唤出来的只会是一块与播放面板抢位置的空页。
     *
     * @return 是否受理（false = 幕布正占着场地）。
     */
    fun togglePanelControls(): Boolean {
        if (stageActive) return false
        if (controlsEntity != null && controls.route == ControlsRoute.BROWSE) {
            hideControls()
            return true
        }
        controls.uiPanelDistance = uiPanelDistanceNow()
        // ⛔ 先换页再唤面板：反过来会先闪一眼播放页再淡入本页（Crossfade 会当成一次换页）。
        controls.route = ControlsRoute.BROWSE
        if (controlsEntity == null) showControls(summoned = true) else touched()
        return true
    }

    /**
     * 「面板远近」按住连走：**逐帧**按 [ViewDistanceMotion.flatFactor] 走，与幕布那条
     * （`handleInput` 里的 [adjustViewDistance]）同一套速率、同一个 0.05s 的每帧上限。
     */
    private fun tickUiPanelHold(now: Long) {
        if (uiPanelHoldDirection == 0) return
        // 面板收了 / 换了页 / 幕布上来了：手指还按着也停（Compose 那边的松手回调可能永远不来）。
        if (stageActive || controlsEntity == null || controls.route != ControlsRoute.BROWSE) {
            endUiPanelHold()
            return
        }
        val seconds = if (uiPanelHoldLastAt == 0L) 0f else ((now - uiPanelHoldLastAt) / 1000f).coerceIn(0f, 0.05f)
        uiPanelHoldLastAt = now
        nudgeUiPanelDistance(ViewDistanceMotion.flatFactor(uiPanelHoldDirection, seconds) - 1f)
    }

    /** 松手 / 被打断：停下，并把这一按走了多远记一笔（逐帧不打日志，那会把 logcat 刷爆）。 */
    private fun endUiPanelHold() {
        if (uiPanelHoldDirection == 0) return
        uiPanelHoldDirection = 0
        uiPanelHoldLastAt = 0L
        Log.i(
            TAG,
            "IMMERSIVE ui panel distance ${"%.2f".format(uiPanelHoldFrom)} -> " +
                "${"%.2f".format(uiPanelDistanceNow())}m",
        )
    }

    /**
     * 藏起来的 UI 面板要**挪走**而不只是隐身：`Visible(false)` 不影响 ISDK 命中，一块看不见的
     * 1.6m 面板会继续挡住射线 —— 用户 2026-09-05：「屏幕某些区域光标不显示，无法调整后方显示器」。
     */
    private fun placeUiPanel(visible: Boolean) {
        val entity = uiPanelEntity ?: return
        // 头部还没跟踪到：先停着不露面，几帧后 [settleHeadPlacement] 按真实视线摆出来
        // （否则先在地板高度闪一下再跳到面前）。等得太久（3DoF）才按兜底摆。
        val ready = headTrackingReady()
        val show = visible && (ready || headSettleTimedOut())
        entity.setComponent(Visible(show))
        val pose = if (show) uiPanelPose() else PARKED_POSE
        applyUiPanelPose(pose)
        uiPlacement.placed(show, headReady = ready)
        if (show) Log.i(TAG, "IMMERSIVE ui panel placed byHead=$ready head=${trackedHeadPose()?.t}")
    }

    /** Keep one authoritative pose for both the content and frame, ahead of ECS propagation. */
    private fun applyUiPanelPose(pose: Pose) {
        uiSurfacePose = pose
        val anchor = uiSurfaceToEntityPose(pose)
        uiPanelEntity?.setComponent(Transform(anchor))
        uiPanel?.let { it.setPosition(anchor.t); it.setRotationQuat(anchor.q) }
    }

    /**
     * 2D 应用面板的网格半径（米）：**弧度**定死 [UI_PANEL_ARC_DEGREES]，半径由宽度反推。
     *
     * 与幕布同一套几何（[ScreenGeometry.radiusFor]）：面宽是弧长，`radius = 弧长 / 弧度`。
     * 于是把窗拉宽拉窄，包过来的角度不变、弯的程度看起来是一致的。
     */
    private fun uiPanelMeshRadius(width: Float): Float = ScreenGeometry.radiusFor(UI_PANEL_ARC_DEGREES, width)

    /**
     * 曲面中心 → 实体锚点（同 [surfaceToEntityPose]）：圆柱的锚点在**轴心**，曲面在它前方一个半径处。
     *
     * ⛔ 半径要乘 [uiScale].x：拖角时面板按当前宽度 reshape（见 [uiHost] 的 `resizeTo`），弧度不变、
     * 半径与宽度同倍变大，`radiusFor` 对宽度是线性的，所以基准半径 × 宽度比就是此刻的半径。
     * 不乘这一下，拖宽窗时曲面会离开轴心、整块往前跑。
     */
    private fun uiSurfaceToEntityPose(surface: Pose): Pose {
        val radius = uiPanelMeshRadius(uiBaseSize.x) * uiScale.x
        return Pose(surface.t - surface.forward() * radius, surface.q)
    }

    /**
     * 把 2D 应用面板的碰撞面告诉 ISDK —— 与 [syncIsdkScreenShape] 同一件事、同一个坑：
     * ISDK 默认按平面 quad 命中，弧面不同步就是「边缘光标消失」。
     */
    private fun syncIsdkUiShape() {
        val entity = uiPanelEntity ?: return
        entity.setComponent(IsdkPanelDimensions(Vector2(uiBaseSize.x * uiScale.x, uiBaseSize.y * uiScale.y)))
        entity.setComponent(IsdkCurvedPanel(UI_PANEL_ARC_DEGREES))
    }

    /** 锚点是否是用兜底值捕获的（头部还没就绪），是的话头部一就绪就重新捕获。 */
    private var anchorIsFallback = false

    /**
     * 缓冲指示**与幕布同位同形**：平幕/弧幕时就是一块和幕布一模一样的透明面板叠在上面
     * （zIndex 更高），转圈压在画面正中、暗一层，像播放器自己画的而不是一个浮窗
     * （用户 2026-09-05：「应该镶嵌于播放器本身，和播放画面融为一体」）。球幕时放在视线前 2m。
     */
    private fun bufferingPose(): Pose {
        // 平幕：跟幕布实体的**实际**位置（用户可能正抓着它挪），不是算出来的那份。
        if (controls.format.isFlat) return screenEntity?.tryGetComponent<Transform>()?.transform ?: screenPose()
        // 球幕：创建那一刻沿球幕的正前方 2m 定死，之后不跟视线（跟着走就一直跳）。
        bufferingFrozenPose?.let { return it }
        val s = spherePose()
        return Pose(s.t + s.forward() * 2f, s.q).also { bufferingFrozenPose = it }
    }

    private fun bufferingShape(): UIPanelShapeOptions =
        if (controls.format.isFlat) {
            ScreenGeometry.shapeFor(controls.format, curArc, curWidth, curAspect) as UIPanelShapeOptions
        } else {
            QuadShapeOptions(width = BUFFERING_SPHERE_SIZE_M, height = BUFFERING_SPHERE_SIZE_M)
        }

    private fun bufferingSettings(): UIPanelSettings = UIPanelSettings(
        shape = bufferingShape(),
        display = DpPerMeterDisplayOptions(dpPerMeter = BUFFERING_DP_PER_METER),
        rendering = UIPanelRenderOptions(
            renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
        ),
    )

    /** Keep summoned controls in a comfortable downward glance, independent of their size. */
    private fun controlsPoseInFront(): Pose {
        val frame = trackedHeadPose()?.let(SpatialPlacement::viewFrame) ?: currentAnchor()
        return SpatialPlacement.controlsSurface(frame, CONTROLS_DISTANCE_M)
    }

    /**
     * zIndex only orders compositor layers; ISDK hits and cursors still use scene depth.
     * Keep the whole controls panel ahead of overlapping screen geometry, including the
     * curved sides and tilt. Restore its saved base when the screen is moved away again.
     */
    private fun syncControlsDepth() {
        val entity = controlsEntity ?: return
        val base = controlsBasePose ?: return
        val viewer = trackedHeadPose() ?: currentAnchor()
        val target = if (controls.format.isFlat && screenEntity != null && screenShown) {
            PanelDepth.inFrontOfScreen(
                panel = base, panelSize = controlsHost.size(), viewer = viewer,
                screen = screenSurfacePose(), screenSize = Vector2(curWidth, curWidth / curAspect),
                radius = ScreenGeometry.radiusFor(curArc, curWidth), gap = CONTROLS_SCREEN_GAP_M,
            )
        } else base
        val current = entity.tryGetComponent<Transform>()?.transform ?: return
        if ((current.t - target.t).length() < 0.002f && abs(current.q.dot(target.q)) > 0.99999f) return
        val pose = if ((current.t - target.t).length() >= 0.002f) SpatialPlacement.facingSurface(target, viewer) else target
        entity.setComponent(Transform(pose))
        controlsPanel?.let { it.setPosition(pose.t); it.setRotationQuat(pose.q) }
        manipulator.syncFrame(WindowKind.CONTROLS)
    }

    /** Restore a saved position only when it is still within an easy glance. */
    private fun isRoughlyInFront(pose: Pose): Boolean {
        val frame = trackedHeadPose()?.let(SpatialPlacement::viewFrame) ?: return true
        return SpatialPlacement.controlsInView(pose, frame)
    }

    /** Cancel in-flight gestures before changing their coordinate system. */
    private fun cancelSpatialInteractions() {
        manipulator.cancelAll()
        input.reset(awaitRelease = true)
        endScrub()
        endSphereGrab(hideControls = false)
        twoHandScaling = false
        cancelStageSwipe()
        stage.swipe.blocked = false
        bufferingState.swipe.blocked = false
        viewDistanceDirection = 0
        for (i in 0..1) tapCandidate[i] = false
    }

    /** A fresh media entry must not inherit a browsing recenter or another projection's anchor. */
    private fun resetStagePlacement(hidePanel: Boolean = true) {
        cancelSpatialInteractions()
        if (hidePanel) hideControls()
        anchor = null
        screenSurfaceOverride = null
        lastControlsPose = null
        bufferingFrozenPose = null
    }

    private fun recenterEverything(waitForTracking: Boolean = false) {
        resetStagePlacement(hidePanel = false)
        if (waitForTracking) headReadiness.reset()
        // Recenter restores a comfortable height as well as heading; distance and size stay personal.
        controls.screenOffset = 0f
        markPrefsDirty()
        if (!stageActive) {
            uiPlacement.reset()
            placeUiPanel(visible = true)
            return
        }
        captureAnchor()
        screenShown = !anchorIsFallback || headSettleTimedOut()
        screenEntity?.setComponent(Visible(screenShown))
        applyScreenTransform()
        if (controlsEntity != null) {
            if (screenShown) {
                val pose = controlsPoseInFront()
                controlsEntity?.setComponent(Transform(pose))
                controlsPanel?.let { it.setPosition(pose.t); it.setRotationQuat(pose.q) }
                lastControlsPose = pose
                controlsBasePose = pose
            } else {
                hideControls()
                lastControlsPose = null
                pendingShowControls = true
            }
        }
    }

    // ================================================================ 幕布

    /**
     * 重建幕布实体（片子换了 / 投影家族换了 / 首次进入）。
     *
     * @param keepPlayback 片子没变，只是几何变了：播放器留着，只换 Surface。
     */
    private fun rebuildScreen(keepPlayback: Boolean = false) {
        // Only explicit user placement survives a rebuild. Capturing every computed center here
        // would preserve a previous default pose across changes to viewing geometry.
        if (!controls.format.isFlat || !screenEntityIsFlat) screenSurfaceOverride = null
        manipulator.detach(WindowKind.SCREEN)
        // 缓冲指示与幕布同形同位，幕布换了它也得重建（旧的形状 / 位置留着就会「跳」）。
        destroyBufferingEntity()
        // ⛔ 顺序：先摘 Surface 再销毁实体，否则播放器往已释放的缓冲上画。
        if (keepPlayback) playback.detachSurface() else playback.release()
        mediaEffects.detach()
        screenEntity?.destroy()
        screenEntity = null
        screenPanel = null

        val idle = !stageActive
        if (idle) playback.release()

        if (!idle && anchor == null) captureAnchor()

        // 看视频时 UI 面板让位：藏起 + 让 Flutter 停止出帧（destroy 会连 Activity 一起杀掉，代价太大）。
        ImmersiveBridge.setPanelRenderingPaused(!idle)
        if (argUiPanel && uiPanelEntity == null) createUiPanel()
        placeUiPanel(visible = idle)

        if (idle) {
            hideControls()
            controls.title = ""
            controls.author = ""
            controls.notice = null
            controls.buffering = false
            screenSurfaceOverride = null
            anchor = null
            screenShown = false
            pendingShowControls = false
            stage.model = null
            screenIsImage = false
            screenUsesEffectMesh = false
            screenUsesProcessedVideo = false
            syncBufferingIndicator()
            Log.i(TAG, "IMMERSIVE 无片源，只留 UI 面板，不建幕布")
            return
        }

        // 这个画面比例上次调过的距离 / 幕宽先恢复回来，再按它建幕布（空间画廊里每张比例都不同，不记也不恢复）。
        applyLayoutForAspect()

        // 形状参数直接落到目标值（首次进入没有过渡可言）。
        curArc = controls.curve.arcDegrees
        curAspect = ScreenGeometry.screenAspect(controls, videoWidth, videoHeight)
        curWidth = targetScreenWidth(curAspect)
        stage.quadAspect = curAspect
        animating = false

        val flat = controls.format.isFlat
        // 空间画廊的图片项：幕布换成 Compose 图片面板；视频项与普通视频都是 ExoPlayer 幕布。
        val wantImage = inGallery && gallery?.current?.isVideo != true
        screenIsImage = wantImage
        screenUsesEffectMesh = wantsEffectMesh()
        screenUsesProcessedVideo = !wantImage && screenUsesEffectMesh
        if (screenUsesProcessedVideo) {
            processedVideoWidth = targetVideoWidth()
            processedVideoHeight = targetVideoHeight()
        }
        // 抓 / 挪 / 缩放不再挂 ISDK 的 Grabbable / IsdkPanelResize：平幕与弧幕都由 WindowManipulator 接管。
        screenShown = !anchorIsFallback || headSettleTimedOut()
        val entity = Entity.create(
            Panel(when {
                wantImage -> R.id.vr_image_panel
                screenUsesProcessedVideo -> R.id.vr_video_effects_panel
                else -> R.id.vr_video_panel
            }),
            Transform(if (screenShown) screenPose() else PARKED_POSE),
            Visible(screenShown),
        )
        screenEntity = entity
        screenEntityIsFlat = flat
        syncIsdkScreenShape()
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            if (screenEntity != entity) return@thenAccept
            val panel = so as? PanelSceneObject
            screenPanel = panel
            applyScreenTransform()
            runCatching { panel?.layer?.setZIndex(if (flat) Z_SCREEN else Z_SPHERE) }
        }
        if (flat) manipulator.attach(screenHost)
        // Gallery item changes may rebuild the surface; keep the existing controls visibility.
        // Entry into a gallery reveals them explicitly in presentGallery().
        if (!inGallery) showControls()
        syncBufferingIndicator()
    }

    private fun mediaSettings(): MediaPanelSettings = MediaPanelSettings(
        shape = ScreenGeometry.shapeFor(controls.format, curArc, curWidth, curAspect),
        display = PixelDisplayOptions(width = videoWidth, height = videoHeight),
        rendering = MediaPanelRenderOptions(
            stereoMode = ScreenGeometry.stereoMode(controls.format, controls.forceMono),
            zIndex = if (controls.format.isFlat) Z_SCREEN else Z_SPHERE,
        ),
        style = mediaEffectStyle(image = false),
    )

    private fun processedMediaSettings(): MediaPanelSettings = MediaPanelSettings(
        shape = ScreenGeometry.shapeFor(controls.format, curArc, curWidth, curAspect),
        display = PixelDisplayOptions(width = processedVideoWidth, height = processedVideoHeight),
        rendering = MediaPanelRenderOptions(
            stereoMode = ScreenGeometry.stereoMode(controls.format, controls.forceMono),
            zIndex = if (controls.format.isFlat) Z_SCREEN else Z_SPHERE,
        ),
        style = mediaEffectStyle(image = false),
    )

    private fun mediaEffectStyle(image: Boolean): PanelStyleOptions =
        if (!wantsEffectMesh()) PanelStyleOptions()
        else mediaEffects.style(image)

    private fun syncMediaEffects() {
        if (mediaEffectsFailed || !stageActive) return
        if (!screenUsesEffectMesh) {
            mediaEffects.detach()
            return
        }
        runCatching {
            mediaEffects.sync(
                screenPanel, controls.mediaEffects, controls.format, screenIsImage, controls.forceMono,
                curWidth, curAspect, curArc, if (screenShown) screenPose() else PARKED_POSE, screenShown,
            )
        }.onFailure {
            Log.e(TAG, "IMMERSIVE media effects unavailable; restoring the direct surface", it)
            mediaEffectsFailed = true
            mediaEffects.detach()
            controls.notice = text(UiR.string.xr_media_effects_fallback)
            rebuildScreen(keepPlayback = true)
        }
    }

    /**
     * 空间画廊图片面板的配置：形状与视频幕布同一套（曲率 / 幕宽 / 比例），像素画布是**固定的方块**。
     *
     * ⛔ 画布**不能**按当前图片的比例给：真机实测 `reshape()` 只换幕布形状、换不掉已经建好的画布
     * （用户 2026-09-06：竖图进去切宽图「宽度对、高度很窄」，反过来「高度满、宽度很窄」——
     * 那就是画布留着上一张比例的样子）。方画布 → 任意比例幕布的那次非等比拉伸由 Compose 侧补偿
     * （`GalleryStageState.imageAspect` / `quadAspect`），换图不必重建面板、不闪。
     */
    private fun imageSettings(): UIPanelSettings = UIPanelSettings(
        shape = ScreenGeometry.shapeFor(controls.format, curArc, curWidth, curAspect) as UIPanelShapeOptions,
        // UI 面板只有 dp 一族的尺寸选项：dpi 钉 160 时 1dp = 1px，正好按像素给。
        display = DpDisplayOptions(IMAGE_PANEL_PX.toFloat(), IMAGE_PANEL_PX.toFloat(), 160),
        rendering = UIPanelRenderOptions(
            renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
        ),
        style = mediaEffectStyle(image = true),
    )

    /** 幕布这块「窗」当前该用的配置：图片面板 / 视频幕布。 */
    private fun stageConfigOptions() = when {
        screenIsImage -> imageSettings().toPanelConfigOptions()
        screenUsesProcessedVideo -> processedMediaSettings().toPanelConfigOptions()
        else -> mediaSettings().toPanelConfigOptions()
    }

    /**
     * 幕布的目标宽度。视频 = 设置里的幕宽；空间画廊 = 把图片**装进「幕宽 × 16:9」的盒子**：
     * 竖图与横图同高，不会一张 9:16 的插画顶天立地（幕宽 3.2m 的话竖图会有 5.7m 高）。
     */
    private fun targetScreenWidth(aspect: Float): Float {
        val box = controls.screenWidth
        if (!inGallery) return box
        val boxHeight = box * 9f / 16f
        return min(box, boxHeight * aspect).coerceAtLeast(GALLERY_MIN_WIDTH_M)
    }

    /** 当前比例下「实际幕宽 / 盒子宽」；拉角缩放把实际宽换回盒子宽时用。 */
    private fun galleryFitFactor(): Float {
        val box = controls.screenWidth
        if (!inGallery || box <= 0f) return 1f
        return targetScreenWidth(curAspect) / box
    }

    /**
     * 发起一次形状过渡：从当前实际值插值到 state 里的目标值。
     *
     * @param durationMs 0 = 立刻到位（换立体模式这类没有中间态的）。滑块连续拖动给个很短的时长，
     *   逐帧跟手；换屏幕类型给 [CURVE_ANIM_MS]，有动画。
     */
    private fun requestShape(durationMs: Long) {
        if (!stageActive) return
        if (!controls.format.isFlat) {
            reshapeNow()
            return
        }
        animFromArc = curArc
        animFromWidth = curWidth
        animFromAspect = curAspect
        animStartAt = SystemClock.uptimeMillis()
        animDurationMs = durationMs
        animating = true
        stepShapeAnimation(animStartAt)
    }

    private fun stepShapeAnimation(now: Long) {
        if (!animating) return
        val targetArc = controls.curve.arcDegrees
        val targetAspect = ScreenGeometry.screenAspect(controls, videoWidth, videoHeight)
        val targetWidth = targetScreenWidth(targetAspect)
        val t = if (animDurationMs <= 0L) 1f else ((now - animStartAt).toFloat() / animDurationMs).coerceIn(0f, 1f)
        val k = t * t * (3f - 2f * t) // smoothstep
        curArc = animFromArc + (targetArc - animFromArc) * k
        curWidth = animFromWidth + (targetWidth - animFromWidth) * k
        curAspect = animFromAspect + (targetAspect - animFromAspect) * k
        // 图片幕布的画布是方的：形状每变一点，Compose 那边的拉伸补偿就要跟着变（见 imageSettings）。
        if (screenIsImage) stage.quadAspect = curAspect
        if (t >= 1f) animating = false
        reshapeNow()
    }

    /** 用当前 cur* 参数原地重塑幕布；reshape 失败退回重建。 */
    private fun reshapeNow() {
        val canvasChanged = screenUsesProcessedVideo &&
            (processedVideoWidth != targetVideoWidth() || processedVideoHeight != targetVideoHeight())
        if (screenUsesEffectMesh != wantsEffectMesh() || canvasChanged) {
            rebuildScreen(keepPlayback = true)
            return
        }
        val panel = screenPanel
        if (panel == null || screenEntity == null) {
            animating = false
            rebuildScreen(keepPlayback = true)
            return
        }
        // 幕布形状每一次落地都在这里：方画布的拉伸补偿必须同一时刻更新，晚一帧就是闪一下变形。
        if (screenIsImage) stage.quadAspect = curAspect
        val ok = runCatching {
            panel.reshape(stageConfigOptions())
            panel.layer?.setZIndex(if (controls.format.isFlat) Z_SCREEN else Z_SPHERE)
            // Processed video decodes into the GPU pipeline's input surface.
            // panel.surface is its OUTPUT. Rebinding the decoder to that output
            // steals the GL producer and stalls the image while its frame resizes.
            if (!screenIsImage && !screenUsesProcessedVideo) playback.attachSurface(panel.surface)
        }.isSuccess
        if (!ok) {
            Log.w(TAG, "IMMERSIVE reshape 失败，退回重建")
            animating = false
            rebuildScreen(keepPlayback = true)
            return
        }
        // 半径变了轴心就得跟着挪；用户抓着挪过的**弧面**位置照旧保留（轴心按新半径重算）。
        applyScreenTransform()
        syncIsdkScreenShape()
        // 缓冲指示与幕布同形，跟着一起重塑（缓冲期间换曲面 / 拖尺寸时才会走到）。
        bufferingPanel?.let { panel ->
            runCatching {
                panel.reshape(bufferingSettings().toPanelConfigOptions())
                panel.layer?.setZIndex(Z_BUFFERING)
            }
        }
    }

    /**
     * 把幕布的碰撞面告诉 ISDK。
     *
     * ISDK 默认把面板当平面 quad 做射线命中，尺寸取创建时那一份。弧幕的可见曲面与这块平面
     * 对不上：微曲面边缘光标消失、中/重曲面整个射线都不见了（真机反馈）—— 后者是碰撞面
     * 与用户交叠，射线一出手就被吃掉。`IsdkCurvedPanel(fieldOfView)` 让 ISDK 按同一段弧建碰撞面，
     * `IsdkPanelDimensions` 在每次 reshape 之后同步尺寸。
     */
    private fun syncIsdkScreenShape() {
        val entity = screenEntity ?: return
        if (!controls.format.isFlat) return
        entity.setComponent(IsdkPanelDimensions(Vector2(curWidth, curWidth / curAspect)))
        if (curArc >= ScreenGeometry.MIN_ARC_DEGREES) {
            val radius = ScreenGeometry.radiusFor(curArc, curWidth)
            entity.setComponent(IsdkCurvedPanel(Math.toDegrees((curWidth / radius).toDouble()).toFloat()))
        } else {
            runCatching { entity.removeComponent<IsdkCurvedPanel>() }
        }
    }

    private fun createUiPanel() {
        uiBaseSize = Vector2(prefs.uiPanelWidth, prefs.uiPanelHeight)
        uiScale = Vector2(1f, 1f)
        val entity = Entity.create(Panel(R.id.vr_ui_panel), Transform(PARKED_POSE), Visible(false))
        uiPlacement.reset()
        uiSurfacePose = PARKED_POSE
        uiPanelEntity = entity
        syncIsdkUiShape()
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            if (uiPanelEntity != entity) return@thenAccept
            val panel = so as? PanelSceneObject
            uiPanel = panel
            applyUiPanelPose(uiSurfacePose)
            runCatching { panel?.layer?.setZIndex(Z_UI) }
        }
        manipulator.attach(uiHost)
        Log.i(TAG, "IMMERSIVE ui panel created size=${uiBaseSize.x}x${uiBaseSize.y}m")
    }

    // ================================================================ 缓冲指示

    /**
     * 缓冲指示的生命周期：
     * - 缓冲持续超过 [BUFFERING_SHOW_DELAY_MS] 才露面（起播 / 拖动的短抖不闪一下）；
     * - 露面 = 建实体 + Compose 侧淡入；
     * - 收 = Compose 侧淡出，[BUFFERING_ANIM_MS] 后再销毁实体（0-alpha 照样付钱，不能常驻）。
     * 每帧从 onSceneTick 调一次。
     */
    private fun syncBufferingIndicator() {
        val now = SystemClock.uptimeMillis()
        val onScreen = stageActive && screenEntity != null && screenShown
        val buffering = controls.buffering && onScreen
        if (buffering) {
            if (bufferingSince == 0L) bufferingSince = now
        } else {
            bufferingSince = 0L
        }
        // 同一块叠层也给摇杆拖动进度的预览用：拖动一开始就露面，不等缓冲那 350ms。
        val want = (scrubbing && onScreen) || (buffering && now - bufferingSince >= BUFFERING_SHOW_DELAY_MS)
        // 横拖翻片的预示浮窗也画在这块叠层上，但它**不点亮** [BufferingState.visible]
        //（那是转圈 / 进度预览那一层的闸门）—— 只是把实体留住，别在拖到一半时被销毁。
        val keepAlive = want || (stageSwipeDragging && onScreen)
        if (keepAlive) {
            bufferingDestroyAt = 0L
            if (bufferingEntity == null) createBufferingEntity()
            bufferingState.visible = want
        } else if (bufferingEntity != null) {
            if (bufferingState.visible) {
                bufferingState.visible = false
                bufferingDestroyAt = now + BUFFERING_ANIM_MS + 40L
            } else {
                // 只为浮窗留着的那种：这里才起算销毁倒计时（等浮窗自己的退场播完）。
                if (bufferingDestroyAt == 0L) bufferingDestroyAt = now + BUFFERING_ANIM_MS + 40L
                if (now >= bufferingDestroyAt) destroyBufferingEntity()
            }
        }
    }

    private fun createBufferingEntity() {
        bufferingFrozenPose = null
        val e = Entity.create(
            Panel(R.id.vr_buffering_panel),
            Transform(bufferingPose()),
            Visible(true),
            // 叠在幕布上的一整块透明面板：不许挡射线（ALPHA_BLEND 的透明区照样是命中面），
            // 否则缓冲期间幕布抓不到、光标也被它截住。
            Hittable(MeshCollision.NoCollision),
        )
        bufferingEntity = e
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(e)?.thenAccept { so ->
            val panel = so as? PanelSceneObject
            bufferingPanel = panel
            runCatching { panel?.layer?.setZIndex(Z_BUFFERING) }
        }
    }

    private fun destroyBufferingEntity() {
        bufferingEntity?.destroy()
        bufferingEntity = null
        bufferingPanel = null
        bufferingFrozenPose = null
        bufferingDestroyAt = 0L
        bufferingState.visible = false
    }

    /** 平幕上的缓冲指示跟着幕布走（用户可能正抓着挪）；球幕的定死不动。 */
    private fun syncBufferingPose() {
        if (!controls.format.isFlat) return
        bufferingEntity?.setComponent(Transform(bufferingPose()))
    }

    // ================================================================ 控制面板

    private fun showControls(summoned: Boolean = false) {
        if (stageActive && !screenShown) {
            pendingShowControls = true
            return
        }
        lastInteractionAt = SystemClock.uptimeMillis()
        if (controlsEntity != null) return
        val saved = lastControlsPose
        val restore = saved != null && (!summoned || !controls.summonInFront || isRoughlyInFront(saved))
        val pose = if (restore) {
            trackedHeadPose()?.let { SpatialPlacement.facingSurface(saved!!, it) } ?: saved!!
        } else controlsPoseInFront()
        val entity = Entity.create(
            Panel(R.id.vr_controls_panel),
            Transform(pose),
            Visible(true),
            // 用户上次拉角拉到的大小：整块等比缩放（与 ISDK 的 Simple 模式同一机制，只是把手换成我们自己的窗框）。
            Scale(Vector3(controlsScale, controlsScale, 1f)),
        )
        controlsEntity = entity
        controlsBasePose = pose
        controlsHovered = false
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            if (controlsEntity != entity) return@thenAccept
            so.addInputListener(hoverListener)
            val panel = so as? PanelSceneObject
            controlsPanel = panel
            runCatching { panel?.layer?.setZIndex(Z_CONTROLS) }
            entity.tryGetComponent<Transform>()?.transform?.let { current ->
                panel?.setPosition(current.t)
                panel?.setRotationQuat(current.q)
            }
        }
        manipulator.attach(controlsHost)
        Log.i(TAG, "IMMERSIVE controls panel created summoned=$summoned restored=$restore")
    }

    /**
     * 收起控制面板：先隐身、隔 [DOOMED_TICKS] 帧再真销毁。
     *
     * 直接销毁时 ISDK 来不及清掉这块面板的悬停/命中态，光标会继续被一块已不存在的面板挡住
     * （真机反馈：自动收起后光标仍被面板遮挡）。隐身一两帧让它先从命中里退出。
     */
    private fun hideControls() {
        viewDistanceDirection = 0
        endUiPanelHold()
        pendingShowControls = false
        val entity = controlsEntity ?: return
        (controlsBasePose ?: entity.tryGetComponent<Transform>()?.transform)?.let { lastControlsPose = it }
        controlsBasePose = null
        manipulator.detach(WindowKind.CONTROLS)
        entity.setComponent(Visible(false))
        controlsDoomed?.destroy()
        controlsDoomed = entity
        controlsDoomedTicks = DOOMED_TICKS
        controlsEntity = null
        controlsPanel = null
        controlsHovered = false
        controls.volumePopupOpen = false
        controls.route = ControlsRoute.PLAYER
    }

    private fun reapDoomedControls() {
        val doomed = controlsDoomed ?: return
        if (--controlsDoomedTicks > 0) return
        doomed.destroy()
        controlsDoomed = null
    }

    // ================================================================ 三块窗（抓 / 挪 / 缩放的宿主）

    /** 幕布：位置记弧面中心，尺寸走 `screenWidth` → reshape 流水线。 */
    private val screenHost = object : WindowHost {
        override val kind = WindowKind.SCREEN
        override val resizePolicy = ResizePolicy.ASPECT_LOCKED
        override val minSize get() = Vector2(SCREEN_MIN_WIDTH_M, SCREEN_MIN_WIDTH_M / curAspect)
        override val maxSize get() = Vector2(SCREEN_MAX_WIDTH_M, SCREEN_MAX_WIDTH_M / curAspect)
        override val zIndex = Z_SCREEN

        override fun surfacePose(): Pose? {
            if (!screenShown || screenEntity == null || !controls.format.isFlat || !screenEntityIsFlat) return null
            return screenSurfacePose()
        }

        override fun size() = Vector2(curWidth, curWidth / curAspect)
        override fun arcDegrees() = if (curArc >= ScreenGeometry.MIN_ARC_DEGREES) curArc else 0f

        override fun moveTo(surface: Pose) {
            screenSurfaceOverride = surface
            applyScreenTransform()
        }

        override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) {
            screenSurfaceOverride = surface
            // 空间画廊里拉的是图片的实际宽，设置里记的是「盒子」宽（见 targetScreenWidth）。
            controls.screenWidth = (size.x / galleryFitFactor()).coerceIn(SCREEN_MIN_WIDTH_M, SCREEN_MAX_WIDTH_M)
            animating = false
            curWidth = targetScreenWidth(curAspect)
            reshapeNow()
            if (commit) {
                markPrefsDirty()
                rememberLayoutForAspect()
            }
        }

        override fun onInteraction() {
            lastInteractionAt = SystemClock.uptimeMillis()
        }

        /** 抓握扳机拖完幕布松手 = 顺手把操作栏收起（用户 2026-09-05）。扳机 / 捏合按在窗框上挪的不收。 */
        override fun onMoveReleased(byGrip: Boolean) {
            rememberLayoutForAspect()
            if (!byGrip || controlsEntity == null) return
            Log.i(TAG, "IMMERSIVE controls hidden after grip drag")
            hideControls()
        }
    }

    /** 控制面板：等比缩放（`Scale`），位置直接写实体。 */
    private val controlsHost = object : WindowHost {
        override val kind = WindowKind.CONTROLS
        override val resizePolicy = ResizePolicy.ASPECT_LOCKED
        override val minSize = Vector2(CONTROLS_WIDTH_M * CONTROLS_MIN_SCALE, CONTROLS_HEIGHT_M * CONTROLS_MIN_SCALE)
        override val maxSize = Vector2(CONTROLS_WIDTH_M * CONTROLS_MAX_SCALE, CONTROLS_HEIGHT_M * CONTROLS_MAX_SCALE)
        // 面板整只是等比 `Scale` 放大的，圆角在世界里也跟着放大 —— 不乘这一下，放大之后窗框的角会明显小一圈。
        override fun cornerRadiusM() = Vector2(CONTROLS_CORNER_M * controlsScale, CONTROLS_CORNER_M * controlsScale)
        override val zIndex = Z_CONTROLS

        override fun surfacePose(): Pose? = controlsEntity?.tryGetComponent<Transform>()?.transform
        override fun size() = Vector2(CONTROLS_WIDTH_M * controlsScale, CONTROLS_HEIGHT_M * controlsScale)

        override fun moveTo(surface: Pose) {
            controlsEntity?.setComponent(Transform(surface))
            controlsPanel?.let { it.setPosition(surface.t); it.setRotationQuat(surface.q) }
            lastControlsPose = surface
            controlsBasePose = surface
        }

        override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) {
            controlsScale = (size.x / CONTROLS_WIDTH_M).coerceIn(CONTROLS_MIN_SCALE, CONTROLS_MAX_SCALE)
            val scale = Vector3(controlsScale, controlsScale, 1f)
            controlsEntity?.setComponent(Scale(scale))
            controlsPanel?.setScale(scale)
            moveTo(surface)
            if (commit) {
                prefs.controlsScale = controlsScale
                markPrefsDirty()
            }
        }

        override fun onInteraction() {
            lastInteractionAt = SystemClock.uptimeMillis()
        }
    }

    /**
     * 2D 应用面板：自由拉。拖动中只 `Scale`（像素不变、先拉伸），松手 `resize(px)` 让 Flutter 按新像素重排，
     * `Scale` 留着 —— 像素与米同比变，dp/m 不变，字不会跟着变大（与 ISDK Relayout 同一机制）。
     */
    private val uiHost = object : WindowHost {
        override val kind = WindowKind.UI
        override val resizePolicy = ResizePolicy.FREE
        override val minSize = Vector2(UI_PANEL_MIN_WIDTH_M, UI_PANEL_MIN_HEIGHT_M)
        override val maxSize = Vector2(UI_PANEL_MAX_WIDTH_M, UI_PANEL_MAX_HEIGHT_M)
        // ⛔ 分轴乘 uiScale：拖角的过程中面板是被非等比 `Scale` 抻着的（松手才按新像素重排），
        // 那期间 Flutter 裁出来的 20dp 圆角本来就是椭圆 —— 窗框照这个椭圆画才贴得住。
        override fun cornerRadiusM() = Vector2(UI_PANEL_CORNER_M * uiScale.x, UI_PANEL_CORNER_M * uiScale.y)
        override val zIndex = Z_UI

        override fun surfacePose(): Pose? =
            if (!uiPlacement.shown || uiPanelEntity == null) null else uiSurfacePose

        override fun size() = Vector2(uiBaseSize.x * uiScale.x, uiBaseSize.y * uiScale.y)

        // 微曲面：弧度定死，半径随宽度走（见 [uiPanelMeshRadius]）。窗框、射线命中、拉角平面全读这一份。
        override fun arcDegrees() = UI_PANEL_ARC_DEGREES

        override fun moveTo(surface: Pose) {
            uiPlacement.moved()
            applyUiPanelPose(surface)
        }

        /**
         * 用手抓着把窗挪完松手，也要记住新的远近 —— 否则「下次打开恢复上次的位置」只对
         * 菜单里那三条成立，抓着挪的人下次进来面板又回到默认档。
         *
         * 只记**距离**：方位与朝向每次都按当时的视线重新算（见 [uiPanelPose]），
         * 存一份世界坐标会让人换个方向坐下之后面板出现在身后。
         */
        override fun onMoveReleased(byGrip: Boolean) {
            rememberUiPanelDistance()
        }

        // `PanelSceneObject.resize` 在 0.13.2 里标着 experimental；ISDK 自己的 Relayout 走的就是它。
        @OptIn(com.meta.spatial.core.SpatialSDKExperimentalAPI::class)
        override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) {
            uiScale = Vector2(size.x / uiBaseSize.x, size.y / uiBaseSize.y)
            // ⛔ 微曲面的面板不能用 `Scale` 拉：SDK 的圆柱层不把它当几何缩放 —— 只把宽度从
            // 1.49 拉到 2.4 米（高不变），面板就等比放大了三四倍并冲到眼前（真机 2026-09-09）。
            // 改成和幕布一样 reshape 圆柱形状：半径随宽度、弧度不变；像素画布拖动中被拉伸，
            // 松手后由下面的 resize(px) 让 Flutter 按新像素重排（resize 保留 reshape 过的几何）。
            uiPanel?.let { panel ->
                runCatching {
                    panel.reshape(uiPanelSettings(size).toPanelConfigOptions())
                    // reshape 重建合成层，层序不保留（与幕布 / 窗框同一件事）。
                    panel.layer?.setZIndex(Z_UI)
                }.onFailure { Log.w(TAG, "IMMERSIVE ui panel reshape 失败", it) }
            }
            moveTo(surface)
            syncIsdkUiShape()
            if (!commit) return
            val px = (size.x * UI_DP_PER_METER * UI_PANEL_DPI / 160f).roundToInt()
            val py = (size.y * UI_DP_PER_METER * UI_PANEL_DPI / 160f).roundToInt()
            runCatching { uiPanel?.resize(px, py) }
                .onFailure { Log.w(TAG, "IMMERSIVE ui panel resize 失败", it) }
            prefs.uiPanelWidth = size.x
            prefs.uiPanelHeight = size.y
            markPrefsDirty()
            Log.i(TAG, "IMMERSIVE ui panel relayout ${size.x}x${size.y}m px=${px}x$py")
        }
    }

    private val hoverListener = object : InputListener {
        override fun onHoverStart(sceneObject: SceneObject, entity: Entity) {
            controlsHovered = true
        }

        override fun onHoverStop(sceneObject: SceneObject, entity: Entity) {
            controlsHovered = false
        }

        override fun onClickDown(sceneObject: SceneObject, hitInfo: HitInfo, entity: Entity) {
            lastPanelTouchAt = SystemClock.uptimeMillis()
        }
    }

    // ================================================================ 每帧

    override fun onSceneTick() {
        super.onSceneTick()
        val now = SystemClock.uptimeMillis()
        mediaEffects.tickBackground(now)
        syncMediaEffects()
        updateTransport()
        status.clockTextIfChanged(System.currentTimeMillis())?.let { controls.clockText = it }
        if (!inputSuspended) {
            input.poll()
            settleHeadPlacement()
            manipulator.tick(input)
            // Back is navigation: it must still work while media is awaiting head placement.
            if (input.events.back) handleBackInput()
            else if (stageActive && screenShown) handleInput(now)
            else if (!stageActive) handleBrowseInput(now)
        }
        tickGallery(now)
        syncControlsDepth()
        reapDoomedControls()
        updateAutoHide(now)
        // 缓冲指示：延迟露面 / 退场后销毁，都按帧走；平幕上还要跟着幕布挪。
        syncBufferingIndicator()
        if (bufferingEntity != null) syncBufferingPose()
        if (playlistWaitUntil != 0L && now >= playlistWaitUntil) {
            Log.w(TAG, "IMMERSIVE playlist request timed out")
            clearPlaylistWait()
        }
        if (switchWaitUntil != 0L && now >= switchWaitUntil) {
            Log.w(TAG, "IMMERSIVE switch timed out")
            playback.cancelPreload()
            clearSwitchWait(resumeOldVideo = true)
            controls.notice = text(UiR.string.xr_notice_next_timeout)
        }
        if (sourceRefreshUntil != 0L && now >= sourceRefreshUntil) {
            Log.w(TAG, "IMMERSIVE source refresh timed out")
            sourceRefreshUntil = 0L
            controls.buffering = false
            controls.notice = text(UiR.string.xr_notice_refresh_timeout)
            showControls(summoned = true)
        }
        if (animating) stepShapeAnimation(now)
        if (resumeTipUntil != 0L && now >= resumeTipUntil) hideResumeTip()
        if (prefsDirty && now >= prefsFlushAt) {
            prefsDirty = false
            prefs.save(controls)
        }
    }

    /**
     * 首次进入时头部位姿往往还没就绪，摆位只能落到兜底值（站姿眼高、朝 +Z）——
     * 用户看到的就是「2D 画面位置过于靠上」。头部一就绪就按真实视线重摆一次。
     */
    private fun settleHeadPlacement() {
        headReadiness.update(headPose())
        val ready = headTrackingReady()
        if (!ready && !headSettleTimedOut()) return
        if (!stageActive) {
            if (uiPlacement.shouldSettle(ready, headSettleTimedOut())) placeUiPanel(visible = true)
        } else if (anchorIsFallback && (ready || !screenShown)) {
            cancelSpatialInteractions()
            captureAnchor()
            screenSurfaceOverride = null
            screenShown = true
            screenEntity?.setComponent(Visible(true))
            applyScreenTransform()
            if (controlsEntity != null) {
                val pose = controlsPoseInFront()
                controlsBasePose = pose
                controlsEntity?.setComponent(Transform(pose))
                controlsPanel?.let { it.setPosition(pose.t); it.setRotationQuat(pose.q) }
            }
            if (pendingShowControls) {
                pendingShowControls = false
                showControls()
            }
        }
    }

    /**
     * 起播 / 换片时把轨道清零。⛔ 进度与**缓冲段**必须一起清：只清进度的话，新片起播那一瞬
     * 轨道上还挂着老片缓冲了多长，看起来像是「新片瞬间就缓冲了一半」。
     */
    private fun resetTrackUi() {
        controls.progress = 0f
        controls.buffered = 0f
        bufferingState.scrubBuffered = 0f
    }

    private fun updateTransport() {
        if (!playback.isAlive) return
        if (controls.isPlaying != playback.isPlaying) controls.isPlaying = playback.isPlaying
        // ⛔ 缓冲段在 seeking 之前写：拖进度时最该看见的就是「拖过去要不要重等」，
        // 那一段与用户按住不放无关（下面那个 return 只是为了别把拖到一半的位置写回去）。
        val total = playback.durationMs
        if (total > 0) {
            val b = (playback.bufferedMs.toFloat() / total).coerceIn(0f, 1f)
            if (controls.buffered != b) controls.buffered = b
            if (bufferingState.scrubBuffered != b) bufferingState.scrubBuffered = b
        }
        if (seeking) return
        val dur = playback.durationMs
        if (dur > 0) {
            controls.progress = (playback.positionMs.toFloat() / dur).coerceIn(0f, 1f)
            controls.positionText = formatMs(playback.positionMs)
            controls.durationText = formatMs(dur)
        }
    }

    /** ⛔ 只在影院态（有片源）：浏览态里捏合是操作 Flutter 面板的，抢不得。 */
    private fun handleInput(now: Long) {
        val seconds = if (lastMotionAt == 0L) 0f else ((now - lastMotionAt) / 1000f).coerceIn(0f, 0.05f)
        lastMotionAt = now
        val e = input.events
        for (i in 0..1) {
            val bit = 1 shl i
            if ((e.selectDown and bit) != 0) onSelectDown(i, now)
            if ((e.selectUp and bit) != 0) onSelectUp(i, now)
        }
        // 抓握扳机按下就抓幕布拖，不用瞄准（用户 2026-09-05）。manipulator.tick 已先跑过：瞄在控制面板 / 窗框上的
        // 那只手已经开了会话（isBusy），这里不抢；球幕没有幕布可抓。
        updateSphereGrab(now)
        // 两手一起抓（双抓握扳机 / 双捏合按住）= 拉开缩放幕布，不用瞄角（用户 2026-09-05：只能靠拖窗角放大缩小）。
        updateTwoHandScale(now)
        // ⛔ 两手缩放期间否决横拖：图片幕布那块 Compose **只看得见其中一枚指针**（Quest 上两只手柄
        // 不是两枚 Compose 指针，§19 续十二·第三轮实测），它自己判不出「这是在缩放不是在横拖」——
        // 不写这一条，两手放大时下面就一直长着翻页进度条（用户 2026-09-06）。
        stage.swipe.blocked = twoHandScaling
        bufferingState.swipe.blocked = twoHandScaling
        // 按在**视频**画面上横拖 = 攒「上一条 / 下一条」的幅度（画面不动，只浮预示）。
        updateStageSwipe(now)
        for (i in 0..1) {
            val bit = 1 shl i
            if ((e.gripDown and bit) != 0 && !twoHandScaling && !manipulator.isBusy(i) && screenEntity != null && sphereGrabHand < 0) {
                if (controls.format.isFlat) manipulator.startGrab(i, WindowKind.SCREEN, input) else startSphereGrab(i, now)
            }
        }
        // ⛔ 射线悬在面板上时 A 键是给面板的（ISDK 把它当点击送进去），这里再切一次播放/暂停就穿透了
        // （用户 2026-09-05：「用 A 键点操作栏，画面跟着暂停」）。扳机那条路早就这么判了（onSelectDown）。
        if (e.primaryTap && controls.controllerTapPlayPause && !controlsHovered) controlsCallbacks.onPlayPause()
        // Only the stick belonging to the hand pointing at the panel scrolls that panel.
        // A resting second pointer must not swallow the active controller's seek/distance input.
        val stick = e.stickForHands(controlsPointerHands().inv())
        // 摇杆左右：空间画廊里 = 上一张 / 下一张（按住连翻）；视频 = 按住拖动进度、越久越快，松开那一刻才 seek。
        if (inGallery) {
            handleGalleryStick(now, stick)
        } else {
            when {
                stick.left != stick.right -> updateScrub(now, forward = stick.right)
                scrubbing -> commitScrub()
            }
        }
        if (e.menu) {
            showControls(summoned = true)
            controls.route = ControlsRoute.SETTINGS
        }
        if (!stageActive || !screenShown) return
        if (viewDistanceDirection != 0 && (!input.anyActive || controlsEntity == null || controls.route != ControlsRoute.DISTANCE)) {
            viewDistanceDirection = 0
        }
        if (viewDistanceDirection != 0) {
            adjustViewDistance(viewDistanceDirection, seconds)
        } else if (twoHandScaling) {
            // 两手缩放中摇杆不管别的。
        } else if (inGallery && stagePressed && screenIsImage && (stick.up != stick.down)) {
            // 指着图片按住扳机 / 捏合，再推摇杆上下 = 以指着的那一点为原点缩放内容（放大镜）。
            stage.zoomAtPress(if (stick.up) STICK_ZOOM_STEP else 1f / STICK_ZOOM_STEP)
            lastInteractionAt = now
        } else if (manipulator.isMoving) {
            // 抓着窗的时候摇杆上下归它：推远 / 拉近（正抓着窗，射线扫到面板上也算它的）。
            nudgeGrabbedWindows()
        } else if (stick.up != stick.down && screenEntity != null) {
            // 不抓也能推远 / 拉近（用户 2026-09-05：「往前推往后推控制播放器离我的远近」，全景片也要）。
            // 摇杆不再管音量：音量在面板的 🔊 弹层里。
            adjustViewDistance(if (stick.up) 1 else -1, seconds)
        }
    }

    /** B/Y returns exactly one level, independently of whether a screen is visible yet. */
    private fun handleBackInput() {
        if (!stageActive) {
            // 浏览态也可能有面板（[ControlsRoute.BROWSE]）：先收它，再让 B/Y 回到应用的返回键。
            if (controlsEntity != null) {
                popPanelOrHide()
                return
            }
            Log.i(TAG, "IMMERSIVE back button -> MainActivity back")
            ImmersiveBridge.requestBack()
        } else if (controlsEntity != null) {
            popPanelOrHide()
        } else {
            Log.i(TAG, "IMMERSIVE back button -> back to app")
            backToApp()
        }
    }

    /** Browsing input stays with ISDK except for moving an explicitly grabbed window. */
    private fun handleBrowseInput(now: Long) {
        nudgeGrabbedWindows()
        tickUiPanelHold(now)
    }

    private fun nudgeGrabbedWindows() {
        for (hand in 0..1) {
            if (!manipulator.isMoving(hand)) continue
            val mask = 1 shl hand
            val stick = input.events.stickForHands(mask)
            if (stick.up != stick.down) {
                manipulator.nudgeDistance(if (stick.up) NUDGE_STEP else -NUDGE_STEP, hands = mask)
            }
        }
    }

    /**
     * 「选择」按下：在面板上就是操作面板，否则记为「点一下」候选，等松开裁决。
     * 捏住移动（拖面板 / 拖幕布 / 拉角缩放）走 ISDK，不会到达 toggle。
     *
     * # ⛔ 判据只能是「本次手势的、这只手的」证据
     *
     * 这里原先还看 [controlsHovered]，而那是一个**不分手、只进不出**的全局标志
     * （另一只手的射线歇在面板上就恒为真；ISDK 的 onHoverStop 也未必可靠，见记忆
     * `xr-hover-never-exits`）。真机症状：面板**只能召唤、无法隐藏**（用户 2026-09-05）。
     * 现在按下只挡「这只手正被 WindowManipulator 占着」，落没落在面板上一律留到松开时
     * 用 [lastPanelTouchAt]（已收窄成**仅按下**）裁决。
     */
    private fun onSelectDown(hand: Int, now: Long) {
        // 按在窗框上已经被 WindowManipulator 接走（抓窗），那不是「点一下」。
        if (manipulator.isBusy(hand)) {
            lastInteractionAt = now
            tapCandidate[hand] = false
            return
        }
        tapCandidate[hand] = true
        tapDownAt[hand] = now
        tapDownPos[hand] = input.handPositions[hand]
        beginStageSwipe(hand, now)
    }

    /**
     * Hands whose current rays hit the controls. Keep ownership through stick routing.
     * ⛔ 不用 [controlsHovered]：那是 ISDK 报的、**只进不出**的全局标志（记忆 `xr-hover-never-exits`），
     * 拿它当闸门会时灵时不灵。这里与幕布横拖同一条路：射线 × 窗面自己算，每帧新鲜。
     */
    private fun controlsPointerHands(): Int {
        if (controlsEntity == null) return 0
        val surface = controlsHost.surfacePose() ?: return 0
        val size = controlsHost.size()
        val arc = controlsHost.arcDegrees()
        var hands = 0
        for (hand in 0..1) {
            if (manipulator.surfaceHit(hand, input, surface, size, arc) != null) hands = hands or (1 shl hand)
        }
        return hands
    }

    private fun pointerOnControls(hand: Int? = null): Boolean =
        controlsPointerHands() and (hand?.let { 1 shl it } ?: 0b11) != 0

    /**
     * 面板上的「返回一层」。手柄 B/Y 与面板自己那枚返回钮走同一套层次：
     *
     * 1. 音量 / 倍速那类浮层开着 → 先关浮层；
     * 2. 播放列表里展开着分组 → 先收回分组行（与页内那枚「‹ 全部」同义）；
     * 3. 停在子页（场景 / 屏幕类型 / 视频类型 / 列表 / 设置）→ 回主页（各页 `PageHeader.onBack`）；
     * 4. 已经在主页 → 才收面板。
     */
    private fun popPanelOrHide() {
        when {
            controls.volumePopupOpen -> controls.volumePopupOpen = false
            controls.route == ControlsRoute.PLAYLIST && controls.expandedGroupId != null ->
                controls.expandedGroupId = null
            // 浏览态那一页身下没有播放页可回，「返回一层」就是收面板。
            controls.route == ControlsRoute.BROWSE -> {
                hideControls()
                return
            }
            controls.route != ControlsRoute.PLAYER -> controls.route = ControlsRoute.PLAYER
            else -> {
                hideControls()
                return
            }
        }
        touched()
        Log.i(TAG, "IMMERSIVE back button -> panel back route=${controls.route}")
    }

    private fun notePanelPress() {
        val now = SystemClock.uptimeMillis()
        lastPanelTouchAt = now
        lastInteractionAt = now
    }

    private fun onSelectUp(hand: Int, now: Long) {
        // ⛔ 在 tapCandidate 那道早退**之前**：真拖过的那一次已经把 tapCandidate 清了。
        endStageSwipe(hand)
        if (!tapCandidate[hand]) return
        tapCandidate[hand] = false
        val held = now - tapDownAt[hand]
        val from = tapDownPos[hand]
        val to = input.handPositions[hand]
        val moved = if (from != null && to != null) from.distanceTo(to) else 0f
        if (held > TAP_MAX_MS || moved > TAP_MAX_MOVE_M) return
        // 这一次按下有没有落进面板：面板 Compose 的**按压**上报（onPanelPressed）在按下那一刻就到了。
        if (lastPanelTouchAt >= tapDownAt[hand] - 60L) {
            lastInteractionAt = now
            return
        }
        if (controlsEntity == null) {
            showControls(summoned = true)
        } else {
            Log.i(TAG, "IMMERSIVE controls hidden by outside tap")
            hideControls()
        }
    }

    /**
     * 摇杆按住拖动进度：每帧按「这个方向已按了多久」取一个速率累加目标点，松开才真 seek（[commitScrub]）。
     * 刚推上去先走一格 [SCRUB_TAP_MS]（一下 = ±5 秒），再按 [scrubRateMsPerSec] 加速到分 / 小时量级。
     * 预览三处同步：幕布叠层（目标时间 + 增量 + 细进度）、面板进度条 / 预览时间、[seeking] 挡住 transport 回写。
     */
    private fun updateScrub(now: Long, forward: Boolean) {
        if (controls.switching || !playback.isAlive) return
        val dur = playback.durationMs
        if (dur <= 0L) return
        val dir = if (forward) 1 else -1
        if (!scrubbing) {
            scrubbing = true
            scrubBaseMs = playback.positionMs
            scrubTargetMs = scrubBaseMs
            scrubDir = 0
            seeking = true
            touched()
        }
        var step = 0L
        if (dir != scrubDir) {
            scrubDir = dir
            scrubDirSince = now
            scrubLastAt = now
            step = SCRUB_TAP_MS
        }
        val held = now - scrubDirSince
        val dt = (now - scrubLastAt).coerceIn(0L, 100L)
        scrubLastAt = now
        step += scrubRateMsPerSec(held) * dt / 1000L
        scrubTargetMs = (scrubTargetMs + dir * step).coerceIn(0L, dur)
        val delta = scrubTargetMs - scrubBaseMs
        controls.progress = (scrubTargetMs.toFloat() / dur).coerceIn(0f, 1f)
        controls.seekPreviewText = formatMs(scrubTargetMs)
        bufferingState.scrubText = formatMs(scrubTargetMs)
        bufferingState.scrubDeltaText = (if (delta >= 0) "+" else "−") + formatMs(abs(delta))
        bufferingState.scrubProgress = controls.progress
        lastInteractionAt = now
    }

    /** Use the current eyes and visible center even when the screen has never been grabbed. */
    private fun nudgeScreenDistance(delta: Float) {
        val viewer = trackedHeadPose() ?: currentAnchor()
        val distance = (screenSurfacePose().t - viewer.t).length()
        if (distance < 0.05f) return
        setScreenDistance(distance * (1f + delta))
        lastInteractionAt = SystemClock.uptimeMillis()
    }

    private fun adjustViewDistance(direction: Int, seconds: Float) {
        if (controls.format.isFlat) {
            nudgeScreenDistance(ViewDistanceMotion.flatFactor(direction, seconds) - 1f)
        } else {
            nudgeSphereDistance(ViewDistanceMotion.sphereDelta(direction, seconds))
        }
    }

    /** Slider, stick, and distance reset preserve the current bearing and face the current eyes. */
    private fun setScreenDistance(meters: Float) {
        val next = meters.coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M)
        val viewer = trackedHeadPose() ?: currentAnchor()
        screenSurfaceOverride = SpatialPlacement.atDistance(screenSurfacePose(), viewer, next)
        controls.screenDistance = next
        applyScreenTransform()
        markPrefsDirty()
        rememberLayoutForAspect()
    }

    // ================================================================ 距离 / 幕宽按画面比例记忆

    /** 当前画面比例的键（两位小数）：与 [ScreenGeometry.screenAspect] 同口径（含宽高比预设与宽比 / 长比）。 */
    private fun aspectKey(): String = "%.2f".format(ScreenGeometry.screenAspect(controls, videoWidth, videoHeight))

    /** 这条片子已经按哪个比例键恢复过布局；换片清空。避免用户调整后又被同一份记录盖回去。 */
    private var layoutAppliedForKey: String? = null

    /**
     * 放到一个新比例的画面：把这个比例上次调过的观看距离 / 幕宽恢复回来（用户 2026-09-05：
     * 「切换其他尺寸视频再切回来，能自动恢复之前调好的距离和大小」）。没记过就沿用当前值。
     */
    private fun applyLayoutForAspect() {
        if (!controls.format.isFlat || inGallery) return
        val key = aspectKey()
        if (key == layoutAppliedForKey) return
        layoutAppliedForKey = key
        val saved = prefs.layoutFor(key) ?: return
        controls.screenDistance = saved[0].coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M)
        controls.screenWidth = saved[1].coerceIn(SCREEN_MIN_WIDTH_M, SCREEN_MAX_WIDTH_M)
        // 距离按锚点视线重摆：拖过的位置只对拖它那条片子有意义。
        screenSurfaceOverride = null
        Log.i(TAG, "IMMERSIVE layout restored aspect=$key distance=${saved[0]} width=${saved[1]}")
    }

    /** 用户刚调过距离 / 幕宽（摇杆 / 滑块 / 抓着拖 / 拉角）：按当前画面比例记一份。 */
    private fun rememberLayoutForAspect() {
        if (!controls.format.isFlat || screenEntity == null || inGallery) return
        val key = aspectKey()
        val override = screenSurfaceOverride
        val distance = if (override != null) {
            val head = trackedHeadPose()?.t ?: currentAnchor().t
            (override.t - head).length().takeIf { it >= 0.05f } ?: controls.screenDistance
        } else {
            controls.screenDistance
        }
        layoutAppliedForKey = key
        prefs.rememberLayout(key, distance.coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M), controls.screenWidth)
        markPrefsDirty()
    }

    /**
     * 球幕推远 / 拉近：球心沿球幕前向离开 / 靠近头部。球半径 50m，偏到 ±25m 时正前方画面的张角变化已经很明显；
     * 3D 片偏得越多双眼视差越失真，这是用户要的取舍。
     */
    private fun nudgeSphereDistance(deltaM: Float) {
        sphereOffsetM = (sphereOffsetM + deltaM).coerceIn(-SPHERE_OFFSET_MAX_M, SPHERE_OFFSET_MAX_M)
        applyScreenTransform()
        lastInteractionAt = SystemClock.uptimeMillis()
    }

    /**
     * 球幕拖视角：抓握扳机按住，手柄转多少球幕就转多少（偏航 + 俯仰，去 roll），像抓着球壳转。
     * 起点记射线方向与此刻的球幕前向，每帧用两帧去 roll 射线坐标系之差转前向，再按 [sphereQuatFor] 重新搭正交基
     * （不累积 roll，地平线始终水平）。
     */
    private fun startSphereGrab(hand: Int, now: Long) {
        val ray = manipulator.ray(hand, input) ?: return
        sphereGrabHand = hand
        sphereGrabRay0 = ray.direction
        sphereGrabForward0 = spherePose().forward()
        lastInteractionAt = now
        Log.i(TAG, "IMMERSIVE sphere grab hand=$hand")
    }

    private fun updateSphereGrab(now: Long) {
        val hand = sphereGrabHand
        if (hand < 0) return
        if (!input.gripHeld[hand]) {
            endSphereGrab(hideControls = true)
            return
        }
        val ray = manipulator.ray(hand, input) ?: return
        val up = trackedHeadPose()?.up() ?: Vector3(0f, 1f, 0f)
        val q0 = frameAlong(ray.origin, sphereGrabRay0, up, dropDeg = 0f).q
        val q1 = frameAlong(ray.origin, ray.direction, up, dropDeg = 0f).q
        val delta = q1 * q0.inverse()
        sphereForwardOverride = clampPitch((delta * sphereGrabForward0).normalize())
        applyScreenTransform()
        lastInteractionAt = now
    }

    /** 俯仰夹在 ±[SPHERE_MAX_PITCH_SIN]（约 80°）内：再往上就翻过头顶，180 半球会整个转到身后。保持水平方向不变。 */
    private fun clampPitch(f: Vector3): Vector3 {
        if (abs(f.y) <= SPHERE_MAX_PITCH_SIN) return f
        val y = if (f.y > 0f) SPHERE_MAX_PITCH_SIN else -SPHERE_MAX_PITCH_SIN
        val h = Vector3(f.x, 0f, f.z)
        val hLen = h.length()
        val hTarget = sqrt(1f - y * y)
        return if (hLen < 1e-4f) Vector3(0f, y, -hTarget) else Vector3(h.x / hLen * hTarget, y, h.z / hLen * hTarget)
    }

    /** 松开抓握扳机：与平幕拖完一样顺手收操作栏；被换片 / 回应用打断时不收。 */
    private fun endSphereGrab(hideControls: Boolean) {
        if (sphereGrabHand < 0) return
        sphereGrabHand = -1
        Log.i(TAG, "IMMERSIVE sphere release forward=$sphereForwardOverride offset=$sphereOffsetM")
        if (hideControls && controlsEntity != null) hideControls()
    }

    /**
     * 按住越久越快：1s 内 15s/s，3s 内 1min/s，6s 内 5min/s，之后 15min/s（长片仍够按小时量级跳）。
     *
     * 每一档都是老值的一半（用户 2026-09-08：「各种效果都太快了」）：原来推住不到一秒就掠过半分钟，
     * 想停在某一句话上根本收不住手。
     */
    private fun scrubRateMsPerSec(heldMs: Long): Long = when {
        heldMs < 1_000L -> 15_000L
        heldMs < 3_000L -> 60_000L
        heldMs < 6_000L -> 300_000L
        else -> 900_000L
    }

    /** 松开摇杆：跳到目标点、收预览。 */
    private fun commitScrub() {
        if (!scrubbing) return
        val target = scrubTargetMs
        endScrub()
        playback.seekTo(target)
        Log.i(TAG, "IMMERSIVE scrub -> ${formatMs(target)} (from ${formatMs(scrubBaseMs)})")
    }

    /** 收掉拖动态但不 seek（换片 / 回应用 / 系统事件打断）。 */
    private fun endScrub() {
        if (!scrubbing) return
        scrubbing = false
        scrubDir = 0
        seeking = false
        controls.seekPreviewText = null
        bufferingState.scrubText = null
    }

    private fun updateAutoHide(now: Long) {
        if (!controls.autoHide || controlsEntity == null) return
        // 空间画廊：幻灯片在放才算「在放」；停着看一张图时面板留着（翻页钮就在上面）。
        val playing = controls.isPlaying || gallery?.slideshow == true
        if (!playing || controls.buffering ||
            controls.route != ControlsRoute.PLAYER || controls.volumePopupOpen || controlsHovered
        ) {
            lastInteractionAt = now
            return
        }
        if (now - lastInteractionAt < controls.autoHideSeconds * 1000L) return
        Log.i(TAG, "IMMERSIVE controls auto-hide after ${controls.autoHideSeconds}s idle")
        hideControls()
    }

    // ================================================================ 播放回调（PlaybackEngine.Listener）

    override fun onBuffering(buffering: Boolean) {
        runOnUiThread { controls.buffering = buffering }
    }

    override fun onReady() {
        runOnUiThread { logMemory("playing") }
    }

    override fun onEnded() {
        runOnUiThread {
            val g = gallery
            if (g != null) {
                // 图库里的短片播完：幻灯片开着就翻下一项；否则停在最后一帧（单条循环由 ExoPlayer 自己转，不会到这）。
                if (g.slideshow) galleryAdvanceForSlideshow()
                return@runOnUiThread
            }
            if (controls.repeatMode == RepeatMode.NEXT) {
                adjacentPlayable(forward = true)?.let { (queueId, item) -> playFromQueue(queueId, item.id) }
            }
        }
    }

    override fun onError(message: String, badHttpStatus: Boolean) {
        runOnUiThread {
            val url = argUrl
            val online = url != null && (url.startsWith("http://") || url.startsWith("https://"))
            if (badHttpStatus && online && videoId.isNotBlank() && !sourceRefreshRequested) {
                // 多半是直链 expires 到期（Iwara 过期回 404）：先向 Dart 要一份新地址，拿到就接着当前位置续播
                // （ExoPlayer 出错后位置与 playWhenReady 都留着），要不到 / 还是被拒才报错。只试一次。
                sourceRefreshRequested = true
                sourceRefreshUntil = SystemClock.uptimeMillis() + SOURCE_REFRESH_WAIT_MS
                controls.buffering = true
                controls.notice = text(UiR.string.xr_notice_url_expired_refreshing)
                ImmersiveBridge.requestSourceRefresh(videoId)
                Log.i(TAG, "IMMERSIVE bad http status -> ask Dart to refresh sources id=$videoId")
                return@runOnUiThread
            }
            controls.notice = text(UiR.string.xr_notice_playback_failed, message)
            showControls(summoned = true)
        }
    }

    override fun onVideoSize(width: Int, height: Int) {
        runOnUiThread {
            if (width == videoWidth && height == videoHeight) return@runOnUiThread
            videoWidth = width
            videoHeight = height
            // The processor output has fixed pixel dimensions. Recreate it for
            // unknown/adaptive sources while keeping the decoder and timeline.
            if (screenUsesProcessedVideo) {
                rebuildScreen(keepPlayback = true)
                return@runOnUiThread
            }
            // 真实尺寸到了才知道单眼比例：先恢复这个比例记住的距离 / 幕宽，再按它重塑幕布。
            applyLayoutForAspect()
            requestShape(0L)
        }
    }

    private fun startPlayback(surface: Surface) {
        val url = argUrl
        if (url.isNullOrBlank()) {
            Log.w(TAG, "IMMERSIVE 没有 url，只建场景不起播")
            return
        }
        if (argMute) controls.muted = true
        val started = playback.play(
            url = url, surface = surface, startPositionMs = pendingStartMs,
            muted = controls.muted, volume = controls.volume,
        )
        if (started) {
            // 从历史进度续播：面板上给一句提示 + 「从头开始」（与 2D 播放器同一套语义，只跳位置、不动历史记录）。
            if (pendingStartMs >= RESUME_TIP_MIN_MS) {
                controls.resumeTipText = text(UiR.string.xr_notice_resumed_at, formatMs(pendingStartMs))
                resumeTipUntil = SystemClock.uptimeMillis() + RESUME_TIP_MS
                // 让用户看得见这句话：起播时面板本来就会露面（rebuildScreen → showControls）。
                lastInteractionAt = SystemClock.uptimeMillis()
            }
            pendingStartMs = 0L
            controls.isPlaying = true
            resetTrackUi()
            controls.buffering = true
            playback.setSpeed(controls.speed)
            if (inGallery) playback.setRepeatOne(galleryRepeatOne()) else applyRepeatMode()
        }
    }

    private fun applyVolume() {
        playback.setVolume(if (controls.muted) 0f else controls.volume)
    }

    private fun applyRepeatMode() {
        playback.setRepeatOne(controls.repeatMode == RepeatMode.ONE)
    }

    private fun applyScene(immediate: Boolean = false) {
        runCatching { mediaEffects.setBackground(controls.mediaEffects, SystemClock.uptimeMillis(), immediate) }
            .onFailure { Log.w(TAG, "IMMERSIVE apply background failed", it) }
    }

    private fun markPrefsDirty() {
        prefsDirty = true
        prefsFlushAt = SystemClock.uptimeMillis() + PREFS_FLUSH_MS
    }

    /** 收起幕布与控制面板，把 UI 面板还回来。 */
    private fun backToApp() {
        endScrub()
        endSphereGrab(hideControls = false)
        playback.cancelPreload()
        clearSwitchWait()
        notifyEnded()
        exitGallery()
        argUrl = null
        nowPlayingId = null
        controls.nowPlayingId = null
        rebuildScreen()
    }

    private fun handOffToExternalPlayer() {
        val url = argUrl
        if (url.isNullOrBlank()) return
        val view = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse(url), "video/*")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        runCatching {
            startActivity(
                Intent.createChooser(view, text(UiR.string.xr_open_with))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }.onFailure {
            Log.w(TAG, "IMMERSIVE 转交外部播放器失败", it)
            controls.notice = text(UiR.string.xr_notice_no_external_player)
        }
    }

    /** 当前分区里、正在放的那条前后最近的一条可播项。 */
    private fun adjacentPlayable(forward: Boolean): Pair<String, ImmersivePlaylistItem>? {
        val section = activeSection ?: return null
        val items = section.items
        if (items.isEmpty()) return null
        val current = items.indexOfFirst { it.id == nowPlayingId }
        val step = if (forward) 1 else -1
        var i = if (current < 0) (if (forward) -1 else items.size) else current
        while (true) {
            i += step
            if (i < 0 || i >= items.size) return null
            if (items[i].playable) return section.queueId to items[i]
        }
    }

    /**
     * 点了「接着看」里的一条：那张卡转圈，老片暂停等着（面板进 Loading 态，见 [beginSwitch]）；
     * Dart 换页 → 新片 present → 预加载 → 就绪才换，失败把老片放回去。
     * ⛔ 不动 buffering、不动 playlistLoading：老片没在缓冲，列表也不该整块盖住。
     */
    private fun playFromQueue(queueId: String, id: String) {
        if (controls.switchingToId != null) return
        beginSwitch(id)
        ImmersiveBridge.requestPlayItem(queueId, id)
    }

    // ================================================================ 面板动作

    /** 面板上的每一次动作都先过这里：记一次交互时间 + 出一声（官方：手没有触觉，音效不是可选项）。 */
    private fun touched() {
        lastInteractionAt = SystemClock.uptimeMillis()
        if (!controls.clickSound) return
        runCatching {
            (getSystemService(AUDIO_SERVICE) as android.media.AudioManager)
                .playSoundEffect(android.media.AudioManager.FX_KEY_CLICK)
        }
    }

    private val controlsCallbacks = object : VideoControlsCallbacks {

        override fun onPlayPause() {
            // 空间画廊停在一张图上：播放 / 暂停 = 幻灯片开关（手柄 A 键走同一口）。视频项照常控制播放器。
            val g = gallery
            if (g != null && g.current?.isVideo != true) {
                onGalleryToggleSlideshow()
                return
            }
            // 换片在途：老片是我们暂停的，用户这一下不该把它放回去（面板上这枚钮也已禁用；手柄 A 键走同一口）。
            if (controls.switching) return
            touched()
            if (!playback.isAlive) return
            controls.isPlaying = playback.togglePlaying()
            pausedBySystem = false
        }

        override fun onSeek(value: Float) {
            if (controls.switching) return
            lastInteractionAt = SystemClock.uptimeMillis()
            seeking = true
            controls.progress = value
            val dur = playback.durationMs
            controls.seekPreviewText = if (dur > 0) formatMs((dur * value).toLong()) else null
        }

        override fun onSeekFinished() {
            if (controls.switching) return
            touched()
            val dur = playback.durationMs
            if (dur > 0) playback.seekTo((dur * controls.progress).toLong())
            seeking = false
            controls.seekPreviewText = null
        }

        override fun onSeekBy(seconds: Int) {
            if (controls.switching) return
            touched()
            playback.seekBy(seconds * 1000L)
        }

        override fun onPickSpeed(speed: Float) {
            touched()
            val s = PLAYBACK_SPEEDS.minByOrNull { abs(it - speed) } ?: 1f
            controls.speed = s
            playback.setSpeed(s)
            markPrefsDirty()
        }

        override fun onVolume(value: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.volume = value.coerceIn(0f, 1f)
            if (value > 0f) controls.muted = false
            applyVolume()
            markPrefsDirty()
        }

        override fun onToggleMute() {
            touched()
            controls.muted = !controls.muted
            applyVolume()
        }

        override fun onVolumePopup(open: Boolean) {
            touched()
            controls.volumePopupOpen = open
        }

        override fun onPickFormat(format: VideoFormat) {
            touched()
            val before = controls.format
            controls.format = format
            controls.formatTab = format.tab
            controls.notice = if (format.supported) {
                null
            } else {
                text(UiR.string.xr_notice_unsupported_projection)
            }
            if (before == format) return
            if (ScreenGeometry.sameFamily(before, format)) requestShape(0L) else {
                resetStagePlacement()
                rebuildScreen(keepPlayback = true)
            }
        }

        override fun onPickFormatTab(tab: FormatTab) {
            touched()
            controls.formatTab = tab
        }

        override fun onAutoDetectFormat() {
            touched()
            onPickFormat(ScreenGeometry.guessFormat(videoWidth, videoHeight))
        }

        override fun onToggleTreat180AsFisheye() {
            touched()
            controls.treat180AsFisheye = !controls.treat180AsFisheye
            markPrefsDirty()
        }

        override fun onHandOffToExternalPlayer() {
            touched()
            handOffToExternalPlayer()
        }

        override fun onPickCurve(curve: ScreenCurve) {
            touched()
            if (curve == controls.curve) return
            controls.curve = curve
            markPrefsDirty()
            requestShape(CURVE_ANIM_MS)
        }

        override fun onToggleForceMono() {
            touched()
            controls.forceMono = !controls.forceMono
            markPrefsDirty()
            if (controls.format.isStereo) requestShape(0L)
        }

        override fun onMediaEffects(settings: MediaEffectsSettings) {
            lastInteractionAt = SystemClock.uptimeMillis()
            val next = settings.normalized()
            if (next == controls.mediaEffects) return
            controls.mediaEffects = next
            markPrefsDirty()
            applyScene()
            // ⛔ 没有片源时到此为止：下面那条路会走 `rebuildScreen`，而它在没有片源时的分支是
            // 「收面板 + 把 2D 面板按默认位摆回去」。这一页此刻本来也没有幕布可重建。
            if (!stageActive) return
            if (screenUsesEffectMesh != wantsEffectMesh()) {
                rebuildScreen(keepPlayback = true)
            } else {
                syncMediaEffects()
            }
        }

        override fun onScreenDistance(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            setScreenDistance(meters)
        }

        override fun onViewDistanceHold(direction: Int, pressed: Boolean) {
            if (!pressed) {
                if (viewDistanceDirection == direction) viewDistanceDirection = 0
                return
            }
            if (inputSuspended || controls.switching || !stageActive || !screenShown || controls.route != ControlsRoute.DISTANCE) return
            touched()
            cancelStageSwipe()
            for (i in 0..1) tapCandidate[i] = false
            viewDistanceDirection = direction.coerceIn(-1, 1)
            lastMotionAt = SystemClock.uptimeMillis()
        }

        override fun onViewDistanceStep(direction: Int) {
            if (inputSuspended || controls.switching || !stageActive || !screenShown) return
            touched()
            adjustViewDistance(direction, 0.05f)
        }

        override fun onResetViewDistance() {
            touched()
            viewDistanceDirection = 0
            if (controls.format.isFlat) setScreenDistance(DEFAULT_VIEW_DISTANCE_M) else {
                sphereOffsetM = 0f
                applyScreenTransform()
            }
        }

        /** 点一下走一格：与幕布那枚钮同一格（[onViewDistanceStep] 的 0.05s 当量）。 */
        override fun onUiPanelDistanceStep(direction: Int) {
            if (inputSuspended || stageActive) return
            touched()
            nudgeUiPanelDistance(ViewDistanceMotion.flatFactor(direction, 0.05f) - 1f)
        }

        override fun onUiPanelDistanceHold(direction: Int, pressed: Boolean) {
            if (!pressed) {
                if (uiPanelHoldDirection == direction) endUiPanelHold()
                return
            }
            if (inputSuspended || stageActive || controls.route != ControlsRoute.BROWSE) return
            touched()
            uiPanelHoldDirection = direction.coerceIn(-1, 1)
            // 从下一帧开始连走（≤14ms，与幕布那条 [handleInput] 里的路径完全一致）。
            uiPanelHoldLastAt = SystemClock.uptimeMillis()
            uiPanelHoldFrom = uiPanelDistanceNow()
        }

        override fun onResetUiPanelDistance() {
            if (inputSuspended || stageActive) return
            touched()
            endUiPanelHold()
            resetUiPanelPlacement()
        }

        override fun onScreenOffset(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenOffset = meters.coerceIn(-1.5f, 1.5f)
            screenSurfaceOverride = null
            applyScreenTransform()
            markPrefsDirty()
        }

        override fun onScreenWidth(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenWidth = meters.coerceIn(SCREEN_MIN_WIDTH_M, SCREEN_MAX_WIDTH_M)
            markPrefsDirty()
            rememberLayoutForAspect()
            // 滑块连续来：给个很短的过渡，逐帧跟手而不是松手才变。
            requestShape(SLIDER_ANIM_MS)
        }

        override fun onResetScreenGeometry() {
            touched()
            controls.screenDistance = DEFAULT_VIEW_DISTANCE_M
            controls.screenOffset = 0f
            controls.screenWidth = DEFAULT_SCREEN_WIDTH_M
            // 重置 = 这个比例回预设：把记的那份也抹掉，别一换片又恢复回去。
            if (controls.format.isFlat) {
                val key = aspectKey()
                prefs.forgetLayout(key)
                layoutAppliedForKey = key
            }
            markPrefsDirty()
            recenterEverything()
            requestShape(CURVE_ANIM_MS)
        }

        override fun onRecenter() {
            touched()
            recenterEverything()
        }

        override fun onPickAspect(preset: AspectPreset) {
            touched()
            if (preset == controls.aspectPreset) return
            controls.aspectPreset = preset
            markPrefsDirty()
            requestShape(CURVE_ANIM_MS)
        }

        override fun onWidthRatio(ratio: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.widthRatio = ratio.coerceIn(0.5f, 2f)
            markPrefsDirty()
            requestShape(SLIDER_ANIM_MS)
        }

        override fun onHeightRatio(ratio: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.heightRatio = ratio.coerceIn(0.5f, 2f)
            markPrefsDirty()
            requestShape(SLIDER_ANIM_MS)
        }

        override fun onResetAspect() {
            touched()
            controls.aspectPreset = AspectPreset.DEFAULT
            controls.widthRatio = 1f
            controls.heightRatio = 1f
            markPrefsDirty()
            requestShape(CURVE_ANIM_MS)
        }

        override fun onToggleCarryOver() {
            touched()
            controls.carryOverToNextVideo = !controls.carryOverToNextVideo
            markPrefsDirty()
        }

        override fun onPlayEntry(queueId: String, id: String) {
            touched()
            if (id == nowPlayingId) return
            controls.activeQueueId = queueId
            playFromQueue(queueId, id)
        }

        override fun onPickPlaylistSection(queueId: String) {
            touched()
            controls.activeQueueId = queueId
            // ⛔ 也告诉 Dart：详情页的当前池要跟着换，否则下一次整套重推（翻页 / 清单到了）会把
            // 分区拽回 Dart 手里那个——「点了别的分区又跳回去」的状态冲突就是这个。
            ImmersiveBridge.requestOpenQueue(queueId)
        }

        override fun onPlayAdjacent(forward: Boolean) {
            touched()
            playAdjacent(forward)
        }

        override fun onRefreshPlaylist() {
            touched()
            beginPlaylistWait()
            ImmersiveBridge.requestPlaylist(force = true)
        }

        override fun onOpenQueue(queueId: String) {
            touched()
            if (controls.playlistLoading) return
            controls.activeQueueId = queueId
            controls.expandedGroupId = null
            if (playlistSections.any { it.queueId == queueId }) {
                ImmersiveBridge.requestOpenQueue(queueId)
                return
            }
            beginPlaylistWait(pendingQueueId = queueId)
            ImmersiveBridge.requestOpenQueue(queueId)
        }

        override fun onExpandPlaylistGroup(groupId: String?) {
            touched()
            controls.expandedGroupId = groupId
        }

        override fun onPickSource(label: String) {
            touched()
            val option = controls.sources.firstOrNull { it.label == label } ?: return
            if (option.label == controls.sourceLabel) return
            if (!playback.swapSource(option.url, muted = controls.muted, volume = controls.volume)) return
            argUrl = option.url
            controls.sourceLabel = option.label
            controls.buffering = true
            sourceRefreshRequested = false
            sourceRefreshUntil = 0L
            ImmersiveBridge.notifySourcePicked(option.label)
            Log.i(TAG, "IMMERSIVE source -> ${option.label} local=${option.local}")
        }

        override fun onRestartFromBeginning() {
            touched()
            hideResumeTip()
            playback.seekTo(0L)
        }

        override fun onDismissResumeTip() {
            touched()
            hideResumeTip()
        }

        override fun onLoadMorePlaylist(queueId: String) {
            lastInteractionAt = SystemClock.uptimeMillis()
            if (controls.playlistLoadingMoreQueueId != null) return
            val section = playlistSections.firstOrNull { it.queueId == queueId } ?: return
            if (!section.hasMore) return
            controls.playlistLoadingMoreQueueId = queueId
            ImmersiveBridge.requestLoadMore(queueId)
        }

        override fun onPickRepeatMode(mode: RepeatMode) {
            touched()
            controls.repeatMode = mode
            applyRepeatMode()
            markPrefsDirty()
        }

        override fun onToggleAutoHide() {
            touched()
            controls.autoHide = !controls.autoHide
            markPrefsDirty()
        }

        override fun onAutoHideSeconds(seconds: Int) {
            touched()
            controls.autoHideSeconds = seconds.coerceIn(4, 60)
            markPrefsDirty()
        }

        override fun onToggleClickSound() {
            controls.clickSound = !controls.clickSound
            touched()
            markPrefsDirty()
        }

        override fun onToggleSummonInFront() {
            touched()
            controls.summonInFront = !controls.summonInFront
            markPrefsDirty()
        }

        override fun onToggleControllerTapPlayPause() {
            touched()
            controls.controllerTapPlayPause = !controls.controllerTapPlayPause
            markPrefsDirty()
        }

        override fun onTogglePauseOnFocusLoss() {
            touched()
            controls.pauseOnFocusLoss = !controls.pauseOnFocusLoss
            markPrefsDirty()
        }

        override fun onRoute(route: ControlsRoute) {
            viewDistanceDirection = 0
            touched()
            controls.route = route
            controls.volumePopupOpen = false
            if (route == ControlsRoute.PLAYLIST) {
                if (playlistSections.isEmpty()) beginPlaylistWait()
                ImmersiveBridge.requestPlaylist()
            }
        }

        /** 含悬停：只续空闲计时。⛔ 别在这里写 [lastPanelTouchAt]，见 [onPanelPressed]。 */
        override fun onPanelTouched() {
            lastInteractionAt = SystemClock.uptimeMillis()
        }

        override fun onPanelPressed() = notePanelPress()

        override fun onHidePanel() {
            touched()
            hideControls()
        }

        override fun onBackToApp() {
            touched()
            backToApp()
        }

        // ---- 空间画廊 ----

        override fun onGalleryShow(index: Int) {
            touched()
            if (gallery?.index == index) return
            showGalleryItem(index)
        }

        override fun onGalleryToggleSlideshow() {
            val g = gallery ?: return
            touched()
            g.slideshow = !g.slideshow
            slideshowNextAt = 0L
            // 视频项：幻灯片开着就不再单条循环（播完要翻页）。
            if (g.current?.isVideo == true && playback.isAlive) playback.setRepeatOne(galleryRepeatOne())
            Log.i(TAG, "IMMERSIVE gallery slideshow=${g.slideshow}")
        }

        override fun onGallerySlideshowSeconds(seconds: Int) {
            val g = gallery ?: return
            touched()
            g.slideshowSeconds = seconds.coerceIn(1, 120)
            prefs.slideshowSeconds = g.slideshowSeconds
            slideshowNextAt = 0L
            markPrefsDirty()
        }

        override fun onGalleryPickQuality(quality: String) {
            val g = gallery ?: return
            touched()
            if (quality == g.quality) return
            g.quality = quality
            // 换了档：手里的文件都是旧档的，全部作废重取；当前那张先留着看，新档到了再换。
            g.resolvedPath.clear()
            galleryResolving.clear()
            ImmersiveBridge.notifyGalleryQuality(quality)
            val current = g.current
            if (current != null && !current.isVideo) {
                g.loading = true
                requestGalleryFile(current.id)
            }
            prefetchGalleryNeighbours(g.index)
            Log.i(TAG, "IMMERSIVE gallery quality -> $quality")
        }

        override fun onGalleryToggleLoop() {
            val g = gallery ?: return
            touched()
            g.loopVideo = !g.loopVideo
            prefs.galleryLoopVideo = g.loopVideo
            markPrefsDirty()
            if (playback.isAlive) playback.setRepeatOne(galleryRepeatOne())
        }
    }

    // ================================================================ 空间画廊

    /**
     * 整本图库交给幕布。
     *
     * 幕布这块「窗」不换：曲率 / 距离 / 幕宽 / 抓挪缩放 / 窗框全部沿用；换的只是里面画的东西
     * （图片 = `vr_image_panel` 的 Compose + Coil，视频项 = 原来的 ExoPlayer 幕布）。
     * 文件本体由 Dart 按需下载到它自己的图片缓存里再把路径交来（[requestGalleryFile]），
     * 这里只解码 —— Dart 那条 HTTP 走应用内代理，原生没有。
     */
    private fun presentGallery(request: ImmersiveGalleryRequest) {
        if (!inGallery || gallery?.galleryId != request.galleryId) resetStagePlacement()
        // 幕布上若正放着视频：把它结束掉（回写位置）；正放着别的图库：告诉 Dart 它结束了。
        if (!argUrl.isNullOrBlank() && !inGallery) {
            endScrub()
            endSphereGrab(hideControls = false)
            playback.cancelPreload()
            clearSwitchWait()
            notifyEnded()
        }
        gallery?.let { old ->
            if (old.galleryId != request.galleryId) ImmersiveBridge.notifyGalleryEnded(old.galleryId, old.index)
        }
        galleryResolving.clear()
        argUrl = null
        videoId = ""
        nowPlayingId = null
        controls.nowPlayingId = null
        controls.sources.clear()
        controls.sourceLabel = ""
        hideResumeTip()
        controls.notice = null
        controls.buffering = false
        controls.format = VideoFormat.FLAT_2D
        controls.formatTab = FormatTab.FLAT
        controls.title = request.title
        // 图集页有自己的两行头部（标题 + 作者），播放页那份不要留着串味。
        controls.author = ""
        // 屏幕尺寸（宽高比预设 / 宽比 / 长比）与倍速回默认：图片要按自己的比例摆，不能带着上一条视频的 16:9 预设。
        if (!controls.carryOverToNextVideo) controls.resetPerVideoSettings()
        layoutAppliedForKey = null
        val g = GalleryState().apply {
            galleryId = request.galleryId
            title = request.title
            author = request.author
            items.addAll(
                request.items.map {
                    GalleryItem(
                        id = it.id, isVideo = it.isVideo,
                        thumbUrl = it.thumbUrl, thumbPath = it.thumbPath, width = it.width, height = it.height,
                    )
                },
            )
            index = request.index.coerceIn(0, request.items.size - 1)
            quality = request.quality.ifBlank { GALLERY_QUALITY_STANDARD }
            slideshowSeconds = prefs.slideshowSeconds
            loopVideo = prefs.galleryLoopVideo
        }
        galleryItems = request.items
        gallery = g
        controls.gallery = g
        // 「接着看」卡片按它高亮；面板里点的那张卡转圈到此收掉（Dart 换页成功、新图库到了）。
        nowPlayingId = request.galleryId.ifBlank { null }
        controls.nowPlayingId = nowPlayingId
        clearSwitchWait()
        stage.resetZoom()
        bufferingState.loadingLabelRes = UiR.string.xr_loading
        Log.i(TAG, "IMMERSIVE gallery present id=${g.galleryId} n=${g.items.size} index=${g.index} quality=${g.quality}")
        showGalleryItem(g.index)
        showControls()
    }

    /** 退出空间画廊（回应用 / 被视频顶掉）：状态清空、图片面板销毁、Dart 收 `galleryEnded`。不重建幕布，由调用方决定。 */
    private fun exitGallery() {
        val g = gallery ?: return
        ImmersiveBridge.notifyGalleryEnded(g.galleryId, g.index)
        Log.i(TAG, "IMMERSIVE gallery exit id=${g.galleryId} index=${g.index}")
        gallery = null
        controls.gallery = null
        galleryItems = emptyList()
        galleryResolving.clear()
        stage.model = null
        stage.itemId = ""
        stage.imageAspect = 0f
        stage.resetZoom()
        stage.swipe.canPrevious = false
        stage.swipe.canNext = false
        nowPlayingId = null
        controls.nowPlayingId = null
        slideshowNextAt = 0L
        galleryStepHeld = 0
        stagePressed = false
        endTwoHandScale()
        bufferingState.loadingLabelRes = UiR.string.xr_buffering
        controls.buffering = false
        controls.title = ""
        controls.author = ""
        controls.notice = null
        // 图片面板不能留给下一条视频复用（它没有 Surface）：直接销毁，调用方重建幕布时按需要的种类重建。
        if (screenIsImage) {
            manipulator.detach(WindowKind.SCREEN)
            destroyBufferingEntity()
            mediaEffects.detach()
            screenEntity?.destroy()
            screenEntity = null
            screenPanel = null
            screenIsImage = false
        } else {
            playback.release()
        }
        argUrl = null
        videoId = ""
    }

    // ================================================================ 幕布横拖翻片（视频）

    /**
     * 按在**图库里那段视频**的画面上横拖 = 上一项 / 下一项。
     *
     * ⛔ **只在空间画廊里成立**（[inGallery]）：横拖翻片是「翻一本图库」这件事自带的手势，
     * 视频详情页进来的那块幕布上**没有**（用户 2026-09-06：那是图库特有的功能，被带进视频空间是错的）。
     * 图库里混着的短片走的是同一块 Surface 幕布，所以判据必须是「在不在图库里」，
     * 不能用「幕布装的是不是图片」——后者会把图库里的视频项一起关掉。
     *
     * 为什么在原生算而不是像图片幕布那样交给 Compose：视频幕布是 ExoPlayer 的 Surface 面板，
     * 根本没有 Compose 层收指针。这里用**射线 × 窗面**（`WindowManipulator.surfaceHit`，与抓窗、
     * 拉角同一套求交）拿到面内横坐标，位移 ÷ 幕宽就是喂给 `StageSwipeState` 的比例 —— 阈值、
     * 橡皮筋、甩动判定、浮窗全部与图片幕布共用那一份，别在这里另立标准。
     *
     * 浮窗画在**幕布叠层面板**上（缓冲转圈那块，同形同位、按需创建），见 `syncBufferingIndicator`。
     */
    private fun stageSwipeAvailable(): Boolean =
        inGallery && controls.format.isFlat && screenEntity != null && !screenIsImage && screenEntityIsFlat

    /** 这只手的射线此刻打在幕布上的横坐标（米，面心为 0、向右为正）；没打到为 null。 */
    private fun stageSwipeHitX(hand: Int): Float? {
        val surface = screenHost.surfacePose() ?: return null
        return manipulator.surfaceHit(hand, input, surface, screenHost.size(), screenHost.arcDegrees())?.x
    }

    /** 那个方向还有没有下一项。⛔ 只有画廊会走到这（见 [stageSwipeAvailable]）。 */
    private fun stageSwipeHasTarget(forward: Boolean): Boolean {
        val g = gallery ?: return false
        return if (forward) g.hasNext else g.hasPrevious
    }

    private fun beginStageSwipe(hand: Int, now: Long) {
        if (stageSwipeHand >= 0 || twoHandScaling || !stageSwipeAvailable()) return
        // 按在操作栏上：面板浮在幕布前面，射线打穿它照样与幕布平面有交点（拖进度条会顺手翻片）。
        if (pointerOnControls(hand)) return
        val x = stageSwipeHitX(hand) ?: return
        stageSwipeHand = hand
        stageSwipeStartX = x
        stageSwipeLastX = x
        stageSwipeLastAt = now
        stageSwipeVelocity = 0f
        stageSwipeDragging = false
        bufferingState.swipe.canPrevious = stageSwipeHasTarget(forward = false)
        bufferingState.swipe.canNext = stageSwipeHasTarget(forward = true)
    }

    private fun updateStageSwipe(now: Long) {
        val hand = stageSwipeHand
        if (hand < 0) return
        if (!input.selectHeld[hand] || twoHandScaling || manipulator.isBusy(hand) || !stageSwipeAvailable()) {
            cancelStageSwipe()
            return
        }
        // ⛔ 这一次按下落在**面板**上（操作栏、弹层、窗框）：面板浮在幕布前面，射线打穿它照样
        // 与幕布平面有交点 —— 不挡的话「拖进度条」会顺手翻片。判据用按压证据（[notePanelPress]），
        // 不用 controlsHovered 那个只进不出的悬停标志（记忆 `xr-hover-never-exits`）。
        if (lastPanelTouchAt >= tapDownAt[hand] - 60L) {
            cancelStageSwipe()
            return
        }
        // 射线滑出幕布：保持上一帧的进度不动（比跳回 0 好看，也不至于误判成松手弹回）。
        val x = stageSwipeHitX(hand) ?: return
        val fraction = (stageSwipeStartX - x) / curWidth.coerceAtLeast(0.01f)
        if (!stageSwipeDragging) {
            if (abs(fraction) < STAGE_SWIPE_SLOP) return
            stageSwipeDragging = true
            bufferingState.swipe.begin()
            // 拖起来了就不是「点一下」。⛔ 必须显式清掉：射线拖动几乎不挪手，
            // onSelectUp 那条按**手的位移**判的路根本够不着，不清就会顺手 toggle 控制面板。
            tapCandidate[hand] = false
        }
        val dt = (now - stageSwipeLastAt).coerceAtLeast(1L) / 1000f
        val v = -((x - stageSwipeLastX) / curWidth) / dt
        stageSwipeVelocity = if (stageSwipeVelocity == 0f) v else stageSwipeVelocity * 0.6f + v * 0.4f
        stageSwipeLastX = x
        stageSwipeLastAt = now
        bufferingState.swipe.update(fraction)
        lastInteractionAt = now
    }

    private fun endStageSwipe(hand: Int) {
        if (stageSwipeHand != hand) return
        val dragging = stageSwipeDragging
        stageSwipeHand = -1
        stageSwipeDragging = false
        val dir = bufferingState.swipe.end(stageSwipeVelocity)
        stageSwipeVelocity = 0f
        if (!dragging || dir == 0) return
        Log.i(TAG, "IMMERSIVE stage swipe -> ${if (dir > 0) "next" else "prev"}")
        playAdjacent(forward = dir > 0)
    }

    private fun cancelStageSwipe() {
        if (stageSwipeHand < 0) return
        stageSwipeHand = -1
        stageSwipeDragging = false
        stageSwipeVelocity = 0f
        bufferingState.swipe.cancel()
    }

    /** 上一条 / 下一条：画廊里翻项，视频里换「接着看」当前分区的相邻一条。 */
    private fun playAdjacent(forward: Boolean) {
        if (inGallery) {
            galleryStep(forward)
            return
        }
        val (queueId, item) = adjacentPlayable(forward) ?: return
        playFromQueue(queueId, item.id)
    }

    // ================================================================ 两手抓取缩放

    /**
     * 双抓握扳机（手柄）或双捏合按住（手势）同时成立 = 抓住幕布两端：手距变化多少倍，幕宽就变多少倍，
     * 以幕心为原点（用户 2026-09-05：放大缩小只能拖窗角，要空间化的办法）。
     * 单手那只正在拖窗的会话被接管；松开一只之后若那只抓握还按着，重新接回单手拖。
     */
    private fun updateTwoHandScale(now: Long) {
        if (!controls.format.isFlat || screenEntity == null || viewDistanceDirection != 0 || pointerOnControls()) {
            endTwoHandScale()
            return
        }
        val grips = input.gripHeld[0] && input.gripHeld[1]
        val selects = input.selectHeld[0] && input.selectHeld[1] && !controlsHovered && !manipulator.isBusy(0) && !manipulator.isBusy(1)
        val p0 = input.handPositions[0]
        val p1 = input.handPositions[1]
        if (!twoHandScaling) {
            if (!(grips || selects) || p0 == null || p1 == null) return
            val d0 = p0.distanceTo(p1)
            if (d0 < 0.05f) return
            twoHandScaling = true
            twoHandBySelect = !grips
            twoHandDist0 = d0
            twoHandWidth0 = controls.screenWidth
            manipulator.release(0)
            manipulator.release(1)
            endSphereGrab(hideControls = false)
            for (i in 0..1) tapCandidate[i] = false
            Log.i(TAG, "IMMERSIVE two-hand scale start d0=$d0 width=$twoHandWidth0 bySelect=$twoHandBySelect")
            return
        }
        val stillHeld = if (twoHandBySelect) input.selectHeld[0] && input.selectHeld[1] else grips
        if (!stillHeld || p0 == null || p1 == null) {
            endTwoHandScale()
            // 一只抓握还按着：接回单手拖。
            if (!twoHandBySelect) {
                for (i in 0..1) if (input.gripHeld[i] && !manipulator.isBusy(i)) manipulator.startGrab(i, WindowKind.SCREEN, input)
            }
            return
        }
        val ratio = p0.distanceTo(p1) / twoHandDist0
        controls.screenWidth = (twoHandWidth0 * ratio).coerceIn(SCREEN_MIN_WIDTH_M, SCREEN_MAX_WIDTH_M)
        animating = false
        curWidth = targetScreenWidth(curAspect)
        reshapeNow()
        lastInteractionAt = now
    }

    private fun endTwoHandScale() {
        if (!twoHandScaling) return
        twoHandScaling = false
        markPrefsDirty()
        rememberLayoutForAspect()
        Log.i(TAG, "IMMERSIVE two-hand scale end width=${controls.screenWidth}")
    }

    /** 视频项单条循环：用户开着「循环」且幻灯片没开。 */
    private fun galleryRepeatOne(): Boolean {
        val g = gallery ?: return false
        return g.loopVideo && !g.slideshow
    }

    /**
     * 把幕布翻到第 [index] 项。
     *
     * - 图 → 图：面板实体不动，换 [stage] 的内容 + 形状按新比例过渡（[CURVE_ANIM_MS]）；
     * - 图 ↔ 视频：种类变了，销毁重建幕布（一次黑屏，可接受）；
     * - 视频 → 视频：沿用 Surface 从头起播（[PlaybackEngine.restart]）。
     * 文件还没到手的图片：先保留上一张在幕布上、压「正在读取…」，到了再换（不闪一次空白）。
     */
    private fun showGalleryItem(index: Int) {
        val g = gallery ?: return
        if (g.items.isEmpty()) return
        viewDistanceDirection = 0
        val i = index.coerceIn(0, g.items.size - 1)
        val item = galleryItems[i]
        g.index = i
        g.error = null
        controls.notice = null
        slideshowNextAt = 0L
        stage.resetZoom()
        // 幕布上的横拖预示要知道还有没有下一张（到头的方向只出「到头」样式，不翻页）。
        stage.swipe.canPrevious = i > 0
        stage.swipe.canNext = i < g.items.size - 1
        val shapeMs = CURVE_ANIM_MS
        endScrub()
        if (item.width > 0 && item.height > 0) {
            videoWidth = item.width
            videoHeight = item.height
        }
        val wantImage = !item.isVideo
        val kindChanged = screenEntity == null || wantImage != screenIsImage
        if (wantImage) {
            argUrl = null
            videoId = ""
            controls.isPlaying = false
            val path = g.resolvedPath[item.id]
            g.loading = true
            if (path != null) {
                stage.itemId = item.id
                stage.model = path
                // ⛔ 与 model 成对写：文件还没到手时幕布上还是**上一张**，这时改比例会把它拉变形。
                stage.imageAspect = ScreenGeometry.screenAspect(controls, item.width, item.height)
            } else {
                requestGalleryFile(item.id)
            }
            if (kindChanged) {
                playback.release()
                rebuildScreen()
            } else {
                requestShape(shapeMs)
            }
        } else {
            argUrl = item.url
            videoId = ""
            pendingStartMs = 0L
            g.loading = false
            resetTrackUi()
            controls.positionText = "00:00"
            controls.durationText = "00:00"
            controls.seekPreviewText = null
            if (kindChanged) {
                playback.release()
                rebuildScreen()
            } else if (playback.restart(item.url, muted = controls.muted, volume = controls.volume, repeatOne = galleryRepeatOne())) {
                controls.isPlaying = true
                controls.buffering = true
                playback.setSpeed(controls.speed)
                requestShape(shapeMs)
            } else {
                rebuildScreen()
            }
        }
        prefetchGalleryNeighbours(i)
        lastInteractionAt = SystemClock.uptimeMillis()
        ImmersiveBridge.notifyGalleryIndex(g.galleryId, i)
        Log.i(TAG, "IMMERSIVE gallery show index=$i video=${item.isVideo} kindChanged=$kindChanged")
    }

    /**
     * 上一张 / 下一张（幕布横拖松手过阈值 / 摇杆左右都到这）。
     *
     * 换的是幕布上画的**内容**（[GalleryStage] 自己 220ms 淡过去），面板实体一动不动 ——
     * 老那套「三块窗沿弧滑」已经整只拆掉（用户 2026-09-06）。
     */
    private fun galleryStep(forward: Boolean) {
        val g = gallery ?: return
        if (forward && !g.hasNext) return
        if (!forward && !g.hasPrevious) return
        showGalleryItem(g.index + if (forward) 1 else -1)
    }

    /** 幻灯片翻页：到末尾绕回第一项。 */
    private fun galleryAdvanceForSlideshow() {
        val g = gallery ?: return
        if (g.items.size <= 1) return
        showGalleryItem(if (g.index + 1 < g.items.size) g.index + 1 else 0)
    }

    /** 摇杆左右：刚推上去翻一张，按住 [GALLERY_STEP_FIRST_MS] 后每 [GALLERY_STEP_REPEAT_MS] 连翻。 */
    private fun handleGalleryStick(now: Long, stick: SpatialInputPoller.StickDirections) {
        val dir = when {
            stick.right && !stick.left -> 1
            stick.left && !stick.right -> -1
            else -> 0
        }
        if (dir == 0) {
            galleryStepHeld = 0
            return
        }
        if (dir != galleryStepHeld) {
            galleryStepHeld = dir
            galleryStepNextAt = now + GALLERY_STEP_FIRST_MS
            galleryStep(forward = dir > 0)
        } else if (now >= galleryStepNextAt) {
            galleryStepNextAt = now + GALLERY_STEP_REPEAT_MS
            galleryStep(forward = dir > 0)
        }
    }

    /** 每帧：图片项的读取态压到幕布叠层（转圈）；幻灯片计时。 */
    private fun tickGallery(now: Long) {
        val g = gallery ?: return
        val item = g.current ?: return
        if (item.isVideo) return
        if (controls.buffering != g.loading) controls.buffering = g.loading
        if (!g.slideshow || pausedBySystem) {
            slideshowNextAt = 0L
            return
        }
        when {
            g.loading -> slideshowNextAt = 0L
            slideshowNextAt == 0L -> slideshowNextAt = now + g.slideshowSeconds * 1000L
            now >= slideshowNextAt -> {
                slideshowNextAt = 0L
                galleryAdvanceForSlideshow()
            }
        }
    }

    /** 当前项前后各两项的图片先向 Dart 要过来（翻到时零等待）。视频项不用。 */
    private fun prefetchGalleryNeighbours(index: Int) {
        val g = gallery ?: return
        for (d in intArrayOf(1, -1, 2, -2)) {
            val item = galleryItems.getOrNull(index + d) ?: continue
            if (!item.isVideo && !g.resolvedPath.containsKey(item.id)) requestGalleryFile(item.id)
        }
    }

    /**
     * 向 Dart 要 [id] 这个文件在当前画质档下的本地路径（单飞）。回来时图库 / 画质档已经换了就丢弃。
     * 到手的路径进 [GalleryState.resolvedPath]（胶片那格随之换成清晰图）；正好是当前项就立刻上幕布。
     */
    private fun requestGalleryFile(id: String) {
        val g = gallery ?: return
        if (g.resolvedPath.containsKey(id)) return
        val now = SystemClock.uptimeMillis()
        val startedAt = galleryResolving[id]
        // 在途且还没超时：单飞，不重发。超时了就当上一次丢了，重来一次。
        if (startedAt != null && now - startedAt < GALLERY_FILE_TIMEOUT_MS) return
        if (startedAt != null) Log.w(TAG, "IMMERSIVE gallery file retry id=$id (上一次 ${now - startedAt}ms 没回来)")
        galleryResolving[id] = now
        val galleryId = g.galleryId
        val quality = g.quality
        ImmersiveBridge.requestGalleryFile(id, quality) { path ->
            runOnUiThread {
                galleryResolving.remove(id)
                val cur = gallery ?: return@runOnUiThread
                if (cur.galleryId != galleryId || cur.quality != quality) return@runOnUiThread
                val isCurrent = cur.current?.id == id
                if (path.isBlank()) {
                    Log.w(TAG, "IMMERSIVE gallery file unavailable id=$id")
                    if (isCurrent) {
                        cur.loading = false
                        cur.error = text(UiR.string.xr_gallery_load_failed, "download")
                        showControls(summoned = true)
                    }
                    return@runOnUiThread
                }
                cur.resolvedPath[id] = path
                if (isCurrent && cur.current?.isVideo != true) {
                    val item = cur.current
                    stage.itemId = id
                    stage.model = path
                    if (item != null) stage.imageAspect = ScreenGeometry.screenAspect(controls, item.width, item.height)
                }
            }
        }
    }

    /** 图片解码完成：读取态收掉；真实比例与手里的不一致就按它重塑幕布（服务端偶尔不给宽高）。 */
    private fun onGalleryImageLoaded(id: String, width: Int, height: Int) {
        val g = gallery ?: return
        if (g.current?.id != id) return
        g.loading = false
        g.error = null
        if (width > 0 && height > 0) {
            val have = videoWidth.toFloat() / videoHeight.coerceAtLeast(1)
            val real = width.toFloat() / height
            if (abs(have - real) > 0.01f) {
                videoWidth = width
                videoHeight = height
                requestShape(0L)
            }
        }
    }

    private fun onGalleryImageFailed(id: String, message: String) {
        val g = gallery ?: return
        if (g.current?.id != id) return
        Log.w(TAG, "IMMERSIVE gallery decode failed id=$id: $message")
        g.loading = false
        g.error = text(UiR.string.xr_gallery_load_failed, message)
        showControls(summoned = true)
    }

    // ================================================================ 面板注册

    // 这个方法在 `super.onCreate()` 内部被调用，读不到 intent —— 无条件注册，是否出现在场景里由 Entity 决定。
    /**
     * 2D 应用面板的设置：微曲面，弧度定死 [UI_PANEL_ARC_DEGREES]、半径由宽度反推（见 [uiPanelMeshRadius]）；
     * dp 按 640dp/m 同比，字号不随窗大小变。创建时取偏好里的尺寸，拖角时按当前尺寸 reshape。
     */
    private fun uiPanelSettings(size: Vector2): UIPanelSettings = UIPanelSettings(
        shape = CylinderShapeOptions(radius = uiPanelMeshRadius(size.x), width = size.x, height = size.y),
        display = DpDisplayOptions(size.x * UI_DP_PER_METER, size.y * UI_DP_PER_METER, UI_PANEL_DPI),
        // 窗口透明 + Flutter 根部裁圆角（MainActivity.getBackgroundMode / my_app.dart）：
        // 面板要按 alpha 合成，四角才透得出后面的场景。
        rendering = UIPanelRenderOptions(
            renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
        ),
    )

    override fun registerPanels(): List<PanelRegistration> = listOf(
        ActivityPanelRegistration(
            R.id.vr_ui_panel,
            { MainActivity::class.java },
            { uiPanelSettings(Vector2(prefs.uiPanelWidth, prefs.uiPanelHeight)) },
        ),
        // 三块窗各自的窗框（见 WindowManipulator）：形状在创建那一刻取窗体尺寸 + 一圈边。
        ComposeViewPanelRegistration(
            R.id.vr_frame_ui_panel,
            { _, ctx -> createWindowFrameView(ctx, manipulator.frameState(WindowKind.UI)) },
            { manipulator.frameSettings(WindowKind.UI) },
        ),
        ComposeViewPanelRegistration(
            R.id.vr_frame_controls_panel,
            { _, ctx -> createWindowFrameView(ctx, manipulator.frameState(WindowKind.CONTROLS)) },
            { manipulator.frameSettings(WindowKind.CONTROLS) },
        ),
        ComposeViewPanelRegistration(
            R.id.vr_frame_screen_panel,
            { _, ctx -> createWindowFrameView(ctx, manipulator.frameState(WindowKind.SCREEN)) },
            { manipulator.frameSettings(WindowKind.SCREEN) },
        ),
        ComposeViewPanelRegistration(
            R.id.vr_controls_panel,
            { _, ctx -> createVideoControlsView(ctx, controls, controlsCallbacks) },
            {
                UIPanelSettings(
                    shape = QuadShapeOptions(width = CONTROLS_WIDTH_M, height = CONTROLS_HEIGHT_M),
                    // 面板逻辑尺寸固定 1100×360dp（与 `:questui` 的 PanelTokens 成对），密度由物理宽度反推。
                    display = DpPerMeterDisplayOptions(dpPerMeter = 1100f / CONTROLS_WIDTH_M),
                    rendering = UIPanelRenderOptions(
                        renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
                    ),
                )
            },
        ),
        ComposeViewPanelRegistration(
            R.id.vr_buffering_panel,
            { _, ctx -> createBufferingView(ctx, bufferingState) },
            // 形状在创建那一刻取幕布当前的形状（同位同形，见 bufferingPose）。
            { bufferingSettings() },
        ),
        VideoSurfacePanelRegistration(
            R.id.vr_video_panel,
            surfaceConsumer = { entity, surface -> if (screenEntity == entity) startPlayback(surface) },
            settingsCreator = { mediaSettings() },
        ),
        VideoSurfacePanelRegistration(
            R.id.vr_video_effects_panel,
            surfaceConsumer = { entity, surface ->
                if (screenEntity == entity) {
                    playback.detachSurface()
                    mediaEffects.prepareVideoSurface(surface, processedVideoWidth, processedVideoHeight) { input ->
                        if (screenEntity == entity) startPlayback(input)
                    }
                }
            },
            settingsCreator = { processedMediaSettings() },
        ),
        // 空间画廊的图片面板：与视频幕布同一块「窗」的另一种内容（见 rebuildScreen）。
        ComposeViewPanelRegistration(
            R.id.vr_image_panel,
            { _, ctx -> createGalleryStageView(ctx, stage) },
            { imageSettings() },
        ),
    )

    /**
     * 面板上那一行提示的取词。
     *
     * ⛔ 走 [PanelLocale]：文案跟**应用内选定的语言**走，不跟头显的系统语言走
     * （用户可能把 Quest 设成英文却把应用设成中文）。词条与面板同一份资源，
     * 见 `:questui` 的 `res/values` 系列目录。
     */
    private fun text(@StringRes id: Int, vararg args: Any): String =
        PanelLocale.apply(this).getString(id, *args)

    private fun formatMs(ms: Long): String {
        if (ms <= 0) return "00:00"
        val total = ms / 1000
        val h = total / 3600
        val m = (total % 3600) / 60
        val s = total % 60
        return if (h > 0) String.format("%d:%02d:%02d", h, m, s) else String.format("%02d:%02d", m, s)
    }

    private fun logMemory(stage: String) {
        val mi = Debug.MemoryInfo()
        Debug.getMemoryInfo(mi)
        val rt = Runtime.getRuntime()
        Log.i(
            TAG,
            "IMMERSIVE_MEM stage=$stage pid=${android.os.Process.myPid()} " +
                "pssTotalKB=${mi.totalPss} pssNativeKB=${mi.nativePss} " +
                "pssDalvikKB=${mi.dalvikPss} pssGraphicsKB=${mi.getMemoryStat("summary.graphics")} " +
                "javaHeapUsedKB=${(rt.totalMemory() - rt.freeMemory()) / 1024}",
        )
    }

    companion object {
        const val TAG = "IwaraVR"

        /** 拿不到头部位姿时的兜底眼高（LOCAL_FLOOR）。 */
        private const val FALLBACK_EYE_HEIGHT_M = 1.6f

        /** 默认观看距离 / 幕宽（米）。 */
        private const val DEFAULT_VIEW_DISTANCE_M = PlayerPrefs.DEFAULT_VIEW_DISTANCE_M
        private const val DEFAULT_SCREEN_WIDTH_M = PlayerPrefs.DEFAULT_SCREEN_WIDTH_M
        private const val SCREEN_MIN_DISTANCE_M = 1.2f
        private const val SCREEN_MAX_DISTANCE_M = 8.0f

        /** UI 面板的几何：1.8m 处 1.6m 宽 ≈ 47° 水平张角，沿视线摆。 */

        /** 2D 应用面板：1024dp / 1.6m = 640dp/m，288dpi；拉角只改米数与像素，不改这两个。 */
        private const val UI_DP_PER_METER = 1024f / PlayerPrefs.DEFAULT_UI_PANEL_WIDTH_M
        private const val UI_PANEL_DPI = 288

        /** 2D 面板的圆角：Flutter 侧裁 20dp（`kXrPanelCornerRadiusDp`），换算成米给窗框用。 */
        private const val UI_PANEL_CORNER_M = 20f / UI_DP_PER_METER

        /**
         * 2D 应用面板的微曲面弧度（度）。
         *
         * 默认 1.6m 宽 ⇒ 半径 3.06m、中心比两边远 10.6cm ——「3000R」那一档曲面显示器的手感：
         * 一眼看得出是包着的，但边缘文字几乎不变形。比幕布最浅的 [ScreenCurve.SLIGHT]（40°）再收一点，
         * 因为这块面板离人更近（[PlayerPrefs.DEFAULT_UI_PANEL_DISTANCE_M]），同样弧度看上去更弯。
         */
        private const val UI_PANEL_ARC_DEGREES = 30f
        private const val UI_PANEL_MIN_WIDTH_M = 0.8f
        private const val UI_PANEL_MIN_HEIGHT_M = 0.5f
        private const val UI_PANEL_MAX_WIDTH_M = 4.0f
        private const val UI_PANEL_MAX_HEIGHT_M = 2.6f

        /** 控制面板拉角的缩放范围；圆角 28dp @ (1100dp / 1.5m)。 */
        private const val CONTROLS_MIN_SCALE = 0.6f
        private const val CONTROLS_MAX_SCALE = 2.0f
        private const val CONTROLS_CORNER_M = 28f * 1.5f / 1100f

        /** 幕布宽度上下限（与设置页滑块同口径）。 */
        private const val SCREEN_MIN_WIDTH_M = 1f
        private const val SCREEN_MAX_WIDTH_M = 10f

        /**
         * 空间画廊：图片面板的**方形**画布边长（像素）。
         *
         * 方的是因为画布建好就改不了（见 [imageSettings]），必须一块画布同时装得下横图与竖图。
         * 2048：Quest 3 单眼 2064px，3.2m 幕布在 2.4m 处约占 67° 视野 ≈ 1400px，2048 仍是过采样；
         * 显存 2048²×4B ≈ 16.8MB，与原先「长边 2560」的横图（2560×1440 ≈ 14.7MB）同量级。
         */
        private const val IMAGE_PANEL_PX = 2048

        /** 空间画廊里竖图装进 16:9 盒子之后的宽度下限。 */
        private const val GALLERY_MIN_WIDTH_M = 0.4f

        /** 摇杆翻页：首翻之后按住这么久开始连翻、连翻间隔。 */
        private const val GALLERY_STEP_FIRST_MS = 550L
        private const val GALLERY_STEP_REPEAT_MS = 320L

        /** 向 Dart 要一个图库文件多久没回来就允许重发（原图可能几十 MB，给得宽一些）。 */
        private const val GALLERY_FILE_TIMEOUT_MS = 20_000L

        /** 幕布上横拖起算的阈值（幕宽比例）：射线抖一下不算拖。 */
        private const val STAGE_SWIPE_SLOP = 0.02f

        /** 指着图片按住 + 摇杆上下：每帧的缩放倍率（72Hz 下按住 1s ≈ ×2.3）。 */
        private const val STICK_ZOOM_STEP = 1.012f

        /** 抓着窗时摇杆每帧推远 / 拉近的比例。 */
        private const val NUDGE_STEP = 0.02f

        /** 拖视角时俯仰上限的正弦（sin 80°）。 */
        private const val SPHERE_MAX_PITCH_SIN = 0.985f

        /** 球幕偏移上限（半径的一半）；调整速度由 [ViewDistanceMotion] 按秒计算。 */
        private const val SPHERE_OFFSET_MAX_M = ScreenGeometry.SPHERE_RADIUS * 0.5f

        /**
         * 控制面板逻辑尺寸固定 1100 × 360dp，基准宽 1.2m，中心离眼睛 1m。
         * 下移与朝向由 [SpatialPlacement.controlsSurface] 计算；即使缩到 0.6，72dp 按钮仍约 2.7°。
         */
        private const val CONTROLS_DISTANCE_M = 1f

        /** Physical clearance for the controls and their native scene cursors. */
        private const val CONTROLS_SCREEN_GAP_M = 0.15f

        private const val CONTROLS_WIDTH_M = 1.2f
        private const val CONTROLS_HEIGHT_M = CONTROLS_WIDTH_M * 360f / 1100f

        /** 藏起来的 UI 面板停在这儿：脚下 100m，射线够不着。 */
        private val PARKED_POSE = Pose(Vector3(0f, -100f, 0f), Quaternion(0f, 0f, 0f))

        /** 球幕时缓冲指示那块小面板的边长；平幕时它与幕布同形。 */
        private const val BUFFERING_SPHERE_SIZE_M = 0.6f
        private const val BUFFERING_DP_PER_METER = 500f

        /** 缓冲持续超过这么久才露面；短抖不闪。 */
        private const val BUFFERING_SHOW_DELAY_MS = 350L

        /** 视线仰角小于 arcsin(0.5)=30° 时球幕只按偏航摆；更仰（躺着）按整个视线摆。 */
        private const val SPHERE_FOLLOW_PITCH_SIN = 0.5f

        /** 「接着看」等 Dart 回话的上限；到点收掉在途态。 */
        private const val PLAYLIST_WAIT_MS = 15_000L

        /** 换片在途上限（Dart 换页 + 拉源 + 预加载）。 */
        private const val SWITCH_WAIT_MS = 45_000L

        /** 直链过期后等 Dart 送新地址的上限。 */
        private const val SOURCE_REFRESH_WAIT_MS = 15_000L

        /** 合成层次序：不靠深度排。 */
        private const val Z_SPHERE = -1
        private const val Z_SCREEN = 0
        private const val Z_UI = 10
        private const val Z_CONTROLS = 20
        private const val Z_BUFFERING = 30

        /** 面板隐身后再等这么多帧才销毁。 */
        private const val DOOMED_TICKS = 3

        /** 「点一下」的判据：捏合不超过这么久、手不超过这么远。 */
        private const val TAP_MAX_MS = 400L
        private const val TAP_MAX_MOVE_M = 0.04f

        private const val CURVE_ANIM_MS = 320L
        private const val SLIDER_ANIM_MS = 60L
        private const val PREFS_FLUSH_MS = 1000L

        /** 摇杆刚推上去先走的一格（一下 = ±5 秒，与面板上那两枚 ±5 秒钮同口径）。 */
        private const val SCRUB_TAP_MS = 5_000L

        /** 续播位置至少这么多才提示（与 2D 的 kMinResumeTipPosition 同口径）；提示停留时长。 */
        private const val RESUME_TIP_MIN_MS = 3_000L
        private const val RESUME_TIP_MS = 10_000L
    }
}
