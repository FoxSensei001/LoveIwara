import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/playback_history_service.dart';
import 'package:i_iwara/app/services/xr_immersive_service.dart';
import 'package:i_iwara/app/services/xr_playlist_source.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

class _Config extends ConfigService {
  bool rememberProgress = true;
  @override
  dynamic operator [](ConfigKey key) =>
      key == ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS
      ? rememberProgress
      : key.defaultValue;
}

class _SourceQueue extends SourcePlaybackQueue {
  _SourceQueue({required super.queueId, required super.context});
  bool get retained => hasListeners;
}

class _History extends GetxService implements PlaybackHistoryService {
  final saved = <(String, int, int)>[];
  final deleted = <String>[];
  Completer<void>? saveGate;
  @override
  Future<void> init() async {}
  @override
  Future<void> savePlaybackHistory(
    String videoId,
    int totalDuration,
    int playedDuration,
  ) async {
    await saveGate?.future;
    saved.add((videoId, totalDuration, playedDuration));
  }

  @override
  Future<void> deletePlaybackHistory(String videoId) async =>
      deleted.add(videoId);
  @override
  Future<Map<String, dynamic>?> getPlaybackHistory(String videoId) async =>
      null;
}

void main() {
  const channel = MethodChannel('i_iwara/immersive');
  late XrImmersiveService service;
  late Map<int, Completer<bool>> presentations;
  late List<Map<dynamic, dynamic>> requests;
  late List<MethodCall> calls;
  late List<XrPlaybackReturn> returns;
  late Future<XrPlayableVideo?> Function(String) resolver;
  late _Config config;
  late _History history;
  late Database db;
  late LocalMediaRepository localRepository;
  late List<PlaybackQueue> queues;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
    db = sqlite3.openInMemory();
    await MigrationManager(
      migrations: MigrationManager.defaultMigrations()
          .where((migration) => migration.version != 7)
          .toList(),
    ).runMigrations(db);
    localRepository = LocalMediaRepository(db);
  });

  tearDownAll(() => db.close());

  setUp(() {
    Get.testMode = true;
    presentations = {};
    requests = [];
    calls = [];
    returns = [];
    queues = [];
    resolver = (_) async => null;
    config = Get.put<ConfigService>(_Config()) as _Config;
    history = Get.put<PlaybackHistoryService>(_History()) as _History;
    db.execute('DELETE FROM local_media_progress');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'present') {
            final args = call.arguments as Map;
            requests.add(args);
            final id = args['requestId'] as int;
            return presentations.putIfAbsent(id, Completer<bool>.new).future;
          }
          if (call.method == 'launchDiagnostics') return null;
          return true;
        });
    service = XrImmersiveService(
      localRepository: localRepository,
      resolveVideo: (id) => resolver(id),
      restorePage: returns.add,
    );
    service.onInit();
  });

  tearDown(() async {
    service.onClose();
    for (final queue in queues) {
      queue.dispose();
    }
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> flushChannel() => Future<void>.delayed(Duration.zero);
  Future<bool> present(String id, {List<XrMediaSource> sources = const []}) =>
      service.present(
        url: 'https://example.test/$id.mp4',
        videoId: id,
        sources: sources,
        format: VrSourceFormat.flatMono,
      );

  Future<int> commit(
    String id, {
    List<XrMediaSource> sources = const [],
  }) async {
    final future = present(id, sources: sources);
    await flushChannel();
    final requestId = requests.last['requestId'] as int;
    presentations[requestId]!.complete(true);
    expect(await future, isTrue);
    return requestId;
  }

  Future<dynamic> native(String method, Map<String, Object?> args) {
    final response = Completer<dynamic>();
    TestWidgetsFlutterBinding.instance.channelBuffers.push(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall(method, args)),
      (data) =>
          response.complete(const StandardMethodCodec().decodeEnvelope(data!)),
    );
    return response.future;
  }

  Future<dynamic> ended(
    int requestId,
    String id, {
    bool replaced = false,
    int positionMs = 30000,
    int durationMs = 120000,
  }) => native('immersiveEnded', {
    'requestId': requestId,
    'mediaId': id,
    'videoId': id,
    'replaced': replaced,
    'positionMs': positionMs,
    'durationMs': durationMs,
  });

  _SourceQueue queue(String id, String itemId) {
    final queue = _SourceQueue(
      queueId: id,
      context: InnerPlaylistContext.fromVideos(
        source: InnerPlaylistSource.popularVideoList,
        videos: [
          Video(id: itemId, title: itemId),
          Video(id: '$itemId-next', title: 'next'),
        ],
        currentVideoId: itemId,
      ),
    );
    queues.add(queue);
    return queue;
  }

  void page(PlaybackQueue queue, String itemId) {
    service.queueProvider = () => (
      queues: [queue],
      active: queue,
      currentItemId: itemId,
      author: null,
      adopt: (_) {},
      mediaType: PlaybackMediaType.video,
    );
  }

  test(
    'a pending or failed switch keeps the committed playback identity',
    () async {
      await commit('a');
      final next = present('b');
      await flushChannel();
      final whilePending = service.nowPlayingId;
      presentations[requests.last['requestId']]!.complete(false);
      expect(await next, isFalse);
      expect(whilePending, 'a');
      expect(service.nowPlayingId, 'a');
    },
  );

  test(
    'only a successful native commit replaces the current identity',
    () async {
      await commit('a');
      final next = present('b');
      await flushChannel();
      final whilePending = service.nowPlayingId;
      presentations[requests.last['requestId']]!.complete(true);
      expect(await next, isTrue);
      expect(whilePending, 'a');
      expect(service.nowPlayingId, 'b');
    },
  );

  test(
    'failed switch retains A queue and sources after its page is replaced',
    () async {
      final a = queue('queue-a', 'a');
      final b = queue('queue-b', 'b');
      page(a, 'a');
      final requestA = await commit(
        'a',
        sources: [
          const XrMediaSource(label: '1080', url: 'https://example.test/a.mp4'),
        ],
      );
      expect(a.retained, isTrue);
      page(b, 'b');
      final pending = present('b');
      await flushChannel();
      presentations[requests.last['requestId']]!.complete(false);
      expect(await pending, isFalse);
      await service.pushQueues();
      final playlist =
          calls.lastWhere((call) => call.method == 'setPlaylist').arguments
              as Map;
      expect(playlist['activeQueueId'], 'queue-a');
      expect(playlist['browseQueueId'], 'queue-b');
      expect(playlist['nowPlayingId'], 'a');
      service.queueProvider = null;
      expect(a.retained, isTrue);
      await ended(requestA, 'a');
      expect(returns.single.queueRef!.queueId, 'queue-a');
      expect(returns.single.queueRef!.currentItemId, 'a');
      expect(a.retained, isFalse);
    },
  );

  test(
    'replacement ended arriving before B acknowledgement never navigates to A',
    () async {
      final requestA = await commit('a');
      final pending = present('b');
      await flushChannel();
      await ended(requestA, 'a', replaced: true);
      expect(returns, isEmpty);
      expect(history.saved.single.$1, 'a');
      presentations[requests.last['requestId']]!.complete(true);
      expect(await pending, isTrue);
      expect(service.nowPlayingId, 'b');
    },
  );

  test(
    'late and duplicate ends for the same media cannot end a new presentation',
    () async {
      final first = await commit('a');
      final second = await commit('a');
      final returned = <(String, int, int)>[];
      service.onImmersiveEndedMediaId = 'a';
      service.onImmersiveEnded = (id, pos, duration) =>
          returned.add((id, pos, duration));
      await ended(first, 'a');
      await ended(first, 'a');
      expect(service.nowPlayingId, 'a');
      expect(returned, isEmpty);
      await ended(second, 'a');
      expect(returned, [('a', 30000, 120000)]);
      expect(history.saved, hasLength(2));
      expect(returns, isEmpty);
    },
  );

  test(
    'dismiss keeps identity until its final position is delivered',
    () async {
      final request = await commit('a');
      await service.dismiss();
      expect(service.nowPlayingId, 'a');
      await ended(request, 'a');
      expect(service.nowPlayingId, isNull);
      expect(returns.single.videoId, 'a');
    },
  );

  test(
    'a new presentation prevents navigation after an old history write finishes',
    () async {
      final a = await commit('a');
      history.saveGate = Completer<void>();
      final returning = ended(a, 'a');
      await flushChannel();
      await commit('b');
      history.saveGate!.complete();
      await returning;
      expect(returns, isEmpty);
      expect(service.nowPlayingId, 'b');
    },
  );

  test('an ended event can overtake its present acknowledgement', () async {
    final pending = present('a');
    await flushChannel();
    final id = requests.last['requestId'] as int;
    await ended(id, 'a');
    presentations[id]!.complete(true);
    expect(await pending, isFalse);
    expect(service.nowPlayingId, isNull);
    expect(returns.single.videoId, 'a');
  });

  test(
    'an anonymous file keeps the local directory even without a queue cursor',
    () async {
      final localQueue = LocalLibraryPlaybackQueue(
        queueId: 'local-files',
        repository: localRepository,
      );
      queues.add(localQueue);
      page(localQueue, '');
      final pending = service.present(
        url: 'file:///fixture/anonymous.mp4',
        mediaId: 'local:anonymous',
        localPath: '/fixture/anonymous.mp4',
        format: VrSourceFormat.flatMono,
      );
      await flushChannel();
      presentations[requests.last['requestId']]!.complete(true);
      expect(await pending, isTrue);
      await service.pushQueues();
      final playlist =
          calls.lastWhere((call) => call.method == 'setPlaylist').arguments
              as Map;
      expect(playlist['activeQueueId'], 'local-files');
      expect(playlist['catalog'], isNotNull);
    },
  );

  test(
    'online progress honors the same recording preference as local progress',
    () async {
      final request = await commit('a');
      config.rememberProgress = false;
      await ended(request, 'a');
      expect(history.saved, isEmpty);
      expect(history.deleted, isEmpty);
    },
  );

  test(
    'returning to a downloaded video keeps its task and quality metadata',
    () async {
      DownloadTask task(String quality) => DownloadTask(
        id: 'download-$quality',
        url: 'https://example.test/a-$quality',
        savePath: '/fixture/a-$quality.mp4',
        fileName: 'a-$quality.mp4',
        status: DownloadStatus.completed,
        extData: DownloadTaskExtData(
          type: DownloadTaskExtDataType.video,
          data: VideoDownloadExtData(id: 'a', quality: quality).toJson(),
        ),
      );
      final source = task('Source');
      final smaller = task('1080');
      page(queue('downloads', 'a'), 'a');
      final first = service.present(
        url: 'file:///fixture/a-Source.mp4',
        format: VrSourceFormat.flatMono,
        videoId: 'a',
        mediaId: 'a',
        localPath: source.savePath,
        localTask: source,
        localAllQualityTasks: [source, smaller],
      );
      await flushChannel();
      final requestId = requests.last['requestId'] as int;
      presentations[requestId]!.complete(true);
      expect(await first, isTrue);
      page(queue('queue-b', 'b'), 'b');
      final next = present('b');
      await flushChannel();
      presentations[requests.last['requestId']]!.complete(false);
      expect(await next, isFalse);
      await ended(requestId, 'a');
      expect(returns.single.localTask, same(source));
      expect(returns.single.localAllQualityTasks, [source, smaller]);
      expect(returns.single.videoId, 'a');
      expect(returns.single.queueRef!.currentItemId, 'a');
    },
  );

  Future<int> local({String id = 'local-library-id'}) async {
    final pending = service.present(
      url: 'file:///fixture/video.mp4',
      format: VrSourceFormat.flatMono,
      mediaId: id,
      localLibraryItemId: id,
      localPath: '/fixture/video.mp4',
    );
    await flushChannel();
    final requestId = requests.last['requestId'] as int;
    presentations[requestId]!.complete(true);
    expect(await pending, isTrue);
    return requestId;
  }

  test(
    'local identity and duration round trip without online history or navigation',
    () async {
      const id = 'local-library-id';
      final requestId = await local();
      expect(requests.last['videoId'], '');
      expect(requests.last['mediaId'], id);
      expect(service.nowPlayingId, id);
      final returned = <(String, int, int)>[];
      service.onImmersiveEndedMediaId = id;
      service.onImmersiveEnded = (id, pos, duration) =>
          returned.add((id, pos, duration));
      await ended(requestId, id);
      expect(returned, [(id, 30000, 120000)]);
      expect(localRepository.getProgress(id), (
        positionMs: 30000,
        durationMs: 120000,
        completed: false,
      ));
      expect(history.saved, isEmpty);
      expect(history.deleted, isEmpty);
      expect(returns, isEmpty);
    },
  );

  test(
    'local source refresh and abort keep their media identity on the channel',
    () async {
      final requestId = await local();
      expect(
        await service.updateSources(
          mediaId: 'local-library-id',
          sources: [
            const XrMediaSource(
              label: 'Source',
              url: 'file:///fixture/video.mp4',
              local: true,
            ),
          ],
        ),
        isTrue,
      );
      final update =
          calls.lastWhere((call) => call.method == 'updateSources').arguments
              as Map;
      expect(update['mediaId'], 'local-library-id');
      expect(update['requestId'], requestId);
      expect(update.containsKey('videoId'), isFalse);
      await service.abortSwitch(mediaId: 'another-local-id');
      final abort =
          calls.lastWhere((call) => call.method == 'abortSwitch').arguments
              as Map;
      expect(abort['mediaId'], 'another-local-id');
    },
  );

  test(
    'local progress survives a destroyed page and restores a local route',
    () async {
      final requestId = await local();
      await ended(requestId, 'local-library-id', positionMs: 114000);
      expect(localRepository.getProgress('local-library-id'), (
        positionMs: 0,
        durationMs: 120000,
        completed: true,
      ));
      expect(returns.single.videoId, isNull);
      expect(returns.single.localLibraryItemId, 'local-library-id');
      expect(returns.single.localPath, '/fixture/video.mp4');
      expect(history.saved, isEmpty);
    },
  );

  test(
    'local progress honors privacy and does not mark a short unplayed clip completed',
    () async {
      final first = await local();
      await ended(first, 'local-library-id', positionMs: 0, durationMs: 9000);
      expect(
        localRepository.getProgress('local-library-id')!.completed,
        isFalse,
      );
      config.rememberProgress = false;
      final second = await local(id: 'private-local');
      await ended(second, 'private-local');
      expect(localRepository.getProgress('private-local'), isNull);
      final third = await local(id: 'unknown-duration');
      config.rememberProgress = true;
      await ended(third, 'unknown-duration', durationMs: 0);
      expect(localRepository.getProgress('unknown-duration'), isNull);
    },
  );

  test(
    'orphaned A refreshes all online sources and keeps local quality choices',
    () async {
      final requestId = await commit(
        'a',
        sources: [
          const XrMediaSource(
            label: 'Source',
            url: 'file:///fixture/source.mp4',
            local: true,
          ),
          const XrMediaSource(
            label: '1080',
            url: 'https://example.test/expired',
          ),
        ],
      );
      var wrongPageRefreshes = 0;
      service.onSourceRefreshRequestedMediaId = 'b';
      service.onSourceRefreshRequested = (_) => wrongPageRefreshes++;
      resolver = (id) async => XrPlayableVideo(
        id: id,
        title: '',
        author: '',
        url: 'https://example.test/new-source',
        format: VrSourceFormat.flatMono,
        width: 0,
        height: 0,
        sources: [
          (label: 'Source', url: 'https://example.test/new-source'),
          (label: '1080', url: 'https://example.test/new-1080'),
        ],
      );
      expect(
        await native('sourceExpired', {'videoId': 'a', 'requestId': requestId}),
        isTrue,
      );
      expect(wrongPageRefreshes, 0);
      final update =
          calls.lastWhere((call) => call.method == 'updateSources').arguments
              as Map;
      expect(update['requestId'], requestId);
      final sources = (update['sources'] as List).cast<Map>();
      expect(
        sources.singleWhere((s) => s['label'] == 'Source')['url'],
        'file:///fixture/source.mp4',
      );
      expect(
        sources.singleWhere((s) => s['label'] == '1080')['url'],
        'https://example.test/new-1080',
      );
    },
  );

  test(
    'a refresh completing after the media changes cannot update the new player',
    () async {
      final a = await commit('a');
      final resolution = Completer<XrPlayableVideo?>();
      resolver = (_) => resolution.future;
      final refreshing = native('sourceExpired', {
        'videoId': 'a',
        'requestId': a,
      });
      await flushChannel();
      await commit('b');
      final count = calls
          .where((call) => call.method == 'updateSources')
          .length;
      resolution.complete(
        const XrPlayableVideo(
          id: 'a',
          title: '',
          author: '',
          url: 'https://example.test/a-new',
          format: VrSourceFormat.flatMono,
          width: 0,
          height: 0,
          sources: [(label: 'Source', url: 'https://example.test/a-new')],
        ),
      );
      expect(await refreshing, isFalse);
      expect(
        calls.where((call) => call.method == 'updateSources'),
        hasLength(count),
      );
    },
  );

  test(
    'late success for an older request cannot replace a newer committed media',
    () async {
      final a = present('a');
      await flushChannel();
      final requestA = requests.last['requestId'] as int;
      await commit('b');
      presentations[requestA]!.complete(true);
      expect(await a, isFalse);
      expect(service.nowPlayingId, 'b');
      await ended(requestA, 'a', replaced: true);
      expect(history.saved.single.$1, 'a');
      expect(returns, isEmpty);
    },
  );
}
