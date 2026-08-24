import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/saved_search_config_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 头部行占位（不含状态栏）：上边距 16 + 玻璃圆钮 44 + 下留白 4。
/// 列表用 paddingTop 让出「状态栏 + 这段」的高度，让卡片可以从玻璃
/// header 背后一直滚到抽屉顶端（与页面 GlassHeaderOverlay 同款）。
const double _kHeaderExtent = 16 + 44 + 4;

/// 底部排序提示行占位（不含底部安全区）：上边距 8 + 玻璃胶囊 32 + 下边距 16。
const double _kFooterExtent = 8 + 32 + 16;

/// 右侧抽屉：展示并管理当前栏目（视频/图库）已保存的快速筛选配置。
/// 支持点击应用、删除、重命名、拖动排序，以及保存当前筛选为新配置。
///
/// 液态玻璃风格：条目为玻璃卡片，头部动作键 / 关闭钮与命名弹窗的确认键
/// 一律走 [GlassIconButton] / 玻璃输入框（与 add_video_to_playlist_dialog
/// 同一套配方）。
class SavedSearchConfigDrawer extends StatelessWidget {
  final String segment;

  /// 应用某个已保存配置。
  final void Function(SavedSearchConfig config) onApply;

  /// 将「当前激活的筛选条件」保存为一条新配置。
  final VoidCallback onAddCurrent;

  const SavedSearchConfigDrawer({
    super.key,
    required this.segment,
    required this.onApply,
    required this.onAddCurrent,
  });

  SavedSearchConfigService get _service => Get.find<SavedSearchConfigService>();

