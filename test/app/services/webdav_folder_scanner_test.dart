import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/webdav/webdav_client.dart';
import 'package:i_iwara/app/services/webdav/webdav_folder_scanner.dart';
import 'package:i_iwara/app/services/webdav/webdav_propfind.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

/// 一台内存里的假 NAS：服务端目录 → 它的直接子项。
class _FakeNas {
  final Map<String, List<DavEntry>> tree = {};
  final List<String> listed = [];
  WebDavFailure? failWith;

  void dir(String path, {int? mtime}) {
    _add(DavEntry(serverPath: path, isDirectory: true, modifiedMs: mtime));
    tree.putIfAbsent(path, () => []);
  }

  void file(String path, {int size = 1, int mtime = 1}) => _add(
    DavEntry(
      serverPath: path,
      isDirectory: false,
      size: size,
      modifiedMs: mtime,
    ),
  );

  void remove(String path) {
    final parent = path.substring(0, path.lastIndexOf('/'));
    tree[parent.isEmpty ? '/' : parent]!.removeWhere(
      (e) => e.serverPath == path,
    );
  }

  void _add(DavEntry entry) {
    final parent = entry.serverPath.substring(
      0,
      entry.serverPath.lastIndexOf('/'),
    );
    tree.putIfAbsent(parent.isEmpty ? '/' : parent, () => []).add(entry);
  }

  Future<List<DavEntry>> list(LocalMediaSource source, String davFolder) async {
    final failure = failWith;
    if (failure != null) throw failure;
    final path = DavPath.toServerPath(davFolder);
    listed.add(path);
    return List.of(tree[path] ?? const []);
  }
}

