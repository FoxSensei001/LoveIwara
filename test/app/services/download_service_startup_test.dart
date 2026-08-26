import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/db/migrations/migration_v17_download_task_conflict_triggers.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

import '../repositories/download_task_repository_test.dart'
    show createDownloadTasksTable, taskWithStatus;

/// 启动恢复语义：上次没跑完的任务一律置为暂停，不自动续传。
///
/// 这条语义直接关系到「杀进程/被系统杀掉之后重开应用会不会偷跑流量」，
/// 靠真机反复复现代价太高，用内存库把它钉死在单测里。
void main() {
  late CommonDatabase db;
  late DownloadTaskRepository repository;
  late DownloadService service;

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    createDownloadTasksTable(db);
    MigrationV17DownloadTaskConflictTriggers.createTriggers(db);
    repository = DownloadTaskRepository(db);
    service = DownloadService(repository: repository);
  });

  tearDown(() {
    db.close();
  });

  test('启动时 downloading 与 pending 一律置为暂停，且不进下载队列', () async {
    await repository.insertTask(
      taskWithStatus('was-downloading', DownloadStatus.downloading),
    );
    await repository.insertTask(
      taskWithStatus('was-pending', DownloadStatus.pending),
    );

    await service.onInit();

    expect(
      (await repository.getTaskById('was-downloading'))!.status,
      DownloadStatus.paused,
    );
    expect(
      (await repository.getTaskById('was-pending'))!.status,
      DownloadStatus.paused,
    );
    expect(service.getQueueIds(), isEmpty, reason: '不应自动续传');
    expect(
      service.store.pausedIds,
      containsAll(['was-downloading', 'was-pending']),
    );
  });

  test('被自动暂停的任务会记进召回名单，供「全部继续」使用', () async {
    await repository.insertTask(
      taskWithStatus('was-downloading', DownloadStatus.downloading),
    );
    // 用户很早以前手动暂停的任务不该混进召回名单
    await repository.insertTask(
      taskWithStatus('manually-paused', DownloadStatus.paused),
    );

    await service.onInit();

    expect(service.restoredPausedIds, ['was-downloading']);
    expect(
      service.store.pausedIds,
      containsAll(['was-downloading', 'manually-paused']),
    );
  });

  test('启动时把暂停与失败任务一并装载进内存真源', () async {
    await repository.insertTask(
      taskWithStatus('paused-one', DownloadStatus.paused),
    );
    await repository.insertTask(
      taskWithStatus('failed-one', DownloadStatus.failed),
    );
    await repository.insertTask(
      taskWithStatus('completed-one', DownloadStatus.completed),
    );

    await service.onInit();

    expect(service.store.pausedIds, ['paused-one']);
    expect(service.store.failedIds, ['failed-one']);
    expect(
      service.store.contains('completed-one'),
      isFalse,
      reason: '已完成任务归 DB 分页的历史区，不进内存',
    );
  });

  group('失败原因分类', () {
    test('超时 / 连接错误 / 5xx 归为可重试的网络类', () {
      expect(
        service.classifyError(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        DownloadErrorType.network,
      );
      expect(
        service.classifyError(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/x'),
              statusCode: 503,
            ),
          ),
        ),
        DownloadErrorType.network,
      );
    });

    test('404 归为资源失效，401/403 归为服务器拒绝', () {
      DioException badResponse(int code) => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: code,
        ),
      );

      expect(
        service.classifyError(badResponse(404)),
        DownloadErrorType.notFound,
      );
      expect(
        service.classifyError(badResponse(403)),
        DownloadErrorType.serverRejected,
      );
    });

    test('取消不算失败原因里的错误', () {
      expect(
        service.classifyError(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.cancel,
          ),
        ),
        DownloadErrorType.cancelled,
      );
    });

    test('磁盘 / 权限 / 占用按 errno 归类', () {
      expect(
        service.classifyError(
          const io.FileSystemException(
            'write failed',
            '/tmp/x',
            io.OSError('No space left on device', 28),
          ),
        ),
        DownloadErrorType.diskFull,
      );
      expect(
        service.classifyError(
          const io.FileSystemException(
            'open failed',
            '/tmp/x',
            io.OSError('Permission denied', 13),
          ),
        ),
        DownloadErrorType.permission,
      );
      expect(
        service.classifyError(
          const io.FileSystemException(
            'delete failed',
            '/tmp/x',
            io.OSError(
              'The process cannot access the file because it is being used by another process',
              32,
            ),
          ),
        ),
        DownloadErrorType.fileInUse,
      );
    });

    test('归不了类的落 unknown，且能与落库字符串互转', () {
      expect(
        service.classifyError(Exception('???')),
        DownloadErrorType.unknown,
      );
      expect(DownloadErrorType.parse(null), DownloadErrorType.unknown);
      expect(DownloadErrorType.parse('diskFull'), DownloadErrorType.diskFull);
      expect(DownloadErrorType.parse('不存在的类型'), DownloadErrorType.unknown);
    });

    test('可重试判定：网络 / 资源失效 / 磁盘 / 占用值得重试，权限与拒绝不值得', () {
      expect(DownloadErrorType.network.isRetriable, isTrue);
      expect(DownloadErrorType.notFound.isRetriable, isTrue);
      expect(DownloadErrorType.serverRejected.isRetriable, isFalse);
      expect(DownloadErrorType.permission.isRetriable, isFalse);
    });
  });

  /// 死链自愈：Iwara 的下载地址会在 expires 还没到期时就 404（资源换了地址）。
  /// 只看 expires 的刷新判断会把这类任务永远钉死在同一个死链上——真机上表现为
  /// 「点多少次重试都是 404，但重新请求视频资源就能拿到能用的新地址」。
  group('死链自愈判定', () {
    test('404 / 410 / 403 都算链接已死，必须强制重新索取地址', () {
      for (final status in const [404, 410, 403, 401]) {
        expect(
          DownloadService.isDeadLinkErrorType(
            service.classifyError(
              DioException(
                requestOptions: RequestOptions(path: '/file/x'),
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: RequestOptions(path: '/file/x'),
                  statusCode: status,
                ),
              ),
            ),
          ),
          isTrue,
          reason: '$status 应触发强制刷新下载链接',
        );
      }
    });

    test('网络 / 磁盘 / 取消不算链接已死，别白跑一趟 API', () {
      for (final type in const [
        DownloadErrorType.network,
        DownloadErrorType.diskFull,
        DownloadErrorType.fileInUse,
        DownloadErrorType.permission,
        DownloadErrorType.cancelled,
        DownloadErrorType.unknown,
      ]) {
        expect(DownloadService.isDeadLinkErrorType(type), isFalse);
      }
    });

    test('只换签名（query / CDN 主机变了）算同一份文件，可以接着续传', () {
      expect(
        DownloadService.isSameRemoteFile(
          'https://d.iwara.tv/file/abc123/preview?expires=100&hash=aaa',
          'https://d.iwara.tv/file/abc123/preview?expires=999&hash=bbb',
        ),
        isTrue,
      );
      expect(
        DownloadService.isSameRemoteFile(
          'https://d.iwara.tv/file/abc123/preview?expires=100&hash=aaa',
          'https://hime.iwara.tv/file/abc123/preview?expires=999&hash=bbb',
        ),
        isTrue,
        reason: 'CDN 换节点不代表换了文件',
      );
    });

    test('path 变了就是另一份文件，半截字节续不上必须删档重下', () {
      expect(
        DownloadService.isSameRemoteFile(
          'https://d.iwara.tv/file/abc123/preview?expires=100',
          'https://d.iwara.tv/file/zzz999/preview?expires=100',
        ),
        isFalse,
      );
      expect(
        DownloadService.isSameRemoteFile(
          'https://d.iwara.tv/file/abc123/preview?expires=100',
          'https://d.iwara.tv/file/abc123/Source?expires=100',
        ),
        isFalse,
      );
      expect(
        DownloadService.isSameRemoteFile('::not a url::', '::not a url::'),
        isTrue,
        reason: '完全相同的字符串不必解析',
      );
      expect(
        DownloadService.isSameRemoteFile(
          'https://d.iwara.tv/file/abc123/preview',
          '',
        ),
        isFalse,
        reason: '解析不出来时宁可重下，也不要把两份文件的字节拼在一起',
      );
    });
  });

  test('失败原因分类能落库并读回', () async {
    final task = taskWithStatus('failed-one', DownloadStatus.failed)
      ..error = 'DioException [connection error]'
      ..errorType = DownloadErrorType.network.name;
    await repository.insertTask(task);

    final loaded = await repository.getTaskById('failed-one');

    expect(loaded!.errorType, DownloadErrorType.network.name);
    expect(DownloadErrorType.parse(loaded.errorType).isRetriable, isTrue);
  });

  test('忽略提示条后召回名单清空', () async {
    await repository.insertTask(
      taskWithStatus('was-pending', DownloadStatus.pending),
    );
    await service.onInit();
    expect(service.restoredPausedIds, isNotEmpty);

    service.dismissRestoredPaused();

    expect(service.restoredPausedIds, isEmpty);
  });
}
