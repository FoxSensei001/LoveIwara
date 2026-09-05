/// 播放器底部**提示胶囊**那一槽的共用几何与密度规则。
///
/// 这一槽现在住着两条提示：续播提示（`ResumePositionTip`）与 VR 建议提示
/// （`VrSuggestionTip`）。两条长得一模一样不是巧合——它们受同一组硬约束：
///
/// - **住在底部工具栏的 Column 里**，位置由布局算出来，不拿
///   `bottomToolbarEstimatedHeight` 的**估算值**去猜偏移量（估算是给别的图层预留
///   空间用的，拿它定位迟早会和真实高度对不上而叠到播放条上）。
/// - **强制单行**。窄屏靠文字 [Flexible] + 省略号收缩，绝不换行：一旦允许换行，
///   高度就有两套，上面那本账立刻不准。
/// - **按优先级逐层脱衣服**而不是换行：先丢装饰，最后才让动作按钮的文字也省略。
///
/// 所以几何常量必须只有一份，并且与 `bottomToolbarEstimatedHeight` 共用——否则
/// 改了布局却忘了改估算，就变成「预留对不上真实高度」（`bottom_toolbar_widget`
/// 文件头记的 64/108 两个魔数就是这么来的）。
///
/// ⚠️ 符号名里的 `ResumeTip` 是历史称呼（这一槽最早只有续播提示），现在指的是
/// 整槽。改名会牵动闸门与既有测试，收益不抵噪音，故留着。
library;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';

/// 提示与下方进度条之间。
const double kResumeTipGap = 8.0;

/// 提示胶囊上下内边距。
const double kResumeTipVPad = 4.0;

/// 提示胶囊左右内边距。
const double kResumeTipHPad = 10.0;

/// 动作按钮的高度。触摸端给大一些——它是这条提示上唯一的操作，按不中比看不见
/// 更让人恼火；桌面端指针精确，收紧以免这条提示占掉太多画面。
final double kResumeTipActionHeight = switch (defaultTargetPlatform) {
  TargetPlatform.android ||
  TargetPlatform.iOS ||
  TargetPlatform.fuchsia => 32.0,
  _ => 26.0,
};

double resumeTipFontSize({required bool isFullScreen}) =>
    isFullScreen ? 13.0 : 11.5;

const double kResumeTipGapInner = 6.0;
const double kResumeTipGapTight = 2.0;
const double kResumeTipActionHPad = 10.0;

/// 文字至少要留出这么宽，否则省略号之后什么都读不到。
const double kResumeTipMinTextWidth = 40.0;

/// 提示条的显示密度。窄屏不是靠换行解决的（换行会让高度估算变成两套），
/// 而是**按优先级逐层脱衣服**：先丢装饰，最后才让动作按钮的文字也省略。
enum ResumeTipDensity {
  /// 图标 + 文字 + 动作 + 关闭
  full,

  /// 文字 + 动作（丢掉图标与关闭钮——它们是装饰，提示到点本来就自动消失）
  compact,

  /// 极窄：动作按钮的文字也允许省略，只求绝不溢出
  minimal,
}

/// 按可用宽度决定显示密度。
///
/// 传进来的宽度都是**实测值**（TextPainter 量的），不是拍脑袋的阈值：
/// 中日英三种语言、不同字号、系统字体放大，同一个阈值不可能都合适。
///
/// ⚠️ 曾经标着 `@visibleForTesting`（那时只有续播提示一家用，函数与调用点同文件）。
/// 现在两条提示各自在自己的文件里调它，它就是正经的公开 API 了。
ResumeTipDensity resolveResumeTipDensity({
  required double maxWidth,
  required double actionWidth,
  required double iconWidth,
  required double closeWidth,
}) {
  final double content = maxWidth - kResumeTipHPad * 2;
  final double compactNeed =
      kResumeTipMinTextWidth + kResumeTipGapInner + actionWidth;
  final double fullNeed =
      iconWidth +
      kResumeTipGapInner +
      compactNeed +
      kResumeTipGapTight +
      closeWidth;
  if (content >= fullNeed) return ResumeTipDensity.full;
  if (content >= compactNeed) return ResumeTipDensity.compact;
  return ResumeTipDensity.minimal;
}

/// 量一段文字实际多宽。阈值必须来自实测：中日英三种语言、不同字号、
/// 系统字体放大，同一个写死的阈值不可能都合适。
double measurePlayerTipText(String text, TextStyle style, TextScaler scaler) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// 一条提示胶囊占多高：`Padding(bottom gap)` + `Container(vertical vPad × 2)`
/// + `Row` 高度（= max(文字行盒, 动作按钮)）。
///
/// 1.45 是中日韩字体的行高比（Noto Sans CJK / PingFang）；主题没设 textTheme 的
/// height，行高由字体决定，这里按最坏情况预留。
double playerTipCapsuleHeight({
  required bool isFullScreen,
  required TextScaler textScaler,
}) {
  final double line =
      textScaler.scale(resumeTipFontSize(isFullScreen: isFullScreen)) * 1.45;
  return kResumeTipGap +
      kResumeTipVPad * 2 +
      (line > kResumeTipActionHeight ? line : kResumeTipActionHeight);
}
