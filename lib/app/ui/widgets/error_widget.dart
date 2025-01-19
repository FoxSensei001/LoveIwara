import 'package:flutter/material.dart';

class CommonErrorWidget extends StatelessWidget {
  final String text;
  final List<Widget>? children;
  final double? maxWidth;

  const CommonErrorWidget({
    super.key,
    required this.text,
    this.children,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacingUnit = theme.visualDensity.baseSizeAdjustment.dx;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxWidth ?? theme.buttonTheme.minWidth * 3),
        child: Card(
          elevation: theme.cardTheme.elevation ?? 0,
          margin: EdgeInsets.all(spacingUnit + 8),
          child: Padding(
            padding: EdgeInsets.all(spacingUnit + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error),
                    SizedBox(width: spacingUnit + 16),
                    Expanded(
                      child: Text(
                        text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                if (children != null) ...[
                  SizedBox(height: spacingUnit + 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: children!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
