import 'dart:io';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 从目录内已有的图里挑一张当封面。
///
/// [folderPath] 为 null 时是**平的源**（「已下载」「设备视频」没有目录树，见
/// [LocalFolderActions]）：候选改从整个源里取，而不是某一个目录直属。
Future<bool> showLocalFolderCoverPickerDialog({
  required BuildContext context,
  required String sourceId,
  required String relPath,
  required String? folderPath,
}) async {
  final result = await showAppDialog<bool>(
    _LocalFolderCoverPickerDialog(
      sourceId: sourceId,
      relPath: relPath,
      folderPath: folderPath,
    ),
    dialogContext: context,
  );
  return result ?? false;
}

class _LocalFolderCoverPickerDialog extends StatefulWidget {
  const _LocalFolderCoverPickerDialog({
    required this.sourceId,
    required this.relPath,
    required this.folderPath,
  });

  final String sourceId;
  final String relPath;
  final String? folderPath;

  @override
  State<_LocalFolderCoverPickerDialog> createState() =>
      _LocalFolderCoverPickerDialogState();
}

class _LocalFolderCoverPickerDialogState
    extends State<_LocalFolderCoverPickerDialog> {
  late final List<String> _candidates;

  /// 当前正在用的那张封面。没有它的话，用户打开这张网格的第一个疑问
  /// 「我现在用的是哪张」就没人回答，只能靠猜。
  String? _currentCover;
  bool _selecting = false;

  @override
  void initState() {
    super.initState();
    final repository = LocalMediaRepository();
    final folderPath = widget.folderPath;
    _candidates = (folderPath == null || folderPath.isEmpty)
        ? repository.sourceCoverCandidates(sourceId: widget.sourceId)
        : repository.folderCoverCandidates(
            sourceId: widget.sourceId,
            folderPath: folderPath,
          );
    _currentCover = repository
        .getFolder(sourceId: widget.sourceId, relPath: widget.relPath)
        ?.coverPath;
  }

  Future<void> _selectCover(String coverPath) async {
    if (_selecting) return;
    setState(() {
      _selecting = true;
    });
    try {
      final ok = LocalMediaRepository().setFolderCover(
        sourceId: widget.sourceId,
        relPath: widget.relPath,
        coverPath: coverPath,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        Navigator.of(context, rootNavigator: true).pop(false);
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(false);
    } finally {
      if (mounted) {
        setState(() {
          _selecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Widget body;
    if (_candidates.isEmpty) {
      body = Padding(
        key: const ValueKey('empty'),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            slang.t.localMedia.browse.coverPickerEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = LayoutBuilder(
        key: const ValueKey('grid'),
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // 按可用宽度自适应每行 3~4 张
          final crossAxisCount = width > 360 ? 4 : 3;
          const spacing = 8.0;
          final cellWidth =
              (width - spacing * (crossAxisCount - 1)) / crossAxisCount;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _candidates.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: LocalFolderCardWidget.coverAspectRatio,
              ),
              itemBuilder: (context, index) {
                final candidatePath = _candidates[index];
                final isCurrent = candidatePath == _currentCover;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent
                        ? Border.all(color: cs.primary, width: 2.5)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: cs.surfaceContainerHighest,
                      child: InkWell(
                        onTap: _selecting
                            ? null
                            : () => _selectCover(candidatePath),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.file(
                              File(candidatePath),
                              fit: BoxFit.cover,
                              cacheWidth:
                                  (cellWidth *
                                          MediaQuery.devicePixelRatioOf(
                                            context,
                                          ))
                                      .round()
                                      .clamp(1, 1280),
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 24,
                                      color: cs.outline,
                                    ),
                                  ),
                            ),
                            if (isCurrent)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return GlassAlertDialog(
      title: slang.t.localMedia.browse.folderCoverPickerTitle,
      maxWidth: 520,
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: body,
      ),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: _selecting
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
      ],
    );
  }
}
