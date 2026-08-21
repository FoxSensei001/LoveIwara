import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';

/// header 刷新钮靠 [ListRefreshSignal] 的回执决定沙漏什么时候收，
/// 所以「一定会落定」比「什么时候落定」更要紧。
void main() {
  test('没有列表在听时立即落定，按钮不会卡在沙漏上', () async {
    final signal = ListRefreshSignal();
    addTearDown(signal.dispose);

    await signal.request().timeout(const Duration(seconds: 1));
    expect(signal.value, 1);
  });

  test('有列表在听时等到回执才落定', () async {
    final signal = ListRefreshSignal();
    addTearDown(signal.dispose);

    var refreshed = 0;
    signal.addListener(() => refreshed++);

    bool done = false;
    final future = signal.request().then((_) => done = true);

    await Future<void>.delayed(Duration.zero);
    expect(refreshed, 1);
    expect(done, isFalse, reason: '列表还没刷完，沙漏得继续转');

    signal.complete();
    await future;
    expect(done, isTrue);
  });

  test('刷新还没回执又点一次：旧的先了结，只等最新那次', () async {
    final signal = ListRefreshSignal();
    addTearDown(signal.dispose);
    signal.addListener(() {});

    final first = signal.request();
    final second = signal.request();

    await first.timeout(const Duration(seconds: 1));
    expect(signal.value, 2);

    bool secondDone = false;
    unawaited(second.then((_) => secondDone = true));
    await Future<void>.delayed(Duration.zero);
    expect(secondDone, isFalse);

    signal.complete();
    await second;
  });

  test('dispose 时把在途回执了结，避免 Future 永远悬着', () async {
    final signal = ListRefreshSignal();
    signal.addListener(() {});

    final future = signal.request();
    signal.dispose();

    await future.timeout(const Duration(seconds: 1));
  });
}
