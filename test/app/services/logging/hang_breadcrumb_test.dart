import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/logging/app_hang_watchdog_service.dart';
import 'package:i_iwara/app/services/logging/hang_breadcrumb.dart';

/// 卡死面包屑要回答的那个问题是：
///
///   **主 isolate 停下来的那一刻，它正在干什么？**
///
/// 看门狗本来只答得出「停了多久」。2026-11-09 一份 Windows 报告就卡死在这个盲区：
/// 日志最后一行是桌面全屏收尾，95 毫秒后心跳断掉、再没回来——究竟堵在退原生全屏
/// 那次 Win32 调用、还是紧跟着的窗口几何还原，日志里再找不出第二条证据。
void main() {
  setUp(HangBreadcrumb.resetForTest);
  tearDown(HangBreadcrumb.resetForTest);

  group('段落栈', () {
    test('进段出段：栈顶就是最里层那个还没结束的段落', () {
      expect(HangBreadcrumb.current, isNull);

      final outer = HangBreadcrumb.enter('outer');
      expect(HangBreadcrumb.current, 'outer');

      final inner = HangBreadcrumb.enter('inner');
      expect(HangBreadcrumb.current, 'inner');
      expect(HangBreadcrumb.depth, 2);

      HangBreadcrumb.leave(inner);
      expect(HangBreadcrumb.current, 'outer');

      HangBreadcrumb.leave(outer);
      expect(HangBreadcrumb.current, isNull);
      expect(HangBreadcrumb.depth, 0);
    });

    test('按 token 删而不是弹栈：并发交错时不会弹掉别人的段落', () {
      // 同一时刻两次退全屏就是这个形状：先开的后关。
      final first = HangBreadcrumb.enter('first');
      final second = HangBreadcrumb.enter('second');

      HangBreadcrumb.leave(first);

      expect(
        HangBreadcrumb.current,
        'second',
        reason: '无条件弹栈会把 second 弹掉，之后的卡死全部归错账',
      );
      HangBreadcrumb.leave(second);
      expect(HangBreadcrumb.current, isNull);
    });

    test('重复 leave / 陌生 token 都是 no-op', () {
      final token = HangBreadcrumb.enter('once');
      HangBreadcrumb.leave(token);
      HangBreadcrumb.leave(token);
      HangBreadcrumb.leave(999999);
      expect(HangBreadcrumb.current, isNull);
      expect(HangBreadcrumb.depth, 0);
    });

    test('有人漏了 leave 也不会顶爆：丢最旧的，保住栈顶', () {
      // 栈顶才是卡死现场，上限到了要丢的是漏掉 leave 的那一头。
      for (int i = 0; i < 40; i++) {
        HangBreadcrumb.enter('leaked-$i');
      }
      expect(HangBreadcrumb.depth, lessThanOrEqualTo(16));
      expect(HangBreadcrumb.current, 'leaked-39');
    });

    test('guard 抛异常也照常出段', () async {
      await expectLater(
        HangBreadcrumb.guard<void>('boom', () async {
          throw StateError('boom');
        }),
        throwsStateError,
      );
      expect(
        HangBreadcrumb.current,
        isNull,
        reason: '漏一次出段，栈顶就永远停在那个段上，之后每次卡死都归错账',
      );
    });

    test('guardSync 抛异常也照常出段', () {
      expect(
        () => HangBreadcrumb.guardSync<void>('boom', () {
          throw StateError('boom');
        }),
        throwsStateError,
      );
      expect(HangBreadcrumb.current, isNull);
    });

    test('没有段落开着就不往心跳里塞东西', () {
      expect(HangBreadcrumb.snapshot(), isNull);
      final token = HangBreadcrumb.enter('something');
      expect(HangBreadcrumb.snapshot(), containsPair('section', 'something'));
      HangBreadcrumb.leave(token);
      expect(HangBreadcrumb.snapshot(), isNull);
    });
  });

  group('看门狗取证', () {
    Future<File> freshEventsFile() async {
      final tempDir = await Directory.systemTemp.createTemp(
        'loveiwara_hang_breadcrumb_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      return File('${tempDir.path}/hang_events.jsonl');
    }

    List<Map<String, dynamic>> eventsOf(List<String> lines) => lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();

    test('卡死事件里写得出「当时在干什么」', () async {
      final eventsFile = await freshEventsFile();
      // 心跳 1 秒一跳、阈值 120ms：start 的那一跳之后就再没有周期心跳，
      // 于是必然判成卡死——这正是真实现场的形状（isolate 停了，心跳跟着停）。
      final watchdog = AppHangWatchdogService(
        threshold: const Duration(milliseconds: 120),
        heartbeatInterval: const Duration(seconds: 1),
        checkInterval: const Duration(milliseconds: 20),
      );

      await watchdog.start(
        sessionId: 'session-breadcrumb',
        hangEventsFilePath: eventsFile.path,
        maxFileBytes: 1024 * 1024,
        maxRotatedFiles: 2,
      );

      // ⛔ 等过补发节流窗口再进段。否则进段这一下会被 50ms 的节流吃掉，段落名
      // 就赶不上这次判定——真实现场里段落往往也是在两跳之间开始的，补发那一跳
      // 就是为它准备的。
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final token = HangBreadcrumb.enter('fullscreen-exit-native');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      HangBreadcrumb.leave(token);
      await watchdog.stop();

      final detected = eventsOf(await eventsFile.readAsLines())
          .where((event) => event['type'] == 'hang_detected')
          .toList();
      expect(detected, isNotEmpty);
      expect(
        detected.last['section'],
        'fullscreen-exit-native',
        reason: '没有这一项，下一次卡死还是只能靠读代码推',
      );
      expect(detected.last['sectionSinceMs'], isA<int>());
    });

    test('没有关键段开着时，事件里不多出 section 字段', () async {
      final eventsFile = await freshEventsFile();
      final watchdog = AppHangWatchdogService(
        threshold: const Duration(milliseconds: 120),
        heartbeatInterval: const Duration(seconds: 1),
        checkInterval: const Duration(milliseconds: 20),
      );

      await watchdog.start(
        sessionId: 'session-plain',
        hangEventsFilePath: eventsFile.path,
        maxFileBytes: 1024 * 1024,
        maxRotatedFiles: 2,
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await watchdog.stop();

      final detected = eventsOf(await eventsFile.readAsLines())
          .where((event) => event['type'] == 'hang_detected')
          .toList();
      expect(detected, isNotEmpty);
      expect(
        detected.last.containsKey('section'),
        isFalse,
        reason: '埋点没覆盖到的卡死照样要能落盘，字段只在有现场时出现',
      );
    });

    test('看门狗停掉之后不再被面包屑回调拽着跑', () async {
      final eventsFile = await freshEventsFile();
      final watchdog = AppHangWatchdogService(
        threshold: const Duration(seconds: 30),
        heartbeatInterval: const Duration(seconds: 10),
        checkInterval: const Duration(seconds: 1),
      );

      await watchdog.start(
        sessionId: 'session-detach',
        hangEventsFilePath: eventsFile.path,
        maxFileBytes: 1024 * 1024,
        maxRotatedFiles: 2,
      );
      expect(HangBreadcrumb.onChanged, isNotNull);

      await watchdog.stop();
      expect(
        HangBreadcrumb.onChanged,
        isNull,
        reason: '挂着不摘，关掉日志持久化之后每次进段还在往一个死掉的 port 上送',
      );

      // 摘干净了，进段不该抛。
      final token = HangBreadcrumb.enter('after-stop');
      HangBreadcrumb.leave(token);
    });
  });
}
