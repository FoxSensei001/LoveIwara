import 'package:flutter/foundation.dart';
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
/// 快捷键服务所需的**全部**持久化能力。
///
/// 抽这一层只为一件事：让键位规则（保留键、默认判定、重复策略）能被直接单测。
/// 在此之前 [KeybindingService] 在字段初始化时就 `Get.find<ConfigService>()`，
/// 而 ConfigService 又要一个真实的 sqlite 库，于是这些纯规则一条都测不到——
/// 只能靠扫源码间接约束。
abstract class KeybindingStore {
  /// 读取已保存的覆盖差量；没有或类型不对时返回 null。
  Object? readOverrides();

  Future<void> writeOverrides(Map<String, dynamic> overrides);
}

/// 生产实现：落在 [ConfigKey.PLAYER_KEYBINDINGS] 上。
class ConfigKeybindingStore implements KeybindingStore {
  final ConfigService _configService;

  ConfigKeybindingStore(this._configService);

  @override
  Object? readOverrides() => _configService[ConfigKey.PLAYER_KEYBINDINGS];

  @override
  Future<void> writeOverrides(Map<String, dynamic> overrides) =>
      _configService.setSetting(ConfigKey.PLAYER_KEYBINDINGS, overrides);
}

/// 纯内存实现，仅供测试。
@visibleForTesting
class InMemoryKeybindingStore implements KeybindingStore {
  Object? raw;

  InMemoryKeybindingStore([this.raw]);

  @override
  Object? readOverrides() => raw;

  @override
  Future<void> writeOverrides(Map<String, dynamic> overrides) async {
    raw = overrides;
  }
}

class KeybindingService extends GetxService {
  final KeybindingStore _store;

  /// 生产构造：默认落到 [ConfigService]。测试可传入 [InMemoryKeybindingStore]。
  KeybindingService({KeybindingStore? store})
    : _store = store ?? ConfigKeybindingStore(Get.find<ConfigService>());

