import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/split_button_widget.dart'
    show FilledActionButton;
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 详情页动作栏里的「稍后再看」。视频与图库共用。
///
/// # 为什么是一个组件而不是两个
///
/// 两边的行为一字不差：查本地库、切换、四种结果各自的 toast、加成功之后那枚
/// 「查看列表」。差别只有"这一条是视频还是图库"——那是一个参数，不是一套代码。
///
/// 自己维护在场状态：稍后再看是纯本地库，加/删都是同步的，没必要为它单独往
/// controller 里塞一份 Rx。列表在别处被改（比如稍后再看页里删掉了这一条）时
/// 靠 [WatchLaterService.watchLaterChangedNotifier] 跟上。
class WatchLaterActionButton extends StatefulWidget {
  const WatchLaterActionButton({super.key, this.video, this.gallery})
    : assert(
        (video == null) != (gallery == null),
        'WatchLaterActionButton 一次只处理一条媒体：video 与 gallery 二选一',
      );

  final Video? video;
  final ImageModel? gallery;

  @override
  State<WatchLaterActionButton> createState() => _WatchLaterActionButtonState();
}

class _WatchLaterActionButtonState extends State<WatchLaterActionButton> {
  bool _inList = false;

  String get _itemId => widget.video?.id ?? widget.gallery!.id;

  WatchLaterItemType get _itemType => widget.video != null
      ? WatchLaterItemType.video
      : WatchLaterItemType.image;

  @override
  void initState() {
    super.initState();
    _sync();
    WatchLaterService.to.watchLaterChangedNotifier.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant WatchLaterActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 详情页可能在原地换了一条（池内续播就是这么走的），换了就得重查。
    if (oldWidget.video?.id != widget.video?.id ||
        oldWidget.gallery?.id != widget.gallery?.id) {
      _sync();
    }
  }

  @override
  void dispose() {
    WatchLaterService.to.watchLaterChangedNotifier.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final next = WatchLaterService.to.contains(_itemId, _itemType);
    if (next != _inList) setState(() => _inList = next);
  }

  void _toggle() {
    final t = slang.Translations.of(context);
    if (_inList) {
      WatchLaterService.to.remove(_itemId, _itemType);
      showAppToast(
        t.watchLater.removedFromWatchLater,
        type: AppToastType.info,
      );
      return;
    }
    final result = widget.video != null
        ? WatchLaterService.to.addVideo(widget.video!)
        : WatchLaterService.to.addImageModel(widget.gallery!);
    switch (result) {
      case WatchLaterAddResult.added:
        // toast 上挂一枚「查看列表」——加完之后想去看看是最自然的下一步。
        showAppToast(
          t.watchLater.addedToWatchLater,
          type: AppToastType.success,
          actionLabel: t.watchLater.viewWatchLaterList,
          onAction: NaviService.navigateToWatchLaterPage,
        );
      case WatchLaterAddResult.alreadyExists:
        showAppToast(
          t.watchLater.alreadyInWatchLater,
          type: AppToastType.info,
        );
      case WatchLaterAddResult.failed:
        showAppToast(t.watchLater.addFailed, type: AppToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return FilledActionButton(
      icon: _inList ? Icons.watch_later : Icons.watch_later_outlined,
      label: t.watchLater.title,
      onTap: _toggle,
      // ⛔ 必须走 colorScheme.primary：primaryColor 是 M2 遗留字段，M3 深色主题
      // 下它不跟随 colorScheme 翻转，选中态会糊成近黑色。
      accentColor: _inList ? Theme.of(context).colorScheme.primary : null,
    );
  }
}
