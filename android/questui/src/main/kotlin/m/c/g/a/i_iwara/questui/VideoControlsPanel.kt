package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import com.meta.spatial.uiset.theme.SpatialTheme
import com.meta.spatial.uiset.theme.darkSpatialColorScheme
import com.meta.spatial.uiset.theme.icons.SpatialIcons
import com.meta.spatial.uiset.theme.icons.regular.Close
import com.meta.spatial.uiset.theme.icons.regular.Environment
import com.meta.spatial.uiset.theme.icons.regular.Home
import com.meta.spatial.uiset.theme.icons.regular.ListView
import com.meta.spatial.uiset.theme.icons.regular.Settings

/**
 * 播放器的空间控制面板。
 *
 * # 形状：一排悬浮圆钮 + 一块深色窗（照参考软件重做，2026-08-29）
 *
 * 用户在 Quest 上找了一款成熟 VR 播放器作参照并要求「直接模仿它」。它的结构是：
 *
 * ```
 * ✕                    ○ 场景  ○ 播放列表  ○ 设置  ○ 返回应用    ← 悬浮圆钮排
 * ┌────────────────────────────────────────────────────────────┐
 * │ 标题                              🕒 时间  🔋 电量  [缓冲中…] │
 * │ [notice]                                                    │
 * │ [🔊] ⏮ ⏪10 ▶/⏸ ⏩10 ⏭       [速度][视频类型][屏幕类型]      │
 * │ ═════════●─────────────────────    00:01:41 / 00:04:27      │
 * └────────────────────────────────────────────────────────────┘
 * ```
 *
 * 我们的取舍（`docs/xr-app-layout.md` §15 已定）：
 * - ⛔ **不做调色**（参考软件里的第三枚顶栏圆钮）；
 * - 顶栏最右一枚是「返回应用」——⛔ 这是官方 **Requirement** 级要求：
 *   「a system back button is **not universally available** across input modalities.
 *    If needed, **add a back button to your app's interface**.」
 *   沉浸空间里既没有手势返回也没有系统返回，必须自己画。
 * - 场景只做**透视 / 虚空**两种；播放列表接应用已有的**稍后再看**。
 *
 * # ⛔ 只有一块面板，页面在它内部换
 *
 * 点「场景 / 播放列表 / 设置 / 视频类型 / 屏幕类型」都是把这块窗的**内容**换掉，
 * 不再飘第二个窗出来。官方 `comfort` 原文：「try to keep the main controls in a
 * **single UI panel**, as opposed to having multiple windows floating around」。
 *
 * # ⛔ 触碰上报挂在最外层，覆盖含顶栏透明区
 *
 * [Modifier.reportPanelTouches] 挂在最外的 Column 上而不是各页各挂：`:app` 侧的
 * `PanelInputBridge` 靠这个信号做两件事 —— 续「空闲收起」计时 + 把「捏合唤出」
 * 和「面板内交互」分家。少覆盖一格都会造成召唤手势被误触发。
 */
@Composable
fun VideoControlsPanel(state: VideoControlsState, cb: VideoControlsCallbacks) {
    SpatialTheme(colorScheme = darkSpatialColorScheme()) {
        Column(modifier = Modifier.fillMaxSize().reportPanelTouches(cb)) {
            TopBar(cb)
            Spacer(Modifier.height(10.dp))
            Column(modifier = Modifier.weight(1f)) {
                PanelSurface {
                    when (state.route) {
                        ControlsRoute.PLAYER -> PlayerPage(state, cb)
                        ControlsRoute.SCENE -> ScenePage(state, cb)
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
 * 悬浮圆钮排。
 *
 * ⭐ 它画在面板底板**外面**，靠 `PanelShapeLayerBlendType.ALPHA_BLEND` 让钮与钮之间
 * 的缝透出后面的画面 —— 这就是参考软件那种「圆钮浮在窗上方」的观感。
 * ⚠️ alpha 面板未真机验证过，若出现黑底/描边，退路是把这排钮收进底板里
 * （只影响观感，不影响功能）。
 *
 * ⛔ 顶栏在**每个子页里都显示**（含 SCENE / SETTINGS 等）：参考软件的子面板也保留
 * 顶栏，用户从任何一页都能一键回到应用或换到另一个子页。
 */
@Composable
private fun TopBar(cb: VideoControlsCallbacks) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        // 关闭 = 收起这块面板（⛔ 实现方必须真销毁实体，不是设 0-alpha）。
        // 收起之后靠捏合重新唤出，见 ImmersiveActivity 的手势召唤。
        TopBarButton(SpatialIcons.Regular.Close, "收起控制面板", cb::onHidePanel)

        Spacer(Modifier.weight(1f))

        TopBarButton(SpatialIcons.Regular.Environment, "场景") {
            cb.onRoute(ControlsRoute.SCENE)
        }
        TopBarButton(SpatialIcons.Regular.ListView, "播放列表") {
            cb.onRoute(ControlsRoute.PLAYLIST)
        }
        TopBarButton(SpatialIcons.Regular.Settings, "设置") {
            cb.onRoute(ControlsRoute.SETTINGS)
        }
        // ⛔ 官方 Requirement：应用内自带返回。沉浸空间没有系统返回可用。
        TopBarButton(SpatialIcons.Regular.Home, "返回应用", cb::onBackToApp)
    }
}

/**
 * 造出一块可以直接交给 `ComposeViewPanelRegistration` 的 [ComposeView]。
 *
 * ⭐ 这个工厂函数是本模块的**唯一出口**：所有 `@Composable` 都留在这里，
 * `:app` 只看到「给我一个 Context 和状态，还我一个 View」——
 * 它那边没有（也不能有）Compose 编译器插件。
 */
fun createVideoControlsView(
    context: Context,
    state: VideoControlsState,
    callbacks: VideoControlsCallbacks,
): ComposeView = ComposeView(context).apply {
    setContent { VideoControlsPanel(state, callbacks) }
}
