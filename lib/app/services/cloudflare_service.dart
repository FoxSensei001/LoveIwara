import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';


const String kFixedUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36";

class CloudflareService extends GetxService {
  final StorageService _storage = StorageService();
  static const _tag = 'CloudflareService';

  bool _isSolving = false;

  Future<Map<String, String>?> solveChallenge(BuildContext context) async {
    if (_isSolving) {
      LogUtils.w('已有一个挑战正在解决中，此次调用被忽略。', _tag);
      return null;
    }

    _isSolving = true;
    LogUtils.i('启动 Cloudflare 挑战求解器...', _tag);

    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const CloudflareChallengeDialog(),
    );

    _isSolving = false;
    if (result != null) {
      LogUtils.i('Cloudflare 挑战成功解决。', _tag);
    } else {
      LogUtils.w('Cloudflare 挑战被取消或失败。', _tag);
    }
    return result;
  }

  Future<void> saveSolution(String cfClearanceCookie, String userAgent) async {
    await _storage.writeData(KeyConstants.cfClearance, cfClearanceCookie);
    await _storage.writeData(KeyConstants.userAgent, userAgent);
    LogUtils.i('Cloudflare 解决方案已保存', _tag);
  }

  Future<Map<String, String>?> loadSolution() async {
    final cookie = await _storage.readData(KeyConstants.cfClearance) as String?;
    final userAgent = kFixedUserAgent; // 始终使用固定的 User Agent

    if (cookie != null) {
      return {'cookie': cookie, 'userAgent': userAgent};
    }
    return null;
  }
}


// --- REWRITTEN DIALOG WIDGET ---

class CloudflareChallengeDialog extends StatefulWidget {
  const CloudflareChallengeDialog({super.key});

  @override
  _CloudflareChallengeDialogState createState() =>
      _CloudflareChallengeDialogState();
}

class _CloudflareChallengeDialogState extends State<CloudflareChallengeDialog> {
  final Completer<Map<String, String>> _completer =
  Completer<Map<String, String>>();
  final CookieManager _cookieManager = CookieManager.instance();
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    // Clear cookies to ensure a fresh challenge
    _cookieManager.deleteAllCookies();
  }

  /// New logic: Check cookies from CookieManager after a page loads.
  Future<void> _checkCookieAndComplete(WebUri? url) async {
    // If already solved or URL is invalid, do nothing.
    if (_isSolved || url == null) return;

    // Get all cookies for the specific domain
    final List<Cookie> cookies = await _cookieManager.getCookies(url: url);
    final cfCookie = cookies.firstWhereOrNull((c) => c.name == 'cf_clearance');

    // If we found the cf_clearance cookie, we've succeeded.
    if (cfCookie != null && cfCookie.value.isNotEmpty) {
      _isSolved = true;
      // This setState call is optional but good for updating the UI text
      if (mounted) setState(() {});

      // 关键改动：打印获取到的 Cookie 的具体值，便于调试
      LogUtils.i('成功捕获 cf_clearance Cookie: ${cfCookie.value}', 'CloudflareChallengeDialog');

      final result = {
        'cookie': 'cf_clearance=${cfCookie.value}',
        'userAgent': kFixedUserAgent,
      };

      // Complete the future if it hasn't been completed already
      if (!_completer.isCompleted) {
        _completer.complete(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent accidental closing
      child: AlertDialog(
        title: Text(_isSolved ? '验证成功' : '安全验证'),
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          // Let the height adjust for the success message
          height: _isSolved ? 150 : MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<Map<String, String>>(
            future: _completer.future,
            builder: (context, snapshot) {
              // When the challenge is solved and the future completes
              if (snapshot.connectionState == ConnectionState.done) {
                // Automatically pop the dialog with the successful result
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Navigator.of(context).pop(snapshot.data);
                });

                // Show a brief success message while closing
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('正在应用设置...'),
                    ],
                  ),
                );
              }

              // While challenge is in progress, show the WebView
              return InAppWebView(
                initialUrlRequest:
                URLRequest(url: WebUri(CommonConstants.iwaraBaseUrl)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  clearCache: true,
                  userAgent: kFixedUserAgent,
                ),
                // 使用 onLoadStop 是最可靠的方式
                onLoadStop: (controller, url) {
                  // 加一个微小的延迟，确保 Cookie 已完全写入
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _checkCookieAndComplete(url);
                  });
                },
                // 为了避免重复调用，移除 onProgressChanged 的逻辑
                onProgressChanged: (controller, progress) {
                  // No longer needed here
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // User manually cancels, pop with null result
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}