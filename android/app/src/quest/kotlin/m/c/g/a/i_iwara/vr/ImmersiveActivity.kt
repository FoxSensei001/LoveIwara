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
import m.c.g.a.i_iwara.questui.createVideoControlsView
import m.c.g.a.i_iwara.xr.ImmersiveBridge
import m.c.g.a.i_iwara.xr.ImmersivePlaylistItem
import m.c.g.a.i_iwara.xr.ImmersiveVideoRequest
import kotlin.math.min
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
 * | 控制面板 | 原生 Compose（`:questui` 模块），照 4XVR 重做 | **空闲即销毁，面板外捏合/扳机 toggle** |
 *
 * # 职责拆分
 *
 * - [ScreenGeometry]：设置 → 面板形状，纯函数。
 * - [PlaybackEngine]：ExoPlayer 薄壳，换形状时只换 Surface 不重载。
 * - [SpatialInputPoller]：每帧读手/手柄按键，抽成事件。
 * - [SystemStatus]：时钟与电量。
 * - [PlayerPrefs]：偏好落盘。
 * - 本类：实体拆建、几何摆位、面板显隐、系统事件、Dart 通道。
 *
 * # ⛔ 三条铁律（都有真机 / 官方依据）
 *
 * 1. 控制面板**隐藏 = 真销毁**：官方明写 0-alpha 的合成层照样付全额成本。
 * 2. 换形状**播放器不死**：只换 Surface；能 `reshape()` 的连实体都不重建。
 * 3. 清理放 `onSpatialShutdown()`，**永远不 `finish()`** 挂着面板的 Activity（会在
 *    `libMetaSpatialSDK.so` 里 SIGSEGV）。
 *
 * # adb 验证入口
 *
 * ```
 * adb shell am start -n <pkg>/m.c.g.a.i_iwara.vr.ImmersiveActivity \
 *   --es url "https://..." --es shape 180 --es stereo lr --ei w 4096 --ei h 2048
 * ```
 * `shape`: flat | 180 | 360   `stereo`: none | lr | tb   `--ez fullFrame`   `--es scene passthrough|void`
 * ⛔ 收起要传空白 url（`--es url " "`）：不传会沿用上一次的值；主页图标（ACTION_MAIN）进来一律回浏览态。
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
    private var uiPanelEntity: Entity? = null
    private var controlsEntity: Entity? = null

    // ---------------------------------------------------------------- 片源

    private var argUrl: String? = null
    private var videoId: String = ""
    private var videoWidth: Int = 1920
    private var videoHeight: Int = 1080

    /** 仅供真机测量用：`--ez mute true` 静音起播（Quest 不接受 adb 改音量）。 */
    private var argMute: Boolean = false

    /** 把 Flutter 的 [MainActivity] 作为一块面板挂进本沉浸空间。默认开；`--ez uiPanel false` 只用于隔离排查。 */
    private var argUiPanel: Boolean = true

    // ---------------------------------------------------------------- 运行态

    private var seeking = false

    /** 幕布现在实际在哪（用户可能抓着挪过）。换形状重建后原位放回；距离/偏移滑块会清掉它。 */
    private var screenPoseOverride: Pose? = null

    /** 控制面板收起前在哪。唤出时优先放回原处。 */
    private var lastControlsPose: Pose? = null

    private var lastInteractionAt = 0L

    /** 射线 / 手指此刻是否悬在控制面板上（由面板 SceneObject 的 InputListener 维护）。 */
    @Volatile
    private var controlsHovered = false

    /** 面板上最近一次触碰的时刻（Compose 侧上报）。 */
    @Volatile
    private var lastPanelTouchAt = 0L

    /** 一次「面板外捏合」的裁决时刻：到点时若期间没有面板触碰就收起。0 = 无待办。 */
    private var pendingToggleAt = 0L
    private var pendingToggleSelectAt = 0L

    /** 幕宽 / 比例是滑块调的，逐帧 reshape 会疯掉 —— 攒到这个时刻再做（0 = 没有待办）。 */
    private var geometryReshapeAt = 0L

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
        // 近场直触与远场捏合射线由 ISDK 按距离自动切换，射线渲染 / 光标 / 命中 / 按下反馈全包。
        IsdkFeature(this, spatial, systemManager),
        // 用 ComposeViewPanelRegistration 就必须注册它，否则面板一创建整个进程崩掉。
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
        // 从 Quest 主页点应用图标进来（ACTION_MAIN、不带 extra）**必须回到浏览态**：
        // 本 Activity 是 singleTask，进程活着时再点图标走的是 onNewIntent，
        // 不这么做上一次看的片子会原样留在场景里（真机反馈）。
        val fromLauncher = source.action == Intent.ACTION_MAIN
        val urlExtra = source.getStringExtra("url")
        val nextUrl = when {
            urlExtra != null -> urlExtra.takeIf { it.isNotBlank() }
            fromLauncher -> null
            else -> argUrl
        }
        // 片子要换 / 要收：先把旧片的位置交还 Dart，再覆盖。
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
        argUiPanel = source.getBooleanExtra("uiPanel", argUiPanel)
        Log.i(
            TAG,
            "IMMERSIVE args format=${controls.format} mute=$argMute uiPanel=$argUiPanel " +
                "dims=${videoWidth}x$videoHeight url=${argUrl?.take(120)}",
        )
    }

    override fun onSceneReady() {
        super.onSceneReady()
        scene.setReferenceSpace(ReferenceSpace.LOCAL_FLOOR)
        // 放球面片时不要让场景光照污染画面：环境光拉满、太阳关掉。
        scene.setLightingEnvironment(
            ambientColor = Vector3(1.0f, 1.0f, 1.0f),
            sunColor = Vector3(0f, 0f, 0f),
            sunDirection = -Vector3(1.0f, 3.0f, 2.0f),
        )
        applyScene()
        Log.i(TAG, "IMMERSIVE onSceneReady")
        logMemory("onSceneReady")
        rebuildScreen()
        // 场景就绪后才接 Dart 的请求：面板里的 Flutter 可能比场景更早跑起来。
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

    override fun onRecenter(isUserInitiated: Boolean) {
        super.onRecenter(isUserInitiated)
        Log.i(TAG, "IMMERSIVE onRecenter user=$isUserInitiated")
        // 视图原点变了：世界锚定的幕布与面板按新的「正前方」重摆。
        screenPoseOverride = null
        applyScreenTransform()
        controlsEntity?.setComponent(Transform(clampControlsPose(controlsPoseInFront())))
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

    /**
     * 清理放这里，**不能只放 `onDestroy()`**：官方明写 `onDestroy` 不保证被调，
     * 只有 `onSpatialShutdown()` 保证。⛔ 永远不要用 `finish()` 结束挂着面板的 Activity。
     */
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
                argUrl = request.url
                videoId = request.videoId
                if (request.width > 0) videoWidth = request.width
                if (request.height > 0) videoHeight = request.height
                controls.format = ScreenGeometry.formatOf(request.shape, request.stereo, request.fullFrame)
                controls.formatTab = controls.format.tab
                controls.title = request.title
                controls.notice = if (!controls.format.supported || request.unsupportedProjection) {
                    UNSUPPORTED_NOTICE
                } else {
                    null
                }
                controls.playlistLoading = false
                if (switchingVideo) pendingStartMs = request.positionMs
                nowPlayingId = request.videoId.ifBlank { null }
                controls.nowPlayingId = nowPlayingId
                Log.i(
                    TAG,
                    "IMMERSIVE present format=${controls.format} dims=${videoWidth}x$videoHeight pos=${request.positionMs}",
                )
                rebuildScreen(keepPlayback = !switchingVideo)
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
                            id = it.id,
                            title = it.title,
                            author = it.author,
                            durationText = it.durationText,
                            progressRatio = it.progress,
                            watched = it.watched,
                            playable = it.playable,
                        )
                    },
                )
            }
        }
    }

    private var pendingStartMs = 0L

    /** 把最后的播放位置交还 Dart（回写观看历史）。只在真有片子时发一次。 */
    private fun notifyEnded() {
        if (argUrl.isNullOrBlank()) return
        val id = videoId
        if (id.isBlank()) return
        ImmersiveBridge.notifyImmersiveEnded(id, playback.positionMs)
    }

    // ================================================================ 幕布

    /**
     * 重建幕布实体（片子换了 / 投影家族换了 / 首次进入）。
     *
     * @param keepPlayback 片子没变，只是几何变了：播放器留着，只换 Surface。
     */
    private fun rebuildScreen(keepPlayback: Boolean = false) {
        screenEntity?.tryGetComponent<Transform>()?.transform?.let { screenPoseOverride = it }
        // ⛔ 顺序：先摘 Surface 再销毁实体，否则播放器往已释放的缓冲上画。
        if (keepPlayback) playback.detachSurface() else playback.release()
        screenEntity?.destroy()
        screenEntity = null
        screenPanel = null

        val idle = argUrl.isNullOrBlank()
        if (idle) playback.release()

        // 看视频时 UI 面板让位：藏起 + 让 Flutter 停止出帧（destroy 会连 Activity 一起杀掉，代价太大）。
        uiPanelEntity?.setComponent(Visible(idle))
        ImmersiveBridge.setPanelRenderingPaused(!idle)

        if (idle) {
            hideControls()
            controls.title = ""
            controls.notice = null
            controls.buffering = false
            screenPoseOverride = null
        } else {
            showControls()
        }

        if (idle) {
            Log.i(TAG, "IMMERSIVE 无片源，只留 UI 面板，不建幕布")
            if (argUiPanel && uiPanelEntity == null) createUiPanel()
            return
        }

        // 平面/弧幕摆到人前方（**「前方」是 +Z**，真机实测）；球幕以观看者为中心放原点。
        // 官方已知限制：曲面面板不能被抓取变换 —— 只有平幕才让 Grabbable 生效。
        val flat = controls.format.isFlat
        val entity = if (flat) {
            Entity.create(
                Panel(R.id.vr_video_panel),
                Transform(screenPose()),
                Visible(true),
                Grabbable(enabled = controls.curve == ScreenCurve.FLAT),
                // 幕布必须保持宽高比；Simple 就够 —— 视频是一张纹理，缩放不需要重新排版。
                IsdkPanelResize(
                    resizeMode = ResizeMode.Simple,
                    minDimensions = Vector2(0.6f, 0.34f),
                    maxDimensions = Vector2(9.0f, 5.0f),
                    preserveAspectRatio = true,
                ),
            )
        } else {
            Entity.create(Panel(R.id.vr_video_panel), Transform(screenPose()), Visible(true))
        }
        screenEntity = entity
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            screenPanel = so as? PanelSceneObject
        }

        if (argUiPanel && uiPanelEntity == null) createUiPanel()
    }

    /**
     * 几何变了但投影家族没变：原地 `reshape()`，实体、Surface、播放器全都不动。
     * reshape 失败（SDK 版本差异）就退回重建。
     */
    private fun applyScreenShape() {
        if (argUrl.isNullOrBlank()) return
        val panel = screenPanel
        if (panel == null || screenEntity == null) {
            rebuildScreen(keepPlayback = true)
            return
        }
        val result = runCatching {
            panel.reshape(mediaSettings().toPanelConfigOptions())
            // reshape 可能换了 Surface：重新指一次是幂等的。
            playback.attachSurface(panel.surface)
        }
        result.onFailure {
            Log.w(TAG, "IMMERSIVE reshape 失败，退回重建", it)
            rebuildScreen(keepPlayback = true)
        }
        screenEntity?.setComponent(Grabbable(enabled = controls.curve == ScreenCurve.FLAT))
        Log.i(TAG, "IMMERSIVE reshape curve=${controls.curve} width=${controls.screenWidth} aspect=${controls.aspectPreset}")
    }

    private fun mediaSettings(): MediaPanelSettings = MediaPanelSettings(
        shape = ScreenGeometry.shape(controls, videoWidth, videoHeight),
        display = PixelDisplayOptions(width = videoWidth, height = videoHeight),
        rendering = MediaPanelRenderOptions(
            stereoMode = ScreenGeometry.stereoMode(controls.format, controls.forceMono),
            // 球幕永远画在最里层，否则会挡住控件。
            zIndex = if (controls.format.isFlat) 0 else -1,
        ),
    )

    private fun screenPose(): Pose = when {
        !controls.format.isFlat -> Pose(Vector3(0f, 0f, 0f))
        else -> screenPoseOverride ?: geometricScreenPose()
    }

    /** 按「距离 + 偏移」两条滑块算出来的标准落点。 */
    private fun geometricScreenPose(): Pose =
        Pose(Vector3(0f, ScreenGeometry.EYE_HEIGHT_M + controls.screenOffset, controls.screenDistance))

    /** 距离/偏移改了：只挪 Transform，不重建（无接缝）。 */
    private fun applyScreenTransform() {
        if (!controls.format.isFlat) return
        screenEntity?.setComponent(Transform(geometricScreenPose()))
    }

    private fun createUiPanel() {
        uiPanelEntity = Entity.create(
            Panel(R.id.vr_ui_panel),
            Transform(Pose(Vector3(0f, UI_PANEL_HEIGHT_M, UI_PANEL_DISTANCE_M))),
            Visible(true),
            Grabbable(),
            // Relayout：按新尺寸重新排版（字不糊）；上限要放开（默认 1.5m，本面板出生就 1.6m）。
            IsdkPanelResize(
                resizeMode = ResizeMode.Relayout,
                minDimensions = Vector2(0.8f, 0.5f),
                maxDimensions = Vector2(4.0f, 2.6f),
                preserveAspectRatio = false,
            ),
        )
        Log.i(TAG, "IMMERSIVE ui panel created at +Z $UI_PANEL_DISTANCE_M")
    }

    // ================================================================ 控制面板

    /**
     * 让控制面板出现。收起再唤出要回到**原来那个地方**（真机反馈）；只有当它转到身后
     * （偏离视线 >60°）才重新摆到面前；最后一律过 [clampControlsPose] 保证不被幕布挡住。
     */
    private fun showControls(summoned: Boolean = false) {
        lastInteractionAt = SystemClock.uptimeMillis()
        val existing = controlsEntity
        if (existing != null) {
            existing.tryGetComponent<Transform>()?.transform?.let {
                existing.setComponent(Transform(clampControlsPose(it)))
            }
            return
        }
        val saved = lastControlsPose
        val restore = saved != null && (!summoned || !controls.summonInFront || isRoughlyInFront(saved))
        val pose = clampControlsPose(if (restore) saved!! else controlsPoseInFront())
        val entity = Entity.create(
            Panel(R.id.vr_controls_panel),
            Transform(pose),
            Visible(true),
            Grabbable(),
        )
        controlsEntity = entity
        controlsHovered = false
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            so.addInputListener(hoverListener)
        }
        Log.i(TAG, "IMMERSIVE controls panel created summoned=$summoned restored=$restore")
    }

    /** 收起控制面板。**真销毁**，不是 `Visible(false)`。 */
    private fun hideControls() {
        controlsEntity?.tryGetComponent<Transform>()?.transform?.let { lastControlsPose = it }
        controlsEntity?.destroy()
        controlsEntity = null
        controlsHovered = false
        pendingToggleAt = 0L
        controls.volumePopupOpen = false
        // 回到播放页：下次唤出时不该停在「设置」这种深处。
        controls.route = ControlsRoute.PLAYER
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

    /**
     * 「摆到当前头部朝向正前方」的落点。面板中心离地 1.55m、自身高 1.0m、距离 2.2m ⇒
     * 下缘下压 ≈14°，在官方 ±15° 内。`removePitchAndRoll()` 只留 yaw，面板永远竖直。
     */
    private fun controlsPoseInFront(): Pose {
        val head = headPose()
            ?: return Pose(Vector3(0f, CONTROLS_CENTER_HEIGHT_M, CONTROLS_DISTANCE_M), Quaternion(0f, 0f, 0f))
        val yaw = head.q.removePitchAndRoll()
        val forward = yaw * Vector3(0f, 0f, 1f)
        return Pose(
            Vector3(
                head.t.x + forward.x * CONTROLS_DISTANCE_M,
                CONTROLS_CENTER_HEIGHT_M,
                head.t.z + forward.z * CONTROLS_DISTANCE_M,
            ),
            yaw,
        )
    }

    private fun isRoughlyInFront(pose: Pose): Boolean {
        val head = headPose() ?: return true
        val forward = head.q.removePitchAndRoll() * Vector3(0f, 0f, 1f)
        val dx = pose.t.x - head.t.x
        val dz = pose.t.z - head.t.z
        val len = sqrt(dx * dx + dz * dz)
        if (len < 0.05f) return true
        return (forward.x * dx + forward.z * dz) / len >= SUMMON_FOV_COS
    }

    /**
     * 合成层完全按深度排前后，幕布拉近就会盖住面板 —— 只能从几何上保证面板更近：
     * 保留方向、把距离压到 `幕布距离 − 余量`，且不低于官方 1m 舒适下限。
     */
    private fun clampControlsPose(pose: Pose): Pose {
        val head = headPose() ?: return pose
        val dx = pose.t.x - head.t.x
        val dz = pose.t.z - head.t.z
        val distance = sqrt(dx * dx + dz * dz)
        val want = controlsDistance()
        if (distance <= want + 0.02f || distance < 0.05f) return pose
        val k = want / distance
        return Pose(Vector3(head.t.x + dx * k, pose.t.y, head.t.z + dz * k), pose.q)
    }

    private fun controlsDistance(): Float {
        if (!controls.format.isFlat) return CONTROLS_DISTANCE_M
        return min(CONTROLS_DISTANCE_M, controls.screenDistance - CONTROLS_SCREEN_CLEARANCE_M)
            .coerceAtLeast(CONTROLS_MIN_DISTANCE_M)
    }

    private fun headPose(): Pose? = systemManager
        .findSystem<PlayerBodyAttachmentSystem>()
        .tryGetLocalPlayerAvatarBody()
        ?.head
        ?.tryGetComponent<Transform>()
        ?.transform

    // ================================================================ 每帧

    /** ⚠️ 与面板里 Flutter 的 platform thread 是同一条主线程，必须保持廉价。 */
    override fun onSceneTick() {
        super.onSceneTick()
        val now = SystemClock.uptimeMillis()
        updateTransport()
        status.clockTextIfChanged(System.currentTimeMillis())?.let { controls.clockText = it }
        input.poll()
        if (!argUrl.isNullOrBlank()) handleInput(now)
        resolvePendingToggle(now)
        updateAutoHide(now)
        if (geometryReshapeAt != 0L && now >= geometryReshapeAt) {
            geometryReshapeAt = 0L
            applyScreenShape()
        }
        if (prefsDirty && now >= prefsFlushAt) {
            prefsDirty = false
            prefs.save(controls)
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

    /**
     * 把手/手柄事件映射到播放器动作。
     *
     * ⛔ 只在影院态（有片源）：浏览态里捏合是操作 Flutter 面板用的，抢不得。
     */
    private fun handleInput(now: Long) {
        val e = input.events
        if (e.select) onSelectGesture(now)
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
     * 面板外捏合 / 扳机 = 显隐 toggle（4XVR 实机行为）。
     *
     * 「在面板外」的判定分两层：射线此刻悬在面板上（ISDK hover）立刻算面板内；
     * 否则等 [TOGGLE_GRACE_MS] 看面板有没有报触碰 —— 直触 / 点击的事件走 Android
     * 视图那条路，比这里晚到一两帧。
     */
    private fun onSelectGesture(now: Long) {
        if (controlsEntity == null) {
            showControls(summoned = true)
            return
        }
        if (controlsHovered || now - lastPanelTouchAt < TOGGLE_GRACE_MS) {
            lastInteractionAt = now
            return
        }
        pendingToggleAt = now + TOGGLE_GRACE_MS
        pendingToggleSelectAt = now
    }

    private fun resolvePendingToggle(now: Long) {
        if (pendingToggleAt == 0L || now < pendingToggleAt) return
        pendingToggleAt = 0L
        if (controlsEntity == null) return
        if (controlsHovered || lastPanelTouchAt >= pendingToggleSelectAt - 60L) {
            lastInteractionAt = now
            return
        }
        Log.i(TAG, "IMMERSIVE controls hidden by outside select")
        hideControls()
    }

    private fun updateAutoHide(now: Long) {
        if (!controls.autoHide || controlsEntity == null) return
        // 暂停 / 缓冲 / 停在子页 / 音量弹层开着：都是正在用面板，不收。
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
            // 出错时必须把面板召回来，否则用户对着黑屏没有任何可操作的东西。
            showControls(summoned = true)
        }
    }

    override fun onVideoSize(width: Int, height: Int) {
        runOnUiThread {
            if (width == videoWidth && height == videoHeight) return@runOnUiThread
            videoWidth = width
            videoHeight = height
            // 真实尺寸到了才知道单眼比例，幕布按它重塑。
            scheduleReshape()
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
            url = url,
            surface = surface,
            startPositionMs = pendingStartMs,
            muted = controls.muted,
            volume = controls.volume,
        )
        if (started) {
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
        // 官方要求 passthrough 切换 smooth blending，但 SDK 只有布尔开关，平滑与否由运行时决定。
        val passthrough = controls.scene == SceneKind.PASSTHROUGH
        runCatching { scene.enablePassthrough(passthrough) }
            .onFailure { Log.w(TAG, "IMMERSIVE enablePassthrough 失败", it) }
    }

    private fun scheduleReshape() {
        geometryReshapeAt = SystemClock.uptimeMillis() + GEOMETRY_DEBOUNCE_MS
    }

    private fun markPrefsDirty() {
        prefsDirty = true
        prefsFlushAt = SystemClock.uptimeMillis() + PREFS_FLUSH_MS
    }

    /** 重新居中：把视图原点挪到当前头部位置与朝向，所有世界锁定的面板回到面前。 */
    private fun recenter() {
        val head = headPose()
        if (head == null) {
            Log.w(TAG, "IMMERSIVE recenter：拿不到头部位姿，跳过")
            return
        }
        scene.setViewOrigin(head.t.x, 0f, head.t.z, head.q.toEuler().y)
        Log.i(TAG, "IMMERSIVE recenter 到 (${head.t.x}, ${head.t.z})")
    }

    /** 收起幕布与控制面板，把 UI 面板还回来。 */
    private fun backToApp() {
        notifyEnded()
        argUrl = null
        nowPlayingId = null
        controls.nowPlayingId = null
        rebuildScreen()
    }

    /** 把当前片源交给本机其它播放器（EAC / 鱼眼这类本机渲染不了的投影的出路）。 */
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

        // ---- 播放 ----

        override fun onPlayPause() {
            touched()
            if (!playback.isAlive) return
            controls.isPlaying = playback.togglePlaying()
            pausedBySystem = false
        }

        override fun onSeek(value: Float) {
            // 拖动中每帧都来：不出声，但续空闲计时。
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
            val s = PLAYBACK_SPEEDS.minByOrNull { kotlin.math.abs(it - speed) } ?: 1f
            controls.speed = s
            playback.setSpeed(s)
            markPrefsDirty()
        }

        // ---- 音量（⛔ 只影响本应用） ----

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

        // ---- 视频类型 ----

        override fun onPickFormat(format: VideoFormat) {
            touched()
            val before = controls.format
            controls.format = format
            controls.formatTab = format.tab
            controls.notice = if (format.supported) null else UNSUPPORTED_NOTICE
            if (before == format) return
            if (ScreenGeometry.sameFamily(before, format)) applyScreenShape() else rebuildScreen(keepPlayback = true)
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

        // ---- 屏幕类型 ----

        override fun onPickCurve(curve: ScreenCurve) {
            touched()
            if (curve == controls.curve) return
            controls.curve = curve
            markPrefsDirty()
            applyScreenShape()
        }

        override fun onToggleForceMono() {
            touched()
            controls.forceMono = !controls.forceMono
            markPrefsDirty()
            if (controls.format.isStereo) applyScreenShape()
        }

        // ---- 场景 ----

        override fun onPickScene(scene: SceneKind) {
            touched()
            controls.scene = scene
            markPrefsDirty()
            applyScene()
        }

        override fun onScreenDistance(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenDistance = meters.coerceIn(SCREEN_MIN_DISTANCE_M, SCREEN_MAX_DISTANCE_M)
            // 距离/偏移滑块的语义是「按几何重新摆」，要清掉抓取记忆。
            screenPoseOverride = null
            applyScreenTransform()
            // 幕布可能已经压到面板前面去了，把面板拉回来。
            controlsEntity?.tryGetComponent<Transform>()?.transform?.let {
                controlsEntity?.setComponent(Transform(clampControlsPose(it)))
            }
            markPrefsDirty()
        }

        override fun onScreenOffset(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenOffset = meters.coerceIn(-1f, 1f)
            screenPoseOverride = null
            applyScreenTransform()
            markPrefsDirty()
        }

        override fun onScreenWidth(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenWidth = meters.coerceIn(1f, 8f)
            markPrefsDirty()
            scheduleReshape()
        }

        override fun onResetScreenGeometry() {
            touched()
            controls.screenDistance = DEFAULT_VIEW_DISTANCE_M
            controls.screenOffset = 0f
            controls.screenWidth = DEFAULT_SCREEN_WIDTH_M
            screenPoseOverride = null
            applyScreenTransform()
            applyScreenShape()
            markPrefsDirty()
        }

        override fun onRecenter() {
            touched()
            recenter()
        }

        // ---- 屏幕尺寸 ----

        override fun onPickAspect(preset: AspectPreset) {
            touched()
            if (preset == controls.aspectPreset) return
            controls.aspectPreset = preset
            markPrefsDirty()
            applyScreenShape()
        }

        override fun onWidthRatio(ratio: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.widthRatio = ratio.coerceIn(0.5f, 2f)
            markPrefsDirty()
            scheduleReshape()
        }

        override fun onHeightRatio(ratio: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.heightRatio = ratio.coerceIn(0.5f, 2f)
            markPrefsDirty()
            scheduleReshape()
        }

        override fun onResetAspect() {
            touched()
            controls.aspectPreset = AspectPreset.DEFAULT
            controls.widthRatio = 1f
            controls.heightRatio = 1f
            markPrefsDirty()
            applyScreenShape()
        }

        // ---- 播放列表 ----

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

        // ---- 设置 ----

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

        // ---- 面板自身 ----

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

    // 这个方法在 `super.onCreate()` **内部**被调用，读不到 intent —— 所以**无条件注册**，
    // 是否出现在场景里由 Entity 决定（官方：「A registered panel does not appear in the scene」）。
    override fun registerPanels(): List<PanelRegistration> = listOf(
        // Flutter 的 MainActivity 作为空间面板（Activity-based，官方预算 2/2；迁到 ViewPanel 要先 FlutterEngineCache 化）。
        ActivityPanelRegistration(
            R.id.vr_ui_panel,
            { MainActivity::class.java },
            {
                UIPanelSettings(
                    shape = QuadShapeOptions(
                        width = UI_PANEL_WIDTH_M,
                        height = UI_PANEL_WIDTH_M * 640f / 1024f,
                    ),
                    display = DpDisplayOptions(1024f, 640f, 288),
                )
            },
        ),
        // 空间化的控制面板：view-based Compose 面板（预算 15/40）。
        ComposeViewPanelRegistration(
            R.id.vr_controls_panel,
            { _, ctx -> createVideoControlsView(ctx, controls, controlsCallbacks) },
            {
                UIPanelSettings(
                    shape = QuadShapeOptions(width = CONTROLS_WIDTH_M, height = CONTROLS_HEIGHT_M),
                    // 500dp/m：1dp = 2mm，面板逻辑尺寸 1100×500dp，与 `:questui` 的 PanelTokens 成对。
                    display = DpPerMeterDisplayOptions(dpPerMeter = 500f),
                    // 透明底：顶栏那排圆钮悬浮在窗外，钮与钮之间透出后面的画面。
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

    /** 一行内存采样。⛔ 已知欠账：显存目前并不随实体销毁归还（见 docs/xr-app-layout.md §14）。 */
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

        /** 默认观看距离 / 幕宽（米）：2.5m 处 55° 水平弧 ≈ 2.4m。 */
        private const val DEFAULT_VIEW_DISTANCE_M = 2.5f
        private const val DEFAULT_SCREEN_WIDTH_M = 2.4f

        /** 幕布距离范围。下限 1.5m：面板要比它近 0.45m 且不低于官方 1m 舒适下限。 */
        private const val SCREEN_MIN_DISTANCE_M = 1.5f
        private const val SCREEN_MAX_DISTANCE_M = 8.0f

        /** UI 面板的几何：1.8m 处 1.6m 宽 ≈ 47° 水平张角，与静息眼高齐平。 */
        private const val UI_PANEL_DISTANCE_M = 1.8f
        private const val UI_PANEL_WIDTH_M = 1.6f
        private const val UI_PANEL_HEIGHT_M = 1.60f

        /** 控制面板几何：2.2m × 1.0m @ 500dp/m = 1100 × 500dp，与 `:questui` 的 PanelTokens 成对。 */
        private const val CONTROLS_DISTANCE_M = 2.2f
        private const val CONTROLS_WIDTH_M = 2.2f
        private const val CONTROLS_HEIGHT_M = 1.0f
        private const val CONTROLS_CENTER_HEIGHT_M = 1.55f
        private const val CONTROLS_SCREEN_CLEARANCE_M = 0.45f
        private const val CONTROLS_MIN_DISTANCE_M = 1.0f

        /** 「还算在视线前方」的判据：cos 60°。 */
        private const val SUMMON_FOV_COS = 0.5f

        private const val GEOMETRY_DEBOUNCE_MS = 350L
        private const val PREFS_FLUSH_MS = 1000L

        /** 面板外捏合的裁决宽限：等面板那条路的触碰事件到齐。 */
        private const val TOGGLE_GRACE_MS = 150L

        private const val SEEK_STEP_S = 10
        private const val VOLUME_STEP = 0.04f
        private const val VOLUME_STEP_MS = 120L
    }
}
