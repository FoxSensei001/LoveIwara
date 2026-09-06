package m.c.g.a.i_iwara.vr

import android.content.Context
import android.net.Uri
import android.util.Log
import android.view.Surface
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

/**
 * 沉浸态的播放器：ExoPlayer 的一层薄壳。
 *
 * 只管「放哪条、放到哪个 Surface、当前状态」，不知道面板与几何。
 * 换形状时幕布实体可能重建，**播放器不跟着死** —— 同一条片子只换 Surface，
 * 缓冲区、解码器、播放位置全程不动（真机验证过的做法，见 `docs/xr-app-layout.md` §17-3）。
 *
 * 沉浸态用 ExoPlayer 而不是 libmpv：mpv 渲不到 Spatial 能绑的 Surface。
 * 代价是 VR 态拿不到 Anime4K / 色觉滤镜 / 字幕。
 */
class PlaybackEngine(private val context: Context) {

    interface Listener {
        fun onBuffering(buffering: Boolean)
        fun onReady()
        fun onEnded()

        /**
         * @param badHttpStatus 服务端回了非 2xx（`ERROR_CODE_IO_BAD_HTTP_STATUS`）。Iwara 直链带 `expires` 签名，
         *   过期后就是这一类（实测是 404 而不是 403）—— Activity 据此向 Dart 要一份新地址而不是直接报错。
         */
        fun onError(message: String, badHttpStatus: Boolean)
        fun onVideoSize(width: Int, height: Int)
    }

    var listener: Listener? = null

    private var player: ExoPlayer? = null

    /** 当前播放器正在放的地址。换形状时靠它判断「这还是同一条片子」。 */
    var playingUrl: String? = null
        private set

    /** 换片时的起播位置（Dart 侧传来的续播点），READY 时消费一次。 */
    private var pendingSeekMs = 0L

    /** 最近一次挂上的 Surface；换源时接着用。 */
    private var surface: Surface? = null

    /** 后台预加载中的下一条（换片时老片继续放，它就绪后再换上来）。 */
    private var preloading: ExoPlayer? = null
    private var preloadUrl: String? = null
    private var preloadListener: Player.Listener? = null

    val isPreloading: Boolean get() = preloading != null

    val isAlive: Boolean get() = player != null
    val isPlaying: Boolean get() = player?.playWhenReady == true
    val positionMs: Long get() = player?.currentPosition ?: 0L
    val durationMs: Long get() = (player?.duration ?: 0L).coerceAtLeast(0L)

    /**
     * 已缓冲到的位置（ms）。ExoPlayer 的 `bufferedPosition` 是**从当前播放点起连续可播**的终点，
     * 不是「一共下了多少」——进度条上要画的正是这一段：越过它就得重新等。本地文件直接是全长。
     */
    val bufferedMs: Long get() = (player?.bufferedPosition ?: 0L).coerceAtLeast(0L)

    /**
     * 把 [url] 放到 [surface] 上。
     *
     * @return true 表示新开了一条片子；false 表示同一条片子只是换了 Surface。
     */
    @OptIn(UnstableApi::class)
    private fun buildPlayer(): ExoPlayer {
        // Iwara 直链靠 query 里的 expires + 签名自证，不需要鉴权头；只留 UA 与超时。
        val httpFactory = DefaultHttpDataSource.Factory()
            .setUserAgent(DEFAULT_UA)
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(15_000)
            .setReadTimeoutMs(15_000)
        // DefaultDataSource 按 scheme 分派：http(s) 交给 httpFactory，file:// / content:// 走本地读取。
        // 不能只给 httpFactory，否则已下载的本地片子在沉浸态里播不了。
        val dataSourceFactory = DefaultDataSource.Factory(context, httpFactory)
        return ExoPlayer.Builder(context)
            .setMediaSourceFactory(DefaultMediaSourceFactory(dataSourceFactory))
            .build()
    }

