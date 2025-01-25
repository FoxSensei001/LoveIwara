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
            maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.8),
        child: Card(
          elevation: theme.cardTheme.elevation ?? 0,
          margin: EdgeInsets.all(spacingUnit + 8),
          child: Padding(
            padding: EdgeInsets.all(spacingUnit + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  spacing: spacingUnit + 16,
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error),
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
                  Wrap(
                    spacing: spacingUnit + 8,
                    runSpacing: spacingUnit + 8,
                    alignment: WrapAlignment.end,
                    textDirection: TextDirection.rtl,
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
