import 'dart:io';
import 'dart:typed_data';

import 'package:i_iwara/app/models/vr_format.model.dart';

/// MP4 头部立体与投影 box 解析结果。
class Mp4StereoBoxResult {
  /// 投影方式（sv3d 存在 ⇒ equirect360 或 equirect180）。
  final VrProjection? projection;

  /// 立体编排（st3d stereo_mode 映射）。
  final VrStereoLayout? stereoLayout;

  /// 是否读到了任何有效的投影或立体信号。
  bool get hasSignal => projection != null || stereoLayout != null;

  const Mp4StereoBoxResult({this.projection, this.stereoLayout});

  /// 未探测到任何立体/投影元数据时的安全空值。
  static const Mp4StereoBoxResult empty = Mp4StereoBoxResult();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mp4StereoBoxResult &&
          other.projection == projection &&
          other.stereoLayout == stereoLayout;

  @override
  int get hashCode => Object.hash(projection, stereoLayout);

  @override
  String toString() =>
      'Mp4StereoBoxResult(projection: $projection, stereoLayout: $stereoLayout)';
}

/// 本地 MP4 文件的 ISOBMFF 立体/全景 box (`st3d` / `sv3d`) 解析器。
///
/// ⛔ 只读文件头若干 KB，绝不整文件进内存：VR 视频体积通常达到数 GB 至数十 GB，
/// 完整读入会导致 OOM 崩溃；通常 faststart 后的 MP4 元数据容器 `moov` 位于头部，
/// 仅需顺序读取前若干 KB 即可无损探测出元数据。
/// ⛔ 绝不引入新依赖，仅使用 `dart:io` 与 `dart:typed_data`。
class Mp4StereoBoxReader {
  const Mp4StereoBoxReader._();

  // 必须递归进入的常规容器 box 集合。
  static const Set<String> _plainContainers = <String>{
    'moov',
    'trak',
    'mdia',
    'minf',
    'stbl',
    'proj',
  };

  // 视觉样本条目（VisualSampleEntry）容器集合：
  // 包含 avc1, hvc1, hev1, mp4v, av01, encv。
  static const Set<String> _visualSampleEntries = <String>{
    'avc1',
    'hvc1',
    'hev1',
    'mp4v',
    'av01',
    'encv',
  };

  /// 只读文件头若干 KB，解析 ISOBMFF 的 `st3d` / `sv3d` box。
  ///
  /// ⛔ 任何异常/格式不符一律返回 [Mp4StereoBoxResult.empty]，绝不抛出：
  /// 该读取属于投机性元数据嗅探，不可因文件截断、编码非标或 IO 瞬断阻断播放主流程。
  static Future<Mp4StereoBoxResult> read(
    String path, {
    int maxBytes = 512 * 1024,
  }) async {
    RandomAccessFile? raf;
    try {
      final file = File(path);
      if (!await file.exists()) {
        return Mp4StereoBoxResult.empty;
      }

      raf = await file.open(mode: FileMode.read);
      final fileLength = await raf.length();
      if (fileLength < 8) return Mp4StereoBoxResult.empty;

      // ⛔ 不能"读头部 512KB 然后在里面找 moov"。`moov` 只有被 faststart 处理过的
      // 文件才在头部；本地库里的片子多半没被处理过，`moov` 躺在**文件末尾**，
      // 前 512KB 里全是 `mdat` 的裸码流——那样写，绝大多数真实文件都会静默无信号。
      //
      // 改成**只顺着顶层 box 的头往前跳**：每次只读 16 字节头，按 size 跳过整个
      // `mdat`（根本不读它的内容），直到撞见 `moov` 才把它读进来。代价是几次
      // seek，收益是无论 moov 在头在尾都能拿到。
      final ctx = _ParseContext();
      var offset = 0;
      while (offset + 8 <= fileLength) {
        await raf.setPosition(offset);
        final header = await raf.read(16);
        if (header.length < 8) break;
        final headerView = ByteData.sublistView(header);
        final size32 = headerView.getUint32(0);
        final type = _readFourCc(headerView, 4);
        if (type == null) break;

        int headerSize = 8;
        int boxSize;
        if (size32 == 1) {
          if (header.length < 16) break;
          final size64 = headerView.getUint64(8);
          if (size64 < 16) break;
          headerSize = 16;
          boxSize = size64;
        } else if (size32 == 0) {
          boxSize = fileLength - offset;
        } else if (size32 < 8) {
          break;
        } else {
          boxSize = size32;
        }

        if (type == 'moov') {
          final payloadStart = offset + headerSize;
          final payloadLength = boxSize - headerSize;
          if (payloadLength > 0) {
            final want = payloadLength < maxBytes ? payloadLength : maxBytes;
            await raf.setPosition(payloadStart);
            final payload = await raf.read(want);
            if (payload.isNotEmpty) {
              final view = ByteData.sublistView(payload);
              _parseBoxes(view, 0, view.lengthInBytes, ctx);
            }
          }
          break;
        }

        final next = offset + boxSize;
        // 跳不动（size 撒谎或溢出）就停手，绝不原地打转。
        if (next <= offset) break;
        offset = next;
      }

      return Mp4StereoBoxResult(
        projection: ctx.projection,
        stereoLayout: ctx.stereoLayout,
      );
    } catch (_) {
      // 吞没异常，安全退守空结果
      return Mp4StereoBoxResult.empty;
    } finally {
      try {
        await raf?.close();
      } catch (_) {}
    }
  }

