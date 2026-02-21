import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
    final atBottom = _scrollController.offset >=
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
    final changed = logs.length != _allLogs.length ||
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final t = slang.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.logViewer.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: !widget.isWideScreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                // Search bar
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    style: theme.textTheme.bodySmall,
                    decoration: InputDecoration(
                      hintText: t.logViewer.searchHint,
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 18),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 6),
                // Filter chips row
                Row(
                  children: [
                    ...LogLevel.values
                        .where((l) => l != LogLevel.fatal)
                        .map((level) {
                      final isActive = _activeFilters.contains(level);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(
                            level.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? _getLevelColor(level, theme)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          selected: isActive,
                          onSelected: (_) => _toggleFilter(level),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          showCheckmark: false,
                          side: BorderSide(
                            color: isActive
                                ? _getLevelColor(level, theme)
                                : theme.dividerColor.withValues(alpha: 0.3),
                          ),
                          backgroundColor: Colors.transparent,
                          selectedColor: _getLevelColor(level, theme)
                              .withValues(alpha: 0.1),
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
          ),
          const Divider(height: 1),
          // Log list
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      t.logViewer.emptyState,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredLogs.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemBuilder: (context, index) {
                      return _LogEntryWidget(
                        event: _filteredLogs[index],
                        theme: theme,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: !_autoScroll
          ? FloatingActionButton.small(
              onPressed: () {
                setState(() => _autoScroll = true);
                _scrollToBottom();
              },
              child: const Icon(Icons.arrow_downward, size: 18),
            )
          : null,
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
            '[${event.formattedTime}] [${event.level.label}] [${event.tag}]');
        text.writeln(event.message);
        if (event.error != null) text.writeln('Error: ${event.error}');
        if (event.stackTrace != null) {
          text.writeln('Stack: ${event.stackTrace}');
        }
        Clipboard.setData(ClipboardData(text: text.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(slang.t.logViewer.copiedToClipboard),
            duration: Duration(seconds: 1),
          ),
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
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
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
