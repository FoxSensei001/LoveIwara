import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
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
import 'package:path/path.dart' as p;

/// 路径模板编辑器（issue #126 子文件夹归档的逃生舱）。
///
/// 全屏二级页，三个 Tab（视频 / 图库 / 单张图片）各持一份独立草稿、一次保存。
/// 每层文件夹一个 monospace 文本框；底部变量托盘点按即插入（全程不用软键盘
/// 打 % 号），按内容 / 作者 / 时间三色分类；预览渲染的是清洗后的真实落盘结果。
///
/// ## 核心不变量：一行 = 一段，段内永不含 `/`
///
/// 这一条是本页所有正确性的地基，别在任何入口上破它：
///   - 打字、插变量、粘贴、回车都汇到 [_onRowTextChanged] 这一个口子做归一化，
///     `\` 换 `_`、`/` 当场拆行；
///   - 载入存量超限值时超出的段用 `_` 并进末段（[foldSegmentsToLimit]），
///     而不是把 `/` 留在行内；
///   - 于是「行数 == 落盘层数」恒成立，预览（按行画）与保存（按行 join）
///     说的是同一件事，各 Tab 的层数上限也就只需要一处定义。
///
/// ## 文本的唯一事实源是 TextEditingController
///
/// 行不再另存一份 `String`——那种双源结构要求每个改文本的地方都记得手动同步
/// 并 `setState`，漏一处（例如变量托盘插入）就会出现「值已改好、红描边和预览
/// 还停在旧状态」。这里每行的 controller 自带 listener，任何来源的文本变化都
/// 会过同一条归一化 + 重绘路径。
///
/// ## 层数上限
///
/// 视频 / 单图 = 3 层文件夹段 + 1 层文件名段；图库全部为文件夹段且最多 2 层
/// （内部图片固定按「图片ID.扩展名」命名，不走模板）。上限只在
/// [_maxRowsFor] 定义一次，编辑期护栏与保存校验共用。
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

/// 一行 = 一段。文本由 [controller] 独家持有，行对象自己不存第二份。
class _SegmentRow {
  _SegmentRow(String text, {required KeyEventResult Function(KeyEvent) onKey})
    : controller = TextEditingController(text: text) {
    focusNode = FocusNode(onKeyEvent: (_, event) => onKey(event));
  }

  final TextEditingController controller;
  late final FocusNode focusNode;

  String get text => controller.text;
  String get trimmed => controller.text.trim();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class PathTemplateEditorPage extends StatefulWidget {
  const PathTemplateEditorPage({super.key});

  /// 全屏二级页走裸路由（先例：下载分类管理页——本页不入 URL，
  /// 且只从下载设置页一处进入）。
  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const PathTemplateEditorPage()));

  /// 把存量模板折进行数上限：超出的段用 `_` 并进末段。
  ///
  /// 用 `_` 而不是留 `/`，是为了守住「段内永不含 `/`」——留 `/` 会让行数与
  /// 落盘层数脱钩，预览按行画就会把 `a/b` 画成一层 `a_b`，而保存 join 后写出
  /// 去的却是两层。一个字不丢，用户看到的就是会落盘的东西。
  static List<String> foldSegmentsToLimit(List<String> segments, int maxRows) {
    if (segments.length <= maxRows) return segments;
    final overflow = segments
        .sublist(maxRows - 1)
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty);
    return [...segments.sublist(0, maxRows - 1), overflow.join('_')];
  }

  /// 一行文本里出现 `/` 时，它该拆成哪几段、光标落在第几段的第几位。
  ///
  /// 单独拎成纯函数是因为这里的判定最容易出错，而错了之后表现得像「按键被
  /// 吞了」——重构前的版本先把所有空段剔光，于是在行尾敲 `/`（人打路径最
  /// 自然的动作）和桌面端按回车都不会产生新的一层，静默无反应。
  ///
  /// 规则：
  ///   - 开头与中间的空段剔除（`a//b` 属于手滑）；
  ///   - **尾部的空段保留**：行尾一个 `/` 就是「我要再开一层」，得给出那行
  ///     空输入框（配红描边提示还没写完），而不是把这次按键吃掉；
  ///   - 段数超出 [room]（这一行最多能变成几行）时，多出来的用 `_` 并进末段，
  ///     `capped` 为真，调用方据此示警。并的是 `_` 不是 `/`——段内留 `/` 会
  ///     让行数与落盘层数脱钩，那正是预览失真的来源；
  ///   - 光标按它在原文里的位置跟到对应的新行上（在行中间敲 `/` 应当接着在
  ///     新行开头打字，而不是被甩到末尾）。
  ///
  /// [caret] 传 `< 0` 表示未知，按落在末尾处理。
  static ({List<String> parts, int caretRow, int caretOffset, bool capped})
  splitInput(String text, {required int caret, required int room}) {
    final rawParts = text.split('/');
    final caretAt = caret < 0 ? text.length : caret.clamp(0, text.length);

    // 1) 先在未 trim 的原文上定位光标落在第几段的第几位。
    var caretPart = rawParts.length - 1;
    var caretOffset = rawParts.last.length;
    var consumed = 0;
    for (var i = 0; i < rawParts.length; i++) {
      final end = consumed + rawParts[i].length;
      if (caretAt <= end) {
        caretPart = i;
        caretOffset = caretAt - consumed;
        break;
      }
      consumed = end + 1; // 跨过分隔符本身
    }

    // 2) trim + 剔空（尾段的空保留），同时记住每段来自哪个 rawPart。
    final parts = <String>[];
    final origin = <int>[];
    for (var i = 0; i < rawParts.length; i++) {
      final segment = rawParts[i].trim();
      if (segment.isEmpty && i != rawParts.length - 1) continue;
      parts.add(segment);
      origin.add(i);
    }
    if (parts.isEmpty) {
      parts.add('');
      origin.add(0);
    }

    // 3) 层数够不够。
    final limit = room.clamp(1, parts.length);
    var capped = false;
    if (limit < parts.length) {
      final overflow = parts.sublist(limit).where((part) => part.isNotEmpty);
      parts[limit - 1] = [
        parts[limit - 1],
        ...overflow,
      ].where((part) => part.isNotEmpty).join('_');
      parts.removeRange(limit, parts.length);
      origin.removeRange(limit, origin.length);
      capped = true;
    }

    // 4) 光标跟到它该去的那一行。
    var caretRow = parts.length - 1;
    var offsetInRow = parts.last.length;
    final mapped = origin.indexOf(caretPart);
    if (mapped >= 0) {
      caretRow = mapped;
      // trim 掉的前导空白要从段内偏移里扣掉。
      final lead =
          rawParts[caretPart].length - rawParts[caretPart].trimLeft().length;
      offsetInRow = (caretOffset - lead).clamp(0, parts[mapped].length);
    }
    return (
      parts: parts,
      caretRow: caretRow,
      caretOffset: offsetInRow,
      capped: capped,
    );
  }

  @override
  State<PathTemplateEditorPage> createState() => _PathTemplateEditorPageState();
}

