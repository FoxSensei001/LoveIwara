import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 当前键盘焦点是否落在一个文本输入组件里。
///
/// 全局快捷键必须先问这一句再决定要不要出手。原因是**键盘事件会从聚焦节点一路
/// 冒泡到应用根部**：`EditableText` 并不消费 Esc、方向键这类按键，于是挂在根部的
/// 全局快捷键处理器照样收得到。此前根部的「全局返回」默认绑 Esc，用户在评论框/
/// 搜索框里打字时按 Esc，得到的不是收起输入，而是**整页退出、草稿一起没**。
///
/// 判定方式：主焦点节点的 context 往上找一个实现了 [TextInputClient] 的 State。
/// 输入框内部那只 `Focus` 正是它的后代，因此聚焦输入框时必然找得到；焦点在别处
/// （按钮、播放器、列表）则找不到。
///
/// ⛔ 不能只找 [EditableTextState] / [EditableText]：评论、回复、论坛、私信用的
/// `ExtendedTextField`（extended_text_field 包）内部是一份**私有 fork** 的
/// `_EditableText`，与官方 [EditableText] 没有继承关系，按官方类型找永远返回
/// false——「打字时别抢焦点 / 别吞 Esc」的保护对这些输入框就成了摆设。两者都
/// 混入了 [TextInputClient]，按它找才能一并认出。
///
/// 不用「有没有软键盘」来判断：桌面端没有软键盘，而这个问题恰恰在桌面端最严重。
///
/// 全应用只认这一处判定，不要在别处另写一份。
///
/// 只能在帧外（按键回调等）或 post-frame 调用：build / didChangeDependencies
/// 期间焦点节点可能处于 inactive（mounted 仍为 true），祖先查找会抛断言。
bool isTextInputFocused() {
  final BuildContext? context = FocusManager.instance.primaryFocus?.context;
  // 焦点节点所在子树可能刚被拆掉（unmount 后 mounted 为 false），对它做祖先
  // 查找会抛断言。
  if (context == null || !context.mounted) return false;
  var found = false;
  context.visitAncestorElements((element) {
    if (element is StatefulElement && element.state is TextInputClient) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// 收起当前文本输入焦点；没有输入框聚焦时返回 false，调用方可继续走原逻辑。
bool unfocusTextInput() {
  if (!isTextInputFocused()) return false;
  FocusManager.instance.primaryFocus?.unfocus();
  return true;
}
