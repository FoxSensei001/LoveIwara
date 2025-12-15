import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  private var pendingUrls: [URL] = []  // 缓存待处理的 URL
  private var isFlutterReady = false   // Flutter 引擎是否准备好

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(
      name: "com.example.i_iwara/file_handler",
      binaryMessenger: controller.engine.binaryMessenger
    )

    // 监听来自 Flutter 的 ready 通知
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "ready" {
        self?.isFlutterReady = true
        // Flutter 已准备好，处理待处理的 URL
        self?.processPendingUrls()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // 延迟一段时间后处理待处理的 URL（作为备用方案）
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
      if !(self?.isFlutterReady ?? true) {
        self?.isFlutterReady = true
        self?.processPendingUrls()
      }
    }
  }

  /// 处理待处理的 URL
  private func processPendingUrls() {
    guard !pendingUrls.isEmpty else { return }

    for url in pendingUrls {
      print("AppDelegate: 处理待处理的文件: \(url.absoluteString)")
      methodChannel?.invokeMethod("onFileOpened", arguments: url.absoluteString)
    }
    pendingUrls.removeAll()
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // 处理文件打开事件（macOS 10.12+）
  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      print("AppDelegate: 收到文件打开请求: \(url.absoluteString)")

      if isFlutterReady {
        // Flutter 已准备好，直接发送
        methodChannel?.invokeMethod("onFileOpened", arguments: url.absoluteString)
      } else {
        // Flutter 未准备好，缓存 URL
        print("AppDelegate: Flutter 未准备好，缓存 URL")
        pendingUrls.append(url)
      }
    }
  }

  // 处理文件打开事件（旧版 macOS 兼容）
  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    print("AppDelegate: 收到文件打开请求（旧版）: \(filename)")

    // 将文件路径转换为 file:// URL
    let fileUrl = URL(fileURLWithPath: filename)

    if isFlutterReady {
      // Flutter 已准备好，直接发送
      methodChannel?.invokeMethod("onFileOpened", arguments: fileUrl.absoluteString)
    } else {
      // Flutter 未准备好，缓存 URL
      print("AppDelegate: Flutter 未准备好，缓存 URL（旧版）")
      pendingUrls.append(fileUrl)
    }

    return true
  }
}
