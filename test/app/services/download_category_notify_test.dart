import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

import '../repositories/download_task_repository_test.dart'
    show createDownloadTasksTable;

void createDownloadCategoriesTable(CommonDatabase db) {
  db.execute('''
    CREATE TABLE download_categories(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
      display_order INTEGER NOT NULL DEFAULT 0
    );
  ''');
}

/// 「在管理页新建分类 → 返回下载列表页，分类条没有它，下拉刷新才出来」。
///
/// 这个 bug 的性质：读取和渲染都没问题，断的是「广播 → 页面 worker → 帧回调 →
/// setState」这条链，而链断了是静默的。修法不是继续加固这条链，而是删掉它——
/// 分类改成服务上的可观察状态，页面 Obx 直接读。下面两组用例分别钉住这件事的
/// 两端：服务侧写完即最新、UI 侧被上层路由盖住时也能拿到更新。
void main() {
  late CommonDatabase db;
  late DownloadService service;

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    createDownloadTasksTable(db);
    createDownloadCategoriesTable(db);
    service = DownloadService(repository: DownloadTaskRepository(db));
    Get.put<DownloadService>(service);
  });

  tearDown(() {
    Get.delete<DownloadService>(force: true);
    db.close();
  });

  group('服务侧：分类是状态，不是信号', () {
    test('新建后 categories 立即包含它（无需任何订阅方配合）', () async {
      await service.refreshCategories();
      expect(service.categories, isEmpty);

      final created = await service.createCategory(title: '新建的分类');

      expect(created, isNotNull);
      expect(service.categories.map((c) => c.title), ['新建的分类']);
    });

    test('改名 / 删除同样立即反映', () async {
      final created = await service.createCategory(title: '旧名字');

      await service.updateCategory(created!.id, title: '新名字');
      expect(service.categories.single.title, '新名字');

      await service.deleteCategory(created.id);
      expect(service.categories, isEmpty);
    });
  });

  testWidgets('被管理页盖住时新建分类，返回后分类条已经有它', (tester) async {
    await service.refreshCategories();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Obx(
            () => Text(
              '分类=${service.categories.map((c) => c.title).join(",")}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
    expect(find.text('分类='), findsOneWidget);

    // 打开管理页（不透明路由，完全盖住列表页）
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('管理分类'))),
      ),
    );
    await tester.pumpAndSettle();

    // 在管理页里新建
    await service.createCategory(title: '假日');
    await tester.pumpAndSettle();

    // 返回列表页
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(
      find.text('分类=假日'),
      findsOneWidget,
      reason: '返回后分类条必须已经有新分类，而不是等下拉刷新',
    );
  });

  testWidgets('界面完全空闲时新建分类也立即可见', (tester) async {
    await service.refreshCategories();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Obx(
            () => Text(
              '数量=${service.categories.length}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
    expect(find.text('数量=0'), findsOneWidget);

    await service.createCategory(title: '空闲时新建');
    // 只泵一帧：模拟「没有动画、没人再来帧」的最坏情况
    await tester.pump();

    expect(find.text('数量=1'), findsOneWidget);
  });

  test('选中的分类被删掉后，筛选值按「全部」处理（页面侧纯计算的等价逻辑）', () async {
    final created = await service.createCategory(title: '会被删掉');
    String effectiveFilter(String filter, List<DownloadCategory> categories) {
      if (filter == 'all') return 'all';
      if (filter == 'uncategorized') {
        return categories.isEmpty ? 'all' : 'uncategorized';
      }
      return categories.any((c) => c.id == filter) ? filter : 'all';
    }

    expect(effectiveFilter(created!.id, service.categories), created.id);

    await service.deleteCategory(created.id);

    expect(effectiveFilter(created.id, service.categories), 'all');
    expect(effectiveFilter('uncategorized', service.categories), 'all');
  });
}
