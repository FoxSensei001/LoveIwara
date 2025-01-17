import 'dart:math';

import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:shimmer/shimmer.dart';

class PrivacyOverlay extends StatefulWidget {
  const PrivacyOverlay({super.key});

  @override
  State<PrivacyOverlay> createState() => _PrivacyOverlayState();
}

class _PrivacyOverlayState extends State<PrivacyOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final watermarkSpacing = size.width / 4;
    final rows = (size.height / watermarkSpacing).ceil() + 1;
    final cols = (size.width / watermarkSpacing).ceil() + 1;

    return Material(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // 背景水印网格
            ...List.generate(rows * cols, (index) {
              final row = index ~/ cols;
              final col = index % cols;
              
              final baseX = (col * watermarkSpacing) - (watermarkSpacing / 2);
              final baseY = (row * watermarkSpacing) - (watermarkSpacing / 2);
              
              return Positioned(
                left: baseX,
                top: baseY,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        20 * sin(_controller.value * 2 * pi + index),
                        20 * cos(_controller.value * 2 * pi + index),
                      ),
                      child: Transform.rotate(
                        angle: -pi / 4,
                        child: Text(
                          t.common.privacyHint,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            // 中央主要文字
            Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Text(
                  t.common.privacyHint,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}