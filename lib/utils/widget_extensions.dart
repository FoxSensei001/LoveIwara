import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Widget 扩展方法集合
/// 提供了一系列便捷的 Widget 包装方法，使布局代码更简洁易读
extension WidgetExtension on Widget {

  /// 将 Widget 转换为可点击的按钮
  /// ```dart
  /// Container(...).asButton(() => print('clicked'))
  /// ```
  Widget asButton(VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: this,
      ),
    );
  }

  /// 为 Widget 添加标题栏顶部内边距
  /// ```dart
  /// Text('Hello').titleBarPaddingTop()
  /// ```
  Widget titleBarPaddingTop() {
    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: this,
      );
    } else {
      return this;
    }
  }

  /// 为 Widget 添加自定义内边距
  /// ```dart
  /// Text('Hello').padding(EdgeInsets.all(16))
  /// ```
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// 为 Widget 添加左侧内边距
  /// ```dart
  /// Text('Hello').paddingLeft(16)
  /// ```
  Widget paddingLeft(double padding) {
    return Padding(padding: EdgeInsets.only(left: padding), child: this);
  }

  /// 为 Widget 添加右侧内边距
  /// ```dart
  /// Text('Hello').paddingRight(16)
  /// ```
  Widget paddingRight(double padding) {
    return Padding(padding: EdgeInsets.only(right: padding), child: this);
  }

  /// 为 Widget 添加顶部内边距
  /// ```dart
  /// Text('Hello').paddingTop(16)
  /// ```
  Widget paddingTop(double padding) {
    return Padding(padding: EdgeInsets.only(top: padding), child: this);
  }

  /// 为 Widget 添加底部内边距
  /// ```dart
  /// Text('Hello').paddingBottom(16)
  /// ```
  Widget paddingBottom(double padding) {
    return Padding(padding: EdgeInsets.only(bottom: padding), child: this);
  }

  /// 为 Widget 添加垂直方向内边距
  /// ```dart
  /// Text('Hello').paddingVertical(16)
  /// ```
  Widget paddingVertical(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: padding), child: this);
  }

  /// 为 Widget 添加水平方向内边距
  /// ```dart
  /// Text('Hello').paddingHorizontal(16)
  /// ```
  Widget paddingHorizontal(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding), child: this);
  }

  /// 为 Widget 添加所有方向相同的内边距
  /// ```dart
  /// Text('Hello').paddingAll(16)
  /// ```
  Widget paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  /// 将 Widget 居中显示
  /// ```dart
  /// Text('Hello').toCenter()
  /// ```
  Widget toCenter() {
    return Center(child: this);
  }

  /// 设置 Widget 的对齐方式
  /// ```dart
  /// Text('Hello').toAlign(Alignment.topRight)
  /// ```
  Widget toAlign(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }

  /// 为 Sliver Widget 添加自定义内边距
  /// ```dart
  /// SliverList(...).sliverPadding(EdgeInsets.all(16))
  /// ```
  Widget sliverPadding(EdgeInsetsGeometry padding) {
    return SliverPadding(padding: padding, sliver: this);
  }

  /// 为 Sliver Widget 添加所有方向相同的内边距
  /// ```dart
  /// SliverList(...).sliverPaddingAll(16)
  /// ```
  Widget sliverPaddingAll(double padding) {
    return SliverPadding(padding: EdgeInsets.all(padding), sliver: this);
  }

  /// 为 Sliver Widget 添加垂直方向内边距
  /// ```dart
  /// SliverList(...).sliverPaddingVertical(16)
  /// ```
  Widget sliverPaddingVertical(double padding) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: padding), sliver: this);
  }

  /// 为 Sliver Widget 添加水平方向内边距
  /// ```dart
  /// SliverList(...).sliverPaddingHorizontal(16)
  /// ```
  Widget sliverPaddingHorizontal(double padding) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: padding), sliver: this);
  }

  /// 将普通 Widget 转换为 Sliver Widget
  /// ```dart
  /// Container(...).toSliver()
  /// ```
  Widget toSliver() {
    return SliverToBoxAdapter(child: this);
  }

  /// 设置 Widget 的固定宽度
  /// ```dart
  /// Text('Hello').fixWidth(100)
  /// ```
  Widget fixWidth(double width) {
    return SizedBox(width: width, child: this);
  }

  /// 设置 Widget 的固定高度
  /// ```dart
  /// Text('Hello').fixHeight(50)
  /// ```
  Widget fixHeight(double height) {
    return SizedBox(height: height, child: this);
  }
}

