import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'key_chord.dart';

/// 快捷键动作的分类（用于设置页分组展示）。
enum PlayerActionCategory { playback, seek, volume, display }

/// 播放器中所有「可绑定按键」的动作。
///
/// 枚举值的顺序不参与持久化，持久化只依赖 [PlayerActionMeta.id]（稳定字符串），
/// 因此后续新增/调整顺序不会破坏用户已保存的键位。
enum PlayerAction {
  playPause,
  speedUp,
  speedDown,
  seekForward,
  seekBackward,
  volumeUp,
  volumeDown,
  toggleMute,
  toggleFullscreen,
}

/// 动作的静态元信息：稳定 id、分类、图标与「默认键位」。
class PlayerActionMeta {
  final String id;
  final PlayerActionCategory category;
  final IconData icon;
  final List<KeyChord> defaultChords;

  const PlayerActionMeta({
    required this.id,
    required this.category,
    required this.icon,
    required this.defaultChords,
  });
}

extension PlayerActionMetaExt on PlayerAction {
  PlayerActionMeta get meta => _metaTable[this]!;

  String get id => meta.id;

  PlayerActionCategory get category => meta.category;

  IconData get icon => meta.icon;

  List<KeyChord> get defaultChords => meta.defaultChords;

  static PlayerAction? fromId(String id) {
    for (final action in PlayerAction.values) {
      if (action.id == id) return action;
    }
    return null;
  }
}

/// 默认键位表。用 [LogicalKeyboardKey] 常量声明，避免硬编码 keyId 出错。
final Map<PlayerAction, PlayerActionMeta> _metaTable = {
  PlayerAction.playPause: PlayerActionMeta(
    id: 'play_pause',
    category: PlayerActionCategory.playback,
    icon: Icons.play_arrow,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.space)],
  ),
  PlayerAction.speedUp: PlayerActionMeta(
    id: 'speed_up',
    category: PlayerActionCategory.playback,
    icon: Icons.speed,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.bracketRight)],
  ),
  PlayerAction.speedDown: PlayerActionMeta(
    id: 'speed_down',
    category: PlayerActionCategory.playback,
    icon: Icons.slow_motion_video,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.bracketLeft)],
  ),
  PlayerAction.seekForward: PlayerActionMeta(
    id: 'seek_forward',
    category: PlayerActionCategory.seek,
    icon: Icons.fast_forward,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowRight)],
  ),
  PlayerAction.seekBackward: PlayerActionMeta(
    id: 'seek_backward',
    category: PlayerActionCategory.seek,
    icon: Icons.fast_rewind,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowLeft)],
  ),
  PlayerAction.volumeUp: PlayerActionMeta(
    id: 'volume_up',
    category: PlayerActionCategory.volume,
    icon: Icons.volume_up,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowUp)],
  ),
  PlayerAction.volumeDown: PlayerActionMeta(
    id: 'volume_down',
    category: PlayerActionCategory.volume,
    icon: Icons.volume_down,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowDown)],
  ),
  PlayerAction.toggleMute: PlayerActionMeta(
    id: 'toggle_mute',
    category: PlayerActionCategory.volume,
    icon: Icons.volume_off,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyM)],
  ),
  PlayerAction.toggleFullscreen: PlayerActionMeta(
    id: 'toggle_fullscreen',
    category: PlayerActionCategory.display,
    icon: Icons.fullscreen,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyF)],
  ),
};
