package m.c.g.a.i_iwara.xr

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import m.c.g.a.i_iwara.questui.PanelLocale

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
 * - `present` → `{url, title, author, videoId, shape: flat|180|360, stereo: none|lr|tb, fullFrame,
 *                w, h, positionMs, unsupportedProjection,
 *                sources: [{label, url, local}], sourceLabel}`
 * - `dismiss` → 收起幕布，只留 UI 面板（视频与空间画廊都归它）
 * - `presentGallery` → `{galleryId, title, author, index, quality,
 *                        items: [{id, video, url, thumbUrl, thumbPath, w, h}]}`：整本图库空间化呈现
 * - `updateSources` → `{videoId, sources: [{label, url, local}]}`：同一条片子的清晰度清单换了一份新地址
 *   （Iwara 直链带 `expires`，Dart 侧到期前 5 分钟刷一次 / 原生报过期时刷一次）；正在放的那一档地址变了
 *   就接着当前位置无缝换过去
 * - `abortSwitch` → `{videoId, reason}`：面板点了下一条、Dart 却打不开那张详情页（跨站切换失败 / 私密 / 删除）：
 *   让原生收掉换片在途态、把老片放回去并提示
 * - `setPlaylist` → `{sections: [{queueId, title, hasMore, loading,
 *                    items: [{id,title,author,durationText,thumbnailUrl,progress,watched,playable,downloaded}]}],
 *                    groups: [{id, title, subtitle, loading, choices: [{queueId, title, count}]}],
 *                    activeQueueId, nowPlayingId}`
 *
 * Kotlin → Dart（同一条通道）：
 * - `requestPlaylist` `{force}` → 让 Dart 重新推一次「接着看」（force = 清单也重拉）
 * - `openQueue` `{queueId}` → 目录里还没开的池：让 Dart 开出来、装第一页、整套推回来
 * - `loadMore` `{queueId}` → 让那个池翻一页，再整套推回来（面板里的无限滚动）
 * - `sourcePicked` `{label}` → 面板上换了清晰度，记成全局偏好（与 2D 底栏同一落点）
 * - `playItem` `{queueId, id}` → 让 Dart 把详情页换成那条视频，新页再 `present` 回来
 * - `immersiveEnded` `{videoId, positionMs, durationMs}` → 沉浸播放结束（返回应用 / 换片 / 退出场景），
 *   把最后的播放位置交还给 Dart 回写观看历史与页面里的播放器
 * - `sourceExpired` `{videoId}` → 播放地址被服务端拒了（非 2xx）：请 Dart 立刻重取一份清单再 `updateSources` 回来
 * - 空间画廊四条：`galleryFile` `{id, quality}` → **有返回值**（本地文件路径，空串 = 失败）；
 *   `galleryIndexChanged` `{galleryId, index}`；`galleryQualityPicked` `{quality}`；`galleryEnded` `{galleryId, index}`
 *
 * ⛔ **反向调用就这几条，刻意保持得很窄**。设计文档 §6.6 已经否掉了「沉浸端持续
 * 回打 Dart 的瘦客户端架构」（跨端持续同步最脆，LMK 一杀会话中途崩），
 * 这里是「原生自足 + 偶尔向 Dart 要一次数据」。
 *
 * 另有两条**不走通道**的：手柄 B/Y 在浏览态 = 系统返回键，直接派给 [MainActivity] 的
 * `OnBackPressedDispatcher`（见 [ImmersiveBridge.requestBack]）；MainActivity 自己 finish 时
 * （根级退出）沉浸 Activity 跟着 finish（见 [ImmersiveBridge.notifyHostFinished]）。
 */
object XrBridge {

    private const val CHANNEL = "i_iwara/immersive"
    private const val TAG = "IwaraVR"