/// BuildContext 扩展方法集合
/// 提供了快速访问 MediaQuery 和 Theme 相关属性的方法
extension ContextExt on BuildContext {
  /// 获取设备的安全区域内边距
  /// ```dart
  /// context.padding.top // 获取顶部安全区域高度
  /// ```
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// 获取屏幕宽度
  /// ```dart
  /// double screenWidth = context.width;
  /// ```
  double get width => MediaQuery.sizeOf(this).width;

  /// 获取屏幕高度
  /// ```dart
  /// double screenHeight = context.height;
  /// ```
  double get height => MediaQuery.sizeOf(this).height;

  /// 获取键盘高度等视图插入的内边距
  /// ```dart
  /// double keyboardHeight = context.viewInsets.bottom;
  /// ```
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// 获取当前主题的颜色方案
  /// ```dart
  /// Color primaryColor = context.colorScheme.primary;
  /// ```
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 获取当前主题的亮度模式
  /// ```dart
  /// bool isDarkMode = context.brightness == Brightness.dark;
  /// ```
  Brightness get brightness => Theme.of(this).brightness;
}

/// 创建默认文本样式的快捷方式
/// ```dart
/// Text('Hello', style: ts.s16.bold)
/// ```
TextStyle get ts => const TextStyle();

/// TextStyle 扩展方法集合
/// 提供了快速设置文本样式的链式调用方法
extension StyledText on TextStyle {
  /// 设置文本为粗体
  /// ```dart
  /// Text('Hello', style: ts.bold)
  /// ```
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// 设置文本为细体
  /// ```dart
  /// Text('Hello', style: ts.light)
  /// ```
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// 设置文本为斜体
  /// ```dart
  /// Text('Hello', style: ts.italic)
  /// ```
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// 设置文本下划线
  /// ```dart
  /// Text('Hello', style: ts.underline)
  /// ```
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// 设置文本删除线
  /// ```dart
  /// Text('Hello', style: ts.lineThrough)
  /// ```
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// 设置文本上划线
  /// ```dart
  /// Text('Hello', style: ts.overline)
  /// ```
  TextStyle get overline => copyWith(decoration: TextDecoration.overline);

  /// 以下是设置不同字号的快捷方法
  /// ```dart
  /// Text('Hello', style: ts.s16) // 16号字
  /// Text('Hello', style: ts.s20.bold) // 粗体20号字
  /// ```
  TextStyle get s8 => copyWith(fontSize: 8);

  TextStyle get s10 => copyWith(fontSize: 10);

  TextStyle get s12 => copyWith(fontSize: 12);

  TextStyle get s14 => copyWith(fontSize: 14);

  TextStyle get s16 => copyWith(fontSize: 16);

  TextStyle get s18 => copyWith(fontSize: 18);

  TextStyle get s20 => copyWith(fontSize: 20);

  TextStyle get s24 => copyWith(fontSize: 24);

  TextStyle get s28 => copyWith(fontSize: 28);

  TextStyle get s32 => copyWith(fontSize: 32);

  TextStyle get s36 => copyWith(fontSize: 36);

  TextStyle get s40 => copyWith(fontSize: 40);

  /// 设置文本行高
  /// ```dart
  /// Text('Hello', style: ts.s16.withHeight(1.5))
  /// ```
  TextStyle withHeight(double value) => copyWith(height: value);

  /// 设置文本颜色
  /// ```dart
  /// Text('Hello', style: ts.s16.withColor(Colors.blue))
  /// ```
  TextStyle withColor(Color? color) => copyWith(color: color);
}

/// 使用示例：
/// ```dart
/// Widget build(BuildContext context) {
///   return Column(
///     children: [
///       // 文本样式链式调用
///       Text('Title', style: ts.s20.bold)
///           .paddingBottom(16)
///           .toCenter(),
///
///       // 获取屏幕尺寸
///       Container(
///         width: context.width * 0.8,
///         height: 50,
///       ),
///
///       // Sliver 组件使用
///       CustomScrollView(
///         slivers: [
///           Text('Sliver Header')
///               .toSliver()
///               .sliverPaddingAll(16),
///         ],
///       ),
///     ],
///   );
/// }
/// ```
