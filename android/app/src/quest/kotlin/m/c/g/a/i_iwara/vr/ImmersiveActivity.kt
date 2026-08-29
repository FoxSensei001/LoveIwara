package m.c.g.a.i_iwara.vr

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Debug
import android.os.SystemClock
import android.util.Log
import androidx.annotation.OptIn
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.VideoSize
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
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
import com.meta.spatial.runtime.ButtonBits
import com.meta.spatial.runtime.PanelShapeLayerBlendType
import com.meta.spatial.runtime.ReferenceSpace
import com.meta.spatial.runtime.StereoMode
import com.meta.spatial.toolkit.ActivityPanelRegistration
import com.meta.spatial.toolkit.AppSystemActivity
import com.meta.spatial.toolkit.Controller
import com.meta.spatial.toolkit.CylinderShapeOptions
import com.meta.spatial.toolkit.DpDisplayOptions
import com.meta.spatial.toolkit.DpPerMeterDisplayOptions
import com.meta.spatial.toolkit.Equirect180ShapeOptions
import com.meta.spatial.toolkit.Equirect360ShapeOptions
import com.meta.spatial.toolkit.Grabbable
import com.meta.spatial.toolkit.MediaPanelRenderOptions
import com.meta.spatial.toolkit.MediaPanelSettings
import com.meta.spatial.toolkit.MediaPanelShapeOptions
import com.meta.spatial.toolkit.Panel
import com.meta.spatial.toolkit.PanelRegistration
import com.meta.spatial.toolkit.PanelRenderMode
import com.meta.spatial.toolkit.PixelDisplayOptions
import com.meta.spatial.toolkit.PlayerBodyAttachmentSystem
import com.meta.spatial.toolkit.QuadShapeOptions
import com.meta.spatial.toolkit.Transform
import com.meta.spatial.toolkit.UIPanelRenderOptions
import com.meta.spatial.toolkit.UIPanelSettings
import com.meta.spatial.toolkit.VideoSurfacePanelRegistration
import com.meta.spatial.toolkit.Visible
import com.meta.spatial.vr.VRFeature
import m.c.g.a.i_iwara.MainActivity
import m.c.g.a.i_iwara.R
import m.c.g.a.i_iwara.questui.ControlsRoute
import m.c.g.a.i_iwara.questui.PlaylistEntry
import m.c.g.a.i_iwara.questui.RepeatMode
import m.c.g.a.i_iwara.questui.SceneKind
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.StereoLayout
import m.c.g.a.i_iwara.questui.VideoControlsCallbacks
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoProjection
import m.c.g.a.i_iwara.questui.createVideoControlsView
import m.c.g.a.i_iwara.xr.ImmersiveBridge
import m.c.g.a.i_iwara.xr.ImmersivePlaylistItem
import m.c.g.a.i_iwara.xr.ImmersiveVideoRequest
import kotlin.math.PI
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/**
 * Quest 沉浸式播放 Activity。**只存在于 quest 变体**，standard 包既不编译它、
 * 也不链接任何 Spatial SDK 的 `.aar`（硬约束 C1：不把 48MB SDK 打进普通包、minSdk 不抬）。
 *
 * # 三块空间实体
 *
 * | 实体 | 是什么 | 生灭 |
 * |---|---|---|
 * | UI 面板 | 整个 Flutter 应用（`ActivityPanelRegistration` 挂 [MainActivity]） | 常在，看视频时停止出帧 |
 * | 幕布 | `VideoSurfacePanelRegistration` + ExoPlayer；平面走 Quad/Cylinder，VR 片走 Equirect | 有片源才建 |
 * | 控制面板 | 原生 Compose（`:questui` 模块），照参考软件重做 | **空闲即销毁，捏合唤出** |
 *
 * # ⛔ 控制面板为什么必须销毁而不是隐藏
 *
 * 官方原文：「It is common for app developers to create compositor layers, and supply
 * them with a **0-alpha texture rather than destroy** the compositor layer.
 * **Note that you will continue to pay the costs**」。成本按屏幕覆盖像素算，
 * 每层约 0.1ms，而 72FPS 是商店审核硬底线。所以 [hideControls] 是真 `destroy()`。
 *
 * # ⭐ 捏合唤出：参考软件那种「朝任意方向点一下」是怎么做到的
 *
 * 参考软件不用瞄准任何东西，随手捏一下悬浮窗就出来。官方文档里没有这个机制的描述，
 * 但 SDK 给了足够的料自己做：`Controller` 组件（`type = HAND`）的 `buttonState` /
 * `changedButtons` 里，**ButtonX / ButtonA 就是左右手食指捏合**。于是
 * [pollSummonGesture] 只要在每帧看一次上升沿即可 —— 不需要射线命中、不需要目标实体。
 *
 * ⛔ 只在**影院态**（有片源）开启。浏览态里捏合是操作 Flutter 面板用的，抢不得。
 *
 * # 参数走 intent extra（adb 直喂，验证用）
 *
 * ```
 * adb shell am start -n <pkg>/m.c.g.a.i_iwara.vr.ImmersiveActivity \
 *   --es url "https://..." --es shape 180 --es stereo lr --ei w 4096 --ei h 2048
 * ```
 * `shape`: flat | 180 | 360      `stereo`: none | lr | tb
 * ⛔ 收起要传空白 url（`--es url " "`）：不传会沿用上一次的值。
 */
class ImmersiveActivity : AppSystemActivity() {

    private var exoPlayer: ExoPlayer? = null
    private var panelEntity: Entity? = null
    private var uiPanelEntity: Entity? = null
    private var controlsEntity: Entity? = null

    // ---------------------------------------------------------------- 片源

    private var argUrl: String? = null
    private var argShape: String = "180"
    private var argStereo: String = "lr"
    private var argWidth: Int = 4096
    private var argHeight: Int = 2048

    /**
     * 仅供真机测量用：`--ez mute true` 让 ExoPlayer 静音起播。
     *
     * 存在的理由很实际 —— Quest 不接受 adb 改音量（`input keyevent VOLUME_DOWN` 与
     * `cmd media_session volume --set` 都改不动系统值），而跑内存/性能基线时不该
     * 把声音外放。正式入口（Dart 网关）永远不下发这个 extra。
     */
    private var argMute: Boolean = false

    /**
     * 把 Flutter 的 [MainActivity] 作为一块面板挂进本沉浸空间。
     *
     * **默认开**：这正是本应用在 Quest 上的形态 —— 应用常驻自己的沉浸空间，
     * 整个现有 UI 是悬浮其中的一块面板。`--ez uiPanel false` 只用于隔离排查。
     */
    private var argUiPanel: Boolean = true

    // ---------------------------------------------------------------- 面板状态

