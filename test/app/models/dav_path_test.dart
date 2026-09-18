import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';

void main() {
  group('DavPath', () {
    test('服务端路径与库内形状互转', () {
      expect(
        DavPath.fromServerPath('/video/剧集/EP01 [SBS].mp4'),
        'dav:/video/剧集/EP01 [SBS].mp4',
      );
      expect(DavPath.fromServerPath('/'), 'dav:/');
      expect(DavPath.fromServerPath('video//a/../b.mp4'), 'dav:/video/b.mp4');
      expect(DavPath.toServerPath('dav:/video/a.mp4'), '/video/a.mp4');
      expect(DavPath.toServerPath('dav:/'), '/');
    });

    test('路径运算固定 posix，不受平台分隔符影响', () {
      const file = 'dav:/video/剧集/EP01#1%.mp4';
      expect(DavPath.dirname(file), 'dav:/video/剧集');
      expect(DavPath.basename(file), 'EP01#1%.mp4');
      expect(DavPath.join('dav:/video', '剧集'), 'dav:/video/剧集');
      expect(DavPath.dirname('dav:/a.mp4'), 'dav:/');
      expect(DavPath.isWithin('dav:/video', file), isTrue);
      expect(DavPath.isWithin('dav:/', file), isTrue);
      expect(DavPath.isWithin(file, file), isFalse);
      expect(DavPath.relative('dav:/video', file), '剧集/EP01#1%.mp4');
      expect(DavPath.relative('dav:/video', 'dav:/video'), '');
      expect(DavPath.segments(file), ['video', '剧集', 'EP01#1%.mp4']);
      expect(DavPath.segments('dav:/'), isEmpty);
    });

    test('只认前缀，本地路径与 content:// 都不是', () {
      expect(DavPath.isDav('dav:/a'), isTrue);
      expect(DavPath.isDav('/video/a.mp4'), isFalse);
      expect(DavPath.isDav('content://media/1'), isFalse);
      expect(DavPath.isDav(null), isFalse);
    });

    test('dav 路径在本机永远不存在（防误伤的前提）', () {
      expect(File('dav:/a.mp4').existsSync(), isFalse);
      expect(Directory(DavPath.dirname('dav:/a.mp4')).existsSync(), isFalse);
    });
  });

  group('LocalMediaSource 种类容错', () {
    test('认不出的 kind 落 unknown，绝不落 directory', () {
      final source = LocalMediaSource.fromRow(const {
        'id': 's',
        'kind': 'smb_from_the_future',
        'path': '/',
      });
      expect(source.kind, LocalMediaSourceKind.unknown);
      expect(source.usesLocalFileSystem, isFalse);
    });

    test('webdav 源字段往返', () {
      const source = LocalMediaSource(
        id: 's',
        kind: LocalMediaSourceKind.webdav,
        displayName: 'nas',
        path: 'dav:/video/',
        uri: 'http://192.0.2.1:5005/',
        createdAt: 1,
        remoteState: LocalMediaRemoteState.authFailed,
        tlsFingerprint: 'ab',
      );
      final back = LocalMediaSource.fromRow(source.toRow());
      expect(back.isRemote, isTrue);
      expect(back.usesLocalFileSystem, isFalse);
      expect(back.remoteState, LocalMediaRemoteState.authFailed);
      expect(back.tlsFingerprint, 'ab');
      expect(back.copyWith(remoteState: null).remoteState, isNull);
    });
  });
}
