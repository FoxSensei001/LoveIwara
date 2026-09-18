import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_cover_image.dart';

/// 图片条目的格子图。
///
/// 本机图片：图就是它自己，直接画原图（与以前一样，一次派生都不排）。
///
/// NAS 图片（`dav:/…`）：原图在远端，`Image.file` 画不出来。挂上时向派生服务要
/// 一张拉进本机缓存的缩略图（前台请求，见 `LocalMediaDerivationService.enqueue`），
/// 拿到之前显示 [placeholder]。
class LocalImageThumb extends StatefulWidget {
  const LocalImageThumb({
    super.key,
    required this.item,
    required this.placeholder,
  });

  final LocalMediaItem item;
  final Widget placeholder;

  @override
  State<LocalImageThumb> createState() => _LocalImageThumbState();
}

class _LocalImageThumbState extends State<LocalImageThumb> {
  LocalMediaItem? _derived;

  LocalMediaItem get _item => _derived ?? widget.item;

  @override
  void initState() {
    super.initState();
    _requestIfRemote();
  }

  @override
  void didUpdateWidget(covariant LocalImageThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _derived = null;
      _requestIfRemote();
    } else if (!identical(oldWidget.item, widget.item)) {
      _derived = null;
    }
  }

  void _requestIfRemote() {
    final item = widget.item;
    if (!DavPath.isDav(item.path) || item.thumbPath != null) return;
    if (!Get.isRegistered<LocalMediaDerivationService>()) return;
    unawaited(
      LocalMediaDerivationService.to.ensureDerived(item).then((updated) {
        if (!mounted || updated == null || updated.id != widget.item.id) {
          return;
        }
        setState(() => _derived = updated);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = _item.coverImagePath;
    if (path == null || path.isEmpty) return widget.placeholder;
    return LocalCoverImage(path: path, placeholder: widget.placeholder);
  }
}
