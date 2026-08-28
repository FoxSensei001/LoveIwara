import 'package:flutter/widgets.dart';

import 'shortcut_scope.dart';

/// 叶子作用域（视频 / 图库）的「当前活跃目标」注册表。
///
/// ## 为什么需要它
///
/// 原来播放器把按键处理挂在自己那只 [Focus] 上，于是**只有当 Flutter 焦点恰好落在
/// 播放器子树里时快捷键才生效**。而按键事件是从当前焦点节点向上冒泡的：路由自己的
/// `FocusScope` 位于页面内容**之上**，焦点停在它身上（或平板宽屏里任何一个可聚焦
/// 控件上）时，播放器那只 Focus 根本不在冒泡路径上。
///
/// 真机实测（OnePlus Pad + 外接键鼠）：新开一个视频详情页后连续 20 秒注入 5 次按键，
/// 播放器**一条都收不到**；注入 Tab 把焦点移进播放器子树后立刻就收得到，Tab 再把焦点
/// 移出去又收不到了。这正是「自定义键不生效、方向键却有效」的真因——两个键只是在
/// 不同的焦点状态下被试的，与键位本身无关。
///
/// ## 机制
///
/// 改为不依赖焦点：叶子页面把自己注册进来，应用根部那只 [Focus]（`my_app.dart` 的
/// `_shortCutsWrapper`，它是整棵树的祖先，**任何焦点状态下都收得到按键**）先问本表，
/// 由**栈顶那个仍然合格的目标**接管，未接管才落到全局动作。
///
/// 后进先出只是并列时的排序；真正决定谁合格的是各目标自己的 [_Entry.isEligible]，
/// 因为本应用有多层嵌套路由（root / shell / 设置内层 shell），而且视频详情页可以层层
/// 叠加（A 在播 → push B，A 暂停但仍挂载）。
class ShortcutTargetRegistry {
  ShortcutTargetRegistry._();

  static final ShortcutTargetRegistry instance = ShortcutTargetRegistry._();

  final List<_Entry> _stack = <_Entry>[];

  /// 注册一个叶子目标。[owner] 用于反注册，重复注册同一个 owner 会顶掉旧的。
  ///
  /// [isEligible] 每次派发都会被问一次，必须是**实时查询**而不是事件标记：
  /// 本项目已经踩过「RouteObserver 不把 removeRoute / pushReplacement 转成
  /// didPopNext，只认事件标记会永久冻结」这个坑（见 author_profile_page 的注释）。
  void register({
    required Object owner,
    required ShortcutScope scope,
    required KeyEventResult Function(KeyEvent event) handle,
    required bool Function() isEligible,
  }) {
    _stack.removeWhere((e) => identical(e.owner, owner));
    _stack.add(
      _Entry(owner: owner, scope: scope, handle: handle, isEligible: isEligible),
    );
  }

  void unregister(Object owner) {
    _stack.removeWhere((e) => identical(e.owner, owner));
  }

  /// 当前会接管按键的作用域（没有则为 null）。仅供诊断与测试。
  ShortcutScope? get activeScope {
    for (var i = _stack.length - 1; i >= 0; i--) {
      if (_stack[i].isEligible()) return _stack[i].scope;
    }
    return null;
  }

  int get length => _stack.length;

  /// 把按键交给栈顶第一个合格的目标；无人接管返回 [KeyEventResult.ignored]。
  ///
  /// 传的是**原始事件**而不是解析后的动作：播放器的进度键长按倍速需要 KeyUpEvent
  /// 才能收尾，只转发 KeyDownEvent 会让它卡在倍速态。
  KeyEventResult dispatch(KeyEvent event) {
    for (var i = _stack.length - 1; i >= 0; i--) {
      final entry = _stack[i];
      if (!entry.isEligible()) continue;
      final result = entry.handle(event);
      if (result == KeyEventResult.handled) return result;
    }
    return KeyEventResult.ignored;
  }

  /// 仅供测试：清空注册表。
  @visibleForTesting
  void clearForTest() => _stack.clear();
}

class _Entry {
  final Object owner;
  final ShortcutScope scope;
  final KeyEventResult Function(KeyEvent event) handle;
  final bool Function() isEligible;

  _Entry({
    required this.owner,
    required this.scope,
    required this.handle,
    required this.isEligible,
  });
}