    fun attach(activity: Activity, engine: FlutterEngine) {
        ImmersiveBridge.attachEngine(engine)
        ImmersiveBridge.attachActivity(activity)
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        ImmersiveBridge.attachChannel(channel)
        // 面板里的 MainActivity 自己 finish（根级「再按一次退出」→ SystemNavigator.pop）时，沉浸 Activity 要跟着退：
        // 否则场景还活着、面板却空了，用户「一直按 B 也退不出应用」。只认 isFinishing，配置变化重建不算。
        (activity as? androidx.activity.ComponentActivity)?.lifecycle?.addObserver(
            androidx.lifecycle.LifecycleEventObserver { _, event ->
                if (event == androidx.lifecycle.Lifecycle.Event.ON_DESTROY && activity.isFinishing) {
                    Log.i(TAG, "XR host MainActivity finishing")
                    ImmersiveBridge.notifyHostFinished()
                }
            },
        )
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(ImmersiveBridge.isSceneAlive)

                // A confirmed app exit must end the scene. SystemNavigator.pop can merely
                // background the embedded Activity, so ON_DESTROY is not an exit signal.
                "exitApp" -> result.success(ImmersiveBridge.requestAppExit())

                // 应用内选定的界面语言。⛔ 空间面板不跟系统语言走，见 PanelLocale。
                "setLocale" -> {
                    PanelLocale.tag = call.argument<String>("locale").orEmpty()
                    Log.i(TAG, "XR locale -> ${PanelLocale.tag}")
                    result.success(true)
                }

                "present" -> {
                    // 面板可能在语言切换之后才第一次被唤出，每次 present 都带上是最省事的兜底。
                    call.argument<String>("locale")?.let { PanelLocale.tag = it }
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("bad_args", "url 不能为空", null)
                    } else {
                        val request = ImmersiveVideoRequest(
                            url = url,
                            title = call.argument<String>("title") ?: "",
                            author = call.argument<String>("author") ?: "",
                            videoId = call.argument<String>("videoId") ?: "",
                            shape = call.argument<String>("shape") ?: "flat",
                            stereo = call.argument<String>("stereo") ?: "none",
                            fullFrame = call.argument<Boolean>("fullFrame") ?: false,
                            width = call.argument<Int>("w") ?: 0,
                            height = call.argument<Int>("h") ?: 0,
                            positionMs = (call.argument<Number>("positionMs") ?: 0).toLong(),
                            unsupportedProjection =
                                call.argument<Boolean>("unsupportedProjection") ?: false,
                            sources = call.argument<List<Map<String, Any?>>>("sources").orEmpty().map { row ->
                                ImmersiveSourceOption(
                                    label = row["label"] as? String ?: "",
                                    url = row["url"] as? String ?: "",
                                    local = row["local"] as? Boolean ?: false,
                                    display = row["displayLabel"] as? String
                                        ?: row["label"] as? String ?: "",
                                )
                            }.filter { it.label.isNotEmpty() && it.url.isNotEmpty() },
                            sourceLabel = call.argument<String>("sourceLabel") ?: "",
                        )
                        Log.i(TAG, "XR present shape=${request.shape} stereo=${request.stereo}")
                        result.success(ImmersiveBridge.present(request))
                    }
                }

                "dismiss" -> result.success(ImmersiveBridge.dismiss())

                // 整本图库交给沉浸空间（空间画廊）。文件本体不在这包里：原生按需 `galleryFile` 回来要本地路径。
                "presentGallery" -> {
                    call.argument<String>("locale")?.let { PanelLocale.tag = it }
                    val rawItems = call.argument<List<Map<String, Any?>>>("items").orEmpty()
                    val items = rawItems.map { row ->
                        ImmersiveGalleryItem(
                            id = row["id"] as? String ?: "",
                            isVideo = row["video"] as? Boolean ?: false,
                            url = row["url"] as? String ?: "",
                            thumbUrl = row["thumbUrl"] as? String ?: "",
                            thumbPath = row["thumbPath"] as? String ?: "",
                            width = (row["w"] as? Number)?.toInt() ?: 0,
                            height = (row["h"] as? Number)?.toInt() ?: 0,
                        )
                    }.filter { it.id.isNotEmpty() }
                    if (items.isEmpty()) {
                        result.error("bad_args", "items 不能为空", null)
                    } else {
                        val request = ImmersiveGalleryRequest(
                            galleryId = call.argument<String>("galleryId") ?: "",
                            title = call.argument<String>("title") ?: "",
                            author = call.argument<String>("author") ?: "",
                            index = (call.argument<Number>("index") ?: 0).toInt().coerceIn(0, items.size - 1),
                            quality = call.argument<String>("quality") ?: "standard",
                            items = items,
                        )
                        Log.i(TAG, "XR presentGallery id=${request.galleryId} n=${items.size} index=${request.index}")
                        result.success(ImmersiveBridge.presentGallery(request))
                    }
                }

