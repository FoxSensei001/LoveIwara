import Flutter
import UIKit

/// UIScene 生命周期下的场景代理。
///
/// Flutter 3.47 起 UI 生命周期由 UISceneDelegate 承担，AppDelegate 只负责进程级事件。
/// 凡是需要 window / rootViewController 或「按场景」分发的事件（打开文件、深链接等），
/// 都必须在这里处理——AppDelegate 上的对应回调在 UIScene 下不再被调用。
///
/// 基类 FlutterSceneDelegate 已实现 scene(_:willConnectTo:options:)、
/// scene(_:openURLContexts:) 等方法，因此这里必须用 override 并调用 super，
/// 否则 Flutter 自身的场景注册逻辑会被跳过。
class SceneDelegate: FlutterSceneDelegate {
  /// 其他 App 通过「用 iwara 打开」传入文件时的入口。
  ///
  /// 迁移前该事件走 AppDelegate 的 application(_:open:options:)，
  /// UIScene 下改由场景接收。
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    for context in URLContexts {
      AppDelegate.current?.notifyFileOpened(url: context.url)
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}
