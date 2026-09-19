import 'package:flutter/material.dart';

import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/services/local_media_directory_policy.dart';
import 'package:i_iwara/app/services/webdav/webdav_client.dart';
import 'package:i_iwara/app/services/webdav/webdav_propfind.dart';
import 'package:i_iwara/app/services/webdav/webdav_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「连接 NAS」弹窗的结果：连得上、用户也选好了根目录。
class WebDavConnectResult {
  const WebDavConnectResult({
    required this.origin,
    required this.rootDavPath,
    required this.credentials,
    required this.displayName,
    this.tlsFingerprint,
  });

  /// `scheme://host[:port]`。
  final String origin;

  /// 选中的根目录（`dav:/…`）。重新登录时就是源原来的根。
  final String rootDavPath;
  final WebDavCredentials credentials;
  final String displayName;
  final String? tlsFingerprint;
}

/// 已经连过的一台 NAS：连接弹窗第一步可以直接选它，免得再输一遍密码。
class WebDavSavedServer {
  const WebDavSavedServer({
    required this.sourceId,
    required this.origin,
    required this.displayName,
    this.tlsFingerprint,
  });

  /// 凭据存在这个源名下（secure storage 按源 id 存）。
  final String sourceId;
  final String origin;
  final String displayName;
  final String? tlsFingerprint;
}

/// 新建一个 NAS 源：填地址+账号 → 连接 → 选根目录。用户取消返回 null。
///
/// [savedServers] 非空时，表单上方列出它们：点一下带上保存的账号密码直接连，
/// 同一台 NAS 加第二个共享不必再输一遍。
Future<WebDavConnectResult?> showWebDavConnectDialog({
  required BuildContext context,
  List<WebDavSavedServer> savedServers = const [],
}) {
  return showAppDialog<WebDavConnectResult>(
    _WebDavConnectDialog(savedServers: savedServers),
    dialogContext: context,
    barrierDismissible: false,
  );
}

/// 重新登录一个已有的 NAS 源（改密码、重新确认证书）。地址与根目录不变。
Future<WebDavConnectResult?> showWebDavReloginDialog({
  required BuildContext context,
  required String origin,
  required String rootDavPath,
  required String displayName,
  String? username,
  String? tlsFingerprint,
}) {
  return showAppDialog<WebDavConnectResult>(
    _WebDavConnectDialog(
      relogin: _Relogin(
        origin: origin,
        rootDavPath: rootDavPath,
        displayName: displayName,
        username: username,
        tlsFingerprint: tlsFingerprint,
      ),
    ),
    dialogContext: context,
    barrierDismissible: false,
  );
}

class _Relogin {
  const _Relogin({
    required this.origin,
    required this.rootDavPath,
    required this.displayName,
    this.username,
    this.tlsFingerprint,
  });

  final String origin;
  final String rootDavPath;
  final String displayName;
  final String? username;
  final String? tlsFingerprint;
}

/// 用户填的地址 → (origin, 起始目录)。没写 scheme 补 `http://`（家用 NAS 的
/// WebDAV 绝大多数是局域网明文）。认不出来返回 null。
({String origin, String startDavPath})? parseWebDavAddress(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'http://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  final origin = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  ).toString();
  final path = uri.pathSegments.where((s) => s.isNotEmpty).join('/');
  return (origin: origin, startDavPath: DavPath.fromServerPath('/$path'));
}

enum _Stage { form, pickRoot }

class _WebDavConnectDialog extends StatefulWidget {
  const _WebDavConnectDialog({this.relogin, this.savedServers = const []});

  final _Relogin? relogin;
  final List<WebDavSavedServer> savedServers;

  @override
  State<_WebDavConnectDialog> createState() => _WebDavConnectDialogState();
}

class _WebDavConnectDialogState extends State<_WebDavConnectDialog> {
  // ⛔ controller 归 State 管、在 dispose 里释放：弹窗关闭时还要播退场动画，
  // 在调用点的 whenComplete 里 dispose 会撞上「used after being disposed」。
  late final TextEditingController _address;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _name;

  _Stage _stage = _Stage.form;
  bool _busy = false;
  String? _error;
  bool _obscure = true;

  /// 连通之后的连接信息，选根目录那一页一直用它。
  WebDavEndpoint? _endpoint;