  /// 顺序遍历 [start] 到 [end] 范围内的 box。
  static void _parseBoxes(
    ByteData data,
    int start,
    int end,
    _ParseContext ctx,
  ) {
    var offset = start;

    while (offset + 8 <= end) {
      final boxStart = offset;
      final size32 = data.getUint32(offset);
      final type = _readFourCc(data, offset + 4);

      // ⛔ type 解不出 ASCII，说明非合法 box 结构，安全退出。
      if (type == null) {
        return;
      }

      int headerSize = 8;
      int boxEnd;

      if (size32 == 1) {
        // 64 位超大 box (largesize)
        if (offset + 16 > end) return;
        final size64 = data.getUint64(offset + 8);
        headerSize = 16;
        // ⛔ size 小于 16 或发生负数溢出，说明数据破损，安全退出。
        if (size64 < 16 || size64 > 0x7FFFFFFFFFFFFFFF) {
          return;
        }
        boxEnd = boxStart + size64;
      } else if (size32 == 0) {
        // size == 0 表示 box 延伸至当前容器/文件末尾。
        boxEnd = end;
      } else if (size32 < 8) {
        // ⛔ size 小于 8 且不为 0/1，非合法 box 头，安全退出。
        return;
      } else {
        boxEnd = boxStart + size32;
      }

      // 防止数值溢出或死循环。
      if (boxEnd <= boxStart && size32 != 0) {
        return;
      }

      final payloadStart = boxStart + headerSize;
      // 允许当外层容器（如 moov）超过 maxBytes 时，仍对已读入的部分做安全解析。
      final actualBoxEnd = boxEnd < end ? boxEnd : end;

      if (type == 'st3d') {
        // `st3d`：4 字节 version/flags + 1 字节 `stereo_mode`。
        // 映射：0 → mono，1 → topBottom，2 → sideBySide，其余 → null。
        if (payloadStart + 5 <= actualBoxEnd) {
          final mode = data.getUint8(payloadStart + 4);
          switch (mode) {
            case 0:
              ctx.stereoLayout = VrStereoLayout.mono;
            case 1:
              ctx.stereoLayout = VrStereoLayout.topBottom;
            case 2:
              ctx.stereoLayout = VrStereoLayout.sideBySide;
            default:
              ctx.stereoLayout = null;
          }
        }
      } else if (type == 'sv3d') {
        // `sv3d`：存在即视作球面投影。
        // 只有 `sv3d` 而找不到 `equi` ⇒ projection 返回 equirect360（保守：sv3d 的语义就是球面全景）。
        ctx.projection = VrProjection.equirect360;
        // 递归进入 sv3d 内部寻找 proj -> equi。
        _parseBoxes(data, payloadStart, actualBoxEnd, ctx);
      } else if (type == 'equi') {
        // 找到 `equi` box ⇒ 等距投影。`equi` 的 4 字节 version/flags 之后是 4 个 uint32
        // （projection_bounds_top/bottom/left/right，0.32 定点数）。
        // left/right 都为 0 且 top/bottom 都为 0 ⇒ 全景 ⇒ equirect360；否则 ⇒ equirect180。
        if (payloadStart + 20 <= actualBoxEnd) {
          final top = data.getUint32(payloadStart + 4);
          final bottom = data.getUint32(payloadStart + 8);
          final left = data.getUint32(payloadStart + 12);
          final right = data.getUint32(payloadStart + 16);
          if (top == 0 && bottom == 0 && left == 0 && right == 0) {
            ctx.projection = VrProjection.equirect360;
          } else {
            ctx.projection = VrProjection.equirect180;
          }
        }
      } else if (type == 'stsd') {
        // 标准 MP4 结构中，visual sample entry (avc1 等) 位于 stsd 内部。
        // stsd 是 FullBox，跳过 4 字节 version/flags + 4 字节 entry_count 共 8 字节。
        const stsdHeader = 8;
        if (payloadStart + stsdHeader <= actualBoxEnd) {
          _parseBoxes(data, payloadStart + stsdHeader, actualBoxEnd, ctx);
        }
      } else if (_visualSampleEntries.contains(type)) {
        // ⚠️ 视觉样本条目（avc1 等）前 78 字节是固定头，子 box 从第 78 字节开始，
        // 进入时要跳过这 78 字节。
        const visualHeader = 78;
        if (payloadStart + visualHeader <= actualBoxEnd) {
          _parseBoxes(data, payloadStart + visualHeader, actualBoxEnd, ctx);
        }
      } else if (_plainContainers.contains(type)) {
        _parseBoxes(data, payloadStart, actualBoxEnd, ctx);
      }

      // 如果两个信号都已确凿获取，提早结束后续 box 的无谓遍历。
      if (ctx.projection != null && ctx.stereoLayout != null) {
        return;
      }

      if (size32 == 0) {
        break;
      }

      offset = boxEnd;
    }
  }

  /// 读取 4 字节 ASCII box type。若含非打印 ASCII 字符则返回 null。
  static String? _readFourCc(ByteData data, int offset) {
    if (offset + 4 > data.lengthInBytes) return null;
    final chars = <int>[];
    for (var i = 0; i < 4; i++) {
      final b = data.getUint8(offset + i);
      if (b < 0x20 || b > 0x7E) return null;
      chars.add(b);
    }
    return String.fromCharCodes(chars);
  }
}

class _ParseContext {
  VrProjection? projection;
  VrStereoLayout? stereoLayout;
}