void main() {
  late LocalMediaRepository repo;
  late _FakeNas nas;
  late WebDavFolderScanner scanner;
  const source = LocalMediaSource(
    id: 'nas1',
    kind: LocalMediaSourceKind.webdav,
    displayName: 'NAS',
    path: 'dav:/',
    uri: 'http://192.0.2.1:5005',
    createdAt: 1,
  );

  String itemId(String serverPath) => LocalMediaItem.buildId(
    source.id,
    LocalMediaItem.hashPath(DavPath.fromServerPath(serverPath)),
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() async {
    final db = sqlite3.openInMemory();
    await MigrationManager(
      migrations: MigrationManager.defaultMigrations()
          .where((m) => m.version != 7)
          .toList(),
    ).runMigrations(db);
    repo = LocalMediaRepository(db);
    repo.upsertSource(source);
    nas = _FakeNas();
    scanner = WebDavFolderScanner(repo, lister: nas.list);

    nas.dir('/番剧', mtime: 10);
    nas.file('/番剧/EP01 [SBS].mp4', size: 100);
    nas.file('/番剧/EP01 [SBS].png');
    nas.file('/番剧/海报.jpg');
    nas.dir('/番剧/S2', mtime: 20);
    nas.file('/番剧/S2/EP01.mkv');
    nas.dir('/.thumbnails', mtime: 1);
    nas.file('/top #1.mp4');
  });

  test('根目录：本层与子目录入库，同名图配对，孙目录只留占位', () async {
    await scanner.scanFolder(source, '');
    final ep = repo.getItem(itemId('/番剧/EP01 [SBS].mp4'))!;
    expect(ep.kind, LocalMediaItemKind.video);
    expect(ep.sidecarImagePath, 'dav:/番剧/EP01 [SBS].png');
    expect(ep.folderPath, 'dav:/番剧');
    expect(
      repo.getItem(itemId('/番剧/EP01 [SBS].png')),
      isNull,
      reason: '同名图不是条目',
    );
    expect(repo.getItem(itemId('/番剧/海报.jpg'))!.kind, LocalMediaItemKind.image);
    expect(repo.getItem(itemId('/top #1.mp4')), isNotNull);
    // 孙目录的文件还没列过。
    expect(repo.getItem(itemId('/番剧/S2/EP01.mkv')), isNull);

    final rootChildren = repo
        .childFolders(
          sourceId: source.id,
          parentRelPath: '',
          includeEmpty: true,
        )
        .map((f) => f.relPath)
        .toList();
    expect(rootChildren, ['番剧'], reason: '`.` 开头的目录跳过');
    final series = repo.getFolder(sourceId: source.id, relPath: '番剧')!;
    expect(series.probedAt, isNotNull);
    expect(series.modifiedAt, 10);
    expect(series.videoCount, 1);
    expect(series.imageCount, 1);
    expect(
      repo.getFolder(sourceId: source.id, relPath: '番剧/S2')!.probedAt,
      isNull,
    );

    final updated = repo.getSource(source.id)!;
    expect(updated.remoteState, LocalMediaRemoteState.ok);
    expect(updated.offline, isFalse);
  });

  test('子目录 mtime 没变就不重探；删掉的文件收敛成 missing', () async {
    await scanner.scanFolder(source, '');
    nas.listed.clear();
    nas.remove('/top #1.mp4');

    await scanner.scanFolder(source, '');
    expect(nas.listed, ['/'], reason: '番剧 探过且 mtime 未变');
    expect(repo.getItem(itemId('/top #1.mp4'))!.missing, isTrue);
    expect(repo.getItem(itemId('/番剧/EP01 [SBS].mp4'))!.missing, isFalse);

    // 子目录里变了东西（mtime 跟着变）→ 重探。
    nas.remove('/番剧/海报.jpg');
    nas.tree['/']!
      ..removeWhere((e) => e.serverPath == '/番剧')
      ..add(
        const DavEntry(serverPath: '/番剧', isDirectory: true, modifiedMs: 11),
      );
    nas.listed.clear();
    await scanner.scanFolder(source, '');
    expect(nas.listed, ['/', '/番剧']);
    expect(repo.getItem(itemId('/番剧/海报.jpg'))!.missing, isTrue);
  });

  test('进入子目录：只动这一层，不碰兄弟和上层', () async {
    await scanner.scanFolder(source, '');
    await scanner.scanFolder(source, '番剧/S2');
    expect(repo.getItem(itemId('/番剧/S2/EP01.mkv'))!.folderPath, 'dav:/番剧/S2');
    expect(repo.getItem(itemId('/top #1.mp4'))!.missing, isFalse);
    expect(repo.getItem(itemId('/番剧/EP01 [SBS].mp4'))!.missing, isFalse);
  });

  test('连不上：整源离线、带原因，库一条不丢', () async {
    await scanner.scanFolder(source, '');
    nas.failWith = const WebDavFailure(WebDavFailureKind.unreachable);

    await scanner.scanFolder(source, '');
    final updated = repo.getSource(source.id)!;
    expect(updated.offline, isTrue);
    expect(updated.remoteState, LocalMediaRemoteState.unreachable);
    expect(repo.getItem(itemId('/top #1.mp4'))!.missing, isFalse);

    nas.failWith = const WebDavFailure(WebDavFailureKind.auth, statusCode: 401);
    await scanner.scanFolder(source, '');
    expect(
      repo.getSource(source.id)!.remoteState,
      LocalMediaRemoteState.authFailed,
    );
  });

  test('NAS 源根为 dav:/ 时不拦本地文件夹', () {
    expect(repo.findOverlappingSource('/'), isNull);
    expect(repo.findOverlappingSource('/Users/someone/Movies'), isNull);
    expect(
      repo.findOverlappingRemoteSource(origin: source.uri!, davPath: 'dav:/番剧'),
      isNotNull,
    );
    expect(
      repo.findOverlappingRemoteSource(
        origin: 'http://192.0.2.2',
        davPath: 'dav:/番剧',
      ),
      isNull,
      reason: '另一台 NAS 的同名路径不是同一个目录',
    );
  });
}
