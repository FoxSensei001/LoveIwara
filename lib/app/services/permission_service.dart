import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 往某个目录里写文件，要先拿到哪一档存储权限（只有 Android 有这回事）。
///
/// 三档而不是「要不要权限」一个布尔：
///   - [none]：不用任何权限。App 自己的专属目录；以及 Android 11+ 上公共
///     `Download/` 之下——分区存储允许任何 App 不申请权限就在那里建子目录、写
///     **自己的**文件（写别人留下的同名文件会 EACCES，那是 probe 的事）。
///   - [legacyStorage]：Android 10 及以下的普通存储权限（WRITE_EXTERNAL_STORAGE；
///     Android 10 还要靠清单里的 requestLegacyExternalStorage 退回旧行为）。
///   - [allFilesAccess]：Android 11+ 写 `Download/` 以外的共享存储（自建目录、
///     SD 卡……）要的「所有文件访问」（MANAGE_EXTERNAL_STORAGE）。
enum StorageAccessNeed { none, legacyStorage, allFilesAccess }

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

  /// MediaStore 只需要媒体读取权限，不需要「所有文件访问」。
  /// Android 14 的部分授权用 [PermissionStatus.limited] 也可以查询到一部分媒体，
  /// 因此调用方应把 granted 和 limited 都当作可用。
  Future<Permission> _mediaStorePermission() async {
    final sdkInt = await _getAndroidVersion();
    return sdkInt >= 33 ? Permission.videos : Permission.storage;
  }

  @override
  void onInit() {
    super.onInit();
    // 暖一下 sdkInt 缓存：getPermissionDescription 是同步的，缓存没暖上时
    // 只能退回 Android 11+ 的措辞，在 Android 10 机器上就说错了。
    unawaited(_getAndroidVersion());
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
  Future<bool> requestStoragePermission() async {
    try {
      if (!GetPlatform.isAndroid) {
        // 其他平台默认有权限
        return true;
      }

      final permission = await _storagePermission();
      if (await permission.isGranted) return true;

      // MANAGE_EXTERNAL_STORAGE 走的是 startActivityForResult + onActivityResult
      // （permission_handler 的 PermissionManager），所以 request() 是等用户从
      // 「所有文件访问」系统页回来之后才完成的，结果就是最终状态，不用再复查。
      final status = await permission.request();
      LogUtils.d('存储权限请求结果: $status ($permission)', 'PermissionService');
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
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

  Future<bool> hasMediaStorePermission() async {
    try {
      if (!GetPlatform.isAndroid) return false;
      final permission = await _mediaStorePermission();
      final status = await permission.status;
      final available = status.isGranted || status.isLimited;
      LogUtils.d(
        'MediaStore 视频权限状态: $status (API ${await _getAndroidVersion()})',
        'PermissionService',
      );
      return available;
    } catch (e) {
      LogUtils.e('检查 MediaStore 权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  Future<bool> requestMediaStorePermission() async {
    try {
      if (!GetPlatform.isAndroid) return false;
      final permission = await _mediaStorePermission();
      final current = await permission.status;
      if (current.isGranted || current.isLimited) return true;
      final status = await permission.request();
      LogUtils.d('MediaStore 视频权限请求结果: $status', 'PermissionService');
      if (status.isPermanentlyDenied) await openAppSettings();
      return status.isGranted || status.isLimited;
    } catch (e) {
      LogUtils.e('请求 MediaStore 权限失败', tag: 'PermissionService', error: e);
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

  /// 当前 Android API level；非 Android 返回 0。
  Future<int> androidSdkInt() => _getAndroidVersion();

  /// 已经探测到的 API level（同步读，给不能 await 的判定用）；没暖上返回 null。
  int? get cachedAndroidSdkInt =>
      GetPlatform.isAndroid ? _cachedAndroidSdkInt : 0;

  /// 这一档存储权限现在有没有。[StorageAccessNeed.none] 恒为 true。
  ///
  /// 分区存储之前（API < 30）根本没有「所有文件访问」，两档都落到普通存储权限；
  /// 30 起两档也都落到 [_storagePermission]（MANAGE_EXTERNAL_STORAGE）——
  /// legacyStorage 在 30+ 上不会被判出来，这里不另开分支。
  Future<bool> hasStorageAccess(StorageAccessNeed need) async {
    if (need == StorageAccessNeed.none) return true;
    return hasStoragePermission();
  }

  /// 申请这一档存储权限，返回用户**最终**有没有给（见 [requestStoragePermission]）。
  Future<bool> requestStorageAccess(StorageAccessNeed need) async {
    if (need == StorageAccessNeed.none) return true;
    return requestStoragePermission();
  }

  /// 检查是否可以访问共享存储（公共目录、外置 SD 卡上的用户目录等）。
  ///
  /// 本 App 用绝对路径直接写共享存储（不走 SAF），所以这跟
  /// [hasStoragePermission] 是同一件事，保留独立入口只是为了调用点读起来清楚。
  Future<bool> canAccessPublicDirectories() => hasStoragePermission();
}
