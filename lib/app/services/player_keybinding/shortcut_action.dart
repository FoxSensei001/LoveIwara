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
  // 图库里混着的视频条目：翻到它那一页时才可用。
  //
  // ⛔ 这几条**必须**是 gallery 域自己的动作，不能指望复用 video 域那套
  // （`play_pause` / `seek_*` / `toggle_mute`）：[KeybindingService.resolve]
  // 按 scope 精确匹配、明确不做跨域回退，而图库查看器注册的是
  // [ShortcutScope.gallery]，于是 video 域的键位在图库里一条也收不到。
  //
  // 默认键位刻意**避开方向键**：图库里 ←/→ 恒是翻页、↑/↓ 恒是缩放，翻到视频
  // 那一页时不改变含义。用户不该需要记住「我现在在哪个模式」。
  galleryPlayPause,
  gallerySeekBackward,
  gallerySeekForward,
  galleryToggleMute,
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

/// 初始播放封面阶段（关闭「首次进入自动播放」时停在封面、媒体尚未打开）仍然放行的动作。
///
/// 判定只问一件事：这个动作是否依赖「已打开的媒体」。
/// - [ShortcutAction.playPause] 是唤起首次播放的入口，必须放行；
/// - [ShortcutAction.toggleFullscreen] 只切换呈现方式（inline / fullscreen），
///   与媒体是否打开无关，因此也放行——它不是播放意图，不应顺带开始播放。
///
/// 其余动作（进度、音量、倍速等）都要读写播放器状态，媒体没打开时放行只会
/// 隐式加载媒体或空转，故一律拦下，等播放器就绪后再生效。
///
/// 键盘与鼠标两条入口共用这一份名单，避免各自维护而再次出现
/// 「键盘能用、鼠标被吞」这类只在一边复现的缺陷。
const Set<ShortcutAction> kShortcutActionsAllowedOnInitialPlaybackCover = {
  ShortcutAction.playPause,
  ShortcutAction.toggleFullscreen,
};

/// 该动作是否允许在初始播放封面阶段执行。
/// 名单见 [kShortcutActionsAllowedOnInitialPlaybackCover]。
bool isShortcutAllowedOnInitialPlaybackCover(ShortcutAction action) =>
    kShortcutActionsAllowedOnInitialPlaybackCover.contains(action);

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

  /// 按住不放时是否应当**连续触发**。
  ///
  /// 默认 false，因为大多数动作重复触发是错的而不只是多余：播放/暂停、静音、
  /// 全屏这类开关会在按住期间疯狂来回翻；倍速、重置缩放是离散档位，按一次就该
  /// 走一档；进度键另有自己的长按倍速定时器（见 `_beginSeekHold`），再让它吃
  /// 系统重复事件就会两套逻辑打架。
  ///
  /// 只有「同一动作重复施加会线性累积、且用户本来就期待按住能一路调过去」的
  /// 才置 true：音量与图库缩放。
  final bool repeatable;

  const ShortcutActionMeta({
    required this.id,
    required this.scope,
    required this.category,
    required this.icon,
    required this.defaultChords,
    this.fixed = false,
    this.repeatable = false,
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

  /// 按住不放时是否连续触发，见 [ShortcutActionMeta.repeatable]。
  bool get repeatable => meta.repeatable;

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
    repeatable: true,
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
    repeatable: true,
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
  ShortcutAction.galleryPlayPause: ShortcutActionMeta(
    id: 'gallery_play_pause',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.playback,
    icon: Icons.play_arrow,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.space)],
  ),
  // J / L 是播放器里通用的「后退 / 前进」（YouTube、mpv、Plex 都是这一对），
  // 而且与图库既有的方向键、0、= / - 全不冲突。
  ShortcutAction.gallerySeekBackward: ShortcutActionMeta(
    id: 'gallery_seek_backward',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.seek,
    icon: Icons.fast_rewind,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyJ)],
    // ⛔ 不 repeatable。位移确实是累加的，但每一次重复都是一次**真的 seek**，
    // 而图库里这条视频是网络流——按住不放会连着发几十次跳转，每次都要重新起
    // 缓冲，读起来是卡死而不是"一路拉过去"。视频域那两条同样是 false。
    repeatable: false,
  ),
  ShortcutAction.gallerySeekForward: ShortcutActionMeta(
    id: 'gallery_seek_forward',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.seek,
    icon: Icons.fast_forward,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyL)],
    repeatable: false,
  ),
  ShortcutAction.galleryToggleMute: ShortcutActionMeta(
    id: 'gallery_toggle_mute',
    scope: ShortcutScope.gallery,
    category: ShortcutActionCategory.volume,
    icon: Icons.volume_off,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.keyM)],
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
    repeatable: true,
  ),
  ShortcutAction.volumeDown: ShortcutActionMeta(
    id: 'volume_down',
    scope: ShortcutScope.video,
    category: ShortcutActionCategory.volume,
    icon: Icons.volume_down,
    defaultChords: [KeyChord.fromKey(LogicalKeyboardKey.arrowDown)],
    repeatable: true,
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
