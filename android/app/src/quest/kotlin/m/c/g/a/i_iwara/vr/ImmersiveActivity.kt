package m.c.g.a.i_iwara.vr

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Debug
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
import com.meta.spatial.core.Entity
import com.meta.spatial.core.Pose
import com.meta.spatial.core.SpatialFeature
import com.meta.spatial.core.Vector3
import com.meta.spatial.runtime.ReferenceSpace
import com.meta.spatial.runtime.StereoMode
import com.meta.spatial.toolkit.AppSystemActivity
import com.meta.spatial.toolkit.Equirect180ShapeOptions
import com.meta.spatial.toolkit.Equirect360ShapeOptions
import com.meta.spatial.toolkit.MediaPanelRenderOptions
import com.meta.spatial.toolkit.MediaPanelSettings
import com.meta.spatial.toolkit.Panel
import com.meta.spatial.toolkit.PanelRegistration
import com.meta.spatial.toolkit.PixelDisplayOptions
import com.meta.spatial.toolkit.QuadShapeOptions
import com.meta.spatial.toolkit.Transform
import com.meta.spatial.toolkit.VideoSurfacePanelRegistration
import com.meta.spatial.toolkit.Visible
import com.meta.spatial.vr.VRFeature
import m.c.g.a.i_iwara.R

/**
 * Quest 沉浸式播放 Activity。**只存在于 quest 变体**，standard 包既不编译它、
 * 也不链接任何 Spatial SDK 的 `.aar`（硬约束 C1：普通安卓包零增重、minSdk 不抬）。
 *
 * # 本期的职责：过闸门，不是做功能
 *
 * 这一版刻意保持在 spike 已验证过的形状上（`VideoSurfacePanelRegistration` +
 * `Equirect180/360ShapeOptions` + `MediaPanelRenderOptions`），因为它要回答的是
 * 设计文档 R2 那个**尚未验证的硬前提**：
 *
 * > 真 Flutter 引擎 + Spatial SDK **同进程**会怎样。
 *
 * 此前 spike 里跟 Spatial SDK 同进程的是一个 Kotlin 占位面板，而「真实 LoveIwara
 * 被沉浸式接管后存活」那次是**跨应用**验的 —— 两者都不能替代「Flutter 引擎和
 * Spatial 渲染栈在同一个进程里」这件事。本项目播放中 PSS 就有 285MB，而且本来
 * 就有 LMK/OOM 闪退前科，所以这条不过，§6.6 那套「Flutter onStop 省内存 + 原生
 * 空间面板」的架构地基就是空的。
 *
 * 因此本 Activity **没有** android:process 属性 —— 与 [m.c.g.a.i_iwara.MainActivity]
 * 同进程是刻意的，正是被测对象。
 *
 * # 内存取样
 *
 * 关键节点（onCreate / onSceneReady / 起播 / onDestroy）都会打一行
 * `IMMERSIVE_MEM`，含 PSS 与 Dart 侧关心的 RSS 量级，方便直接从 logcat 拉曲线，
 * 不必接 profiler。
 *
 * # 参数走 intent extra
 *
 * 沿用 spike 验证过的契约，可以直接用 adb 喂一条真实直链：
 * ```
 * adb shell am start -n <pkg>/m.c.g.a.i_iwara.vr.ImmersiveActivity \
 *   --es url "https://..." --es shape 180 --es stereo lr --ei w 4096 --ei h 2048
 * ```
 * `shape`: flat | 180 | 360      `stereo`: none | lr | tb
 *
 * 之所以先走 intent 而不是先接 MethodChannel：闸门只关心同进程表现，接 Dart 通道
 * 是功能接线，放在闸门通过之后做才不会白写。
 */
class ImmersiveActivity : AppSystemActivity() {

    private var exoPlayer: ExoPlayer? = null
    private var panelEntity: Entity? = null

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

