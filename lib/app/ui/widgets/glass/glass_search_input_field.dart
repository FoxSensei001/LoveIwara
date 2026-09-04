import 'package:flutter/material.dart';

/// 行盒高度相对字号的倍数。1.25 是「容得下所有中文字形、又不至于把 44 的胶囊
/// 撑满」的一档；改它会同时动输入文字与提示文字，两者必须一致。
const double _lineHeight = 1.25;

/// 玻璃胶囊里那条搜索输入框。
///
/// # ⛔ 不要靠「把 TextField 拉满高度」来对齐（2026-08-31 报障）
///
/// `TextField` 默认按内容收缩，44 的胶囊里那条行盒只有 19 上下。第一版的修法是
/// 给它 `SizedBox(height: double.infinity)` + `isCollapsed` + [TextAlignVertical]
/// `.center`，指望「命中区撑满、文字在其中居中」一次解决。**居中那半是假的**：
///
/// `InputDecorator` 先按**内容**算出 containerHeight（≈23）并按它摆好里头的
/// 输入行，最后才 `constraints.constrain(...)` 把自己撑到 52——孩子早摆完了，
/// 不会跟着往下挪。实测（52 高的桌面胶囊）输入行落在 `274.6..297.6`，而外框是
/// `274.6..325.4`：**贴着顶，离居中差了 14px**。`isCollapsed` 下 [textAlignVertical]
/// 能挪的只是 containerHeight 内部那点余量，这里余量是 0，所以它一点用没有。
/// 用户报的「有的形态下 placeholder 没垂直居中」就是这条。
///
/// 所以现在**不拉伸**：行盒保持自然高度，外面套一层撑满的 [Align] 把它摆到正中
/// ——这一层是布局，不受 `InputDecorator` 那套内部时序影响。
///
/// 那命中区呢？——**不归它管了**。整只胶囊的取焦交给 [GlassSearchPillTapArea]，
/// 那层连左内边距、放大镜图标、图标与文字之间的缝一起接住，比「把输入框拉满」
/// 盖得更全（拉满也盖不到图标那一段）。两件事各归各位，别再想用一个尺寸同时
/// 解决对齐和命中。
///
/// ⚠️ `height: double.infinity` 要求**外壳的高度是有界的**——放进 [GlassSurface]
/// 这类定高胶囊里才成立（它默认就是 `GlassTokens.pillHeight`）。别塞进高度不定
/// 的容器。
///
/// # ⛔ 字在行盒里还得再居中一次
///
/// 把行盒摆正只是第一步：**字在行盒里本来就不居中**。行盒高 = ascent + descent，
/// 而这两个数来自当前实际用上的字体——中文回退到系统字体（Windows 上是雅黑一
/// 类）时 ascent 特别高、descent 特别浅，字就整体压在行盒下半截；只把盒子摆正，
/// 看到的仍旧是「偏下 / 偏上」。字号越是被我们改小（提示文字比输入文字小 1px），
/// 两条行盒的偏移量还不一样，于是「有的形态下没居中」。
///
/// 两把锁一起上：
///   - `strutStyle(forceStrutHeight: true, height: [_lineHeight])`——行盒高度不再
///     由字体说了算，恒等于 `fontSize × 1.25`，中英混排、换字体都不会跳；
///   - [TextLeadingDistribution.even]——多出来的行距**上下平分**（默认是全塞在
///     上面），字这才落到行盒正中。
///
/// 提示文字走的是 `InputDecorator` 自己的那只 `Text`，吃不到 strut，所以 `hintStyle`
/// 里得把同一套 `height` + `leadingDistribution` 再写一遍。
///
/// # ⛔ 这里**没有**「光学抬升」——字就落在胶囊的几何正中。
///
/// 2026-08-31 曾经加过一档 `fontSize × 0.22` 的上抬，理由是「几何居中读着偏沉」
/// （眼睛按 x-height 那一带的墨量判重心，下伸部留的空白算不进视觉重量）。真机
/// 上它是反效果：14.5 字号下那是 3.2px，同一只胶囊里的放大镜图标走的仍是几何
/// 正中，于是文字与图标肉眼可见地错开一档——用户 2026-09-04 报的「输入那一行
/// 没垂直居中，而 icon 是居中的」就是这条。
///
/// 全站的参照是搜索结果页那只胶囊（`search_result.dart` 的 `_buildSearchPill`）：
/// 一条普通 `Text` 由 `Row` 按几何正中摆放。上面那两把锁（forceStrutHeight +
/// [TextLeadingDistribution.even]）已经让这里的行盒与那条 `Text` 的墨迹落点一致，
/// 两处因此严丝合缝。要再动这个取向，请连图标一起动，否则只会重新拉开这道缝。
///
/// # ⛔ 提示文字**不能**比输入文字小一号
///
/// 这条是上面两把锁都锁不住的第三个坑，也是「有的形态下没居中」最后那一点残余。
///
/// `InputDecorator` 把提示文字和输入文字**按同一条 alphabetic 基线**摆在一起——
/// 不是各自在容器里居中（Flutter SDK `input_decorator.dart` 的
/// `_RenderDecoration.performLayout`：`baselineLayout()` 拿同一个 `baseline` 先后
/// 摆 `input` 和 `hint`）。`textAlignVertical` / `isCollapsed` 能挪的只是这条**共用
/// 基线**在容器里的高低，管不到两只盒子之间的关系。
///
/// 于是只要两边字号不同，两条行盒的高度就不同（行盒高 = 字号 × [_lineHeight]），
/// 按同一条基线拼起来之后两者的几何中心**必然错开**：
///
/// ```
/// 中心偏移 = (输入字号 − 提示字号) × (descent 比例 − ascent 比例) / 2
/// ```
///
/// 字号差为 0 时它恒等于 0，**与用什么字体无关**；字号差 1px 时实测在 0.4~0.6px
/// 之间随字体漂移（默认测试字体 0.38、黑体 0.48、Segoe UI 0.54）——量小，但它是
/// 「换个形态、换台机器就不一样」的那种偏移，不该留着。
///
/// 所以两边共用一个 [fontSize]，提示文字与输入文字的区分改由 [hintAlpha] 承担。
///
/// ⚠️ `maxLines` 保持默认的 1：改成多行（或 `expands: true`）会让回车变成换行，
/// [onSubmitted] 从此不再触发，搜索就按不出去了。
class GlassSearchInputField extends StatelessWidget {
  const GlassSearchInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSubmitted,
    this.onChanged,
    this.fontSize = 14.5,
    this.hintAlpha = 0.8,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  /// 回车（或输入法的「搜索」键）提交。
  final ValueChanged<String> onSubmitted;

