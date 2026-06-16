import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 跨平台「系统通知」服务。
///
/// 平台路由：Windows 使用 [local_notifier]；其余平台（Android / iOS / macOS /
/// Linux）使用 [flutter_local_notifications]。每个平台分支都用 [GetPlatform] 守卫，
/// 保证不会在缺少实现的平台上调用对应插件而抛出 MissingPluginException。
///
/// 仅负责「弹出系统通知 + 点击跳转」。是否要弹（用户开关）由调用方
/// （DownloadService 的派发逻辑）统一把控；此处再做一层防御性判断。
class DownloadNotificationService extends GetxService {
  static DownloadNotificationService get to =>
      Get.find<DownloadNotificationService>();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'download_status';

  bool _initialized = false;

  /// Android：本会话是否已发起过通知权限请求，避免每次通知都弹框打扰。
  bool _androidPermissionAsked = false;

  bool get _useLocalNotifier => GetPlatform.isWindows;

  @override
  void onInit() {
    super.onInit();
    // 初始化是异步的，不阻塞启动；失败不影响应用其他功能。
    init();
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      if (_useLocalNotifier) {
        // Windows：local_notifier 需要先 setup（注册开始菜单快捷方式以投递 toast）。
        await localNotifier.setup(
          appName: 'LoveIwara',
          shortcutPolicy: ShortcutPolicy.requireCreate,
        );
      } else {
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        // iOS / macOS 启动时不请求权限，改为用户开启开关时再请求。
        const darwinInit = DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
        const linuxInit = LinuxInitializationSettings(
          defaultActionName: 'Open',
        );
        const settings = InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
          macOS: darwinInit,
          linux: linuxInit,
        );
        await _fln.initialize(
          settings: settings,
          onDidReceiveNotificationResponse: _onTap,
        );
        await _ensureAndroidChannel();
        // 冷启动：进程此前被杀，点击通知不会触发 onTap，需主动查询启动详情。
        await _handleNotificationLaunch();
      }
      _initialized = true;
    } catch (e) {
      LogUtils.e('初始化下载通知服务失败', tag: 'DownloadNotificationService', error: e);
    }
  }

  Future<void> _ensureAndroidChannel() async {
    if (!GetPlatform.isAndroid) return;
    final androidImpl = _fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;
    final channel = AndroidNotificationChannel(
      _androidChannelId,
      slang.t.downloadNotifications.channelName,
      description: slang.t.downloadNotifications.channelDescription,
      importance: Importance.defaultImportance,
    );
    await androidImpl.createNotificationChannel(channel);
  }

  /// Android 弹通知前确保已有权限：已授权直接放行；未授权则本会话仅请求一次，
  /// 之后（用户拒绝/永久拒绝）不再打扰，避免每次下载完成都弹框。
  Future<bool> _ensureAndroidPermission() async {
    if (!Get.isRegistered<PermissionService>()) return true;
    final ps = Get.find<PermissionService>();
    if (await ps.hasNotificationPermission()) return true;
    if (_androidPermissionAsked) return false;
    _androidPermissionAsked = true;
    return ps.requestNotificationPermission();
  }

  /// 请求通知权限。
  /// - Android 13+：经 [PermissionService] 走 permission_handler。
  /// - iOS / macOS：经插件请求。
  /// - Windows / Linux：无需运行时权限，直接返回 true。
  Future<bool> requestPermission() async {
    try {
      if (GetPlatform.isAndroid) {
        if (Get.isRegistered<PermissionService>()) {
          return Get.find<PermissionService>().requestNotificationPermission();
        }
        return true;
      }
      if (GetPlatform.isIOS) {
        final impl = _fln.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await impl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
      if (GetPlatform.isMacOS) {
        final impl = _fln.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
        final granted = await impl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
      // Windows / Linux
      return true;
    } catch (e) {
      LogUtils.e('请求通知权限失败', tag: 'DownloadNotificationService', error: e);
      return false;
    }
  }

  /// 下载完成系统通知。
  Future<void> showDownloadComplete({
    required String taskId,
    required String title,
  }) async {
    await _show(
      taskId: taskId,
      title: slang.t.downloadNotifications.completedTitle,
      body: slang.t.downloadNotifications.completedBody(name: title),
    );
  }

  /// 下载失败系统通知。
  Future<void> showDownloadFailed({
    required String taskId,
    required String title,
    String? error,
  }) async {
    final base = slang.t.downloadNotifications.failedBody(name: title);
    final trimmedError = error?.trim() ?? '';
    // 限制错误信息长度，避免过长的本地化错误把通知撑爆。
    final shortError = trimmedError.length > 120
        ? '${trimmedError.substring(0, 120)}…'
        : trimmedError;
    final body = shortError.isNotEmpty ? '$base · $shortError' : base;
    await _show(
      taskId: taskId,
      title: slang.t.downloadNotifications.failedTitle,
      body: body,
    );
  }

  Future<void> _show({
    required String taskId,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }
    try {
      if (_useLocalNotifier) {
        final notification = LocalNotification(title: title, body: body);
        notification.onClick = () => _navigateWhenReady(Routes.DOWNLOAD_TASK_LIST);
        await notification.show();
        return;
      }

      // Android 13+：通知默认开启但需运行时权限。开关默认开，用户可能从未进过
      // 设置页，故首次实际要弹通知时若未授权则在此就地请求一次（in-context）。
      if (GetPlatform.isAndroid && !await _ensureAndroidPermission()) {
        return;
      }

      final id = taskId.hashCode & 0x7fffffff;
      // 渠道名/描述用本地化文案（Android O+ 以渠道为准，pre-O 用此处作为兜底）。
      final androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        slang.t.downloadNotifications.channelName,
        channelDescription: slang.t.downloadNotifications.channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const darwinDetails = DarwinNotificationDetails();
      const linuxDetails = LinuxNotificationDetails();
      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: linuxDetails,
      );
      await _fln.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: Routes.DOWNLOAD_TASK_LIST,
      );
    } catch (e) {
      LogUtils.e('展示下载系统通知失败', tag: 'DownloadNotificationService', error: e);
    }
  }

  /// 处理「应用被通知点击冷启动」的情况：进程此前已终止时，点击不会触发
  /// [onDidReceiveNotificationResponse]，需主动查询启动详情并在路由就绪后跳转。
  Future<void> _handleNotificationLaunch() async {
    try {
      final details = await _fln.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        final payload = details?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          // 不 await：冷启动时路由可能尚未挂载，交由 _navigateWhenReady 重试。
          _navigateWhenReady(payload);
        }
      }
    } catch (e) {
      LogUtils.w('处理通知冷启动跳转失败: $e', 'DownloadNotificationService');
    }
  }

  void _onTap(NotificationResponse response) {
    _navigateWhenReady(response.payload ?? Routes.DOWNLOAD_TASK_LIST);
  }

  /// 在全局路由就绪后跳转。应用已在运行时首次即命中；冷启动时 navigator 可能
  /// 尚未挂载，做有界重试（最多约 6s）。
  Future<void> _navigateWhenReady(String route) async {
    for (var i = 0; i < 40; i++) {
      if (rootNavigatorKey.currentContext != null) {
        _pushDedup(route);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
    LogUtils.w('路由长时间未就绪，放弃下载通知跳转: $route', 'DownloadNotificationService');
  }

  void _pushDedup(String route) {
    try {
      // 已在目标页则不重复入栈，避免多次点击堆叠同一路由。
      if (_currentLocation() == route) return;
      appRouter.push(route);
    } catch (e) {
      LogUtils.w('处理下载通知点击跳转失败: $e', 'DownloadNotificationService');
    }
  }

  String _currentLocation() {
    try {
      return appRouter.routerDelegate.currentConfiguration.uri.path;
    } catch (_) {
      return '';
    }
  }
}
