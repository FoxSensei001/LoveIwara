import 'dart:isolate';

import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/services/webdav/webdav_client.dart';
import 'package:i_iwara/app/services/webdav/webdav_gateway.dart';
import 'package:i_iwara/app/services/webdav/webdav_propfind.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// NAS 账号密码。
class WebDavCredentials {
  const WebDavCredentials({required this.username, required this.password});

  final String username;
  final String password;
}

/// NAS 源在主 isolate 这一侧的门面：凭据、列目录、播放地址。
///
/// ⛔ 凭据只在 secure storage（`webdav_cred_<sourceId>`），**不进库、不进 URL、
/// 不进日志、不进路由 extra / Intent**。库会随备份跨设备还原，凭据不跟着走——
/// 还原后源在、凭据缺，源状态落 `authFailed`，由用户重新输入。
class WebDavService {
  WebDavService._();

  static final WebDavService instance = WebDavService._();
  static const String _tag = 'WebDavService';

  final StorageService _storage = StorageService();
  WebDavGateway get gateway => WebDavGateway.instance;

  static String _credentialKey(String sourceId) => 'webdav_cred_$sourceId';

  /// 读凭据。⛔ 必须区分「没有」和「读失败」：读失败当没有，就是让用户去重输
  /// 一个其实还在的密码（同应用锁那次 fail-open 的教训）。
  Future<SecureReadResult<WebDavCredentials>> readCredentials(
    String sourceId,
  ) async {
    final raw = await _storage.readSecureObjectDetailed(
      _credentialKey(sourceId),
    );
    if (raw.isMissing) return const SecureReadResult.missing();
    if (raw.isFailed) return SecureReadResult.failed(raw.error);
    final value = raw.value!;
    final username = value['username'];
    final password = value['password'];
    if (username is! String || password is! String) {
      return SecureReadResult.failed(const FormatException('凭据格式不对'));
    }
    return SecureReadResult.found(
      WebDavCredentials(username: username, password: password),
    );
  }

  /// 存凭据。返回 false = 没存下来（安全存储与降级加密都不可用，按 fail-closed
  /// 不落明文）——调用方不能在这种情况下建源，否则建出来就是「需要重新登录」。
  Future<bool> writeCredentials(
    String sourceId,
    WebDavCredentials credentials,
  ) async {
    final result = await _storage.writeSecureObject(_credentialKey(sourceId), {
      'username': credentials.username,
      'password': credentials.password,
    });
    return result != SecureWriteResult.skipped;
  }

  /// 源被移除时调：凭据与网关里的连接信息一起清掉。
  Future<void> forgetSource(String sourceId) async {
    gateway.removeEndpoint(sourceId);
    await _storage.deleteSecureData(_credentialKey(sourceId));
  }

  /// 源 → 连接信息。凭据缺失/读失败时抛 [WebDavUnavailable]，带上该落的源状态。
  Future<WebDavEndpoint> endpointFor(LocalMediaSource staleSource) async {
    assert(staleSource.isRemote, '不是 NAS 源：${staleSource.kind}');
    // ⛔ 以库里的为准：调用方手上那份可能是「重新登录 / 重新确认证书」之前的，
    // 拿它 put 进网关会把刚确认的新指纹覆盖回旧的。
    final source =
        LocalMediaRepository().getSource(staleSource.id) ?? staleSource;
    final origin = source.uri;
    if (origin == null || origin.isEmpty) {
      throw const WebDavUnavailable(LocalMediaRemoteState.unreachable);
    }
    final credentials = await readCredentials(source.id);
    if (credentials.isFailed) {
      throw const WebDavUnavailable(LocalMediaRemoteState.credUnreadable);
    }
    if (credentials.isMissing) {
      throw const WebDavUnavailable(LocalMediaRemoteState.authFailed);
    }
    final endpoint = WebDavEndpoint(
      sourceId: source.id,
      origin: origin,
      username: credentials.value!.username,
      password: credentials.value!.password,
      tlsFingerprint: source.tlsFingerprint,
    );
    // 顺手交给网关：列目录成功之后紧接着就是播放/拉封面。
    gateway.putEndpoint(endpoint);
    return endpoint;
  }