    /**
     * 控制面板的状态。类型来自 `:questui` 模块，对外只是普通属性 ——
     * 所以这里不需要（也刻意不要）Compose 编译器插件。
     */
    private val controls = VideoControlsState()

    private var seeking = false
    private var speedIndex = 2

    /** 换片时的起播位置（Dart 侧传来的续播点）。⛔ 换形状**不**走这条，见 [rebuildPanel]。 */
    private var pendingSeekMs = 0L

    /** 当前播放器正在放的地址。换形状时靠它判断「这还是同一条片子」，从而只换 Surface。 */
    private var playingUrl: String? = null

    /**
     * 幕布现在实际在哪。
     *
     * ⛔ 换形状（屏幕类型 / 幕宽 / 投影）必须销毁重建实体，而**实体一销毁位置就没了** ——
     * 用户抓着幕布挪过、或者只是不在默认位置，重建后会瞬移回几何默认值。
     * 所以每次重建前把当前 Transform 记下来，重建后原位放回。
     * ⚠️ 距离/高度滑块是「按几何重新摆」的语义，会清掉这个记忆（见 `onScreenDistance`）。
     */
    private var screenPoseOverride: Pose? = null

    /** 控制面板收起前在哪。唤出时优先放回原处，见 [showControls]。 */
    private var lastControlsPose: Pose? = null

    /** 最近一次用户交互的时刻，空闲自动收起靠它。 */
    private var lastInteractionAt = 0L

    /** 上一帧看到的捏合位，用来取上升沿。 */
    private var lastPinchDown = false

    /** 幕宽是滑块调的，逐帧重建幕布会疯掉 —— 攒到这个时刻再重建（0 = 没有待办）。 */
    private var geometryRebuildAt = 0L

    private var playlist: List<ImmersivePlaylistItem> = emptyList()
    private var nowPlayingId: String? = null

    // ---------------------------------------------------------------- 回调

