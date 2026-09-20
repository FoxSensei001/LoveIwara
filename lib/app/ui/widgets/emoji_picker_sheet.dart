import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 表情选择器。
///
/// # 这一版改了什么，以及为什么
///
/// 旧版是「左侧 80px 分组 rail + 右侧固定 4 列网格」，装在一只自建的
/// `DraggableScrollableSheet` 壳里。四个问题：
///
/// 1. **rail 在 360dp 屏上吃掉 22% 的宽度**，而它承载的只是几个分组名。改成
///    顶部横向分组条之后，这 80px 全部还给了表情本身。
/// 2. **列数写死 4**：窄屏上格子挤、平板上格子大得离谱。改成按可用宽度算。
/// 3. **自建壳不走 [GlassBottomSheet]**，材质与全站其它弹层对不上（旧文件里
///    的注释自己承认了这点）。
/// 4. **骨架屏写死 `Colors.grey[300]`**，深色模式下是一片刺眼的亮块。
///
/// 另外补了两件事：
///
/// - **最近用过**排在第一格。斗图是这个站的核心玩法，「再发一次刚才那张」是
///   最高频的动作，而旧版每次都得重新翻到那一组。存在
///   [ConfigKey.RECENT_EMOJIS_KEY]。
/// - **选完不自动关**。旧版由调用点在回调里 `Navigator.pop`，于是连发三张表情
///   要开三次弹层。现在插入之后弹层留在原地，底部实时显示这次插了几个，用户
///   自己决定什么时候收。
class EmojiPickerSheet extends StatefulWidget {
  const EmojiPickerSheet({
    super.key,
    required this.onEmojiSelected,
    required this.onSizeChanged,
    this.initialSize = EmojiSize.medium,
  });

  /// 插入一个表情。⛔ **不要在这个回调里关闭弹层**——连选是刻意的。
  final void Function(String imageUrl, EmojiSize size) onEmojiSelected;
  final void Function(EmojiSize) onSizeChanged;
  final EmojiSize initialSize;

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> {
  /// 一个表情格子的目标边长。列数由可用宽度除以它算出来，而不是写死——
  /// 写死列数的话，同一份网格在 360dp 手机上挤成一团、在平板上又大得滑稽。
  static const double _cellTarget = 76;
  static const double _cellGap = 8;

  /// 「最近用过」最多记多少个。多了就不是「最近」了，还会把分组挤下去。
  static const int _recentLimit = 24;

  late final EmojiLibraryService _emojiService;
  late final ConfigService _configService;

  late EmojiSize _selectedSize;
  List<EmojiGroup> _groups = const [];
  List<String> _recent = const [];

  /// 当前选中的格子：0 是「最近」（有内容时才在），其余是分组。
  int _tab = 0;
  bool _loading = true;

  /// 这次开着弹层一共插了几个，显示在底部。连选没有这个反馈的话，用户不确定
  /// 刚才那一下到底有没有插进去（输入框被弹层盖住了看不见）。
  int _inserted = 0;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
    _emojiService = Get.find<EmojiLibraryService>();
    _configService = Get.find<ConfigService>();
    _recent = _readRecent();
    _load();
  }

  void _load() {
    try {
      _groups = _emojiService.getEmojiGroups();
    } catch (_) {
      _groups = const [];
    }
    if (mounted) setState(() => _loading = false);
  }

  // ── 最近用过 ──────────────────────────────────────────────

  List<String> _readRecent() {
    try {
      final raw = _configService[ConfigKey.RECENT_EMOJIS_KEY] as String;
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list.whereType<String>().toList(growable: false);
    } catch (_) {
      // 存坏了就当没有，不要因为一条历史记录把整个选择器炸掉
      return const [];
    }
  }

  void _pushRecent(String url) {
    final next = <String>[url, ..._recent.where((u) => u != url)];
    if (next.length > _recentLimit) next.removeRange(_recentLimit, next.length);
    _recent = next;
    _configService[ConfigKey.RECENT_EMOJIS_KEY] = jsonEncode(next);
  }

