import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart'
    show GlassSegmentItem;
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 路径模板编辑器（issue #126 子文件夹归档的逃生舱）。
///
/// 全屏二级页，三个 Tab（视频 / 图库 / 单张图片）各持一份独立草稿、一次保存。
/// 每层文件夹一个 monospace 文本框；底部变量托盘点按即插入（全程不用软键盘
/// 打 % 号），按内容 / 作者 / 时间三色分类；输入 `/` 自动拆段、`\` 即时替换
/// 为 `_`；预览渲染的是清洗后的真实落盘结果（所见即所得）。
///
/// 内容上限：视频 / 单图 = 3 层文件夹段 + 1 层文件名段；图库全部为文件夹段
/// 且最多 2 层（内部图片固定按「图片ID.扩展名」命名，不走模板）。
enum _SegmentTab { video, gallery, image }

/// 变量托盘 chip 的三色分类（沿用设计稿的语义色：内容蓝 / 作者绿 / 时间琥珀）。
enum _TrayCategory { content, author, time }

class _TrayChipSpec {
  final String token;
  final _TrayCategory category;

  /// chip 上的人话标签（%authorcache 特殊：按设计稿显示「作者名·固定」）。
  final String Function(slang.Translations t) label;
  const _TrayChipSpec(this.token, this.category, this.label);
}

class PathTemplateEditorPage extends StatefulWidget {
  const PathTemplateEditorPage({super.key});

  /// 全屏二级页走裸路由（先例：下载分类管理页——本页不入 URL，
  /// 且只从下载设置页一处进入）。
  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PathTemplateEditorPage()),
      );

  /// 草稿段数收敛：超过 [maxRows] 时把超出部分并入末行（与编辑器拆段到顶时
  /// 的「并回末段」同一约定）——内容一个字不丢，行内保留的 `/` 会在保存时被
  /// 「段数超限」准确拦下，用户改这一行即可收敛。
  static List<String> capDraftSegments(List<String> segments, int maxRows) {
    if (segments.length <= maxRows) return segments;
    return [
      ...segments.sublist(0, maxRows - 1),
      segments.sublist(maxRows - 1).join('/'),
    ];
  }

  @override
  State<PathTemplateEditorPage> createState() => _PathTemplateEditorPageState();
}

class _PathTemplateEditorPageState extends State<PathTemplateEditorPage> {
  static const _sampleVars = FilenameTemplateService.sampleVariables;

  final ConfigService _configService = Get.find<ConfigService>();

  _SegmentTab _activeTab = _SegmentTab.video;

  /// 三个 Tab 的独立草稿（每段一条字符串，保存时按 `/` join）。
  late final Map<_SegmentTab, List<String>> _drafts;

  /// 当前 Tab 的段编辑控制器 / 焦点（只在结构性变化后重建）。
  final List<TextEditingController> _rowControllers = [];
  final List<FocusNode> _rowFocusNodes = [];
  int _focusedRow = -1;

  /// 结构性拆段 / 删段 / 加段后要落焦的行号（materialize 时消费）。
  int _pendingFocusRow = 0;

  @override
  void initState() {
    super.initState();
    _drafts = {
      for (final tab in _SegmentTab.values) tab: _initialDraft(tab),
    };
    _materializeRows();
  }

  @override
  void dispose() {
    // 退役队列里可能还有没等到 post-frame 的上一代控制器，一并回收。
    for (final controller in [..._rowControllers, ..._retiredControllers]) {
      controller.dispose();
    }
    for (final node in [..._rowFocusNodes, ..._retiredFocusNodes]) {
      node.dispose();
    }
    super.dispose();
  }

  /// 本 Tab 的草稿行数上限：图库 2 行（全文件夹段）；视频/单图 3 层文件夹 + 1 层文件。
  static int _maxRowsFor(_SegmentTab tab) =>
      tab == _SegmentTab.gallery ? 2 : 4;

