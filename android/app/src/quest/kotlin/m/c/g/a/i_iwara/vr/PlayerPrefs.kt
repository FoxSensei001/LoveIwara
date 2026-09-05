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

    // ---- 窗的几何（不在 VideoControlsState 里：它们是空间里的窗，不是播放器设置） ----

    /** 2D 应用面板的物理宽高（米）。用户拉过角之后记住，下次进来就是那个大小。 */
    var uiPanelWidth = DEFAULT_UI_PANEL_WIDTH_M
    var uiPanelHeight = DEFAULT_UI_PANEL_WIDTH_M * UI_PANEL_ASPECT_H_OVER_W

    /** 控制面板相对基准尺寸的等比缩放。 */
    var controlsScale = 1f

    /**
     * 按**画面宽高比**记住的观看距离与幕宽：`"1.78" -> [distance, width]`。
     *
     * 用户看 16:9 与看竖屏片想要的远近 / 大小不一样，预设值又不可能对所有人都合适——每次拖过距离 / 尺寸
     * 就按当前画面比例记一份，下次放到同比例的片子直接恢复（用户 2026-09-05）。比例四舍五入到两位小数，
     * 1920×1080 与 1280×720 落同一格。
     */
    private val aspectLayouts = LinkedHashMap<String, FloatArray>()

    fun layoutFor(aspectKey: String): FloatArray? = aspectLayouts[aspectKey]?.copyOf()

    fun rememberLayout(aspectKey: String, distance: Float, width: Float) {
        aspectLayouts.remove(aspectKey)
        aspectLayouts[aspectKey] = floatArrayOf(distance, width)
        while (aspectLayouts.size > MAX_ASPECT_LAYOUTS) aspectLayouts.remove(aspectLayouts.keys.first())
    }

    fun forgetLayout(aspectKey: String) {
        aspectLayouts.remove(aspectKey)
    }

    fun load(state: VideoControlsState) {
        aspectLayouts.clear()
        sp.getString(KEY_ASPECT_LAYOUTS, null)?.split(';')?.forEach { row ->
            val (key, value) = row.split('=').takeIf { it.size == 2 } ?: return@forEach
            val nums = value.split(',').mapNotNull { it.toFloatOrNull() }
            if (nums.size == 2) aspectLayouts[key] = floatArrayOf(nums[0], nums[1])
        }
        uiPanelWidth = sp.getFloat(KEY_UI_WIDTH, DEFAULT_UI_PANEL_WIDTH_M).coerceIn(0.8f, 4f)
        uiPanelHeight = sp.getFloat(KEY_UI_HEIGHT, DEFAULT_UI_PANEL_WIDTH_M * UI_PANEL_ASPECT_H_OVER_W).coerceIn(0.5f, 2.6f)
        controlsScale = sp.getFloat(KEY_CONTROLS_SCALE, 1f).coerceIn(0.6f, 2f)
        state.curve = enum(KEY_CURVE, ScreenCurve.SLIGHT)
        state.scene = enum(KEY_SCENE, SceneKind.VOID)
        state.screenDistance = sp.getFloat(KEY_DISTANCE, 2.4f)
        state.screenOffset = sp.getFloat(KEY_OFFSET, 0f)
        state.screenWidth = sp.getFloat(KEY_WIDTH, 3.2f)
        // 「沿用到下一条视频」关着时，屏幕尺寸与倍速跨会话也不恢复：每条片子都从默认值开始。
        state.carryOverToNextVideo = sp.getBoolean(KEY_CARRY_OVER, false)
        if (state.carryOverToNextVideo) {
            state.aspectPreset = enum(KEY_ASPECT, AspectPreset.DEFAULT)
            state.widthRatio = sp.getFloat(KEY_WIDTH_RATIO, 1f)
            state.heightRatio = sp.getFloat(KEY_HEIGHT_RATIO, 1f)
            state.speed = sp.getFloat(KEY_SPEED, 1f)
        } else {
            state.resetPerVideoSettings()
        }
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
            .putFloat(KEY_UI_WIDTH, uiPanelWidth)
            .putFloat(KEY_UI_HEIGHT, uiPanelHeight)
            .putFloat(KEY_CONTROLS_SCALE, controlsScale)
            .putString(KEY_CURVE, state.curve.name)
            .putString(KEY_SCENE, state.scene.name)
            .putFloat(KEY_DISTANCE, state.screenDistance)
            .putFloat(KEY_OFFSET, state.screenOffset)
            .putFloat(KEY_WIDTH, state.screenWidth)
            .putString(KEY_ASPECT, state.aspectPreset.name)
            .putFloat(KEY_WIDTH_RATIO, state.widthRatio)
            .putFloat(KEY_HEIGHT_RATIO, state.heightRatio)
            .putFloat(KEY_SPEED, state.speed)
            .putBoolean(KEY_CARRY_OVER, state.carryOverToNextVideo)
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
            .putString(
                KEY_ASPECT_LAYOUTS,
                aspectLayouts.entries.joinToString(";") { (k, v) -> "$k=${"%.2f".format(v[0])},${"%.2f".format(v[1])}" },
            )
            .apply()
    }

    private inline fun <reified E : Enum<E>> enum(key: String, default: E): E {
        val name = sp.getString(key, null) ?: return default
        return runCatching { enumValueOf<E>(name) }.getOrDefault(default)
    }

    companion object {
        /** 2D 应用面板默认 1.6m 宽、1024×640dp（与 `ImmersiveActivity.registerPanels` 成对）。 */
        const val DEFAULT_UI_PANEL_WIDTH_M = 1.6f
        const val UI_PANEL_ASPECT_H_OVER_W = 640f / 1024f

        private const val KEY_UI_WIDTH = "uiPanelWidth"
        private const val KEY_UI_HEIGHT = "uiPanelHeight"
        private const val KEY_CONTROLS_SCALE = "controlsScale"
        const val KEY_CURVE = "curve"
        const val KEY_SCENE = "scene"
        const val KEY_DISTANCE = "distance"
        const val KEY_OFFSET = "offset"
        const val KEY_WIDTH = "width"
        const val KEY_ASPECT = "aspect"
        const val KEY_WIDTH_RATIO = "widthRatio"
        const val KEY_HEIGHT_RATIO = "heightRatio"
        const val KEY_SPEED = "speed"
        const val KEY_CARRY_OVER = "carryOverToNextVideo"
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
        const val KEY_ASPECT_LAYOUTS = "aspectLayouts"
        private const val MAX_ASPECT_LAYOUTS = 24
    }
}
