/// 小尾巴的「示范场景」：拿一份真实的上下文，把模板渲染给用户看。
///
/// ## ⛔ 为什么非有不可
///
/// 设置页里**没有上下文**——那儿没有正在看的作品。于是
/// [SignatureService.estimate] 的样例档刻意把填不出的上下文变量原样留成
/// `{title}`（否则预览里会出现「我在看《》」）。代价是：案例、实时预览、变量
/// 面板三处加起来，用户**从头到尾看不到一个真实的结果**——案例给了名字、变量
/// 给了语法，唯独没给「长什么样」，而那正是他唯一想知道的事
/// （2026-09-21 用户原话：「光靠文字用户很难理解是什么」）。
///
/// 所以补的不是文案，是一份上下文。
///
/// ## ⭐ 示范内容取自**用户自己最近看过的那条**
///
/// 不是虚构的「示范视频 / 示范作者」。看到自己昨天看的那个标题，不用任何解释
/// 就懂了「这些值从哪儿来」；虚构数据一眼就是假的，还要为它翻 12 种语言。
/// 历史为空时（刚装完、首次引导页）才退回内置的那份虚构示范。
///
/// ## 场景为什么是四个
///
/// 同一条小尾巴切着看四遍，是讲清楚「填不出就整段消失、所以一条模板到处通用」
/// 最省事的办法——这条规则写十行字也说不明白。`none` 那一档演的就是消失。
library;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 一个可以拿来预览的场合。
class SignatureScene {
  const SignatureScene({
    required this.id,
    required this.label,
    required this.icon,
    required this.context,
  });

  /// 稳定标识，案例用它说明自己该在哪儿看（见 [SignatureSceneSet.byId]）。
  final String id;

  /// 切换条上的说法（「在视频页」）。
  final String label;

  final IconData icon;

  /// 这个场合能给出的上下文。`none` 那条是 [SignatureContext.empty]。
  final SignatureContext context;

  static const String videoId = 'video';
  static const String forumId = 'forum';
  static const String authorId = 'author';
  static const String noneId = 'none';
}

/// 四个场景 + 「示范内容是真的还是虚构的」。
class SignatureSceneSet {
  const SignatureSceneSet({required this.scenes, required this.fromHistory});

  final List<SignatureScene> scenes;

  /// true＝示范内容取自用户自己的浏览历史，false＝历史为空，用的是内置虚构示范。
  /// 切换条下那句说明按它换说法：把「这是你最近看的那条」说成虚构示范会让人
  /// 以为应用在编数据，反过来更糟。
  final bool fromHistory;

  SignatureScene get primary => scenes.first;

  /// 找一个场景；认不出就退回第一个（而不是抛）——案例里写错一个 id 不该让
  /// 整张画廊打不开。
  SignatureScene byId(String? id) {
    for (final scene in scenes) {
      if (scene.id == id) return scene;
    }
    return primary;
  }
}

/// 从历史里刨出来的那几条事实。与语言无关，所以可以跨语言缓存。
class _SceneFacts {
  const _SceneFacts({
    this.videoTitle,
    this.videoAuthor,
    this.videoTags,
    this.videoDuration,
    this.videoPlayed,
    this.threadTitle,
    this.threadAuthor,
    this.threadSection,
  });

  final String? videoTitle;
  final String? videoAuthor;
  final List<String>? videoTags;
  final Duration? videoDuration;
  final Duration? videoPlayed;

  final String? threadTitle;
  final String? threadAuthor;
  final String? threadSection;

  bool get hasAnything =>
      (videoTitle?.isNotEmpty ?? false) || (threadTitle?.isNotEmpty ?? false);
}

/// 查一次库就够了：设置页开着的这段时间里，用户的「最近看过」不会变到需要重查。
Future<_SceneFacts>? _factsFuture;

/// 关掉设置页再进来时重新取一次。目前没有调用点，留着是因为这份缓存是**进程级**
/// 的，将来要是想让它跟着页面生命周期走，出口在这里而不是散在各处。
void invalidateSignatureScenes() => _factsFuture = null;

Future<SignatureSceneSet> loadSignatureScenes(slang.Translations t) async {
  final facts = await (_factsFuture ??= _loadFacts());
  return _buildScenes(t, facts);
}

Future<_SceneFacts> _loadFacts() async {
  try {
    final repo = HistoryRepository();
    // 各取一条最近的。视频那条会 JOIN 出观看进度，`{playtime}` / `{duration}`
    // 因此也是真的。
    final videos = await repo.listRecords(itemType: 'video', limit: 1);
    final threads = await repo.listRecords(itemType: 'thread', limit: 1);

    final video = videos.isEmpty ? null : videos.first;
    final thread = threads.isEmpty ? null : threads.first;

    return _SceneFacts(
      videoTitle: video?.title.trim(),
      videoAuthor: video?.author?.trim(),
      videoTags: _tagsOf(video),
      // ⛔ `totalMs` 来自 JOIN 进来的播放进度表，只有**真看过并存下进度**的那些
      // 才有。退回视频自己的时长（`file.duration`，秒）——不然一条刚点开过的
      // 记录会让 `{duration}` 掉回内置的假数字，而上面那行说明写着「取自你最近
      // 看过的那条」，两边对不上（2026-09-21 真机上就是这样）。
      videoDuration: _ms(video?.totalMs) ?? _fileDuration(video),
      videoPlayed: _ms(video?.playedMs),
      threadTitle: thread?.title.trim(),
      threadAuthor: thread?.author?.trim(),
      threadSection: _sectionOf(thread),
    );
  } catch (e) {
    // 取不到就当没有历史，退回虚构示范。一张预览不值得把设置页炸掉。
    LogUtils.w('小尾巴示范场景读取历史失败：$e', 'SignatureScenes');
    return const _SceneFacts();
  }
}

