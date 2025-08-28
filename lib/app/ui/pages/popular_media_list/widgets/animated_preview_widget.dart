import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/common/constants.dart';

class AnimatedPreview extends StatefulWidget {
  final String videoId;
  final int numThumbnails;
  final double width;
  final double height;
  final BoxFit fit;

  const AnimatedPreview({
    super.key,
    required this.videoId,
    required this.numThumbnails,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  State<AnimatedPreview> createState() => _AnimatedPreviewState();
}

class _AnimatedPreviewState extends State<AnimatedPreview> {
  late List<String> thumbnailUrls;
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    thumbnailUrls = List.generate(widget.numThumbnails, (index) {
      String paddedIndex = index.toString().padLeft(2, '0');
      return '${CommonConstants.iwaraImageBaseUrl}/image/thumbnail/${widget.videoId}/thumbnail-$paddedIndex.jpg';
    });

    if (thumbnailUrls.isNotEmpty) {
      timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
        if (mounted) {
          setState(() {
            currentIndex = (currentIndex + 1) % thumbnailUrls.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrls.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
      );
    }

    return Stack(
      children: thumbnailUrls.asMap().entries.map((entry) {
        int idx = entry.key;
        String url = entry.value;
        return Opacity(
          opacity: idx == currentIndex ? 1.0 : 0.0,
          child: CachedNetworkImage(
            imageUrl: url,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: (context, url) => Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[300],
            ),
            errorWidget: (context, url, error) => Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 50),
            ),
          ),
        );
      }).toList(),
    );
  }
}
