import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 「Seek Preview 只准有一份实现」的闸门。
///
/// # 为什么需要它
///
/// 进度条上方那扇预览窗口曾经被实现了两遍：主进度条
/// （`custom_slider_bar_shape_widget.dart`）一套，工具栏收起后那条底部细进度条
/// （`my_video_screen.dart`）又一套。两份代码连 `_tooltipWidth = 160`、
/// `width: 160, height: 90` 和整段边界钳制都是照抄的。
///
/// 这是本工作流反复撞见的同一种缺陷形状（初始封面守卫、六处播放/暂停开关、
/// 叶子作用域派发器）：同一件事实现在多处，然后各自漂移——改了一处，另一处
/// 悄悄留在旧行为上，而且**编译得过、analyze 干净、单测全绿**。
///
/// 所以修法不是「两处都改成响应式」，而是收成一份
/// （`seek_preview.dart` 的 `SeekPreview`），闸门钉在这里：
/// 谁再在别处自己画一遍预览画面，这个测试会红。
void main() {
  const String implementation =
      'lib/app/ui/pages/video_detail/widgets/player/seek_preview.dart';
  const List<String> callSites = [
    'lib/app/ui/pages/video_detail/widgets/player/custom_slider_bar_shape_widget.dart',
    'lib/app/ui/pages/video_detail/widgets/player/my_video_screen.dart',
  ];

  test('预览画面只在唯一实现里渲染（零容忍）', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      final path = _rel(file);
      if (path == implementation) continue;
      if (_rendersPreviewFrame(file.readAsStringSync())) offenders.add(path);
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '这些文件自己拿预览播放器画了一遍画面：$offenders\n'
          '预览窗口只有一份实现（$implementation 的 SeekPreview）。'
          '需要在新位置显示，就把 SeekPreview 摆过去，不要再抄一份——'
          '抄出来的那份不会跟着播放器尺寸和视频比例走。',
    );
  });

  test('两条已知路径都走同一只组件', () {
    for (final path in callSites) {
      final source = File(path).readAsStringSync();
      expect(
        source.contains('SeekPreview('),
        isTrue,
        reason: '$path 不再经过 SeekPreview：它要么被删了，要么又自己画了一份',
      );
    }
  });

  test('固定 160 x 90 的老盒子不许回来', () {
    final offenders = <String>[];
    for (final file in _dartFiles()) {
      final path = _rel(file);
      if (path == implementation) continue;
      final source = _stripComments(file.readAsStringSync());
      if (!source.contains('previewVideoController')) continue;
      if (_fixedTooltipBox.hasMatch(source)) offenders.add(path);
    }
    expect(
      offenders,
      isEmpty,
      reason:
          '这些文件又把预览窗口写死成固定尺寸：$offenders\n'
          '尺寸由 resolveSeekPreviewFrameSize 按播放器几何与视频宽高比推出来，'
          '写死的像素在竖屏手机内嵌播放器和横屏平板全屏之间没有共同意义。',
    );
  });
}

/// 这个源文件是不是自己拿「预览播放器」渲染了一块画面。
///
/// 判据是 `Video(` 的 `controller:` 实参里带 preview——预览播放器是
/// `MyVideoStateController.previewVideoController`，主播放器不是。
bool _rendersPreviewFrame(String rawSource) {
  final source = _stripComments(rawSource);
  for (final match in _videoWidget.allMatches(source)) {
    final int end = (match.end + 400).clamp(0, source.length);
    final String args = source.substring(match.end, end);
    final controller = _controllerArg.firstMatch(args);
    if (controller == null) continue;
    if (controller.group(1)!.toLowerCase().contains('preview')) return true;
  }
  return false;
}

/// `Video(`，但不含 `VideoController(`、`MyVideoScreen(` 这类。
final RegExp _videoWidget = RegExp(r'(?<![A-Za-z0-9_])Video\(');
final RegExp _controllerArg = RegExp(r'controller:\s*([^,\n]+)');
final RegExp _fixedTooltipBox = RegExp(r'width:\s*160\b[\s\S]{0,80}height:\s*90\b');

String _stripComments(String source) => source
    .split('\n')
    .map((line) {
      final idx = line.indexOf('//');
      return idx == -1 ? line : line.substring(0, idx);
    })
    .join('\n');

Iterable<File> _dartFiles() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String _rel(File file) => file.path.replaceFirst(RegExp(r'^\./'), '');
