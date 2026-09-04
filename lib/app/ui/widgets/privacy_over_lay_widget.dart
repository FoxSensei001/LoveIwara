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

    // 这层遮罩会被系统拍进「最近任务」缩略图，颜色必须跟着应用主题走，
    // 否则深色模式下切后台会闪出一整屏纯白。
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final watermarkColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.10 : 0.14,
    );
    // Shimmer 用 srcATop 把渐变直接盖在文字上，半透明的渐变色会与底下的
    // 文字颜色混出不可控的结果，这里先自己压平成不透明色再交给它。
    Color onSurfaceOver(double alpha) => Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: alpha),
      colorScheme.surface,
    );
    final shimmerBase = onSurfaceOver(isDark ? 0.34 : 0.30);
    final shimmerHighlight = onSurfaceOver(isDark ? 0.14 : 0.12);

    return Material(
      child: Container(
        color: colorScheme.surface,
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
                            color: watermarkColor,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Shimmer.fromColors(
                  baseColor: shimmerBase,
                  highlightColor: shimmerHighlight,
                  child: Text(
                    t.common.privacyHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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