  // ── 事件 ────────────────────────────────────────────────

  void _pick(String url) {
    widget.onEmojiSelected(url, _selectedSize);
    setState(() {
      _inserted++;
      final hadRecent = _recent.isNotEmpty;
      _pushRecent(url);
      // 第一次用之后「最近」这一格才长出来，此时后面的分组整体右移一位，
      // 当前选中的那一格要跟着挪，否则用户会发现自己突然换了组。
      // ⛔ 不加 `_tab > 0` 的条件：第 0 格原先是第一个分组，长出「最近」之后
      // 第 0 格变成了「最近」，不挪的话用户正看着的那一组会当场被换掉。
      if (!hadRecent) _tab++;
    });
  }

  void _changeSize(EmojiSize size) {
    setState(() => _selectedSize = size);
    widget.onSizeChanged(size);
  }

  bool get _hasRecent => _recent.isNotEmpty;

  /// 当前这一格要显示哪些图。
  List<String> get _currentUrls {
    if (_hasRecent && _tab == 0) return _recent;
    final index = _hasRecent ? _tab - 1 : _tab;
    if (index < 0 || index >= _groups.length) return const [];
    return _emojiService
        .getEmojiImages(_groups[index].groupId)
        .map((e) => e.thumbnailUrl ?? e.url)
        .toList(growable: false);
  }

  /// 点格子时要插入的**原图** url（网格里显示的是缩略图）。
  List<EmojiImage>? get _currentImages {
    if (_hasRecent && _tab == 0) return null;
    final index = _hasRecent ? _tab - 1 : _tab;
    if (index < 0 || index >= _groups.length) return null;
    return _emojiService.getEmojiImages(_groups[index].groupId);
  }