class _PathTemplateEditorPageState extends State<PathTemplateEditorPage> {
  static const _sampleVars = FilenameTemplateService.sampleVariables;

  /// 相对路径的字符预算（超了只示警，不拦保存——真落盘时各平台上限不同）。
  static const int _pathLengthBudget = 200;

  /// 段落行的三段式度量：前导图标 / 输入框 / 尾部删除位。
  ///
  /// 抽成常量是因为「添加一层文件夹」那条必须和上面的输入框**左右对齐**——
  /// 两处各写一遍常数，改一边忘一边就是一道歪出去的边。
  static const double _rowLeadingIcon = 18;
  static const double _rowLeadingGap = 10;
  static const double _rowTrailingGap = 4;
  static const double _rowTrailingWidth = 34;
  static const double _rowInset = _rowLeadingIcon + _rowLeadingGap;
  static const double _rowOutset = _rowTrailingGap + _rowTrailingWidth;

  final ConfigService _configService = Get.find<ConfigService>();

  _SegmentTab _activeTab = _SegmentTab.video;

  /// 三个 Tab 各自持有自己的行，切 Tab 不重建——光标、已填内容、滚动位置
  /// 都还在，来回比对两个 Tab 时不会每切一次就被清一次场。
  final Map<_SegmentTab, List<_SegmentRow>> _rows = {};

  /// 最近持焦的行（变量托盘插入的落点）。行被删时置空。
  _SegmentRow? _focusedRow;

  /// 归一化期间对 controller 的写回不该再次触发归一化。
  bool _normalizing = false;

  /// 等下一帧再销毁的行：删行发生在 build 之外，但被删那行的 EditableText
  /// 要到下一帧才从树上摘掉，当帧直接 dispose 它的 controller 不稳。
  final List<_SegmentRow> _retired = [];

  @override
  void initState() {
    super.initState();
    for (final tab in _SegmentTab.values) {
      _rows[tab] = [
        for (final segment in _initialSegments(tab)) _createRow(segment),
      ];
    }
    // ⛔ 这里不落焦：本页的主交互是点变量托盘，进来就弹软键盘会盖掉预览和
    // 托盘本身。焦点只跟着用户发起的结构性动作走（拆行 / 加行 / 删行）。
  }

