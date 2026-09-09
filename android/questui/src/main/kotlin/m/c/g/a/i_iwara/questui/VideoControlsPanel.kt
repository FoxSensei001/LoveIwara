package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import com.meta.spatial.uiset.theme.SpatialTheme
import com.meta.spatial.uiset.theme.darkSpatialColorScheme

/**
 * 播放器的空间控制面板。
 *
 * # 形状：一张卡片，没有透明区（2026-09-05 真机之后）
 *
 * 第一版照参考软件把五枚圆钮悬浮在卡片**外面**的透明区里。真机上两条硬伤：
 * 1. 透明区照样是这块面板的命中面 —— 光标到那儿就被挡住、穿不过去，用户以为是 bug；
 * 2. 圆钮外圈点不到（UI Set 的圆钮命中区只有自己那 56dp）。
 * 所以改成**一张卡片**：顶栏钮进卡片头部行（✕ · 标题 · 状态 · 场景/列表/设置/返回），
 * 走带行居中，进度条在底。面板逻辑尺寸 1100×360dp，比第一版矮 140dp。
 *
 * # ⛔ 只有一块面板，页面在它内部换
 *
 * 点「场景 / 播放列表 / 设置 / 视频类型 / 屏幕类型」都是把这张卡片的**内容**换掉，
 * 不再飘第二个窗出来。官方 `comfort`：「keep the main controls in a **single UI panel**」。
 * 子页自带「‹ 返回」，回到播放页再切别的页。
 *
 * # ⛔ 交互反馈是必做项
 *
 * 官方：「**Hands have no haptics.** … every successful poke, pinch, or grab needs strong
 * audiovisual feedback … **This is not optional.**」按钮的 hover / 按下态由 [CircleActionButton]
 * 与 UI Set 组件自带，音效由调用方在每个回调里播。
 *
 * # 触碰上报
 *
 * 最外层挂 [reportPanelTouches]：任何触碰都告诉 `:app`，用于「捏合发生在面板上」的判定
 * 与空闲计时。
 */
@Composable
fun VideoControlsPanel(state: VideoControlsState, cb: VideoControlsCallbacks) {
    SpatialTheme(colorScheme = darkSpatialColorScheme()) {
        Box(modifier = Modifier.fillMaxSize().reportPanelTouches(cb)) {
            PanelSurface {
                // 换页淡入淡出，不硬切（本项目「有出有入」的纪律在空间面板上同样适用）。
                Crossfade(targetState = state.route, animationSpec = tween(180), label = "route") { route ->
                    when (route) {
                        // 幕布上放的是一本图库时，主页是图集页；子页（场景 / 屏幕类型 / 设置）两者共用。
                        ControlsRoute.PLAYER -> {
                            val gallery = state.gallery
                            if (gallery != null) GalleryPage(state, gallery, cb) else PlayerPage(state, cb)
                        }
                        // 浏览态（没有片子）唯一的一页，与播放页互斥，见 [BrowsePanelPage]。
                        ControlsRoute.BROWSE -> BrowsePanelPage(state, cb)
                        ControlsRoute.SCENE -> ScenePage(state, cb)
                        ControlsRoute.DISTANCE -> ViewDistancePage(cb)
                        ControlsRoute.VIDEO_TYPE -> VideoTypePage(state, cb)
                        ControlsRoute.SCREEN_TYPE -> ScreenTypePage(state, cb)
                        ControlsRoute.PLAYLIST -> PlaylistPage(state, cb)
                        ControlsRoute.SETTINGS -> SettingsPage(state, cb)
                    }
                }
            }
        }
    }
}

/**
 * 造出一块可以直接交给 `ComposeViewPanelRegistration` 的 [ComposeView]。
 *
 * ⭐ 这个工厂函数是本模块的**唯一出口**：所有 `@Composable` 都留在这里，
 * `:app` 只看到「给我一个 Context 和状态，还我一个 View」。
 *
 * ⛔ 内容包在 [PanelLocalization] 里：面板文案跟**应用内选的语言**走，不跟系统语言走。
 * 包在工厂里而不是让 `:app` 自己包，是为了「新加一块面板也不会漏掉语言」。
 */
fun createVideoControlsView(
    context: Context,
    state: VideoControlsState,
    callbacks: VideoControlsCallbacks,
): ComposeView = ComposeView(context).apply {
    setContent { PanelLocalization { VideoControlsPanel(state, callbacks) } }
}
