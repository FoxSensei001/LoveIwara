package m.c.g.a.i_iwara.vr

import android.content.Context
import m.c.g.a.i_iwara.questui.AspectPreset
import m.c.g.a.i_iwara.questui.RepeatMode
import m.c.g.a.i_iwara.questui.SceneKind
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsState

/**
 * 沉浸播放器的用户偏好：屏幕类型、场景、几何、倍速、面板行为……
 *
 * 全部落 SharedPreferences，跨会话记住。**视频类型（格式）刻意不记**：那是每条片子
 * 自己的属性，由 Dart 侧的判定 + 用户覆盖决定，跨片记忆只会放错。
 */
class PlayerPrefs(context: Context) {

    private val sp = context.getSharedPreferences("xr_player_v2", Context.MODE_PRIVATE)

    fun load(state: VideoControlsState) {
        state.curve = enum(KEY_CURVE, ScreenCurve.SLIGHT)
        state.scene = enum(KEY_SCENE, SceneKind.VOID)
        state.screenDistance = sp.getFloat(KEY_DISTANCE, 2.4f)
        state.screenOffset = sp.getFloat(KEY_OFFSET, 0f)
        state.screenWidth = sp.getFloat(KEY_WIDTH, 3.2f)
        state.aspectPreset = enum(KEY_ASPECT, AspectPreset.DEFAULT)
        state.widthRatio = sp.getFloat(KEY_WIDTH_RATIO, 1f)
        state.heightRatio = sp.getFloat(KEY_HEIGHT_RATIO, 1f)
        state.speed = sp.getFloat(KEY_SPEED, 1f)
        state.volume = sp.getFloat(KEY_VOLUME, 1f)
        state.forceMono = sp.getBoolean(KEY_FORCE_MONO, false)
        state.treat180AsFisheye = sp.getBoolean(KEY_TREAT_180_FISHEYE, false)
        state.repeatMode = enum(KEY_REPEAT, RepeatMode.ONE)
        state.autoHide = sp.getBoolean(KEY_AUTO_HIDE, true)
        state.autoHideSeconds = sp.getInt(KEY_AUTO_HIDE_SECONDS, 12)
        state.clickSound = sp.getBoolean(KEY_CLICK_SOUND, true)
        state.summonInFront = sp.getBoolean(KEY_SUMMON_IN_FRONT, true)
        state.controllerTapPlayPause = sp.getBoolean(KEY_CONTROLLER_TAP, true)
        state.pauseOnFocusLoss = sp.getBoolean(KEY_PAUSE_ON_FOCUS_LOSS, true)
    }

    fun save(state: VideoControlsState) {
        sp.edit()
            .putString(KEY_CURVE, state.curve.name)
            .putString(KEY_SCENE, state.scene.name)
            .putFloat(KEY_DISTANCE, state.screenDistance)
            .putFloat(KEY_OFFSET, state.screenOffset)
            .putFloat(KEY_WIDTH, state.screenWidth)
            .putString(KEY_ASPECT, state.aspectPreset.name)
            .putFloat(KEY_WIDTH_RATIO, state.widthRatio)
            .putFloat(KEY_HEIGHT_RATIO, state.heightRatio)
            .putFloat(KEY_SPEED, state.speed)
            .putFloat(KEY_VOLUME, state.volume)
            .putBoolean(KEY_FORCE_MONO, state.forceMono)
            .putBoolean(KEY_TREAT_180_FISHEYE, state.treat180AsFisheye)
            .putString(KEY_REPEAT, state.repeatMode.name)
            .putBoolean(KEY_AUTO_HIDE, state.autoHide)
            .putInt(KEY_AUTO_HIDE_SECONDS, state.autoHideSeconds)
            .putBoolean(KEY_CLICK_SOUND, state.clickSound)
            .putBoolean(KEY_SUMMON_IN_FRONT, state.summonInFront)
            .putBoolean(KEY_CONTROLLER_TAP, state.controllerTapPlayPause)
            .putBoolean(KEY_PAUSE_ON_FOCUS_LOSS, state.pauseOnFocusLoss)
            .apply()
    }

    private inline fun <reified E : Enum<E>> enum(key: String, default: E): E {
        val name = sp.getString(key, null) ?: return default
        return runCatching { enumValueOf<E>(name) }.getOrDefault(default)
    }

    private companion object {
        const val KEY_CURVE = "curve"
        const val KEY_SCENE = "scene"
        const val KEY_DISTANCE = "distance"
        const val KEY_OFFSET = "offset"
        const val KEY_WIDTH = "width"
        const val KEY_ASPECT = "aspect"
        const val KEY_WIDTH_RATIO = "widthRatio"
        const val KEY_HEIGHT_RATIO = "heightRatio"
        const val KEY_SPEED = "speed"
        const val KEY_VOLUME = "volume"
        const val KEY_FORCE_MONO = "forceMono"
        const val KEY_TREAT_180_FISHEYE = "treat180Fisheye"
        const val KEY_REPEAT = "repeat"
        const val KEY_AUTO_HIDE = "autoHide"
        const val KEY_AUTO_HIDE_SECONDS = "autoHideSeconds"
        const val KEY_CLICK_SOUND = "clickSound"
        const val KEY_SUMMON_IN_FRONT = "summonInFront"
        const val KEY_CONTROLLER_TAP = "controllerTap"
        const val KEY_PAUSE_ON_FOCUS_LOSS = "pauseOnFocusLoss"
    }
}
