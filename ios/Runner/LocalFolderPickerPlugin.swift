import Flutter
import UIKit
import UniformTypeIdentifiers

/// iOS 文件夹选取与 Security-Scoped Bookmark 访问控制插件。
///
/// 约束与设计意图：
/// 1. iOS 沙箱外目录访问必须通过 Security-Scoped Bookmark 持久化权限；
/// 2. 苹果官方文档严格要求：stopAccessingSecurityScopedResource 必须在调用过
///    startAccessingSecurityScopedResource 的同一个 URL 实例上调用，否则不仅不能释放权限，
///    还会造成内核安全作用域引用计数泄露；
/// 3. UIDocumentPickerViewController 的展示必须在主线程从当前活跃场景的顶层 UIViewController 弹出；
/// 4. pickFolder 是异步交互，FlutterResult 暂存在 delegate 回调时完成。
class LocalFolderPickerPlugin: NSObject, UIDocumentPickerDelegate {
  static let shared = LocalFolderPickerPlugin()

  private var channel: FlutterMethodChannel?
  private var pendingPickerResult: FlutterResult?

  /// 记录处于 accessing 状态的 URL 实例及引用计数。
  /// key 为 bookmark base64 字符串。
  private struct AccessEntry {
    let url: URL
    var count: Int
  }
  private var activeAccessEntries = [String: AccessEntry]()
  private let lock = NSLock()

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "i_iwara/ios_folder_picker",
      binaryMessenger: messenger
    )
    let instance = LocalFolderPickerPlugin.shared
    instance.channel = channel
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "pickFolder":
      pickFolder(result: result)
    case "resolveBookmark":
      guard let args = call.arguments as? [String: Any],
            let bookmark = args["bookmark"] as? String else {
        result(nil)
        return
      }
      resolveBookmark(bookmark: bookmark, result: result)
    case "startAccess":
      guard let args = call.arguments as? [String: Any],
            let bookmark = args["bookmark"] as? String else {
        result(false)
        return
      }
      result(startAccess(bookmark: bookmark))
    case "stopAccess":
      guard let args = call.arguments as? [String: Any],
            let bookmark = args["bookmark"] as? String else {
        result(false)
        return
      }
      result(stopAccess(bookmark: bookmark))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Folder Picker

  private func pickFolder(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      // 若已有正在进行的选取，先取消前一次回调
      if let previous = self.pendingPickerResult {
        self.pendingPickerResult = nil
        previous(nil)
      }

      guard let topVC = self.topViewController() else {
        result(FlutterError(
          code: "NO_VIEW_CONTROLLER",
          message: "无法找到用于展示文件夹选择器的视图控制器",
          details: nil
        ))
        return
      }

      self.pendingPickerResult = result

      let picker: UIDocumentPickerViewController
      if #available(iOS 14.0, *) {
        picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
      } else {
        picker = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
      }
      picker.delegate = self
      picker.allowsMultipleSelection = false
      topVC.present(picker, animated: true, completion: nil)
    }
  }

  // MARK: - UIDocumentPickerDelegate

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let result = pendingPickerResult else { return }
    pendingPickerResult = nil

    guard let url = urls.first else {
      result(nil)
      return
    }

    // 在选定回调中，url 拥有临时安全访问权限，但创建持久 bookmark 时需保证处于访问作用域内
    let accessing = url.startAccessingSecurityScopedResource()
    defer {
      if accessing {
        url.stopAccessingSecurityScopedResource()
      }
    }

    do {
      let bookmarkData = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      let bookmarkBase64 = bookmarkData.base64EncodedString()
      let displayName = FileManager.default.displayName(atPath: url.path)

      result([
        "path": url.path,
        "bookmark": bookmarkBase64,
        "displayName": displayName.isEmpty ? url.lastPathComponent : displayName,
      ])
    } catch {
      result(FlutterError(
        code: "BOOKMARK_CREATION_FAILED",
        message: "创建 Security-Scoped Bookmark 失败: \(error.localizedDescription)",
        details: nil
      ))
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    guard let result = pendingPickerResult else { return }
    pendingPickerResult = nil
    result(nil)
  }

  // MARK: - Bookmark Operations

  private func resolveBookmark(bookmark: String, result: @escaping FlutterResult) {
    guard let data = Data(base64Encoded: bookmark) else {
      result(nil)
      return
    }

    var isStale = false
    do {
      let url = try URL(
        resolvingBookmarkData: data,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      var response: [String: Any] = [
        "path": url.path,
        "stale": isStale,
      ]

      if isStale {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
          if accessing {
            url.stopAccessingSecurityScopedResource()
          }
        }
        if let newBookmarkData = try? url.bookmarkData(
          options: .withSecurityScope,
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        ) {
          response["bookmark"] = newBookmarkData.base64EncodedString()
        }
      }

      result(response)
    } catch {
      result(nil)
    }
  }

  private func startAccess(bookmark: String) -> Bool {
    lock.lock()
    defer { lock.unlock() }

    if var entry = activeAccessEntries[bookmark] {
      entry.count += 1
      activeAccessEntries[bookmark] = entry
      return true
    }

    guard let data = Data(base64Encoded: bookmark) else {
      return false
    }

    var isStale = false
    do {
      let url = try URL(
        resolvingBookmarkData: data,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      if url.startAccessingSecurityScopedResource() {
        activeAccessEntries[bookmark] = AccessEntry(url: url, count: 1)
        return true
      }
    } catch {
      print("LocalFolderPickerPlugin: startAccess 失败: \(error)")
    }
    return false
  }

  private func stopAccess(bookmark: String) -> Bool {
    lock.lock()
    defer { lock.unlock() }

    guard var entry = activeAccessEntries[bookmark] else {
      return false
    }

    entry.count -= 1
    if entry.count <= 0 {
      activeAccessEntries.removeValue(forKey: bookmark)
      entry.url.stopAccessingSecurityScopedResource()
    } else {
      activeAccessEntries[bookmark] = entry
    }
    return true
  }

  // MARK: - UI Helpers

  private func topViewController() -> UIViewController? {
    let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let activeScene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
    let window = activeScene?.windows.first { $0.isKeyWindow } ?? activeScene?.windows.first
    var topController = window?.rootViewController
    while let presented = topController?.presentedViewController {
      topController = presented
    }
    return topController
  }
}
