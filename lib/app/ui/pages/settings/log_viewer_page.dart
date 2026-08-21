import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 日志查看器（诊断页入口）。
///
/// 玻璃化改造：
/// - 旧 AppBar 的 BackdropFilter blur 违反「无 blur 纯渐变」，整页换
///   [GlassSettingsScaffold]（GlassHeaderOverlay 渐变蒙层）。
/// - 级别筛选从 FilterChip 换成玻璃多选胶囊（选中态底/边/字色同一段过渡）。
/// - 「跳到底部」浮钮从 FAB 挪进 header 动作位，出现/消失走
///   [GlassGroupSlot] 平滑挤入挤出。
/// - 复制反馈从 SnackBar 换 [showGlassToast]。
class LogViewerPage extends StatefulWidget {
  final bool isWideScreen;

  const LogViewerPage({required this.isWideScreen, super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<LogEvent> _allLogs = [];
  List<LogEvent> _filteredLogs = [];
  final Set<LogLevel> _activeFilters = LogLevel.values.toSet();
  String _searchText = '';
  bool _autoScroll = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadLogs();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 50;
    if (_autoScroll != atBottom) {
      setState(() => _autoScroll = atBottom);
    }
  }

  void _loadLogs() {
    if (!Get.isRegistered<LogService>()) return;
    final logService = Get.find<LogService>();
    final logs = logService.getRecentLogs();

    if (!mounted) return;

    // Check both length and last entry to detect changes when buffer is full
    final changed =
        logs.length != _allLogs.length ||
        (logs.isNotEmpty &&
            _allLogs.isNotEmpty &&
            logs.last.timestamp != _allLogs.last.timestamp);

    if (changed) {
      setState(() {
        _allLogs = logs;
        _applyFilters();
      });
      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  void _applyFilters() {
    _filteredLogs = _allLogs.where((event) {
      if (!_activeFilters.contains(event.level)) return false;
      if (_searchText.isNotEmpty) {
        final query = _searchText.toLowerCase();
        return event.message.toLowerCase().contains(query) ||
            event.tag.toLowerCase().contains(query) ||
            (event.error?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _jumpToBottom() {
    setState(() => _autoScroll = true);
    _scrollToBottom();
  }

  void _toggleFilter(LogLevel level) {
    setState(() {
      if (_activeFilters.contains(level)) {
        if (_activeFilters.length > 1) {
          _activeFilters.remove(level);
        }
      } else {
        _activeFilters.add(level);
      }
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.t;

    return GlassSettingsScaffold(
      title: t.logViewer.title,
      isWideScreen: widget.isWideScreen,
      controller: _scrollController,
      // 不在底部时才出现「跳到底部」；GlassGroupSlot 让它平滑进出而不是闪现
      actions: [
        GlassGroupSlot(
          visible: !_autoScroll,
          child: GlassIconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: _jumpToBottom,
          ),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(child: _buildFilterArea(context, theme, t)),
        if (_filteredLogs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                t.logViewer.emptyState,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _LogEntryWidget(
                  event: _filteredLogs[index],
                  theme: theme,
                ),
                childCount: _filteredLogs.length,
              ),
            ),
          ),
      ],
    );
  }

  /// 搜索框 + 级别筛选胶囊 + 命中计数。
  Widget _buildFilterArea(
    BuildContext context,
    ThemeData theme,
    slang.Translations t,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Column(
        children: [
          GlassInputSurface(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _searchController,
              style: theme.textTheme.bodySmall,
              decoration: glassFieldDecoration(
                context,
                hint: t.logViewer.searchHint,
                icon: Icons.search,
              ).copyWith(
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  _applyFilters();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...LogLevel.values.where((l) => l != LogLevel.fatal).map((level) {
                final isActive = _activeFilters.contains(level);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _LevelChip(
                    label: level.label,
                    color: _getLevelColor(level, theme),
                    active: isActive,
                    onTap: () => _toggleFilter(level),
                  ),
                );
              }),
              const Spacer(),
              Text(
                '${_filteredLogs.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(LogLevel level, ThemeData theme) {
    switch (level) {
      case LogLevel.debug:
        return theme.colorScheme.outline;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
      case LogLevel.fatal:
        return theme.colorScheme.error;
    }
  }
}

/// 级别筛选胶囊：底色 / 描边 / 文字三色一起经 [GlassAnimatedColors] 过渡，
/// 选中读起来是「点亮」，未选中是「熄灭」，而不是 FilterChip 的硬切。
class _LevelChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _LevelChip({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassAnimatedColors(
      colors: [
        active ? Color.alphaBlend(color.withValues(alpha: 0.22), GlassTokens.fill(cs)) : GlassTokens.fill(cs),
        active ? color : cs.onSurfaceVariant,
        active ? color.withValues(alpha: 0.7) : GlassTokens.stroke(cs),
      ],
      builder: (context, c) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: c[0],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c[2], width: GlassTokens.strokeWidth),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: c[1],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogEntryWidget extends StatelessWidget {
  final LogEvent event;
  final ThemeData theme;

  const _LogEntryWidget({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(event.level);
    final hasDetails = event.error != null || event.stackTrace != null;

    return InkWell(
      onLongPress: () {
        final text = StringBuffer();
        text.writeln(
          '[${event.formattedTime}] [${event.level.label}] [${event.tag}]',
        );
        text.writeln(event.message);
        if (event.error != null) text.writeln('Error: ${event.error}');
        if (event.stackTrace != null) {
          text.writeln('Stack: ${event.stackTrace}');
        }
        Clipboard.setData(ClipboardData(text: text.toString()));
        showGlassToast(
          slang.t.logViewer.copiedToClipboard,
          type: GlassToastType.success,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 14,
              margin: const EdgeInsets.only(top: 2, right: 6),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            Text(
              event.formattedTime,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                event.tag,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.message,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: event.level.value >= LogLevel.error.value
                          ? levelColor
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasDetails)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.error ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: levelColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return theme.colorScheme.outline;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
      case LogLevel.fatal:
        return theme.colorScheme.error;
    }
  }
}
