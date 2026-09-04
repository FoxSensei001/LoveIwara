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
        fun onError(message: String)
        fun onVideoSize(width: Int, height: Int)
    }

    var listener: Listener? = null

    private var player: ExoPlayer? = null

    /** 当前播放器正在放的地址。换形状时靠它判断「这还是同一条片子」。 */
    var playingUrl: String? = null
        private set

    /** 换片时的起播位置（Dart 侧传来的续播点），READY 时消费一次。 */
    private var pendingSeekMs = 0L

    val isAlive: Boolean get() = player != null
    val isPlaying: Boolean get() = player?.playWhenReady == true
    val positionMs: Long get() = player?.currentPosition ?: 0L
    val durationMs: Long get() = (player?.duration ?: 0L).coerceAtLeast(0L)

    /**
     * 把 [url] 放到 [surface] 上。
     *
     * @return true 表示新开了一条片子；false 表示同一条片子只是换了 Surface。
     */
    @OptIn(UnstableApi::class)
    fun play(url: String, surface: Surface, startPositionMs: Long, muted: Boolean, volume: Float): Boolean {
        val running = player
        if (running != null && playingUrl == url) {
            Log.i(TAG, "IMMERSIVE 复用播放器，只换 surface")
            running.setVideoSurface(surface)
            return false
        }
        release()

        // Iwara 直链靠 query 里的 expires + 签名自证，不需要鉴权头；只留 UA 与超时。
        val httpFactory = DefaultHttpDataSource.Factory()
            .setUserAgent(DEFAULT_UA)
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(15_000)
            .setReadTimeoutMs(15_000)
        // DefaultDataSource 按 scheme 分派：http(s) 交给 httpFactory，file:// / content:// 走本地读取。
        // 不能只给 httpFactory，否则已下载的本地片子在沉浸态里播不了。
        val dataSourceFactory = DefaultDataSource.Factory(context, httpFactory)

        val p = ExoPlayer.Builder(context)
            .setMediaSourceFactory(DefaultMediaSourceFactory(dataSourceFactory))
            .build()
        p.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                Log.e(TAG, "IMMERSIVE PLAYBACK_ERROR ${error.errorCodeName}: ${error.message}", error)
                listener?.onBuffering(false)
                listener?.onError(error.errorCodeName)
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
        })

        player = p
        playingUrl = url
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
        player?.setVideoSurface(surface)
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