    /**
     * 后台预加载 [url]：不占 Surface、不出声、不出帧，READY 一次就回 [onReady]。
     * 老片在这期间照常播。再次调用会丢掉上一次的预加载。
     */
    fun preload(url: String, startPositionMs: Long, onReady: () -> Unit, onError: (String) -> Unit) {
        cancelPreload()
        val p = buildPlayer()
        var readyOnce = false
        val l = object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                Log.e(TAG, "IMMERSIVE PRELOAD_ERROR ${error.errorCodeName}: ${error.message}", error)
                if (preloading === p) cancelPreload()
                onError(error.errorCodeName)
            }

            override fun onPlaybackStateChanged(state: Int) {
                if (state == Player.STATE_READY && !readyOnce && preloading === p) {
                    readyOnce = true
                    Log.i(TAG, "IMMERSIVE PRELOAD_READY")
                    onReady()
                }
            }
        }
        p.addListener(l)
        preloading = p
        preloadUrl = url
        preloadListener = l
        p.volume = 0f
        p.playWhenReady = false
        p.setMediaItem(MediaItem.fromUri(Uri.parse(url)), startPositionMs.coerceAtLeast(0L))
        p.prepare()
    }

    fun cancelPreload() {
        preloading?.let { p ->
            preloadListener?.let { p.removeListener(it) }
            p.release()
        }
        preloading = null
        preloadUrl = null
        preloadListener = null
    }

    /**
     * 把预加载好的那条换上来：老播放器释放，新的接管 Surface、音量、倍速、循环并开播。
     * @return 新片的画面尺寸（宽 × 高），拿不到为 null。
     */
    fun commitPreloaded(muted: Boolean, volume: Float, speed: Float, repeatOne: Boolean): Pair<Int, Int>? {
        val p = preloading ?: return null
        val url = preloadUrl
        preloadListener?.let { p.removeListener(it) }
        preloading = null
        preloadUrl = null
        preloadListener = null
        player?.release()
        player = p
        playingUrl = url
        pendingSeekMs = 0L
        p.addListener(mainListener(p))
        p.volume = if (muted) 0f else volume
        p.setPlaybackSpeed(speed)
        p.repeatMode = if (repeatOne) Player.REPEAT_MODE_ONE else Player.REPEAT_MODE_OFF
        surface?.let { p.setVideoSurface(it) }
        p.playWhenReady = true
        val size = p.videoSize
        return if (size.width > 0 && size.height > 0) size.width to size.height else null
    }

    /**
     * 把 [url] 放到 [surface] 上。
     *
     * @return true 表示新开了一条片子；false 表示同一条片子只是换了 Surface。
     */
    fun play(url: String, surface: Surface, startPositionMs: Long, muted: Boolean, volume: Float): Boolean {
        val running = player
        if (running != null && playingUrl == url) {
            Log.i(TAG, "IMMERSIVE 复用播放器，只换 surface")
            this.surface = surface
            running.setVideoSurface(surface)
            return false
        }
        release()

        val p = buildPlayer()
        p.addListener(mainListener(p))
        return startWith(p, url, surface, startPositionMs, muted, volume)
    }

    /** 正式播放那条的监听：缓冲 / 就绪 / 播完 / 尺寸都往 Activity 报。 */
    private fun mainListener(p: ExoPlayer): Player.Listener =
        object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                Log.e(TAG, "IMMERSIVE PLAYBACK_ERROR ${error.errorCodeName}: ${error.message}", error)
                listener?.onBuffering(false)
                listener?.onError(
                    error.errorCodeName,
                    badHttpStatus = error.errorCode == PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS,
                )
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
                listener?.onBuffering(state == Player.STATE_BUFFERING)
                if (state == Player.STATE_READY) {
                    if (pendingSeekMs > 0) {
                        p.seekTo(pendingSeekMs)
                        pendingSeekMs = 0
                    }
                    listener?.onReady()
                }
                if (state == Player.STATE_ENDED) listener?.onEnded()
            }

            override fun onVideoSizeChanged(videoSize: VideoSize) {
                Log.i(TAG, "IMMERSIVE VIDEO_SIZE ${videoSize.width}x${videoSize.height}")
                if (videoSize.width > 0 && videoSize.height > 0) {
                    listener?.onVideoSize(videoSize.width, videoSize.height)
                }
            }
        }

    private fun startWith(p: ExoPlayer, url: String, surface: Surface, startPositionMs: Long, muted: Boolean, volume: Float): Boolean {
        player = p
        playingUrl = url
        this.surface = surface
        pendingSeekMs = startPositionMs
        p.volume = if (muted) 0f else volume
        p.setVideoSurface(surface)
        p.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
        p.prepare()
        p.playWhenReady = true
        return true
    }

    /** 幕布实体要销毁了：先摘 Surface，否则播放器会往已释放的缓冲上画。 */
    fun detachSurface() {
        player?.setVideoSurface(null)
    }

    fun attachSurface(surface: Surface) {
        this.surface = surface
        player?.setVideoSurface(surface)
    }

    /**
     * 同一条片子换一档清晰度 / 换一份新签名的地址：接着当前位置、沿用 Surface 与播放/暂停状态，幕布不重建。
     * 播放器出错停在 IDLE 时也能用（ExoPlayer 出错后保留位置与 playWhenReady），这就是过期地址的恢复路径。
     * @return false = 没有 Surface（还没起播）或地址没变。
     */
    fun swapSource(url: String, muted: Boolean, volume: Float): Boolean {
        val s = surface ?: return false
        if (url == playingUrl) return false
        val pos = positionMs
        val wasPlaying = isPlaying
        val speed = player?.playbackParameters?.speed ?: 1f
        val repeat = player?.repeatMode ?: Player.REPEAT_MODE_OFF
        val started = play(url, s, pos, muted, volume)
        if (started) {
            player?.playWhenReady = wasPlaying
            player?.setPlaybackSpeed(speed)
            player?.repeatMode = repeat
        }
        return started
    }

    /**
     * 空间画廊里从一条短片换到另一条：从头起播、沿用 Surface（同一个幕布实体），倍速不沿用。
     * @return false = 还没有 Surface（幕布还没建出来，走正常的 startPlayback 路径）。
     */
    fun restart(url: String, muted: Boolean, volume: Float, repeatOne: Boolean): Boolean {
        val s = surface ?: return false
        val started = play(url, s, 0L, muted, volume)
        if (!started) {
            player?.seekTo(0L)
            player?.playWhenReady = true
        }
        setRepeatOne(repeatOne)
        return true
    }

    fun setPlaying(playing: Boolean) {
        player?.playWhenReady = playing
    }

    fun togglePlaying(): Boolean {
        val p = player ?: return false
        p.playWhenReady = !p.playWhenReady
        return p.playWhenReady
    }

    fun seekTo(ms: Long) {
        val p = player ?: return
        val dur = p.duration
        p.seekTo(if (dur > 0) ms.coerceIn(0L, dur) else ms.coerceAtLeast(0L))
    }

    fun seekBy(deltaMs: Long) = seekTo(positionMs + deltaMs)

    fun setSpeed(speed: Float) {
        player?.setPlaybackSpeed(speed)
    }

    fun setVolume(volume: Float) {
        player?.volume = volume.coerceIn(0f, 1f)
    }

    fun setRepeatOne(repeatOne: Boolean) {
        player?.repeatMode = if (repeatOne) Player.REPEAT_MODE_ONE else Player.REPEAT_MODE_OFF
    }

    fun release() {
        cancelPreload()
        player?.release()
        player = null
        playingUrl = null
        pendingSeekMs = 0
    }

    companion object {
        private const val TAG = ImmersiveActivity.TAG
        private const val DEFAULT_UA =
            "Mozilla/5.0 (Linux; Android 14; Quest 3) AppleWebKit/537.36 " +
                "Chrome/126.0.0.0 Safari/537.36"
    }
}
