import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/xr_queue_catalog.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late CommonDatabase db;
  late Directory files;
  late XrQueueCatalog catalog;
  late SourcePlaybackQueue queue;
  const directoryId = 'local:dir:source|';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() async {
    db = sqlite3.openInMemory();
    await MigrationManager(
      migrations: MigrationManager.defaultMigrations()
          .where((migration) => migration.version != 7)
          .toList(),
    ).runMigrations(db);
    files = Directory.systemTemp.createTempSync('xr_catalog_');
    for (final path in [
      'root.mp4',
      'first.png',
      'second.png',
      'Video only/clip.mp4',
      'Image only/photo.png',
    ]) {
      final file = File('${files.path}/$path');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('fixture');
    }
    final repository = LocalMediaRepository(db);
    final source = LocalMediaSource(
      id: 'source',
      kind: LocalMediaSourceKind.directory,
      displayName: 'Mixed media',
      path: files.path,
      createdAt: 0,
    );
    repository.upsertSource(source);
    await LocalMediaScanService(repository: repository).scanSource(source);
    catalog = XrQueueCatalog(onChanged: () {}, localRepository: repository);
    queue = SourcePlaybackQueue(
      queueId: 'source-queue',
      context: InnerPlaylistContext.fromVideos(
        source: InnerPlaylistSource.popularVideoList,
        videos: [Video(id: 'current', title: 'current')],
        currentVideoId: 'current',
      ),
    );
  });

  tearDown(() {
    queue.dispose();
    db.close();
    files.deleteSync(recursive: true);
  });

  XrCatalogNode build(PlaybackMediaType type) => catalog.build(
    queues: [queue],
    browsing: queue,
    currentItemId: 'current',
    author: null,
    playingLocalFile: true,
    mediaType: type,
  );

  XrCatalogNode? find(XrCatalogNode node, String id) {
    if (node.id == id) return node;
    for (final child in node.children ?? <XrCatalogNode>[]) {
      final match = find(child, id);
      if (match != null) return match;
    }
    return null;
  }

  Future<XrCatalogNode> directory(
    PlaybackMediaType type, {
    bool expand = false,
  }) async {
    build(type);
    await catalog.expand('localLibrary');
    build(type);
    await catalog.expand('localLibrary:folders');
    var tree = build(type);
    expect(find(tree, directoryId), isNotNull);
    if (expand) {
      await catalog.expand(directoryId);
      tree = build(type);
    }
    return find(tree, directoryId)!;
  }

  test(
    'video and gallery directory results keep their own children and counts',
    () async {
      final video = await directory(PlaybackMediaType.video, expand: true);
      expect(video.children!.map((node) => node.title), contains('Video only'));
      expect(
        video.children!.map((node) => node.title),
        isNot(contains('Image only')),
      );
      expect(find(video, '$directoryId:here')!.trailing, '1');
      expect((await directory(PlaybackMediaType.gallery)).children, isNull);
      final gallery = await directory(PlaybackMediaType.gallery, expand: true);
      expect(
        gallery.children!.map((node) => node.title),
        contains('Image only'),
      );
      expect(
        gallery.children!.map((node) => node.title),
        isNot(contains('Video only')),
      );
      expect(find(gallery, '$directoryId:here')!.trailing, '2');
      final restored = await directory(PlaybackMediaType.video);
      expect(
        restored.children!.map((node) => node.title),
        contains('Video only'),
      );
      expect(find(restored, '$directoryId:here')!.trailing, '1');
    },
  );

  test('refresh discards an expansion already in flight', () async {
    await directory(PlaybackMediaType.video);
    final pending = catalog.expand(directoryId);
    catalog.invalidate();
    await pending;
    expect((await directory(PlaybackMediaType.video)).children, isNull);
  });

  test('switching media type invalidates an unfinished expansion', () async {
    await directory(PlaybackMediaType.video);
    final pending = catalog.expand(directoryId);
    build(PlaybackMediaType.gallery);
    await pending;
    expect((await directory(PlaybackMediaType.video)).children, isNull);
  });
}
