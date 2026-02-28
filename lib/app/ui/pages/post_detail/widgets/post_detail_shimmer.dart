import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostDetailShimmer extends StatelessWidget {
  final double topPadding;
  final bool isWideLayout;
  final double availableWideHeight;
  final String? heroTag;

  const PostDetailShimmer({
    super.key,
    required this.topPadding,
    required this.isWideLayout,
    required this.availableWideHeight,
    this.heroTag,
  });

  Widget _block({
    required double height,
    double? width,
    BorderRadiusGeometry? radius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: shape == BoxShape.circle
            ? null
            : (radius ?? BorderRadius.circular(8)),
        shape: shape,
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: child,
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final card = _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(height: 22, width: double.infinity),
          const SizedBox(height: 8),
          _block(height: 22, width: 240),
          const SizedBox(height: 14),
          Row(
            children: [
              _block(height: 42, width: 42, shape: BoxShape.circle),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(height: 16, width: 120),
                    const SizedBox(height: 6),
                    _block(height: 12, width: 100),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _block(height: 34, width: 88),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _block(height: 28, width: 130),
              _block(height: 28, width: 120),
              _block(height: 28, width: 100),
            ],
          ),
        ],
      ),
    );
    if (heroTag == null) {
      return card;
    }
    return Hero(tag: heroTag!, child: card);
  }

  Widget _buildContentCard(BuildContext context) {
    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(height: 18, width: 150),
          const SizedBox(height: 12),
          _block(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          _block(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          _block(height: 14, width: 240),
          const SizedBox(height: 10),
          _block(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          _block(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          _block(height: 14, width: 180),
        ],
      ),
    );
  }

  Widget _buildCommentEntryCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _block(height: 16, width: 16, radius: BorderRadius.circular(999)),
            const SizedBox(width: 6),
            _block(height: 18, width: 110),
          ],
        ),
        const SizedBox(height: 8),
        _block(
          height: 48,
          width: double.infinity,
          radius: BorderRadius.circular(14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = 12 + MediaQuery.paddingOf(context).bottom;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isWideLayout
          ? Padding(
              padding: EdgeInsets.fromLTRB(12, topPadding + 6, 12, 0),
              child: SizedBox(
                height: availableWideHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 360,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewCard(context),
                            const SizedBox(height: 12),
                            _buildCommentEntryCard(context),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: _buildContentCard(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  topPadding + 4,
                  12,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(context),
                    const SizedBox(height: 12),
                    _buildContentCard(context),
                    const SizedBox(height: 12),
                    _buildCommentEntryCard(context),
                  ],
                ),
              ),
            ),
    );
  }
}
