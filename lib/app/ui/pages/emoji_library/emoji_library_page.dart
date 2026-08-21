import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_group_detail_page.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 表情包库（分组列表）。与 download_category_manage_page 同构：
/// 玻璃 header（返回圆钮 / 标题胶囊 / 动作胶囊）+ 可拖拽排序的分组卡片列表。
class EmojiLibraryPage extends StatefulWidget {
  const EmojiLibraryPage({super.key});

  @override
  State<EmojiLibraryPage> createState() => _EmojiLibraryPageState();
}

class _EmojiLibraryPageState extends State<EmojiLibraryPage> {
  late EmojiLibraryService _emojiService;
  List<EmojiGroup> _groups = [];
  final Map<int, int> _groupImageCounts = {};
  bool _isDragMode = false;

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _groups = _emojiService.getEmojiGroups();
      _groupImageCounts.clear();
      for (final group in _groups) {
        _groupImageCounts[group.groupId] = _emojiService.getEmojiImageCount(
          group.groupId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
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
          headerExtent: headerExtent,
          headerTop: statusBarHeight,
          solidExtent: statusBarHeight,
          body: _buildBody(context, headerExtent, t),
          // header 行：左 返回圆钮 / 中 标题胶囊 / 右 动作胶囊
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
                Expanded(child: GlassTitlePill(title: t.emoji.library)),
                const SizedBox(width: 8),
                _buildActionGroup(t),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 右侧动作胶囊：编辑/完成拖拽排序 · 新建分组。
  Widget _buildActionGroup(Translations t) {
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: Icon(_isDragMode ? Icons.check : Icons.drag_handle),
          tooltip: _isDragMode ? t.common.exitEditMode : t.common.editMode,
          onPressed: () => setState(() => _isDragMode = !_isDragMode),
        ),
        GlassIconButton(
          icon: const Icon(Icons.add),
          tooltip: t.emoji.createGroup,
          onPressed: () => _showCreateGroupDialog(),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    double headerExtent,
    Translations t,
  ) {
    final double bottomInset =
        computeBottomSafeInset(MediaQuery.of(context)) + 8;

    if (_groups.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(top: headerExtent),
              child: Center(
                child: Text(
                  t.emoji.noEmojis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(16, headerExtent + 8, 16, bottomInset),
      itemCount: _groups.length,
      buildDefaultDragHandles: false,
      onReorderItem: (oldIndex, newIndex) {
        setState(() {
          final item = _groups.removeAt(oldIndex);
          _groups.insert(newIndex, item);
        });
        _emojiService.updateEmojiGroupsOrder(_groups);
      },
      itemBuilder: (context, index) =>
          _buildGroupCard(context, t, _groups[index], index),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    Translations t,
    EmojiGroup group,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageCount = _groupImageCounts[group.groupId] ?? 0;

    return Card(
      key: ValueKey(group.groupId),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isDragMode) ...[
              ReorderableDragStartListener(
                index: index,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Icon(Icons.drag_handle, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: group.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        group.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildGroupInitial(colorScheme, group.name),
                      ),
                    )
                  : _buildGroupInitial(colorScheme, group.name),
            ),
          ],
        ),
        title: Text(
          group.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(t.emoji.imageCount(count: imageCount)),
        trailing: _isDragMode
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassIconButton(
                    standalone: true,
                    size: 36,
                    iconSize: 18,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: t.emoji.editGroupName,
                    onPressed: () => _showEditGroupDialog(group),
                  ),
                  const SizedBox(width: 4),
                  GlassIconButton(
                    standalone: true,
                    size: 36,
                    iconSize: 18,
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                    tooltip: t.emoji.deleteGroup,
                    onPressed: () => _showDeleteGroupDialog(group),
                  ),
                ],
              ),
        onTap: () => _navigateToGroupDetail(group),
      ),
    );
  }

  Widget _buildGroupInitial(ColorScheme colorScheme, String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  void _navigateToGroupDetail(EmojiGroup group) {
    EmojiGroupDetailPage.show(context, group);
    _loadData();
  }

  /// 弹窗标题行：标题 + 玻璃关闭圆钮（全局统一约定）。
  Widget _dialogTitleRow(Translations t, String title) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.close),
          tooltip: t.common.close,
          onPressed: () => AppService.tryPop(),
        ),
      ],
    );
  }

  void _showCreateGroupDialog() {
    final t = Translations.of(context);
    final controller = TextEditingController();
    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(t, t.emoji.createGroup),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: t.emoji.groupName,
            hintText: t.emoji.enterGroupName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _emojiService.createEmojiGroup(name);
                AppService.tryPop();
                _loadData();
                showGlassToast(t.common.success, type: GlassToastType.success);
              }
            },
            child: Text(t.emoji.create),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(EmojiGroup group) {
    final t = Translations.of(context);
    final controller = TextEditingController(text: group.name);
    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(t, t.emoji.editGroupName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: t.emoji.groupName),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _emojiService.updateEmojiGroupName(group.groupId, name);
                AppService.tryPop();
                _loadData();
                showGlassToast(t.common.success, type: GlassToastType.success);
              }
            },
            child: Text(t.emoji.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(EmojiGroup group) {
    final t = Translations.of(context);
    showAppDialog(
      AlertDialog(
        title: _dialogTitleRow(t, t.emoji.deleteGroup),
        content: Text(t.emoji.confirmDeleteGroup),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(t.emoji.cancel),
          ),
          TextButton(
            onPressed: () {
              _emojiService.deleteEmojiGroup(group.groupId);
              AppService.tryPop();
              _loadData();
              showGlassToast(t.common.success, type: GlassToastType.success);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.emoji.delete),
          ),
        ],
      ),
    );
  }
}
