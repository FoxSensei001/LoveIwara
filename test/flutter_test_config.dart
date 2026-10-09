import 'dart:async';

import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 出厂默认的界面材质是 Material，但玻璃相关的老用例都是照「默认＝真玻璃」写的。
/// 每个测试文件开跑前统一钉回液态档；要测 Material 档的用例自己显式设置。
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  glassMaterialMode.value = GlassMaterialMode.liquid;
  await testMain();
}
