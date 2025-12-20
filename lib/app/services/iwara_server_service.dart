import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_status.model.dart';
import 'package:i_iwara/app/repositories/commons_repository.dart';
import 'package:i_iwara/app/services/iwara_status_client.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// Iwara 服务器管理服务
class IwaraServerService extends GetxService {
  static const String _cdnServerListKey = 'iwara_cdn_server_list';

  final CommonsRepository _repository = CommonsRepository.instance;
  final IwaraStatusClient _client = IwaraStatusClient();

  final RxList<IwaraServer> servers = <IwaraServer>[].obs;
  final Rx<IwaraStatusPage?> statusPage = Rx<IwaraStatusPage?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 定时刷新定时器
  Timer? _periodicRefreshTimer;
  // 定时刷新间隔（默认5分钟）
  static const Duration _refreshInterval = Duration(minutes: 5);

  /// 格式化服务器地址
  /// 将服务器名称格式化为完整的 HTTPS URL
  static String formatServerUrl(String serverName) {
    return CommonUtils.normalizeUrl(serverName) ?? 'https://$serverName';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    _periodicRefreshTimer?.cancel();
    _client.close();
    super.onClose();
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    // 1. 加载服务器列表
    await _loadServersFromDatabase();
    // 2. 拉取最新的服务器列表并保存到数据库
    refreshServerList();
  }

  /// 从数据库加载服务器列表
  Future<void> _loadServersFromDatabase() async {
    try {
      final data = await _repository.getData(_cdnServerListKey);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(data);
        final loadedServers = jsonList
            .map((json) => IwaraServer.fromJson(json as Map<String, dynamic>))
            .toList();
        servers.value = loadedServers;

        LogUtils.i('从数据库加载了 ${servers.length} 个服务器', 'IwaraServerService');
      }
    } catch (e) {
      LogUtils.e('从数据库加载服务器列表失败', error: e, tag: 'IwaraServerService');
    }
  }

  /// 保存服务器列表到数据库
  Future<void> _saveServersToDatabase(List<IwaraServer> serverList) async {
    try {
      final jsonList = serverList.map((server) => server.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _repository.setData(_cdnServerListKey, jsonString);

      LogUtils.i('保存了 ${serverList.length} 个服务器到数据库', 'IwaraServerService');
    } catch (e) {
      LogUtils.e('保存服务器列表到数据库失败', error: e, tag: 'IwaraServerService');
    }
  }

  /// 从 API 刷新服务器列表
  Future<void> refreshServerList() async {
    if (isLoading.value) {
      LogUtils.w('正在刷新中，跳过重复请求', 'IwaraServerService');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      LogUtils.i('开始刷新服务器列表', 'IwaraServerService');
      final pageData = await _client.getDistributionStatus();
      statusPage.value = pageData;

      // 收集所有服务器
      final allServers = <IwaraServer>[];
      allServers.addAll(pageData.fastRing.servers);
      if (pageData.pushRing != null) {
        allServers.addAll(pageData.pushRing!.servers);
      }
      allServers.addAll(pageData.slowRing.servers);

      // 同步到数据库
      await _syncServers(allServers);

      // 更新内存中的列表
      servers.value = allServers;

      LogUtils.i('服务器列表刷新成功，共 ${allServers.length} 个服务器', 'IwaraServerService');
    } catch (e) {
      final error = e.toString();
      errorMessage.value = error;
      LogUtils.e('刷新服务器列表失败', error: e, tag: 'IwaraServerService');
    } finally {
      isLoading.value = false;
    }
  }

  /// 同步到数据库
  Future<void> _syncServers(List<IwaraServer> newServers) async {
    try {
      LogUtils.i('开始同步 ${newServers.length} 个服务器到数据库', 'IwaraServerService');

      // 直接保存完整的新列表到数据库
      await _saveServersToDatabase(newServers);
    } catch (e) {
      LogUtils.e('同步服务器到数据库失败', error: e, tag: 'IwaraServerService');
      rethrow;
    }
  }

  /// 启动定时刷新任务
  /// 每隔 [_refreshInterval] 时间自动刷新环服务器列表
  void startPeriodicRefresh() {
    // 如果已经有定时器在运行，先取消
    _periodicRefreshTimer?.cancel();

    LogUtils.i(
      '启动定时刷新任务，间隔: ${_refreshInterval.inMinutes} 分钟',
      'IwaraServerService',
    );

    _periodicRefreshTimer = Timer.periodic(_refreshInterval, (timer) {
      LogUtils.i('执行定时刷新任务', 'IwaraServerService');
      _performPeriodicRefresh();
    });
  }

  /// 停止定时刷新任务
  void stopPeriodicRefresh() {
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = null;
    LogUtils.i('停止定时刷新任务', 'IwaraServerService');
  }

  /// 执行定期刷新
  Future<void> _performPeriodicRefresh() async {
    try {
      // 1. 刷新服务器列表
      await refreshServerList();
    } catch (e) {
      LogUtils.e('定时刷新任务执行失败', error: e, tag: 'IwaraServerService');
    }
  }
}
