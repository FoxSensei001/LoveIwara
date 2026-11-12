import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Cast V2 的一条消息（protobuf `CastMessage`，只用字符串负载）。
class CastMessage {
  const CastMessage({
    required this.sourceId,
    required this.destinationId,
    required this.namespace,
    required this.payload,
  });

  final String sourceId;
  final String destinationId;
  final String namespace;

  /// 已解析的 JSON 负载；二进制负载或解析失败时为空 Map。
  final Map<String, dynamic> payload;

  String? get type => payload['type'] as String?;

  int? get requestId => (payload['requestId'] as num?)?.toInt();
}

/// 一条到 Google Cast 接收端（8009 端口）的 TLS 连接。
///
/// 协议：每帧 = 4 字节大端长度 + protobuf `CastMessage`。字段很少，手写编解码，
/// 不引入 protobuf 依赖：
///
/// ```
/// 1 protocol_version  enum   (0 = CASTV2_1_0)
/// 2 source_id         string
/// 3 destination_id    string
/// 4 namespace         string
/// 5 payload_type      enum   (0 = STRING, 1 = BINARY)
/// 6 payload_utf8      string
/// 7 payload_binary    bytes
/// ```
///
/// 接收端用自签证书，校验必须放行。
class CastChannel {
  CastChannel._(this._socket) {
    _subscription = _socket.listen(
      _onData,
      onError: (Object e) => _fail(e),
      onDone: () => _fail(const SocketException('连接被设备关闭')),
      cancelOnError: true,
    );
    // 对端重置时 socket 的 done 也会以错误完成；没人接就成了未捕获异常。
    unawaited(_socket.done.then<void>((_) {}, onError: (Object _) {}));
    _heartbeat = Timer.periodic(const Duration(seconds: 5), (_) {
      send(
        namespace: nsHeartbeat,
        destinationId: receiver,
        payload: {'type': 'PING'},
      );
    });
  }

  static const String nsConnection = 'urn:x-cast:com.google.cast.tp.connection';
  static const String nsHeartbeat = 'urn:x-cast:com.google.cast.tp.heartbeat';
  static const String nsReceiver = 'urn:x-cast:com.google.cast.receiver';
  static const String nsMedia = 'urn:x-cast:com.google.cast.media';
  static const String sender = 'sender-0';
  static const String receiver = 'receiver-0';

  static Future<CastChannel> connect(
    String host,
    int port, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // ⛔ SecureSocket.connect 的 timeout 只管 TCP 建连，TLS 握手不计时：对端收了
    // 连接却不回 ServerHello（进程假死、手动输入的地址 8009 上是别的服务）会一直
    // 挂着，把投屏指令队列整个堵死。所以拆成两步，握手单独限时。
    final raw = await Socket.connect(host, port, timeout: timeout);
    try {
      final socket = await SecureSocket.secure(
        raw,
        onBadCertificate: (_) => true,
      ).timeout(timeout);
      return CastChannel._(socket);
    } catch (_) {
      raw.destroy();
      rethrow;
    }
  }

  final SecureSocket _socket;
  late final StreamSubscription<Uint8List> _subscription;
  late final Timer _heartbeat;
  final _incoming = StreamController<CastMessage>.broadcast();
  final _buffer = BytesBuilder(copy: false);
  int _nextRequestId = 1;
  bool _closed = false;
  Object? _error;

  Stream<CastMessage> get messages => _incoming.stream;

  bool get isClosed => _closed;

  /// 和某个端点建立虚连接（receiver-0 或应用的 transportId）。
  void connectTo(String destinationId) {
    send(
      namespace: nsConnection,
      destinationId: destinationId,
      payload: {'type': 'CONNECT'},
    );
  }

  void send({
    required String namespace,
    required String destinationId,
    required Map<String, dynamic> payload,
  }) {
    if (_closed) return;
    final body = encodeCastMessage(
      sourceId: sender,
      destinationId: destinationId,
      namespace: namespace,
      payloadUtf8: jsonEncode(payload),
    );
    final header = ByteData(4)..setUint32(0, body.length);
    _socket.add(header.buffer.asUint8List());
    _socket.add(body);
  }

  /// 发一条带 requestId 的请求，等 [accept] 认可的第一条回应。
  ///
  /// [accept] 返回 null 表示「不是这条」，继续等；返回非空即为结果。
  /// 不带 [accept] 时按 requestId 匹配。
  Future<CastMessage> request({
    required String namespace,
    required String destinationId,
    required Map<String, dynamic> payload,
    bool Function(CastMessage message, int requestId)? accept,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_closed) {
      throw _error ?? const SocketException('连接已关闭');
    }
    final requestId = _nextRequestId++;
    final completer = Completer<CastMessage>();
    late final StreamSubscription<CastMessage> sub;
    sub = messages.listen(
      (m) {
        if (completer.isCompleted) return;
        final ok = accept != null
            ? accept(m, requestId)
            : (m.namespace == namespace && m.requestId == requestId);
        if (ok) completer.complete(m);
      },
      onError: (Object e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(_error ?? const SocketException('连接已关闭'));
        }
      },
    );
    send(
      namespace: namespace,
      destinationId: destinationId,
      payload: {...payload, 'requestId': requestId},
    );
    try {
      return await completer.future.timeout(timeout);
    } finally {
      await sub.cancel();
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _heartbeat.cancel();
    await _subscription.cancel();
    await _incoming.close();
    try {
      await _socket.close();
    } catch (_) {}
    _socket.destroy();
  }

