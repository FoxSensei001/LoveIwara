import 'package:flutter/rendering.dart';

/// 本机文件那几页共用的网格度量。
///
/// # 为什么不直接用 `SliverGridDelegateWithMaxCrossAxisExtent`
///
/// 因为这里的格子**不是等比例的**：一张目录卡＝一张 16:10 封面 + 一块高度写死的
/// 文字区，总高是 `宽 × 0.625 + 文字区`，不是 `宽 × 常数`。`childAspectRatio`
/// 表达不了这种「比例 + 常量」的高度，硬凑出来的比例在窄屏上文字被切、在宽屏上
/// 底下留一条空白。所以先算出**这一行到底几列、每格多宽**，再把精确的
/// `mainAxisExtent` 交给 `SliverGridDelegateWithFixedCrossAxisCount`。
///
/// 顺带解决另一件事：常用目录、来源、子目录、列表模式的行，全部从这里取列数，
/// 几个区块的边界才会对齐成一根竖线，而不是各算各的、错开几个像素。
class LocalGridMetrics {
  const LocalGridMetrics({
    required this.crossAxisCount,
    required this.cellWidth,
    required this.spacing,
  });

  final int crossAxisCount;
  final double cellWidth;
  final double spacing;

  /// 默认格间距，也是各页横向内边距的一半基准。
  static const double defaultSpacing = 12;

  /// 按「一格最宽不超过 [maxCellWidth]」铺满 [availableWidth]。
  ///
  /// [availableWidth] 传的是**已经扣掉页面左右内边距**的可用宽度。
  static LocalGridMetrics resolve({
    required double availableWidth,
    required double maxCellWidth,
    double spacing = defaultSpacing,
  }) {
    final safeWidth = availableWidth.isFinite && availableWidth > 0
        ? availableWidth
        : maxCellWidth;
    final count = (safeWidth / maxCellWidth).ceil().clamp(1, 12);
    final cellWidth = (safeWidth - spacing * (count - 1)) / count;
    return LocalGridMetrics(
      crossAxisCount: count,
      cellWidth: cellWidth <= 0 ? safeWidth : cellWidth,
      spacing: spacing,
    );
  }

  /// 每格高度固定为 [mainAxisExtent] 的网格。
  SliverGridDelegate delegate(double mainAxisExtent) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: mainAxisExtent,
      );

  /// 每格高度由卡片自己算：`delegate(LocalFolderCardWidget.extentFor(context, cellWidth))`。
  ///
  /// ⛔ 这里不再提供「封面比例 + 文字高度」那种拼装式的行高。卡片长什么样是卡片
  /// 自己的事（夹子的舌头、封面留边都会算进高度里），网格只该问它「这么宽你多
  /// 高」——把公式摊在调用点上，改一次外形就要满仓库找漏网的那一处。
}