  /// 弹出命名对话框，把「当前激活的筛选条件」保存为一条新配置。
  ///
  /// 热门视频/图库与订阅页的 header 共用这一个入口，保证各页保存出的
  /// 配置结构、默认命名规则完全一致。
  static Future<void> promptSaveCurrent({
    required String segment,
    required List<Tag> tags,
    required String date,
    required String rating,
  }) async {
    final name = await _promptName(
      title: t.savedSearchConfig.namePromptTitle,
      hint: t.savedSearchConfig.nameHint,
      initialText: _buildDefaultConfigName(
        tags: tags,
        date: date,
        rating: rating,
      ),
    );
    if (name == null) return;

    final config = SavedSearchConfig(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.isEmpty
          ? _buildDefaultConfigName(tags: tags, date: date, rating: rating)
          : name,
      tags: List<Tag>.from(tags),
      date: date,
      rating: rating,
    );
    await Get.find<SavedSearchConfigService>().add(segment, config);
    showGlassToast(
      t.savedSearchConfig.saveSuccess,
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  /// 玻璃风格的命名输入弹窗：标题 + 关闭圆钮 + 玻璃输入框 + 主色确认钮。
  /// 保存 / 重命名共用；返回 null 表示取消，否则为 trim 后的输入。
  static Future<String?> _promptName({
    required String title,
    required String hint,
    String initialText = '',
  }) {
    final controller = TextEditingController(text: initialText);
    return showAppDialog<String>(
      Builder(
        builder: (dialogContext) {
          final colorScheme = Theme.of(dialogContext).colorScheme;
          void submit() =>
              Navigator.of(dialogContext).pop(controller.text.trim());
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行：标题 + 玻璃关闭圆钮
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(dialogContext).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      GlassIconButton(
                        standalone: true,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 玻璃输入框 + 主色确认钮
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: GlassTokens.fill(colorScheme),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: GlassTokens.stroke(colorScheme),
                              width: 0.6,
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.label_outline,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => submit(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: submit,
                        tooltip: slang.t.common.save,
                        icon: const Icon(Icons.check),
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 根据筛选条件生成一个默认名称（评级/日期/标签数）。
  static String _buildDefaultConfigName({
    required List<Tag> tags,
    required String date,
    required String rating,
  }) {
    final parts = <String>[];
    if (rating.isNotEmpty) {
      final r = MediaRating.values.firstWhere(
        (e) => e.value == rating,
        orElse: () => MediaRating.ALL,
      );
      if (r != MediaRating.ALL) parts.add(r.label);
    }
    if (date.isNotEmpty) parts.add(date);
    if (tags.isNotEmpty) {
      parts.add(t.savedSearchConfig.tagsCount(count: tags.length));
    }
    return parts.isEmpty ? t.savedSearchConfig.noConditions : parts.join(' · ');
  }

  /// 条目摘要：评级 · 日期 · 标签名（直接展示标签内容而不是只报数量）。
  String _summaryOf(BuildContext context, SavedSearchConfig config) {
    final t = slang.Translations.of(context);
    final parts = <String>[];

    if (config.rating.isNotEmpty) {
      final rating = MediaRating.values.firstWhere(
        (r) => r.value == config.rating,
        orElse: () => MediaRating.ALL,
      );
      if (rating != MediaRating.ALL) parts.add(rating.label);
    }
    if (config.date.isNotEmpty) parts.add(config.date);
    parts.addAll(config.tags.map((tag) => '#${tag.id}'));

    if (parts.isEmpty) return t.savedSearchConfig.noConditions;
    return parts.join(' · ');
  }

  Future<void> _renameConfig(
    BuildContext context,
    SavedSearchConfig config,
  ) async {
    final t = slang.Translations.of(context);
    final newName = await _promptName(
      title: t.savedSearchConfig.rename,
      hint: t.savedSearchConfig.nameHint,
      initialText: config.name,
    );
    if (newName != null && newName.isNotEmpty) {
      await _service.rename(segment, config.id, newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // 状态栏 / 手势条高度并入占位：列表铺满整个抽屉（含安全区），
    // 靠渐变蒙层保证状态栏与提示行的可读性，不做 SafeArea 硬切。
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double headerExtent = statusBarHeight + _kHeaderExtent;
    final double footerExtent = _kFooterExtent + safeBottom;

    return Drawer(
      width: 320,
      // 蒙层铺满整宽，靠 clip 收进抽屉自身的圆角
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 主体：列表铺满整个抽屉，用 paddingTop 让出 header 高度，
          // 让卡片可以从玻璃 header 背后滚过去。
          Positioned.fill(
            child: Obx(() {
              final list = _service.listFor(segment);
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: headerExtent),
                  child: Center(
                    child: MyEmptyWidget(message: t.savedSearchConfig.empty),
                  ),
                );
              }
              return ReorderableListView.builder(
                // 与页面 GlassHeaderOverlay 配方一致：首卡片紧跟 header
                // 底部出现（蒙层渐变尾巴压在首卡片上属于预期效果）；
                // 底部让出提示胶囊 + 少量呼吸。
                padding: EdgeInsets.fromLTRB(
                  16,
                  headerExtent,
                  16,
                  footerExtent + 8,
                ),
                itemCount: list.length,
                buildDefaultDragHandles: false,
                onReorderItem: (oldIndex, newIndex) =>
                    _service.reorder(segment, oldIndex, newIndex),
                proxyDecorator: (child, index, animation) {
                  // 拖起时轻微放大，玻璃卡片自带投影，不再叠 Material 阴影
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => Transform.scale(
                      scale: 1.0 + 0.04 * animation.value,
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final config = list[index];
                  final displayName = config.name.isNotEmpty
                      ? config.name
                      : t.savedSearchConfig.unnamed;
                  return Padding(
                    key: ValueKey(config.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassSurface(
                      height: 72,
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onTap: () => onApply(config),
                      child: Center(
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.drag_handle,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _summaryOf(context, config),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GlassIconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: t.savedSearchConfig.rename,
                              onPressed: () => _renameConfig(context, config),
                            ),
                            GlassIconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              tooltip: t.common.delete,
                              onPressed: () =>
                                  _service.remove(segment, config.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          // 顶部渐变蒙层：与页面 GlassHeaderOverlay 完全同款--恒定不透明段
          // 只有状态栏高度，header 行本身处在渐变段里（越向下越透），
          // 再向下延伸 GlassTokens.headerFadeExtent 淡出。
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: EdgeFadeScrim.top(
              height: headerExtent + GlassTokens.headerFadeExtent,
              solidExtent: statusBarHeight,
            ),
          ),
          // 顶部玻璃控件行：标题 + 保存当前筛选 + 关闭
          //
          // ⭐ 抽屉挂在 Navigator 之外，够不到页面的 LiquidGlassScope，也不经过
          // 弹窗/弹层那两条会自动供档的路由——不自己包一层，这几枚键会静默落回
          // 传统档（同 GlobalDrawerContent 的悬浮键，做法一致）。
          // ⛔ scope 只包这一行和下面的底部提示胶囊，**不包列表**：列表项自己
          // 也是 GlassSurface，而它在 ReorderableListView 里，lens 不该进滚动
          // 容器（见 liquid_glass_material.dart 约束 2）。
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LiquidGlassScope(
              backend: kChromeGlassBackend,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.savedSearchConfig.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      tooltip: t.savedSearchConfig.addCurrent,
                      onPressed: onAddCurrent,
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.close),
                      tooltip: t.common.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 底部渐变蒙层：与首页浮动底栏同款--恒定不透明段只有手势条高度，
          // 其余靠渐变淡出；提示文字放进小玻璃胶囊保证可读。
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EdgeFadeScrim.bottom(
              height: footerExtent + GlassTokens.bottomFadeExtent,
              solidExtent: safeBottom,
            ),
          ),
          // 底部排序提示胶囊
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LiquidGlassScope(
              backend: kChromeGlassBackend,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + safeBottom),
                child: Center(
                  child: GlassSurface(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.savedSearchConfig.reorderHint,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
