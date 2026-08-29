package m.c.g.a.i_iwara.xr

import android.app.Activity
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
 * - `present` → 参数 `{url, shape: flat|180|360, stereo: none|lr|tb, w, h, positionMs}`
 * - `dismiss` → 收起幕布，只留 UI 面板
 */
object XrBridge {

    private const val CHANNEL = "i_iwara/immersive"
    private const val TAG = "IwaraVR"

    fun attach(activity: Activity, engine: FlutterEngine) {
        ImmersiveBridge.attachEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
            when (call.method) {
                "isAvailable" -> result.success(ImmersiveBridge.isSceneAlive)

                "present" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("bad_args", "url 不能为空", null)
                    } else {
                        val request = ImmersiveVideoRequest(
                            url = url,
                            shape = call.argument<String>("shape") ?: "flat",
                            stereo = call.argument<String>("stereo") ?: "none",
                            width = call.argument<Int>("w") ?: 0,
                            height = call.argument<Int>("h") ?: 0,
                            positionMs = (call.argument<Number>("positionMs") ?: 0).toLong(),
                        )
                        Log.i(TAG, "XR present shape=${request.shape} stereo=${request.stereo}")
                        val delivered = ImmersiveBridge.present(request)
                        result.success(delivered)
                    }
                }

                "dismiss" -> result.success(ImmersiveBridge.dismiss())

                else -> result.notImplemented()
            }
        }
    }
}

/** 一次「把这个视频空间化呈现」的请求。纯数据，便于将来直接落盘做冷返回兜底。 */
data class ImmersiveVideoRequest(
    val url: String,
    val shape: String,
    val stereo: String,
    val width: Int,
    val height: Int,
    val positionMs: Long,
)

/**
 * 进程内的会合点：Flutter 面板这一侧发请求，沉浸场景那一侧消费。
 *
 * ⚠️ 沉浸场景可能还没 ready（例如 Dart 在 `onSceneReady` 之前就发了请求），
 * 所以这里保留 [pending]，场景就绪时自取。
 */
object ImmersiveBridge {

    /** 沉浸场景就绪后由 ImmersiveActivity 设置；Dart 靠它判断入口要不要露出。 */
    @Volatile
    var isSceneAlive: Boolean = false
        private set

    /**
     * 承载 UI 面板的那个 Flutter 引擎。弱引用：引擎的生死由 MainActivity 负责，
     * 这里只是借用，不该延长它的寿命。
     */
    private var engineRef: WeakReference<FlutterEngine>? = null

    fun attachEngine(engine: FlutterEngine) {
        engineRef = WeakReference(engine)
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
     * 所以「Dart 当大脑」不受影响。
     *
     * ⚠️ 副作用要盯：应用自己的「后台即上锁」逻辑是按 paused 判定真后台的
     * （见记忆 app-lock-pr108-merge）。看视频时被判成进后台，回来可能要求生物识别。
     * 这条必须真机确认。
     */
    fun setPanelRenderingPaused(paused: Boolean) {
        val engine = engineRef?.get() ?: return
        if (paused) engine.lifecycleChannel.appIsPaused() else engine.lifecycleChannel.appIsResumed()
    }

    private var listener: Listener? = null
    private var pending: ImmersiveVideoRequest? = null

    interface Listener {
        fun onPresent(request: ImmersiveVideoRequest)
        fun onDismiss()
    }

    /** 场景就绪。返回时会把等待中的请求补投一次。 */
    fun attachScene(listener: Listener) {
        this.listener = listener
        isSceneAlive = true
        pending?.let {
            pending = null
            listener.onPresent(it)
        }
    }

    fun detachScene() {
        listener = null
        isSceneAlive = false
        pending = null
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
}
