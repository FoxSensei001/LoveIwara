import Flutter
import UIKit
import MediaPlayer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var volumeKeyEnabled = false
  private var volumeView: MPVolumeView?
  private var channel: FlutterMethodChannel?
  private var previousVolume: Float = 0.0
  private var audioSession: AVAudioSession?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    channel = FlutterMethodChannel(name: "i_iwara/volume_key",
                                 binaryMessenger: controller.binaryMessenger)
    
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
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
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
      window?.rootViewController?.view.addSubview(volumeView)
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
}
