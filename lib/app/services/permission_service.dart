import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 权限管理服务
/// 处理各平台的存储权限请求和检查
class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// 本进程内缓存的 Android API level（0 表示尚未探测 / 非 Android）。
  static int? _cachedAndroidSdkInt;

  /// 当前平台该用哪个存储权限。
  ///
  /// Android 11+ 走 MANAGE_EXTERNAL_STORAGE（本 App 直接用绝对路径写共享存储，
  /// 不走 SAF，所以要的是「所有文件访问」）；Android 10 及以下走传统存储权限。
  Future<Permission> _storagePermission() async {
    final sdkInt = await _getAndroidVersion();
    return sdkInt >= 30 ? Permission.manageExternalStorage : Permission.storage;
  }

  /// 检查是否有存储权限
  Future<bool> hasStoragePermission() async {
    try {
      if (!GetPlatform.isAndroid) {
        // 其他平台默认有权限
        return true;
      }
      final permission = await _storagePermission();
      final granted = await permission.isGranted;
      LogUtils.d(
        '存储权限状态: $granted (API ${await _getAndroidVersion()}, $permission)',
        'PermissionService',
      );
      return granted;
    } catch (e) {
      LogUtils.e('检查存储权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 请求存储权限。
  ///
  /// ⛔ 返回值必须是「用户到底授权了没有」。历史实现在被拒后 `return await
  /// openAppSettings()`，而 openAppSettings 报的是「设置页打开成功」——于是用户
  /// 点了拒绝，调用方照样弹「授权成功」、路径修复照样报修好了。
  Future<bool> requestStoragePermission({
    bool openSettingsWhenBlocked = true,
  }) async {
    try {
      if (!GetPlatform.isAndroid) {
        // 其他平台默认有权限
        return true;
      }

      final permission = await _storagePermission();
      if (await permission.isGranted) return true;

      final status = await permission.request();
      LogUtils.d('存储权限请求结果: $status ($permission)', 'PermissionService');
      if (status.isGranted) return true;

      // MANAGE_EXTERNAL_STORAGE 是跳「所有文件访问」系统页再返回的异步流程，
      // 部分 ROM 上 request() 拿到的是跳转前的旧状态，回来后再复查一次才准。
      if (await permission.isGranted) return true;

      if (openSettingsWhenBlocked && status.isPermanentlyDenied) {
        // 只是把用户送到设置页，不能据此认为已授权。
        LogUtils.d('权限被永久拒绝，打开应用设置页', 'PermissionService');
        await openAppSettings();
      }
      return false;
    } catch (e) {
      LogUtils.e('请求存储权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 检查是否有通知权限。
  /// Android：`Permission.notification` 在 Android 13 以下系统默认授予，
  /// permission_handler 会直接返回 granted；其他平台交由各自插件处理，返回 true。
  Future<bool> hasNotificationPermission() async {
    try {
      if (GetPlatform.isAndroid) {
        return await Permission.notification.isGranted;
      }
      return true;
    } catch (e) {
      LogUtils.e('检查通知权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 请求通知权限（主要针对 Android 13+ 的 POST_NOTIFICATIONS）。
  /// Android 13 以下系统默认授予，request 会直接返回 granted；被永久拒绝时
  /// 引导用户到系统设置。其他平台返回 true（由对应插件自行请求）。
  Future<bool> requestNotificationPermission() async {
    try {
      if (GetPlatform.isAndroid) {
        if (await Permission.notification.isGranted) {
          return true;
        }
        final status = await Permission.notification.request();
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return status.isGranted;
      }
      return true;
    } catch (e) {
      LogUtils.e('请求通知权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 获取权限状态详情
  Future<PermissionStatus> getStoragePermissionStatus() async {
    try {
      if (!GetPlatform.isAndroid) {
        return PermissionStatus.granted;
      }
      return await (await _storagePermission()).status;
    } catch (e) {
      LogUtils.e('获取权限状态失败', tag: 'PermissionService', error: e);
      return PermissionStatus.denied;
    }
  }

  /// 检查权限是否被永久拒绝
  Future<bool> isStoragePermissionPermanentlyDenied() async {
    try {
      final status = await getStoragePermissionStatus();
      return status.isPermanentlyDenied;
    } catch (e) {
      LogUtils.e('检查权限永久拒绝状态失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 获取权限说明文本。
  ///
  /// ⛔ 这段文案会直接显示在下载设置页，不能写死中文（英/日界面会露馅）。
  /// 走 slang；Android 11+ 与 10- 的措辞不同，按缓存到的 sdkInt 选，
  /// 拿不到就用 11+ 的说法（多说一句「所有文件访问」不会错）。
  String getPermissionDescription() {
    final t = slang.t.settings.downloadSettings;
    final sdkInt = _cachedAndroidSdkInt;
    if (sdkInt != null && sdkInt < 30) {
      return t.storagePermissionRationaleLegacy;
    }
    return t.storagePermissionRationale;
  }

  /// 获取 Android API level。
  ///
  /// ⛔ 别再用「调某个权限的 status 会不会抛异常」来反推版本：
  /// `Permission.manageExternalStorage.status` 在 Android 10 上也不抛，
  /// 于是所有设备都被判成 API 30，Android 10 及以下会去查一个系统里根本不存在的
  /// MANAGE_EXTERNAL_STORAGE，恒为未授权 → 用户设的公共目录永远静默回落到应用
  /// 私有目录。device_info_plus 本来就是依赖，直接读真的 sdkInt。
  Future<int> _getAndroidVersion() async {
    if (!GetPlatform.isAndroid) return 0;
    final cached = _cachedAndroidSdkInt;
    if (cached != null) return cached;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final sdkInt = info.version.sdkInt;
      _cachedAndroidSdkInt = sdkInt;
      return sdkInt;
    } catch (e) {
      LogUtils.e('获取Android版本失败', tag: 'PermissionService', error: e);
      // 拿不到就按最新行为处理：宁可多要一次「所有文件访问」，也不要在
      // Android 11+ 上误用传统权限，那在 11+ 上是永远不够用的。
      return 30;
    }
  }

  /// 检查是否需要显示权限说明
  Future<bool> shouldShowPermissionRationale() async {
    try {
      if (!GetPlatform.isAndroid) return false;
      return await (await _storagePermission()).shouldShowRequestRationale;
    } catch (e) {
      LogUtils.e('检查权限说明显示状态失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 打开应用设置页面
  Future<bool> openSettings() async {
    try {
      LogUtils.d('打开应用设置页面', 'PermissionService');
      return await openAppSettings();
    } catch (e) {
      LogUtils.e('打开应用设置页面失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 获取权限状态的用户友好描述
  String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '已拒绝';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '有限授权';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.provisional:
        return '临时授权';
    }
  }

  /// 检查是否可以访问共享存储（公共目录、外置 SD 卡上的用户目录等）。
  ///
  /// 本 App 用绝对路径直接写共享存储（不走 SAF），所以这跟
  /// [hasStoragePermission] 是同一件事，保留独立入口只是为了调用点读起来清楚。
  Future<bool> canAccessPublicDirectories() => hasStoragePermission();
}
