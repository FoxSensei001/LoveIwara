package m.c.g.a.i_iwara.vr

import com.meta.spatial.runtime.StereoMode
import com.meta.spatial.toolkit.CylinderShapeOptions
import com.meta.spatial.toolkit.Equirect180ShapeOptions
import com.meta.spatial.toolkit.Equirect360ShapeOptions
import com.meta.spatial.toolkit.MediaPanelShapeOptions
import com.meta.spatial.toolkit.QuadShapeOptions
import m.c.g.a.i_iwara.questui.AspectPreset
import m.c.g.a.i_iwara.questui.Projection
import m.c.g.a.i_iwara.questui.ScreenCurve
import m.c.g.a.i_iwara.questui.StereoPacking
import m.c.g.a.i_iwara.questui.VideoControlsState
import m.c.g.a.i_iwara.questui.VideoFormat
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.max

/**
 * 幕布的几何：把「视频类型 / 屏幕类型 / 屏幕尺寸」三块设置翻译成 Spatial SDK 的面板形状。
 *
 * 全是纯函数，不碰实体。沉浸 Activity 只负责把结果喂给 `reshape()` 或 `settingsCreator`。
 */
object ScreenGeometry {

    /** 球幕半径（米）。官方媒体样例 180 用 50、360 用 300；这里统一取 50，两者视觉无差。 */
    const val SPHERE_RADIUS = 50.0f

    /** 静息眼高（米）。参考空间是 LOCAL_FLOOR，所以场景里的 y 都是绝对高度。 */
    const val EYE_HEIGHT_M = 1.60f

    /**
     * 单眼画面的真实宽高比。
     *
     * 立体片取半幅之后才是人眼看到的那个比例，而**半幅/全幅决定了要不要除二**：
     * - HSBS（半幅左右）：两眼各压进半幅，单眼比例 = 整帧比例；
     * - FSBS（全幅左右）：两眼各占一整幅，单眼比例 = (宽/2)/高；
     * - HOU / FOU 同理，换成竖向。
     */
    fun eyeAspect(format: VideoFormat, width: Int, height: Int): Float {
        if (width <= 0 || height <= 0) return 16f / 9f
        val w = width.toFloat()
        val h = height.toFloat()
        return when (format.packing) {
            StereoPacking.MONO -> w / h
            StereoPacking.LEFT_RIGHT -> if (format.fullFrame) (w / 2f) / h else w / h
            StereoPacking.TOP_BOTTOM -> if (format.fullFrame) w / (h / 2f) else w / h
        }
    }

    /** 幕布最终的宽高比：片源比例 → 预设比例覆盖 → 宽比/长比系数。 */
    fun screenAspect(state: VideoControlsState, width: Int, height: Int): Float {
        val base = if (state.aspectPreset == AspectPreset.DEFAULT) {
            eyeAspect(state.format, width, height)
        } else {
            state.aspectPreset.ratio
        }
        return (base * state.widthRatio / state.heightRatio).coerceIn(0.2f, 6f)
    }

    /** SDK 的立体模式：编排 + 「强制 2D」开关。 */
    fun stereoMode(format: VideoFormat, forceMono: Boolean): StereoMode = when (format.packing) {
        StereoPacking.MONO -> StereoMode.None
        StereoPacking.LEFT_RIGHT -> if (forceMono) StereoMode.MonoLeft else StereoMode.LeftRight
        StereoPacking.TOP_BOTTOM -> if (forceMono) StereoMode.MonoUp else StereoMode.UpDown
    }

    /**
     * 幕布形状。
     *
     * 几何模型：**幕宽是弧长**（用户滑块直接给），弧度档决定包多紧，于是
     * `radius = 弧长 / 弧度`。60° + 2.4m ⇒ 半径 2.29m ≈ 默认观看距离 2.5m，
     * 正好接近「曲率半径 = 观看距离」那个理想值（每个像素到眼等距，无梯形畸变）。
     *
     * 鱼眼 / EAC 本机渲染不了，按平面放（至少能看），面板上另有提示。
     */
    fun shape(state: VideoControlsState, width: Int, height: Int): MediaPanelShapeOptions {
        val format = state.format
        return when (format.projection) {
            Projection.PANORAMA_360 -> Equirect360ShapeOptions(radius = SPHERE_RADIUS)
            Projection.PANORAMA_180 -> Equirect180ShapeOptions(radius = SPHERE_RADIUS)
            Projection.FLAT, Projection.EAC, Projection.FISHEYE -> {
                val w = state.screenWidth
                val h = w / screenAspect(state, width, height)
                if (state.curve == ScreenCurve.FLAT) {
                    QuadShapeOptions(width = w, height = h)
                } else {
                    val arc = (state.curve.arcDegrees * PI / 180.0).toFloat()
                    CylinderShapeOptions(radius = max(0.5f, w / arc), width = w, height = h)
                }
            }
        }
    }

    /** 两个形状是不是同一「家族」（平面 quad/cylinder 之间可以 reshape；球幕另算）。 */
    fun sameFamily(a: VideoFormat, b: VideoFormat): Boolean = a.isFlat == b.isFlat &&
        (a.isFlat || a.projection == b.projection)

    /**
     * 「自动识别」：按整帧宽高比猜一个格式。
     *
     * 与 Dart 侧 L1 判定同源的启发式（官方 Media View 也是按 2:1 判 360）。
     * 这只是一个默认档，用户随时能改。
     */
    fun guessFormat(width: Int, height: Int): VideoFormat {
        if (width <= 0 || height <= 0) return VideoFormat.FLAT_2D
        val r = width.toFloat() / height
        return when {
            abs(r - 2f) < 0.12f -> VideoFormat.PANO_180_3D_LR
            abs(r - 1f) < 0.08f -> VideoFormat.PANO_180_2D
            abs(r - 0.5f) < 0.06f -> VideoFormat.PANO_180_3D_TB
            r >= 3.2f -> VideoFormat.FLAT_3D_FSBS
            else -> VideoFormat.FLAT_2D
        }
    }

    /** intent / bridge 传来的字符串档位 → 格式枚举。 */
    fun formatOf(shape: String, stereo: String, fullFrame: Boolean): VideoFormat = when (shape) {
        "180" -> when (stereo) {
            "lr" -> VideoFormat.PANO_180_3D_LR
            "tb" -> VideoFormat.PANO_180_3D_TB
            else -> VideoFormat.PANO_180_2D
        }
        "360" -> when (stereo) {
            "lr" -> VideoFormat.PANO_360_3D_LR
            "tb" -> VideoFormat.PANO_360_3D_TB
            else -> VideoFormat.PANO_360_2D
        }
        "fisheye" -> when (stereo) {
            "lr", "tb" -> VideoFormat.FISHEYE_180_3D
            else -> VideoFormat.FISHEYE_2D
        }
        else -> when (stereo) {
            "lr" -> if (fullFrame) VideoFormat.FLAT_3D_FSBS else VideoFormat.FLAT_3D_HSBS
            "tb" -> if (fullFrame) VideoFormat.FLAT_3D_FOU else VideoFormat.FLAT_3D_HOU
            else -> VideoFormat.FLAT_2D
        }
    }
}
