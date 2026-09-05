package m.c.g.a.i_iwara.questui

import android.content.Context
import android.content.res.Configuration
import android.os.LocaleList
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import java.util.Locale

/**
 * 空间面板的语言。
 *
 * # ⛔ 面板的语言跟**应用内的语言设置**走，不跟系统语言走
 *
 * 应用的界面语言是用户自己在设置里选的（slang，`ConfigKey.APPLICATION_LOCALE`），
 * 完全可能与头显的系统语言不同 —— 一个把 Quest 设成英文、把应用设成简体中文的用户，
 * 2D 面板里全是中文、空间面板里却全是英文，那是明显的割裂。
 *
 * 所以 Dart 侧在启动、进播放页、`present`、以及设置页里换语言的那一刻，把
 * `LocaleSettings.currentLocale.languageTag`（如 `zh-CN`）推给原生
 * （`XrBridge` 的 `setLocale`），存进 [tag]；词条在 `:questui` 的 `res/values`、`res/values-zh-rCN` 等目录里，
 * 语种与 `lib/i18n` 一致（en / zh-rCN / zh-rTW / ja）。
 *
 * # 用法
 *
 * - Compose 面板：整棵树包一层 [PanelLocalization]（两个工厂函数已经包好），
 *   里面的 `stringResource(...)` 就会走这个语言。
 * - 非 Compose 处（沉浸 Activity 里那一行提示文案）：`PanelLocale.apply(this).getString(...)`，
 *   见 `ImmersiveActivity.text`。
 *
 * # 换语言即时生效
 *
 * [tag] 是 Compose 状态：面板正开着时换语言，这棵树会自己重组换词，不用收起再唤出。
 * 已经生成好的那一行 `notice` 字符串是个例外（生成时就定死了），要等下一次事件才刷新。
 */
object PanelLocale {

    /** BCP-47 语言标签，如 `en` / `ja` / `zh-CN` / `zh-TW`。空串 = 跟随系统。 */
    var tag: String by mutableStateOf("")

    /** 用 [tag] 造一个取词用的 Context；[tag] 为空或解析不出语言时原样返回。 */
    fun apply(context: Context): Context {
        val languageTag = tag
        if (languageTag.isBlank()) return context
        val locale = Locale.forLanguageTag(languageTag)
        if (locale.language.isEmpty()) return context
        val config = Configuration(context.resources.configuration)
        config.setLocales(LocaleList(locale))
        return context.createConfigurationContext(config)
    }
}

/**
 * 把 [content] 里的取词切到应用内选定的语言。
 *
 * ⛔ 换的是 `LocalContext` 而不是 `ComposeView` 自己的 Context：那只 View 的 Context
 * 是 Spatial SDK 交给我们的，它自己还要拿去做别的事（生命周期宿主、Activity 强转……），
 * 包一层 `ContextWrapper` 递回去是没必要的风险。`stringResource` 读的就是 `LocalContext`，
 * 换在这里够了。
 */
@Composable
fun PanelLocalization(content: @Composable () -> Unit) {
    val context = LocalContext.current
    val tag = PanelLocale.tag
    val localized = remember(context, tag) { PanelLocale.apply(context) }
    CompositionLocalProvider(LocalContext provides localized, content = content)
}
