import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:i_iwara/app/models/iwara_status.model.dart';
import 'package:i_iwara/app/repositories/commons_repository.dart';
import 'package:i_iwara/app/services/iwara_status_client.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 服务器测速结果
class ServerSpeedTestResult {
  final String serverName;
  final int? latencyMs; // null 表示测试失败
  final bool isReachable;
  final String? errorMessage;
  final DateTime? testTime; // 测速时间

  const ServerSpeedTestResult({
    required this.serverName,
    this.latencyMs,
    required this.isReachable,
    this.errorMessage,
    this.testTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'serverName': serverName,
      'latencyMs': latencyMs,
      'isReachable': isReachable,
      'errorMessage': errorMessage,
      'testTime': testTime?.toIso8601String(),
    };
  }

  factory ServerSpeedTestResult.fromJson(Map<String, dynamic> json) {
    return ServerSpeedTestResult(
      serverName: json['serverName'] as String,
      latencyMs: json['latencyMs'] as int?,
      isReachable: json['isReachable'] as bool,
      errorMessage: json['errorMessage'] as String?,
      testTime: json['testTime'] != null ? DateTime.parse(json['testTime'] as String) : null,
    );
  }

  @override
  String toString() {
    if (isReachable && latencyMs != null) {
      return '$serverName: ${latencyMs}ms';
    } else {
      return '$serverName: 不可达 ${errorMessage ?? ''}';
    }
  }
}

/// Iwara 服务器管理服务
class IwaraServerService extends GetxService {
  static const String _fastServerListKey = 'iwara_fast_server_list';
  static const String _fastServerLastSyncTimeKey = 'iwara_fast_server_last_sync_time';
  static const String _speedTestResultsKey = 'iwara_speed_test_results';
  
  final CommonsRepository _repository = CommonsRepository.instance;
  final IwaraStatusClient _client = IwaraStatusClient();
  
  final RxList<IwaraServer> servers = <IwaraServer>[].obs;
  final Rx<IwaraStatusPage?> statusPage = Rx<IwaraStatusPage?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, ServerSpeedTestResult> speedTestResults = <String, ServerSpeedTestResult>{}.obs;
  // 正在测速的服务器名称集合
  final RxSet<String> testingServerNames = <String>{}.obs;
  // 快速环服务器名称集合（用于判断哪些服务器需要保存测速结果）
  final Set<String> _fastRingServerNames = {};
  
  // 定时刷新定时器
  Timer? _periodicRefreshTimer;
  // 定时刷新间隔（默认5分钟）
  static const Duration _refreshInterval = Duration(minutes: 5);
  
  /// 格式化服务器地址
  /// 将服务器名称格式化为完整的 HTTPS URL
  static String formatServerUrl(String serverName) {
    return CommonUtils.normalizeUrl(serverName) ?? 'https://$serverName';
  }
  
  /// 获取快速环服务器名称集合（只读）
  Set<String> get fastRingServerNames => Set.unmodifiable(_fastRingServerNames);
  
  /// 获取快速环服务器列表（过滤后）
  List<IwaraServer> get fastRingServers => 
      servers.where((s) => _fastRingServerNames.contains(s.name)).toList();
  
  /// 检查服务器是否在快速环中且可达
  bool isServerInFastRingAndReachable(String serverName) {
    if (!_fastRingServerNames.contains(serverName)) return false;
    final result = speedTestResults[serverName];
    return result != null && result.isReachable;
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
    
    // 2. 加载历史测速结果
    await _loadSpeedTestResultsFromDatabase();
    
    // 3. 如果有服务器但没有测速结果，自动测速
    if (servers.isNotEmpty) {
      final serversNeedTest = servers.where((server) {
        return !speedTestResults.containsKey(server.name);
      }).toList();
      
      if (serversNeedTest.isNotEmpty) {
        LogUtils.i('发现 ${serversNeedTest.length} 个未测速的服务器，开始自动测速', 'IwaraServerService');
        // 异步执行，不阻塞初始化
        unawaited(testServersSpeed(targetServers: serversNeedTest, saveToDatabase: true));
      }
    }
  }

