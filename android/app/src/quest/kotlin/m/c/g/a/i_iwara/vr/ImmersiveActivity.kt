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
import com.meta.spatial.toolkit.PlayerBodyAttachmentSystem
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
import m.c.g.a.i_iwara.questui.PLAYBACK_SPEEDS
import m.c.g.a.i_iwara.questui.PanelLocale
import m.c.g.a.i_iwara.questui.PlaylistChoice
import m.c.g.a.i_iwara.questui.PlaylistEntry
import m.c.g.a.i_iwara.questui.PlaylistGroup
import m.c.g.a.i_iwara.questui.PlaylistSection
import m.c.g.a.i_iwara.questui.SourceOption
import m.c.g.a.i_iwara.questui.RepeatMode
import m.c.g.a.i_iwara.questui.SceneKind
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoFormat
import m.c.g.a.i_iwara.questui.createBufferingView
import m.c.g.a.i_iwara.questui.createVideoControlsView
import m.c.g.a.i_iwara.questui.createWindowFrameView
import m.c.g.a.i_iwara.questui.R as UiR
import m.c.g.a.i_iwara.xr.ImmersiveBridge
import m.c.g.a.i_iwara.xr.ImmersivePlaylistGroup
import m.c.g.a.i_iwara.xr.ImmersivePlaylistItem
import m.c.g.a.i_iwara.xr.ImmersivePlaylistSection
import m.c.g.a.i_iwara.xr.ImmersiveSourceOption
import m.c.g.a.i_iwara.xr.ImmersiveVideoRequest
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.math.sqrt

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
 *
 * # 摆位全部跟随头部（2026-09-05 真机反馈之后）
 *
 * 此前按地面绝对高度摆（眼高 1.6m 的站姿假设），坐着/躺着都不对：面板偏上、竖得笔直。
 * 现在的规则：
 * - **锚点** [anchor]：一帧头部位姿（去掉 roll，保留俯仰与偏航），在首次进入、系统 recenter、
 *   「重新居中」/「重置」时重新捕获。幕布沿锚点视线方向摆在「距离」处，朝向 = 锚点朝向。
 * - 控制面板唤出时沿**当下**视线方向摆在 1.5m 处、略偏下，朝向面对头部。
 * - 官方要求「pitch 与 yaw 自动跟随、roll 固定」，这里正是。
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
 * `shape`: flat | 180 | 360   `stereo`: none | lr | tb   `--ez fullFrame`   `--es scene passthrough|void`
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

    /** 当前幕布实体是平幕（quad / cylinder）还是球幕。 */
    private var screenEntityIsFlat = true
    private var uiPanelEntity: Entity? = null
    private var uiPanel: PanelSceneObject? = null

    /** UI 面板此刻是露着的（不是停在脚下）；窗框只在它露面时跟着出现。 */
    private var uiPanelShown = false

    /** UI 面板创建那一刻的基准尺寸（米），拉角只改相对它的 [uiScale]。 */
    private var uiBaseSize = Vector2(PlayerPrefs.DEFAULT_UI_PANEL_WIDTH_M, PlayerPrefs.DEFAULT_UI_PANEL_WIDTH_M * PlayerPrefs.UI_PANEL_ASPECT_H_OVER_W)
    private var uiScale = Vector2(1f, 1f)
    private var controlsEntity: Entity? = null
    private var controlsPanel: PanelSceneObject? = null

    /** 控制面板相对基准尺寸（1.5m 宽）的等比缩放；进偏好。 */
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
                else frameAlong(position, dir, head.up(), dropDeg = 0f).q
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
            videoId = source.getStringExtra("videoId") ?: ""
        }
        argMute = source.getBooleanExtra("mute", argMute)
        source.getStringExtra("scene")?.let {
            controls.scene = if (it == "passthrough") SceneKind.PASSTHROUGH else SceneKind.VOID
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
        applyScene()
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
        recenterEverything()
    }

    private fun pauseForSystem() {
        input.reset()
        endScrub()
        endSphereGrab(hideControls = false)
        if (!controls.pauseOnFocusLoss) return
        if (playback.isAlive && playback.isPlaying) {
            playback.setPlaying(false)
            controls.isPlaying = false
            pausedBySystem = true
        }
    }

    private fun resumeAfterSystem() {
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
        ImmersiveBridge.detachScene()
        status.stop()
        if (prefsDirty) prefs.save(controls)
        manipulator.shutdown()
        playback.detachSurface()
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
        super.onDestroy()
    }

    // ================================================================ Dart 通道

    private val bridgeListener = object : ImmersiveBridge.Listener {

        override fun onPresent(request: ImmersiveVideoRequest) {
            runOnUiThread {
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
        controls.progress = 0f
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
        endScrub()
        endSphereGrab(hideControls = false)
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

    private fun headPose(): Pose? = systemManager
        .findSystem<PlayerBodyAttachmentSystem>()
        .tryGetLocalPlayerAvatarBody()
        ?.head
        ?.tryGetComponent<Transform>()
        ?.transform

    /**
     * **真的跟踪到了**的头部位姿。
     *
     * ⛔ 头部实体一建出来 `Transform` 就在，但值是单位位姿（原点、朝 +Z），要过几帧追踪才写进来。
     * 之前只判 `!= null`，于是首帧就拿「地板高度」摆了面板并标成「已按头部摆过」——躺着进应用
     * 时「2D 面板非常靠下」就是这么来的（用户 2026-09-05）。原点附近一律当没跟踪到。
     */
    private fun trackedHeadPose(): Pose? {
        val p = headPose() ?: return null
        if (p.t.length() < HEAD_ORIGIN_EPS_M) return null
        return p
    }

    /** 连续多少帧拿到了跟踪位姿。摆位要等它稳定几帧，别拿刚写进来的第一帧。 */
    private var headReadyFrames = 0
    private var sceneTicks = 0

    private fun headTrackingReady(): Boolean = headReadyFrames >= HEAD_SETTLE_FRAMES

    /** 等了太久还没跟踪到（3DoF 一类）：不再等，按兜底摆。 */
    private fun headSettleTimedOut(): Boolean = sceneTicks >= HEAD_SETTLE_TIMEOUT_TICKS

    /**
     * 当下的「视线坐标系」：头部位置 + 沿头部前向、去掉 roll 的朝向，再整体**压低
     * [GAZE_DROP_DEG]**。人自然注视比头部轴线低十来度，按轴线摆的东西一律偏上（真机反馈两轮）。
     *
     * ⛔ 不再走欧拉角：躺着看时视线接近竖直，欧拉分解到万向锁附近，yaw 随机、「去 roll」也失义，
     * 摆出来的面板方向不可预期。改成直接用前向量搭正交基（[frameAlong]），
     * 「压低」= 前向量绕右轴朝这个基的 −上 转 12°——躺着时就是朝下巴方向，正是自然注视。
     */
    private fun gazeFrame(): Pose? {
        val head = trackedHeadPose() ?: return null
        return frameAlong(head.t, head.forward(), head.up(), dropDeg = GAZE_DROP_DEG)
    }

    /**
     * 以 [forward] 为前向搭一个去 roll 的坐标系。
     *
     * 参考「上」平时取世界上（面板与地面垂直）；前向接近竖直（躺着 / 仰头）时世界上退化，
     * 改用 [headUp]（头自己的上），面板就以头顶方向为上，正对着躺着的人。
     */
    private fun frameAlong(origin: Vector3, forward: Vector3, headUp: Vector3, dropDeg: Float): Pose {
        val f0 = forward.normalize()
        val worldUp = Vector3(0f, 1f, 0f)
        val refUp = if (abs(f0.dot(worldUp)) < VERTICAL_GAZE_COS) worldUp else headUp.normalize()
        val right = refUp.cross(f0).normalize()
        val up0 = f0.cross(right).normalize()
        val d = dropDeg * (Math.PI / 180.0).toFloat()
        val f = (f0 * cos(d) - up0 * sin(d)).normalize()
        val up = (up0 * cos(d) + f0 * sin(d)).normalize()
        return Pose(origin, quaternionFromBasis(right, up, f))
    }

    /**
     * 由正交基（右 / 上 / 前）造四元数，并**用 SDK 自己的 `Pose.forward()/up()` 验证**四元数的
     * 分量顺序与旋转约定：四种候选（w 在前 / 在后 × 原/共轭）里取前、上都对得上的那个。
     * 只在第一次自检时打一行日志。
     */
    private fun quaternionFromBasis(right: Vector3, up: Vector3, forward: Vector3): Quaternion {
        val m00 = right.x; val m01 = up.x; val m02 = forward.x
        val m10 = right.y; val m11 = up.y; val m12 = forward.y
        val m20 = right.z; val m21 = up.z; val m22 = forward.z
        val w: Float; val x: Float; val y: Float; val z: Float
        val trace = m00 + m11 + m22
        if (trace > 0f) {
            val s = sqrt(trace + 1f) * 2f
            w = 0.25f * s; x = (m21 - m12) / s; y = (m02 - m20) / s; z = (m10 - m01) / s
        } else if (m00 > m11 && m00 > m22) {
            val s = sqrt(1f + m00 - m11 - m22) * 2f
            w = (m21 - m12) / s; x = 0.25f * s; y = (m01 + m10) / s; z = (m02 + m20) / s
        } else if (m11 > m22) {
            val s = sqrt(1f + m11 - m00 - m22) * 2f
            w = (m02 - m20) / s; x = (m01 + m10) / s; y = 0.25f * s; z = (m12 + m21) / s
        } else {
            val s = sqrt(1f + m22 - m00 - m11) * 2f
            w = (m10 - m01) / s; x = (m02 + m20) / s; y = (m12 + m21) / s; z = 0.25f * s
        }
        val candidates = listOf(
            "wxyz" to Quaternion(w, x, y, z),
            "xyzw" to Quaternion(x, y, z, w),
            "wxyz*" to Quaternion(w, -x, -y, -z),
            "xyzw*" to Quaternion(-x, -y, -z, w),
        )
        val order = quatOrder
        if (order != null) return candidates.first { it.first == order }.second
        for ((name, q) in candidates) {
            val probe = Pose(Vector3(0f, 0f, 0f), q)
            if (probe.forward().dot(forward) > 0.99f && probe.up().dot(up) > 0.99f) {
                quatOrder = name
                Log.i(TAG, "IMMERSIVE quaternion convention = $name")
                return q
            }
        }
        Log.w(TAG, "IMMERSIVE quaternion convention 自检全部失败，退回 wxyz")
        quatOrder = "wxyz"
        return candidates[0].second
    }

    /** 自检出的四元数分量约定，见 [quaternionFromBasis]。 */
    private var quatOrder: String? = null

    /** 拿不到头部位姿时的兜底锚点：原点上方站姿眼高、朝 +Z。 */
    private fun fallbackFrame(): Pose = Pose(Vector3(0f, FALLBACK_EYE_HEIGHT_M, 0f), Quaternion(0f, 0f, 0f))

    private fun currentAnchor(): Pose = anchor ?: captureAnchor()

    private fun captureAnchor(): Pose {
        val g = anchorFromUiPanel() ?: gazeFrame()
        anchorIsFallback = g == null
        // 锚点重来（首次 / 重定向 / 跨家族换片）：球幕拖过的视角与推过的远近一并归零。
        sphereForwardOverride = null
        sphereOffsetM = 0f
        return (g ?: fallbackFrame()).also { anchor = it }
    }

    /**
     * 从 2D 面板上点「播放」进影院：面板此刻在哪、用户就正看着哪 —— 幕布落在**面板的方向**上。
     *
     * ⛔ 不能再按视线压一次 12°：面板本来就是按「视线 − 12°」摆的，用户看着它按播放，此刻视线就在
     * 那个方向，再压一次幕布就比面板还低一截（「首次打开沉浸视频，播放器位置校准不佳」）。
     * 用户拖过面板的话，落点也跟着它 —— 那正是用户自己挑的舒服位置。面板没露面（刚起动、刚重置）
     * 时返回 null，退回视线。
     */
    private fun anchorFromUiPanel(): Pose? {
        if (!uiPanelPlacedByHead) return null
        val head = trackedHeadPose() ?: return null
        val panel = uiPanelEntity?.tryGetComponent<Transform>()?.transform ?: return null
        if (panel.t.y < -10f) return null // 停在脚下 100m 的是藏起来的
        val dir = panel.t - head.t
        if (dir.length() < 0.3f) return null
        return frameAlong(head.t, dir, head.up(), dropDeg = 0f)
    }

    /** 平面/弧幕：沿锚点视线摆在「距离」处，按「偏移」沿锚点的上方向挪，弧幕再把轴心退一个半径。 */
    private fun geometricScreenPose(): Pose {
        val a = currentAnchor()
        val f = a.forward()
        val u = a.up()
        val radius = ScreenGeometry.radiusFor(curArc, curWidth)
        val pos = a.t + f * (controls.screenDistance - radius) + u * controls.screenOffset
        return Pose(pos, a.q)
    }

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
        else -> screenSurfaceOverride?.let { surfaceToEntityPose(it) } ?: geometricScreenPose()
    }

    /** 弧面中心 → 实体锚点（圆柱轴心在面后一个半径处；平面半径为 0 就是自己）。 */
    private fun surfaceToEntityPose(surface: Pose): Pose {
        val radius = ScreenGeometry.radiusFor(curArc, curWidth)
        return Pose(surface.t - surface.forward() * radius, surface.q)
    }

    /** 实体锚点 → 弧面中心。 */
    private fun entityToSurfacePose(entity: Pose): Pose {
        val radius = ScreenGeometry.radiusFor(curArc, curWidth)
        return Pose(entity.t + entity.forward() * radius, entity.q)
    }

    /**
     * 距离/偏移/半径改了：只挪位置，不重建（无接缝）。
     *
     * ⛔ 位置要**同时**直接写到场景对象上：ECS 的 Transform 组件要到下一帧才由系统应用，
     * 而 `reshape()` 是立即生效的 —— 差这一帧就是「切曲面时画面猛进猛退、抖动」的根因
     * （每帧都先按新半径 + 旧位置画一次）。
     */
    private fun applyScreenTransform() {
        val pose = screenPose()
        screenEntity?.setComponent(Transform(pose))
        screenPanel?.let {
            it.setPosition(pose.t)
            it.setRotationQuat(pose.q)
        }
        syncBufferingPose()
    }

    /** 2D 应用面板沿视线 1.8m 处、正对头部。 */
    private fun uiPanelPose(): Pose {
        val g = gazeFrame() ?: fallbackFrame()
        return Pose(g.t + g.forward() * UI_PANEL_DISTANCE_M, g.q)
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
        entity.setComponent(Transform(pose))
        uiPanel?.let { it.setPosition(pose.t); it.setRotationQuat(pose.q) }
        uiPanelShown = show
        uiPanelPlacedByHead = show && ready
        if (show) Log.i(TAG, "IMMERSIVE ui panel placed byHead=$ready head=${trackedHeadPose()?.t}")
    }

    /** UI 面板是否已经按真实头部位姿摆过（首次进入时头部可能还没就绪）。 */
    private var uiPanelPlacedByHead = false

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

    /** 控制面板「摆到面前」的落点：当下视线方向 1.5m 处、略偏下，面对头部。 */
    private fun controlsPoseInFront(): Pose {
        val g = gazeFrame() ?: fallbackFrame()
        return Pose(g.t + g.forward() * CONTROLS_DISTANCE_M + g.up() * CONTROLS_DROP_M, g.q)
    }

    /** 平幕可见面中心到头部的距离；球幕 / 没幕布为 null。 */
    private fun screenSurfaceDistance(): Float? {
        if (!controls.format.isFlat) return null
        val entity = screenEntity?.tryGetComponent<Transform>()?.transform ?: return null
        val head = trackedHeadPose()?.t ?: currentAnchor().t
        return (entityToSurfacePose(entity).t - head).length()
    }

    /**
     * 控制面板必须**物理上**在幕布前面。
     *
     * 合成层次序（zIndex）只管画：幕布被拉到比面板还近时面板照样画在上面，但 ISDK 的射线按几何命中，
     * 打到的是更近的幕布 —— 用户 2026-09-05：「播放器确实优先展示了，但射线选择的实际上是视频」。
     * 所以每帧看一眼：面板本来的位置（[controlsBasePose]）比幕布远，就沿「头 → 面板」把它拉到幕布前
     * [CONTROLS_SCREEN_GAP_M]；幕布再推远了就放回原位。只挪位置、不改朝向。
     */
    private fun syncControlsDepth() {
        val entity = controlsEntity ?: return
        val base = controlsBasePose ?: return
        val head = trackedHeadPose()?.t ?: currentAnchor().t
        val dir = base.t - head
        val len = dir.length()
        if (len < 0.05f) return
        val limit = screenSurfaceDistance()?.let { it - CONTROLS_SCREEN_GAP_M }?.coerceAtLeast(CONTROLS_MIN_DISTANCE_M)
        val target = if (limit != null && len > limit) head + dir * (limit / len) else base.t
        val current = entity.tryGetComponent<Transform>()?.transform?.t ?: return
        if ((current - target).length() < 0.002f) return
        val pose = Pose(target, base.q)
        entity.setComponent(Transform(pose))
        controlsPanel?.let { it.setPosition(pose.t); it.setRotationQuat(pose.q) }
    }

    /** 这个落点还在视线前方吗（转过身之后要不要重新摆到面前）。 */
    private fun isRoughlyInFront(pose: Pose): Boolean {
        val g = gazeFrame() ?: return true
        val d = pose.t - g.t
        val len = d.length()
        if (len < 0.05f) return true
        return g.forward().dot(d) / len >= SUMMON_FOV_COS
    }

    /** 重新捕获锚点并把幕布、面板都按新视线重摆。 */
    private fun recenterEverything() {
        captureAnchor()
        screenSurfaceOverride = null
        applyScreenTransform()
        // 浏览态：把 2D 应用面板也摆回视线正前方（用户反馈「重置后 2D 画面位置过于靠上」）。
        if (argUrl.isNullOrBlank()) placeUiPanel(visible = true)
        if (controlsEntity != null) {
            val pose = controlsPoseInFront()
            controlsEntity?.setComponent(Transform(pose))
            controlsPanel?.let { it.setPosition(pose.t); it.setRotationQuat(pose.q) }
            lastControlsPose = pose
            controlsBasePose = pose
        } else {
            // 面板收着时也要「重置」：忘掉它收起前的位置，下次唤出按新视线摆到面前。
            // 否则系统级重定向（看着捏合中的手指）之后幕布挪了、面板却还从旧世界坐标冒出来（用户 2026-09-05）。
            lastControlsPose = null
        }
        // 球幕的缓冲指示位置是创建那刻定死的，重定向后也按新视线重放。
        bufferingFrozenPose = null
    }

    // ================================================================ 幕布

    /**
     * 重建幕布实体（片子换了 / 投影家族换了 / 首次进入）。
     *
     * @param keepPlayback 片子没变，只是几何变了：播放器留着，只换 Surface。
     */
    private fun rebuildScreen(keepPlayback: Boolean = false) {
        // 只有「上一块也是平幕」时才把它的位置带过来。⛔ 球幕实体的位置就是你的头部位置 ——
        // 从全景切回平面时若把它当成「抓着挪过的平幕位置」，平幕会被摆进眼睛里（真机反馈：
        // 「切回后画面不显示，要点重新居中才出来」）。
        if (controls.format.isFlat && screenEntityIsFlat) {
            screenEntity?.tryGetComponent<Transform>()?.transform?.let { screenSurfaceOverride = entityToSurfacePose(it) }
        } else {
            screenSurfaceOverride = null
        }
        manipulator.detach(WindowKind.SCREEN)
        // 缓冲指示与幕布同形同位，幕布换了它也得重建（旧的形状 / 位置留着就会「跳」）。
        destroyBufferingEntity()
        // ⛔ 顺序：先摘 Surface 再销毁实体，否则播放器往已释放的缓冲上画。
        if (keepPlayback) playback.detachSurface() else playback.release()
        screenEntity?.destroy()
        screenEntity = null
        screenPanel = null

        val idle = argUrl.isNullOrBlank()
        if (idle) playback.release()

        // ⛔ 锚点要在 UI 面板停走之前捕获：从面板点播放进影院，幕布落在面板的方向上（见 anchorFromUiPanel）。
        if (!idle && anchor == null) captureAnchor()

        // 看视频时 UI 面板让位：藏起 + 让 Flutter 停止出帧（destroy 会连 Activity 一起杀掉，代价太大）。
        ImmersiveBridge.setPanelRenderingPaused(!idle)
        if (argUiPanel && uiPanelEntity == null) createUiPanel()
        placeUiPanel(visible = idle)

        if (idle) {
            hideControls()
            controls.title = ""
            controls.notice = null
            controls.buffering = false
            screenSurfaceOverride = null
            anchor = null
            syncBufferingIndicator()
            Log.i(TAG, "IMMERSIVE 无片源，只留 UI 面板，不建幕布")
            return
        }

        // 这个画面比例上次调过的距离 / 幕宽先恢复回来，再按它建幕布。
        applyLayoutForAspect()

        // 形状参数直接落到目标值（首次进入没有过渡可言）。
        curArc = controls.curve.arcDegrees
        curWidth = controls.screenWidth
        curAspect = ScreenGeometry.screenAspect(controls, videoWidth, videoHeight)
        animating = false

        val flat = controls.format.isFlat
        // 抓 / 挪 / 缩放不再挂 ISDK 的 Grabbable / IsdkPanelResize：平幕与弧幕都由 WindowManipulator 接管。
        val entity = Entity.create(Panel(R.id.vr_video_panel), Transform(screenPose()), Visible(true))
        screenEntity = entity
        screenEntityIsFlat = flat
        syncIsdkScreenShape()
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            val panel = so as? PanelSceneObject
            screenPanel = panel
            runCatching { panel?.layer?.setZIndex(if (flat) Z_SCREEN else Z_SPHERE) }
        }
        if (flat) manipulator.attach(screenHost)
        showControls()
        syncBufferingIndicator()
    }

    private fun mediaSettings(): MediaPanelSettings = MediaPanelSettings(
        shape = ScreenGeometry.shapeFor(controls.format, curArc, curWidth, curAspect),
        display = PixelDisplayOptions(width = videoWidth, height = videoHeight),
        rendering = MediaPanelRenderOptions(
            stereoMode = ScreenGeometry.stereoMode(controls.format, controls.forceMono),
            zIndex = if (controls.format.isFlat) Z_SCREEN else Z_SPHERE,
        ),
    )

    /**
     * 发起一次形状过渡：从当前实际值插值到 state 里的目标值。
     *
     * @param durationMs 0 = 立刻到位（换立体模式这类没有中间态的）。滑块连续拖动给个很短的时长，
     *   逐帧跟手；换屏幕类型给 [CURVE_ANIM_MS]，有动画。
     */
    private fun requestShape(durationMs: Long) {
        if (argUrl.isNullOrBlank()) return
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
        val targetWidth = controls.screenWidth
        val targetAspect = ScreenGeometry.screenAspect(controls, videoWidth, videoHeight)
        val t = if (animDurationMs <= 0L) 1f else ((now - animStartAt).toFloat() / animDurationMs).coerceIn(0f, 1f)
        val k = t * t * (3f - 2f * t) // smoothstep
        curArc = animFromArc + (targetArc - animFromArc) * k
        curWidth = animFromWidth + (targetWidth - animFromWidth) * k
        curAspect = animFromAspect + (targetAspect - animFromAspect) * k
        if (t >= 1f) animating = false
        reshapeNow()
    }

    /** 用当前 cur* 参数原地重塑幕布；reshape 失败退回重建。 */
    private fun reshapeNow() {
        val panel = screenPanel
        if (panel == null || screenEntity == null) {
            animating = false
            rebuildScreen(keepPlayback = true)
            return
        }
        val ok = runCatching {
            panel.reshape(mediaSettings().toPanelConfigOptions())
            playback.attachSurface(panel.surface)
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
        bufferingPanel?.let { runCatching { it.reshape(bufferingSettings().toPanelConfigOptions()) } }
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
            entity.setComponent(IsdkCurvedPanel(curArc))
        } else {
            runCatching { entity.removeComponent<IsdkCurvedPanel>() }
        }
    }

    private fun createUiPanel() {
        uiBaseSize = Vector2(prefs.uiPanelWidth, prefs.uiPanelHeight)
        uiScale = Vector2(1f, 1f)
        val entity = Entity.create(Panel(R.id.vr_ui_panel), Transform(uiPanelPose()), Visible(true))
        uiPanelEntity = entity
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            val panel = so as? PanelSceneObject
            uiPanel = panel
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
        val onScreen = !argUrl.isNullOrBlank() && screenEntity != null
        val buffering = controls.buffering && onScreen
        if (buffering) {
            if (bufferingSince == 0L) bufferingSince = now
        } else {
            bufferingSince = 0L
        }
        // 同一块叠层也给摇杆拖动进度的预览用：拖动一开始就露面，不等缓冲那 350ms。
        val want = (scrubbing && onScreen) || (buffering && now - bufferingSince >= BUFFERING_SHOW_DELAY_MS)
        if (want) {
            bufferingDestroyAt = 0L
            if (bufferingEntity == null) createBufferingEntity()
            bufferingState.visible = true
        } else if (bufferingEntity != null) {
            if (bufferingState.visible) {
                bufferingState.visible = false
                bufferingDestroyAt = now + BUFFERING_ANIM_MS + 40L
            } else if (bufferingDestroyAt != 0L && now >= bufferingDestroyAt) {
                destroyBufferingEntity()
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
        lastInteractionAt = SystemClock.uptimeMillis()
        if (controlsEntity != null) return
        val saved = lastControlsPose
        val restore = saved != null && (!summoned || !controls.summonInFront || isRoughlyInFront(saved))
        val pose = if (restore) saved!! else controlsPoseInFront()
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
            so.addInputListener(hoverListener)
            val panel = so as? PanelSceneObject
            controlsPanel = panel
            runCatching { panel?.layer?.setZIndex(Z_CONTROLS) }
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
            if (!controls.format.isFlat || !screenEntityIsFlat) return null
            val entity = screenEntity?.tryGetComponent<Transform>()?.transform ?: return null
            return entityToSurfacePose(entity)
        }

        override fun size() = Vector2(curWidth, curWidth / curAspect)
        override fun arcDegrees() = if (curArc >= ScreenGeometry.MIN_ARC_DEGREES) curArc else 0f

        override fun moveTo(surface: Pose) {
            screenSurfaceOverride = surface
            applyScreenTransform()
        }

        override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) {
            screenSurfaceOverride = surface
            controls.screenWidth = size.x.coerceIn(SCREEN_MIN_WIDTH_M, SCREEN_MAX_WIDTH_M)
            animating = false
            curWidth = controls.screenWidth
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
        override val cornerRadiusM = CONTROLS_CORNER_M
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
        override val cornerRadiusM = UI_PANEL_CORNER_M
        override val zIndex = Z_UI

        override fun surfacePose(): Pose? =
            if (!uiPanelShown) null else uiPanelEntity?.tryGetComponent<Transform>()?.transform

        override fun size() = Vector2(uiBaseSize.x * uiScale.x, uiBaseSize.y * uiScale.y)

        override fun moveTo(surface: Pose) {
            uiPanelEntity?.setComponent(Transform(surface))
            uiPanel?.let { it.setPosition(surface.t); it.setRotationQuat(surface.q) }
        }

        // `PanelSceneObject.resize` 在 0.13.2 里标着 experimental；ISDK 自己的 Relayout 走的就是它。
        @OptIn(com.meta.spatial.core.SpatialSDKExperimentalAPI::class)
        override fun resizeTo(size: Vector2, surface: Pose, commit: Boolean) {
            uiScale = Vector2(size.x / uiBaseSize.x, size.y / uiBaseSize.y)
            val scale = Vector3(uiScale.x, uiScale.y, 1f)
            uiPanelEntity?.setComponent(Scale(scale))
            uiPanel?.setScale(scale)
            moveTo(surface)
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
        updateTransport()
        status.clockTextIfChanged(System.currentTimeMillis())?.let { controls.clockText = it }
        input.poll()
        settleHeadPlacement()
        // 抓 / 挪 / 缩放先裁决：按在窗框上的「选择」不会再落到下面的「点一下 toggle」。
        manipulator.tick(input)
        if (!argUrl.isNullOrBlank()) handleInput(now) else handleBrowseInput()
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
        sceneTicks++
        if (trackedHeadPose() == null) {
            headReadyFrames = 0
        } else if (headReadyFrames < HEAD_SETTLE_FRAMES) {
            headReadyFrames++
        }
        val ready = headTrackingReady()
        if (!ready && !headSettleTimedOut()) return
        if (argUrl.isNullOrBlank()) {
            if (!uiPanelPlacedByHead) placeUiPanel(visible = true)
        } else if (anchorIsFallback && ready) {
            captureAnchor()
            screenSurfaceOverride = null
            applyScreenTransform()
        }
    }

    private fun updateTransport() {
        if (!playback.isAlive) return
        if (controls.isPlaying != playback.isPlaying) controls.isPlaying = playback.isPlaying
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
        val e = input.events
        for (i in 0..1) {
            val bit = 1 shl i
            if ((e.selectDown and bit) != 0) onSelectDown(i, now)
            if ((e.selectUp and bit) != 0) onSelectUp(i, now)
        }
        // 抓握扳机按下就抓幕布拖，不用瞄准（用户 2026-09-05）。manipulator.tick 已先跑过：瞄在控制面板 / 窗框上的
        // 那只手已经开了会话（isBusy），这里不抢；球幕没有幕布可抓。
        updateSphereGrab(now)
        for (i in 0..1) {
            val bit = 1 shl i
            if ((e.gripDown and bit) != 0 && !manipulator.isBusy(i) && screenEntity != null && sphereGrabHand < 0) {
                if (controls.format.isFlat) manipulator.startGrab(i, WindowKind.SCREEN, input) else startSphereGrab(i, now)
            }
        }
        // ⛔ 射线悬在面板上时 A 键是给面板的（ISDK 把它当点击送进去），这里再切一次播放/暂停就穿透了
        // （用户 2026-09-05：「用 A 键点操作栏，画面跟着暂停」）。扳机那条路早就这么判了（onSelectDown）。
        if (e.primaryTap && controls.controllerTapPlayPause && !controlsHovered) controlsCallbacks.onPlayPause()
        // B/Y = 「返回」：面板开着就收面板，面板收着就退出影院回应用 —— 与浏览态里 B = 上一页同一条语义。
        if (e.back) {
            if (controlsEntity != null) {
                hideControls()
            } else {
                Log.i(TAG, "IMMERSIVE back button -> back to app")
                backToApp()
            }
        }
        // 摇杆左右：按住拖动进度、越久越快，松开那一刻才 seek（预览在幕布叠层 + 面板进度条上）。
        when {
            e.seekLeft != e.seekRight -> updateScrub(now, forward = e.seekRight)
            scrubbing -> commitScrub()
        }
        if (e.menu) {
            showControls(summoned = true)
            controls.route = ControlsRoute.SETTINGS
        }
        if (manipulator.isMoving) {
            // 抓着窗的时候摇杆上下归它：推远 / 拉近。
            if (e.volumeUp) manipulator.nudgeDistance(NUDGE_STEP) else if (e.volumeDown) manipulator.nudgeDistance(-NUDGE_STEP)
        } else if ((e.volumeUp || e.volumeDown) && screenEntity != null) {
            // 不抓也能推远 / 拉近（用户 2026-09-05：「往前推往后推控制播放器离我的远近」，全景片也要）。
            // 摇杆不再管音量：音量在面板的 🔊 弹层里。
            if (controls.format.isFlat) {
                nudgeScreenDistance(if (e.volumeUp) SCREEN_NUDGE_STEP else -SCREEN_NUDGE_STEP)
            } else {
                nudgeSphereDistance(if (e.volumeUp) SPHERE_NUDGE_STEP_M else -SPHERE_NUDGE_STEP_M)
            }
        }
    }

    /**
     * 浏览态（没有片源、只有 Flutter 面板）：手柄 B/Y = 系统返回键，派给面板里的 MainActivity。
     *
     * 只接这一个键。捏合 / 扳机 / 摇杆在浏览态都是 ISDK 交给面板的正常输入，这里抢不得。
     */
    private fun handleBrowseInput() {
        val e = input.events
        if (e.back) {
            Log.i(TAG, "IMMERSIVE back button -> MainActivity back")
            ImmersiveBridge.requestBack()
        }
        if (manipulator.isMoving) {
            if (e.volumeUp) manipulator.nudgeDistance(NUDGE_STEP) else if (e.volumeDown) manipulator.nudgeDistance(-NUDGE_STEP)
        }
    }

    /**
     * 「选择」按下：在面板上就是操作面板，否则记为「点一下」候选，等松开裁决。
     * 捏住移动（拖面板 / 拖幕布 / 拉角缩放）走 ISDK，不会到达 toggle。
     */
    private fun onSelectDown(hand: Int, now: Long) {
        // 按在面板上是操作面板；按在窗框上已经被 WindowManipulator 接走（抓窗），都不是「点一下」。
        if (controlsHovered || manipulator.isBusy(hand)) {
            lastInteractionAt = now
            tapCandidate[hand] = false
            return
        }
        tapCandidate[hand] = true
        tapDownAt[hand] = now
        tapDownPos[hand] = input.handPositions[hand]
    }

    private fun onSelectUp(hand: Int, now: Long) {
        if (!tapCandidate[hand]) return
        tapCandidate[hand] = false
        val held = now - tapDownAt[hand]
        val from = tapDownPos[hand]
        val to = input.handPositions[hand]
        val moved = if (from != null && to != null) from.distanceTo(to) else 0f
        if (held > TAP_MAX_MS || moved > TAP_MAX_MOVE_M) return
        // 松开时面板那条路的触碰事件早就到了：期间碰过面板就不是「面板外」。
        if (controlsHovered || lastPanelTouchAt >= tapDownAt[hand] - 60L) {
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
     * 刚推上去先走一格 [SCRUB_TAP_MS]（一下 = 老的 ±10 秒），再按 [scrubRateMsPerSec] 加速到分 / 小时量级。
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

    /**
     * 摇杆上下把幕布沿「头 → 幕心」的方向推远 / 拉近（每帧按比例，按住约 1 秒推 1.4 倍）。
     * 用户抓着挪过（有 [screenSurfaceOverride]）就动那份位置；否则动设置里的观看距离并落偏好。
     */
    private fun nudgeScreenDistance(delta: Float) {
        val override = screenSurfaceOverride
        if (override != null) {
            val head = trackedHeadPose()?.t ?: currentAnchor().t
            val d = override.t - head
            val len = d.length()
            if (len < 0.05f) return
            val next = (len * (1f + delta)).coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M)
            screenSurfaceOverride = Pose(head + d * (next / len), override.q)
        } else {
            controls.screenDistance = (controls.screenDistance * (1f + delta)).coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M)
            markPrefsDirty()
        }
        applyScreenTransform()
        rememberLayoutForAspect()
        lastInteractionAt = SystemClock.uptimeMillis()
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
        if (!controls.format.isFlat) return
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
        if (!controls.format.isFlat || screenEntity == null) return
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
        sphereGrabForward0 = sphereForwardOverride ?: currentAnchor().forward()
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

    /** 按住越久越快：1s 内 30s/s，3s 内 2min/s，6s 内 10min/s，之后 30min/s（长片按小时量级跳）。 */
    private fun scrubRateMsPerSec(heldMs: Long): Long = when {
        heldMs < 1_000L -> 30_000L
        heldMs < 3_000L -> 120_000L
        heldMs < 6_000L -> 600_000L
        else -> 1_800_000L
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
        if (!controls.isPlaying || controls.buffering ||
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
            controls.progress = 0f
            controls.buffering = true
            playback.setSpeed(controls.speed)
            applyRepeatMode()
        }
    }

    private fun applyVolume() {
        playback.setVolume(if (controls.muted) 0f else controls.volume)
    }

    private fun applyRepeatMode() {
        playback.setRepeatOne(controls.repeatMode == RepeatMode.ONE)
    }

    private fun applyScene() {
        val passthrough = controls.scene == SceneKind.PASSTHROUGH
        runCatching { scene.enablePassthrough(passthrough) }
            .onFailure { Log.w(TAG, "IMMERSIVE enablePassthrough 失败", it) }
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
            if (ScreenGeometry.sameFamily(before, format)) requestShape(0L) else rebuildScreen(keepPlayback = true)
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

        override fun onPickScene(scene: SceneKind) {
            touched()
            controls.scene = scene
            markPrefsDirty()
            applyScene()
        }

        override fun onScreenDistance(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenDistance = meters.coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M)
            screenSurfaceOverride = null
            applyScreenTransform()
            markPrefsDirty()
            rememberLayoutForAspect()
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
            val (queueId, item) = adjacentPlayable(forward) ?: return
            playFromQueue(queueId, item.id)
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
            touched()
            controls.route = route
            controls.volumePopupOpen = false
            if (route == ControlsRoute.PLAYLIST) {
                if (playlistSections.isEmpty()) beginPlaylistWait()
                ImmersiveBridge.requestPlaylist()
            }
        }

        override fun onPanelTouched() {
            val now = SystemClock.uptimeMillis()
            lastPanelTouchAt = now
            lastInteractionAt = now
        }

        override fun onHidePanel() {
            touched()
            hideControls()
        }

        override fun onBackToApp() {
            touched()
            backToApp()
        }
    }

    // ================================================================ 面板注册

    // 这个方法在 `super.onCreate()` 内部被调用，读不到 intent —— 无条件注册，是否出现在场景里由 Entity 决定。
    override fun registerPanels(): List<PanelRegistration> = listOf(
        ActivityPanelRegistration(
            R.id.vr_ui_panel,
            { MainActivity::class.java },
            {
                // 尺寸取用户上次拉到的（偏好）；dp 按 640dp/m 同比，字号不随窗大小变。
                val w = prefs.uiPanelWidth
                val h = prefs.uiPanelHeight
                UIPanelSettings(
                    shape = QuadShapeOptions(width = w, height = h),
                    display = DpDisplayOptions(w * UI_DP_PER_METER, h * UI_DP_PER_METER, UI_PANEL_DPI),
                    // 窗口透明 + Flutter 根部裁圆角（MainActivity.getBackgroundMode / my_app.dart）：
                    // 面板要按 alpha 合成，四角才透得出后面的场景。
                    rendering = UIPanelRenderOptions(
                        renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
                    ),
                )
            },
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
            surfaceConsumer = { _, surface -> startPlayback(surface) },
            settingsCreator = { mediaSettings() },
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
        private const val DEFAULT_VIEW_DISTANCE_M = 2.4f
        private const val DEFAULT_SCREEN_WIDTH_M = 3.2f
        private const val SCREEN_MIN_DISTANCE_M = 1.2f
        private const val SCREEN_MAX_DISTANCE_M = 8.0f

        /** UI 面板的几何：1.8m 处 1.6m 宽 ≈ 47° 水平张角，沿视线摆。 */
        private const val UI_PANEL_DISTANCE_M = 1.8f

        /** 2D 应用面板：1024dp / 1.6m = 640dp/m，288dpi；拉角只改米数与像素，不改这两个。 */
        private const val UI_DP_PER_METER = 1024f / PlayerPrefs.DEFAULT_UI_PANEL_WIDTH_M
        private const val UI_PANEL_DPI = 288

        /** 2D 面板的圆角：Flutter 侧裁 20dp（`kXrPanelCornerRadiusDp`），换算成米给窗框用。 */
        private const val UI_PANEL_CORNER_M = 20f / UI_DP_PER_METER
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

        /** 抓着窗时摇杆每帧推远 / 拉近的比例。 */
        private const val NUDGE_STEP = 0.02f

        /** 不抓时摇杆上下推幕布的每帧比例（72Hz 下按住 1s ≈ ×1.4）。 */
        private const val SCREEN_NUDGE_STEP = 0.005f

        /** 拖视角时俯仰上限的正弦（sin 80°）。 */
        private const val SPHERE_MAX_PITCH_SIN = 0.985f

        /** 球幕每帧推远 / 拉近的米数（72Hz 下 ≈ 8.6m/s）与偏移上限（半径的一半）。 */
        private const val SPHERE_NUDGE_STEP_M = 0.12f
        private const val SPHERE_OFFSET_MAX_M = ScreenGeometry.SPHERE_RADIUS * 0.5f

        /**
         * 控制面板几何：逻辑尺寸固定 1100 × 360dp，物理 1.5m 宽，沿视线 1.5m 处、比视线中心低 0.25m。
         * 72dp 圆钮 = 0.098m @1.5m ≈ 3.7°，高于官方 2.5–3° 下限。
         */
        private const val CONTROLS_DISTANCE_M = 1.5f
        private const val CONTROLS_DROP_M = -0.12f

        /** 面板至少压在幕布前面这么多、且离头不近于这么多（幕布拉到脸前时面板跟着到脸前）。 */
        private const val CONTROLS_SCREEN_GAP_M = 0.15f
        private const val CONTROLS_MIN_DISTANCE_M = 0.45f

        /** 摆位视线比头部轴线低这么多度。 */
        private const val GAZE_DROP_DEG = 12f
        private const val CONTROLS_WIDTH_M = 1.5f
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

        /** 头部位姿离原点近于这个数 = 还没跟踪到（组件默认的单位位姿）。 */
        private const val HEAD_ORIGIN_EPS_M = 0.05f

        /** 跟踪位姿连续这么多帧才拿来摆位；等不到这么多 tick 就按兜底摆。 */
        private const val HEAD_SETTLE_FRAMES = 8
        private const val HEAD_SETTLE_TIMEOUT_TICKS = 120

        /** 前向与世界上的夹角余弦超过它 = 视线接近竖直（躺着 / 仰头），去 roll 改用头自己的上。 */
        private const val VERTICAL_GAZE_COS = 0.85f

        /** 合成层次序：不靠深度排。 */
        private const val Z_SPHERE = -1
        private const val Z_SCREEN = 0
        private const val Z_UI = 10
        private const val Z_CONTROLS = 20
        private const val Z_BUFFERING = 30

        /** 「还算在视线前方」的判据：cos 60°。 */
        private const val SUMMON_FOV_COS = 0.5f

        /** 面板隐身后再等这么多帧才销毁。 */
        private const val DOOMED_TICKS = 3

        /** 「点一下」的判据：捏合不超过这么久、手不超过这么远。 */
        private const val TAP_MAX_MS = 400L
        private const val TAP_MAX_MOVE_M = 0.04f

        private const val CURVE_ANIM_MS = 320L
        private const val SLIDER_ANIM_MS = 60L
        private const val PREFS_FLUSH_MS = 1000L

        /** 摇杆刚推上去先走的一格（一下 = ±10 秒，与老键位同口径）。 */
        private const val SCRUB_TAP_MS = 10_000L

        /** 续播位置至少这么多才提示（与 2D 的 kMinResumeTipPosition 同口径）；提示停留时长。 */
        private const val RESUME_TIP_MIN_MS = 3_000L
        private const val RESUME_TIP_MS = 10_000L
    }
}
