import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/glass_material_intro.dart';

/// 「玻璃质感」一次性提醒的**时机**契约。
///
/// 弹窗本身不难，难的是别弹在会被立刻盖掉的那几秒里。这里把
/// [GlassMaterialIntro.decide] 当纯函数测，覆盖冷启动那几种真实处境：
/// 被链接拉起来、还在首次引导里、上面压着自动更新弹窗、人根本不在首页。
void main() {
  GlassIntroAction decide({
    bool introShown = false,
    bool setupCompleted = true,
    bool pendingDeepLink = false,
    bool overlay = false,
    String? location = '/',
  }) {
    return GlassMaterialIntro.decide(
      introShown: introShown,
      firstTimeSetupCompleted: setupCompleted,
      hasPendingDeepLink: pendingDeepLink,
      hasOverlay: overlay,
      currentLocation: location,
    );
  }

  test('老用户站在首页、什么都没挡着 → 弹', () {
    expect(decide(), GlassIntroAction.show);
  });

  test('问过一次就永远不再问（哪怕别的条件都满足）', () {
    expect(decide(introShown: true), GlassIntroAction.alreadyDone);
    // 引导没走完也一样：引导页那份选择同样会把它标记掉。
    expect(
      decide(introShown: true, setupCompleted: false),
      GlassIntroAction.alreadyDone,
    );
  });

  test('首次引导还没完成 → 交给引导页，别抢它的活', () {
    expect(decide(setupCompleted: false), GlassIntroAction.guideWillAsk);
    // 引导页不是 tab 根，但这条要先于「不在首页」判出来，否则会白重试 5 次。
    expect(
      decide(setupCompleted: false, location: '/first_time_setup'),
      GlassIntroAction.guideWillAsk,
    );
  });

  test('DeepLink 冷启动：链接还在路上就先等着', () {
    // 链接是 markReady 之后延迟 1.5s 才导航的，这会儿首页只是「过路的」。
    expect(decide(pendingDeepLink: true), GlassIntroAction.waitAndRetry);
  });

  test('DeepLink 落到详情页 → 一直不弹（重试到放弃，留到下次启动）', () {
    expect(
      decide(location: '/video_detail/abc123'),
      GlassIntroAction.waitAndRetry,
    );
    expect(
      decide(location: '/gallery_detail/xyz'),
      GlassIntroAction.waitAndRetry,
    );
  });

  test('DeepLink 落到 tab 根：链接处理完之后就能弹了', () {
    expect(
      decide(pendingDeepLink: true, location: '/gallery'),
      GlassIntroAction.waitAndRetry,
    );
    expect(
      decide(pendingDeepLink: false, location: '/gallery'),
      GlassIntroAction.show,
    );
  });

  test('上面压着别的弹窗（自动更新 / 崩溃恢复）→ 等它先走', () {
    expect(decide(overlay: true), GlassIntroAction.waitAndRetry);
  });

  test('人不在首页时不打断（设置页、播放器、未知路由）', () {
    for (final location in <String?>[
      '/settings',
      '/first_time_setup',
      '/search',
      '',
      null,
    ]) {
      expect(
        decide(location: location),
        GlassIntroAction.waitAndRetry,
        reason: 'location=$location 不该弹',
      );
    }
  });

  test('四个 tab 根都算首页（末尾斜杠也认）', () {
    for (final location in <String>[
      '/',
      '/gallery',
      '/subscriptions',
      '/community',
      '/gallery/',
    ]) {
      expect(
        GlassMaterialIntro.isHomeTabRoot(location),
        isTrue,
        reason: 'location=$location 应该算首页 tab 根',
      );
    }
    for (final location in <String?>[
      null,
      '',
      '/video_detail/1',
      '/galleryx',
      '/community/thread/1',
    ]) {
      expect(
        GlassMaterialIntro.isHomeTabRoot(location),
        isFalse,
        reason: 'location=$location 不该算首页 tab 根',
      );
    }
  });
}
