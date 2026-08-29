package m.c.g.a.i_iwara.xr

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * `quest` 变体的真实现：把 Dart 侧的「把这个视频空间化呈现」接到沉浸场景上。
 *
 * # 为什么走进程内单例而不是跨进程
 *
 * 已实测：沉浸 Activity 与承载 Flutter 的 [m.c.g.a.i_iwara.MainActivity] **同进程**
 * （面板形态下 MainActivity 就活在沉浸 Activity 的虚拟显示里）。所以这里不存在 IPC，
 * [ImmersiveBridge] 就是一个普通的对象引用，没有序列化、没有跨进程死亡问题。
 *
 * # 契约
 *
 * Dart → Kotlin（通道 `i_iwara/immersive`）：
 * - `isAvailable` → Boolean，沉浸场景当前是否活着（Dart 用它决定要不要显示入口）
 * - `present` → `{url, title, shape: flat|180|360, stereo: none|lr|tb, w, h,
 *                positionMs, unsupportedProjection}`
 * - `dismiss` → 收起幕布，只留 UI 面板
 * - `setPlaylist` → `{items: [{id,title,author,durationText,progress,watched,playable}],
 *                    nowPlayingId}`
 *
 * Kotlin → Dart（同一条通道）：
 * - `requestPlaylist` → 让 Dart 重新推一次「接着看」
 * - `playItem` `{id}` → 让 Dart 把这条解析成地址再 `present` 回来
 *
 * ⛔ **反向调用只有这两条，刻意保持得很窄**。设计文档 §6.6 已经否掉了「沉浸端持续
 * 回打 Dart 的瘦客户端架构」（跨端持续同步最脆，LMK 一杀会话中途崩），
 * 这里是「原生自足 + 偶尔向 Dart 要一次数据」。
 */
object XrBridge {

    private const val CHANNEL = "i_iwara/immersive"
    private const val TAG = "IwaraVR"

    fun attach(activity: Activity, engine: FlutterEngine) {
        ImmersiveBridge.attachEngine(engine)
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        ImmersiveBridge.attachChannel(channel)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(ImmersiveBridge.isSceneAlive)

                "present" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("bad_args", "url 不能为空", null)
                    } else {
                        val request = ImmersiveVideoRequest(
                            url = url,
                            title = call.argument<String>("title") ?: "",
                            shape = call.argument<String>("shape") ?: "flat",
                            stereo = call.argument<String>("stereo") ?: "none",
                            width = call.argument<Int>("w") ?: 0,
                            height = call.argument<Int>("h") ?: 0,
                            positionMs = (call.argument<Number>("positionMs") ?: 0).toLong(),
                            unsupportedProjection =
                                call.argument<Boolean>("unsupportedProjection") ?: false,
                        )
                        Log.i(TAG, "XR present shape=${request.shape} stereo=${request.stereo}")
                        result.success(ImmersiveBridge.present(request))
                    }
                }

                "dismiss" -> result.success(ImmersiveBridge.dismiss())

                "setPlaylist" -> {
                    val raw = call.argument<List<Map<String, Any?>>>("items").orEmpty()
                    val items = raw.map { row ->
                        ImmersivePlaylistItem(
                            id = row["id"] as? String ?: "",
                            title = row["title"] as? String ?: "",
                            author = row["author"] as? String ?: "",
                            durationText = row["durationText"] as? String ?: "",
                            progress = (row["progress"] as? Number)?.toFloat() ?: 0f,
                            watched = row["watched"] as? Boolean ?: false,
                            playable = row["playable"] as? Boolean ?: true,
                        )
                    }.filter { it.id.isNotEmpty() }
                    ImmersiveBridge.setPlaylist(items, call.argument<String>("nowPlayingId"))
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}

/** 一次「把这个视频空间化呈现」的请求。纯数据，便于将来直接落盘做冷返回兜底。 */
data class ImmersiveVideoRequest(
    val url: String,
    val title: String,
    val shape: String,
    val stereo: String,
    val width: Int,
    val height: Int,
    val positionMs: Long,
    /** 片源投影 SDK 渲染不了（目前只有鱼眼）。面板据此如实提示并给外部播放器出口。 */
    val unsupportedProjection: Boolean,
)

/** 「接着看」里的一条，字段与 Dart 的 `XrPlaylistEntry` 一一对应。 */
data class ImmersivePlaylistItem(
    val id: String,
    val title: String,
    val author: String,
    val durationText: String,
    val progress: Float,
    val watched: Boolean,
    val playable: Boolean,
)

/**
 * 进程内的会合点：Flutter 面板这一侧发请求，沉浸场景那一侧消费。
 *
 * ⚠️ 沉浸场景可能还没 ready（例如 Dart 在 `onSceneReady` 之前就发了请求），
 * 所以这里保留 [pending]，场景就绪时自取。
 */
object ImmersiveBridge {

    private const val TAG = "IwaraVR"