  /// 从数据库加载服务器列表
  Future<void> _loadServersFromDatabase() async {
    try {
      final data = await _repository.getData(_fastServerListKey);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(data);
        final loadedServers = jsonList
            .map((json) => IwaraServer.fromJson(json as Map<String, dynamic>))
            .toList();
        servers.value = loadedServers;
        
        // 更新快速环服务器名称集合（数据库中存储的就是快速环的服务器）
        _fastRingServerNames.clear();
        _fastRingServerNames.addAll(loadedServers.map((s) => s.name));
        
        LogUtils.i('从数据库加载了 ${servers.length} 个快速环服务器', 'IwaraServerService');
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
      await _repository.setData(_fastServerListKey, jsonString);
      
      // 保存同步时间
      await _repository.setData(_fastServerLastSyncTimeKey, DateTime.now().toIso8601String());
      
      LogUtils.i('保存了 ${serverList.length} 个服务器到数据库', 'IwaraServerService');
    } catch (e) {
      LogUtils.e('保存服务器列表到数据库失败', error: e, tag: 'IwaraServerService');
    }
  }

  /// 从数据库加载测速结果
  Future<void> _loadSpeedTestResultsFromDatabase() async {
    try {
      final data = await _repository.getData(_speedTestResultsKey);
      if (data != null && data.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(data);
        final results = <String, ServerSpeedTestResult>{};
        
        jsonMap.forEach((key, value) {
          try {
            results[key] = ServerSpeedTestResult.fromJson(value as Map<String, dynamic>);
          } catch (e) {
            LogUtils.w('解析测速结果失败: $key', 'IwaraServerService');
          }
        });
        
        speedTestResults.value = results;
        LogUtils.i('从数据库加载了 ${results.length} 个测速结果', 'IwaraServerService');
      }
    } catch (e) {
      LogUtils.e('从数据库加载测速结果失败', error: e, tag: 'IwaraServerService');
    }
  }

  /// 保存测速结果到数据库（仅保存快速环的服务器）
  Future<void> _saveSpeedTestResultsToDatabase() async {
    try {
      final jsonMap = <String, dynamic>{};
      int savedCount = 0;
      
      speedTestResults.forEach((key, value) {
        // 只保存快速环的服务器测速结果
        if (_fastRingServerNames.contains(key)) {
          jsonMap[key] = value.toJson();
          savedCount++;
        }
      });
      
      final jsonString = jsonEncode(jsonMap);
      await _repository.setData(_speedTestResultsKey, jsonString);
      
      LogUtils.d('保存了 $savedCount 个快速环测速结果到数据库（总共 ${speedTestResults.length} 个结果）', 'IwaraServerService');
    } catch (e) {
      LogUtils.e('保存测速结果到数据库失败', error: e, tag: 'IwaraServerService');
    }
  }

  /// 获取上次同步时间
  Future<DateTime?> getLastSyncTime() async {
    try {
      final data = await _repository.getData(_fastServerLastSyncTimeKey);
      if (data != null && data.isNotEmpty) {
        return DateTime.parse(data);
      }
    } catch (e) {
      LogUtils.e('获取上次同步时间失败', error: e, tag: 'IwaraServerService');
    }
    return null;
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

      // 更新快速环服务器名称集合
      _fastRingServerNames.clear();
      _fastRingServerNames.addAll(pageData.fastRing.servers.map((s) => s.name));
      LogUtils.d('快速环服务器: ${_fastRingServerNames.join(", ")}', 'IwaraServerService');

      // 同步到数据库并测速
      await _syncServersAndTestSpeed(pageData.fastRing.servers);
      
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

  /// 同步到数据库并测速
  Future<void> _syncServersAndTestSpeed(List<IwaraServer> newServers) async {
    try {
      LogUtils.i('开始同步 ${newServers.length} 个服务器到数据库', 'IwaraServerService');
      
      // 直接保存完整的新列表到数据库
      await _saveServersToDatabase(newServers);
      
      // 对所有服务器自动测速
      LogUtils.i('同步完成，开始对所有服务器进行测速', 'IwaraServerService');
      unawaited(testServersSpeed(targetServers: newServers, saveToDatabase: true));
    } catch (e) {
      LogUtils.e('同步服务器到数据库并测速失败', error: e, tag: 'IwaraServerService');
      rethrow;
    }
  }

  /// 测试单个服务器的速度
  Future<ServerSpeedTestResult> testServerSpeed(IwaraServer server) async {
    final serverUrl = formatServerUrl(server.name);
    
    try {
      LogUtils.d('开始测速: $serverUrl', 'IwaraServerService');
      
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 5),
        // 允许所有状态码，只要服务器有响应就算成功
        validateStatus: (status) => true,
      ));