  /// 选根目录页：当前所在目录与它的子目录。
  String _currentDav = DavPath.prefix;
  List<DavEntry> _folders = const [];
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    final relogin = widget.relogin;
    _address = TextEditingController(text: relogin?.origin ?? '');
    _username = TextEditingController(text: relogin?.username ?? '');
    _password = TextEditingController();
    _name = TextEditingController(text: relogin?.displayName ?? '');
  }

  @override
  void dispose() {
    _generation++;
    _address.dispose();
    _username.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  slang.TranslationsLocalMediaWebdavEn get _t => slang.t.localMedia.webdav;

  Future<void> _connect() async {
    final relogin = widget.relogin;
    final parsed = relogin != null
        ? (origin: relogin.origin, startDavPath: relogin.rootDavPath)
        : parseWebDavAddress(_address.text);
    if (parsed == null) {
      setState(() => _error = _t.invalidAddress);
      return;
    }
    // 连接中可以取消：取消 = 关掉弹窗（dispose 里 `_generation++`），晚回来的
    // 结果凭 generation 认出自己已经作废。
    final generation = ++_generation;
    bool stale() => !mounted || generation != _generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    var endpoint = WebDavEndpoint(
      sourceId: '_probe',
      origin: parsed.origin,
      username: _username.text.trim(),
      password: _password.text,
      // 连一台已保存过的 NAS：沿用上次信任的证书指纹，不再弹一次 TOFU。
      tlsFingerprint:
          relogin?.tlsFingerprint ??
          widget.savedServers
              .where((server) => server.origin == parsed.origin)
              .firstOrNull
              ?.tlsFingerprint,
    );
    try {
      final entries = await _list(endpoint, parsed.startDavPath);
      if (stale()) return;
      _onConnected(endpoint, parsed.startDavPath, entries);
    } on WebDavFailure catch (failure) {
      if (stale()) return;
      final fingerprint = failure.certFingerprint;
      if (failure.kind == WebDavFailureKind.cert && fingerprint != null) {
        final trusted = await _confirmCertificate(
          fingerprint,
          changed: endpoint.tlsFingerprint != null,
        );
        if (stale()) return;
        if (!trusted) {
          setState(() => _busy = false);
          return;
        }
        endpoint = WebDavEndpoint(
          sourceId: endpoint.sourceId,
          origin: endpoint.origin,
          username: endpoint.username,
          password: endpoint.password,
          tlsFingerprint: fingerprint,
        );
        try {
          final entries = await _list(endpoint, parsed.startDavPath);
          if (stale()) return;
          _onConnected(endpoint, parsed.startDavPath, entries);
        } on WebDavFailure catch (again) {
          if (stale()) return;
          setState(() {
            _busy = false;
            _error = _describe(again, endpoint.origin);
          });
        }
        return;
      }
      setState(() {
        _busy = false;
        _error = _describe(failure, endpoint.origin);
      });
    }
  }

  Future<List<DavEntry>> _list(WebDavEndpoint endpoint, String davPath) =>
      WebDavService.instance.listFolderWith(endpoint, davPath);

  void _onConnected(
    WebDavEndpoint endpoint,
    String startDavPath,
    List<DavEntry> entries,
  ) {
    final relogin = widget.relogin;
    if (relogin != null) {
      // 重新登录：根目录不变，连得上就完事。
      Navigator.of(context, rootNavigator: true).pop(
        WebDavConnectResult(
          origin: endpoint.origin,
          rootDavPath: relogin.rootDavPath,
          credentials: WebDavCredentials(
            username: endpoint.username,
            password: endpoint.password,
          ),
          displayName: relogin.displayName,
          tlsFingerprint: endpoint.tlsFingerprint,
        ),
      );
      return;
    }
    setState(() {
      _endpoint = endpoint;
      _stage = _Stage.pickRoot;
      _busy = false;
      _currentDav = startDavPath;
      _folders = _foldersOf(entries);
    });
  }

  /// 选中一台已保存的 NAS：取出保存的账号密码填进表单，直接连。
  Future<void> _useSaved(WebDavSavedServer server) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final saved = await WebDavService.instance.readCredentials(server.sourceId);
    if (!mounted) return;
    final credentials = saved.value;
    _address.text = server.origin;
    if (credentials == null) {
      // 读不出来（被清掉 / 钥匙串出错）：地址照样填上，让用户自己补账号密码。
      setState(() {
        _busy = false;
        _error = _t.errorCredUnreadable;
      });
      return;
    }
    _username.text = credentials.username;
    _password.text = credentials.password;
    setState(() => _busy = false);
    await _connect();
  }

  List<DavEntry> _foldersOf(List<DavEntry> entries) {
    final folders = entries
        .where(
          (e) => e.isDirectory && !LocalDirectoryPolicy.skipListedChild(e.name),
        )
        .toList();
    folders.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return folders;
  }

  Future<void> _open(String davPath) async {
    final endpoint = _endpoint;
    if (endpoint == null) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final entries = await _list(endpoint, davPath);
      if (!mounted || generation != _generation) return;
      setState(() {
        _busy = false;
        _currentDav = davPath;
        _folders = _foldersOf(entries);
      });
    } on WebDavFailure catch (failure) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _busy = false;
        _error = _describe(failure, endpoint.origin);
      });
    }
  }

  /// 失败 → 用户看得懂、知道下一步做什么的那句话。
  ///
  /// - 403：账号密码是对的，只是这个账号没有 WebDAV 权限（群晖默认就这样）——
  ///   说成「用户名或密码不对」会让人一直改密码。
  /// - 证书失败却没拿到指纹：是握手本身失败，不是连不上。
  /// - 用 http 连却碰到 400 / 连不上：多半是 NAS 只开了 HTTPS 端口（群晖 5006），
  ///   而地址没写协议时我们补的是 http://。
  String _describe(WebDavFailure failure, String origin) {
    final plainHttp = origin.startsWith('http://');
    String withHttpsHint(String text) =>
        plainHttp ? '$text\n${_t.errorTryHttps}' : text;
    return switch (failure.kind) {
      WebDavFailureKind.auth =>
        failure.statusCode == 403 ? _t.errorForbidden : _t.errorAuth,
      WebDavFailureKind.unreachable => withHttpsHint(_t.errorUnreachable),
      WebDavFailureKind.cert => _t.errorTls,
      WebDavFailureKind.protocol =>
        failure.statusCode == 405 || failure.statusCode == 404
            ? _t.errorNotWebdav
            : failure.statusCode == 400
            ? withHttpsHint(_t.errorGeneric(code: 400))
            : _t.errorGeneric(code: failure.statusCode ?? '-'),
    };
  }

  /// 选根目录这一步回到表单：地址、账号、密码原样留着，只丢掉这次连接。
  void _backToForm() {
    setState(() {
      _generation++;
      _stage = _Stage.form;
      _endpoint = null;
      _busy = false;
      _error = null;
      _folders = const [];
    });
  }

  Future<bool> _confirmCertificate(
    String fingerprint, {
    required bool changed,
  }) async {
    final formatted = _formatFingerprint(fingerprint);
    final trusted = await showGlassAlertDialog<bool>(
      title: _t.certTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(changed ? _t.certChangedBody : _t.certBody),
          const SizedBox(height: 12),
          SelectableText(
            formatted,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ),
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: !changed,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
        GlassDialogAction(
          label: _t.trust,
          destructive: changed,
          emphasized: !changed,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    );
    return trusted == true;
  }

  static String _formatFingerprint(String hex) {
    final pairs = <String>[
      for (var i = 0; i + 1 < hex.length; i += 2)
        hex.substring(i, i + 2).toUpperCase(),
    ];
    return pairs.join(':');
  }

  void _useCurrentFolder() {
    final endpoint = _endpoint;
    if (endpoint == null) return;
    final typedName = _name.text.trim();
    final folderName = DavPath.basename(_currentDav);
    final host = Uri.tryParse(endpoint.origin)?.host ?? endpoint.origin;
    Navigator.of(context, rootNavigator: true).pop(
      WebDavConnectResult(
        origin: endpoint.origin,
        rootDavPath: _currentDav,
        credentials: WebDavCredentials(
          username: endpoint.username,
          password: endpoint.password,
        ),
        displayName: typedName.isNotEmpty
            ? typedName
            : (folderName.isEmpty || folderName == '/' ? host : folderName),
        tlsFingerprint: endpoint.tlsFingerprint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.form => _buildForm(context),
      _Stage.pickRoot => _buildPicker(context),
    };
  }

  Widget _field(
    TextEditingController controller, {
    required String label,
    String? hint,
    IconData? icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    bool enabled = true,
    List<String>? autofillHints,
    TextInputAction action = TextInputAction.next,
  }) {
    return GlassInputSurface(
      child: TextField(
        controller: controller,
        enabled: enabled && !_busy,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: !obscure,
        keyboardType: keyboardType,
        textInputAction: action,
        autofillHints: autofillHints,
        onSubmitted: action == TextInputAction.done ? (_) => _connect() : null,
        decoration: glassFieldDecoration(
          context,
          label: label,
          hint: hint,
          icon: icon,
        ).copyWith(suffixIcon: suffix),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final relogin = widget.relogin;
    return GlassAlertDialog(
      title: relogin != null ? _t.editTitle : _t.connectTitle,
      maxWidth: 460,
      floatingActions: true,
      floatingHeader: true,
      scrollable: true,
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          // ⛔ 连接中也能取消：碰上只收连接不回数据的主机，超时要几十秒。
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
        ),
        GlassDialogAction(
          label: _t.connect,
          emphasized: true,
          onPressed: _busy ? null : _connect,
        ),
      ],
      content: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (relogin == null && widget.savedServers.isNotEmpty) ...[
              Text(
                slang.t.localMedia.savedServers,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              for (final server in widget.savedServers)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  enabled: !_busy,
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(server.displayName),
                  subtitle: Text(
                    Uri.tryParse(server.origin)?.authority ?? server.origin,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _useSaved(server),
                ),
              const Divider(height: 20),
              Text(
                slang.t.localMedia.newServer,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (relogin == null) ...[
              Text(
                _t.hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _field(
              _address,
              label: _t.address,
              hint: _t.addressHint,
              icon: Icons.dns_outlined,
              keyboardType: TextInputType.url,
              enabled: relogin == null,
              autofillHints: const [AutofillHints.url],
            ),
            const SizedBox(height: 10),
            _field(
              _username,
              label: _t.username,
              icon: Icons.person_outline,
              autofillHints: const [AutofillHints.username],
            ),
            const SizedBox(height: 10),
            _field(
              _password,
              label: _t.password,
              icon: Icons.lock_outline,
              obscure: _obscure,
              autofillHints: const [AutofillHints.password],
              action: relogin != null
                  ? TextInputAction.done
                  : TextInputAction.next,
              suffix: IconButton(
                tooltip: _t.password,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            if (relogin == null) ...[
              const SizedBox(height: 10),
              _field(
                _name,
                label: _t.displayName,
                icon: Icons.label_outline,
                action: TextInputAction.done,
              ),
            ],
            _StatusLine(busy: _busy, error: _error),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final theme = Theme.of(context);
    final serverPath = DavPath.toServerPath(_currentDav);
    final atRoot = serverPath == '/';
    return GlassAlertDialog(
      title: _t.pickRootTitle,
      maxWidth: 520,
      floatingActions: true,
      // 标题 + 路径条浮在目录列表之上，列表从它们背后滚过去（与动作行一上一下，
      // 同选择器弹窗的版式）。
      floatingHeader: true,
      scrollable: false,
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
        ),
        // 连错了机器 / 想换账号：回到表单改，不必取消后全部重填。
        GlassDialogAction(
          label: _t.previousStep,
          emphasized: false,
          onPressed: _backToForm,
        ),
        GlassDialogAction(
          label: slang.t.localMedia.browse.useThisFolder,
          emphasized: true,
          onPressed: _busy ? null : _useCurrentFolder,
        ),
      ],
      headerRows: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: slang.t.common.back,
                  onPressed: atRoot || _busy
                      ? null
                      : () => _open(DavPath.dirname(_currentDav)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassSurface(
                    height: GlassTokens.pillHeight,
                    borderRadius: BorderRadius.circular(
                      GlassTokens.pillHeight / 2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    liquidTouch: false,
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            atRoot ? _t.serverRoot : serverPath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 打不开某个子目录时的原因挂在路径条下面：它说的就是「这一跳」。
            // ⛔ 别放回列表底下——那里被浮动的动作行盖着。
            _PickerErrorLine(error: _error),
          ],
        ),
      ],
      // 列表铺满整块面板，高度里含着上下两段浮层让出去的部分。
      content: SizedBox(height: 480, child: _buildFolderList(context)),
    );
  }

  Widget _buildFolderList(BuildContext context) {
    final theme = Theme.of(context);
    final Widget child;
    if (_busy) {
      child = const GlassSpinningArc(key: ValueKey('busy'), size: 36);
    } else if (_folders.isEmpty) {
      child = Text(
        slang.t.localMedia.browse.noSubfolders,
        key: const ValueKey('empty'),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      child = ListView.builder(
        key: ValueKey(_currentDav),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _open(DavPath.fromServerPath(folder.serverPath)),
          );
        },
      );
    }
    // 转圈 / 空态要落在「两段浮层之间」那块看得见的区域中间，不是整块面板中间。
    final insets = MediaQuery.paddingOf(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: child is ListView
          ? child
          : Padding(
              key: child.key,
              padding: EdgeInsets.only(top: insets.top, bottom: insets.bottom),
              child: Center(child: child),
            ),
    );
  }
}

/// 选根目录那一步，路径条下面的出错原因：带底色的一小条（它浮在列表之上，
/// 光秃秃的红字压在滚动的条目上读不清）。出现与消失都有过渡。
class _PickerErrorLine extends StatelessWidget {
  const _PickerErrorLine({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final error = this.error;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: error == null
            ? const SizedBox(key: ValueKey('none'), width: double.infinity)
            : Padding(
                key: ValueKey(error),
                padding: const EdgeInsets.only(top: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// 表单底下那一行：连接中转圈，失败给原因。出现与消失都有过渡。
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.busy, required this.error});

  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget child;
    if (busy) {
      child = const Padding(
        key: ValueKey('busy'),
        padding: EdgeInsets.only(top: 14),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    } else if (error != null) {
      child = Padding(
        key: ValueKey(error),
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          error!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    } else {
      child = const SizedBox(key: ValueKey('none'), width: double.infinity);
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: child,
      ),
    );
  }
}