                "abortSwitch" -> {
                    result.success(
                        ImmersiveBridge.abortSwitch(
                            videoId = call.argument<String>("videoId") ?: "",
                            reason = call.argument<String>("reason") ?: "",
                        ),
                    )
                }

                "updateSources" -> {
                    val videoId = call.argument<String>("videoId") ?: ""
                    val sources = call.argument<List<Map<String, Any?>>>("sources").orEmpty().map { row ->
                        ImmersiveSourceOption(
                            label = row["label"] as? String ?: "",
                            url = row["url"] as? String ?: "",
                            local = row["local"] as? Boolean ?: false,
                            display = row["displayLabel"] as? String
                                ?: row["label"] as? String ?: "",
                        )
                    }.filter { it.label.isNotEmpty() && it.url.isNotEmpty() }
                    result.success(ImmersiveBridge.updateSources(videoId, sources))
                }

                "setPlaylist" -> {
                    val rawSections = call.argument<List<Map<String, Any?>>>("sections").orEmpty()
                    val sections = rawSections.map { sec ->
                        val raw = sec["items"] as? List<*> ?: emptyList<Any?>()
                        ImmersivePlaylistSection(
                            queueId = sec["queueId"] as? String ?: "",
                            title = sec["title"] as? String ?: "",
                            hasMore = sec["hasMore"] as? Boolean ?: false,
                            loading = sec["loading"] as? Boolean ?: false,
                            items = raw.mapNotNull { it as? Map<*, *> }.map { row ->
                                ImmersivePlaylistItem(
                                    id = row["id"] as? String ?: "",
                                    title = row["title"] as? String ?: "",
                                    author = row["author"] as? String ?: "",
                                    durationText = row["durationText"] as? String ?: "",
                                    thumbnailUrl = row["thumbnailUrl"] as? String ?: "",
                                    progress = (row["progress"] as? Number)?.toFloat() ?: 0f,
                                    watched = row["watched"] as? Boolean ?: false,
                                    playable = row["playable"] as? Boolean ?: true,
                                    downloaded = row["downloaded"] as? Boolean ?: false,
                                )
                            }.filter { it.id.isNotEmpty() },
                        )
                    }.filter { it.queueId.isNotEmpty() }
                    val rawGroups = call.argument<List<Map<String, Any?>>>("groups").orEmpty()
                    val groups = rawGroups.map { g ->
                        val raw = g["choices"] as? List<*> ?: emptyList<Any?>()
                        ImmersivePlaylistGroup(
                            id = g["id"] as? String ?: "",
                            title = g["title"] as? String ?: "",
                            subtitle = g["subtitle"] as? String ?: "",
                            loading = g["loading"] as? Boolean ?: false,
                            choices = raw.mapNotNull { it as? Map<*, *> }.map { c ->
                                ImmersivePlaylistChoice(
                                    queueId = c["queueId"] as? String ?: "",
                                    title = c["title"] as? String ?: "",
                                    count = (c["count"] as? Number)?.toInt() ?: -1,
                                )
                            }.filter { it.queueId.isNotEmpty() },
                        )
                    }.filter { it.id.isNotEmpty() }
                    ImmersiveBridge.setPlaylist(
                        sections,
                        groups,
                        activeQueueId = call.argument<String>("activeQueueId"),
                        nowPlayingId = call.argument<String>("nowPlayingId"),
                    )
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
    /** 作者名；本地文件 / 外部地址可为空串。面板标题下面那行小字。 */
    val author: String,
    /** 应用内的视频 id；本地文件/外部地址可为空串。回写进度时靠它。 */
    val videoId: String,
    val shape: String,
    val stereo: String,
    /** 立体片每只眼占一整幅（FSBS / FOU）。默认半幅（HSBS / HOU）。 */
    val fullFrame: Boolean,
    val width: Int,
    val height: Int,
    val positionMs: Long,
    /** 片源投影 SDK 渲染不了（目前只有鱼眼）。面板据此如实提示并给外部播放器出口。 */
    val unsupportedProjection: Boolean,
    /** 可选清晰度（在线 / 本地文件）。空 = 只有 [url] 这一档。 */
    val sources: List<ImmersiveSourceOption> = emptyList(),
    /** [url] 对应的那一档的标签。 */
    val sourceLabel: String = "",
)

/**
 * 一档清晰度。
 *
 * ⛔ [label] 是**身份**（`Source` / `1080`……）：原样回传 Dart 存偏好、面板也靠它匹配当前档，
 * 不能本地化。要显示的是 [display] —— Dart 按应用内语言算好推过来的（与 2D 播放器底栏
 * 同一套 `getQualityDisplayLabel`）。
 */
data class ImmersiveSourceOption(
    val label: String,
    val url: String,
    val local: Boolean,
    val display: String = label,
)

/** 「接着看」里的一条，字段与 Dart 的 `XrPlaylistEntry` 一一对应。 */
data class ImmersivePlaylistItem(
    val id: String,
    val title: String,
    val author: String,
    val durationText: String,
    val thumbnailUrl: String,
    val progress: Float,
    val watched: Boolean,
    val playable: Boolean,
    val downloaded: Boolean,
)

/** 「接着看」来源目录的一个分组（= 2D 抽屉第一级）。 */
data class ImmersivePlaylistGroup(
    val id: String,
    val title: String,
    val subtitle: String,
    val loading: Boolean,
    val choices: List<ImmersivePlaylistChoice>,
)

/** 分组里的一个选项（= 抽屉第二级），对应一个池；count < 0 表示没有计数。 */
data class ImmersivePlaylistChoice(val queueId: String, val title: String, val count: Int)

/** 「接着看」的一个分区 = 详情页的一个视频池。 */
data class ImmersivePlaylistSection(
    val queueId: String,
    val title: String,
    val hasMore: Boolean,
    val items: List<ImmersivePlaylistItem>,
    /** 池正在拉第一页 / 翻页（或还没装过任何一页）。 */
    val loading: Boolean = false,
)

/** 空间画廊里的一项（与 Dart 的 `XrGalleryItem` 一一对应）。[url] 是当前画质档的地址，只作日志 / 兜底。 */
data class ImmersiveGalleryItem(
    val id: String,
    val isVideo: Boolean,
    val url: String,
    val thumbUrl: String,
    /** Dart 手里已有缓存的缩略图文件；空串 = 没有。 */
    val thumbPath: String,
    val width: Int,
    val height: Int,
)

/** 一次「把整本图库空间化呈现」的请求。 */
data class ImmersiveGalleryRequest(
    val galleryId: String,
    val title: String,
    val author: String,
    val index: Int,
    /** `standard` / `original`（Dart 的大图页画质偏好）。 */
    val quality: String,
    val items: List<ImmersiveGalleryItem>,
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

    /** 面板里那个承载 Flutter 的 Activity；手柄「返回」要派给它。弱引用，理由同 [engineRef]。 */
    private var activityRef: WeakReference<Activity>? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    fun attachEngine(engine: FlutterEngine) {
        engineRef = WeakReference(engine)
    }

    fun attachActivity(activity: Activity) {
        activityRef = WeakReference(activity)
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
    private var pendingPlaylist: PendingPlaylist? = null

    private class PendingPlaylist(
        val sections: List<ImmersivePlaylistSection>,
        val groups: List<ImmersivePlaylistGroup>,
        val activeQueueId: String?,
        val nowPlayingId: String?,
    )

    /** 场景还没就绪时先攒着的图库。 */
    private var pendingGallery: ImmersiveGalleryRequest? = null

    interface Listener {
        fun onPresent(request: ImmersiveVideoRequest)

        /** 整本图库交给沉浸空间（空间画廊）。 */
        fun onPresentGallery(request: ImmersiveGalleryRequest)
        fun onDismiss()

        /** 同一条片子（[videoId]）的清晰度清单换了新地址。不是正在放的那条就忽略。 */
        fun onSources(videoId: String, sources: List<ImmersiveSourceOption>)

        /** 面板里的 MainActivity 正在 finish（应用级退出）：沉浸场景也该退。 */
        fun onHostFinished()

        /** Dart 打不开面板点的那条视频：收掉换片在途态。[videoId] 为空 = 收掉任何在途换片。 */
        fun onAbortSwitch(videoId: String, reason: String)
        fun onPlaylist(
            sections: List<ImmersivePlaylistSection>,
            groups: List<ImmersivePlaylistGroup>,
            activeQueueId: String?,
            nowPlayingId: String?,
        )
    }

    /** 场景就绪。返回时会把等待中的请求补投一次。 */
    fun attachScene(listener: Listener) {
        this.listener = listener
        isSceneAlive = true
        pendingPlaylist?.let {
            pendingPlaylist = null
            listener.onPlaylist(it.sections, it.groups, it.activeQueueId, it.nowPlayingId)
        }
        pending?.let {
            pending = null
            listener.onPresent(it)
        }
        pendingGallery?.let {
            pendingGallery = null
            listener.onPresentGallery(it)
        }
    }

    fun detachScene() {
        listener = null
        isSceneAlive = false
        pending = null
        pendingGallery = null
        pendingPlaylist = null
    }

    /** @return true 表示已直接投递给场景；false 表示场景未就绪、已暂存。 */
    fun presentGallery(request: ImmersiveGalleryRequest): Boolean {
        pending = null
        val target = listener
        return if (target == null) {
            pendingGallery = request
            false
        } else {
            target.onPresentGallery(request)
            true
        }
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
        pendingGallery = null
        val target = listener ?: return false
        target.onDismiss()
        return true
    }

    /** Dart 打不开面板点的那条：让场景把换片在途态收掉。@return false = 场景没活着。 */
    fun abortSwitch(videoId: String, reason: String): Boolean {
        val target = listener ?: return false
        target.onAbortSwitch(videoId, reason)
        return true
    }

    /** 面板里的 MainActivity 正在 finish：让场景一起退。场景没活着就没事可做。 */
    fun notifyHostFinished() {
        listener?.onHostFinished()
    }

    /** Acknowledge the request before tearing down the scene and its ActivityPanel. */
    fun requestAppExit(): Boolean {
        val target = listener ?: return false
        mainHandler.post {
            if (listener === target) target.onHostFinished()
        }
        return true
    }

    /** @return false = 场景没活着（没有可更新的播放器）。不暂存：新地址只对正在放的那条有意义。 */
    fun updateSources(videoId: String, sources: List<ImmersiveSourceOption>): Boolean {
        val target = listener ?: return false
        target.onSources(videoId, sources)
        return true
    }

    fun setPlaylist(
        sections: List<ImmersivePlaylistSection>,
        groups: List<ImmersivePlaylistGroup>,
        activeQueueId: String?,
        nowPlayingId: String?,
    ) {
        val target = listener
        if (target == null) {
            pendingPlaylist = PendingPlaylist(sections, groups, activeQueueId, nowPlayingId)
        } else {
            target.onPlaylist(sections, groups, activeQueueId, nowPlayingId)
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
    fun requestPlaylist(force: Boolean = false) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("requestPlaylist", mapOf("force" to force)) }
    }

    /** 面板上换了清晰度：记成全局偏好，下一条按它匹配 / 向下降级。 */
    fun notifySourcePicked(label: String) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("sourcePicked", mapOf("label" to label)) }
    }