  @override
  void dispose() {
    for (final rows in _rows.values) {
      for (final row in rows) {
        row.dispose();
      }
    }
    for (final row in _retired) {
      row.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────── 行与草稿 ───────────────────────────

  List<_SegmentRow> get _current => _rows[_activeTab]!;

  /// 本 Tab 的行数（= 落盘层数）上限：图库 2 层全是文件夹；
  /// 视频 / 单图 3 层文件夹 + 1 层文件名。编辑期护栏与保存校验共用这一处。
  static int _maxRowsFor(_SegmentTab tab) => tab == _SegmentTab.gallery ? 2 : 4;

  /// 当前 Tab 是不是「最后一行是文件名段」的结构（图库全为文件夹段）。
  static bool _hasFileRowIn(_SegmentTab tab) => tab != _SegmentTab.gallery;

  bool get _hasFileRow => _hasFileRowIn(_activeTab);

  int get _maxFolders => _maxRowsFor(_activeTab) - (_hasFileRow ? 1 : 0);

  bool _isFileRow(int index) => _hasFileRow && index == _current.length - 1;

  int get _folderCount => _current.length - (_hasFileRow ? 1 : 0);

  _SegmentRow _createRow(String text) {
    late final _SegmentRow row;
    row = _SegmentRow(text, onKey: (event) => _handleRowKey(row, event));
    row.controller.addListener(() => _onRowTextChanged(row));
    row.focusNode.addListener(() {
      if (row.focusNode.hasFocus) _focusedRow = row;
    });
    return row;
  }

  /// 从 config 读当前模板拆段；值异常（空 / 全空段）时以出厂默认作草稿起点。
  List<String> _initialSegments(_SegmentTab tab) {
    final key = switch (tab) {
      _SegmentTab.video => ConfigKey.VIDEO_FILENAME_TEMPLATE,
      _SegmentTab.gallery => ConfigKey.GALLERY_FILENAME_TEMPLATE,
      _SegmentTab.image => ConfigKey.IMAGE_FILENAME_TEMPLATE,
    };
    final stored = FilenameTemplateService.splitTemplateSegments(
      _configService[key] as String? ?? '',
    );
    final source = stored.isNotEmpty
        ? stored
        : FilenameTemplateService.splitTemplateSegments(_defaultFor(tab));
    return PathTemplateEditorPage.foldSegmentsToLimit(source, _maxRowsFor(tab));
  }

  static String _defaultFor(_SegmentTab tab) => switch (tab) {
    _SegmentTab.video => '%authorcache/%title_%quality',
    _SegmentTab.gallery => '%authorcache/%title_%id',
    _SegmentTab.image => '%authorcache/%title/%filename',
  };

  List<String> _segmentsOf(_SegmentTab tab) =>
      _rows[tab]!.map((row) => row.trimmed).toList();

  // ─────────────────────── 归一化（唯一入口） ───────────────────────

  /// 任何来源的文本变化都到这里：打字、变量托盘插入、粘贴、回车拆行。
  ///
  /// 职责有三件，缺一条不变量就破了：`\` 换 `_`、含 `/` 当场拆行、
  /// 以及无论有没有改写都 `setState` 一次（红描边 / 预览 / 保存红点全靠它）。
  void _onRowTextChanged(_SegmentRow row) {
    if (_normalizing || !mounted) return;
    final index = _current.indexOf(row);
    if (index < 0) return;

    final raw = row.controller.text;
    final cleaned = raw.replaceAll('\\', '_');
    if (!cleaned.contains('/')) {
      if (cleaned != raw) {
        // `\` 被替换过：写回净化后的文本，光标停在原处（长度没变）。
        final caret = row.controller.selection.baseOffset;
        _writeBack(row, cleaned, caret < 0 ? cleaned.length : caret);
      }
      setState(() {});
      return;
    }
    _splitRow(index, row, cleaned);
  }

  /// 绕开 listener 写回文本（避免归一化自己触发自己）。
  void _writeBack(_SegmentRow row, String text, int caret) {
    _normalizing = true;
    row.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret.clamp(0, text.length)),
    );
    _normalizing = false;
  }

  /// 把第 [index] 行按 `/` 拆成多行（规则见 [PathTemplateEditorPage.splitInput]）。
  void _splitRow(int index, _SegmentRow row, String text) {
    final maxRows = _maxRowsFor(_activeTab);
    final outcome = PathTemplateEditorPage.splitInput(
      text,
      caret: row.controller.selection.baseOffset,
      room: maxRows - (_current.length - 1),
    );

    if (outcome.capped) {
      showAppToast(
        slang.Translations.of(
          context,
        ).settings.downloadSettings.pathTemplateEditor.folderCapReached,
        type: AppToastType.warning,
      );
    }

    // 复用当前行承接第一段（它正持焦，换成新 node 会闪一下键盘），
    // 其余段新建行插到它后面。
    final parts = outcome.parts;
    _writeBack(row, parts.first, parts.first.length);
    _current.insertAll(index + 1, [
      for (var i = 1; i < parts.length; i++) _createRow(parts[i]),
    ]);
    setState(() {});
    _focusRowAt(index + outcome.caretRow, offset: outcome.caretOffset);
  }