  /// 列一个 NAS 目录（[davFolder] 是 `dav:/…`）。
  ///
  /// 网络请求与 XML 解析都在 `Isolate.run` 里：一个几千文件的目录，PROPFIND
  /// 响应有几 MB，在主 isolate 解析会卡 UI。失败抛 [WebDavFailure]。
  Future<List<DavEntry>> listFolder(
    LocalMediaSource source,
    String davFolder,
  ) async {
    final endpoint = await endpointFor(source);
    return listFolderWith(endpoint, davFolder);
  }

  /// 同 [listFolder]，给还没建源的「测试连接 / 选根目录」用。
  Future<List<DavEntry>> listFolderWith(
    WebDavEndpoint endpoint,
    String davFolder,
  ) {
    return _listInIsolate(endpoint, DavPath.toServerPath(davFolder));
  }

  /// ⛔ 必须是 static：实例方法里写 `Isolate.run(() => …)`，闭包会连带捕获
  /// `this`（这里挂着 StorageService），发往别的 isolate 时直接失败。静态方法里
  /// 造的闭包只捕获这两个纯数据参数。
  static Future<List<DavEntry>> _listInIsolate(
    WebDavEndpoint endpoint,
    String serverPath,
  ) => Isolate.run(() => webDavListFolder(endpoint, serverPath));

  /// NAS 文件 → 本机网关地址。**打开那一刻现算，绝不存下来**（端口/token 进程级）。
  Future<String> gatewayUrlFor(LocalMediaSource source, String davPath) async {
    if (!gateway.hasEndpoint(source.id)) await endpointFor(source);
    return gateway.urlFor(source.id, DavPath.toServerPath(davPath));
  }

  /// 本地库条目（NAS 上的那一条）→ 本机网关地址。播放器、播放池、Quest 都走这里。
  ///
  /// 凭据缺失 / 读不出时抛 [WebDavUnavailable]（带着该落的源状态），调用方据此
  /// 给「需要重新登录」一类的具体文案，而不是泛泛的「播放失败」。
  Future<String> gatewayUrlForItem(String itemId) async {
    final repository = LocalMediaRepository();
    final item = repository.getItem(itemId);
    final source = item == null ? null : repository.getSource(item.sourceId);
    if (item == null || source == null || !source.isRemote) {
      throw const WebDavUnavailable(LocalMediaRemoteState.unreachable);
    }
    return gatewayUrlFor(source, item.path);
  }

  /// [WebDavUnavailable] 给用户看的那句话。
  static String describeUnavailable(WebDavUnavailable e) =>
      describeState(e.state);

  /// 源状态给用户看的那句话（来源卡副标题、目录页空态、播放错误页共用）。
  static String describeState(LocalMediaRemoteState state) {
    final t = slang.t.localMedia.webdav;
    return switch (state) {
      LocalMediaRemoteState.authFailed => t.stateAuthFailed,
      LocalMediaRemoteState.certUntrusted => t.stateCertUntrusted,
      LocalMediaRemoteState.credUnreadable => t.stateCredUnreadable,
      LocalMediaRemoteState.unreachable ||
      LocalMediaRemoteState.ok => t.stateUnreachable,
    };
  }

  /// 列目录失败 → 源该落的状态。
  static LocalMediaRemoteState remoteStateOf(WebDavFailure failure) =>
      switch (failure.kind) {
        WebDavFailureKind.auth => LocalMediaRemoteState.authFailed,
        WebDavFailureKind.cert => LocalMediaRemoteState.certUntrusted,
        WebDavFailureKind.unreachable ||
        WebDavFailureKind.protocol => LocalMediaRemoteState.unreachable,
      };

  static void logFailure(String what, Object error) {
    // ⛔ 只打种类与状态码，不打 URL（路径里有文件名）。
    LogUtils.w('$what 失败：$error', _tag);
  }
}

/// 还没发请求就知道用不了（凭据缺失/读失败、源不完整）。
class WebDavUnavailable implements Exception {
  const WebDavUnavailable(this.state);

  final LocalMediaRemoteState state;

  @override
  String toString() => 'WebDavUnavailable(${state.name})';
}