    /**
     * 面板上的每一次动作都先过这里：**记一次交互时间 + 出一声**。
     *
     * ⛔ 音效不是锦上添花。官方原话：「**Hands have no haptics.** Without controller
     * vibration to confirm an action, every successful poke, pinch, or grab needs strong
     * audiovisual feedback to compensate… **This is not optional.**」
     */
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
            val p = exoPlayer ?: return
            p.playWhenReady = !p.playWhenReady
            controls.isPlaying = p.playWhenReady
        }

        override fun onSeek(value: Float) {
            // ⚠️ 拖动中每帧都会来，**不出声也不当成一次「动作」**——否则音效会连成一片噪音。
            // 但空闲计时要续，不然拖着拖着面板自己没了。
            lastInteractionAt = SystemClock.uptimeMillis()
            seeking = true
            controls.progress = value
        }

        override fun onSeekFinished() {
            touched()
            val p = exoPlayer ?: return
            val dur = p.duration
            if (dur > 0) p.seekTo((dur * controls.progress).toLong())
            seeking = false
        }

        override fun onSeekBy(seconds: Int) {
            touched()
            val p = exoPlayer ?: return
            val target = (p.currentPosition + seconds * 1000L).coerceAtLeast(0L)
            p.seekTo(if (p.duration > 0) target.coerceAtMost(p.duration) else target)
        }

        override fun onCycleSpeed() {
            touched()
            val p = exoPlayer ?: return
            speedIndex = (speedIndex + 1) % SPEEDS.size
            p.setPlaybackSpeed(SPEEDS[speedIndex])
            controls.speedText = "${SPEEDS[speedIndex]}×"
        }

        // ---- 音量。⛔ 只影响本应用，绝不碰系统音量（官方 Requirement） ----

        override fun onVolume(value: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.volume = value
            if (value > 0f) controls.muted = false
            applyVolume()
        }

        override fun onToggleMute() {
            touched()
            controls.muted = !controls.muted
            applyVolume()
        }

        // ---- 片源格式 ----

        override fun onPickProjection(projection: VideoProjection) {
            touched()
            if (!projection.supported) {
                // 选到放不了的档：**不重建幕布**（重建了也放不对），只把提示打出来。
                controls.projection = projection
                controls.notice = "${projection.label} 投影本机渲染不了，可用「用其他应用打开」"
                return
            }
            controls.notice = null
            val shape = when (projection) {
                VideoProjection.PANORAMA_180 -> "180"
                VideoProjection.PANORAMA_360 -> "360"
                else -> "flat"
            }
            if (shape == argShape) {
                controls.projection = projection
                return
            }
            argShape = shape
            controls.projection = projection
            controls.curveAvailable = shape == "flat"
            rebuildScreenKeepingPlayback()
        }

        override fun onPickStereo(layout: StereoLayout) {
            touched()
            val stereo = when (layout) {
                StereoLayout.SIDE_BY_SIDE -> "lr"
                StereoLayout.TOP_BOTTOM -> "tb"
                StereoLayout.MONO -> "none"
            }
            if (stereo == argStereo) return
            argStereo = stereo
            controls.stereo = layout
            rebuildScreenKeepingPlayback()
        }

        override fun onHandOffToExternalPlayer() {
            touched()
            handOffToExternalPlayer()
        }

        // ---- 幕布 ----

        override fun onPickCurve(curve: ScreenCurve) {
            touched()
            if (curve == controls.curve) return
            controls.curve = curve
            rebuildScreenKeepingPlayback()
        }

        override fun onScreenDistance(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenDistance = meters
            // ⛔ 距离/高度滑块的语义是「**按几何重新摆**」，所以要清掉抓取记忆 ——
            // 否则拖滑块时幕布纹丝不动，用户只会以为滑块坏了。
            screenPoseOverride = null
            // 只改 Transform，**不用重建面板** —— 立即生效、无接缝。
            applyScreenTransform()
            // 幕布可能已经压到面板前面去了，把面板拉回来。
            controlsEntity?.tryGetComponent<Transform>()?.transform?.let {
                controlsEntity?.setComponent(Transform(clampControlsPose(it)))
            }
        }

        override fun onScreenOffset(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenOffset = meters
            screenPoseOverride = null
            applyScreenTransform()
        }

        override fun onScreenWidth(meters: Float) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.screenWidth = meters
            // ⛔ 幕宽是**形状**，形状只在实体创建时定（`settingsCreator` 跑一次），
            // 所以必须重建。滑块每帧都来，攒一下再重建，否则拖动过程会疯狂拆装面板。
            geometryRebuildAt = SystemClock.uptimeMillis() + GEOMETRY_DEBOUNCE_MS
        }

        override fun onResetScreenGeometry() {
            touched()
            controls.screenDistance = DEFAULT_VIEW_DISTANCE_M
            controls.screenOffset = 0f
            controls.screenWidth = DEFAULT_QUAD_WIDTH_M
            controls.curve = ScreenCurve.FLAT
            rebuildScreenKeepingPlayback()
        }

        override fun onRecenter() {
            touched()
            recenter()
        }

        // ---- 场景 ----

        override fun onPickScene(scene: SceneKind) {
            touched()
            controls.scene = scene
            applyScene()
        }

        // ---- 播放列表 ----

        override fun onPlayEntry(id: String) {
            touched()
            if (id == nowPlayingId) return
            controls.playlistLoading = true
            // Dart 那边拉详情 + 要新地址，回来会走 onPresent。
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
        }

        override fun onToggleAutoHide() {
            touched()
            controls.autoHide = !controls.autoHide
        }

        override fun onAutoHideSeconds(seconds: Int) {
            lastInteractionAt = SystemClock.uptimeMillis()
            controls.autoHideSeconds = seconds.coerceIn(4, 60)
        }

        override fun onToggleClickSound() {
            controls.clickSound = !controls.clickSound
            touched()
        }

        override fun onToggleSummonInFront() {
            touched()
            controls.summonInFront = !controls.summonInFront
        }

        // ---- 面板自身 ----

        override fun onRoute(route: ControlsRoute) {
            touched()
            controls.route = route
            if (route == ControlsRoute.PLAYLIST) {
                controls.playlistLoading = playlist.isEmpty()
                ImmersiveBridge.requestPlaylist()
            }
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

    // ---------------------------------------------------------------- 生命周期

    override fun registerFeatures(): List<SpatialFeature> = listOf(
        VRFeature(this),
        // ⭐ 纯手势体验的地基。官方原文：「Direct touch is not a 'mode' and should be
        // always available」、「Avoid artificial distinction between near-field and
        // far-field」—— 近场直触与远场捏合射线由 ISDK 按距离自动切换，
        // **不需要我们定「哪种输入是主路径」这种策略**。
        IsdkFeature(this, spatial, systemManager),
        // ⛔ 用 ComposeViewPanelRegistration 就必须注册它，否则面板一创建就抛
        // 「ComposeFeature is not registered with the Feature」并整个进程崩掉。
        ComposeFeature(),
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "IMMERSIVE onCreate pid=${android.os.Process.myPid()}")
        logMemory("onCreate")
        readIntent(intent)
    }

    override fun onNewIntent(newIntent: Intent) {
        super.onNewIntent(newIntent)
        val before = argUrl
        readIntent(newIntent)
        // 同一条片子只是换了形状（adb 调参时常见）：留着播放器，别重新缓冲。
        rebuildPanel(keepPlayback = argUrl != null && argUrl == before)
    }

    private fun readIntent(source: Intent?) {
        source ?: return
        // ⛔ 从 Quest 主页点应用图标进来（ACTION_MAIN、不带任何 extra）**必须回到浏览态**。
        // 本 Activity 是 singleTask，进程活着时再点图标走的是 onNewIntent；
        // 原先 `?: argUrl` 会把**上一次看的那条片子**原样留在场景里，
        // 于是用户「刚进应用，背后就凭空挂着一个视频」（2026-08-29 真机反馈）。
        // 带了 url（哪怕是空白串，那是收起用的约定）才由 intent 说了算。
        val fromLauncher = source.action == Intent.ACTION_MAIN
        val urlExtra = source.getStringExtra("url")
        argUrl = when {
            urlExtra != null -> urlExtra.takeIf { it.isNotBlank() }
            fromLauncher -> null
            else -> argUrl
        }
        argShape = source.getStringExtra("shape") ?: argShape
        argStereo = source.getStringExtra("stereo") ?: argStereo
        argWidth = source.getIntExtra("w", argWidth)
        argHeight = source.getIntExtra("h", argHeight)
        argMute = source.getBooleanExtra("mute", argMute)
        // `--es scene passthrough|void`：与 `--ez mute` 同类的 adb 验证入口。
        // 面板上的「场景」页是正式入口，这条只是让真机验证不必靠手戳面板。
        source.getStringExtra("scene")?.let {
            controls.scene = if (it == "passthrough") SceneKind.PASSTHROUGH else SceneKind.VOID
            applyScene()
        }
        argUiPanel = source.getBooleanExtra("uiPanel", argUiPanel)
        syncFormatToControls()
        Log.i(
            TAG,
            "IMMERSIVE args shape=$argShape stereo=$argStereo mute=$argMute uiPanel=$argUiPanel " +
                "dims=${argWidth}x$argHeight url=${argUrl?.take(120)}",
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
        rebuildPanel()

        // 场景就绪后才接 Dart 的请求：面板里的 Flutter 可能比场景更早跑起来，
        // ImmersiveBridge 会把这段时间里的请求暂存下来，在这里补投。
        ImmersiveBridge.attachScene(bridgeListener)
    }

    /** Dart 侧「把这个视频空间化呈现 / 收起来 / 这是播放列表」的落点。 */
    private val bridgeListener = object : ImmersiveBridge.Listener {

        override fun onPresent(request: ImmersiveVideoRequest) {
            runOnUiThread {
                val switchingVideo = request.url != argUrl
                argUrl = request.url
                argShape = request.shape
                argStereo = request.stereo
                if (request.width > 0) argWidth = request.width
                if (request.height > 0) argHeight = request.height
                controls.title = request.title
                controls.notice = if (request.unsupportedProjection) {
                    "这个片源的投影本机渲染不了，可用「用其他应用打开」"
                } else {
                    null
                }
                controls.playlistLoading = false
                syncFormatToControls()
                // 换片时从头放，不要把上一条的进度接到新片子上。
                if (switchingVideo) pendingSeekMs = request.positionMs
                Log.i(
                    TAG,
                    "IMMERSIVE present shape=$argShape stereo=$argStereo " +
                        "dims=${argWidth}x$argHeight pos=${request.positionMs}",
                )
                // 同一条片子被重新 present（例如只改了格式判定）时不该重新加载。
                rebuildPanel(keepPlayback = !switchingVideo)
            }
        }

        override fun onDismiss() {
            runOnUiThread {
                Log.i(TAG, "IMMERSIVE dismiss")
                argUrl = null
                rebuildPanel()
            }
        }

        override fun onPlaylist(items: List<ImmersivePlaylistItem>, playingId: String?) {
            runOnUiThread {
                playlist = items
                nowPlayingId = playingId
                controls.playlistLoading = false
                controls.nowPlayingId = playingId
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

    // ---------------------------------------------------------------- 实体拆建

    /**
     * 重建幕布实体。
     *
     * @param keepPlayback 只是换形状（屏幕类型 / 幕宽 / 投影 / 立体编排），片子没变。
     *
     * # ⛔ 换形状**不该**让视频重新加载
     *
     * `settingsCreator` 只在实体创建时跑一次，官方没有「运行时热换形状」的 API，
     * 所以换形状确实必须销毁重建实体。但**重建的是面板实体，不是播放器** ——
     * 此前这里无条件 `releasePlayer()`，于是每次调屏幕类型都要重新连接、重新缓冲，
     * 用户看到的是「整个画面一黑，然后从头加载」。
     *
     * 正确做法：留着同一个 [ExoPlayer]，只把它的输出重新指到新实体给出的 Surface 上
     * （[startPlayback] 里那条同 URL 短路）。缓冲区、解码器、播放位置全都不动，
     * 接缝只剩「旧合成层消失到新合成层出现」这一下。
     *
     * ⛔ 顺序很重要：**先摘掉 surface 再销毁实体**。老 Surface 是随实体一起没的，
     * 播放器还往上画就会写到已释放的缓冲上。
     */
    private fun rebuildPanel(keepPlayback: Boolean = false) {
        // 记住幕布现在在哪，重建后原位放回（用户可能抓着挪过）。
        panelEntity?.tryGetComponent<Transform>()?.transform?.let { screenPoseOverride = it }
        if (keepPlayback) exoPlayer?.setVideoSurface(null) else releasePlayer()
        panelEntity?.destroy()
        panelEntity = null

        val idle = argUrl.isNullOrBlank()
        if (idle) releasePlayer()

        // 看视频时 UI 面板要让位。
        //
        // ⚠️ 官方对「暂时不用的面板」只给了性能告警、没给设计处方，而那条告警说的是
        // 「用 0-alpha 贴图代替销毁**照样付钱**」。但我们这块面板里跑的是 Flutter，
        // `panelEntity.destroy()` 会连 Activity 一起销毁 → 引擎冷重启、页面状态全丢，
        // 代价远大于省下的那一层。所以这里用 Visible(false) + 让 Flutter 停止出帧。
        // ⛔ 这条路目前**并没有把显存还回来**（实测三招全无效，见文档 §14），是已知欠账。
        uiPanelEntity?.setComponent(Visible(idle))
        ImmersiveBridge.setPanelRenderingPaused(!idle)

        if (idle) {
            hideControls()
            controls.title = ""
            controls.notice = null
            screenPoseOverride = null
        } else {
            showControls()
        }

        if (idle) {
            // ⛔ 没有片源就**不要建幕布实体**。此前无论如何都建，于是空手进来时会有一只
            // 半径 50m 的黑色球幕把整个空间罩住 —— 白白吃掉一块合成层（官方：每层约 0.1ms、
            // 全屏层 0.6ms，且 0-alpha 也照样付钱），还挡住天幕与 passthrough。
            Log.i(TAG, "IMMERSIVE 无片源，只留 UI 面板，不建幕布")
            return
        }

        // ⛔⛔ 平面/弧幕必须摆到人前方，而**「前方」是 +Z，不是 -Z**（2026-08-29 真机实测；
        // 官方旁证：`Followable`「stay in front of another entity」的默认 offset 就是
        // `Pose(Vector3(0f, 0f, 3.0f))`）。球面不受影响：以观看者为中心，原点是对的。
        // ⚠️ 官方已知限制：**曲面面板不能被抓取变换**（"Curved panels cannot be grabbed
        // and transformed."）。所以只有真正的平幕才挂 Grabbable + 缩放；
        // 弧幕与球幕靠「场景」页的距离/高度/幕宽滑块与「重新居中」摆位。
        panelEntity = if (isFlatScreen() && controls.curve == ScreenCurve.FLAT) {
            Entity.create(
                Panel(R.id.vr_video_panel),
                Transform(screenPose()),
                Visible(true),
                Grabbable(),
                // 幕布与 UI 面板相反：**必须保持宽高比**（画面不能被拉变形），
                // 而且用 `Simple` 就够 —— 视频是一张纹理，缩放它不需要重新排版，
                // Relayout 反而会去改 surface 分辨率、打断播放。
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

        if (argUiPanel && uiPanelEntity == null) {
            createUiPanel()
        }
    }

    private fun createUiPanel() {
        // UI 面板摆在正前方、与静息眼高齐平（俯角 0°，官方 ±15° 预算内）。
        uiPanelEntity = Entity.create(
            Panel(R.id.vr_ui_panel),
            Transform(Pose(Vector3(0f, UI_PANEL_HEIGHT_M, UI_PANEL_DISTANCE_M))),
            Visible(true),
            // 抓着边缘挪位置、拖角改大小。
            // ⛔ 官方陷阱：挂了 Grabbable 的实体**会失去 onClick**，除非同时有
            // IsdkPanelDimensions —— 面板由 IsdkComponentCreationSystem 自动补上，
            // 所以只要 ISDK 开着就没事；一旦禁用 ISDK 系统，面板就点不动了。
            Grabbable(),
            // ⛔ 三个默认值都不适合承载 Flutter UI 的面板（官方默认是
            // `Simple / (0.3,0.3) / (1.5,1.5) / preserveAspectRatio = true`），实测全撞上：
            // 1. `Simple` 只拉伸纹理 —— 字会糊。Relayout 会按新尺寸重新排版（窄屏↔宽屏
            //    布局也会跟着切），官方定位正是「Best for: Dynamic UI, text, interactive」。
            // 2. `maxDimensions` 默认 1.5m，而本面板出生就 1.6m 宽 —— **一出生就顶格**。
            // 3. `preserveAspectRatio = true` 让它只能等比缩放；UI 面板该能自由改形状。
            IsdkPanelResize(
                resizeMode = ResizeMode.Relayout,
                minDimensions = Vector2(0.8f, 0.5f),
                maxDimensions = Vector2(4.0f, 2.6f),
                preserveAspectRatio = false,
            ),
        )
        Log.i(TAG, "IMMERSIVE ui panel created at +Z $UI_PANEL_DISTANCE_M")
    }

    // ---------------------------------------------------------------- 控制面板显隐

    /**
     * 让控制面板出现。
     *
     * # ⛔ 收起再唤出必须回到**原来那个地方**
     *
     * 用户 2026-08-29 真机反馈：叉掉再唤出，面板换了个位置。根因是收起时实体被销毁、
     * 位置随之丢失，唤出时又按「头部正前方」重算了一个。
     *
     * 现在的规则：
     * 1. 收起时把 Transform 记进 [lastControlsPose]（含用户抓着挪过的位置）；
     * 2. 唤出时**优先放回那儿**；
     * 3. 只有当它已经转到身后（偏离视线超过 [SUMMON_FOV_COS] 对应的角度）才重新摆到面前 ——
     *    否则「转过身捏一下」会召唤到一块看不见的面板。
     * 4. 最后一律过一次 [clampControlsPose]，保证它不会被幕布挡住。
     *
     * @param summoned 这次是**捏合唤出**（可能需要摆到面前），而不是播放开始时的自然出现。
     */
    private fun showControls(summoned: Boolean = false) {
        lastInteractionAt = SystemClock.uptimeMillis()
        val existing = controlsEntity
        if (existing != null) {
            // 已经在了：只做一次「别被幕布挡住」的校正，⛔ 不要挪位置 ——
            // 那会让用户刚摆好的面板在换个投影之后自己跑掉。
            existing.tryGetComponent<Transform>()?.transform?.let {
                existing.setComponent(Transform(clampControlsPose(it)))
            }
            return
        }
        val saved = lastControlsPose
        val restore = saved != null && (!summoned || !controls.summonInFront || isRoughlyInFront(saved))
        val pose = clampControlsPose(if (restore) saved!! else controlsPoseInFront())
        controlsEntity = Entity.create(
            Panel(R.id.vr_controls_panel),
            Transform(pose),
            Visible(true),
            Grabbable(),
        )
        Log.i(TAG, "IMMERSIVE controls panel created summoned=$summoned restored=$restore")
    }

    /**
     * 收起控制面板。
     *
     * ⛔ **真销毁**，不是 `Visible(false)`：官方明写 0-alpha 的合成层照样付全额成本，
     * 而成本按屏幕覆盖像素数算。这块面板 2.2m×1.0m 铺在 2.2m 处，占屏不小。
     */
    private fun hideControls() {
        // ⛔ 先把位置抄下来再销毁，否则下次唤出就只能瞎猜一个位置。
        controlsEntity?.tryGetComponent<Transform>()?.transform?.let { lastControlsPose = it }
        controlsEntity?.destroy()
        controlsEntity = null
        // 回到播放页：下次唤出时不该停在「设置」这种深处。
        controls.route = ControlsRoute.PLAYER
    }

    /**
     * 「摆到当前头部朝向正前方」的落点。
     *
     * ⛔ 俯角要和官方 ±15° 上限对账：静息眼高 1.6m，面板中心离地 1.55m、自身高 1.0m、
     * 距离 2.2m ⇒ 下缘 1.05m ⇒ 下压 `atan(0.55 / 2.2)` ≈ **14.0°**，在预算内；
     * 上缘 2.05m ⇒ 仰 11.5°。**面板再高就会把下缘推出 −15°，加内容要往横里加。**
     */
    private fun controlsPoseInFront(): Pose {
        val head = headPose()
            ?: return Pose(
                Vector3(0f, CONTROLS_CENTER_HEIGHT_M, CONTROLS_DISTANCE_M),
                Quaternion(0f, 0f, 0f),
            )
        // ⭐ `removePitchAndRoll()` 是 SDK 自带的：只留 yaw，于是面板永远是竖直的，
        // 不会因为用户当时在低头而歪着出现。官方对面板朝向的要求正是
        // 「pitch and yaw should update automatically… **Hold the panel's roll constant**」。
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

    /** 这个落点还在视线前方吗（用来判断「转过身之后要不要重新摆到面前」）。 */
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
     * 把面板拉到幕布前面来。
     *
     * ⛔ 真机反馈：幕布距离调得很近时，面板被幕布挡住。原因是两者都是靠**深度**排前后的，
     * 幕布一近就压在面板前面。合成层没有「永远画在最上面」的开关
     * （`UIPanelRenderOptions` 只有 renderMode，`MediaPanelRenderOptions` 的 zIndex
     * 管的是媒体面板之间的次序），所以只能从几何上保证面板更近。
     *
     * 规则：保留面板的**方向**，只把**距离**压到 `幕布距离 − 余量`，
     * 且不低于官方的舒适下限（`hands-3d-best-practices`：UI 别落在 0.5–0.8m 的中距离，
     * 要么进直触范围 <46cm，要么推到 **1m 以上**）。
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

    /** 面板该离用户多远：默认 2.2m，但永远比幕布近一截。 */
    private fun controlsDistance(): Float {
        if (!isFlatScreen()) return CONTROLS_DISTANCE_M
        return min(CONTROLS_DISTANCE_M, controls.screenDistance - CONTROLS_SCREEN_CLEARANCE_M)
            .coerceAtLeast(CONTROLS_MIN_DISTANCE_M)
    }

    private fun headPose(): Pose? = systemManager
        .findSystem<PlayerBodyAttachmentSystem>()
        .tryGetLocalPlayerAvatarBody()
        ?.head
        ?.tryGetComponent<Transform>()
        ?.transform

    // ---------------------------------------------------------------- 每帧

    /**
     * ⚠️ 这条方法与面板里 Flutter 的 platform thread **是同一条主线程**（文档 §14），
     * 所以它必须保持廉价。这里只做：读播放位置、看空闲、看捏合、必要时补一次重建。
     */
    override fun onSceneTick() {
        super.onSceneTick()
        val now = SystemClock.uptimeMillis()
        updateTransport()
        pollSummonGesture(now)
        updateAutoHide(now)
        if (geometryRebuildAt != 0L && now >= geometryRebuildAt) {
            geometryRebuildAt = 0L
            rebuildScreenKeepingPlayback()
        }
    }

    private fun updateTransport() {
        val p = exoPlayer ?: return
        if (controls.isPlaying != p.playWhenReady) controls.isPlaying = p.playWhenReady
        if (seeking) return
        val dur = p.duration
        if (dur > 0) {
            controls.progress = (p.currentPosition.toFloat() / dur).coerceIn(0f, 1f)
            controls.positionText = formatMs(p.currentPosition)
            controls.durationText = formatMs(dur)
        }
    }

    /**
     * 捏合唤出。
     *
     * `Controller` 组件在手部输入下把**食指捏合**映射到 ButtonX（左）/ ButtonA（右）
     * （官方 `spatial-sdk-inputs-controllers` 原文）。这里两位一起看，不区分左右 ——
     * 参考软件也不区分。
     *
     * ⛔ 只在**影院态**且**面板已收起**时才响应：浏览态里捏合是操作 Flutter 面板的，
     * 抢了会让整个应用没法用。
     */
    private fun pollSummonGesture(now: Long) {
        if (argUrl.isNullOrBlank()) {
            lastPinchDown = false
            return
        }
        val body = systemManager
            .findSystem<PlayerBodyAttachmentSystem>()
            .tryGetLocalPlayerAvatarBody()
        if (body == null) {
            lastPinchDown = false
            return
        }
        val mask = ButtonBits.ButtonX or ButtonBits.ButtonA
        var down = false
        for (hand in arrayOf(body.leftHand, body.rightHand)) {
            val controller = hand.tryGetComponent<Controller>() ?: continue
            if (!controller.isActive) continue
            if ((controller.buttonState and mask) != 0) down = true
        }
        val rising = down && !lastPinchDown
        lastPinchDown = down
        if (!rising) return
        // 面板已经在了：这次捏合是在操作它，只当作一次「还在用」的心跳。
        if (controlsEntity != null) {
            lastInteractionAt = now
            return
        }
        showControls(summoned = true)
    }

    private fun updateAutoHide(now: Long) {
        if (!controls.autoHide) return
        if (controlsEntity == null) return
        // 暂停时不收：用户刚按了暂停，面板正是他要用的东西。
        if (!controls.isPlaying) {
            lastInteractionAt = now
            return
        }
        // 缓冲中不收：这时候画面是黑的，把唯一有信息的东西也收走等于让人对着黑屏发呆。
        if (controls.buffering) {
            lastInteractionAt = now
            return
        }
        // ⛔ 不在播放页就不收。停在「设置 / 播放列表 / 屏幕类型」这些页上的人正在做一件事，
        // 收起来会连他翻到一半的位置一起丢掉（[hideControls] 会把路由复位到播放页）。
        if (controls.route != ControlsRoute.PLAYER) {
            lastInteractionAt = now
            return
        }
        if (now - lastInteractionAt < controls.autoHideSeconds * 1000L) return
        Log.i(TAG, "IMMERSIVE controls auto-hide after ${controls.autoHideSeconds}s idle")
        hideControls()
    }

    // ---------------------------------------------------------------- 场景/几何/音量

    /**
     * 应用场景选择。
     *
     * ⚠️ 官方要求 passthrough 切换必须 **smooth blending**、不能硬切，
     * 但 Spatial SDK 只暴露一个布尔 `scene.enablePassthrough(Boolean)`，
     * **没有任何不透明度/渐变 API**（本机 aar v0.13.2 的 `Scene` 全表核过：
     * 只有 `enablePassthrough` / `setPassthroughLUT` / `isSystemPassthroughEnabled`）。
     * 所以过渡平不平滑由运行时说了算 —— **这是待真机观察项，不是已解决**。
     */
    private fun applyScene() {
        val passthrough = controls.scene == SceneKind.PASSTHROUGH
        runCatching { scene.enablePassthrough(passthrough) }
            .onFailure { Log.w(TAG, "IMMERSIVE enablePassthrough 失败", it) }
    }

    private fun applyVolume() {
        exoPlayer?.volume = if (controls.muted) 0f else controls.volume
    }

    private fun applyRepeatMode() {
        exoPlayer?.repeatMode = when (controls.repeatMode) {
            RepeatMode.ONE -> Player.REPEAT_MODE_ONE
            RepeatMode.NEXT, RepeatMode.STOP -> Player.REPEAT_MODE_OFF
        }
    }

    /** 距离/高度改了：只挪 Transform，不重建（无接缝）。 */
    private fun applyScreenTransform() {
        if (!isFlatScreen()) return
        panelEntity?.setComponent(Transform(geometricScreenPose()))
    }

    private fun isFlatScreen(): Boolean = argShape == "flat"

    private fun screenPose(): Pose = when {
        // 球幕：观看者在球心，实体就该在原点。
        !isFlatScreen() -> Pose(Vector3(0f, 0f, 0f))
        // 有抓取/上一次的位置就原位放回（换形状不该让幕布瞬移）。
        else -> screenPoseOverride ?: geometricScreenPose()
    }

    /** 按「距离 + 高度」两条滑块算出来的标准落点。 */
    private fun geometricScreenPose(): Pose =
        Pose(Vector3(0f, EYE_HEIGHT_M + controls.screenOffset, controls.screenDistance))

    /**
     * 只换几何（形状 / 投影 / 立体编排），**片子不动**。
     *
     * ⛔ 不再记 `pendingSeekMs` 也不再重开播放器：播放器根本没被释放，
     * 位置、缓冲、解码器全都还在，只是输出重新指到新实体的 Surface 上。
     */
    private fun rebuildScreenKeepingPlayback() = rebuildPanel(keepPlayback = true)

    /** intent / bridge 传来的字符串档位同步到面板状态。 */
    private fun syncFormatToControls() {
        controls.projection = when (argShape) {
            "180" -> VideoProjection.PANORAMA_180
            "360" -> VideoProjection.PANORAMA_360
            else -> VideoProjection.FLAT
        }
        controls.stereo = when (argStereo) {
            "lr" -> StereoLayout.SIDE_BY_SIDE
            "tb" -> StereoLayout.TOP_BOTTOM
            else -> StereoLayout.MONO
        }
        controls.curveAvailable = isFlatScreen()
    }

    /**
     * 重新居中：把视图原点挪到当前头部位置与朝向，于是所有世界锁定的面板都回到面前。
     *
     * 球幕模式下这是唯一的「摆正」手段 —— 人在球心，球本身没法抓也不该移动
     * （官方：曲面面板不能被抓取变换）。
     */
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
        argUrl = null
        rebuildPanel()
    }

    /**
     * 把当前片源交给本机其它播放器。
     *
     * 给的是 EAC / 鱼眼这类**我们渲染不了**的投影一条出路。直链自证、不需要鉴权头
     * （设计文档事实 6：现有播放路径一个 HTTP 头都不下发），所以递 URL 就够。
     * ⚠️ 代价与 2D 侧的「用其他应用打开」一样：链接有时效，且外部播放器拿不到我们的
     * 续期能力，长片可能中途断。
     */
    private fun handOffToExternalPlayer() {
        val url = argUrl
        if (url.isNullOrBlank()) return
        val view = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse(url), "video/*")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        runCatching {
            startActivity(
                Intent.createChooser(view, "用其他应用打开")
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
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

    // ---------------------------------------------------------------- 面板注册

    // ⛔ 这个方法是在 `super.onCreate()` **内部**被调用的，而 `readIntent()` 在
    // `super.onCreate()` **之后**才跑 —— 所以这里**读不到任何 intent 参数**。
    // 官方措辞正好解释了正确写法：「Registration happens once during activity
    // initialization… **A registered panel does not appear in the scene**」——
    // 注册是免费的，是否出现在场景里由 Entity 决定。所以**无条件注册**。
    override fun registerPanels(): List<PanelRegistration> = listOf(
        // Flutter 的 MainActivity 作为空间面板。
        // ⚠️ 官方预算表：**UI view panel 15/40，Activity-based panel 2/2** ——
        // 这条路是官方眼里最贵的一条，迁到 ViewPanel 的前置是 FlutterEngineCache 化，
        // 那是另一条线（文档 §12）。
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
        // 空间化的控制面板。走 view-based 的 Compose 面板（官方预算 15/40，
        // 比 Activity-based 的 2/2 宽裕得多，控制面板这种小面板没理由用后者）。
        ComposeViewPanelRegistration(
            R.id.vr_controls_panel,
            { _, ctx -> createVideoControlsView(ctx, controls, controlsCallbacks) },
            {
                UIPanelSettings(
                    shape = QuadShapeOptions(
                        width = CONTROLS_WIDTH_M,
                        height = CONTROLS_HEIGHT_M,
                    ),
                    // 500dp/m 是官方默认换算，1dp = 2mm。面板逻辑尺寸因此是
                    // 1100×500dp，与 `:questui` 的 `PanelTokens` 成对，改要一起改。
                    display = DpPerMeterDisplayOptions(dpPerMeter = 500f),
                    // ⭐ 透明底：顶栏那排圆钮要像参考软件一样悬浮在窗**外**，
                    // 钮与钮之间的缝得透出后面的画面。
                    // ⚠️ 未真机验证。若出现黑底/怪边，把这一行删掉即可退回不透明面板
                    // （只影响观感，不影响功能）。
                    rendering = UIPanelRenderOptions(
                        renderMode = PanelRenderMode.Layer(
                            layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND,
                        ),
                    ),
                )
            },
        ),
        VideoSurfacePanelRegistration(
            R.id.vr_video_panel,
            surfaceConsumer = { _, surface -> startPlayback(surface) },
            settingsCreator = {
                MediaPanelSettings(
                    shape = screenShape(),
                    display = PixelDisplayOptions(width = argWidth, height = argHeight),
                    rendering = MediaPanelRenderOptions(
                        stereoMode = when (argStereo) {
                            "lr" -> StereoMode.LeftRight
                            "tb" -> StereoMode.UpDown
                            else -> StereoMode.None
                        },
                        // 球面永远画在最里层，否则会挡住控件。
                        zIndex = if (isFlatScreen()) 0 else -1,
                    ),
                )
            },
        ),
    )

    /**
     * 幕布形状。
     *
     * ⚠️ **弧幕是本设计最大的单点未知**：`CylinderShapeOptions` 在类型系统上是合法的
     * 媒体面板形状（`CylinderShapeOptions : MediaPanelShapeOptions`，本机 aar 逐字核过），
     * **但官方 `spatial-sdk-media-playback` 列的媒体面板形状只有
     * Quad / Equirect180 / Equirect360**，没有 Cylinder；官方自家 Media View 样例里的
     * 弯屏视频用的是自建 `SceneMesh.cylinderSurface(...)`。**能编译 ≠ 官方支持。**
     *
     * 所以 [ScreenCurve.FLAT] 永远走 Quad，是保证能用的那一档，也是默认。
     *
     * 几何模型：**幕宽是弧长**（用户滑块直接给），弧度档决定包多紧，
     * 于是 `radius = 弧长 / 弧度`。60° + 2.4m 宽 ⇒ 半径 2.29m ≈ 默认观看距离 2.5m，
     * 正好接近「曲率半径 = 观看距离」那个理想值（每个像素到眼等距，无梯形畸变）。
     */
    private fun screenShape(): MediaPanelShapeOptions = when {
        !isFlatScreen() && argShape == "360" -> Equirect360ShapeOptions(radius = SPHERE_RADIUS)
        !isFlatScreen() -> Equirect180ShapeOptions(radius = SPHERE_RADIUS)
        controls.curve == ScreenCurve.FLAT -> QuadShapeOptions(
            width = controls.screenWidth,
            height = controls.screenWidth / eyeAspectRatio(),
        )
        else -> {
            val arcRadians = (controls.curve.arcDegrees * PI / 180.0).toFloat()
            CylinderShapeOptions(
                radius = max(0.5f, controls.screenWidth / arcRadians),
                width = controls.screenWidth,
                height = controls.screenWidth / eyeAspectRatio(),
            )
        }
    }

    /** 单眼画面的真实宽高比：立体片取半幅之后才是人眼看到的那个比例。 */
    private fun eyeAspectRatio(): Float {
        if (argWidth <= 0 || argHeight <= 0) return 16f / 9f
        return when (argStereo) {
            "lr" -> (argWidth / 2f) / argHeight
            "tb" -> argWidth / (argHeight / 2f)
            else -> argWidth.toFloat() / argHeight
        }
    }

    // ---------------------------------------------------------------- 播放

    @OptIn(UnstableApi::class)
    private fun startPlayback(surface: android.view.Surface) {
        val url = argUrl
        if (url.isNullOrBlank()) {
            Log.w(TAG, "IMMERSIVE 没有 url extra，只建场景不起播")
            logMemory("sceneOnly")
            return
        }

        // ⭐ 换形状（屏幕类型 / 幕宽 / 投影 / 立体编排）走的是这条：**同一条片子，
        // 只是换了个面板实体**。留着原播放器、把输出重新指到新 Surface 上即可 ——
        // 缓冲区、解码器、播放位置全都不动，用户看不到「一黑然后重新加载」。
        // ⛔ 此前这里无条件新建播放器，那正是真机上「调屏幕类型 = 视频重载」的根因。
        val running = exoPlayer
        if (running != null && playingUrl == url) {
            Log.i(TAG, "IMMERSIVE 复用播放器，只换 surface")
            running.setVideoSurface(surface)
            return
        }
        releasePlayer()
        // Iwara 直链靠 query 里的 expires + 签名自证，**不需要鉴权头**
        // （事实 6：现有播放路径一个 HTTP 头都不下发）。这里只留 UA 与超时。
        val httpFactory = DefaultHttpDataSource.Factory()
            .setUserAgent(DEFAULT_UA)
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(15_000)
            .setReadTimeoutMs(15_000)

        // 外层套 DefaultDataSource：它按 scheme 分派，http/https 交给上面那个
        // httpFactory，file:// / content:// 走本地读取。**不能只给 httpFactory**
        // —— 那样一切非 http 的 uri 都打不开，已下载到本地的片子在沉浸态里就播不了
        // （离线优先是既有的下载能力，VR 态不该倒退）。
        val dataSourceFactory = DefaultDataSource.Factory(this, httpFactory)

        val player = ExoPlayer.Builder(this)
            .setMediaSourceFactory(DefaultMediaSourceFactory(dataSourceFactory))
            .build()

        player.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                Log.e(TAG, "IMMERSIVE PLAYBACK_ERROR ${error.errorCodeName}: ${error.message}", error)
                controls.notice = "这个片源放不出来（${error.errorCodeName}），可以换外部播放器试试"
                controls.buffering = false
                // ⛔ 出错时必须把面板召回来，否则用户对着黑屏没有任何可操作的东西。
                showControls(summoned = true)
            }

            override fun onPlaybackStateChanged(state: Int) {
                val name = when (state) {
                    Player.STATE_IDLE -> "IDLE"
                    Player.STATE_BUFFERING -> "BUFFERING"
                    Player.STATE_READY -> "READY"
                    Player.STATE_ENDED -> "ENDED"
                    else -> "?"
                }
                Log.i(TAG, "IMMERSIVE PLAYBACK_STATE $name")
                // ⛔ 缓冲态必须让用户看得见。真机反馈：换形状时「画面一黑就没了」，
                // 而面板上没有任何东西说明发生了什么 —— 黑屏 + 无反馈 = 像死机。
                controls.buffering = state == Player.STATE_BUFFERING
                if (state == Player.STATE_READY) {
                    logMemory("playing")
                    // 换投影/换屏幕类型导致的重建：接回原来的进度，别退回片头。
                    if (pendingSeekMs > 0) {
                        player.seekTo(pendingSeekMs)
                        pendingSeekMs = 0
                    }
                }
                if (state == Player.STATE_ENDED && controls.repeatMode == RepeatMode.NEXT) {
                    adjacentPlayable(forward = true)?.let {
                        controls.playlistLoading = true
                        ImmersiveBridge.requestPlayItem(it.id)
                    }
                }
            }

            override fun onVideoSizeChanged(videoSize: VideoSize) {
                Log.i(TAG, "IMMERSIVE VIDEO_SIZE ${videoSize.width}x${videoSize.height}")
            }
        })

        if (argMute) controls.muted = true
        controls.isPlaying = true
        controls.progress = 0f
        controls.buffering = true
        speedIndex = 2
        controls.speedText = "1.0×"
        exoPlayer = player
        playingUrl = url
        applyRepeatMode()
        applyVolume()
        player.setVideoSurface(surface)
        player.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
        player.prepare()
        player.playWhenReady = true
    }

    private fun releasePlayer() {
        exoPlayer?.release()
        exoPlayer = null
        playingUrl = null
        controls.buffering = false
    }

    private fun formatMs(ms: Long): String {
        if (ms <= 0) return "0:00"
        val total = ms / 1000
        val h = total / 3600
        val m = (total % 3600) / 60
        val s = total % 60
        return if (h > 0) String.format("%d:%02d:%02d", h, m, s) else String.format("%d:%02d", m, s)
    }

    /**
     * 打一行内存采样。同进程跑起来之后 PSS 涨到哪儿、退出后收不收得回来，
     * 直接决定 §6.6 那套架构成不成立。
     *
     * ⛔ 已知欠账：显存**目前根本没还回来**（Visible(false) / 停 Flutter 出帧 /
     * 销毁幕布实体三招实测全无效，Graphics 稳在 ~290MB、PSS 冲到 1GB+）。
     * 本项目有 LMK/OOM 闪退前科，这条是头号技术债，见文档 §14。
     */
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

    /**
     * ⛔ 清理逻辑必须放这里，**不能只放 `onDestroy()`** —— 官方明写
     * "`onDestroy` is not guaranteed to be called. Consider putting shutdown logic in
     * `onSpatialShutdown()`"，只有后者被保证调用。
     *
     * ⛔ 与之配套的另一条官方铁律：**永远不要用 `finish()` 结束挂着面板的 Activity**。
     * 面板的 3D mesh / layer / texture / Android surface 的内存引用还活着，
     * 会在 `libMetaSpatialSDK.so` 里 SIGSEGV。
     */
    override fun onSpatialShutdown() {
        Log.i(TAG, "IMMERSIVE onSpatialShutdown")
        logMemory("onSpatialShutdown")
        ImmersiveBridge.detachScene()
        panelEntity?.destroy()
        panelEntity = null
        uiPanelEntity?.destroy()
        uiPanelEntity = null
        controlsEntity?.destroy()
        controlsEntity = null
        releasePlayer()
        super.onSpatialShutdown()
    }

    override fun onDestroy() {
        Log.i(TAG, "IMMERSIVE onDestroy")
        logMemory("onDestroy")
        // 兜底：onSpatialShutdown 正常情况下已经清干净了，这句是幂等的。
        releasePlayer()
        super.onDestroy()
    }

    companion object {
        const val TAG = "IwaraVR"
        private const val SPHERE_RADIUS = 50.0f

        /** 静息眼高（米）。参考空间是 LOCAL_FLOOR，所以场景里的 y 都是绝对高度。 */
        private const val EYE_HEIGHT_M = 1.60f

        /** 默认观看距离（米）。设计文档 §6.6 的取值。 */
        private const val DEFAULT_VIEW_DISTANCE_M = 2.5f

        /** 默认幕宽（米）：2.5m 处 55° 水平弧 ≈ 2.4m。 */
        private const val DEFAULT_QUAD_WIDTH_M = 2.4f

        /** UI 面板的几何：1.8m 处 1.6m 宽 ≈ 47° 水平张角，与静息眼高齐平。 */
        private const val UI_PANEL_DISTANCE_M = 1.8f
        private const val UI_PANEL_WIDTH_M = 1.6f
        private const val UI_PANEL_HEIGHT_M = 1.60f

        /**
         * 控制面板几何。⛔ 与 `:questui` 的 `PanelTokens.WIDTH_DP / HEIGHT_DP` 成对
         * （2.2m × 1.0m @ 500dp/m = 1100 × 500dp），改一边必须改另一边。
         *
         * 俯角对账见 [controlsPose] 的注释：下缘下压 ≈14.0°，在官方 ±15° 内。
         */
        private const val CONTROLS_DISTANCE_M = 2.2f

        /**
         * 面板与幕布之间至少留这么多余量（米）。
         *
         * ⛔ 合成层没有「永远画在最上面」的开关，前后完全按深度排 —— 幕布拉近到面板
         * 前面就会把它挡住（2026-08-29 真机反馈）。只能从几何上保证面板更近。
         */
        private const val CONTROLS_SCREEN_CLEARANCE_M = 0.45f

        /**
         * 面板离用户的下限（米）。官方 `hands-3d-best-practices`：
         * 「**Avoid placing UI in the middle distance (roughly 0.5m to 0.8m)**… push it
         * well into raycast range (**1m or more**)」。
         */
        private const val CONTROLS_MIN_DISTANCE_M = 1.0f

        /** 「还算在视线前方」的判据：cos 60°。超过这个角度才认为面板转到身后了。 */
        private const val SUMMON_FOV_COS = 0.5f
        private const val CONTROLS_CENTER_HEIGHT_M = 1.55f
        private const val CONTROLS_WIDTH_M = 2.2f
        private const val CONTROLS_HEIGHT_M = 1.0f

        /** 幕宽滑块停手多久之后才真的重建幕布。 */
        private const val GEOMETRY_DEBOUNCE_MS = 350L

        /** 倍速档。1.0 在下标 2，起播时复位到它。 */
        private val SPEEDS = floatArrayOf(0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 2.0f)

        private const val DEFAULT_UA =
            "Mozilla/5.0 (Linux; Android 14; Quest 3) AppleWebKit/537.36 " +
                "Chrome/126.0.0.0 Safari/537.36"
    }
}
