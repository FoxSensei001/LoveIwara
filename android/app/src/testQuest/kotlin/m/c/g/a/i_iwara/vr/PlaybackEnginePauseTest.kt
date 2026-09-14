package m.c.g.a.i_iwara.vr

import android.content.ContextWrapper
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import java.lang.reflect.Proxy
import org.junit.Assert.*
import org.junit.Test

class PlaybackEnginePauseTest {
    private class Fixture {
        var playing = false
        var state = Player.STATE_READY
        val engine = PlaybackEngine(ContextWrapper(null))
        init {
            val player = Proxy.newProxyInstance(ExoPlayer::class.java.classLoader,
                arrayOf(ExoPlayer::class.java)) { _, method, args ->
                when (method.name) {
                    "setPlayWhenReady" -> { playing = args!![0] as Boolean; null }
                    "getPlayWhenReady" -> playing
                    "getPlaybackState" -> state
                    "seekTo", "release" -> null
                    else -> error("Unexpected player call: ${method.name}")
                }
            }
            PlaybackEngine::class.java.getDeclaredField("player").apply { isAccessible = true }.set(engine, player)
        }
    }

    @Test fun nestedSystemPausesPreservePlayIntent() {
        val f = Fixture()
        f.engine.setPlaying(true)
        f.engine.setSystemPaused(true)
        f.engine.setSystemPaused(true)
        assertFalse(f.playing)
        f.engine.setSystemPaused(false)
        assertTrue(f.playing)
    }

    @Test fun userPauseIsNotUndoneBySystemResume() {
        val f = Fixture()
        f.engine.setPlaying(true)
        f.engine.togglePlaying()
        f.engine.setSystemPaused(true)
        f.engine.setSystemPaused(false)
        assertFalse(f.playing)
    }

    @Test fun aLatePlaybackRequestWaitsUntilTheSystemResumes() {
        val f = Fixture()
        f.engine.setSystemPaused(true)
        f.engine.setPlaying(true)
        assertFalse(f.playing)
        f.engine.setSystemPaused(false)
        assertTrue(f.playing)
    }
}