  void _fail(Object error) {
    if (_closed) return;
    _error = error;
    if (!_incoming.isClosed) _incoming.addError(error);
    unawaited(close());
  }

  void _onData(Uint8List chunk) {
    _buffer.add(chunk);
    final bytes = _buffer.takeBytes();
    var offset = 0;
    while (bytes.length - offset >= 4) {
      final length = ByteData.sublistView(
        bytes,
        offset,
        offset + 4,
      ).getUint32(0);
      if (length > 1024 * 1024) {
        _fail(const FormatException('Cast 帧长度异常'));
        return;
      }
      if (bytes.length - offset - 4 < length) break;
      final frame = Uint8List.sublistView(
        bytes,
        offset + 4,
        offset + 4 + length,
      );
      offset += 4 + length;
      final message = decodeCastMessage(frame);
      if (message == null) continue;
      if (message.namespace == nsHeartbeat && message.type == 'PING') {
        send(
          namespace: nsHeartbeat,
          destinationId: message.sourceId,
          payload: {'type': 'PONG'},
        );
        continue;
      }
      if (!_incoming.isClosed) _incoming.add(message);
    }
    if (offset < bytes.length) {
      _buffer.add(Uint8List.sublistView(bytes, offset));
    }
  }
}

// ── protobuf 编解码 ─────────────────────────────────────────────────────────

Uint8List encodeCastMessage({
  required String sourceId,
  required String destinationId,
  required String namespace,
  required String payloadUtf8,
}) {
  final b = BytesBuilder();
  b.add(const [0x08, 0x00]); // protocol_version = CASTV2_1_0
  _writeString(b, 2, sourceId);
  _writeString(b, 3, destinationId);
  _writeString(b, 4, namespace);
  b.add(const [0x28, 0x00]); // payload_type = STRING
  _writeString(b, 6, payloadUtf8);
  return b.takeBytes();
}

CastMessage? decodeCastMessage(Uint8List data) {
  var pos = 0;
  int readVarint() {
    var result = 0;
    var shift = 0;
    while (true) {
      if (pos >= data.length) throw const FormatException('varint 截断');
      final byte = data[pos++];
      result |= (byte & 0x7f) << shift;
      if (byte & 0x80 == 0) return result;
      shift += 7;
      if (shift > 63) throw const FormatException('varint 过长');
    }
  }

  String source = '';
  String destination = '';
  String namespace = '';
  String? payloadUtf8;
  try {
    while (pos < data.length) {
      final tag = readVarint();
      final field = tag >> 3;
      final wire = tag & 0x07;
      switch (wire) {
        case 0:
          readVarint();
        case 1:
          pos += 8;
        case 5:
          pos += 4;
        case 2:
          final len = readVarint();
          if (len < 0 || pos + len > data.length) {
            throw const FormatException('字段长度越界');
          }
          final slice = Uint8List.sublistView(data, pos, pos + len);
          pos += len;
          switch (field) {
            case 2:
              source = utf8.decode(slice, allowMalformed: true);
            case 3:
              destination = utf8.decode(slice, allowMalformed: true);
            case 4:
              namespace = utf8.decode(slice, allowMalformed: true);
            case 6:
              payloadUtf8 = utf8.decode(slice, allowMalformed: true);
          }
        default:
          throw FormatException('未知 wire type $wire');
      }
    }
  } catch (_) {
    // 畸形帧（含 varint 溢出成负数引起的 RangeError）：丢掉这一帧。
    return null;
  }

  Map<String, dynamic> payload = const {};
  if (payloadUtf8 != null) {
    try {
      final decoded = jsonDecode(payloadUtf8);
      if (decoded is Map<String, dynamic>) payload = decoded;
    } catch (_) {}
  }
  return CastMessage(
    sourceId: source,
    destinationId: destination,
    namespace: namespace,
    payload: payload,
  );
}

void _writeString(BytesBuilder b, int field, String value) {
  final bytes = utf8.encode(value);
  b.addByte((field << 3) | 2);
  _writeVarint(b, bytes.length);
  b.add(bytes);
}

void _writeVarint(BytesBuilder b, int value) {
  var v = value;
  while (v >= 0x80) {
    b.addByte((v & 0x7f) | 0x80);
    v >>= 7;
  }
  b.addByte(v);
}
