import Flutter
import UIKit
import MediaPlayer

/// UIScene 生命周期下的应用代理。
///
/// 迁移要点（Flutter 3.47 / Xcode 27 起强制）：
/// - 插件注册与应用级 MethodChannel 不再放在 didFinishLaunchingWithOptions，
///   而是在隐式引擎就绪的 didInitializeImplicitFlutterEngine 回调里创建；
/// - AppDelegate 不再持有 window，任何需要 window / rootViewController 的逻辑
///   都要在场景层解析（见 activeWindow）或移到 SceneDelegate；
/// - 打开文件的回调迁到 SceneDelegate 的 scene(_:openURLContexts:)。
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// 供 SceneDelegate 回调转发（打开文件等场景级事件）。
  static private(set) weak var current: AppDelegate?

  private var volumeKeyEnabled = false
  private var volumeView: MPVolumeView?
  private var channel: FlutterMethodChannel?
  private var previousVolume: Float = 0.0
  private var audioSession: AVAudioSession?

  // 文件处理 MethodChannel
  private var fileHandlerChannel: FlutterMethodChannel?
  private var deviceFormFactorChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    AppDelegate.current = self
    // 插件注册与通道创建已移至 didInitializeImplicitFlutterEngine。
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - FlutterImplicitEngineDelegate

  /// 隐式 FlutterEngine 初始化完成后回调，此时才能取到可用的 binaryMessenger。
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()

    channel = FlutterMethodChannel(name: "i_iwara/volume_key", binaryMessenger: messenger)

    fileHandlerChannel = FlutterMethodChannel(
      name: "com.example.i_iwara/file_handler",
      binaryMessenger: messenger
    )
    deviceFormFactorChannel = FlutterMethodChannel(
      name: "i_iwara/device_form_factor",
      binaryMessenger: messenger
    )

    channel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "enableVolumeKeyListener":
        self?.enableVolumeKeyListener()
        result(nil)
      case "disableVolumeKeyListener":
        self?.disableVolumeKeyListener()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    deviceFormFactorChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "getDeviceFormFactorInfo":
        result(self?.deviceFormFactorInfo())
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }

  // MARK: - 场景事件转发

  /// 由 SceneDelegate 在 scene(_:openURLContexts:) 中调用。
  func notifyFileOpened(url: URL) {
    print("AppDelegate: 收到文件打开请求: \(url.absoluteString)")
    fileHandlerChannel?.invokeMethod("onFileOpened", arguments: url.absoluteString)
  }

  /// UIScene 下 AppDelegate 不再持有 window，按需从当前活跃场景解析。
  private var activeWindow: UIWindow? {
    let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let activeScene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
    return activeScene?.windows.first { $0.isKeyWindow } ?? activeScene?.windows.first
  }

  // MARK: - 音量键监听

  private func enableVolumeKeyListener() {
    volumeKeyEnabled = true

    // 初始化音频会话
    audioSession = AVAudioSession.sharedInstance()
    try? audioSession?.setActive(true)
    previousVolume = audioSession?.outputVolume ?? 0.0

    // 创建并配置隐藏的音量视图
    volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
    volumeView?.isHidden = true
    if let volumeView = volumeView {
      activeWindow?.rootViewController?.view.addSubview(volumeView)
    }

    // 添加音量变化通知监听
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(volumeDidChange),
      name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
      object: nil
    )
  }

  private func disableVolumeKeyListener() {
    volumeKeyEnabled = false
    volumeView?.removeFromSuperview()
    volumeView = nil
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func volumeDidChange(_ notification: NSNotification) {
    guard volumeKeyEnabled,
          let userInfo = notification.userInfo,
          let volumeValue = userInfo["AVSystemController_AudioVolumeNotificationParameter"] as? Float else {
      return
    }

    // 判断音量变化方向
    if volumeValue > previousVolume {
      channel?.invokeMethod("onVolumeKeyUp", arguments: nil)
    } else if volumeValue < previousVolume {
      channel?.invokeMethod("onVolumeKeyDown", arguments: nil)
    }

    // 重置音量到原始值
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      try? self?.audioSession?.setActive(true)
      let volumeView = MPVolumeView()
      if let slider = volumeView.subviews.first as? UISlider {
        slider.value = self?.previousVolume ?? 0.5
      }
    }
  }

  private func deviceFormFactorInfo() -> [String: Any] {
    let isTablet = UIDevice.current.userInterfaceIdiom == .pad
    return [
      "platformIsTablet": isTablet,
      "model": UIDevice.current.model,
      "source": "ios_user_interface_idiom"
    ]
  }
}