  /// 仅供测试：不经 GetX 生命周期直接建好并加载一次。
  @visibleForTesting
  factory KeybindingService.forTest({KeybindingStore? store}) {
    final service = KeybindingService(
      store: store ?? InMemoryKeybindingStore(),
    );
    service._rebuild();
    return service;
  }

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
    if (event is KeyDownEvent) return _matchKey(event, scope);
    // 按住不放时系统会持续发 KeyRepeatEvent。以前这里一律丢弃，于是「按住调音量」
    // 只调一格就不动了——用户按住的手感全应用都对不上。现在放行，但**只放行
    // 声明了可重复的动作**（见 [ShortcutActionMeta.repeatable]），否则按住空格
    // 就成了每秒几十次播放/暂停。
    if (event is KeyRepeatEvent) {
      final action = _matchKey(event, scope);
      return (action != null && action.repeatable) ? action : null;
    }
    return null;
  }

  /// 该事件命中了本作用域的哪个绑定——**不管**事件类型、也不管动作是否可重复。
  ///
  /// 给调度层判断「这次事件即使不执行动作，也必须消费掉」用。典型场景：方向键
  /// 绑成了音量/进度，按住不放产生的重复事件若原样放过去，会一路冒泡到
  /// `WidgetsApp` 的默认快捷键被翻译成 `DirectionalFocusIntent`，把焦点挪走——
  /// 表现为「按住方向键，播放器忽然不响应了」。
  ShortcutAction? matchIgnoringRepeatPolicy(KeyEvent event, ShortcutScope scope) =>
      _matchKey(event, scope);

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

  /// 该组合在指定作用域是否**不可绑定**。
  /// - 鼠标组合：该作用域不受理鼠标按键时不可绑定（见 [kScopeInputChannels]）——
  ///   否则会绑上却永远不触发；
  /// - global：无保留键（全局返回自己的键当然可以改）；
  /// - gallery / video：**当前绑定给 [ShortcutAction.globalBack] 的那些键**保留，
  ///   使其能落到全局返回上。
  ///
  /// 注意最后一条不是「Esc 保留」。以前这里写死 Esc，于是用户把「返回」改绑到
  /// 别的键之后，两头都不对：新键在叶子作用域里没被保护（绑走了就再也退不出
  /// 全屏），而 Esc 明明已经不是返回键却仍然不让绑。保留哪个键必须跟着返回键
  /// 的**真实绑定**走。
  bool isReserved(KeyChord chord, ShortcutScope scope) {
    if (isUnbindable(chord, scope)) return true;
    if (chord.isPointer) return false;
    return _globalBackKeyIdsFor(scope).contains(chord.keyId);
  }

  /// 该组合是否**永远**不可绑定——与 [isReserved] 的区别是这一类与用户配置无关：
  /// 无论键位表怎么改都不会变，因此加载与编辑两条入口都要无条件清洗掉。
  ///
  /// 把这两件事分开是有原因的：「保留给全局返回」取决于返回键当前绑到了哪儿，
  /// 是会随配置变化的**策略**；而「作用域不收鼠标」「平台自己就把这个键当返回」
  /// 是**事实**。只有后者适合在加载时静默剔除。
  bool isUnbindable(KeyChord chord, ShortcutScope scope) {
    if (chord.isPointer) {
      // 作用域根本不受理鼠标 → 绑了也永不触发。
      if (!scopeAcceptsMouseButtons(scope)) return true;
      // 该按钮在本平台不可绑（安卓的鼠标后退键已被系统当返回用）→
      // 连同**历史遗留**的绑定一起挡掉，否则老配置会活过升级继续双触发。
      return !KeyChord.isBindableMouseButton(chord.pointerButton!);
    }
    // 平台自带返回语义的按键在**所有**作用域不可绑：系统那条返回通道照样会跑，
    // 绑上去只会一次按下返回两次（真机用罗技侧键复现过）。桌面端无此问题，
    // 故仅在移动端拦。
    return KeyChord.isPlatformHandledBackButton &&
        KeyChord.platformBackKeyIds.contains(chord.keyId);
  }

  /// 叶子作用域里要让给「全局返回」的键；global 作用域自身不设保留。
  Set<int> _globalBackKeyIdsFor(ShortcutScope scope) {
    if (scope == ShortcutScope.global) return const {};
    return globalBackKeyIds;
  }

  /// 当前绑定给全局返回的键盘键 id 集合。
  ///
  /// 用户把返回键全部删掉时集合为空——那么叶子作用域不再保留任何键，这是用户
  /// 自己放弃了这条退路，不该反过来继续锁着一个已经没用的 Esc。
  Set<int> get globalBackKeyIds =>
      _keyIdsOf(bindings[ShortcutAction.globalBack]);

  static Set<int> _keyIdsOf(List<KeyChord>? chords) => (chords ?? const [])
      .where((c) => !c.isPointer)
      .map((c) => c.keyId)
      .toSet();

  /// 某动作是否仍是默认键位。
  ///
  /// **与顺序无关**：键位列表的顺序只影响设置页里若干个 chip 的排布，不影响任何
  /// 行为。以前这里逐位比较，于是「删掉一个默认键再加回来」会因为 [addBinding]
  /// 一律追加到末尾而变成非默认——设置页凭空多出一个「恢复默认」按钮，更糟的是
  /// [_persist] 会把它当成用户覆盖存进配置，从此这个动作再也吃不到未来默认键位的
  /// 演进。
  bool isDefault(ShortcutAction action) {
    final current = bindings[action] ?? const [];
    final def = action.defaultChords;
    if (current.length != def.length) return false;
    return current.toSet().containsAll(def) && def.toSet().containsAll(current);
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
    bindings[action] = _sanitize(
      chords,
      action.scope,
      backKeyIds: action == ShortcutAction.globalBack
          // 正在改的就是返回键本身：拿新值来判，别拿旧值。
          ? _keyIdsOf(chords.toList())
          : globalBackKeyIds,
    );
    if (action == ShortcutAction.globalBack) _reSanitizeLeafScopes();
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
    if (action == ShortcutAction.globalBack) _reSanitizeLeafScopes();
    await _persist();
  }

  Future<void> removeBinding(ShortcutAction action, KeyChord chord) async {
    final current = bindings[action];
    if (current == null) return;
    bindings[action] = current.where((c) => c != chord).toList();
    // 删掉一个返回键后，它在叶子作用域里就不再是保留键了——但已存的绑定不会
    // 凭空出现，所以这里只需重算一次保证不变式，不会有新的丢弃。
    if (action == ShortcutAction.globalBack) _reSanitizeLeafScopes();
    await _persist();
  }

  /// 将某动作恢复为默认键位。
  Future<void> resetAction(ShortcutAction action) async {
    bindings[action] = List<KeyChord>.from(action.defaultChords);
    if (action == ShortcutAction.globalBack) _reSanitizeLeafScopes();
    await _persist();
  }

  /// 将某作用域下的全部动作恢复为默认键位。
  Future<void> resetScope(ShortcutScope scope) async {
    for (final action in ShortcutAction.values) {
      if (action.scope != scope) continue;
      bindings[action] = List<KeyChord>.from(action.defaultChords);
    }
    if (scope == ShortcutScope.global) _reSanitizeLeafScopes();
    await _persist();
  }

  /// 返回键变动后，重算叶子作用域的保留键不变式。
  ///
  /// 「叶子作用域不得占用返回键」这条规则依赖返回键的当前绑定，因此返回键一改，
  /// 已存的叶子绑定就可能违反它。必须**当场**重算：留到下次启动由 [_rebuild]
  /// 清洗的话，用户会在几天后莫名其妙地发现某个快捷键没了，且无从关联到当初那次
  /// 改动。丢弃的项一律记日志，不做无声删除。
  void _reSanitizeLeafScopes() {
    final backKeyIds = globalBackKeyIds;
    for (final action in ShortcutAction.values) {
      if (action.scope == ShortcutScope.global) continue;
      final current = bindings[action];
      if (current == null || current.isEmpty) continue;
      final cleaned = _sanitize(current, action.scope, backKeyIds: backKeyIds);
      if (cleaned.length == current.length) continue;
      final dropped = current.where((c) => !cleaned.contains(c)).toList();
      LogUtils.w(
        '「${action.id}」的键位 ${dropped.map((c) => c.displayLabel).join('、')} '
        '已让给全局返回键',
        'Keybinding',
      );
      bindings[action] = cleaned;
    }
  }

  /// 全部恢复默认。
  Future<void> resetAll() async {
    for (final action in ShortcutAction.values) {
      bindings[action] = List<KeyChord>.from(action.defaultChords);
    }
    await _store.writeOverrides(<String, dynamic>{});
  }

  // ---------------------------------------------------------------------------
  // 内部：加载 / 保存
  // ---------------------------------------------------------------------------

  void _rebuild() {
    final overrides = _readOverrides();
    final next = <ShortcutAction, List<KeyChord>>{};
    // 先把「全局返回」定下来：叶子作用域的保留键取决于它，而此刻 [bindings]
    // 还是上一轮的值，直接读会用错基准。
    final backOverride = overrides[ShortcutAction.globalBack.id];
    final backChords = _sanitize(
      backOverride ?? ShortcutAction.globalBack.defaultChords,
      ShortcutScope.global,
      backKeyIds: const {},
    );
    next[ShortcutAction.globalBack] = backChords;
    final backKeyIds = _keyIdsOf(backChords);
    for (final action in ShortcutAction.values) {
      if (action == ShortcutAction.globalBack) continue;
      final override = overrides[action.id];
      if (override != null) {
        // 加载入口必须做与编辑入口同样的清洗。历史配置里可能存着当时允许、
        // 如今该作用域已不受理的组合（典型：全局/图库的鼠标键——那批绑定
        // 从来就不会触发），或重复项；不在这里滤掉，它们会一路显示到设置页
        // 上，让用户以为绑定生效了。
        next[action] = _sanitize(
          override,
          action.scope,
          backKeyIds: backKeyIds,
        );
      } else {
        next[action] = List<KeyChord>.from(action.defaultChords);
      }
    }
    bindings.assignAll(next);
  }

  /// 编辑与加载共用的清洗：剔除该作用域不可绑定的组合，并去重（保序）。
  ///
  /// [backKeyIds] 为「此刻全局返回占用的键」。加载时不能直接读 [bindings]
  /// —— 那会儿它还是上一轮的值 —— 所以由 [_rebuild] 先解析出返回键再传进来。
  List<KeyChord> _sanitize(
    Iterable<KeyChord> chords,
    ShortcutScope scope, {
    required Set<int> backKeyIds,
  }) {
    final cleaned = <KeyChord>[];
    for (final chord in chords) {
      if (isUnbindable(chord, scope)) continue;
      if (scope != ShortcutScope.global &&
          !chord.isPointer &&
          backKeyIds.contains(chord.keyId)) {
        continue;
      }
      if (!cleaned.contains(chord)) cleaned.add(chord);
    }
    return cleaned;
  }

  Map<String, List<KeyChord>> _readOverrides() {
    final raw = _store.readOverrides();
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
    await _store.writeOverrides(overrides);
    LogUtils.d('已保存快捷键覆盖: ${overrides.keys.toList()}', 'Keybinding');
  }
}
