import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_relocation_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_relocation_flow.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/rx_ever.dart';

/// 「有 N 项已下载内容不在这个目录里 · 移到这里」。
///
/// 改下载目录只影响**以后**的下载，之前下的还在老地方——那没问题，它们照样
/// 能播；但用户往往以为改了目录东西就全过去了。这张卡把差异摆出来，一键搬齐。
///
/// 设置页「更改位置」流程在确认那一步也会问一次（搬过去 / 保留 / 以后再说）；
/// 这张卡兜住其余情况——默认目录变了、选了「以后再说」、别处改的配置——它只认
/// 「当前生效的目录」这一个结果，哪条路改的都一样。
class DownloadsOutsideFolderCard extends StatefulWidget {
  const DownloadsOutsideFolderCard({super.key});

  @override
  State<DownloadsOutsideFolderCard> createState() =>
      _DownloadsOutsideFolderCardState();
}

class _DownloadsOutsideFolderCardState
    extends State<DownloadsOutsideFolderCard> {
  static const _tag = 'DownloadsOutsideFolderCard';

  String? _directory;
  List<String> _outside = const [];
  late final Worker _pathWorker;

  @override
  void initState() {
    super.initState();
    // 路径状态每次改目录后都会刷新一遍，跟着它重算。
    // ⛔ 用 rxEver 不用 ever：后者二次进页面会静默失聪（见 rxEver 的文档）。
    _pathWorker = rxEver(
      DownloadPathService.to.pathStatusRx,
      (_) => unawaited(_refresh()),
    );
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _pathWorker.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final pathService = DownloadPathService.to;
    if (!pathService.hasFixedDownloadDirectory ||
        !Get.isRegistered<DownloadRelocationService>()) {
      if (mounted) setState(() => _outside = const []);
      return;
    }
    try {
      final directory = await pathService.migrationTargetDirectory();
      final outside = directory == null
          ? const <String>[]
          : await DownloadRelocationService.to.movableTaskIdsOutside(directory);
      if (!mounted) return;
      setState(() {
        _directory = directory;
        _outside = outside;
      });
    } catch (e) {
      LogUtils.w('统计目录外的下载失败: $e', _tag);
    }
  }

  Future<void> _moveHere() async {
    final directory = _directory;
    if (directory == null || _outside.isEmpty) return;
    await startDownloadRelocation(_outside, destination: directory);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context).download.relocation;
    final theme = Theme.of(context);
    final visible = _outside.isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      child: !visible
          ? const SizedBox(key: ValueKey('empty'), width: double.infinity)
          : Padding(
              key: const ValueKey('card'),
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassSettingSection(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.drive_folder_upload_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.outsideTitle(count: _outside.length),
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.outsideSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => GlassButtonGroup(
                            children: [
                              GlassTextActionButton(
                                label: t.moveHere,
                                emphasized: true,
                                onPressed:
                                    DownloadRelocationService.to.running.value
                                    ? null
                                    : _moveHere,
                              ),
                            ],
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
}