  /// 从 config 读当前模板拆段；值异常（空/全空段）时以出厂默认作草稿起点。
  List<String> _initialDraft(_SegmentTab tab) {
    final key = switch (tab) {
      _SegmentTab.video => ConfigKey.VIDEO_FILENAME_TEMPLATE,
      _SegmentTab.gallery => ConfigKey.GALLERY_FILENAME_TEMPLATE,
      _SegmentTab.image => ConfigKey.IMAGE_FILENAME_TEMPLATE,
    };
    final segments = FilenameTemplateService.splitTemplateSegments(
      _configService[key] as String? ?? '',
    );
    if (segments.isNotEmpty) {
      return PathTemplateEditorPage.capDraftSegments(segments, _maxRowsFor(tab));
    }
    return FilenameTemplateService.splitTemplateSegments(_defaultFor(tab));
  }

  static String _defaultFor(_SegmentTab tab) => switch (tab) {
    _SegmentTab.video => '%authorcache/%title_%quality',
    _SegmentTab.gallery => '%authorcache/%title_%id',
    _SegmentTab.image => '%authorcache/%title/%filename',
  };

  int get _maxFolders => switch (_activeTab) {
    _SegmentTab.gallery => 2,
    _ => 3,
  };

  /// 当前 Tab 是不是「最后一行是文件段」的结构（图库全为文件夹段）。
  bool get _hasFileRow => _activeTab != _SegmentTab.gallery;

  bool _isFileRow(int index) =>
      _hasFileRow && index == _drafts[_activeTab]!.length - 1;

  int get _folderCount =>
      _hasFileRow ? _drafts[_activeTab]!.length - 1 : _drafts[_activeTab]!.length;

  // ─────────────────────────── 行的物化 ───────────────────────────

  /// 上一代控制器/焦点节点的退役队列。拆段/切 Tab 发生在输入回调里，旧
  /// controller 此刻可能还在通知链和当前帧的组件树上（其中某个 focus node 正
  /// 持焦点）——框架对「dispose 后 removeListener」是容忍的，但等当前帧重建
  /// 完成、EditableText 解绑完再销毁才是无条件的稳。
  final List<TextEditingController> _retiredControllers = [];
  final List<FocusNode> _retiredFocusNodes = [];

