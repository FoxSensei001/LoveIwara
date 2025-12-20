import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:i_iwara/app/models/iwara_status.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/iwara_server_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ServerSelectorDialog extends StatefulWidget {
  final String currentUrl;
  final Function(String newUrl, String serverName) onServerSelected;

  const ServerSelectorDialog({
    super.key,
    required this.currentUrl,
    required this.onServerSelected,
  });

  @override
  State<ServerSelectorDialog> createState() => _ServerSelectorDialogState();
}

class _ServerSelectorDialogState extends State<ServerSelectorDialog> {
  final IwaraServerService _serverService = Get.find();
  final Map<String, ServerTestResult> _testResults = {};
  bool _isRefreshing = false;
  bool _isTesting = false;
  List<ServerTestResult> _sortedServers = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadServers() async {
    if (_serverService.servers.isEmpty) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _isRefreshing = true;
      });
      await _serverService.refreshServerList();
      if (!mounted || _isDisposed) return;
      setState(() {
        _isRefreshing = false;
      });
    }
    if (!_isDisposed) {
      _startTesting();
    }
  }

  Future<void> _startTesting() async {
    if (_isTesting || !mounted || _isDisposed) return;

    setState(() {
      _isTesting = true;
      _testResults.clear();
      _sortedServers.clear();
    });

    final servers = _serverService.servers;
    if (servers.isEmpty) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _isTesting = false;
      });
      return;
    }

    LogUtils.i('开始测速 ${servers.length} 个服务器', 'ServerSelectorDialog');
    LogUtils.d('当前播放URL: ${widget.currentUrl}', 'ServerSelectorDialog');

    // 并发测试所有服务器
    final futures = servers.map((server) => _testServer(server)).toList();
    await Future.wait(futures);

    if (!mounted || _isDisposed) return;

    LogUtils.i('所有服务器测速完成', 'ServerSelectorDialog');

    // 排序：成功的在前，按延迟排序
    _sortedServers = _testResults.values.toList();
    _sortedServers.sort((a, b) {
      if (a.isSuccess && !b.isSuccess) return -1;
      if (!a.isSuccess && b.isSuccess) return 1;
      if (a.isSuccess && b.isSuccess) {
        return a.latency.compareTo(b.latency);
      }
      return 0;
    });

    setState(() {
      _isTesting = false;
    });

    LogUtils.i(
      '成功的服务器数量: ${_sortedServers.where((s) => s.isSuccess).length}',
      'ServerSelectorDialog',
    );
  }

  Future<void> _testServer(IwaraServer server) async {
    final serverName = server.name;
    final testUrl = _replaceServerInUrl(widget.currentUrl, serverName);

    if (!mounted) return;

    setState(() {
      _testResults[serverName] = ServerTestResult(
        serverName: serverName,
        isSuccess: false,
        isTesting: true,
        latency: 0,
        error: null,
      );
    });

    LogUtils.d('开始测速服务器: $serverName, URL: $testUrl', 'ServerSelectorDialog');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final cancelToken = CancelToken();
    final stopwatch = Stopwatch()..start();

    // 10s 强制超时
    final timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Timeout');
      }
    });

    try {
      // 使用 GET 请求但只请求前 1KB 的数据来测速
      final response = await dio.get(
        testUrl,
        cancelToken: cancelToken,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'Range': 'bytes=0-1023', // 只请求前 1KB
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
        onReceiveProgress: (received, total) {
          // 收到足够数据后取消请求以节省流量
          if (received >= 1024 && !cancelToken.isCancelled) {
            cancelToken.cancel(slang.t.mediaPlayer.testCompleted);
          }
        },
      );

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      final isSuccess =
          response.statusCode == 200 ||
          response.statusCode == 206 ||
          response.statusCode == 302 ||
          response.statusCode == 301;

      if (!mounted) return;

      setState(() {
        _testResults[serverName] = ServerTestResult(
          serverName: serverName,
          isSuccess: isSuccess,
          isTesting: false,
          latency: latency,
          error: isSuccess
              ? null
              : slang.t.mediaPlayer.statusCode(
                  code: response.statusCode.toString(),
                ),
        );
      });

      LogUtils.d(
        '服务器测速完成: $serverName, 延迟: ${latency}ms, 状态码: ${response.statusCode}',
        'ServerSelectorDialog',
      );
    } on DioException catch (e) {
      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      // 如果是因为测速完成而取消的请求，也算作成功
      if (e.type == DioExceptionType.cancel &&
          e.error == slang.t.mediaPlayer.testCompleted) {
        if (!mounted) {
          timeoutTimer.cancel();
          dio.close();
          return;
        }

        setState(() {
          _testResults[serverName] = ServerTestResult(
            serverName: serverName,
            isSuccess: true,
            isTesting: false,
            latency: latency,
            error: null,
          );
        });

        LogUtils.d(
          '服务器测速完成（提前取消）: $serverName, 延迟: ${latency}ms',
          'ServerSelectorDialog',
        );
        timeoutTimer.cancel();
        dio.close();
        return;
      }

      LogUtils.w('服务器测速失败: $serverName, 错误: $e', 'ServerSelectorDialog');

      if (!mounted) {
        timeoutTimer.cancel();
        dio.close();
        return;
      }

      // 判断错误类型以提供更友好的错误信息
      String errorMsg = slang.t.mediaPlayer.connectionFailed;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          (e.type == DioExceptionType.cancel && e.error == 'Timeout')) {
        errorMsg = slang.t.mediaPlayer.connectionTimeout;
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = slang.t.mediaPlayer.networkError;
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMsg = slang.t.mediaPlayer.sslError;
      } else if (e.response != null) {
        errorMsg = slang.t.mediaPlayer.statusCode(
          code: e.response?.statusCode.toString() ?? '',
        );
      }

      setState(() {
        _testResults[serverName] = ServerTestResult(
          serverName: serverName,
          isSuccess: false,
          isTesting: false,
          latency: 0,
          error: errorMsg,
        );
      });
    } catch (e) {
      stopwatch.stop();

      // 检查是否是 SSL 证书错误
      String errorMsg = slang.t.common.unknownError;
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException')) {
        errorMsg = slang.t.mediaPlayer.sslError;
      }

      LogUtils.w('服务器测速失败: $serverName, 错误: $e', 'ServerSelectorDialog');

      if (!mounted) {
        timeoutTimer.cancel();
        dio.close();
        return;
      }

      setState(() {
        _testResults[serverName] = ServerTestResult(
          serverName: serverName,
          isSuccess: false,
          isTesting: false,
          latency: 0,
          error: errorMsg,
        );
      });
    } finally {
      timeoutTimer.cancel();
      dio.close();
    }
  }

  String _replaceServerInUrl(String originalUrl, String newServerName) {
    try {
      final uri = Uri.parse(originalUrl);
      final originalHost = uri.host;
      final newUri = uri.replace(host: newServerName);
      final newUrl = newUri.toString();

      LogUtils.d(
        '替换服务器域名: $originalHost -> $newServerName\n原URL: $originalUrl\n新URL: $newUrl',
        'ServerSelectorDialog',
      );

      return newUrl;
    } catch (e) {
      LogUtils.e('替换服务器域名失败: $e', tag: 'ServerSelectorDialog', error: e);
      return originalUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Flexible(child: _buildServerList()),
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.dns, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slang.t.mediaPlayer.serverSelector,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slang.t.mediaPlayer.serverSelectorDescription,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (_isRefreshing || _isTesting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: slang.t.mediaPlayer.retestSpeed,
              onPressed: _startTesting,
            ),
        ],
      ),
    );
  }

  Widget _buildServerList() {
    if (_isRefreshing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(slang.t.mediaPlayer.loadingServerList),
          ],
        ),
      );
    }

    if (_serverService.servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(slang.t.mediaPlayer.noAvailableServers),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                if (!mounted || _isDisposed) return;
                setState(() {
                  _isRefreshing = true;
                });
                await _serverService.refreshServerList();
                if (!mounted || _isDisposed) return;
                setState(() {
                  _isRefreshing = false;
                });
                if (!_isDisposed) {
                  _startTesting();
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(slang.t.mediaPlayer.refreshServerList),
            ),
          ],
        ),
      );
    }

    // 实时排序：从当前测试结果构建列表并排序
    List<ServerTestResult> displayList = _serverService.servers.map((server) {
      return _testResults[server.name] ??
          ServerTestResult(
            serverName: server.name,
            isSuccess: false,
            isTesting: false,
            latency: 0,
            error: null,
          );
    }).toList();

    // 实时排序：成功的在前，按延迟排序；失败的在后；未测试的最后
    displayList.sort((a, b) {
      // 成功的排在前面
      if (a.isSuccess && !b.isSuccess) return -1;
      if (!a.isSuccess && b.isSuccess) return 1;

      // 都成功时，按延迟排序
      if (a.isSuccess && b.isSuccess) {
        return a.latency.compareTo(b.latency);
      }

      // 都失败时，测试中的排在有错误的前面
      if (!a.isSuccess && !b.isSuccess) {
        if (a.isTesting && !b.isTesting) return -1;
        if (!a.isTesting && b.isTesting) return 1;
      }

      return 0;
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final result = displayList[index];
        return _buildServerTile(result);
      },
    );
  }

  Widget _buildServerTile(ServerTestResult result) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    String statusText = slang.t.mediaPlayer.waitingForSpeedTest;

    if (result.isTesting) {
      statusColor = Colors.blue;
      statusIcon = Icons.sync;
      statusText = slang.t.mediaPlayer.testingSpeed;
    } else if (result.isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = '${result.latency}ms';
    } else if (result.error != null) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = slang.t.mediaPlayer.testFailed;
    }

    final bool isNarrow = MediaQuery.of(context).size.width < 450;

    return ListTile(
      dense: true,
      leading: Icon(statusIcon, color: statusColor, size: 24),
      title: Text(
        result.serverName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: (result.error != null || (isNarrow && result.isSuccess))
          ? Text(
              result.error ?? statusText,
              style: TextStyle(
                fontSize: 11,
                color: result.error != null ? Colors.red : statusColor,
                fontWeight: result.isSuccess ? FontWeight.bold : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.isTesting)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (!isNarrow && result.isSuccess)
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          if (result.isSuccess) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final newUrl = _replaceServerInUrl(
                  widget.currentUrl,
                  result.serverName,
                );
                widget.onServerSelected(newUrl, result.serverName);
                AppService.tryPop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(60, 32),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                slang.t.common.select,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              slang.t.mediaPlayer.serverCount(
                count: _serverService.servers.length,
              ),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
        ],
      ),
    );
  }
}

class ServerTestResult {
  final String serverName;
  final bool isSuccess;
  final bool isTesting;
  final int latency;
  final String? error;

  ServerTestResult({
    required this.serverName,
    required this.isSuccess,
    required this.isTesting,
    required this.latency,
    this.error,
  });
}
