import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/pages/favorite/favorite_list_page.dart';
import 'package:i_iwara/db/migrations/migration_v4.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

/// 新建 / 重命名收藏夹弹窗关闭时的 controller 生命周期回归测试。
///
/// 旧写法把 controller 挂在 `showDialog(...).whenComplete(controller.dispose)`
/// 上，而这个 future 在 `Navigator.pop` 当下就完成、弹窗却还要播完退场动画，
/// 于是退场期间 TextField 重建会抛「A TextEditingController was used after
/// being disposed」。
void main() {
  late Database db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    MigrationV4Favorites().up(db);
    Get.put<FavoriteService>(FavoriteService(database: db));
  });

  tearDown(() {
    Get.delete<FavoriteService>(force: true);
    db.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(home: FavoriteListPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('取消新建收藏夹后，弹窗退场动画期间不会用到已销毁的 controller', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.create_new_folder));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '新建收藏夹');
    await tester.pump();

    // 取消：弹窗开始退场，controller 必须活到弹窗真正卸载
    await tester.tap(find.text(TranslationProvider.of(tester.element(
      find.byType(FavoriteListPage),
    )).translations.common.cancel));

    // 逐帧推进退场动画——崩溃正是发生在这几帧里
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsNothing);
  });
}
