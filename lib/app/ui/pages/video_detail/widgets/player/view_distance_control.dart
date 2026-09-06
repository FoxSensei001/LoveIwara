import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// A one-handed alternative to pinch: press to move, release/cancel to stop.
/// Owns its ticker and pointer lifecycle; media state remains with the caller.
class ViewDistanceControl extends StatefulWidget {
  const ViewDistanceControl({
    super.key,
    required this.visible,
    required this.onScale,
    required this.onReset,
    required this.onInteraction,
    required this.maxWidth,
    this.materialize = 1,
    this.compact = false,
    this.cancelSignal,
  });

  final bool visible;
  final ValueChanged<double> onScale;
  final VoidCallback onReset;
  final ValueChanged<bool> onInteraction;
  final double maxWidth;
  final double materialize;
  final bool compact;
  final Listenable? cancelSignal;

  @override
  State<ViewDistanceControl> createState() => _ViewDistanceControlState();
}

class _ViewDistanceControlState extends State<ViewDistanceControl>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker = createTicker(_tick);
  final Set<int> _pointers = {};
  Duration _lastTick = Duration.zero;
  int _direction = 0;
  bool _expanded = false;
  bool _interacting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.cancelSignal?.addListener(_cancel);
  }

  @override
  void didUpdateWidget(ViewDistanceControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cancelSignal != widget.cancelSignal) {
      oldWidget.cancelSignal?.removeListener(_cancel);
      widget.cancelSignal?.addListener(_cancel);
      _stop();
    }
    if (!widget.visible) {
      _stop();
      if (widget.materialize <= 0) _expanded = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _stop();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.cancelSignal?.removeListener(_cancel);
    _stop();
    _ticker.dispose();
    super.dispose();
  }

  void _syncInteraction() {
    final active = _pointers.isNotEmpty || _direction != 0;
    if (active == _interacting) return;
    _interacting = active;
    widget.onInteraction(active);
  }

  void _stop() {
    _direction = 0;
    _ticker.stop();
    _pointers.clear();
    _syncInteraction();
  }

  void _cancel() {
    _stop();
    if (mounted) setState(() {});
  }

  void _hold(int direction, bool pressed) {
    if (!mounted || !widget.visible) return;
    if (pressed) {
      _ticker.stop();
      _lastTick = Duration.zero;
      setState(() => _direction = direction);
      _syncInteraction();
      // A short tap makes a small adjustment too; continuous movement starts from this value.
      widget.onScale(math.exp(direction * 0.025));
      _ticker.start();
    } else if (_direction == direction) {
      setState(() => _direction = 0);
      _ticker.stop();
      _syncInteraction();
    }
  }

  void _tick(Duration elapsed) {
    final seconds = ((elapsed - _lastTick).inMicroseconds / 1000000).clamp(
      0.0,
      0.05,
    );
    _lastTick = elapsed;
    if (_direction != 0 && seconds > 0) {
      widget.onScale(math.exp(_direction * 0.55 * seconds));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && widget.materialize <= 0) {
      return const SizedBox.shrink();
    }
    final t = slang.Translations.of(context);
    final width = math.min(320.0, widget.maxWidth);
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: const ColorScheme.dark().onSurface),
        child: IconTheme.merge(
          data: IconThemeData(color: const ColorScheme.dark().onSurface),
          child: IgnorePointer(
            ignoring: !widget.visible,
            child: Listener(
              onPointerDown: (event) {
                _pointers.add(event.pointer);
                _syncInteraction();
              },
              onPointerUp: (event) {
                _pointers.remove(event.pointer);
                _syncInteraction();
              },
              onPointerCancel: (event) {
                _pointers.remove(event.pointer);
                _syncInteraction();
              },
              // Keep button hit targets at their final width during expansion. The material's
              // press animation must not squeeze the new row into the old pill's width.
              child: SizedBox(
                width: _expanded ? width : math.min(148, width),
                child: GlassSurface(
                  height: null,
                  borderRadius: BorderRadius.circular(20),
                  padding: EdgeInsets.all(_expanded ? 8 : 0),
                  liquidTouch: false,
                  materialize: widget.materialize,
                  child: _expanded
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _holdButton(
                                    -1,
                                    Icons.zoom_out,
                                    t.vrFormat.viewFarther,
                                  ),
                                ),
                                Expanded(
                                  child: GlassTapArea(
                                    onTap: () {
                                      _stop();
                                      widget.onReset();
                                    },
                                    child: SizedBox(
                                      height: 48,
                                      child: Center(
                                        child: Text(
                                          t.vrFormat.resetDistance,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _holdButton(
                                    1,
                                    Icons.zoom_in,
                                    t.vrFormat.viewNearer,
                                  ),
                                ),
                                GlassTapArea(
                                  onTap: () {
                                    _stop();
                                    setState(() => _expanded = false);
                                  },
                                  child: const SizedBox(
                                    width: 36,
                                    height: 48,
                                    child: Icon(Icons.close, size: 18),
                                  ),
                                ),
                              ],
                            ),
                            if (!widget.compact)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Text(
                                  t.vrFormat.viewDistanceHint,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        )
                      : GlassTapArea(
                          onTap: () => setState(() => _expanded = true),
                          child: SizedBox(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.zoom_out_map, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    t.vrFormat.viewDistance,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _holdButton(int direction, IconData icon, String label) {
    return Semantics(
      button: true,
      label: label,
      onTap: () => widget.onScale(math.exp(direction * 0.08)),
      child: GlassTapArea(
        excludeFromSemantics: true,
        onTap: () {},
        onPressedChanged: (pressed) => _hold(direction, pressed),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 48,
          decoration: BoxDecoration(
            color: _direction == direction
                ? const Color(0xFF3D5069)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
