import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(
      name: "com.example.i_iwara/file_handler",
      binaryMessenger: controller.engine.binaryMessenger
    )
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
      
      // 通过 MethodChannel 将文件路径传递给 Flutter
      methodChannel?.invokeMethod("onFileOpened", arguments: url.absoluteString)
    }
  }
  
  // 处理文件打开事件（旧版 macOS 兼容）
  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    print("AppDelegate: 收到文件打开请求（旧版）: \(filename)")
    
    // 将文件路径转换为 file:// URL
    let fileUrl = URL(fileURLWithPath: filename)
    methodChannel?.invokeMethod("onFileOpened", arguments: fileUrl.absoluteString)
    
    return true
  }
}
