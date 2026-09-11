import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 让用户从 [item] 里挑一帧当封面。返回 true 表示封面换了（调用方据此刷新）。
Future<bool> showLocalCoverPickerDialog({
  required BuildContext context,
  required LocalMediaItem item,
}) async {
  final result = await showAppDialog<bool>(
    _LocalCoverPickerDialog(item: item),
    dialogContext: context,
  );
  return result ?? false;
}

class _LocalCoverPickerDialog extends StatefulWidget {
  const _LocalCoverPickerDialog({required this.item});

  final LocalMediaItem item;

  @override
  State<_LocalCoverPickerDialog> createState() =>
      _LocalCoverPickerDialogState();
}

class _LocalCoverPickerDialogState extends State<_LocalCoverPickerDialog> {
  LocalCoverPickerSession? _session;
  bool _opening = true;
  bool _openFailed = false;
  Duration _duration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Uint8List? _frameBytes;
  bool _fetchingFrame = false;
  Duration? _pendingTarget;
  Timer? _debounceTimer;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    unawaited(_session?.close());
    super.dispose();
  }

  Future<void> _open() async {
    final session = await LocalMediaDerivationService.openCoverPicker(
      widget.item.resolvePlaybackTarget(),
    );
    if (!mounted) {
      unawaited(session?.close());
      return;
    }
    if (session == null) {
      setState(() {
        _opening = false;
        _openFailed = true;
      });
      return;
    }

    _session = session;
    final duration = session.duration;
    final initialPosMs = (duration.inMilliseconds * 0.2).round();
    final initialPosition = Duration(milliseconds: initialPosMs);

    setState(() {
      _opening = false;
      _duration = duration;
      _currentPosition = initialPosition;
    });

    unawaited(_fetchFrame(initialPosition));
  }

  void _onSliderChanged(double value) {
    final pos = Duration(milliseconds: value.round());
    setState(() {
      _currentPosition = pos;
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchFrame(pos);
    });
  }

  void _onSliderChangeEnd(double value) {
    _debounceTimer?.cancel();
    final pos = Duration(milliseconds: value.round());
    _fetchFrame(pos);
  }

  Future<void> _fetchFrame(Duration at) async {
    final session = _session;
    if (session == null || !mounted) return;

    if (_fetchingFrame) {
      _pendingTarget = at;
      return;
    }

    setState(() {
      _fetchingFrame = true;
    });

    try {
      final bytes = await session.frameAt(at);
      if (!mounted) return;
      if (bytes != null) {
        setState(() {
          _frameBytes = bytes;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _fetchingFrame = false;
        });
        if (_pendingTarget != null) {
          final nextTarget = _pendingTarget!;
          _pendingTarget = null;
          unawaited(_fetchFrame(nextTarget));
        }
      }
    }
  }

  Future<void> _onConfirm() async {
    final bytes = _frameBytes;
    if (bytes == null || _saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final resultPath = await LocalMediaDerivationService.to.saveCustomCover(
        item: widget.item,
        bytes: bytes,
      );
      if (!mounted) return;
      if (resultPath != null) {
        showAppToast(slang.t.localMedia.browse.coverSaved);
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        showAppToast(
          slang.t.localMedia.browse.coverSaveFailed,
          type: AppToastType.error,
        );
        Navigator.of(context, rootNavigator: true).pop(false);
      }
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        slang.t.localMedia.browse.coverSaveFailed,
        type: AppToastType.error,
      );
      Navigator.of(context, rootNavigator: true).pop(false);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_openFailed) {
      return GlassAlertDialog(
        title: slang.t.localMedia.browse.coverPickerTitle,
        maxWidth: 520,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              slang.t.localMedia.browse.coverUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
          ),
        ],
      );
    }

    final durationMs = _duration.inMilliseconds.toDouble();
    final sliderValue = durationMs > 0
        ? _currentPosition.inMilliseconds.toDouble().clamp(0.0, durationMs)
        : 0.0;

    final String positionText;
    if (_duration > Duration.zero) {
      positionText =
          '${CommonUtils.formatDuration(_currentPosition)} / ${CommonUtils.formatDuration(_duration)}';
    } else {
      positionText = '--:-- / --:--';
    }

    return GlassAlertDialog(
      title: slang.t.localMedia.browse.coverPickerTitle,
      maxWidth: 520,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_frameBytes != null)
                    Image.memory(
                      _frameBytes!,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    )
                  else
                    const SizedBox.expand(),
                  if (_fetchingFrame || _opening)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: sliderValue,
            min: 0.0,
            max: durationMs > 0 ? durationMs : 1.0,
            onChanged: (_saving || durationMs <= 0) ? null : _onSliderChanged,
            onChangeEnd: (_saving || durationMs <= 0)
                ? null
                : _onSliderChangeEnd,
          ),
          Text(
            positionText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: _saving
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        GlassDialogAction(
          label: slang.t.common.ok,
          emphasized: true,
          loading: _saving,
          onPressed: (_frameBytes == null || _saving) ? null : _onConfirm,
        ),
      ],
    );
  }
}
