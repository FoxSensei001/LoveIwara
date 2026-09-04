package m.c.g.a.i_iwara.questui

import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * 缓冲指示：一枚转圈 + 「缓冲中…」，整块面板透明底，浮在幕布正中。
 *
 * 用户 2026-09-05：「缓冲动画应该在播放器中间显示」。它是一块独立的小面板，
 * 只在缓冲期间由 `:app` 创建实体、缓冲结束即销毁（合成层按存在付钱）。
 */
@Composable
fun BufferingIndicator() {
    Box(modifier = Modifier.fillMaxSize().background(Color.Transparent), contentAlignment = Alignment.Center) {
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(24.dp))
                .background(PanelTokens.SURFACE)
                .padding(horizontal = 28.dp, vertical = 22.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            CircularProgressIndicator(
                modifier = Modifier.size(56.dp),
                color = PanelTokens.ON_SURFACE,
                strokeWidth = 5.dp,
            )
            Text(text = "缓冲中…", color = PanelTokens.ON_SURFACE, fontSize = 18.sp)
        }
    }
}

/** 交给 `ComposeViewPanelRegistration` 的工厂；`:app` 侧没有 Compose 编译器插件，只认 View。 */
fun createBufferingView(context: Context): ComposeView = ComposeView(context).apply {
    setContent { BufferingIndicator() }
}