    /** 沉浸场景就绪后由 ImmersiveActivity 设置；Dart 靠它判断入口要不要露出。 */
    @Volatile
    var isSceneAlive: Boolean = false
        private set

    /**
     * 承载 UI 面板的那个 Flutter 引擎。弱引用：引擎的生死由 MainActivity 负责，
     * 这里只是借用，不该延长它的寿命。
     */
    private var engineRef: WeakReference<FlutterEngine>? = null

    /** 反向调用用的通道。与 [engineRef] 同生共死。 */
    private var channelRef: WeakReference<MethodChannel>? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    fun attachEngine(engine: FlutterEngine) {
        engineRef = WeakReference(engine)
    }

    fun attachChannel(channel: MethodChannel) {
        channelRef = WeakReference(channel)
    }

    /**
     * 让面板里的 Flutter **停止出帧**，但不销毁它。
     *
     * # 为什么需要这个
     *
     * 实测（2026-08-29）：把 UI 面板设成 `Visible(false)` **什么都不省** ——
     * Graphics 稳在 281.9MB 不动，`topResumedActivity` 依然是 MainActivity，
     * 也就是 Flutter 照常渲染、照常占用主线程。这与官方那条
     * 「0-alpha 贴图代替销毁照样付钱」是同一回事。
     *
     * 而官方给的处方（`panelEntity.destroy()`）在我们这里代价太大：那会连 Activity
     * 一起销毁，Flutter 引擎冷重启、页面状态全丢。
     *
     * 第三条路：走 Flutter 自己的生命周期通道。引擎收到 paused 后停止出帧，
     * 但 Activity、引擎、Dart isolate 全都活着 —— 而我们**当天已实测**
     * `AppLifecycleState.paused` 下 Dart 的定时器与异步 I/O 照常工作，
     * 所以「Dart 当大脑」不受影响，沉浸面板向 Dart 要播放列表/换片也照样能跑。
     *
     * ⚠️ 副作用要盯：应用自己的「后台即上锁」逻辑是按 paused 判定真后台的
     * （见记忆 app-lock-pr108-merge）。看视频时被判成进后台，回来可能要求生物识别。
     * 这条必须真机确认。
     */
    fun setPanelRenderingPaused(paused: Boolean) {
        val engine = engineRef?.get() ?: return
        if (paused) engine.lifecycleChannel.appIsPaused() else engine.lifecycleChannel.appIsResumed()
    }

    // ---------------------------------------------------------------- 场景侧

    private var listener: Listener? = null
    private var pending: ImmersiveVideoRequest? = null

    /** 场景还没就绪时先攒着的播放列表。 */
    private var pendingPlaylist: Pair<List<ImmersivePlaylistItem>, String?>? = null

    interface Listener {
        fun onPresent(request: ImmersiveVideoRequest)
        fun onDismiss()
        fun onPlaylist(items: List<ImmersivePlaylistItem>, nowPlayingId: String?)
    }

    /** 场景就绪。返回时会把等待中的请求补投一次。 */
    fun attachScene(listener: Listener) {
        this.listener = listener
        isSceneAlive = true
        pendingPlaylist?.let {
            pendingPlaylist = null
            listener.onPlaylist(it.first, it.second)
        }
        pending?.let {
            pending = null
            listener.onPresent(it)
        }
    }

    fun detachScene() {
        listener = null
        isSceneAlive = false
        pending = null
        pendingPlaylist = null
    }

    /** @return true 表示已直接投递给场景；false 表示场景未就绪、已暂存。 */
    fun present(request: ImmersiveVideoRequest): Boolean {
        val target = listener
        return if (target == null) {
            pending = request
            false
        } else {
            target.onPresent(request)
            true
        }
    }

    fun dismiss(): Boolean {
        pending = null
        val target = listener ?: return false
        target.onDismiss()
        return true
    }

    fun setPlaylist(items: List<ImmersivePlaylistItem>, nowPlayingId: String?) {
        val target = listener
        if (target == null) {
            pendingPlaylist = items to nowPlayingId
        } else {
            target.onPlaylist(items, nowPlayingId)
        }
    }

    // ---------------------------------------------------------------- 反向调用

    /**
     * 请 Dart 重新推一次「接着看」。
     *
     * ⛔ `MethodChannel` 只能在主线程调用，而这里的调用点在 Spatial 的场景回调里 ——
     * 那**恰好也是主线程**（`onSceneTick` 与 Flutter 的 platform thread 同一条，
     * 见文档 §14），但为了不把这个巧合写死成前提，统一 post 一次。
     */
    fun requestPlaylist() {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("requestPlaylist", null) }
    }

    /** 请 Dart 把这条解析成可播地址，然后它会自己 `present` 回来。 */
    fun requestPlayItem(id: String) {
        val channel = channelRef?.get()
        if (channel == null) {
            Log.w(TAG, "XR requestPlayItem 但通道已不在 id=$id")
            return
        }
        mainHandler.post { channel.invokeMethod("playItem", mapOf("id" to id)) }
    }
}
