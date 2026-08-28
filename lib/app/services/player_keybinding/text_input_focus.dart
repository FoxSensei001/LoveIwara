import 'package:flutter/widgets.dart';

/// 当前键盘焦点是否落在一个文本输入组件里。
///
/// 全局快捷键必须先问这一句再决定要不要出手。原因是**键盘事件会从聚焦节点一路
/// 冒泡到应用根部**：`EditableText` 并不消费 Esc、方向键这类按键，于是挂在根部的
/// 全局快捷键处理器照样收得到。此前根部的「全局返回」默认绑 Esc，用户在评论框/
/// 搜索框里打字时按 Esc，得到的不是收起输入，而是**整页退出、草稿一起没**。
///
/// 判定方式：主焦点节点的 context 往上找 [EditableTextState]。`EditableText`
/// 内部那只 `Focus` 正是它的后代，因此聚焦输入框时必然找得到；焦点在别处（按钮、
/// 播放器、列表）则找不到。
///
/// 不用「有没有软键盘」来判断：桌面端没有软键盘，而这个问题恰恰在桌面端最严重。
bool isTextInputFocused() {
  final BuildContext? context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return false;
  return context.findAncestorStateOfType<EditableTextState>() != null;
}

/// 收起当前文本输入焦点；没有输入框聚焦时返回 false，调用方可继续走原逻辑。
bool unfocusTextInput() {
  if (!isTextInputFocused()) return false;
  FocusManager.instance.primaryFocus?.unfocus();
  return true;
}
