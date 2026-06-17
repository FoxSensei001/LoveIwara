import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'key_chord.dart';
import 'shortcut_scope.dart';

/// 快捷键动作的分类（用于设置页在作用域内再次分组展示）。
enum ShortcutActionCategory {
  navigation,
  zoom,
  playback,
  seek,
  volume,
  display,
}

/// 全应用「可绑定按键」的动作（横跨全局 / 图库 / 视频等作用域）。
///
/// 枚举值顺序不参与持久化，持久化只依赖 [ShortcutActionMeta.id]（稳定字符串）。
///
/// **id 兼容性**：视频动作 id 与历史版本保持完全一致（`play_pause` 等，不加前缀），
/// 因此老用户保存在 [ConfigKey.PLAYER_KEYBINDINGS] 里的覆盖键位无需迁移即可继续生效；
/// 新作用域的动作统一加作用域前缀（`gallery_` / `global_`）保证全局唯一、不冲突。
enum ShortcutAction {
  // ---- 全局 ----
  globalBack,
  // ---- 图库 ----
  galleryNext,
  galleryPrevious,
  galleryZoomIn,
  galleryZoomOut,
  galleryResetZoom,
  // ---- 视频 ----
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

/// 动作的静态元信息：稳定 id、作用域、分类、图标、默认键位、是否只读固定。
class ShortcutActionMeta {
  final String id;
  final ShortcutScope scope;
  final ShortcutActionCategory category;
  final IconData icon;
  final List<KeyChord> defaultChords;

  /// 只读固定项：在设置页展示但不可编辑（如 Ctrl+滚轮缩放，本身不是按键组合）。
  /// 当前所有可绑定动作均为 false；固定项以独立的「固定区」渲染，不进入此表。
  final bool fixed;

  const ShortcutActionMeta({
    required this.id,
    required this.scope,
    required this.category,
    required this.icon,
    required this.defaultChords,
    this.fixed = false,
  });
}

extension ShortcutActionMetaExt on ShortcutAction {
  ShortcutActionMeta get meta => _metaTable[this]!;

  String get id => meta.id;

  ShortcutScope get scope => meta.scope;

  ShortcutActionCategory get category => meta.category;

  IconData get icon => meta.icon;

  List<KeyChord> get defaultChords => meta.defaultChords;

  bool get fixed => meta.fixed;

  static ShortcutAction? fromId(String id) {
    for (final action in ShortcutAction.values) {
      if (action.id == id) return action;
    }
    return null;
  }

  /// 某作用域下的全部动作（保持枚举声明顺序）。
  static List<ShortcutAction> inScope(ShortcutScope scope) =>
      ShortcutAction.values.where((a) => a.scope == scope).toList();
}

/// 默认键位表。用 [LogicalKeyboardKey] 常量声明，避免硬编码 keyId 出错。
final Map<ShortcutAction, ShortcutActionMeta> _metaTable = {
  // ---------------------------------------------------------------------------
  // 全局
  // ---------------------------------------------------------------------------
  ShortcutAction.globalBack: ShortcutActionMeta(
    id: 'global_back',
    scope: ShortcutScope.global,
    category: ShortcutActionCategory.navigation,
    icon: Icons.arrow_back,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.escape)],
  ),

  // ---------------------------------------------------------------------------
  // 图库（默认键位与历史写死行为完全一致）
  // ---------------------------------------------------------------------------
  ShortcutAction.galleryNext: ShortcutActionMeta(
    id: 'gallery_next',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.navigation,
    icon: Icons.navigate_next,
    defaultChords: [
      KeyChord.fromKey(LogicalKeyboardKey.arrowRight),
      KeyChord.fromKey(LogicalKeyboardKey.pageDown),
    ],
  ),
  ShortcutAction.galleryPrevious: ShortcutActionMeta(
    id: 'gallery_previous',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.navigation,
    icon: Icons.navigate_before,
    defaultChords: [
      KeyChord.fromKey(LogicalKeyboardKey.arrowLeft),
      KeyChord.fromKey(LogicalKeyboardKey.pageUp),
    ],
  ),
  ShortcutAction.galleryZoomIn: ShortcutActionMeta(
    id: 'gallery_zoom_in',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.zoom,
    icon: Icons.zoom_in,
    defaultChords: [
      KeyChord.fromKey(LogicalKeyboardKey.arrowUp),
      KeyChord.fromKey(LogicalKeyboardKey.equal),
      KeyChord.fromKey(LogicalKeyboardKey.numpadAdd),
    ],
  ),
  ShortcutAction.galleryZoomOut: ShortcutActionMeta(
    id: 'gallery_zoom_out',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.zoom,
    icon: Icons.zoom_out,
    defaultChords: [
      KeyChord.fromKey(LogicalKeyboardKey.arrowDown),
      KeyChord.fromKey(LogicalKeyboardKey.minus),
      KeyChord.fromKey(LogicalKeyboardKey.numpadSubtract),
    ],
  ),
  ShortcutAction.galleryResetZoom: ShortcutActionMeta(
    id: 'gallery_reset_zoom',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.zoom,
    icon: Icons.center_focus_strong,
    defaultChords: [
      KeyChord.fromKey(LogicalKeyboardKey.digit0),
      KeyChord.fromKey(LogicalKeyboardKey.numpad0),
    ],
  ),

  // ---------------------------------------------------------------------------
  // 视频（id 与历史版本一致，确保旧配置零迁移）
  // ---------------------------------------------------------------------------
  ShortcutAction.playPause: ShortcutActionMeta(
    id: 'play_pause',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.playback,
    icon: Icons.play_arrow,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.space)],
  ),
  ShortcutAction.speedUp: ShortcutActionMeta(
    id: 'speed_up',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.playback,
    icon: Icons.speed,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.bracketRight)],
  ),
  ShortcutAction.speedDown: ShortcutActionMeta(
    id: 'speed_down',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.playback,
    icon: Icons.slow_motion_video,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.bracketLeft)],
  ),
  ShortcutAction.seekForward: ShortcutActionMeta(
    id: 'seek_forward',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.seek,
    icon: Icons.fast_forward,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowRight)],
  ),
  ShortcutAction.seekBackward: ShortcutActionMeta(
    id: 'seek_backward',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.seek,
    icon: Icons.fast_rewind,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowLeft)],
  ),
  ShortcutAction.volumeUp: ShortcutActionMeta(
    id: 'volume_up',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.volume,
    icon: Icons.volume_up,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowUp)],
  ),
  ShortcutAction.volumeDown: ShortcutActionMeta(
    id: 'volume_down',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.volume,
    icon: Icons.volume_down,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowDown)],
  ),
  ShortcutAction.toggleMute: ShortcutActionMeta(
    id: 'toggle_mute',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.volume,
    icon: Icons.volume_off,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyM)],
  ),
  ShortcutAction.toggleFullscreen: ShortcutActionMeta(
    id: 'toggle_fullscreen',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.display,
    icon: Icons.fullscreen,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyF)],
  ),
};