    /** 目录里还没开的池：请 Dart 开出来、装第一页、整套推回来。 */
    fun requestOpenQueue(queueId: String) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("openQueue", mapOf("queueId" to queueId)) }
    }

    /**
     * 请 Dart 给 [queueId] 这个池翻一页，翻完它会整套 `setPlaylist` 推回来。
     */
    fun requestLoadMore(queueId: String) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("loadMore", mapOf("queueId" to queueId)) }
    }

    /**
     * 手柄 B/Y 在浏览态 = **系统返回键**。
     *
     * # 为什么要我们自己派
     *
     * Flutter 面板是挂在本沉浸 Activity 里的 `ActivityPanel`，手柄按键由 Spatial SDK 收走，
     * **不会**像普通 2D 应用那样变成 `KEYCODE_BACK` 落到面板里的 Activity —— 用户 2026-09-05：
     * 「在应用内按 B 键没有回到上一页，非常反直觉」。
     *
     * 派给 `OnBackPressedDispatcher` 而不是直接调 Dart 的 pop：这正是硬件返回键走的那条路
     * （FlutterActivity 的返回回调 → `navigationChannel.popRoute` → go_router），应用里的
     * 「再按一次退出」等根级处理原样生效，不用在 Dart 侧再造一条。
     */
    fun requestBack() {
        val activity = activityRef?.get()
        if (activity == null || activity.isFinishing || activity.isDestroyed) {
            Log.w(TAG, "XR requestBack 但 MainActivity 已不在")
            return
        }
        mainHandler.post {
            // FlutterFragmentActivity 一定是 ComponentActivity；派给它的分发器 = 硬件返回键那条路。
            val dispatcher = (activity as? androidx.activity.ComponentActivity)?.onBackPressedDispatcher
            if (dispatcher == null) {
                Log.w(TAG, "XR requestBack：MainActivity 不是 ComponentActivity")
                return@post
            }
            runCatching { dispatcher.onBackPressed() }
                .onFailure { Log.w(TAG, "XR requestBack 失败", it) }
        }
    }

    /**
     * 播放地址被服务端拒了（多半是 `expires` 到期）：请 Dart 立刻重取清单、`updateSources` 回来。
     * Dart 侧同一条片子在途只会有一次刷新，这里不做去抖。
     */
    fun requestSourceRefresh(videoId: String) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("sourceExpired", mapOf("videoId" to videoId)) }
    }

    /**
     * 沉浸播放结束：把最后位置交还给 Dart。
     *
     * 幕布上的进度从不经过 `MyVideoStateController`，所以观看历史 / 稍后再看的进度
     * 只能在这一刻一次性回写（设计文档 §6.6-4 的决定）。
     */
    fun notifyImmersiveEnded(videoId: String, positionMs: Long, durationMs: Long) {
        val channel = channelRef?.get() ?: return
        mainHandler.post {
            channel.invokeMethod(
                "immersiveEnded",
                mapOf("videoId" to videoId, "positionMs" to positionMs, "durationMs" to durationMs),
            )
        }
    }

    // ---------------------------------------------------------------- 空间画廊的反向调用

    /**
     * 请 Dart 把图库里 [id] 这个文件按 [quality] 档下载到本机缓存，把**本地路径**交回来（空串 = 失败）。
     *
     * 为什么不让原生自己下：Dart 那条 HTTP 走应用内代理（`HttpOverrides.global`）、也带着自己的
     * 图片缓存；原生 Coil / OkHttp 两样都没有。文件到手之后原生只负责解码。
     */
    fun requestGalleryFile(id: String, quality: String, onResult: (String) -> Unit) {
        val channel = channelRef?.get()
        if (channel == null) {
            onResult("")
            return
        }
        mainHandler.post {
            channel.invokeMethod(
                "galleryFile",
                mapOf("id" to id, "quality" to quality),
                object : MethodChannel.Result {
                    override fun success(result: Any?) = onResult((result as? String).orEmpty())
                    override fun error(code: String, message: String?, details: Any?) {
                        Log.w(TAG, "XR galleryFile failed id=$id code=$code msg=$message")
                        onResult("")
                    }
                    override fun notImplemented() = onResult("")
                },
            )
        }
    }

    /** 幕布翻到了第 [index] 项：让 2D 面板里的横向清单跟过去（回应用时落在刚看的那张）。 */
    fun notifyGalleryIndex(galleryId: String, index: Int) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("galleryIndexChanged", mapOf("galleryId" to galleryId, "index" to index)) }
    }

    /** 面板上换了图片画质：记成全局偏好（与 2D 大图页同一落点）。 */
    fun notifyGalleryQuality(quality: String) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("galleryQualityPicked", mapOf("quality" to quality)) }
    }

    /** 空间画廊结束（回应用 / 被视频顶掉 / 退出场景）。 */
    fun notifyGalleryEnded(galleryId: String, index: Int) {
        val channel = channelRef?.get() ?: return
        mainHandler.post { channel.invokeMethod("galleryEnded", mapOf("galleryId" to galleryId, "index" to index)) }
    }

    /**
     * 请 Dart 播放 [queueId] 池里的 [id]：Dart 会把详情页换成那条视频，新页把片源 present 回来。
     *
     * ⛔ 换页要 Flutter 出帧（build 新页面、起播放器），所以这里**先把面板的出帧恢复**；
     * 新页 present 到场景后，沉浸 Activity 会在 rebuildScreen 里再把它停掉。
     */
    fun requestPlayItem(queueId: String, id: String) {
        val channel = channelRef?.get()
        if (channel == null) {
            Log.w(TAG, "XR requestPlayItem 但通道已不在 id=$id")
            return
        }
        setPanelRenderingPaused(false)
        mainHandler.post { channel.invokeMethod("playItem", mapOf("queueId" to queueId, "id" to id)) }
    }
}