Duration? _ms(int? value) =>
    (value == null || value <= 0) ? null : Duration(milliseconds: value);

/// 视频自身的时长（`file.duration`，秒）。没有播放进度记录时拿它顶上。
Duration? _fileDuration(HistoryRecord? record) {
  final data = record?.originalData;
  if (data is! Video) return null;
  final seconds = data.file?.duration;
  if (seconds == null || seconds <= 0) return null;
  return Duration(seconds: seconds);
}

List<String>? _tagsOf(HistoryRecord? record) {
  final data = record?.originalData;
  if (data is! Video) return null;
  final tags = data.tags
      ?.map((e) => e.id.trim())
      .where((e) => e.isNotEmpty)
      .take(SignatureContext.maxTags)
      .toList();
  return (tags == null || tags.isEmpty) ? null : tags;
}

/// 版块名要翻成给人看的说法，和论坛页那条上下文走同一套映射
/// （`thread_detail_page.dart` 的 `_signatureContextOf`）——两边显示的
/// `{section}` 必须是同一个词。
String? _sectionOf(HistoryRecord? record) {
  final data = record?.originalData;
  if (data is! ForumThreadModel) return null;
  final raw = data.section.trim();
  if (raw.isEmpty) return null;
  return idNames[replaceUnderline(raw)] ?? raw;
}

SignatureSceneSet _buildScenes(slang.Translations t, _SceneFacts facts) {
  final s = t.settings;
  final fromHistory = facts.hasAnything;

  final videoTitle = _orElse(facts.videoTitle, s.signatureDemoVideoTitle);
  final videoAuthor = _orElse(facts.videoAuthor, s.signatureDemoAuthor);
  final videoTags =
      facts.videoTags ??
      s.signatureDemoTags.split(' ').where((e) => e.isNotEmpty).toList();
  // 虚构那份给一个「看了三分多钟的九分钟片子」：两个数不一样，`{playtime}` 和
  // `{duration}` 摆在一起才看得出各是各。
  final duration =
      facts.videoDuration ?? const Duration(minutes: 9, seconds: 12);
  // 看过但没存下进度时，按真时长的三分之一虚构一个位置——`{playtime}` 本来就是
  // 「看到哪」，没有进度记录就没有真值可用，至少让它和真时长对得上。
  final played =
      facts.videoPlayed ??
      Duration(milliseconds: (duration.inMilliseconds / 3).round());

  final threadTitle = _orElse(facts.threadTitle, s.signatureDemoThreadTitle);
  final threadAuthor = _orElse(facts.threadAuthor, s.signatureDemoAuthor);
  final threadSection = _orElse(facts.threadSection, s.signatureDemoSection);

  return SignatureSceneSet(
    fromHistory: fromHistory,
    scenes: [
      SignatureScene(
        id: SignatureScene.videoId,
        label: s.signatureSceneVideo,
        icon: Icons.play_circle_outline,
        context: SignatureContext(
          title: videoTitle,
          author: videoAuthor,
          tags: videoTags,
          duration: duration,
          // ⛔ 是取值函数不是快照（见 [SignatureContext.playPosition]）。
          // 这里给一个常量闭包：示范场景不需要跟着真进度走。
          playPosition: () => played,
          // 视频页也答得出「正在回复谁」——回复投稿人是最常见的那一种。
          replyTo: videoAuthor,
        ),
      ),
      SignatureScene(
        id: SignatureScene.forumId,
        label: s.signatureSceneForum,
        icon: Icons.forum_outlined,
        context: SignatureContext(
          title: threadTitle,
          author: threadAuthor,
          section: threadSection,
          replyTo: threadAuthor,
          // 楼层只有论坛数得出。给一个不是 1 的数，好让人看出它真的是楼号。
          floor: 7,
        ),
      ),
      SignatureScene(
        id: SignatureScene.authorId,
        label: s.signatureSceneAuthor,
        icon: Icons.person_outline,
        // 作者页的留言板只知道「这是谁的主页」，别的一概没有——这一档正是用来
        // 说明各处给得**深浅不一**的。
        context: SignatureContext(author: videoAuthor),
      ),
      SignatureScene(
        id: SignatureScene.noneId,
        label: s.signatureSceneNone,
        icon: Icons.block_outlined,
        context: SignatureContext.empty,
      ),
    ],
  );
}

String _orElse(String? value, String fallback) =>
    (value == null || value.isEmpty) ? fallback : value;
