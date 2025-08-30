import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/shared_ui_constants.dart';

class ExpandableSectionWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;
  final VoidCallback? onHelpTap;
  final bool showHelpButton;
  final bool showToggleButton;

  const ExpandableSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = true,
    this.onHelpTap,
    this.showHelpButton = false,
    this.showToggleButton = true,
  });

  @override
  State<ExpandableSectionWidget> createState() => _ExpandableSectionWidgetState();
}

class _ExpandableSectionWidgetState extends State<ExpandableSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: UIConstants.iconTextSpacing),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              if (widget.showHelpButton)
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.onHelpTap,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.help_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              if (widget.showToggleButton)
                IconButton(
                  icon: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: const Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _handleToggle,
                ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: SizeTransition(
                    sizeFactor: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(curvedAnimation),
                    axis: Axis.vertical,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                ),
              );
            },
            child: _isExpanded
                ? Column(
                    key: ValueKey('expanded_${widget.title}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: UIConstants.listSpacing),
                      widget.child,
                    ],
                  )
                : SizedBox.shrink(key: ValueKey('collapsed_${widget.title}')),
          ),
        ],
      ),
    );
  }
}
