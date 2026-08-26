import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/rx_ever.dart';

/// 让微任务跑完（rxEver / ever 的回调都在微任务里）。
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('rxEver', () {
    test('值变化时回调（异步，与 ever 一致）', () async {
      final rx = 0.obs;
      final seen = <int>[];
      final worker = rxEver<int>(rx, seen.add);

      rx.value = 1;
      expect(seen, isEmpty, reason: '不在 refresh() 的同步栈里跑');
      await settle();
      expect(seen, [1]);

      rx.value = 2;
      await settle();
      expect(seen, [1, 2]);

      worker.dispose();
      rx.value = 3;
      await settle();
      expect(seen, [1, 2], reason: 'dispose 之后不再收到');
    });

    test('⭐ 订阅 -> 取消 -> 再订阅之后仍然收得到（ever 在这里是死的）', () async {
      // 这正是「下载完成不出现在历史区」的机制：Rx 属于常驻服务，页面每次
      // 打开都新订阅一次、关闭时取消一次。第二次打开必须照常收到。
      final rx = 0.obs;

      var first = 0;
      rxEver<int>(rx, (_) => first++).dispose();

      var second = 0;
      final worker = rxEver<int>(rx, (_) => second++);

      rx.value++;
      await settle();

      expect(second, 1);
      expect(first, 0);
      worker.dispose();
    });

    test('多个订阅者互不影响；一个取消不会连累另一个', () async {
      final rx = 0.obs;
      var a = 0;
      var b = 0;
      final workerA = rxEver<int>(rx, (_) => a++);
      final workerB = rxEver<int>(rx, (_) => b++);

      rx.value++;
      await settle();
      expect([a, b], [1, 1]);

      workerA.dispose();
      rx.value++;
      await settle();
      expect([a, b], [1, 2]);

      workerB.dispose();
    });
  });

  /// 这条不是在测 GetX，是把「为什么不能用 ever」钉在测试里：哪天有人觉得
  /// rxEver 是多余的一层想删掉，先看这条。
  test('（记录 GetX 的坑）ever() 在重新订阅之后收不到值', () async {
    final rx = 0.obs;

    ever<int>(rx, (_) {}).dispose();

    var hits = 0;
    final worker = ever<int>(rx, (_) => hits++);
    // Obx 走的那条路（addListener）仍然是活的
    var listenerHits = 0;
    rx.addListener(() => listenerHits++);

    rx.value++;
    await settle();

    expect(listenerHits, 1, reason: 'addListener 这条路没坏');
    expect(
      hits,
      0,
      reason: 'ever 走 stream，最后一个订阅者取消时 onCancel 摘掉了内部的 '
          '_streamListener，而 _controller 不再重建 —— 之后的订阅者永久失聪。'
          '若哪天 GetX 修好了这条会变红，那时才可以考虑去掉 rxEver。',
    );
    worker.dispose();
  });
}
