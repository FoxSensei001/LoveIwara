import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/oreno3d_html_parser.dart';

/// [Oreno3dHtmlParser.extractIwaraVideoId] 的单测。
///
/// 这是匹配流程里唯一的「校验」动作，必须只认详情页正文那条 iwara 链接：
/// 认错了会把别的视频当成当前视频，而这里恰恰是整个流程唯一的防误报点。
void main() {
  group('extractIwaraVideoId', () {
    test('取详情页正文的 iwara 链接', () {
      const html = '''
        <header>
          <figure class="video-figure">
            <a href="https://www.iwara.tv/video/wZnIuPmUg9UoIX/sex-only-1"
               target="_blank" rel="noopener"></a>
          </figure>
        </header>
      ''';
      expect(Oreno3dHtmlParser.extractIwaraVideoId(html), 'wZnIuPmUg9UoIX');
    });

    test('正文链接排在推荐位之前时取到的是正文那条', () {
      // 页面底部的推荐位指向 oreno3d 站内，不带 iwara 链接；
      // 真出现多条时，第一条（正文「この動画を見る」）才是本视频的来源。
      const html = '''
        <a href="https://www.iwara.tv/video/aaaaaaaaaaaaaa/first"></a>
        <a href="https://www.iwara.tv/video/bbbbbbbbbbbbbb/second"></a>
      ''';
      expect(Oreno3dHtmlParser.extractIwaraVideoId(html), 'aaaaaaaaaaaaaa');
    });

    test('兼容不带 www 与 http 的写法', () {
      expect(
        Oreno3dHtmlParser.extractIwaraVideoId(
          'http://iwara.tv/video/1z7zwileds302yx4/',
        ),
        '1z7zwileds302yx4',
      );
    });

    test('没有 iwara 链接时返回 null，不会误抓站内链接', () {
      const html = '''
        <div class="tag-text">iwara</div>
        <a href="https://oreno3d.com/movies/356315"></a>
      ''';
      expect(Oreno3dHtmlParser.extractIwaraVideoId(html), isNull);
    });

    test('空文档返回 null', () {
      expect(Oreno3dHtmlParser.extractIwaraVideoId(''), isNull);
    });
  });

  group('与 parseVideoDetail 的一致性', () {
    // 结构照抄真实详情页 https://oreno3d.com/movies/356315：
    // 正文 <header> 里的 .video-figure a.pop_separate 和页尾的 a.video-watch-btn2
    // 指向同一条 iwara 链接，页面底部的推荐位则只指向 oreno3d 站内。
    //
    // 这一条是整条匹配链路唯一的防误报支点：校验走的是正则 firstMatch，
    // 而落库/展示走的是 parseVideoDetail 的 CSS 选择器。两套抽取必须指向同一条链接，
    // 否则会出现「校验通过了、但页面上显示的是另一条视频」。
    const realStructure = '''
<html><body>
<article class="g-main-video-article">
  <header>
    <figure class="video-figure">
      <a href="https://www.iwara.tv/video/wZnIuPmUg9UoIX/sex-only-1"
         target="_blank" rel="noopener" class="pop_separate">
        <i class="material-icons video-watch-btn1 md-5em">play_arrow</i>
        <img src="/storage/thumbnails/6a8a3328adb51" alt="" class="video-img">
      </a>
    </figure>
    <h1 class="video-h1">[Sex only]测试标题</h1>
    <div class="video-watch-favorite" onclick="toggleFavorite(356315, 'movie')">
      <div class="video-watch-btn2 video-watch-favorite-btn">お気に入り登録</div>
    </div>
  </header>
  <a href="https://www.iwara.tv/video/wZnIuPmUg9UoIX/sex-only-1"
     class="video-watch-btn2" target="_blank" rel="noopener">この動画を見る</a>
  <section class="video-section-tag">
    <h2 class="video-h2-information">作成者：</h2>
    <a href="https://oreno3d.com/authors/11839" class="tag-btn">
      <div class="video-center">10yue</div>
    </a>
  </section>
  <div class="g-main-grid">
    <article>
      <a href="https://oreno3d.com/movies/999999" class="box">
        <h2 class="box-h2">推荐位的另一条视频</h2>
        <div class="box-text2"><div class="box-text-in">iwara</div></div>
      </a>
    </article>
  </div>
</body></html>
''';

    test('正则校验取到的 ID 与 parseVideoDetail 的 playUrl 是同一条', () {
      final probed = Oreno3dHtmlParser.extractIwaraVideoId(realStructure);
      final parsed = Oreno3dHtmlParser.parseVideoDetail(realStructure, '356315');

      expect(probed, 'wZnIuPmUg9UoIX');
      expect(parsed, isNotNull);
      expect(parsed!.extractIwaraId(), probed);
    });

    test('推荐位的站内链接不会被误当成来源', () {
      // 推荐位卡片带 "iwara" 标签文本、链接却指向 oreno3d，
      // 正则只认 iwara.tv/video/ 形式，不会把它算进来。
      expect(
        Oreno3dHtmlParser.extractIwaraVideoId(realStructure),
        isNot(contains('999999')),
      );
    });
  });
}
