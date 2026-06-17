import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'key_chord.dart';
import 'shortcut_action.dart';
import 'shortcut_scope.dart';

/// 全应用统一快捷键服务。
///
/// 负责：
/// - 合并「内置默认键位」与「用户覆盖键位」得到最终生效的 keymap（涵盖全部作用域）；
/// - 对外提供 [resolve] / [resolvePointer]（按键/鼠标事件 + 作用域 → 动作）供各界面调度；
/// - 提供编辑 API（设置 / 重置 / 按作用域恢复 / 全部恢复默认）并持久化到 [ConfigService]；
/// - 作用域感知的冲突检测：同一组合在不同作用域下互不冲突，仅同作用域内独占。
///
/// 持久化只保存「用户改动过的动作」的差量（actionId → 序列化键位列表），
/// 复用历史配置键 [ConfigKey.PLAYER_KEYBINDINGS]：视频动作 id 与历史一致，
/// 故老用户配置零迁移即可加载；图库/全局等新动作无覆盖时取默认。
class KeybindingService extends GetxService {
  final ConfigService _configService = Get.find<ConfigService>();

  /// 当前生效的键位表（默认表叠加用户覆盖），响应式以便设置页/各界面即时刷新。
  final RxMap<ShortcutAction, List<KeyChord>> bindings =
      <ShortcutAction, List<KeyChord>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _rebuild();
  }

  // ---------------------------------------------------------------------------
  // 读取 / 解析
  // ---------------------------------------------------------------------------

  List<KeyChord> chordsOf(ShortcutAction action) =>
      List.unmodifiable(bindings[action] ?? const []);

  /// 解析一次键盘按下事件，仅匹配 [scope] 内的动作；未命中返回 null。
  ///
  /// 不在此做「回退全局」：叶子界面（视频/图库）用 [KeyboardListener] / [Focus] 监听，
  /// 未命中的按键会自然冒泡到应用根部的全局处理器（见 my_app.dart）。叶子层若也回退
  /// 匹配全局，会与根部重复触发（如 Esc 被双重处理）。
  ShortcutAction? resolve(KeyEvent event, ShortcutScope scope) {
    if (event is! KeyDownEvent) return null;
    return _matchKey(event, scope);
  }

  /// 解析一次鼠标按下事件，仅匹配 [scope] 内的动作；未命中返回 null。
  ShortcutAction? resolvePointer(PointerDownEvent event, ShortcutScope scope) {
    return _matchPointer(event, scope);
  }

  ShortcutAction? _matchKey(KeyEvent event, ShortcutScope scope) {
    for (final entry in bindings.entries) {
      if (entry.key.scope != scope) continue;
      for (final chord in entry.value) {
        if (chord.matches(event)) return entry.key;
      }
    }
    return null;
  }

  ShortcutAction? _matchPointer(PointerDownEvent event, ShortcutScope scope) {
    for (final entry in bindings.entries) {
      if (entry.key.scope != scope) continue;
      for (final chord in entry.value) {
        if (chord.matchesPointer(event)) return entry.key;
      }
    }
    return null;
  }

  /// 该组合在指定作用域内已绑定到哪些动作（可排除自身，用于编辑时忽略当前动作）。
  ///
  /// 仅检测「同作用域」冲突——同一组合在不同作用域下视为合法（如 → 既是视频快进
  /// 又是图库下一张）。
  List<ShortcutAction> conflictsFor(
    KeyChord chord, {
    required ShortcutScope scope,
    ShortcutAction? except,
  }) {
    final result = <ShortcutAction>[];
    for (final entry in bindings.entries) {
      if (entry.key.scope != scope) continue;
      if (entry.key == except) continue;
      if (entry.value.contains(chord)) result.add(entry.key);
    }
    return result;
  }

  /// 若在叶子作用域绑定某组合会「遮蔽」一个常驻全局绑定，返回被遮蔽的全局动作；
  /// 否则返回 null。用于软提示（可继续），不阻断绑定。
  ShortcutAction? shadowsGlobal(
    KeyChord chord, {
    required ShortcutScope scope,
  }) {
    if (scope == ShortcutScope.global) return null;
    for (final entry in bindings.entries) {
      if (entry.key.scope != ShortcutScope.global) continue;
      if (entry.value.contains(chord)) return entry.key;
    }
    return null;
  }

  /// 在全局作用域绑定某组合时，找出会在叶子作用域（gallery / video）遮蔽它的动作。
  /// 这些叶子动作已绑定同一组合，故进入其界面后该全局绑定不会触发（叶子层优先匹配）。
  /// 用于软提示（可继续），不阻断绑定。是 [shadowsGlobal] 的反向检测。
  List<ShortcutAction> shadowedByLeaf(KeyChord chord) {
    final result = <ShortcutAction>[];
    for (final entry in bindings.entries) {
      if (entry.key.scope == ShortcutScope.global) continue;
      if (entry.value.contains(chord)) result.add(entry.key);
    }
    return result;
  }

  /// 该组合在指定作用域是否为保留键（不允许绑定）。
  /// - global：无保留键（Esc 即全局返回默认键，可改）；
  /// - gallery / video：Esc 保留，使其冒泡到全局返回。
  bool isReserved(KeyChord chord, ShortcutScope scope) {
    if (chord.isPointer) return false;
    return _reservedKeyIdsFor(scope).contains(chord.keyId);
  }

  Set<int> _reservedKeyIdsFor(ShortcutScope scope) {
    switch (scope) {
      case ShortcutScope.global:
        return const {};
      case ShortcutScope.gallery:
      case ShortcutScope.video:
        return {LogicalKeyboardKey.escape.keyId};
    }
  }

  bool isDefault(ShortcutAction action) {
    final current = bindings[action] ?? const [];
    final def = action.defaultChords;
    if (current.length != def.length) return false;
    for (var i = 0; i < def.length; i++) {
      if (current[i] != def[i]) return false;
    }
    return true;
  }

  /// 某作用域是否全部为默认键位（用于「按作用域重置」按钮显隐）。
  bool isScopeDefault(ShortcutScope scope) {
    for (final action in ShortcutAction.values) {
      if (action.scope != scope) continue;
      if (!isDefault(action)) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // 编辑 API
  // ---------------------------------------------------------------------------

  /// 覆盖某动作的全部键位。传入空列表表示「该动作无快捷键」。
  Future<void> setBindings(ShortcutAction action, List<KeyChord> chords) async {
    final cleaned = <KeyChord>[];
    for (final chord in chords) {
      if (isReserved(chord, action.scope)) continue;
      if (!cleaned.contains(chord)) cleaned.add(chord);
    }
    bindings[action] = cleaned;
    await _persist();
  }

  /// 为某动作追加一个组合；若该组合已被「同作用域」的其它动作占用，先从其移除（独占）。
  Future<void> addBinding(ShortcutAction action, KeyChord chord) async {
    if (isReserved(chord, action.scope)) return;
    // 仅解除「同作用域」其它动作对该组合的占用（跨作用域允许共享）。
    for (final other in ShortcutAction.values) {
      if (other == action) continue;
      if (other.scope != action.scope) continue;
      final list = bindings[other];
      if (list != null && list.contains(chord)) {
        bindings[other] = list.where((c) => c != chord).toList();
      }
    }
    final current = List<KeyChord>.from(bindings[action] ?? const []);
    if (!current.contains(chord)) current.add(chord);
    bindings[action] = current;
    await _persist();
  }

  Future<void> removeBinding(ShortcutAction action, KeyChord chord) async {
    final current = bindings[action];
    if (current == null) return;
    bindings[action] = current.where((c) => c != chord).toList();
    await _persist();
  }

  /// 将某动作恢复为默认键位。
  Future<void> resetAction(ShortcutAction action) async {
    bindings[action] = List<KeyChord>.from(action.defaultChords);
    await _persist();
  }

  /// 将某作用域下的全部动作恢复为默认键位。
  Future<void> resetScope(ShortcutScope scope) async {
    for (final action in ShortcutAction.values) {
      if (action.scope != scope) continue;
      bindings[action] = List<KeyChord>.from(action.defaultChords);
    }
    await _persist();
  }

  /// 全部恢复默认。
  Future<void> resetAll() async {
    for (final action in ShortcutAction.values) {
      bindings[action] = List<KeyChord>.from(action.defaultChords);
    }
    await _configService.setSetting(
      ConfigKey.PLAYER_KEYBINDINGS,
      <String, dynamic>{},
    );
  }

  // ---------------------------------------------------------------------------
  // 内部：加载 / 保存
  // ---------------------------------------------------------------------------

  void _rebuild() {
    final overrides = _readOverrides();
    final next = <ShortcutAction, List<KeyChord>>{};
    for (final action in ShortcutAction.values) {
      final override = overrides[action.id];
      if (override != null) {
        next[action] = override;
      } else {
        next[action] = List<KeyChord>.from(action.defaultChords);
      }
    }
    bindings.assignAll(next);
  }

  Map<String, List<KeyChord>> _readOverrides() {
    final raw = _configService[ConfigKey.PLAYER_KEYBINDINGS];
    if (raw is! Map) return {};
    final result = <String, List<KeyChord>>{};
    raw.forEach((key, value) {
      if (key is! String || value is! List) return;
      final chords = <KeyChord>[];
      for (final item in value) {
        if (item is! String) continue;
        final chord = KeyChord.tryDeserialize(item);
        if (chord != null) chords.add(chord);
      }
      result[key] = chords;
    });
    return result;
  }

  Future<void> _persist() async {
    // 只保存与默认不同的动作，保持配置精简、利于未来默认演进。
    final overrides = <String, dynamic>{};
    for (final action in ShortcutAction.values) {
      if (isDefault(action)) continue;
      overrides[action.id] = (bindings[action] ?? const [])
          .map((c) => c.serialize())
          .toList();
    }
    await _configService.setSetting(ConfigKey.PLAYER_KEYBINDINGS, overrides);
    LogUtils.d('已保存快捷键覆盖: ${overrides.keys.toList()}', 'Keybinding');
  }
}