  /// 桌面端回车 = 在光标处插一个 `/`，交给归一化去拆行。
  ///
  /// 走「插分隔符」而不是「直接建行」，是为了让回车和手打 `/` 共用同一条
  /// 归一化路径——上限判定、空段处理、光标落点只有一份实现。
  KeyEventResult _handleRowKey(_SegmentRow row, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter &&
        event.logicalKey != LogicalKeyboardKey.numpadEnter) {
      return KeyEventResult.ignored;
    }
    if (!_current.contains(row)) return KeyEventResult.ignored;

    final text = row.controller.text;
    final selection = row.controller.selection;
    final base = selection.baseOffset < 0 ? text.length : selection.baseOffset;
    final extent = selection.extentOffset < 0 ? base : selection.extentOffset;
    final start = math.min(base, extent);
    final end = math.max(base, extent);
    _writeBack(row, text.replaceRange(start, end, '/'), start + 1);
    _onRowTextChanged(row);
    return KeyEventResult.handled;
  }

  /// 落焦到第 [index] 行（下一帧执行：新建的 FocusNode 这一帧还没挂上树）。
  void _focusRowAt(int index, {int? offset}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _current.length) return;
      final row = _current[index];
      row.controller.selection = TextSelection.collapsed(
        offset: (offset ?? row.text.length).clamp(0, row.text.length),
      );
      row.focusNode.requestFocus();
    });
  }

  // ─────────────────────────── 结构性编辑 ───────────────────────────

  void _deleteRow(int index) {
    if (_current.length <= 1) return;
    final row = _current.removeAt(index);
    if (identical(_focusedRow, row)) _focusedRow = null;
    _retire(row);
    setState(() {});
    _focusRowAt((index - 1).clamp(0, _current.length - 1));
  }

  void _addFolderRow() {
    if (_folderCount >= _maxFolders) return;
    // 空行而不是替用户塞一个 `%date`：新开的这层写什么是用户的决定，
    // 空行配红描边正好说明「这里还等着填」。
    final insertAt = _hasFileRow ? _current.length - 1 : _current.length;
    _current.insert(insertAt, _createRow(''));
    setState(() {});
    _focusRowAt(insertAt);
  }

  void _retire(_SegmentRow row) {
    _retired.add(row);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // 已整页销毁：dispose() 统一回收过，跳过防双销
      for (final retired in _retired) {
        retired.dispose();
      }
      _retired.clear();
    });
  }

  void _switchTab(_SegmentTab tab) {
    if (tab == _activeTab) return;
    // 切 Tab 同样不抢焦点：不弹键盘，也不打断另一个 Tab 里已有的光标位置。
    FocusScope.of(context).unfocus();
    setState(() {
      _activeTab = tab;
      _focusedRow = null;
    });
  }

  /// 托盘点按：把 `%token` 插到当前焦点行的光标处（无焦点则落末行）。
  ///
  /// 只动 controller——刷新由它的 listener 统一负责，这里不需要（也不该）
  /// 自己 `setState`，漏写就是「插进去了但红描边不消失」那类 bug 的来源。
  void _insertVariable(String token) {
    if (_current.isEmpty) return;
    final row = (_focusedRow != null && _current.contains(_focusedRow))
        ? _focusedRow!
        : _current.last;
    final text = row.controller.text;
    final selection = row.controller.selection;
    final base = selection.baseOffset < 0 ? text.length : selection.baseOffset;
    final extent = selection.extentOffset < 0 ? base : selection.extentOffset;
    final start = math.min(base, extent);
    final end = math.max(base, extent);
    final insertion = '%$token';
    _writeBack(
      row,
      text.replaceRange(start, end, insertion),
      start + insertion.length,
    );
    _onRowTextChanged(row);
  }

  // ─────────────────────────── 校验与保存 ───────────────────────────

  /// 段是否为「空段」：字面为空，或样例渲染清洗后为空（全点 / 全空白）。
  bool _isEmptySegment(String segment) =>
      segment.trim().isEmpty ||
      FilenameTemplateService.isRenderedSegmentEmpty(
        FilenameTemplateService.renderSampleSegment(segment, _sampleVars()),
      );

  /// 三份草稿与 config 里的现值是否一致（决定保存钮的小红点）。
  bool get _isDirty {
    for (final entry in _configKeys.entries) {
      final current = _configService[entry.value] as String? ?? '';
      if (FilenameTemplateService.splitTemplateSegments(current).join('/') !=
          _segmentsOf(entry.key).join('/')) {
        return true;
      }
    }
    return false;
  }

  static const Map<_SegmentTab, ConfigKey> _configKeys = {
    _SegmentTab.video: ConfigKey.VIDEO_FILENAME_TEMPLATE,
    _SegmentTab.gallery: ConfigKey.GALLERY_FILENAME_TEMPLATE,
    _SegmentTab.image: ConfigKey.IMAGE_FILENAME_TEMPLATE,
  };

  /// 校验失败时切到出问题的 Tab 并把光标送到那一行——报了错却不告诉用户
  /// 是哪一行，等于没报。
  void _revealProblem(_SegmentTab tab, int rowIndex, String message) {
    setState(() {
      _activeTab = tab;
      _focusedRow = null;
    });
    _focusRowAt(rowIndex);
    showAppToast(message, type: AppToastType.error);
  }

  Future<void> _save() async {
    final t = slang.Translations.of(context);
    final editor = t.settings.downloadSettings.pathTemplateEditor;

    for (final tab in _SegmentTab.values) {
      final segments = _segmentsOf(tab);

      // 空段：定位到第一个空的那一行。
      final emptyAt = segments.indexWhere(_isEmptySegment);
      if (segments.isEmpty || emptyAt >= 0) {
        _revealProblem(
          tab,
          emptyAt < 0 ? 0 : emptyAt,
          editor.emptySegmentSaveBlocked,
        );
        return;
      }

      // 段数：按本 Tab 自己的上限判（图库 2 层；视频 / 单图 4 层）。
      // 不变量成立时走不到这里，留作最后一道防线。
      if (segments.length > _maxRowsFor(tab)) {
        _revealProblem(
          tab,
          _maxRowsFor(tab),
          editor.tooManySegmentsSaveBlocked,
        );
        return;
      }

      // 非法字符一类（如手工改配置写进来的东西）。
      if (!Get.find<FilenameTemplateService>().validateTemplate(
        segments.join('/'),
      )) {
        _revealProblem(tab, 0, editor.templateInvalidSaveBlocked);
        return;
      }
    }

    for (final entry in _configKeys.entries) {
      _configService[entry.value] = _segmentsOf(entry.key).join('/');
    }
    showAppToast(editor.savedToast, type: AppToastType.success);
    _leave();
  }

  /// ⛔ 离开本页一律走 `Navigator.pop`，不要换成 `AppService.tryPop`。
  ///
  /// 后者走的是 `PopCoordinator.handleBack -> Navigator.maybePop`，而 maybePop
  /// 会**再触发一遍本页的 [PopScope]**。PopCoordinator 的重入保护是同步标记，
  /// 挡不住「异步确认弹窗」这条路径：确认完再 tryPop，`_isDirty` 还是真，于是
  /// 又弹一次确认框，无限套娃。这里是裸 MaterialPageRoute 推的二级页，
  /// 直接 pop 自己就是正确且唯一需要的语义。
  void _leave() {
    if (mounted) Navigator.of(context).pop();
  }

  /// 返回前确认：草稿只活在这一页，退出即丢，不问一声等于偷偷删东西。
  ///
  /// ⛔ 弹窗里的 `pop` 一律用 [Builder] 现取的 `dialogContext`（与下载分类
  /// 管理页同一约定）。[showAppDialog] 走 `useRootNavigator: true`，弹窗压在
  /// root 栈上；而本页是设置页用它自己那层 Navigator 推出来的。拿**页面**的
  /// context 裸调 `Navigator.of(context).pop()`，找到的是本页所在的那层——
  /// 于是「取消」把编辑器页自己 pop 了、弹窗反倒留在屏幕上，草稿静默丢失。
  /// 真机上复现过。
  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final t = slang.Translations.of(context);
    final confirmed = await showAppDialog<bool>(
      Builder(
        builder: (dialogContext) => GlassAlertDialog(
          title: t.common.unsavedChanges,
          maxWidth: 420,
          content: Text(t.common.exitConfirmTip),
          actions: [
            GlassDialogAction(
              label: t.common.cancel,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            GlassDialogAction(
              label: t.common.confirm,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleBack() async {
    if (await _confirmDiscard()) _leave();
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard()) _leave();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
            body: LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth >= _twoColumnWidth
                  ? _buildWideBody(context, headerExtent)
                  : _buildNarrowBody(context, headerExtent),
            ),
            // ⛔ header **不进** [_constrained]：全站二级页的标题行一律是
            // 「通栏 + 左右 16」（见 GlassSettingsScaffold），夹进 720 后宽屏上
            // 左右会各多出半个居中余量（本页 783dp 的栏里多出 31dp），
            // 返回钮和动作钮比别的页往里缩一截，一眼就看得出不是一套东西。
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: t.common.back,
                    onPressed: _handleBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlassTitlePill(
                      title:
                          t.settings.downloadSettings.pathTemplateEditor.title,
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
      ),
    );
  }

  /// 窄屏（手机 / 竖屏平板 / 小窗）：一列到底，变量托盘是钉在最下面的底栏。
  Widget _buildNarrowBody(BuildContext context, double headerExtent) => Column(
    children: [
      Expanded(
        child: _constrained(
          Column(
            children: [
              SizedBox(height: headerExtent + 8),
              _buildTabs(context),
              // 预览钉在 Tab 下方不随滚动：它是本页每一次编辑的即时回执，
              // 滚走了就等于改着改着看不见结果。
              _buildPreviewCard(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    ..._buildSegmentRows(context),
                    _buildAddRow(context),
                    _buildCaption(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // ⛔ 托盘在 [_constrained] **外面**：它是整页的底栏，底色必须通栏。
      // 跟正文一起被夹进 720，宽屏上就成了一条两边露缝的悬空带子。
      _buildVariableTray(context),
    ],
  );

  /// 宽屏（横屏平板 / 桌面）：表单在左，变量面板在右。
  ///
  /// 这页的表单一共就三四行，摊在宽屏上是「上面一小撮内容、中间一大片空、
  /// 底下一条托盘」。把托盘立起来收进右栏，空洞没了，变量也离输入框更近——
  /// 原先要把手从屏幕中间挪到最底下才点得着一枚 chip。
  ///
  /// 两种形态**共用** [_buildTrayContent]：差的只是外壳（通栏底栏 / 独立卡片），
  /// chip 自己会在窄列里换行。分叉只留在容器上，内容一份。
  Widget _buildWideBody(BuildContext context, double headerExtent) => SafeArea(
    // 窄屏那条底栏自己带 SafeArea；两栏形态下没有底栏，得在这里让出手势条，
    // 否则段落填满时最后一行会压在导航条底下。
    top: false,
    child: _constrained(
      maxWidth: _wideContentWidth,
      Column(
        children: [
          SizedBox(height: headerExtent + 8),
          _buildTabs(context),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildPreviewCard(context),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          children: [
                            ..._buildSegmentRows(context),
                            _buildAddRow(context),
                            _buildCaption(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: _trayPanelWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                    child: _buildTrayPanel(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  /// 两栏阈值与度量。
  ///
  /// 760 = 表单最少 460（一条 `%authorcache/%title_%quality` 在 12.5px
  /// monospace 下约 200，留够两倍余量）+ 面板 280 + 边距。低于它右栏会把
  /// 输入框压到读不下一条模板串，不如老老实实回到一列。
  ///
  /// ⛔ 量的是**本页拿到的约束**不是屏幕：本页是设置页右半栏推出来的，
  /// 横屏平板上整屏 1143dp，落到这里只有 783dp。拿 MediaQuery 的屏幕宽去判
  /// 会在平板上误判成「很宽」，然后按不存在的空间排版。
  static const double _twoColumnWidth = 760;
  static const double _contentWidth = 720;
  static const double _wideContentWidth = 1060;
  static const double _trayPanelWidth = 280;

  /// 桌面 / 平板上不让 monospace 输入框横拉满屏——这一页是一列窄表单，
  /// 宽屏下居中收到可读宽度即可（与设置页其余二级页同一约定）。
  Widget _constrained(Widget child, {double maxWidth = _contentWidth}) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );

  Widget _buildTabs(BuildContext context) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    return Padding(
      // 底部留白：Tab 与预览卡贴在一起会读成「预览是视频这一栏的一部分」，
      // 实际上它是下面整张表单的结果。
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      // 左对齐：胶囊居中时它和下面左对齐的预览卡、输入框各走各的轴线，
      // 宽屏上整页就散了。贴左缘才看得出「这三栏管的是下面这堆东西」。
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassAdaptiveSegmentedControl(
          items: [
            GlassSegmentItem(label: e.tabVideo),
            GlassSegmentItem(label: e.tabGallery),
            GlassSegmentItem(label: e.tabImage),
          ],
          selectedIndex: _activeTab.index,
          onChanged: (index) => _switchTab(_SegmentTab.values[index]),
        ),
      ),
    );
  }

  /// 预览里根目录那截灰字（如 `Download`）。
  ///
  /// ⛔ 读的是**当前生效**的目录，不是出厂默认——与下载设置页同一理由：
  /// 开了自定义下载路径的用户，出厂默认那个目录根本不会被写入。
  String get _previewRootLabel {
    if (!Get.isRegistered<DownloadPathService>()) return '…';
    final service = DownloadPathService.to;
    final current = service.pathStatus?.currentPath ?? '';
    final base = current.isNotEmpty ? current : service.defaultDownloadPath;
    return base.isEmpty ? '…' : p.basename(base);
  }

  /// 预览卡：渲染清洗后的真实落盘结果；空段标红、超字符预算示警。
  ///
  /// 直接按行画——「一行 = 一段」的不变量保证了它和保存写出去的层级一致。
  Widget _buildPreviewCard(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final segments = _segmentsOf(_activeTab);
    final variables = _sampleVars();

    final cleaned = [
      for (var i = 0; i < segments.length; i++)
        FilenameTemplateService.sanitizePathSegment(
          FilenameTemplateService.renderSampleSegment(segments[i], variables),
          fallback: _isFileRow(i) ? 'file' : 'unknown',
        ),
    ];
    final totalLength = cleaned.join('/').length;
    final overBudget = totalLength > _pathLengthBudget;
    final hasEmpty = segments.any(_isEmptySegment);

    // 根目录灰字打头：和下载设置页的预览行同一形状，用户两处看到的是
    // 同一条完整落点，不用自己在脑子里把「根」和「模板」拼起来。
    final spans = <InlineSpan>[
      TextSpan(
        text: _previewRootLabel,
        style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
    ];
    for (var i = 0; i < segments.length; i++) {
      final isFile = _isFileRow(i);
      final bad = _isEmptySegment(segments[i]);
      spans.add(
        TextSpan(
          text: ' › ',
          style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        ),
      );
      spans.add(
        TextSpan(
          text: cleaned[i],
          style: TextStyle(
            color: bad
                ? cs.error
                : isFile
                ? cs.onSurface
                : cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasEmpty
              ? cs.error.withValues(alpha: 0.5)
              : overBudget
              ? cs.tertiary.withValues(alpha: 0.6)
              : GlassTokens.stroke(cs),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasFileRow ? e.previewLabel : e.galleryPreviewLabel,
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
                  : '${t.settings.downloadSettings.pathTooLongWarning} '
                        '($totalLength/$_pathLengthBudget)',
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
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final cs = Theme.of(context).colorScheme;
    final widgets = <Widget>[];
    for (var i = 0; i < _current.length; i++) {
      final row = _current[i];
      final isFile = _isFileRow(i);
      final bad = _isEmptySegment(row.trimmed);
      final deletable = _current.length > 1 && !isFile;
      widgets.add(
        Padding(
          // 行随增删进出，给一把稳定的 key，免得删中间一行时 Flutter 把
          // 下面那行的 widget 状态错接到被删行上。
          key: ValueKey(row),
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                isFile
                    ? Icons.insert_drive_file_outlined
                    : Icons.folder_outlined,
                size: _rowLeadingIcon,
                color: isFile ? cs.onSurfaceVariant : cs.primary,
              ),
              const SizedBox(width: _rowLeadingGap),
              Expanded(
                child: GlassInputSurface(
                  borderRadius: 12,
                  error: bad,
                  child: TextField(
                    controller: row.controller,
                    focusNode: row.focusNode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                    ),
                    decoration:
                        glassFieldDecoration(
                          context,
                          hint: isFile
                              ? e.fileSegmentHint
                              : e.folderSegmentHint,
                        ).copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: _rowTrailingGap),
              // 文件名段删不得（模板得有个落点）——那里留空位而不是画一个
              // 按不动的灰 ✕：摆一个永远失效的按钮只是噪音，还让人以为坏了。
              SizedBox(
                width: _rowTrailingWidth,
                height: _rowTrailingWidth,
                child: deletable
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                        tooltip: t.common.delete,
                        onPressed: () => _deleteRow(i),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildAddRow(BuildContext context) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final cs = Theme.of(context).colorScheme;
    final atCap = _folderCount >= _maxFolders;
    final tint = atCap
        ? cs.onSurfaceVariant.withValues(alpha: 0.45)
        : cs.primary;
    // 左右内缩到和上面的输入框同一条边：它就是「下一行」的占位，
    // 缩进对不上就会读成另一个层级的东西。
    return Padding(
      padding: const EdgeInsets.fromLTRB(_rowInset, 2, _rowOutset, 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: atCap ? null : _addFolderRow,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: atCap
                    ? cs.outlineVariant.withValues(alpha: 0.4)
                    : cs.primary.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                // ⛔ 只画这一个加号。文案里不许再带 `＋`——中文那两份译文
                // 原本写成「＋添加一层文件夹」，和这枚图标一起就是一大一小
                // 两个加号并排。
                Icon(atCap ? Icons.block : Icons.add, size: 18, color: tint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    atCap ? e.folderCapReached : e.addFolder,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tint,
                    ),
                  ),
                ),
                // 层数计数从文案里拎出来单放右侧：它是状态不是动作名，
                // 混在按钮标题里每次都得整句重读一遍才知道还能加几层。
                Text(
                  '$_folderCount/$_maxFolders',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.fromLTRB(_rowInset, 0, 0, 4),
      child: Text(
        note,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// 变量托盘的**窄屏外壳**：整页底栏，底色通栏、内容跟正文对齐。
  ///
  /// 底栏是页面的边界，边界就该顶到两侧。所以底色 [Container] 在
  /// [_constrained] 外面，只有里面的内容被夹进正文宽度。
  Widget _buildVariableTray(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: GlassTokens.stroke(cs))),
      ),
      child: SafeArea(
        top: false,
        child: _constrained(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: _buildTrayContent(context, stacked: false),
          ),
        ),
      ),
    );
  }

  /// 变量托盘的**宽屏外壳**：右栏里的一张独立卡片。
  ///
  /// 窄列放不下「提示 + 三个图例」一行，所以这里传 `stacked: true` 让标题
  /// 竖着摞；chip 一份不改，自己在 300dp 宽里换行。
  Widget _buildTrayPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GlassTokens.stroke(cs)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: _buildTrayContent(context, stacked: true),
      ),
    );
  }

  /// 托盘内容（两种外壳共用这一份）。
  ///
  /// ## 为什么不横向滚动
  ///
  /// 早先这里是一条横滚的 chip 带，11 个变量只露得出前 6 个。手机上要盲滑
  /// 才知道后面还有什么，桌面上连滚动条都没有——等于把一半的能力藏了起来。
  /// 现在整只 [Wrap] 铺开：几行换行换来的是「一眼看全」。
  Widget _buildTrayContent(BuildContext context, {required bool stacked}) {
    final t = slang.Translations.of(context);
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // 三个色点是 chip 上小圆点的图例（同色即同类，chip 已按类相邻排列）——
    // 有了它就不必再画三条分组标题去占高度。
    final legend = [
      legendDot(_TrayCategory.content, e.trayCategoryContent),
      const SizedBox(width: 9),
      legendDot(_TrayCategory.author, e.trayCategoryAuthor),
      const SizedBox(width: 9),
      legendDot(_TrayCategory.time, e.trayCategoryTime),
    ];
    final hint = Text(
      e.trayHint,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: cs.onSurfaceVariant.withValues(alpha: 0.75),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stacked) ...[
          Row(children: legend),
          const SizedBox(height: 4),
          hint,
        ] else
          Row(
            children: [
              Expanded(child: hint),
              const SizedBox(width: 10),
              ...legend,
            ],
          ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final spec in _trayChips(t)) _buildTrayChip(context, spec),
          ],
        ),
      ],
    );
  }

  /// 单枚变量 chip。
  ///
  /// [Tooltip] 是给桌面补的那半条交互：触屏上长按看说明，鼠标上没有「长按」，
  /// 悬停即见。全局 `tooltipTheme` 把触发模式钉成 manual，所以它不会在触屏上
  /// 抢走这里的 `onLongPress`（见 my_app.dart 那段注释）。
  Widget _buildTrayChip(BuildContext context, _TrayChipSpec spec) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _trayColor(spec.category, cs, theme.brightness);
    final variable = FilenameTemplateService.to
        .getSupportedVariables()
        .where((v) => v.variable == '%${spec.token}')
        .firstOrNull;
    return Tooltip(
      message: variable == null
          ? '%${spec.token}'
          : '%${spec.token} · ${variable.description}',
      child: Material(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () => _insertVariable(spec.token),
          onLongPress: () => _showVariableDescription(spec.token),
          child: Container(
            // 高度 36：低于这个数在手机上点不准，chip 又不该长成按钮那么胖。
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
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

  /// 托盘 chip，**按分类连续排列**。
  ///
  /// 顺序不是随手写的：[Wrap] 里换行是连续铺的，同类挨着才会在视觉上自然
  /// 结块，配上 chip 里的色点就不必再画三条分组标题去占高度。原先是三类
  /// 交替排（内容-作者-作者-作者-内容…），色点看上去就只是彩色噪点。
  List<_TrayChipSpec> _trayChips(slang.Translations t) {
    final e = t.settings.downloadSettings.pathTemplateEditor;
    final v = t.settings.downloadSettings;
    return [
      _TrayChipSpec('title', _TrayCategory.content, (_) => v.variableTitle),
      _TrayChipSpec('quality', _TrayCategory.content, (_) => v.variableQuality),
      _TrayChipSpec('id', _TrayCategory.content, (_) => v.variableId),
      _TrayChipSpec(
        'filename',
        _TrayCategory.content,
        (_) => v.variableFilename,
      ),
      // ⛔ 时间三件与序号用 chip 专属短名，别换回 `variableDate` 那组。
      // 那组是帮助弹窗用的完整说明（「当前日期 (YYYY-MM-DD)」），摆到 chip 上
      // 一枚就占掉半行，托盘从两行胀到四行——格式说明属于 tooltip / 长按。
      _TrayChipSpec('count', _TrayCategory.content, (_) => e.chipCount),
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
      _TrayChipSpec('date', _TrayCategory.time, (_) => e.chipDate),
      _TrayChipSpec('time', _TrayCategory.time, (_) => e.chipTime),
      _TrayChipSpec('datetime', _TrayCategory.time, (_) => e.chipDatetime),
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
    // pop 用弹窗自己的 context，理由见 [_confirmDiscard]。
    showAppDialog(
      Builder(
        builder: (dialogContext) => GlassAlertDialog(
          title: variable.variable,
          maxWidth: 420,
          content: Text(variable.description),
          actions: [
            GlassDialogAction(
              label: t.common.confirm,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
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
