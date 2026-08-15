/// 判断一条 mpv 日志是否代表「渲染器 / 着色器管线失败」
///
/// 用于 Anime4K 的黑屏兜底：部分移动端 GPU（已知如麒麟 980 的 Mali-G76）在
/// mpv 的 glsl-shaders 非空后会离开 gpu-dumb-mode 进入 FBO 渲染路径，
/// 而这些驱动在该路径上直接失败，表现为「有声音但画面全黑」。
/// 失败发生在渲染阶段，`change-list glsl-shaders` 命令本身是成功返回的，
/// 只能靠日志发现，所以这里的匹配规则决定了兜底能不能真正生效。
///
/// 规则、关键字均按随包 libmpv 二进制里的实际文案核对得出，
/// 调整时请同步 test/utils/mpv_shader_failure_detector_test.dart。
class MpvShaderFailureDetector {
  MpvShaderFailureDetector._();

  /// mpv 渲染器日志前缀
  ///
  /// - Android：media_kit 用 `vo=gpu` + `gpu-context=android`，前缀为
  ///   `vo/gpu`、`vo/gpu/opengl`
  /// - 桌面端：media_kit 用 `vo=libmpv` + render API，mpv 为该渲染上下文
  ///   单独建了日志器（vo_libmpv.c: `mp_log_new(ctx, log, "libmpv_render")`），
  ///   FBO / 着色器错误以 `libmpv_render` 为前缀输出
  ///
  /// 限定前缀是为了不让解码、网络等无关错误误伤 Anime4K。
  static const List<String> renderPrefixes = [
    'vo/gpu',
    'vo/libmpv',
    'libmpv_render',
  ];

  /// 渲染失败关键字（全部小写，按 contains 匹配）
  ///
  /// 注意 mpv 的 GL 错误格式是 `"%s: OpenGL error %s."`，第二个 %s 取自
  /// INVALID_ENUM / INVALID_VALUE / INVALID_OPERATION /
  /// INVALID_FRAMEBUFFER_OPERATION / OUT_OF_MEMORY —— 既没有 `GL_` 前缀，
  /// 单词间也是下划线。所以必须用 `opengl error` 兜底，否则
  /// 「after creating texture: OpenGL error OUT_OF_MEMORY.」
  /// 这类最典型的失败会被整个漏掉。
  static const List<String> failureKeywords = [
    'shader', // "user shader: ...", "Could not create shader resource texture"
    'glsl',
    'compil', // "... compilation failed" / "failed to compile"
    'fbo',
    'framebuffer', // "framebuffer completeness check failed (error=%d)"
    'opengl error', // gl_check_error 的统一格式，覆盖全部 GL error 枚举
    'out of memory',
    'out_of_memory',
    'unsupported format', // "Trying to create renderable texture with unsupported format."
    'unrecognized', // user_shaders.c: "Unrecognized command/FILTER/BORDER '...'"
    'error while parsing', // user_shaders.c: "Error while parsing SIZE!"
  ];

  /// [prefix]、[level]、[text] 直接取自 media_kit 的 PlayerLog
  static bool isRenderFailure({
    required String prefix,
    required String level,
    required String text,
  }) {
    final normalizedLevel = level.trim().toLowerCase();
    if (normalizedLevel != 'error' && normalizedLevel != 'fatal') {
      return false;
    }

    final normalizedPrefix = prefix.trim().toLowerCase();
    if (!renderPrefixes.any(normalizedPrefix.startsWith)) {
      return false;
    }

    final normalizedText = text.toLowerCase();
    return failureKeywords.any(normalizedText.contains);
  }
}