  /// 用草稿重建当前 Tab 的控制器列表（只在拆段 / 删段 / 加段 / 切 Tab 时调用；
  /// 普通打字直接改草稿，不重建——否则光标会跳）。
  void _materializeRows() {
    _retiredControllers.addAll(_rowControllers);
    _retiredFocusNodes.addAll(_rowFocusNodes);
    _rowControllers.clear();
    _rowFocusNodes.clear();
    for (final segment in _drafts[_activeTab]!) {
      final controller = TextEditingController(text: segment);
      _rowControllers.add(controller);
      final node = FocusNode(onKeyEvent: _handleRowKeyEvent);
      node.addListener(() {
        if (node.hasFocus) {
          _focusedRow = _rowFocusNodes.indexOf(node);
        }
      });
      _rowFocusNodes.add(node);
    }
    if (_retiredControllers.isNotEmpty || _retiredFocusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // State 先于本回调销毁时，dispose() 已统一回收过退役队列，跳过防双销。
        if (!mounted) return;
        for (final controller in _retiredControllers) {
          controller.dispose();
        }
        for (final node in _retiredFocusNodes) {
          node.dispose();
        }
        _retiredControllers.clear();
        _retiredFocusNodes.clear();
      });
    }
    final target = _pendingFocusRow.clamp(0, _rowControllers.length - 1);
    _pendingFocusRow = target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _rowFocusNodes.isEmpty) return;
      _rowFocusNodes[target].requestFocus();
      _rowControllers[target].selection = TextSelection.collapsed(
        offset: _rowControllers[target].text.length,
      );
    });
  }

  /// 桌面端在文本框里按回车 = 拆段（与输入 `/` 等价），别让回车白白换行。
  KeyEventResult _handleRowKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      final index = _rowFocusNodes.indexOf(node);
      if (index >= 0) {
        _splitRow(index, '${_rowControllers[index].text}/');
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ─────────────────────────── 编辑行为 ───────────────────────────

  void _onRowChanged(int index, String raw) {
    final cleaned = raw.replaceAll('\\', '_');
    if (cleaned.contains('/')) {
      _splitRow(index, cleaned);
      return;
    }
    if (cleaned != raw) {
      // `\` 被替换过：把净化后的文本写回输入框（不动光标结构）。
      _rowControllers[index].value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    _drafts[_activeTab]![index] = cleaned;
    setState(() {}); // 刷新空段红描边与保存钮可用性
  }

  /// 把第 [index] 行按 `/` 拆成多段（行数到顶时，多余内容并入末段提示上限）。
  void _splitRow(int index, String value) {
    final t = slang.Translations.of(context);
    final rows = _drafts[_activeTab]!;
    var parts = value.split('/').map((part) => part.trim()).toList();
    // 中间的空段直接剔除（与 splitTemplateSegments 同语义）；输入只是分隔符
    // （比如敲了个 `/`）时留一个空段，让红描边告诉用户这里还没写完。
    final meaningful = parts.where((part) => part.isNotEmpty).toList();
    parts = meaningful.isEmpty ? [''] : meaningful;

    final room = (_maxFolders + (_hasFileRow ? 1 : 0) - (rows.length - 1)).clamp(
      1,
      parts.length,
    );
    final accepted = parts.sublist(0, room);
    final dropped = parts.sublist(room).where((part) => part.isNotEmpty).toList();
    if (dropped.isNotEmpty) {
      // 内容超出层数上限时并回末段而不是悄悄丢字，同时显式示警。
      accepted[room - 1] = '${accepted[room - 1]}/${dropped.join('/')}';
      showAppToast(t.settings.downloadSettings.pathTemplateEditor.folderCapReached, type: AppToastType.warning);
    }
    rows
      ..removeRange(index, index + 1)
      ..insertAll(index, accepted);
    _pendingFocusRow = index + accepted.length - 1;
    _materializeRows();
    setState(() {});
  }

  void _deleteRow(int index) {
    final rows = _drafts[_activeTab]!;
    if (rows.length <= 1) return;
    rows.removeAt(index);
    _pendingFocusRow = (index - 1).clamp(0, rows.length - 1);
    _materializeRows();
    setState(() {});
  }

  void _addFolderRow() {
    final rows = _drafts[_activeTab]!;
    if (_folderCount >= _maxFolders) return;
    final insertAt = _hasFileRow ? rows.length - 1 : rows.length;
    rows.insert(insertAt, '%date');
    _pendingFocusRow = insertAt;
    _materializeRows();
    setState(() {});
  }

  void _switchTab(_SegmentTab tab) {
    if (tab == _activeTab) return;
    setState(() {
      _activeTab = tab;
      _focusedRow = -1;
      _pendingFocusRow = 0;
      _materializeRows();
    });
  }

  /// 托盘点按：把 `%token` 插到当前焦点段的光标处（无焦点则落末段）。
  void _insertVariable(String token) {
    final t = slang.Translations.of(context);
    if (_rowControllers.isEmpty) return;
    final index = (_focusedRow >= 0 && _focusedRow < _rowControllers.length)
        ? _focusedRow
        : _rowControllers.length - 1;
    final controller = _rowControllers[index];
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : controller.text.length;
    final end = selection.end >= 0 ? selection.end : start;
    final insertion = '%$token';
    final newText = controller.text.replaceRange(start, end, insertion);
    _drafts[_activeTab]![index] = newText;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
    showAppToast(
      '${t.settings.downloadSettings.pathTemplateEditor.variableInserted}: %$token',
      type: AppToastType.info,
    );
  }

  // ─────────────────────────── 校验与保存 ───────────────────────────

  /// 段是否为「空段」：字面为空，或样例渲染清洗后为空（全点 / 全空白）。
  bool _isEmptySegment(String segment) =>
      segment.trim().isEmpty ||
      FilenameTemplateService.isRenderedSegmentEmpty(
        FilenameTemplateService.renderSampleSegment(segment, _sampleVars()),
      );

  bool _tabHasEmpty(_SegmentTab tab) =>
      _drafts[tab]!.isEmpty ||
      _drafts[tab]!.any(_isEmptySegment);

  /// 三份草稿与 config 里的现值是否一致（决定保存钮的小红点）。
  bool get _isDirty {
    final values = {
      _SegmentTab.video: ConfigKey.VIDEO_FILENAME_TEMPLATE,
      _SegmentTab.gallery: ConfigKey.GALLERY_FILENAME_TEMPLATE,
      _SegmentTab.image: ConfigKey.IMAGE_FILENAME_TEMPLATE,
    };
    for (final entry in values.entries) {
      final current =
          _configService[entry.value] as String? ?? '';
      final draft = _drafts[entry.key]!.join('/');
      if (FilenameTemplateService.splitTemplateSegments(current).join('/') !=
          draft) {
        return true;
      }
    }
    return false;
  }

  Future<void> _save() async {
    final t = slang.Translations.of(context);

    // 校验所有 Tab（不只当前看的这个）。
    for (final tab in _SegmentTab.values) {
      if (_tabHasEmpty(tab)) {
        setState(() => _activeTab = tab);
        _pendingFocusRow = 0;
        _materializeRows();
        showAppToast(
          t.settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked,
          type: AppToastType.error,
        );
        return;
      }
    }

    // 段数超限单独报：行内并回的 `/`（拆段到顶、或载入了超限的存量值）会让
    // join 后的段数越界——这和「空段」是两种病，文案必须分开，否则用户对着
    // 没有空段的表单被告知「存在空段」。
    for (final tab in _SegmentTab.values) {
      final segmentCount = FilenameTemplateService.splitTemplateSegments(
        _drafts[tab]!.join('/'),
      ).length;
      if (segmentCount > FilenameTemplateService.maxTemplateSegments) {
        setState(() => _activeTab = tab);
        _pendingFocusRow = 0;
        _materializeRows();
        showAppToast(
          t
              .settings
              .downloadSettings
              .pathTemplateEditor
              .tooManySegmentsSaveBlocked,
          type: AppToastType.error,
        );
        return;
      }
    }

    final values = {
      ConfigKey.VIDEO_FILENAME_TEMPLATE: _drafts[_SegmentTab.video]!.join('/'),
      ConfigKey.GALLERY_FILENAME_TEMPLATE:
          _drafts[_SegmentTab.gallery]!.join('/'),
      ConfigKey.IMAGE_FILENAME_TEMPLATE: _drafts[_SegmentTab.image]!.join('/'),
    };
    for (final entry in values.entries) {
      if (!Get.find<FilenameTemplateService>().validateTemplate(entry.value)) {
        // 空段与段数都查过了，到这里还失败只剩非法字符一类
        // （如手工改配置写进来的 `\`），给对应的文案而不是「空段」。
        showAppToast(
          t
              .settings
              .downloadSettings
              .pathTemplateEditor
              .templateInvalidSaveBlocked,
          type: AppToastType.error,
        );
        return;
      }
    }
    values.forEach((key, value) => _configService[key] = value);

    showAppToast(
      t.settings.downloadSettings.pathTemplateEditor.savedToast,
      type: AppToastType.success,
    );
    if (mounted) AppService.tryPop();
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: GlassHeaderOverlay(
          liquid: true,
          headerExtent: headerExtent,
          headerTop: statusBarHeight,
          solidExtent: statusBarHeight,
          body: Column(
            children: [
              SizedBox(height: headerExtent + 8),
              _buildTabs(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    _buildPreviewCard(context),
                    ..._buildSegmentRows(context),
                    _buildAddRow(context),
                    _buildCaption(context),
                  ],
                ),
              ),
              _buildVariableTray(context),
            ],
          ),
          header: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: t.common.back,
                  onPressed: () => AppService.tryPop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassTitlePill(
                    title: t.settings.downloadSettings.pathTemplateEditor.title,
                  ),
                ),
                const SizedBox(width: 8),
                GlassButtonGroup(
                  children: [
                    GlassIconButton(
                      icon: const Icon(Icons.help_outline),
                      tooltip: t.settings.downloadSettings.supportedVariables,
                      onPressed: () => _showVariableHelpDialog(context),
                    ),
                    GlassIconButton(
                      icon: const Icon(Icons.save_outlined),
                      tooltip: t.common.save,
                      showBadge: _isDirty,
                      onPressed: _save,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassAdaptiveSegmentedControl(
        items: [
          GlassSegmentItem(label: e.tabVideo),
          GlassSegmentItem(label: e.tabGallery),
          GlassSegmentItem(label: e.tabImage),
        ],
        selectedIndex: _activeTab.index,
        onChanged: (index) => _switchTab(_SegmentTab.values[index]),
      ),
    );
  }

  /// 预览卡：渲染清洗后的真实落盘结果；空段标红、超 200 字符示警。
  Widget _buildPreviewCard(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final rows = _drafts[_activeTab]!;
    final variables = _sampleVars();

    final cleaned = [
      for (var i = 0; i < rows.length; i++)
        FilenameTemplateService.sanitizePathSegment(
          FilenameTemplateService.renderSampleSegment(rows[i], variables),
          fallback: _isFileRow(i) ? 'file' : 'unknown',
        ),
    ];
    final totalLength = cleaned.join('/').length;
    final overBudget = totalLength > 200;
    final hasEmpty = rows.any(_isEmptySegment);

    final label = _hasFileRow
        ? e.previewLabel
        : e.galleryPreviewLabel;
    final spans = <InlineSpan>[];
    for (var i = 0; i < rows.length; i++) {
      final isFile = _isFileRow(i);
      final bad = _isEmptySegment(rows[i]);
      if (i > 0) {
        spans.add(
          TextSpan(
            text: ' › ',
            style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          ),
        );
      }
      final color = bad
          ? cs.error
          : isFile
          ? cs.onSurface
          : cs.primary;
      spans.add(
        TextSpan(
          text: cleaned[i],
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GlassTokens.stroke(cs)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
              children: spans,
            ),
          ),
          if (hasEmpty || overBudget) ...[
            const SizedBox(height: 6),
            Text(
              hasEmpty
                  ? e.emptySegmentSaveBlocked
                  : t.settings.downloadSettings.pathTooLongWarning,
              style: theme.textTheme.labelSmall?.copyWith(
                color: hasEmpty ? cs.error : cs.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSegmentRows(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < _rowControllers.length; i++) {
      final isFile = _isFileRow(i);
      final bad = _isEmptySegment(_drafts[_activeTab]![i]);
      final deletable = _drafts[_activeTab]!.length > 1 && !isFile;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isFile ? Icons.movie_outlined : Icons.folder_outlined,
                size: 18,
                color: isFile
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassInputSurface(
                  borderRadius: 12,
                  error: bad,
                  child: TextField(
                    controller: _rowControllers[i],
                    focusNode: _rowFocusNodes[i],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
                    decoration: glassFieldDecoration(
                      context,
                      hint: isFile
                          ? slang
                                .t
                                .settings
                                .downloadSettings
                                .pathTemplateEditor
                                .fileSegmentHint
                          : slang
                                .t
                                .settings
                                .downloadSettings
                                .pathTemplateEditor
                                .folderSegmentHint,
                    ).copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                    ),
                    onChanged: (value) => _onRowChanged(i, value),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: Icon(
                    Icons.close,
                    color: deletable
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                  ),
                  tooltip: deletable ? null : slang.t.common.delete,
                  onPressed: deletable ? () => _deleteRow(i) : null,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildAddRow(BuildContext context) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final cs = Theme.of(context).colorScheme;
    final atCap = _folderCount >= _maxFolders;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: atCap ? null : _addFolderRow,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.onSurfaceVariant.withValues(
                  alpha: atCap ? 0.15 : 0.35,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 16,
                  color: atCap
                      ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                      : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  atCap
                      ? e.folderCapReached
                      : e.addFolder(current: _folderCount, max: _maxFolders),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: atCap
                        ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                        : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaption(BuildContext context) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final note = switch (_activeTab) {
      _SegmentTab.video => e.videoCapNote(max: _maxFolders),
      _SegmentTab.gallery => e.galleryCapNote(max: _maxFolders),
      _SegmentTab.image => e.imageCapNote(max: _maxFolders),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 2),
      child: Text(
        note,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// 变量托盘：三色 chip（点按插入、长按说明）+ 分类图例 + 提示行。
  Widget _buildVariableTray(BuildContext context) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final chips = _trayChips(t);
    Widget legendDot(_TrayCategory category, String label) {
      final color = _trayColor(category, cs, theme.brightness);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: GlassTokens.stroke(cs))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    _buildTrayChip(context, chips[i]),
                    if (i != chips.length - 1) const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  legendDot(_TrayCategory.content, e.trayCategoryContent),
                  const SizedBox(width: 10),
                  legendDot(_TrayCategory.author, e.trayCategoryAuthor),
                  const SizedBox(width: 10),
                  legendDot(_TrayCategory.time, e.trayCategoryTime),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      e.trayHint,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
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

  Widget _buildTrayChip(BuildContext context, _TrayChipSpec spec) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _trayColor(spec.category, cs, theme.brightness);
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () => _insertVariable(spec.token),
      onLongPress: () => _showVariableDescription(spec.token),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              spec.label(slang.Translations.of(context)),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _trayColor(
    _TrayCategory category,
    ColorScheme cs,
    Brightness brightness,
  ) {
    // 设计稿语义色：内容蓝 / 作者绿 / 时间琥珀。亮色主题下压深保证可读。
    final base = switch (category) {
      _TrayCategory.content => const Color(0xFF7BA7F0),
      _TrayCategory.author => const Color(0xFF7DDBA3),
      _TrayCategory.time => const Color(0xFFF2C76E),
    };
    return brightness == Brightness.light
        ? Color.lerp(base, Colors.black, 0.45)!
        : base;
  }

  List<_TrayChipSpec> _trayChips(slang.Translations t) {
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final v = t.settings.downloadSettings;
    return [
      _TrayChipSpec('title', _TrayCategory.content, (_) => v.variableTitle),
      _TrayChipSpec(
        'authorcache',
        _TrayCategory.author,
        (_) => e.chipAuthorcache,
      ),
      _TrayChipSpec('author', _TrayCategory.author, (_) => v.variableAuthor),
      _TrayChipSpec(
        'username',
        _TrayCategory.author,
        (_) => v.variableUsername,
      ),
      _TrayChipSpec('quality', _TrayCategory.content, (_) => v.variableQuality),
      _TrayChipSpec('id', _TrayCategory.content, (_) => v.variableId),
      _TrayChipSpec(
        'filename',
        _TrayCategory.content,
        (_) => v.variableFilename,
      ),
      _TrayChipSpec('count', _TrayCategory.content, (_) => v.variableCount),
      _TrayChipSpec('date', _TrayCategory.time, (_) => v.variableDate),
      _TrayChipSpec('time', _TrayCategory.time, (_) => v.variableTime),
      _TrayChipSpec('datetime', _TrayCategory.time, (_) => v.variableDatetime),
    ];
  }

  // ─────────────────────────── 帮助弹窗 ───────────────────────────

  void _showVariableDescription(String token) {
    final t = slang.Translations.of(context);
    final variable = FilenameTemplateService.to
        .getSupportedVariables()
        .where((v) => v.variable == '%$token')
        .firstOrNull;
    if (variable == null) return;
    showAppDialog(
      GlassAlertDialog(
        title: variable.variable,
        maxWidth: 420,
        content: Text(variable.description),
        actions: [
          GlassDialogAction(
            label: t.common.confirm,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showVariableHelpDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    final variables = FilenameTemplateService.to.getSupportedVariables();

    showAppDialog(
      GlassAlertDialog(
        title: t.settings.downloadSettings.supportedVariables,
        maxWidth: 600,
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.downloadSettings.supportedVariablesDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            ...variables.map(
              (variable) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        variable.variable,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          variable.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
