import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/utils/desktop_native_fullscreen.dart';

/// 桌面端「原生全屏会话」——它要回答的那个问题是：
///
///   **窗口还铺满整块显示器，可屏幕上演的已经不是全屏播放了。**
///
/// 这件事没有任何系统事件会通知我们（全屏是 media_kit 自己开的，页面被
/// `pushReplacement` 顶掉时也没人替我们收），所以判据只能自己立：
/// 登记谁在全屏里演出，最后一个演出者离场而会话还开着，就是一次孤儿会话。
///
/// 2026-08-31 用户报障：全屏里用「接着看」换到私密视频 / 站外短链视频，窗口留在
/// 满屏、标题栏和侧边导航还藏着，内容却已经是详情页——退不出去，也拖不动。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 会话只在桌面端成立（移动端没有"窗口"可言，acquire/release 全是 no-op）。
  final bool onDesktop =
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  setUp(() {
    DesktopNativeFullscreen.resetForTest();
    // 原生通道在单测里不存在。让它安静地答 null，走到的分支才是被测的那条。
    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.alexmercerind/media_kit_video'),
          (call) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.alexmercerind/media_kit_video'),
          null,
        );
    DesktopNativeFullscreen.resetForTest();
  });

  /// 孤儿检查是延迟判定的，等过那段缓冲再看结论。
  Future<void> settleOrphanCheck() =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  group('会话登记', () {
    test('最后一个演出者离场，孤儿会话被收回', () async {
      if (!onDesktop) return;
      final presenter = Object();
      DesktopNativeFullscreen.markEntered();
      DesktopNativeFullscreen.acquire(presenter);
      expect(DesktopNativeFullscreen.isActive, isTrue);

      DesktopNativeFullscreen.release(presenter);
      await settleOrphanCheck();

      expect(
        DesktopNativeFullscreen.isActive,
        isFalse,
        reason: '没人在全屏里演出了，窗口不该继续铺满显示器',
      );
      expect(DesktopNativeFullscreen.hasPresenter, isFalse);
    });

    test('全屏连播换片：新页先接手，旧页再放手，会话原地不动', () async {
      if (!onDesktop) return;
      final oldPage = Object();
      final newPage = Object();
      DesktopNativeFullscreen.markEntered();
      DesktopNativeFullscreen.acquire(oldPage);

      // pushReplacement 下新页的 onInit 跑在旧页 dispose 之前，顺序就是这个。
      DesktopNativeFullscreen.acquire(newPage);
      DesktopNativeFullscreen.release(oldPage);
      await settleOrphanCheck();

      expect(
        DesktopNativeFullscreen.isActive,
        isTrue,
        reason: '这是一次正常的全屏接力，把用户踢出全屏就是回归',
      );
      expect(DesktopNativeFullscreen.hasPresenter, isTrue);
    });

    test('acquire 幂等：同一个演出者登记两次，放一次手就算离场', () async {
      if (!onDesktop) return;
      final presenter = Object();
      DesktopNativeFullscreen.markEntered();
      // 全屏接力开局一次（onInit）、enterFullscreen 里再一次，是真实路径。
      DesktopNativeFullscreen.acquire(presenter);
      DesktopNativeFullscreen.acquire(presenter);

      DesktopNativeFullscreen.release(presenter);
      await settleOrphanCheck();

      expect(
        DesktopNativeFullscreen.isActive,
        isFalse,
        reason: '用计数器就会配不平，第二次 acquire 让会话永远收不掉',
      );
    });

    test('会话没开着时放手，什么都不做', () async {
      if (!onDesktop) return;
      final presenter = Object();
      DesktopNativeFullscreen.acquire(presenter);
      DesktopNativeFullscreen.release(presenter);
      await settleOrphanCheck();

      expect(DesktopNativeFullscreen.isActive, isFalse);
    });

    test('正常退出全屏（先 release 再退原生）不会被孤儿检查重复收一次', () async {
      if (!onDesktop) return;
      final presenter = Object();
      DesktopNativeFullscreen.markEntered();
      DesktopNativeFullscreen.acquire(presenter);

      // exitFullscreen() 的顺序：先注销演出者，再退原生全屏。
      DesktopNativeFullscreen.release(presenter);
      await DesktopNativeFullscreen.exitNative();
      await settleOrphanCheck();

      expect(DesktopNativeFullscreen.isActive, isFalse);
    });
  });

  group('全屏里放不了的片子', () {
    bool drop({
      bool isDesktop = true,
      bool holdsDesktopFullscreen = true,
      bool isPiPMode = false,
      bool isPlaybackBlocked = true,
    }) => MyVideoStateController.shouldDropDesktopFullscreenForBlockedPlayback(
      isDesktop: isDesktop,
      holdsDesktopFullscreen: holdsDesktopFullscreen,
      isPiPMode: isPiPMode,
      isPlaybackBlocked: isPlaybackBlocked,
    );

    test('桌面端全屏里换到一条播不了的片子，退回详情页', () {
      expect(drop(), isTrue);
    });

    test('与「自动进入全屏」那个设置无关——它关着也照退', () {
      // 这条判据整个不接收 AutoFullscreenMode：窗口铺满屏幕却只有一张错误页，
      // 是状态不自洽，跟用户有没有打开那项能力毫无关系。
      expect(
        MyVideoStateController.shouldAutoExitFullscreenForBlockedPlayback(
          mode: AutoFullscreenMode.off,
          isAnyFullscreenActive: true,
          isPiPMode: false,
          isPlaybackBlocked: true,
        ),
        isFalse,
        reason: '那一条是自动全屏能力自己的契约，保持不变',
      );
      expect(drop(), isTrue, reason: '这一条独立成立，才补得上默认设置下的那个洞');
    });

    test('没占着桌面全屏就不管', () {
      expect(drop(holdsDesktopFullscreen: false), isFalse);
    });

    test('判据是"占着全屏"而不是"已经在全屏里"', () {
      // 全屏连播换片时新页在 onInit 就接手了会话，真正进全屏要等下一帧。
      // 命中缓存的站外视频恰好落在这中间——只看 isFullscreen 会漏判，
      // 然后下一帧照样把用户推进一个只有错误页的满屏窗口。
      final source = File(
        'lib/app/ui/pages/video_detail/controllers/my_video_state_controller.dart',
      ).readAsStringSync().replaceAll('\r\n', '\n');
      expect(
        source.contains('holdsDesktopFullscreen: holdsDesktopFullscreen'),
        isTrue,
        reason: '传 isAnyFullscreenActive 进去就退回到了漏判的那一版',
      );
    });

    test('片子放得了就不管', () {
      expect(drop(isPlaybackBlocked: false), isFalse);
    });

    test('PiP 期间既不自动进也不自动退', () {
      expect(drop(isPiPMode: true), isFalse);
    });

    test('只管桌面端：移动端全屏没有窗口几何可言，不在本次范围内', () {
      expect(drop(isDesktop: false), isFalse);
    });
  });

  // ⛔ 读源码的闸门必须先抹平换行：仓库 core.autocrlf=true，工作区是 CRLF，
  // 而下面的断言写的是 '\n'。不抹平的话本地全绿、别人机器上全红。
  group('源码闸门', () {
    final controllerSource = File(
      'lib/app/ui/pages/video_detail/controllers/my_video_state_controller.dart',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    String bodyOf(String signature) {
      final start = controllerSource.indexOf(signature);
      expect(start, greaterThan(-1), reason: '找不到 $signature');
      return controllerSource.substring(
        start,
        controllerSource.indexOf('\n  }', start),
      );
    }

    test('交接件不再携带窗口几何', () {
      final handoff = File(
        'lib/app/models/video_fullscreen_handoff.model.dart',
      ).readAsStringSync().replaceAll('\r\n', '\n');
      expect(
        handoff.contains('desktopWindow'),
        isFalse,
        reason:
            '快照一旦跟着交接件一页页传，只要有一次没传到就永远消失——'
            '"换到一条播不了的片子"恰恰就是被有意丢掉交接件的那一次。'
            '几何归 DesktopNativeFullscreen 这个进程级会话所有。',
      );
    });

    test('controller 销毁时一定放手', () {
      expect(
        bodyOf('  void onClose() {').contains(
          'DesktopNativeFullscreen.release(this)',
        ),
        isTrue,
        reason: '这是"桌面端已经不在全屏播放了"唯一靠得住的信号；漏掉它窗口就永远铺满屏幕',
      );
    });

    test('路由接力时**不能**提前放手', () {
      expect(
        bodyOf(
          '  void relinquishFullscreenForRouteHandoff() {',
        ).contains('DesktopNativeFullscreen.release'),
        isFalse,
        reason: '这一步跑在 pushReplacement 之前，此刻新页还不存在——'
            '提前放手会把一次正常的接力当成孤儿会话，当场把用户踢出全屏',
      );
    });

    test('接手全屏的新页在 onInit 里同步登记', () {
      expect(
        controllerSource.contains(
          "if (fullscreenHandoff?.nativeFullscreenActive == true) {\n"
          "        DesktopNativeFullscreen.acquire(this);",
        ),
        isTrue,
        reason: 'enterFullscreen() 是异步的，等它跑完再登记，接力中间就是一段空窗',
      );
    });
  });
}