  /// 文本变化。参数没有意义（内容读 [controller]），所以不带值。
  final VoidCallback? onChanged;

  /// 输入文字与提示文字**共用**的字号。
  ///
  /// ⛔ 别再给提示文字单开一个「小一号」的字号，理由见类注释最后一段。
  final double fontSize;

  /// 提示文字相对 `onSurfaceVariant` 的透明度。提示文字与输入文字的区分靠这个，
  /// 不靠字号。
  final double hintAlpha;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: double.infinity,
      // 撑满的是**槽位**（免得胶囊里的其他孩子跟着变矮），居中的是里头那条行盒。
      child: Align(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          // 行盒高度写死成 fontSize × [_lineHeight]，多出来的行距**上下平分**。
          // 见类注释「字在行盒里还得再居中一次」。
          strutStyle: StrutStyle(
            fontSize: fontSize,
            height: _lineHeight,
            leading: 0,
            forceStrutHeight: true,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            height: _lineHeight,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: fontSize,
              color: colorScheme.onSurfaceVariant.withValues(alpha: hintAlpha),
              // 提示文字是 `InputDecorator` 自己摆的一只 `Text`，吃不到上面那条
              // strut，必须自带同一套行高规则，否则它在行盒里的偏移与输入文字
              // 不一样——「有字时是正的、空着时提示偏上」就是这么来的。
              height: _lineHeight,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged == null ? null : (_) => onChanged!(),
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}

/// 把「整只搜索胶囊」变成输入框的命中区。
///
/// # ⛔ 光让 [GlassSearchInputField] 撑满高度还不够（2026-08-31 报障续）
///
/// 撑满的只是**输入框自己那一格**。胶囊里排在它前后的东西——左内边距、放大镜
/// 图标、图标与文字之间的间隔、右侧清除键与搜索键之间的缝——都不在 `TextField`
/// 的命中区里，点上去一点反应都没有。实测（52 高、左内边距 16 的桌面胶囊）
/// 左边整整 44.6px 是死区，而提示文字恰好紧贴死区右侧，用起来就是用户报的那句
/// 「要正好点到 placeholder 上才能输入」。
///
/// 这层把整只胶囊接住：点在任何一处死区都给 [focusNode] 取焦。命中行为按
/// [HitTestBehavior.translucent] 走，所以**深处的控件照样先赢**——点文字本身仍由
/// `TextField` 自己处理（光标落在点的位置，而不是被这层顶到末尾），点右侧的清除
/// 键、搜索键也照旧是各自的 `onPressed`。
///
/// ⚠️ 要包在 [GlassSurface] **外面**，不能当它的 `child`：它的 `padding` 是套在
/// child 外层的（见 `glass_surface.dart` 里 `buildBox` 那句 `Padding(...)`），
/// 当 child 就正好漏掉左内边距那一条——而那正是提示文字左边最常被点到的一段。
class GlassSearchPillTapArea extends StatelessWidget {
  const GlassSearchPillTapArea({
    super.key,
    required this.focusNode,
    required this.child,
  });

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: focusNode.requestFocus,
      child: child,
    );
  }
}
