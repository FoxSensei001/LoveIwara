import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_actions.dart';

DownloadTask _task(
  String id,
  DownloadStatus status, {
  DownloadTaskExtDataType? type,
  Map<String, dynamic>? data,
}) => DownloadTask(
  id: id,
  url: 'https://example.test/$id',
  savePath: '/tmp/$id',
  fileName: id,
  status: status,
  extData: type == null
      ? null
      : DownloadTaskExtData(type: type, data: data ?? const {}),
);

List<DownloadAction> _resolve(
  Set<DownloadTask> tasks, {
  bool desktop = false,
  Set<String> missing = const {},
}) => DownloadActionResolver.resolve(
  tasks,
  isDesktop: desktop,
  isFileMissing: (t) => missing.contains(t.id),
);

void main() {
  test('移动文件到 / 归类到 / 删除对所有状态都开放', () {
    for (final status in DownloadStatus.values) {
      final actions = _resolve({_task('a', status)});
      expect(
        actions,
        containsAll([
          DownloadAction.relocate,
          DownloadAction.categorize,
          DownloadAction.delete,
        ]),
        reason: '$status',
      );
    }
  });

  test('播放控制按状态出现', () {
    expect(
      _resolve({_task('a', DownloadStatus.downloading)}),
      contains(DownloadAction.pause),
    );
    expect(
      _resolve({_task('a', DownloadStatus.pending)}),
      contains(DownloadAction.pause),
    );
    expect(
      _resolve({_task('a', DownloadStatus.paused)}),
      allOf(
        contains(DownloadAction.resume),
        isNot(contains(DownloadAction.pause)),
      ),
    );
    expect(
      _resolve({_task('a', DownloadStatus.failed)}),
      allOf(
        contains(DownloadAction.retry),
        isNot(contains(DownloadAction.open)),
      ),
    );
  });

  test('重新下载只给文件已知不在的已完成任务', () {
    final ok = _task('ok', DownloadStatus.completed);
    final gone = _task('gone', DownloadStatus.completed);
    expect(_resolve({ok}), isNot(contains(DownloadAction.redownload)));
    expect(
      _resolve({gone}, missing: {'gone'}),
      contains(DownloadAction.redownload),
    );
  });

  test('打开 / 用其他应用打开只在单条已完成时出现', () {
    final video = _task(
      'v',
      DownloadStatus.completed,
      type: DownloadTaskExtDataType.video,
      data: {'id': 'vid'},
    );
    final actions = _resolve({video});
    expect(actions.first, DownloadAction.open);
    expect(actions, contains(DownloadAction.openWith));
    expect(actions, contains(DownloadAction.viewOnline));

    final two = _resolve({video, _task('b', DownloadStatus.completed)});
    expect(two, isNot(contains(DownloadAction.open)));
    expect(two, isNot(contains(DownloadAction.detail)));
    expect(two, isNot(contains(DownloadAction.copyLink)));
  });

  test('在文件夹中显示：仅桌面、单条；图库下载中也可以', () {
    final done = _task('a', DownloadStatus.completed);
    expect(_resolve({done}), isNot(contains(DownloadAction.revealInFolder)));
    expect(
      _resolve({done}, desktop: true),
      contains(DownloadAction.revealInFolder),
    );
    final galleryDownloading = _task(
      'g',
      DownloadStatus.downloading,
      type: DownloadTaskExtDataType.gallery,
    );
    expect(
      _resolve({galleryDownloading}, desktop: true),
      contains(DownloadAction.revealInFolder),
    );
    expect(
      _resolve({_task('v', DownloadStatus.downloading)}, desktop: true),
      isNot(contains(DownloadAction.revealInFolder)),
    );
    // 图库没有「复制链接」（它的 url 不是下载地址）。
    expect(
      _resolve({galleryDownloading}),
      isNot(contains(DownloadAction.copyLink)),
    );
  });

  test('批量混选：动作取并集，删除永远在', () {
    final actions = _resolve({
      _task('a', DownloadStatus.paused),
      _task('b', DownloadStatus.failed),
    });
    expect(
      actions.where(DownloadActionResolver.batchCapable.contains),
      containsAll([
        DownloadAction.resume,
        DownloadAction.retry,
        DownloadAction.relocate,
        DownloadAction.categorize,
        DownloadAction.delete,
      ]),
    );
    expect(actions.last, DownloadAction.delete);
  });
}
