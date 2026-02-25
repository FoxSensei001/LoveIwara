import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/cloudflare_challenge.model.dart';
import 'package:i_iwara/app/services/cloudflare_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CloudflareChallengePage extends StatefulWidget {
  final CloudflareChallengeRequest request;

  const CloudflareChallengePage({super.key, required this.request});

  @override
  State<CloudflareChallengePage> createState() =>
      _CloudflareChallengePageState();
}

class _CloudflareChallengePageState extends State<CloudflareChallengePage> {
  static const String _cookieName = 'cf_clearance';

  final CookieManager _cookieManager = CookieManager.instance();

  InAppWebViewController? _controller;
  double _progress = 0;
  bool _checking = false;
  String? _userAgent;

  late final InAppWebViewSettings _settings;

  @override
  void initState() {
    super.initState();

    String? ua;
    if (Get.isRegistered<CloudflareService>()) {
      ua = Get.find<CloudflareService>().userAgent;
    }

    _settings = InAppWebViewSettings(
      javaScriptEnabled: true,
      domStorageEnabled: true,
      thirdPartyCookiesEnabled: true,
      sharedCookiesEnabled: true,
      userAgent: ua,
      useShouldOverrideUrlLoading: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final host = widget.request.triggerHost;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cloudflare ${t.translation.needVerification}'),
          actions: [
            IconButton(
              tooltip: t.common.refresh,
              onPressed: () => _controller?.reload(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_progress < 1.0)
              LinearProgressIndicator(value: _progress)
            else
              const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.request.reason?.trim().isNotEmpty == true
                        ? widget.request.reason!.trim()
                        : '检测到 $host 需要进行安全验证，请按页面提示完成。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _checking
                              ? null
                              : () => _checkClearance(manual: true),
                          icon: _checking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.verified_user_outlined),
                          label: Text(_checking ? t.common.loading : '我已完成验证'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _cancel,
                        child: Text(t.common.cancel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(widget.request.initialUri.toString()),
                ),
                initialSettings: _settings,
                onWebViewCreated: (controller) {
                  _controller = controller;
                },
                onLoadStop: (controller, url) async {
                  await _maybeUpdateUserAgent(controller);
                  await _checkClearance();
                },
                onProgressChanged: (controller, progress) async {
                  setState(() {
                    _progress = progress / 100.0;
                  });
                  if (progress >= 80) {
                    await _checkClearance();
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  if (uri == null) return NavigationActionPolicy.ALLOW;

                  final scheme = uri.scheme;
                  const allowedSchemes = {
                    'http',
                    'https',
                    'file',
                    'chrome',
                    'data',
                    'javascript',
                    'about',
                  };
                  if (!allowedSchemes.contains(scheme)) {
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _maybeUpdateUserAgent(InAppWebViewController controller) async {
    if (_userAgent != null && _userAgent!.isNotEmpty) return;
    try {
      final ua = await controller.evaluateJavascript(
        source: 'navigator.userAgent',
      );
      if (ua is String && ua.trim().isNotEmpty) {
        _userAgent = ua.trim();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _checkClearance({bool manual = false}) async {
    if (!mounted) return;
    if (_checking) return;

    if (manual) {
      setState(() {
        _checking = true;
      });
    }

    try {
      final host = widget.request.triggerHost;
      final cookie = await _cookieManager.getCookie(
        url: WebUri('https://$host/'),
        name: _cookieName,
      );
      final value = cookie?.value;
      if (value != null && value.isNotEmpty) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop(CloudflareChallengeResult(verified: true, userAgent: _userAgent));
      }
    } finally {
      if (manual && mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  void _cancel() {
    if (!mounted) return;
    Navigator.of(context).pop(const CloudflareChallengeResult.cancelled());
  }
}
