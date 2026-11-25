# 补帧组件在 iOS / macOS 上的落点：一组预编译好的 xcframework，由 CocoaPods 嵌进
# 应用的 Frameworks/、按应用的身份签名。
#
# component/ 由同目录的 prepare_component.sh 准备（ios/Podfile、macos/Podfile 在
# pod install 时调它）；没准备出来时 Podfile 根本不引用这个 pod，应用照常构建，
# 只是不带补帧。
#
# 应用并不链接这几只 framework 里的任何符号——引擎是 Dart 侧用 dart:ffi 按路径
# 打开的（lib/app/services/frame_interp/frame_interp_component.dart）。借 CocoaPods
# 只是为了「嵌进去 + 签名」这一步。
Pod::Spec.new do |s|
  s.name             = 'FrameInterp'
  s.version          = '1.0.0'
  s.summary          = 'Offline frame interpolation engine (RIFE on ncnn + MoltenVK, FFmpeg).'
  s.description      = 'Prebuilt frame interpolation component bundled with the app.'
  s.homepage         = 'https://github.com/FoxSensei001/LoveIwara'
  s.license          = { :type => 'Mixed', :text => 'See component/licenses/' }
  s.author           = { 'LoveIwara' => 'https://github.com/FoxSensei001/LoveIwara' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.vendored_frameworks = [
    'component/FrameInterp.xcframework',
    'component/FiAvutil.xcframework',
    'component/FiSwscale.xcframework',
    'component/FiAvcodec.xcframework',
    'component/FiAvformat.xcframework',
  ]
end