  // ── 构建 ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return GlassDraggableBottomSheet(
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, t),
          if (!_loading) _buildGroupStrip(context, t),
          Expanded(
            child: _loading
                ? _buildSkeleton(context)
                : _buildGrid(context, t, scrollController),
          ),
          _buildFooter(context, t),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Translations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.emoji.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.tune),
            tooltip: t.emoji.library,
            onPressed: () {
              Navigator.pop(context);
              NaviService.navigateToEmojiLibraryPage();
            },
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.close),
            tooltip: t.common.close,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// 顶部横向分组条，取代旧版左侧那条 80px 的 rail。
  ///
  /// 分组名是短词（「NG娘」「颜文字」），横排比竖排省地方得多；而且它和全站
  /// 其它 tab 的语言一致，不用再学一套。
  Widget _buildGroupStrip(BuildContext context, Translations t) {
    final cs = Theme.of(context).colorScheme;
    final labels = <String>[
      if (_hasRecent) t.emoji.recentlyUsed,
      for (final g in _groups) g.name,
    ];
    if (labels.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final bool on = i == _tab;
          return GlassPressable(
            onTap: () => setState(() => _tab = i),
            builder: (context, pressed) => AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on
                    ? cs.primary.withValues(alpha: pressed ? 0.26 : 0.18)
                    : cs.onSurface.withValues(alpha: pressed ? 0.12 : 0.05),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  if (i == 0 && _hasRecent) ...[
                    Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: on ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                      color: on ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    Translations t,
    ScrollController controller,
  ) {
    final urls = _currentUrls;
    if (urls.isEmpty) {
      return _buildEmpty(context, t);
    }
    final images = _currentImages;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 列数按可用宽度算，不写死
        final int columns =
            ((constraints.maxWidth - 24 + _cellGap) / (_cellTarget + _cellGap))
                .floor()
                .clamp(4, 10);
        return GridView.builder(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _cellGap,
            mainAxisSpacing: _cellGap,
          ),
          itemCount: urls.length,
          itemBuilder: (context, i) {
            // 网格里放缩略图，插进正文的是原图
            final String insertUrl = images != null && i < images.length
                ? images[i].url
                : urls[i];
            return _EmojiCell(
              thumbnailUrl: urls[i],
              onTap: () => _pick(insertUrl),
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, Translations t) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 44,
            color: cs.onSurface.withValues(alpha: 0.28),
          ),
          const SizedBox(height: 12),
          Text(
            _groups.isEmpty ? t.emoji.noEmojis : t.emoji.noEmojisInGroup,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          if (_groups.isEmpty) ...[
            const SizedBox(height: 14),
            GlassButtonGroup(
              children: [
                GlassTextActionButton(
                  label: t.emoji.addEmojis,
                  emphasized: true,
                  onPressed: () {
                    Navigator.pop(context);
                    NaviService.navigateToEmojiLibraryPage();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 骨架屏：用主题色的脉动，不用写死的灰。
  ///
  /// 旧版是 `Colors.grey[300]` / `Colors.grey[100]`，深色模式下是一片刺眼的
  /// 亮块；而且它把整套真实布局又抄了一遍（近 180 行），布局一改就对不上。
  Widget _buildSkeleton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns =
            ((constraints.maxWidth - 24 + _cellGap) / (_cellTarget + _cellGap))
                .floor()
                .clamp(4, 10);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _cellGap,
            mainAxisSpacing: _cellGap,
          ),
          itemCount: columns * 4,
          itemBuilder: (context, i) => _SkeletonCell(
            color: cs.onSurface.withValues(alpha: 0.07),
            delayIndex: i,
          ),
        );
      },
    );
  }

  /// 底栏：左边尺寸、右边本次插入计数。
  ///
  /// 尺寸从旧版的标题行挪到这里——它是「插入时用多大」，属于动作的参数，
  /// 和标题（这是什么弹层）不是一类东西。
  Widget _buildFooter(BuildContext context, Translations t) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          Builder(
            builder: (anchorContext) => GlassSurface(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              opensOverlay: true,
              onTap: () async {
                final picked = await showGlassMenu<EmojiSize>(
                  anchorContext: anchorContext,
                  entries: [
                    for (final size in EmojiSize.values)
                      GlassMenuOption<EmojiSize>(
                        value: size,
                        label: size.displayName,
                        selected: size == _selectedSize,
                      ),
                  ],
                );
                if (picked != null) _changeSize(picked);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${t.emoji.size} · ${_selectedSize.displayName}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.expand_more, size: 17, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 插入反馈：连选时输入框被弹层盖着，没有这个就不确定插没插进去。
          // 「有出有入」：它是淡入 + 撑开的，不是硬切出现。
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _inserted == 0
                ? const SizedBox.shrink()
                : Text(
                    t.emoji.insertedCount(count: _inserted),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 一枚表情格子。按下缩一点，给出「点到了」的反馈——连选时这个反馈尤其重要。
class _EmojiCell extends StatefulWidget {
  const _EmojiCell({required this.thumbnailUrl, required this.onTap});

  final String thumbnailUrl;
  final VoidCallback onTap;

  @override
  State<_EmojiCell> createState() => _EmojiCellState();
}

class _EmojiCellState extends State<_EmojiCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: widget.thumbnailUrl,
            fit: BoxFit.contain,
            httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => Icon(
              Icons.broken_image_outlined,
              size: 20,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// 骨架格子：整片一起呼吸会像坏掉的闪烁，按索引错开相位才读得出「在加载」。
class _SkeletonCell extends StatefulWidget {
  const _SkeletonCell({required this.color, required this.delayIndex});

  final Color color;
  final int delayIndex;

  @override
  State<_SkeletonCell> createState() => _SkeletonCellState();
}

class _SkeletonCellState extends State<_SkeletonCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    // ⛔ 顺序不能倒过来：`value` 的 setter 自带一次 stop()，先 repeat 再错峰
    // 会把动画当场停死，整片骨架冻在各自的静态透明度上。
    _c.value = (widget.delayIndex % 7) / 7;
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_c),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
