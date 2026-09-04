package m.c.g.a.i_iwara.xr

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine

/**
 * `standard` 变体的空实现。
 *
 * 这个类在 `standard` 与 `quest` 两个源集里各有一份**同名同签名**的实现
 * （所以它不能出现在 `main` 里）。`MainActivity` 无条件调用它，
 * 由变体决定拿到的是空壳还是真接线 —— 这样 Dart 侧与 `MainActivity`
 * 都不需要写任何 `if (isQuest)` 分支。
 *
 * ⚠️ 诚实记录：这确实让 `standard` 包多了一个空类（dex 里约 1KB）。
 * 硬约束 C1 的本意是「不把 48MB 的 Spatial SDK 打进普通包、不抬 minSdk」，
 * 这一点仍然成立；但「字节完全不变」这句话从此不再准确。
 */
object XrBridge {
    fun attach(activity: Activity, engine: FlutterEngine) {
        // no-op：非 XR 变体没有沉浸空间可用。
    }
}