      final stopwatch = Stopwatch()..start();
      
      // 使用 HEAD 请求减少数据传输
      Response? response;
      try {
        response = await dio.head(serverUrl);
      } catch (e) {
        // 某些服务器不支持 HEAD 请求，尝试 GET
        // 或者处理其他可能的网络层面的异常
        // 但这里我们主要依赖 try-catch 外层的处理，这里 catch 只是为了不中断 stopwatch 哪怕失败太快
      }
      
      stopwatch.stop();
      final latencyMs = stopwatch.elapsedMilliseconds;

      dio.close();

      // 只要有响应状态码，说明服务器是活的，网络是通的
      if (response != null && response.statusCode != null) {
        // 对于 404/403 等状态码，也认为是成功的，因为我们要测的是"连通性"
        // LogUtils.d('测速成功: $serverUrl - ${latencyMs}ms (Status: ${response.statusCode})', 'IwaraServerService');
        return ServerSpeedTestResult(
          serverName: server.name,
          latencyMs: latencyMs,
          isReachable: true,
        );
      } else {
        LogUtils.w('测速失败: $serverUrl - 无响应', 'IwaraServerService');
        return ServerSpeedTestResult(
          serverName: server.name,
          isReachable: false,
          errorMessage: '无响应',
        );
      }
    } on DioException catch (e) {
      String errorMsg = 'Unknown error';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMsg = 'Timeout';
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'Connection failed'; // e.g., DNS resolution failed, connection refused
          break;
        case DioExceptionType.badCertificate:
          errorMsg = 'Bad certificate';
          break;
        case DioExceptionType.cancel:
          errorMsg = 'Canceled';
          break;
        // badResponse will not be triggered here because validateStatus is set to always true
        default:
          errorMsg = e.message ?? 'Unknown error';
      }
      
      LogUtils.w('测速异常: $serverUrl - $errorMsg', 'IwaraServerService');
      return ServerSpeedTestResult(
        serverName: server.name,
        isReachable: false,
        errorMessage: errorMsg,
      );
    } catch (e) {
      LogUtils.e('测速异常: $serverUrl', error: e, tag: 'IwaraServerService');
      return ServerSpeedTestResult(
        serverName: server.name,
        isReachable: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 批量测试指定服务器列表的速度
  /// 如果 [targetServers] 为空，则测试所有服务器
  /// [saveToDatabase] 是否保存测速结果到数据库
  Future<void> testServersSpeed({
    List<IwaraServer>? targetServers,
    Function(int current, int total)? onProgress,
    bool saveToDatabase = false,
  }) async {
    final serversToTest = targetServers ?? servers;
    
    if (serversToTest.isEmpty) {
      LogUtils.w('服务器列表为空，无法测速', 'IwaraServerService');
      return;
    }
    
    LogUtils.i('开始批量测速，共 ${serversToTest.length} 个服务器', 'IwaraServerService');
    
    // 1. 标记这些服务器为正在测速状态
    // 2. 清除旧的测速结果
    for (var server in serversToTest) {
      testingServerNames.add(server.name);
      speedTestResults.remove(server.name);
    }
    
    int current = 0;
    final total = serversToTest.length;

    // 使用并发控制，避免同时发起过多请求
    const concurrency = 30; // 同时测试30个服务器（提高测速速度）
    final chunks = <List<IwaraServer>>[];
    
    for (var i = 0; i < serversToTest.length; i += concurrency) {
      final end = (i + concurrency < serversToTest.length) ? i + concurrency : serversToTest.length;
      chunks.add(serversToTest.sublist(i, end));
    }

    for (final chunk in chunks) {
      final futures = chunk.map((server) async {
        try {
          final result = await testServerSpeed(server);
          // 添加时间戳
          final resultWithTime = ServerSpeedTestResult(
            serverName: result.serverName,
            latencyMs: result.latencyMs,
            isReachable: result.isReachable,
            errorMessage: result.errorMessage,
            testTime: DateTime.now(),
          );
          speedTestResults[resultWithTime.serverName] = resultWithTime;
          return resultWithTime;
        } finally {
          // 测速完成（无论成功失败），移除测试状态
          testingServerNames.remove(server.name);
        }
      });
      
      final results = await Future.wait(futures);
      
      for (final _ in results) {
        current++;
        onProgress?.call(current, total);
      }
      
      // 移除批次间延迟，加快测速速度
      // if (chunk != chunks.last) {
      //   await Future.delayed(const Duration(milliseconds: 200));
      // }
    }

    LogUtils.i('批量测速完成', 'IwaraServerService');
    
    // 保存到数据库
    if (saveToDatabase) {
      await _saveSpeedTestResultsToDatabase();
    }
  }

  /// 获取最快的服务器
  List<ServerSpeedTestResult> getFastestServers({int limit = 10}) {
    final reachableResults = speedTestResults.values
        .where((result) => result.isReachable && result.latencyMs != null)
        .toList();
    
    reachableResults.sort((a, b) => a.latencyMs!.compareTo(b.latencyMs!));
    
    return reachableResults.take(limit).toList();
  }

  /// 清除测速结果
  void clearSpeedTestResults() {
    speedTestResults.clear();
  }

  /// 保存单个测速结果并持久化到数据库
  Future<void> saveSpeedTestResult(ServerSpeedTestResult result) async {
    speedTestResults[result.serverName] = result;
    await _saveSpeedTestResultsToDatabase();
  }

  /// 获取延迟最低的可达服务器名称（用于 CDN 策略）
  String? getFastestReachableServer() {
    final reachableResults = speedTestResults.values
        .where((result) => result.isReachable && result.latencyMs != null)
        .toList();
    
    if (reachableResults.isEmpty) return null;
    
    reachableResults.sort((a, b) => a.latencyMs!.compareTo(b.latencyMs!));
    
    return reachableResults.first.serverName;
  }

  /// 启动定时刷新任务
  /// 每隔 [_refreshInterval] 时间自动刷新快速环服务器列表并测速
  void startPeriodicRefresh() {
    // 如果已经有定时器在运行，先取消
    _periodicRefreshTimer?.cancel();
    
    LogUtils.i('启动定时刷新任务，间隔: ${_refreshInterval.inMinutes} 分钟', 'IwaraServerService');
    
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
      
      // 2. 对快速环服务器进行测速
      if (fastRingServers.isNotEmpty) {
        LogUtils.i('定时任务：开始对 ${fastRingServers.length} 个快速环服务器进行测速', 'IwaraServerService');
        await testServersSpeed(
          targetServers: fastRingServers,
          saveToDatabase: true,
        );
        LogUtils.i('定时任务：测速完成', 'IwaraServerService');
      } else {
        LogUtils.w('定时任务：没有快速环服务器需要测速', 'IwaraServerService');
      }
    } catch (e) {
      LogUtils.e('定时刷新任务执行失败', error: e, tag: 'IwaraServerService');
    }
  }
}

