import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 权限管理服务
/// 处理各平台的存储权限请求和检查
class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// 检查是否有存储权限
  Future<bool> hasStoragePermission() async {
    try {
      if (GetPlatform.isAndroid) {
        // 获取Android版本
        final androidVersion = await _getAndroidVersion();
        LogUtils.d('Android版本: $androidVersion', 'PermissionService');
        
        if (androidVersion >= 30) {
          // Android 11+ (API 30+): 检查所有文件管理权限
          final hasManagePermission = await Permission.manageExternalStorage.isGranted;
          LogUtils.d('MANAGE_EXTERNAL_STORAGE权限状态: $hasManagePermission', 'PermissionService');
          return hasManagePermission;
        } else {
          // Android 10及以下: 检查传统存储权限
          final hasStoragePermission = await Permission.storage.isGranted;
          LogUtils.d('传统存储权限状态: $hasStoragePermission', 'PermissionService');
          return hasStoragePermission;
        }
      } else {
        // 其他平台默认有权限
        return true;
      }
    } catch (e) {
      LogUtils.e('检查存储权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 请求存储权限
  Future<bool> requestStoragePermission() async {
    try {
      if (GetPlatform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        
        if (androidVersion >= 30) {
          // Android 11+: 请求所有文件管理权限
          LogUtils.d('请求MANAGE_EXTERNAL_STORAGE权限', 'PermissionService');
          
          // 检查是否已经有权限
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          }
          
          // 请求权限
          final status = await Permission.manageExternalStorage.request();
          LogUtils.d('MANAGE_EXTERNAL_STORAGE权限请求结果: $status', 'PermissionService');
          
          if (status.isDenied || status.isPermanentlyDenied) {
            // 如果被拒绝，引导用户到设置页面
            LogUtils.d('权限被拒绝，尝试打开设置页面', 'PermissionService');
            return await openAppSettings();
          }
          
          return status.isGranted;
        } else {
          // Android 10及以下: 请求传统存储权限
          LogUtils.d('请求传统存储权限', 'PermissionService');
          
          final status = await Permission.storage.request();
          LogUtils.d('传统存储权限请求结果: $status', 'PermissionService');
          
          if (status.isDenied || status.isPermanentlyDenied) {
            return await openAppSettings();
          }
          
          return status.isGranted;
        }
      } else {
        // 其他平台默认有权限
        return true;
      }
    } catch (e) {
      LogUtils.e('请求存储权限失败', tag: 'PermissionService', error: e);
      return false;
    }
  }

  /// 获取权限状态详情
  Future<PermissionStatus> getStoragePermissionStatus() async {
    try {
      if (GetPlatform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        
        if (androidVersion >= 30) {
          return await Permission.manageExternalStorage.status;
        } else {
          return await Permission.storage.status;
        }
      } else {
        return PermissionStatus.granted;
      }
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

  /// 获取权限说明文本
  String getPermissionDescription() {
    if (GetPlatform.isAndroid) {
      return '为了能够将文件下载到您选择的位置，应用需要存储权限。'
          '\n\n在Android 11及以上版本中，需要授予"所有文件访问权限"才能访问公共目录（如下载文件夹）。'
          '\n\n如果不授予此权限，文件将保存到应用专用目录中。';
    } else {
      return '应用需要访问文件系统来保存下载的文件。';
    }
  }

  /// 获取权限类型说明
  Future<String> getPermissionTypeDescription() async {
    if (GetPlatform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 30) {
        return '所有文件访问权限 (Android 11+)';
      } else {
        return '存储权限 (Android 10及以下)';
      }
    } else {
      return '文件系统访问权限';
    }
  }

  /// 获取Android版本号
  Future<int> _getAndroidVersion() async {
    try {
      if (GetPlatform.isAndroid) {
        // 通过Platform.version获取Android版本
        // Platform.version格式类似: "2.8.6 (stable) (Tue Dec 10 15:26:15 2019 +0100) on android-arm64"
        // 我们需要通过其他方式获取Android API级别
        
        // 这里我们使用一个简化的方法，基于permission_handler的行为来判断
        // 如果MANAGE_EXTERNAL_STORAGE权限存在，说明是Android 11+
        try {
          await Permission.manageExternalStorage.status;
          return 30; // Android 11+
        } catch (e) {
          return 29; // Android 10及以下
        }
      }
      return 0;
    } catch (e) {
      LogUtils.e('获取Android版本失败', tag: 'PermissionService', error: e);
      return 29; // 默认返回Android 10
    }
  }

  /// 检查是否需要显示权限说明
  Future<bool> shouldShowPermissionRationale() async {
    try {
      if (GetPlatform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        
        if (androidVersion >= 30) {
          return await Permission.manageExternalStorage.shouldShowRequestRationale;
        } else {
          return await Permission.storage.shouldShowRequestRationale;
        }
      }
      return false;
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
      default:
        return '未知状态';
    }
  }

  /// 检查是否可以访问公共目录
  Future<bool> canAccessPublicDirectories() async {
    if (!GetPlatform.isAndroid) {
      return true; // 非Android平台默认可以访问
    }
    
    final androidVersion = await _getAndroidVersion();
    if (androidVersion >= 30) {
      // Android 11+需要MANAGE_EXTERNAL_STORAGE权限
      return await Permission.manageExternalStorage.isGranted;
    } else {
      // Android 10及以下需要传统存储权限
      return await Permission.storage.isGranted;
    }
  }
}
