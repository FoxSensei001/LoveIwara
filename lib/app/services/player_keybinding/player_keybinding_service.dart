import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'key_chord.dart';
import 'player_action.dart';

/// 播放器快捷键服务。
///
/// 负责：
/// - 合并「内置默认键位」与「用户覆盖键位」得到最终生效的 keymap；
/// - 对外提供 [resolve]（按键事件 → 动作）供播放器调度；
/// - 提供编辑 API（设置 / 重置 / 全部恢复默认）并持久化到 [ConfigService]；
/// - 冲突检测，避免同一组合绑定到多个动作。
///
/// 持久化只保存「用户改动过的动作」的差量（actionId → 序列化键位列表），
/// 这样未来新增动作时，老用户会自动继承新动作的默认键位。
class PlayerKeybindingService extends GetxService {
  final ConfigService _configService = Get.find<ConfigService>();

  /// 当前生效的键位表（默认表叠加用户覆盖），响应式以便设置页/播放器即时刷新。
  final RxMap<PlayerAction, List<KeyChord>> bindings =
      <PlayerAction, List<KeyChord>>{}.obs;

  /// 不允许被绑定的保留键（由系统/全局处理，如 Esc 交给 PopCoordinator）。
  static final Set<int> _reservedKeyIds = {LogicalKeyboardKey.escape.keyId};

  @override
  void onInit() {
    super.onInit();
    _rebuild();
  }

  // ---------------------------------------------------------------------------
  // 读取 / 解析
  // ---------------------------------------------------------------------------

  List<KeyChord> chordsOf(PlayerAction action) =>
      List.unmodifiable(bindings[action] ?? const []);

  /// 解析一次按下事件，命中则返回对应动作，否则返回 null。
  PlayerAction? resolve(KeyEvent event) {
    if (event is! KeyDownEvent) return null;
    for (final entry in bindings.entries) {
      for (final chord in entry.value) {
        if (chord.matches(event)) return entry.key;
      }
    }
    return null;
  }

  /// 该组合当前已绑定到哪些动作（可排除某个动作，用于编辑时忽略自身）。
  List<PlayerAction> conflictsFor(KeyChord chord, {PlayerAction? except}) {
    final result = <PlayerAction>[];
    for (final entry in bindings.entries) {
      if (entry.key == except) continue;
      if (entry.value.contains(chord)) result.add(entry.key);
    }
    return result;
  }

  bool isReserved(KeyChord chord) => _reservedKeyIds.contains(chord.keyId);

  bool isDefault(PlayerAction action) {
    final current = bindings[action] ?? const [];
    final def = action.defaultChords;
    if (current.length != def.length) return false;
    for (var i = 0; i < def.length; i++) {
      if (current[i] != def[i]) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // 编辑 API
  // ---------------------------------------------------------------------------

  /// 覆盖某动作的全部键位。传入空列表表示「该动作无快捷键」。
  Future<void> setBindings(PlayerAction action, List<KeyChord> chords) async {
    // 去重并过滤保留键。
    final cleaned = <KeyChord>[];
    for (final chord in chords) {
      if (isReserved(chord)) continue;
      if (!cleaned.contains(chord)) cleaned.add(chord);
    }
    bindings[action] = cleaned;
    await _persist();
  }

  /// 为某动作追加一个组合；若该组合已被其它动作占用，先从其它动作移除（独占）。
  Future<void> addBinding(PlayerAction action, KeyChord chord) async {
    if (isReserved(chord)) return;
    // 解除其它动作对该组合的占用。
    for (final other in PlayerAction.values) {
      if (other == action) continue;
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

  Future<void> removeBinding(PlayerAction action, KeyChord chord) async {
    final current = bindings[action];
    if (current == null) return;
    bindings[action] = current.where((c) => c != chord).toList();
    await _persist();
  }

  /// 将某动作恢复为默认键位。
  Future<void> resetAction(PlayerAction action) async {
    bindings[action] = List<KeyChord>.from(action.defaultChords);
    await _persist();
  }

  /// 全部恢复默认。
  Future<void> resetAll() async {
    for (final action in PlayerAction.values) {
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
    final next = <PlayerAction, List<KeyChord>>{};
    for (final action in PlayerAction.values) {
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
    for (final action in PlayerAction.values) {
      if (isDefault(action)) continue;
      overrides[action.id] = (bindings[action] ?? const [])
          .map((c) => c.serialize())
          .toList();
    }
    await _configService.setSetting(ConfigKey.PLAYER_KEYBINDINGS, overrides);
    LogUtils.d('已保存播放器快捷键覆盖: ${overrides.keys.toList()}', 'PlayerKeybinding');
  }
}
