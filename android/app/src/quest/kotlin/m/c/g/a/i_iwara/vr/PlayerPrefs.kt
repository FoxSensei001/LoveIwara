package m.c.g.a.i_iwara.vr

import android.content.Context
import m.c.g.a.i_iwara.questui.AspectPreset
import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings
import m.c.g.a.i_iwara.questui.MediaEffectsSettings
import m.c.g.a.i_iwara.questui.RepeatMode
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.VideoControlsState

/**
 * 沉浸播放器的用户偏好：屏幕类型、背景、几何、倍速、面板行为……
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

    /**
     * 2D 应用面板离人多远（米）。侧栏头像上的「拉远 / 拉近 / 重置」改的就是它，
     * 与宽高同样**跨会话记住** —— 下次进来面板还在上次那个远近上。
     *
     * ⛔ 只记距离、不记朝向：面板的落点每次都按**当时**的视线重新算
     * （见 `ImmersiveActivity.uiPanelPose`），把一份世界坐标存下来会让人换个方向
     * 坐下之后面板出现在身后。
     */
    var uiPanelDistance = DEFAULT_UI_PANEL_DISTANCE_M

    /** 控制面板相对基准尺寸的等比缩放。 */
    var controlsScale = 1f

    /** 空间画廊：幻灯片间隔（秒）与视频项单条循环。 */
    var slideshowSeconds = 5
    var galleryLoopVideo = true

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
        uiPanelDistance = sp.getFloat(KEY_UI_DISTANCE, DEFAULT_UI_PANEL_DISTANCE_M)
            .coerceIn(MIN_UI_PANEL_DISTANCE_M, MAX_UI_PANEL_DISTANCE_M)
        controlsScale = sp.getFloat(KEY_CONTROLS_SCALE, 1f).coerceIn(0.6f, 2f)
        slideshowSeconds = sp.getInt(KEY_SLIDESHOW_SECONDS, 5).coerceIn(1, 120)
        galleryLoopVideo = sp.getBoolean(KEY_GALLERY_LOOP, true)
        state.curve = enum(KEY_CURVE, ScreenCurve.SLIGHT)
        // Do not reuse the retired "scene" key (VOID/PASSTHROUGH). Existing users
        // keep their room visibility; a new environment is selected explicitly.
        state.environment = EnvironmentSettings(
            kind = enum(KEY_ENVIRONMENT, EnvironmentKind.PASSTHROUGH),
            spaceBrightness = sp.getFloat(KEY_SPACE_BRIGHTNESS, 0.65f),
        ).normalized()
        state.mediaEffects = MediaEffectsSettings(
            enabled = sp.getBoolean(KEY_EFFECTS_ENABLED, true),
            // The first prototype used unrelated Gaussian parameters. Its saved
            // 35/55 defaults cannot describe the reference's coupled response.
            edgeFeather = if (sp.getInt(KEY_AMBIENCE_VERSION, 0) >= 2) sp.getFloat(KEY_EDGE_FEATHER, 1f) else 1f,
            glowStrength = if (sp.getInt(KEY_AMBIENCE_VERSION, 0) >= 2) sp.getFloat(KEY_GLOW_STRENGTH, 0.4f) else 0.4f,
            backgroundTransparency = sp.getFloat(KEY_BACKGROUND_TRANSPARENCY, 1f),
        ).normalized()
        state.screenDistance = sp.getFloat(KEY_DISTANCE, DEFAULT_VIEW_DISTANCE_M).coerceIn(1.2f, 8f)
        state.screenOffset = sp.getFloat(KEY_OFFSET, 0f).coerceIn(-1.5f, 1.5f)
        state.screenWidth = sp.getFloat(KEY_WIDTH, DEFAULT_SCREEN_WIDTH_M).coerceIn(1f, 10f)
        val migrateLayout = !sp.getBoolean(KEY_COMFORTABLE_LAYOUT, false)
        if (migrateLayout) {
            // Bring old distant layouts closer once, retaining their apparent size. Later edits stay personal.
            val closer = nearerLayout(state.screenDistance, state.screenWidth)
            state.screenDistance = closer[0]
            state.screenWidth = closer[1]
            state.screenOffset = 0f
            for ((key, saved) in aspectLayouts.toMap()) aspectLayouts[key] = nearerLayout(saved[0], saved[1])
        }
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
        // ⛔ 音量不进偏好：面板上那根调的是**系统**音量（[SystemVolume]），
        // 归用户和系统管，起播时照读系统当前值，不该由本 App 在下次启动时改回去。
        state.forceMono = sp.getBoolean(KEY_FORCE_MONO, false)
        state.treat180AsFisheye = sp.getBoolean(KEY_TREAT_180_FISHEYE, false)
        state.repeatMode = migratedRepeatMode()
        state.autoHide = sp.getBoolean(KEY_AUTO_HIDE, true)
        state.autoHideSeconds = sp.getInt(KEY_AUTO_HIDE_SECONDS, 12)
        state.clickSound = sp.getBoolean(KEY_CLICK_SOUND, true)
        state.summonInFront = sp.getBoolean(KEY_SUMMON_IN_FRONT, true)
        state.controllerTapPlayPause = sp.getBoolean(KEY_CONTROLLER_TAP, true)
        state.pauseOnFocusLoss = sp.getBoolean(KEY_PAUSE_ON_FOCUS_LOSS, true)
        if (migrateLayout) {
            save(state)
            sp.edit().putBoolean(KEY_COMFORTABLE_LAYOUT, true).apply()
        }
    }

    fun save(state: VideoControlsState) {
        sp.edit()
            .putFloat(KEY_UI_WIDTH, uiPanelWidth)
            .putFloat(KEY_UI_HEIGHT, uiPanelHeight)
            .putFloat(KEY_UI_DISTANCE, uiPanelDistance)
            .putFloat(KEY_CONTROLS_SCALE, controlsScale)
            .putInt(KEY_SLIDESHOW_SECONDS, slideshowSeconds)
            .putBoolean(KEY_GALLERY_LOOP, galleryLoopVideo)
            .putString(KEY_CURVE, state.curve.name)
            .putString(KEY_ENVIRONMENT, state.environment.kind.name)
            .putFloat(KEY_SPACE_BRIGHTNESS, state.environment.spaceBrightness)
            .putBoolean(KEY_EFFECTS_ENABLED, state.mediaEffects.enabled)
            .putInt(KEY_AMBIENCE_VERSION, 2)
            .putFloat(KEY_EDGE_FEATHER, state.mediaEffects.edgeFeather)
            .putFloat(KEY_GLOW_STRENGTH, state.mediaEffects.glowStrength)
            .putFloat(KEY_BACKGROUND_TRANSPARENCY, state.mediaEffects.backgroundTransparency)
            .putFloat(KEY_DISTANCE, state.screenDistance)
            .putFloat(KEY_OFFSET, state.screenOffset)
            .putFloat(KEY_WIDTH, state.screenWidth)
            .putString(KEY_ASPECT, state.aspectPreset.name)
            .putFloat(KEY_WIDTH_RATIO, state.widthRatio)
            .putFloat(KEY_HEIGHT_RATIO, state.heightRatio)
            .putFloat(KEY_SPEED, state.speed)
            .putBoolean(KEY_CARRY_OVER, state.carryOverToNextVideo)
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

    /**
     * 「播完之后」：默认**单集循环**，并对老档案做一次性归位。
     *
     * 代码里的默认值一直是 [RepeatMode.ONE]，但 [save] 每次都会把当时的值写进
     * SharedPreferences —— 早期版本里点过「自动下一条 / 播完停止」的设备，那条记录就一直躺着，
     * 用户看到的「默认」于是不是循环（用户 2026-09-06）。这里只**刷一次**：刷完立刻落标记，
     * 之后用户自己再选什么都原样留着。
     */
    private fun migratedRepeatMode(): RepeatMode {
        val stored = enum(KEY_REPEAT, RepeatMode.ONE)
        if (sp.getBoolean(KEY_REPEAT_DEFAULT_MIGRATED, false)) return stored
        sp.edit().putBoolean(KEY_REPEAT_DEFAULT_MIGRATED, true).apply()
        return RepeatMode.ONE
    }

    private inline fun <reified E : Enum<E>> enum(key: String, default: E): E {
        val name = sp.getString(key, null) ?: return default
        return runCatching { enumValueOf<E>(name) }.getOrDefault(default)
    }

    companion object {
        const val DEFAULT_VIEW_DISTANCE_M = 1.6f
        const val DEFAULT_SCREEN_WIDTH_M = 2.2f

        internal fun nearerLayout(distance: Float, width: Float): FloatArray {
            val oldDistance = distance.takeIf { it.isFinite() }?.coerceIn(1.2f, 8f) ?: DEFAULT_VIEW_DISTANCE_M
            val oldWidth = width.takeIf { it.isFinite() }?.coerceIn(1f, 10f) ?: DEFAULT_SCREEN_WIDTH_M
            val closer = oldDistance.coerceAtMost(DEFAULT_VIEW_DISTANCE_M)
            return floatArrayOf(closer, (oldWidth * closer / oldDistance).coerceIn(1f, 10f))
        }
        /** 2D 应用面板默认 1.6m 宽、1024×640dp（与 `ImmersiveActivity.registerPanels` 成对）。 */
        const val DEFAULT_UI_PANEL_WIDTH_M = 1.6f
        const val UI_PANEL_ASPECT_H_OVER_W = 640f / 1024f

        /** 2D 面板的默认距离，以及「重置位置」回到的那一档。 */
        const val DEFAULT_UI_PANEL_DISTANCE_M = 1.8f

        // ⛔ 下限不是 0.5m：官方 `hands-3d-best-practices` 说 UI 不要落在 0.5~0.8m 的中距，
        // 要「push it well into raycast range (1m or more)」。
        //
        // ⛔ 这一对同时是**菜单的步进范围**和**记住位置时的夹取范围**，故意是同一份：
        // 两份不同的上下限意味着「手动拖到 6m → 记住 6m → 一按拉近却先跳回 4m」。
        // 上限取 6m（大房间里把窗推到墙边还能读得动，面板本身也能一起拉大）。
        const val MIN_UI_PANEL_DISTANCE_M = 1.0f
        const val MAX_UI_PANEL_DISTANCE_M = 6.0f

        // ⛔ 这里原先还有一个 `UI_PANEL_DISTANCE_STEP_M = 0.25f`（「一档走多少米」）。已删：
        // 面板的远近改成与幕布同一套**乘性连续量**（`ViewDistanceMotion.flatFactor`），
        // 没有「档」这回事了 —— 留着一个没人读的常量只会让下一个人以为还在按格走。

        private const val KEY_UI_WIDTH = "uiPanelWidth"
        private const val KEY_UI_HEIGHT = "uiPanelHeight"
        private const val KEY_UI_DISTANCE = "uiPanelDistance"
        private const val KEY_CONTROLS_SCALE = "controlsScale"
        private const val KEY_SLIDESHOW_SECONDS = "slideshowSeconds"
        private const val KEY_GALLERY_LOOP = "galleryLoopVideo"
        const val KEY_CURVE = "curve"
        private const val KEY_EFFECTS_ENABLED = "mediaEffectsEnabled"
        private const val KEY_AMBIENCE_VERSION = "mediaAmbienceVersion"
        private const val KEY_EDGE_FEATHER = "mediaEdgeFeather"
        private const val KEY_GLOW_STRENGTH = "mediaGlowStrength"
        private const val KEY_BACKGROUND_TRANSPARENCY = "mediaBackgroundTransparency"
        private const val KEY_ENVIRONMENT = "backgroundEnvironment"
        private const val KEY_SPACE_BRIGHTNESS = "deepSpaceBrightness"
        const val KEY_DISTANCE = "distance"
        const val KEY_OFFSET = "offset"
        private const val KEY_COMFORTABLE_LAYOUT = "comfortableViewingLayoutV2"
        const val KEY_WIDTH = "width"
        const val KEY_ASPECT = "aspect"
        const val KEY_WIDTH_RATIO = "widthRatio"
        const val KEY_HEIGHT_RATIO = "heightRatio"
        const val KEY_SPEED = "speed"
        const val KEY_CARRY_OVER = "carryOverToNextVideo"
        const val KEY_FORCE_MONO = "forceMono"
        const val KEY_TREAT_180_FISHEYE = "treat180Fisheye"
        const val KEY_REPEAT = "repeat"

        /** 「播完之后」归位到单集循环这件事做过了。见 [migratedRepeatMode]。 */
        private const val KEY_REPEAT_DEFAULT_MIGRATED = "repeatDefaultMigratedV1"
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
