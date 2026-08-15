import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/mpv_shader_failure_detector.dart';

/// 这些样本的文案格式取自随包 libmpv 二进制里的格式串，
/// 目的是锁住「Anime4K 黑屏兜底」的触发条件（见 issue #109）。
void main() {
  bool check(String prefix, String level, String text) =>
      MpvShaderFailureDetector.isRenderFailure(
        prefix: prefix,
        level: level,
        text: text,
      );

  group('识别为渲染失败', () {
    test('GL 错误：枚举值不带 GL_ 前缀且用下划线分词', () {
      // mpv: "%s: OpenGL error %s." —— 这条最容易被朴素关键字漏掉
      expect(
        check(
          'vo/gpu/opengl',
          'error',
          'after creating texture: OpenGL error OUT_OF_MEMORY.',
        ),
        isTrue,
      );
      expect(
        check(
          'vo/gpu/opengl',
          'error',
          'after creating framebuffer: OpenGL error INVALID_OPERATION.',
        ),
        isTrue,
      );
    });

    test('FBO 完整性检查失败', () {
      expect(
        check(
          'vo/gpu',
          'error',
          'Error: framebuffer completeness check failed (error=36054).',
        ),
        isTrue,
      );
    });

    test('纹理格式不受支持', () {
      expect(
        check(
          'vo/gpu',
          'error',
          'Trying to create renderable texture with unsupported format.',
        ),
        isTrue,
      );
    });

    test('用户着色器解析失败', () {
      expect(check('vo/gpu', 'error', "Unrecognized command 'SAVE'!"), isTrue);
      expect(check('vo/gpu', 'error', 'Error while parsing SIZE!'), isTrue);
    });

    test('桌面端 render API 前缀 libmpv_render', () {
      // 桌面端 media_kit 用 vo=libmpv，GL 错误走这个日志器
      expect(
        check(
          'libmpv_render',
          'error',
          'after uploading: OpenGL error OUT_OF_MEMORY.',
        ),
        isTrue,
      );
    });

    test('fatal 级别同样处理，大小写与空白不敏感', () {
      expect(
        check(' VO/GPU ', ' FATAL ', 'Shader compilation FAILED'),
        isTrue,
      );
    });
  });

  group('不应识别为渲染失败', () {
    test('非渲染器前缀的同类文案', () {
      // 解码器 OOM 与 Anime4K 无关，不能误伤用户设置
      expect(check('vd', 'error', 'Out of memory'), isFalse);
      expect(
        check('ffmpeg/video', 'error', 'Failed to compile shader'),
        isFalse,
      );
    });

    test('渲染器前缀但非 error/fatal 级别', () {
      expect(
        check('vo/gpu', 'warn', 'framebuffer completeness check failed'),
        isFalse,
      );
      expect(check('vo/gpu/opengl', 'v', '16 bit UNORM textures not available.'),
          isFalse);
    });

    test('渲染器 error 但与着色器管线无关', () {
      expect(
        check('vo/gpu', 'error', 'Could not create window for hwdec interop'),
        isFalse,
      );
    });

    test('前缀只是恰好以相同片段开头的其它模块', () {
      expect(check('vd/lavc', 'error', 'OpenGL error OUT_OF_MEMORY.'), isFalse);
    });
  });
}