    override fun registerFeatures(): List<SpatialFeature> = listOf(VRFeature(this))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "IMMERSIVE onCreate pid=${android.os.Process.myPid()}")
        logMemory("onCreate")
        readIntent(intent)
    }

    override fun onNewIntent(newIntent: Intent) {
        super.onNewIntent(newIntent)
        readIntent(newIntent)
        rebuildPanel()
    }

    private fun readIntent(source: Intent?) {
        source ?: return
        argUrl = source.getStringExtra("url") ?: argUrl
        argShape = source.getStringExtra("shape") ?: argShape
        argStereo = source.getStringExtra("stereo") ?: argStereo
        argWidth = source.getIntExtra("w", argWidth)
        argHeight = source.getIntExtra("h", argHeight)
        argMute = source.getBooleanExtra("mute", argMute)
        Log.i(
            TAG,
            "IMMERSIVE args shape=$argShape stereo=$argStereo mute=$argMute " +
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
        Log.i(TAG, "IMMERSIVE onSceneReady")
        logMemory("onSceneReady")
        rebuildPanel()
    }

    private fun rebuildPanel() {
        panelEntity?.destroy()
        releasePlayer()
        // ⛔ 平面/弧幕**必须摆到人前方**。原来这里用的是单位变换 `Transform()`，
        // 等于把幕布摆在原点 —— 参考空间是 LOCAL_FLOOR，原点在脚下，人正好站在
        // 幕布里面/背面，结果是**一片全黑**（2026-08-29 Quest 3 真机实测踩到；
        // 昨天的 spike 只测了 180°，这条从来没被覆盖）。
        //
        // 球面不受影响：半径 50m 的球本来就该以观看者为中心，原点是对的。
        val pose = if (argShape == "flat") {
            Pose(Vector3(0f, SCREEN_CENTER_HEIGHT_M, -VIEW_DISTANCE_M))
        } else {
            Pose(Vector3(0f, 0f, 0f))
        }
        panelEntity = Entity.create(Panel(R.id.vr_video_panel), Transform(pose), Visible(true))
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

    override fun registerPanels(): List<PanelRegistration> = listOf(
        VideoSurfacePanelRegistration(
            R.id.vr_video_panel,
            surfaceConsumer = { _, surface -> startPlayback(surface) },
            settingsCreator = {
                MediaPanelSettings(
                    shape = when (argShape) {
                        "360" -> Equirect360ShapeOptions(radius = SPHERE_RADIUS)
                        "180" -> Equirect180ShapeOptions(radius = SPHERE_RADIUS)
                        // 幕宽按设计文档 §6.6 的 55° 水平弧算（2.5m 处约 2.4m），
                        // 高度跟着单眼宽高比走，不写死 16:9 —— 竖屏片和 21:9 都得保比例。
                        else -> QuadShapeOptions(
                            width = QUAD_WIDTH_M,
                            height = QUAD_WIDTH_M / eyeAspectRatio(),
                        )
                    },
                    display = PixelDisplayOptions(width = argWidth, height = argHeight),
                    rendering = MediaPanelRenderOptions(
                        stereoMode = when (argStereo) {
                            "lr" -> StereoMode.LeftRight
                            "tb" -> StereoMode.UpDown
                            else -> StereoMode.None
                        },
                        // 球面永远画在最里层，否则会挡住控件。
                        zIndex = if (argShape == "flat") 0 else -1,
                    ),
                )
            },
        ),
    )

    @OptIn(UnstableApi::class)
    private fun startPlayback(surface: android.view.Surface) {
        val url = argUrl
        if (url.isNullOrBlank()) {
            Log.w(TAG, "IMMERSIVE 没有 url extra，只建场景不起播")
            logMemory("sceneOnly")
            return
        }
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
                if (state == Player.STATE_READY) logMemory("playing")
            }

            override fun onVideoSizeChanged(videoSize: VideoSize) {
                Log.i(TAG, "IMMERSIVE VIDEO_SIZE ${videoSize.width}x${videoSize.height}")
            }
        })

        player.repeatMode = Player.REPEAT_MODE_ONE
        if (argMute) player.volume = 0f
        player.setVideoSurface(surface)
        player.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
        player.prepare()
        player.playWhenReady = true
        exoPlayer = player
    }

    private fun releasePlayer() {
        exoPlayer?.release()
        exoPlayer = null
    }

    /**
     * 打一行内存采样。闸门的判据全靠它 —— 同进程跑起来之后 PSS 涨到哪儿、
     * 退出后收不收得回来，直接决定 §6.6 那套架构成不成立。
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
     * 原因是面板的 3D mesh / layer / texture / Android surface 的内存引用还活着，
     * 会在 `libMetaSpatialSDK.so` 里 SIGSEGV。正解是 `panelEntity.destroy()`
     * 之后走 `launchPanelActivityInHome()` 那套转场。见文档 §19。
     */
    override fun onSpatialShutdown() {
        Log.i(TAG, "IMMERSIVE onSpatialShutdown")
        logMemory("onSpatialShutdown")
        panelEntity?.destroy()
        panelEntity = null
        releasePlayer()
        super.onSpatialShutdown()
    }

    override fun onDestroy() {
        Log.i(TAG, "IMMERSIVE onDestroy")
        logMemory("onDestroy")
        // 兜底：onSpatialShutdown 正常情况下已经清干净了，这两句是幂等的。
        releasePlayer()
        super.onDestroy()
    }

    companion object {
        const val TAG = "IwaraVR"
        private const val SPHERE_RADIUS = 50.0f

        /** 观看距离（米）。设计文档 §6.6 的取值，也是弧幕的曲率半径。 */
        private const val VIEW_DISTANCE_M = 2.5f

        /** 幕宽（米）：2.5m 处 55° 水平弧 ≈ 2.4m。 */
        private const val QUAD_WIDTH_M = 2.4f

        /**
         * 幕布中心离地高度（米）。参考空间是 LOCAL_FLOOR，所以这是绝对高度。
         *
         * ⛔ 原值 1.34f 是按「静息视线 −6° 俯角」算的（1.6 − 2.5·tan6°）。**已作废**：
         * 官方要求 "avoid forcing the user to tilt their head down more than **±15°**"，
         * 而 2.5m 处 2.4m 宽的 16:9 幕布垂直张角就是 ±15.1° —— 幕心再下压 6°，
         * 下缘会落到 −21°，越线一大截（见文档 §19-4 / §6.6 模式 A）。
         * 幕心抬到与静息眼高齐平（0° 俯角）后，上下缘正好 ±15.1°，卡在官方上限。
         */
        private const val SCREEN_CENTER_HEIGHT_M = 1.60f
        private const val DEFAULT_UA =
            "Mozilla/5.0 (Linux; Android 14; Quest 3) AppleWebKit/537.36 " +
                "Chrome/126.0.0.0 Safari/537.36"
    }
}
