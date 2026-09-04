package m.c.g.a.i_iwara.vr

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Debug
import android.os.SystemClock
import android.util.Log
import android.view.Surface
import com.meta.spatial.compose.ComposeFeature
import com.meta.spatial.compose.ComposeViewPanelRegistration
import com.meta.spatial.core.Entity
import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.SpatialFeature
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import com.meta.spatial.isdk.IsdkFeature
import com.meta.spatial.isdk.IsdkPanelResize
import com.meta.spatial.isdk.ResizeMode
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
import com.meta.spatial.toolkit.Grabbable
import com.meta.spatial.toolkit.MediaPanelRenderOptions
import com.meta.spatial.toolkit.MediaPanelSettings
import com.meta.spatial.toolkit.Panel
import com.meta.spatial.toolkit.PanelRegistration
import com.meta.spatial.toolkit.PanelRenderMode
import com.meta.spatial.toolkit.PixelDisplayOptions
import com.meta.spatial.toolkit.PlayerBodyAttachmentSystem
import com.meta.spatial.toolkit.QuadShapeOptions
import com.meta.spatial.toolkit.SceneObjectSystem
import com.meta.spatial.toolkit.Transform
import com.meta.spatial.toolkit.UIPanelRenderOptions
import com.meta.spatial.toolkit.UIPanelSettings
import com.meta.spatial.toolkit.VideoSurfacePanelRegistration
import com.meta.spatial.toolkit.Visible
import com.meta.spatial.vr.VRFeature
import m.c.g.a.i_iwara.MainActivity
import m.c.g.a.i_iwara.R
import m.c.g.a.i_iwara.questui.AspectPreset
import m.c.g.a.i_iwara.questui.ControlsRoute
import m.c.g.a.i_iwara.questui.FormatTab
import m.c.g.a.i_iwara.questui.PLAYBACK_SPEEDS
import m.c.g.a.i_iwara.questui.PlaylistEntry
import m.c.g.a.i_iwara.questui.RepeatMode
import m.c.g.a.i_iwara.questui.SceneKind
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoFormat
import m.c.g.a.i_iwara.questui.createBufferingView
import m.c.g.a.i_iwara.questui.createVideoControlsView
import m.c.g.a.i_iwara.xr.ImmersiveBridge
import m.c.g.a.i_iwara.xr.ImmersivePlaylistItem
import m.c.g.a.i_iwara.xr.ImmersiveVideoRequest
import kotlin.math.abs

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
 * 才算「点一下」= 面板显隐 toggle；捏住移动就是 ISDK 的拖拽 / 缩放，不会误触发。
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

    // ---------------------------------------------------------------- 实体

    private var screenEntity: Entity? = null
    private var screenPanel: PanelSceneObject? = null

    /** 当前幕布实体是平幕（quad / cylinder）还是球幕。 */
    private var screenEntityIsFlat = true
    private var uiPanelEntity: Entity? = null
    private var controlsEntity: Entity? = null
    private var bufferingEntity: Entity? = null

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

    /** 幕布现在实际在哪（用户可能抓着挪过）。重建后原位放回；距离/偏移滑块与重置会清掉它。 */
    private var screenPoseOverride: Pose? = null

    /** 控制面板收起前在哪。唤出时优先放回原处。 */
    private var lastControlsPose: Pose? = null

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
    private var lastVolumeStepAt = 0L

    /** 被系统事件（系统菜单 / 摘下头显）暂停的，回来要续播。 */
    private var pausedBySystem = false

    private var playlist: List<ImmersivePlaylistItem> = emptyList()
    private var nowPlayingId: String? = null

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
        Log.i(TAG, "IMMERSIVE onSceneReady")
        logMemory("onSceneReady")
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
        playback.detachSurface()
        screenEntity?.destroy()
        screenEntity = null
        screenPanel = null
        uiPanelEntity?.destroy()
        uiPanelEntity = null
        controlsEntity?.destroy()
        controlsEntity = null
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
                val switchingVideo = request.url != argUrl
                if (switchingVideo && argUrl != null) notifyEnded()
                val before = controls.format
                argUrl = request.url
                videoId = request.videoId
                if (request.width > 0) videoWidth = request.width
                if (request.height > 0) videoHeight = request.height
                controls.format = ScreenGeometry.formatOf(request.shape, request.stereo, request.fullFrame)
                controls.formatTab = controls.format.tab
                controls.title = request.title
                controls.notice = if (!controls.format.supported || request.unsupportedProjection) UNSUPPORTED_NOTICE else null
                controls.playlistLoading = false
                if (switchingVideo) pendingStartMs = request.positionMs
                nowPlayingId = request.videoId.ifBlank { null }
                controls.nowPlayingId = nowPlayingId
                Log.i(TAG, "IMMERSIVE present format=${controls.format} dims=${videoWidth}x$videoHeight pos=${request.positionMs}")
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

        override fun onPlaylist(items: List<ImmersivePlaylistItem>, playingId: String?) {
            runOnUiThread {
                playlist = items
                if (playingId != null) nowPlayingId = playingId
                controls.playlistLoading = false
                controls.nowPlayingId = nowPlayingId
                controls.playlist.clear()
                controls.playlist.addAll(
                    items.map {
                        PlaylistEntry(
                            id = it.id, title = it.title, author = it.author, durationText = it.durationText,
                            progressRatio = it.progress, watched = it.watched, playable = it.playable,
                        )
                    },
                )
            }
        }
    }

    /** 把最后的播放位置交还 Dart（回写观看历史）。只在真有片子时发一次。 */
    private fun notifyEnded() {
        if (argUrl.isNullOrBlank()) return
        val id = videoId
        if (id.isBlank()) return
        ImmersiveBridge.notifyImmersiveEnded(id, playback.positionMs)
    }

    // ================================================================ 头部 / 摆位

    private fun headPose(): Pose? = systemManager
        .findSystem<PlayerBodyAttachmentSystem>()
        .tryGetLocalPlayerAvatarBody()
        ?.head
        ?.tryGetComponent<Transform>()
        ?.transform

    /**
     * 当下的「视线坐标系」：头部位置 + 去掉 roll 的头部朝向（保留俯仰与偏航），再整体**压低
     * [GAZE_DROP_DEG]**。人自然注视比头部轴线低十来度，按轴线摆的东西一律偏上（真机反馈两轮）。
     *
     * 俯仰角的正负号不假设 SDK 的欧拉约定：两个方向各算一次，取前向量更朝下的那个。
     */
    private fun gazeFrame(): Pose? {
        val head = headPose() ?: return null
        val e = head.q.toEuler()
        val a = Quaternion(e.x + GAZE_DROP_DEG, e.y, 0f)
        val b = Quaternion(e.x - GAZE_DROP_DEG, e.y, 0f)
        val forward = Vector3(0f, 0f, 1f)
        val q = if ((a * forward).y < (b * forward).y) a else b
        return Pose(head.t, q)
    }

    /** 拿不到头部位姿时的兜底锚点：原点上方站姿眼高、朝 +Z。 */
    private fun fallbackFrame(): Pose = Pose(Vector3(0f, FALLBACK_EYE_HEIGHT_M, 0f), Quaternion(0f, 0f, 0f))

    private fun currentAnchor(): Pose = anchor ?: captureAnchor()

    private fun captureAnchor(): Pose {
        val g = gazeFrame()
        anchorIsFallback = g == null
        return (g ?: fallbackFrame()).also { anchor = it }
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

    /** 球幕：人在球心，只按锚点的偏航转向。 */
    private fun spherePose(): Pose {
        val a = currentAnchor()
        return Pose(a.t, a.q.removePitchAndRoll())
    }

    private fun screenPose(): Pose = when {
        !controls.format.isFlat -> spherePose()
        else -> screenPoseOverride ?: geometricScreenPose()
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
        entity.setComponent(Visible(visible))
        entity.setComponent(Transform(if (visible) uiPanelPose() else PARKED_POSE))
        uiPanelPlacedByHead = visible && headPose() != null
    }

    /** UI 面板是否已经按真实头部位姿摆过（首次进入时头部可能还没就绪）。 */
    private var uiPanelPlacedByHead = false

    /** 锚点是否是用兜底值捕获的（头部还没就绪），是的话头部一就绪就重新捕获。 */
    private var anchorIsFallback = false

    /** 缓冲指示放在幕布正中、比幕布近一点点。球幕时放在视线前 2m。 */
    private fun bufferingPose(): Pose {
        if (controls.format.isFlat) {
            val a = currentAnchor()
            val f = a.forward()
            val u = a.up()
            return Pose(a.t + f * (controls.screenDistance - 0.15f) + u * controls.screenOffset, a.q)
        }
        val g = gazeFrame() ?: fallbackFrame()
        return Pose(g.t + g.forward() * 2f, g.q)
    }

    /** 控制面板「摆到面前」的落点：当下视线方向 1.5m 处、略偏下，面对头部。 */
    private fun controlsPoseInFront(): Pose {
        val g = gazeFrame() ?: fallbackFrame()
        return Pose(g.t + g.forward() * CONTROLS_DISTANCE_M + g.up() * CONTROLS_DROP_M, g.q)
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
        screenPoseOverride = null
        applyScreenTransform()
        // 浏览态：把 2D 应用面板也摆回视线正前方（用户反馈「重置后 2D 画面位置过于靠上」）。
        if (argUrl.isNullOrBlank()) placeUiPanel(visible = true)
        if (controlsEntity != null) {
            val pose = controlsPoseInFront()
            controlsEntity?.setComponent(Transform(pose))
            lastControlsPose = pose
        }
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
            screenEntity?.tryGetComponent<Transform>()?.transform?.let { screenPoseOverride = it }
        } else {
            screenPoseOverride = null
        }
        // ⛔ 顺序：先摘 Surface 再销毁实体，否则播放器往已释放的缓冲上画。
        if (keepPlayback) playback.detachSurface() else playback.release()
        screenEntity?.destroy()
        screenEntity = null
        screenPanel = null

        val idle = argUrl.isNullOrBlank()
        if (idle) playback.release()

        // 看视频时 UI 面板让位：藏起 + 让 Flutter 停止出帧（destroy 会连 Activity 一起杀掉，代价太大）。
        ImmersiveBridge.setPanelRenderingPaused(!idle)
        if (argUiPanel && uiPanelEntity == null) createUiPanel()
        placeUiPanel(visible = idle)

        if (idle) {
            hideControls()
            controls.title = ""
            controls.notice = null
            controls.buffering = false
            screenPoseOverride = null
            anchor = null
            syncBufferingIndicator()
            Log.i(TAG, "IMMERSIVE 无片源，只留 UI 面板，不建幕布")
            return
        }

        if (anchor == null) captureAnchor()
        // 形状参数直接落到目标值（首次进入没有过渡可言）。
        curArc = controls.curve.arcDegrees
        curWidth = controls.screenWidth
        curAspect = ScreenGeometry.screenAspect(controls, videoWidth, videoHeight)
        animating = false

        val flat = controls.format.isFlat
        val entity = if (flat) {
            Entity.create(
                Panel(R.id.vr_video_panel),
                Transform(screenPose()),
                Visible(true),
                // 官方说曲面面板不能被抓取；用户要求平幕/弧幕都能拖，这里一律开着让真机说话。
                Grabbable(),
                IsdkPanelResize(
                    resizeMode = ResizeMode.Simple,
                    minDimensions = Vector2(0.6f, 0.34f),
                    maxDimensions = Vector2(10.0f, 6.0f),
                    preserveAspectRatio = true,
                ),
            )
        } else {
            Entity.create(Panel(R.id.vr_video_panel), Transform(screenPose()), Visible(true))
        }
        screenEntity = entity
        screenEntityIsFlat = flat
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            val panel = so as? PanelSceneObject
            screenPanel = panel
            runCatching { panel?.layer?.setZIndex(if (flat) Z_SCREEN else Z_SPHERE) }
        }
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
        // 半径变了轴心就得跟着挪。平幕上用户抓着挪过的位置照旧保留。
        if (curArc >= ScreenGeometry.MIN_ARC_DEGREES || screenPoseOverride == null) {
            screenPoseOverride = null
            applyScreenTransform()
        }
    }

    private fun createUiPanel() {
        uiPanelEntity = Entity.create(
            Panel(R.id.vr_ui_panel),
            Transform(uiPanelPose()),
            Visible(true),
            Grabbable(),
            IsdkPanelResize(
                resizeMode = ResizeMode.Relayout,
                minDimensions = Vector2(0.8f, 0.5f),
                maxDimensions = Vector2(4.0f, 2.6f),
                preserveAspectRatio = false,
            ),
        )
        Log.i(TAG, "IMMERSIVE ui panel created")
    }

    // ================================================================ 缓冲指示

    private fun syncBufferingIndicator() {
        val want = controls.buffering && !argUrl.isNullOrBlank() && screenEntity != null
        val existing = bufferingEntity
        if (want && existing == null) {
            val e = Entity.create(Panel(R.id.vr_buffering_panel), Transform(bufferingPose()), Visible(true))
            bufferingEntity = e
            systemManager.findSystem<SceneObjectSystem>().getSceneObject(e)?.thenAccept { so ->
                runCatching { (so as? PanelSceneObject)?.layer?.setZIndex(Z_BUFFERING) }
            }
        } else if (!want && existing != null) {
            existing.destroy()
            bufferingEntity = null
        }
    }

    private fun syncBufferingPose() {
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
            Grabbable(),
            // 四角缩放：整块等比缩放（Simple），用户按自己的距离把面板调到顺眼的大小。
            IsdkPanelResize(
                resizeMode = ResizeMode.Simple,
                minDimensions = Vector2(CONTROLS_WIDTH_M * 0.6f, CONTROLS_HEIGHT_M * 0.6f),
                maxDimensions = Vector2(CONTROLS_WIDTH_M * 2.0f, CONTROLS_HEIGHT_M * 2.0f),
                preserveAspectRatio = true,
            ),
        )
        controlsEntity = entity
        controlsHovered = false
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            so.addInputListener(hoverListener)
            runCatching { (so as? PanelSceneObject)?.layer?.setZIndex(Z_CONTROLS) }
        }
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
        entity.tryGetComponent<Transform>()?.transform?.let { lastControlsPose = it }
        entity.setComponent(Visible(false))
        controlsDoomed?.destroy()
        controlsDoomed = entity
        controlsDoomedTicks = DOOMED_TICKS
        controlsEntity = null
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
        if (!argUrl.isNullOrBlank()) handleInput(now)
        reapDoomedControls()
        updateAutoHide(now)
        if (animating) stepShapeAnimation(now)
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
        if (headPose() == null) return
        if (argUrl.isNullOrBlank()) {
            if (!uiPanelPlacedByHead) placeUiPanel(visible = true)
        } else if (anchorIsFallback) {
            captureAnchor()
            screenPoseOverride = null
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
        if (e.primaryTap && controls.controllerTapPlayPause) controlsCallbacks.onPlayPause()
        if (e.back && controlsEntity != null) hideControls()
        if (e.seekBack) controlsCallbacks.onSeekBy(-SEEK_STEP_S)
        if (e.seekForward) controlsCallbacks.onSeekBy(SEEK_STEP_S)
        if (e.menu) {
            showControls(summoned = true)
            controls.route = ControlsRoute.SETTINGS
        }
        if ((e.volumeUp || e.volumeDown) && now - lastVolumeStepAt >= VOLUME_STEP_MS) {
            lastVolumeStepAt = now
            val delta = if (e.volumeUp) VOLUME_STEP else -VOLUME_STEP
            controlsCallbacks.onVolume((controls.volume + delta).coerceIn(0f, 1f))
        }
    }

    /**
     * 「选择」按下：在面板上就是操作面板，否则记为「点一下」候选，等松开裁决。
     * 捏住移动（拖面板 / 拖幕布 / 拉角缩放）走 ISDK，不会到达 toggle。
     */
    private fun onSelectDown(hand: Int, now: Long) {
        if (controlsHovered) {
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
        runOnUiThread {
            controls.buffering = buffering
            syncBufferingIndicator()
        }
    }

    override fun onReady() {
        runOnUiThread { logMemory("playing") }
    }

    override fun onEnded() {
        runOnUiThread {
            if (controls.repeatMode == RepeatMode.NEXT) {
                adjacentPlayable(forward = true)?.let {
                    controls.playlistLoading = true
                    ImmersiveBridge.requestPlayItem(it.id)
                }
            }
        }
    }

    override fun onError(message: String) {
        runOnUiThread {
            controls.notice = "这个片源放不出来（$message），可以换外部播放器试试"
            showControls(summoned = true)
        }
    }

    override fun onVideoSize(width: Int, height: Int) {
        runOnUiThread {
            if (width == videoWidth && height == videoHeight) return@runOnUiThread
            videoWidth = width
            videoHeight = height
            // 真实尺寸到了才知道单眼比例，幕布按它重塑。
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
            pendingStartMs = 0L
            controls.isPlaying = true
            controls.progress = 0f
            controls.buffering = true
            syncBufferingIndicator()
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
            startActivity(Intent.createChooser(view, "用其他应用打开").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }.onFailure {
            Log.w(TAG, "IMMERSIVE 转交外部播放器失败", it)
            controls.notice = "这台设备上没有能接住这个视频的播放器"
        }
    }

    private fun adjacentPlayable(forward: Boolean): ImmersivePlaylistItem? {
        if (playlist.isEmpty()) return null
        val current = playlist.indexOfFirst { it.id == nowPlayingId }
        val step = if (forward) 1 else -1
        var i = if (current < 0) (if (forward) -1 else playlist.size) else current
        while (true) {
            i += step
            if (i < 0 || i >= playlist.size) return null
            if (playlist[i].playable) return playlist[i]
        }
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
            touched()
            if (!playback.isAlive) return
            controls.isPlaying = playback.togglePlaying()
            pausedBySystem = false
        }

        override fun onSeek(value: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            seeking = true
            controls.progress = value
            val dur = playback.durationMs
            controls.seekPreviewText = if (dur > 0) formatMs((dur * value).toLong()) else null
        }

        override fun onSeekFinished() {
            touched()
            val dur = playback.durationMs
            if (dur > 0) playback.seekTo((dur * controls.progress).toLong())
            seeking = false
            controls.seekPreviewText = null
        }

        override fun onSeekBy(seconds: Int) {
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
            controls.notice = if (format.supported) null else UNSUPPORTED_NOTICE
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
            screenPoseOverride = null
            applyScreenTransform()
            markPrefsDirty()
        }

        override fun onScreenOffset(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenOffset = meters.coerceIn(-1.5f, 1.5f)
            screenPoseOverride = null
            applyScreenTransform()
            markPrefsDirty()
        }

        override fun onScreenWidth(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenWidth = meters.coerceIn(1f, 10f)
            markPrefsDirty()
            // 滑块连续来：给个很短的过渡，逐帧跟手而不是松手才变。
            requestShape(SLIDER_ANIM_MS)
        }

        override fun onResetScreenGeometry() {
            touched()
            controls.screenDistance = DEFAULT_VIEW_DISTANCE_M
            controls.screenOffset = 0f
            controls.screenWidth = DEFAULT_SCREEN_WIDTH_M
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

        override fun onPlayEntry(id: String) {
            touched()
            if (id == nowPlayingId) return
            controls.playlistLoading = true
            ImmersiveBridge.requestPlayItem(id)
        }

        override fun onPlayAdjacent(forward: Boolean) {
            touched()
            val target = adjacentPlayable(forward) ?: return
            controls.playlistLoading = true
            ImmersiveBridge.requestPlayItem(target.id)
        }

        override fun onRefreshPlaylist() {
            touched()
            controls.playlistLoading = true
            ImmersiveBridge.requestPlaylist()
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
                controls.playlistLoading = playlist.isEmpty()
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
                UIPanelSettings(
                    shape = QuadShapeOptions(width = UI_PANEL_WIDTH_M, height = UI_PANEL_WIDTH_M * 640f / 1024f),
                    display = DpDisplayOptions(1024f, 640f, 288),
                )
            },
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
            { _, ctx -> createBufferingView(ctx) },
            {
                UIPanelSettings(
                    shape = QuadShapeOptions(width = BUFFERING_SIZE_M, height = BUFFERING_SIZE_M),
                    display = DpPerMeterDisplayOptions(dpPerMeter = 500f),
                    rendering = UIPanelRenderOptions(
                        renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
                    ),
                )
            },
        ),
        VideoSurfacePanelRegistration(
            R.id.vr_video_panel,
            surfaceConsumer = { _, surface -> startPlayback(surface) },
            settingsCreator = { mediaSettings() },
        ),
    )

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

        private const val UNSUPPORTED_NOTICE = "这种投影本机渲染不了，已按平面显示；可用「用其他应用打开」"

        /** 拿不到头部位姿时的兜底眼高（LOCAL_FLOOR）。 */
        private const val FALLBACK_EYE_HEIGHT_M = 1.6f

        /** 默认观看距离 / 幕宽（米）。 */
        private const val DEFAULT_VIEW_DISTANCE_M = 2.4f
        private const val DEFAULT_SCREEN_WIDTH_M = 3.2f
        private const val SCREEN_MIN_DISTANCE_M = 1.2f
        private const val SCREEN_MAX_DISTANCE_M = 8.0f

        /** UI 面板的几何：1.8m 处 1.6m 宽 ≈ 47° 水平张角，沿视线摆。 */
        private const val UI_PANEL_DISTANCE_M = 1.8f
        private const val UI_PANEL_WIDTH_M = 1.6f

        /**
         * 控制面板几何：逻辑尺寸固定 1100 × 360dp，物理 1.5m 宽，沿视线 1.5m 处、比视线中心低 0.25m。
         * 72dp 圆钮 = 0.098m @1.5m ≈ 3.7°，高于官方 2.5–3° 下限。
         */
        private const val CONTROLS_DISTANCE_M = 1.5f
        private const val CONTROLS_DROP_M = -0.12f

        /** 摆位视线比头部轴线低这么多度。 */
        private const val GAZE_DROP_DEG = 12f
        private const val CONTROLS_WIDTH_M = 1.5f
        private const val CONTROLS_HEIGHT_M = CONTROLS_WIDTH_M * 360f / 1100f

        /** 藏起来的 UI 面板停在这儿：脚下 100m，射线够不着。 */
        private val PARKED_POSE = Pose(Vector3(0f, -100f, 0f), Quaternion(0f, 0f, 0f))

        private const val BUFFERING_SIZE_M = 0.6f

        /** 合成层次序：不靠深度排。 */
        private const val Z_SPHERE = -1
        private const val Z_SCREEN = 0
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

        private const val SEEK_STEP_S = 10
        private const val VOLUME_STEP = 0.04f
        private const val VOLUME_STEP_MS = 120L
    }
}
