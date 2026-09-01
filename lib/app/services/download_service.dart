import 'dart:async';
import 'dart:io';
// 需要与本项目模型里同名的 FileSystemException 区分开：非 SDK 库的同名声明会
// 遮蔽 dart:io 的，判断磁盘 / 权限 / 占用类错误时必须用带前缀的那个。
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download/download_state_log.dart';
import 'package:i_iwara/app/services/download/download_task_store.dart';
import 'package:i_iwara/app/services/download_notification_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path_lib;
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 批量删除结果统计（用于“按日期删除”等耗时批量操作的结果汇总）。
class DeleteTasksResult {
  /// 本次尝试删除的任务总数。
  final int total;

  /// 成功删除（或目标本就不存在被清理）的任务数。
  final int deleted;

  /// 因文件被占用 / 删除目标不安全等原因被跳过（记录保留）的任务数。
  final int skipped;

  const DeleteTasksResult({
    required this.total,
    required this.deleted,
    required this.skipped,
  });
}

/// 任务模型
/// enum DownloadStatus {
///   pending,      // 等待中
///   downloading,  // 下载中
///   paused,       // 暂停
///   completed,    // 完成
///   failed,       // 失败
/// }
class DownloadService extends GetxService {
  static DownloadService get to => Get.find<DownloadService>();

  /// =============================== 对外暴露的接口, 对当前的业务无影响 ===============================

  /// 活跃任务（pending/downloading/paused/failed）的内存单一真源。
  ///
  /// UI 一律从这里读活跃任务，不再各自查库：分区由状态唯一决定，一条任务不可能
  /// 同时出现在两个区；每行只订阅自己的句柄，状态变化只重建那一行。
  /// 已完成任务量大且只读，仍在 DB 分页，通过 [DownloadTaskStore.completedRevision]
  /// 精确失效（见该类的类注释）。
  final DownloadTaskStore store = DownloadTaskStore();

  // 获取所有活跃任务（仅包含下载中的任务）
  Map<String, DownloadTask> get tasks => _activeTasks;

  /// 全部下载分类（含各自的任务计数），以及「未分类」的任务数。
  ///
  /// 这两个是**可观察状态本身**，不是「有变化」的信号：页面直接 `Obx` 读它们，
  /// 不再各自持有一份快照、也不再靠 worker + postFrame 回调去重拉。
  ///
  /// 为什么改：分类此前走的是 `RxInt` 版本号广播 + 页面 `ever()` 订阅 + 帧回调
  /// 里 setState 的链路。这条链有三个环节可能悄悄断掉（订阅挂在被换掉的服务实例
  /// 上、帧回调等不到下一帧、收到广播的 State 不是屏幕上那个），而断掉时没有任何
  /// 报错——表现就是「在管理页新建了分类，返回列表页没有，下拉刷新才出来」。
  /// 换成 Obx 之后这三个环节整体消失：订阅在可见元素 build 时建立，值一变它自己
  /// 重建，不存在中间人。
  final RxList<DownloadCategory> categories = <DownloadCategory>[].obs;
  final RxInt uncategorizedCount = 0.obs;

  /// 从数据库重新装载分类与未分类计数。
  ///
  /// 所有分类写操作（新建 / 改名 / 删除 / 排序 / 移动任务）末尾都会 await 它，
  /// 因此调用方拿到返回值时，可观察状态已经是最新的。
  Future<void> refreshCategories() async {
    try {
      final list = await _repository.getAllCategories();
      final uncategorized = await _repository.getUncategorizedCount();
      categories.assignAll(list);
      uncategorizedCount.value = uncategorized;
      DownloadStateLog.emit(
        this,
        'categories/refreshed',
        detail: '${list.length} 个分类',
      );
    } catch (e) {
      LogUtils.e('加载下载分类失败', tag: 'DownloadService', error: e);
    }
  }

  /// 发布一条任务的最新状态。
  ///
  /// 所有会改变任务状态 / 归属的路径都必须走这里：Store 据此把它放进正确的区、
  /// 只重建对应的那一行；同时留下埋点，出问题时能看出是哪条路径发的、有没有落到 UI。
  void _publishTask(DownloadTask task, String event) {
    store.upsert(task);
    DownloadStateLog.emit(
      this,
      'task/$event',
      taskId: task.id,
      detail: 'status=${task.status.name}',
    );
  }

  /// 发布「一条任务已被删除」。
  void _publishRemovedTask(String taskId, String event) {
    store.remove(taskId);
    DownloadStateLog.emit(this, 'task/$event', taskId: taskId);
  }

  /// 记住的「下载到分类」默认值（'' / 读取失败视为未分类/null）。
  /// 供跳过弹窗的下载路径（单图保存等）沿用上次所选分类。
  String? get stickyDownloadCategoryId {
    try {
      final v =
          Get.find<ConfigService>()[ConfigKey.LAST_DOWNLOAD_CATEGORY_ID]
              as String?;
      return (v == null || v.isEmpty) ? null : v;
    } catch (_) {
      return null;
    }
  }

  /// 允许注入仓储，便于用内存数据库对启动恢复、状态机等做单元测试；
  /// 生产路径不传参，行为与此前完全一致。
  DownloadService({DownloadTaskRepository? repository})
    : _repository = repository ?? DownloadTaskRepository();

  final DownloadTaskRepository _repository;

  /// 已派发「终态通知」（完成/失败）的任务 id 集合，用于去重：
  /// 同一次终态转换只通知一次。当任务重新回到非终态（pending/downloading/
  /// paused）时会从集合移除，从而允许「续传后再次失败」「重下后再次完成」等
  /// 真正的新一次终态再次通知。
  final Set<String> _notifiedTerminalTaskIds = <String>{};

  /// 允许的并发下载数范围
  static const minConcurrentDownloads = 1;
  static const maxConcurrentDownloadsLimit = 5;
  static const defaultConcurrentDownloads = 3;

  /// 最大并发下载数，可在设置中调整（[minConcurrentDownloads]~[maxConcurrentDownloadsLimit]）。
  /// 读取配置失败时回退默认值，保证下载流程不被配置异常阻断。
  int get maxConcurrentDownloads {
    try {
      if (Get.isRegistered<ConfigService>()) {
        final v =
            Get.find<ConfigService>()[ConfigKey.MAX_CONCURRENT_DOWNLOADS]
                as int;
        return v.clamp(minConcurrentDownloads, maxConcurrentDownloadsLimit);
      }
    } catch (e) {
      LogUtils.w('读取最大并发下载数配置失败，使用默认值: $e', 'DownloadService');
    }
    return defaultConcurrentDownloads;
  }

  final dio = Dio()..options.persistentConnection = false;

  DownloadTaskRepository get repository => _repository;

  // 获取图库下载进度
  Map<String, bool>? getGalleryDownloadProgress(String taskId) {
    return _galleryDownloadProgress[taskId];
  }

  // 获取单个图片下载进度
  Map<String, double>? getGalleryImageProgress(String taskId) {
    return _galleryImageProgress[taskId];
  }

  // 获取下载队列的id列表
  List<String> getQueueIds() {
    return _downloadQueue.toList();
  }

  // =============================== 下载分类（自定义文件夹）===============================

  /// 获取所有分类（带任务计数）。
  Future<List<DownloadCategory>> getAllCategories() =>
      _repository.getAllCategories();

  /// 「未分类」任务数量。
  Future<int> getUncategorizedCount() => _repository.getUncategorizedCount();

  /// 新建分类。
  Future<DownloadCategory?> createCategory({
    required String title,
    String? description,
  }) async {
    final category = await _repository.createCategory(
      title: title,
      description: description,
    );
    if (category != null) {
      // 先把可观察状态刷新到最新，再返回：调用方一 await 完就能确信
      // 分类条 / 选择器已经能看到这个新分类了。
      await refreshCategories();
    }
    return category;
  }

  /// 重命名 / 编辑分类。
  Future<bool> updateCategory(
    String id, {
    required String title,
    String? description,
  }) async {
    final ok = await _repository.updateCategory(
      id,
      title: title,
      description: description,
    );
    if (ok) await refreshCategories();
    return ok;
  }

  /// 删除分类（不删文件，任务退回未分类）。
  Future<bool> deleteCategory(String id) async {
    final ok = await _repository.deleteCategory(id);
    if (ok) {
      // 同步内存中活跃任务的 categoryId：被删分类下「正在下载」的任务，其内存
      // 对象仍持有该分类 id；若不清空，下一次整行 updateTask（下载循环每秒触发）
      // 会把悬空 id 重新写回 DB，导致该任务既不在「未分类」也不在任何分类下，
      // 在各分类筛选中均不可见。
      for (final t in _activeTasks.values) {
        if (t.categoryId == id) t.categoryId = null;
      }
      // 活跃任务的分类归属同样要就地清空并刷新对应行；已完成任务在库里，
      // 让历史区重拉即可。
      for (final t in store.activeTasks) {
        if (t.categoryId == id) {
          t.categoryId = null;
          store.touch(t.id);
        }
      }
      store.invalidateCompleted();
      await refreshCategories();
    }
    return ok;
  }

  /// 批量更新分类顺序。
  Future<bool> updateCategoriesOrder(List<String> ids) async {
    final ok = await _repository.updateCategoriesOrder(ids);
    if (ok) await refreshCategories();
    return ok;
  }

  /// 把一批任务归入某分类（categoryId 为 null 表示退回未分类）。
  Future<void> assignTasksToCategory(
    List<String> taskIds,
    String? categoryId,
  ) async {
    if (taskIds.isEmpty) return;
    // 防御：分类可能在「移至分类」弹窗打开期间被删除。若写入一个已不存在的
    // 分类 id 会产生悬空引用（任务在所有分类/未分类筛选下都不可见），这里把
    // 不存在的分类视为「未分类」(null)。
    String? effectiveId = categoryId;
    if (effectiveId != null && !await _repository.categoryExists(effectiveId)) {
      effectiveId = null;
    }
    await _repository.assignTasksToCategory(taskIds, effectiveId);
    // 同步内存中活跃（下载中）任务的 categoryId，避免后续整行 updateTask 把
    // 刚写入的分类覆盖回旧值（窄 UPDATE 只改了 DB，没改内存对象）。
    for (final id in taskIds) {
      final t = _activeTasks[id];
      if (t != null) t.categoryId = effectiveId;
      // Store 里的活跃任务同样就地更新并刷新该行（元数据变更不换区）。
      final stored = store.taskOf(id);
      if (stored != null) {
        stored.categoryId = effectiveId;
        store.touch(id);
      }
    }
    // 被移动的可能是已完成任务，历史区按分类筛选的结果会变，让它重拉。
    store.invalidateCompleted();
    await refreshCategories();
  }

  // =============================== 内部方法 ===============================
  // 活跃任务列表，只包含下载中的任务
  // 活跃任务列表，key是任务的id，value是任务对象，此处是最新的任务信息状态,
  // 当变更内容时，会通知_taskStatusChangedNotifier，用于刷新UI列表数据
  // 理论来说，如果任务的状态发生变更，则应该同步给持久化数据库
  final _activeTasks = <String, DownloadTask>{}.obs;
  // 活跃下载列表，key是任务的id，value是下载任务的CancelToken
  final _activeDownloads = <String, CancelToken>{};
  // 取消后的资源清理 Future，key 是任务 id。
  // 取消（pause/delete）会触发 whenCancel 异步关闭 raf/取消订阅，
  // deleteTask 删除文件前需要 await 它，确保文件句柄已真正释放（尤其 Windows）。
  final _cancelCleanupFutures = <String, Future<void>>{};
  // 下载队列，存储的是任务的id
  final _downloadQueue = <String>[].obs;

  // 任务计时器映射，key是任务的id，value是任务的计时器，用于计时更新任务的下载进度UI
  final _taskTimers = <String, Timer>{};

  // 进度通知器映射，key是任务的id，value是RxInt，用于高频通知单个Item刷新进度
  final _progressTriggers = <String, RxInt>{};
  // 上次通知时间映射，用于节流
  final _lastNotifyTime = <String, int>{};

  // 获取特定任务的进度通知器
  RxInt getProgressTrigger(String taskId) {
    return _progressTriggers.putIfAbsent(taskId, () => 0.obs);
  }

  // 通知进度更新（带节流）
  void _notifyProgress(String taskId) {
    const throttleDuration = 200; // 200ms节流
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastNotifyTime[taskId] ?? 0;

    if (now - lastTime > throttleDuration) {
      _lastNotifyTime[taskId] = now;
      _progressTriggers[taskId]?.value++;
    }
  }

  // 队列处理锁，防止并发调用 _processQueue 导致超过最大并发数
  bool _isProcessingQueue = false;

  // 正在处理中的任务ID集合（用于 loading 状态）
  final _processingTaskIds = <String>{}.obs;

  // 检查任务是否正在处理中（用于 UI 显示 loading）
  bool isTaskProcessing(String taskId) => _processingTaskIds.contains(taskId);

  // =============================== 图库下载相关的字段(图库需要特殊处理，因为它需要下载多个图片而非单个文件) ===============================
  // 图库下载相关的字段, key是任务的id，value是图库下载进度
  final _galleryDownloadProgress = <String, Map<String, bool>>{}.obs;
  // 单个图片下载进度跟踪, key是任务的id，value是单个图片下载进度
  final _galleryImageProgress = <String, Map<String, double>>{}.obs;

  // 更新进度的辅助方法
  void _updateGalleryProgress(String taskId, String imageId, bool downloaded) {
    final progress = Map<String, bool>.from(
      _galleryDownloadProgress[taskId] ?? {},
    );
    progress[imageId] = downloaded;
    _galleryDownloadProgress[taskId] = progress;
  }

  void _updateImageProgress(String taskId, String imageId, double progress) {
    final imageProgress = Map<String, double>.from(
      _galleryImageProgress[taskId] ?? {},
    );
    imageProgress[imageId] = progress;
    _galleryImageProgress[taskId] = imageProgress;
  }

  bool _enqueueTaskId(String taskId) {
    if (_downloadQueue.contains(taskId) ||
        _activeDownloads.containsKey(taskId)) {
      LogUtils.d('任务已在队列或下载中，跳过重复入队: $taskId', 'DownloadService');
      return false;
    }
    _downloadQueue.add(taskId);
    return true;
  }

  bool _galleryImageExists(GalleryDownloadExtData galleryData, String imageId) {
    final localPath = galleryData.localPaths[imageId];
    return localPath != null && File(localPath).existsSync();
  }

  int _countDownloadedGalleryImages(GalleryDownloadExtData galleryData) {
    return galleryData.imageList.keys
        .where((imageId) => _galleryImageExists(galleryData, imageId))
        .length;
  }

  void _syncGalleryProgressFromData(
    String taskId,
    GalleryDownloadExtData galleryData,
  ) {
    final previousImageProgress = _galleryImageProgress[taskId] ?? {};
    _galleryDownloadProgress[taskId] = {
      for (final imageId in galleryData.imageList.keys)
        imageId: _galleryImageExists(galleryData, imageId),
    };
    _galleryImageProgress[taskId] = {
      for (final imageId in galleryData.imageList.keys)
        imageId: _galleryImageExists(galleryData, imageId)
            ? 1.0
            : previousImageProgress[imageId] ?? 0.0,
    };
  }

  void _refreshGalleryTaskProgress(
    DownloadTask task,
    GalleryDownloadExtData galleryData,
  ) {
    _syncGalleryProgressFromData(task.id, galleryData);
    task.totalBytes = galleryData.imageList.length;
    task.downloadedBytes = _countDownloadedGalleryImages(galleryData);
  }

  static String _safeExtensionFromUrl(String url) {
    String extension = '';
    try {
      extension = path_lib.extension(Uri.parse(url).path);
    } catch (_) {
      extension = path_lib.extension(url.split('?').first);
    }

    if (!RegExp(r'^\.[A-Za-z0-9]{1,10}$').hasMatch(extension)) {
      return '.jpg';
    }
    return extension;
  }

  static String buildGalleryImageSavePath({
    required String galleryDirectory,
    required String imageId,
    required String url,
  }) {
    final fileName =
        '${FilenameTemplateService.sanitizePathSegment(imageId, fallback: 'image')}${_safeExtensionFromUrl(url)}';
    return DownloadPathService.safeJoinUnderBase(galleryDirectory, [fileName]);
  }

  // =============================== 初始化 ===============================
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadActiveTasks();
  }

  // =============================== 加载活跃任务 ===============================
  /// 启动时把**全部活跃任务**（downloading / pending / paused / failed）装载进
  /// [store]，并把可跑的任务重新入队。
  ///
  /// 注意与旧实现的差别：旧实现只捞 downloading + pending（因为内存里只留下载中
  /// 的任务），暂停与失败的任务完全不进内存，UI 只能自己查库——这正是「暂停后那条
  /// 任务跑到分页历史区里去了、状态还对不上」的来源。现在活跃任务一律常驻内存，
  /// 分区由状态唯一决定。
  Future<void> _loadActiveTasks() async {
    try {
      // 暂停 / 失败的任务不参与队列，但同样属于活跃区，必须进内存真源。
      // 必须在下面把 downloading/pending 改写成 paused **之前**查，否则会把它们
      // 重复读进来。
      final paused = await _repository.getAllTasksByStatus(
        DownloadStatus.paused,
      );
      final failed = await _repository.getAllTasksByStatus(
        DownloadStatus.failed,
      );

      // 拉取所有 downloading + pending 任务，按创建时间升序
      final queueTasks = await _repository
          .getDownloadingAndPendingTasksOrderByCreatedAtAsc();

      // 启动语义：上次没跑完的任务（downloading + pending）一律置为 paused，
      // 不自动续传。
      //
      // 旧行为是自动接着跑：进程被系统杀死（LMK/OOM）或用户杀掉 App 之后一开应用
      // 就在用户毫不知情的情况下动用移动数据；而且续传依赖的「已写字节数是否可信」
      // 在这条路径上从未被验证过，恢复出错就是一个损坏的文件。改为全部暂停 +
      // 顶部一键继续，把决定权交回用户。
      final restoredIds = <String>[];
      for (var task in queueTasks) {
        await _repository.updateTaskStatusById(task.id, DownloadStatus.paused);
        task.status = DownloadStatus.paused;
        restoredIds.add(task.id);
      }

      store.hydrate([...paused, ...failed, ...queueTasks]);
      _restoredPausedIds.assignAll(restoredIds);
      await refreshCategories();

      LogUtils.d(
        '启动恢复：${restoredIds.length} 个未完成任务已置为暂停, '
            '${paused.length} 个原暂停任务, ${failed.length} 个失败任务',
        'DownloadService',
      );
    } catch (e) {
      LogUtils.e('加载下载任务失败', error: e);
      _showMessage(slang.t.download.errors.failedToLoadTasks, Colors.red);
    }
  }

  /// 本次启动时被自动置为暂停的任务 id（上次退出时还没下完的那些）。
  ///
  /// 列表页据此显示「上次有 N 个任务未完成 · 全部继续」的提示条：全部暂停之后如果
  /// 没有一键召回，用户下了 30 条就要手点 30 次，这个提示条是上面那条启动语义的
  /// 必要配套，不是装饰。
  final _restoredPausedIds = <String>[].obs;
  RxList<String> get restoredPausedIds => _restoredPausedIds;

  /// 继续「启动时被自动暂停」的那些任务。
  ///
  /// 刻意不复用 [resumeAll]：那会把用户很久以前手动暂停的任务也一并叫醒，
  /// 而提示条上写的是「上次未完成的 N 个」，行为必须与文案一致。
  Future<void> resumeRestoredTasks() async {
    final ids = List<String>.from(_restoredPausedIds);
    _restoredPausedIds.clear();
    for (final id in ids) {
      await resumeTask(id);
    }
  }

  /// 用户忽略「上次未完成」提示条。
  void dismissRestoredPaused() => _restoredPausedIds.clear();

  // 获取内存中的活跃任务
  DownloadTask? getMemoryActiveTaskById(String taskId) {
    return _activeTasks[taskId];
  }

  // 获取数据库中的活跃任务
  Future<DownloadTask?> getDatabaseActiveTaskById(String taskId) async {
    return await _repository.getTaskById(taskId);
  }

  // 添加任务
  Future<void> addTask(DownloadTask task) async {
    LogUtils.d('添加任务: ${task.id}', 'DownloadService');

    final requestedSavePath = CommonUtils.formatSavePathUriByPath(
      task.savePath,
    );
    task.savePath = requestedSavePath;
    try {
      // 自动补全媒体索引字段，便于后续通过 media_type/media_id/quality 做高效查询
      try {
        final ext = task.extData;
        if (ext != null) {
          if (ext.type == DownloadTaskExtDataType.video) {
            final videoData = VideoDownloadExtData.fromJson(ext.data);
            task.mediaType ??= 'video';
            task.mediaId ??= videoData.id;
            task.quality ??= videoData.quality;
          } else if (ext.type == DownloadTaskExtDataType.gallery) {
            final galleryData = GalleryDownloadExtData.fromJson(ext.data);
            task.mediaType ??= 'gallery';
            task.mediaId ??= galleryData.id;
            // 图库任务目前不区分 quality，保持为 null
          }
        }
      } catch (e) {
        LogUtils.w('自动填充下载任务媒体索引字段失败: $e', 'DownloadService');
      }

      task.savePath = await _resolveUniqueTaskSavePath(task, requestedSavePath);

      task.status = DownloadStatus.pending;
      await _insertTaskWithSavePathRetry(task, requestedSavePath);

      _enqueueTaskId(task.id);
      // 新任务立刻进内存真源：列表页据此立即多出一行，不必等任何广播或重进页面。
      _publishTask(task, 'added');

      LogUtils.i('添加下载任务: ${task.fileName}', 'DownloadService');
      _processQueue();
    } on DuplicateDownloadTaskException catch (e) {
      final message = switch (e.type) {
        DownloadTaskConflictType.media =>
          slang.t.download.errors.downloadTaskAlreadyExists,
        DownloadTaskConflictType.savePath =>
          slang.t.download.errors.downloadTaskSavePathConflict,
        DownloadTaskConflictType.id =>
          slang.t.download.errors.downloadFailedForMessage(
            errorInfo: _getErrorMessage(e),
          ),
      };
      _showMessage(message, Colors.orange);
      throw Exception(message);
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'DownloadService', error: e);
      _showMessage(
        slang.t.download.errors.downloadFailedForMessage(
          errorInfo: _getErrorMessage(e),
        ),
        Colors.red,
      );
      rethrow;
    }
  }

  bool _taskUsesDirectorySavePath(DownloadTask task) {
    return task.extData?.type == DownloadTaskExtDataType.gallery;
  }

  Future<String> _resolveUniqueTaskSavePath(
    DownloadTask task,
    String requestedSavePath,
  ) {
    return DownloadPathService.resolveAvailablePath(
      requestedSavePath,
      isDirectory: _taskUsesDirectorySavePath(task),
      isReserved: (candidate) {
        final normalized = CommonUtils.formatSavePathUriByPath(candidate);
        return _repository.existsTaskBySavePath(normalized);
      },
    );
  }

  Future<void> _insertTaskWithSavePathRetry(
    DownloadTask task,
    String requestedSavePath,
  ) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _repository.insertTask(task);
        return;
      } on DuplicateDownloadTaskException catch (e) {
        if (e.type == DownloadTaskConflictType.savePath && attempt < 2) {
          task.savePath = await _resolveUniqueTaskSavePath(
            task,
            requestedSavePath,
          );
          continue;
        }
        rethrow;
      }
    }
  }

  /// 暂停任务。
  ///
  /// 走**乐观更新**：先把状态落进内存真源让那一行立刻变成「暂停」，再去写库、取消
  /// 连接、等资源释放。这一段慢活加起来可能几百毫秒（取消清理本身就有 500ms 兜底），
  /// 若等它跑完再改 UI，用户看到的就是「点了没反应」。任一步失败则回滚状态并提示。
  Future<void> pauseTask(String taskId) async {
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    LogUtils.d('暂停任务: $taskId', 'DownloadService');

    DownloadTask? task;
    DownloadStatus? previousStatus;
    try {
      // 优先取 Store 里的实例：它就是 UI 正在显示的那个对象，就地改状态 + upsert
      // 才能保证「点暂停 → 那一行立刻变」；退化路径才回落到内存队列 / 数据库。
      task =
          store.taskOf(taskId) ??
          _activeTasks[taskId] ??
          await _repository.getTaskById(taskId);
      if (task == null) {
        LogUtils.d('任务不存在: $taskId', 'DownloadService');
        return;
      }

      previousStatus = task.status;
      task.status = DownloadStatus.paused;
      // 乐观更新：先让 UI 变，再干慢活。
      _publishTask(task, 'paused');

      // [持久化]
      await _repository.updateTask(task);

      // 清理内存前先判断是否真有进行中的下载，供取消等待判断是否需要兜底延时。
      final hadActiveDownload = _activeDownloads.containsKey(taskId);

      // 从内存/队列中移除、取消下载、移除计时器
      _clearMemoryTask(taskId, '用户暂停下载');
      await _waitForCancelCleanup(taskId, hadActiveDownload: hadActiveDownload);

      // 处理等待队列中的下一个任务
      _processQueue();
    } catch (e) {
      LogUtils.e('暂停任务失败: $taskId', tag: 'DownloadService', error: e);
      // 回滚乐观更新：状态没能落库就不能让 UI 停在「暂停」上，否则界面与库不一致，
      // 重进页面又会变回去——正是这类「显示的和实际的不一样」的来源。
      if (task != null && previousStatus != null) {
        task.status = previousStatus;
        _publishTask(task, 'pauseRolledBack');
      }
      _showMessage(slang.t.errors.failedToOperate, Colors.red);
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  /// 恢复任务。
  ///
  /// 同样走乐观更新：视频任务恢复前要先联网校验链接是否还有效（[refreshVideoTask]，
  /// 可能耗时数秒），不先把状态改成「等待中」的话，这几秒里界面完全没有反应。
  Future<void> resumeTask(String taskId) async {
    // 防止重复点击
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    DownloadTask? optimisticTask;
    DownloadStatus? previousStatus;
    try {
      LogUtils.d('恢复任务: $taskId', 'DownloadService');
      // 优先取内存真源里的实例（UI 正显示的那个），退化到数据库
      DownloadTask? task =
          store.taskOf(taskId) ?? await _repository.getTaskById(taskId);
      if (task == null) {
        LogUtils.d('任务不存在于数据库，无法恢复: $taskId', 'DownloadService');
        _showMessage(slang.t.download.errors.taskNotFound, Colors.red);
        return;
      }

      if (task.status == DownloadStatus.paused ||
          task.status == DownloadStatus.failed) {
        LogUtils.d('任务状态为暂停或失败，需要验证链接有效性: $taskId', 'DownloadService');
        // 乐观更新：先进等待区，联网校验在后台继续。
        optimisticTask = task;
        previousStatus = task.status;
        task.status = DownloadStatus.pending;
        _publishTask(task, 'resuming');
        // 如果是视频任务，需要验证链接有效性
        if (task.extData?.type == DownloadTaskExtDataType.video) {
          DownloadTask? newTask = await refreshVideoTask(task);
          if (newTask != null) {
            LogUtils.d('刷新视频任务成功: $taskId', 'DownloadService');
            newTask.status = DownloadStatus.pending;
            task = newTask;
            await _repository.updateTask(newTask); // [更新持久化信息]
          } else {
            _showMessage(
              slang.t.download.errors.canNotRefreshVideoTask,
              Colors.red,
            );
            // 让任务变为失败状态，并记录错误信息
            task.status = DownloadStatus.failed;
            task.error = slang.t.download.errors.canNotRefreshVideoTask;
            // 链接刷新不出来，基本等于资源已被删除 / 权限变更。
            task.errorType = DownloadErrorType.notFound.name;
            await _repository.updateTask(task); // [更新持久化信息]
            // 此路径不经过 _updateTaskStatus，需显式派发终态通知。
            await _dispatchTerminalNotification(task);
            _clearMemoryTask(taskId, '刷新视频任务失败，无法处理');
            // 续传失败也是一次状态变更：不发布的话，这一行会一直停在「暂停」，
            // 用户点了继续却毫无反应，必须重进页面才看到它其实已经失败了。
            _publishTask(task, 'resumeRefreshFailed');
            LogUtils.d('刷新视频任务失败，无法处理: $taskId', 'DownloadService');
            return;
          }
        } else {
          task.status = DownloadStatus.pending;
          await _repository.updateTask(task);
        }

        // 重新回到等待队列，解除终态通知去重，允许后续真正的新终态再次通知。
        _notifiedTerminalTaskIds.remove(taskId);
        // 仅将任务 id 加入等待队列，pending 任务不常驻内存
        _enqueueTaskId(taskId);

        // 通知任务状态变更
        _publishTask(task, 'resumed');

        _processQueue();
      }
    } catch (e) {
      LogUtils.e('恢复任务失败: $taskId', tag: 'DownloadService', error: e);
      // 回滚乐观更新，避免界面停在「等待中」而库里其实还是暂停 / 失败。
      if (optimisticTask != null && previousStatus != null) {
        optimisticTask.status = previousStatus;
        _publishTask(optimisticTask, 'resumeRolledBack');
      }
      _showMessage(slang.t.errors.failedToOperate, Colors.red);
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  /// 全部暂停：暂停所有「下载中」+「等待中」的任务
  Future<void> pauseAll() async {
    LogUtils.i('全部暂停', 'DownloadService');
    final ids = <String>{};
    ids.addAll(_activeTasks.keys);
    ids.addAll(_downloadQueue);
    try {
      final tasks = await _repository
          .getDownloadingAndPendingTasksOrderByCreatedAtAsc();
      ids.addAll(tasks.map((t) => t.id));
    } catch (e) {
      LogUtils.w('全部暂停时获取待暂停任务失败: $e', 'DownloadService');
    }
    for (final id in ids) {
      await pauseTask(id);
    }
  }

  /// 全部开始：恢复所有「已暂停」的任务
  Future<void> resumeAll() async {
    LogUtils.i('全部开始', 'DownloadService');
    try {
      final paused = await _repository.getAllTasksByStatus(
        DownloadStatus.paused,
      );
      for (final task in paused) {
        await resumeTask(task.id);
      }
    } catch (e) {
      LogUtils.w('全部开始失败: $e', 'DownloadService');
    }
  }

  void _clearMemoryTask(String taskId, String message) {
    // 从内存中移除
    _activeTasks.remove(taskId);
    _downloadQueue.remove(taskId);
    // 取消下载
    _activeDownloads[taskId]?.cancel(message);
    _activeDownloads.remove(taskId);
    // 移除计时器和进度追踪器
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);
    // 释放终态通知去重令牌：删除/暂停等清理后，集合不再无界增长；任务若再次
    // 进入终态（如重下）会被当作一次新的终态正常通知。
    _notifiedTerminalTaskIds.remove(taskId);
    // 不立即移除 _progressTriggers，因为 UI 可能还在监听，让它自然回收或在适当时候清理
  }

  /// 等待被取消任务的资源（文件句柄/订阅）真正释放后再返回。
  ///
  /// [hadActiveDownload] 表示调用方在清理内存前该任务确有进行中的下载。
  /// 若任务原本就处于 pending/已暂停（没有 dio/stream 在跑），则无需等待，
  /// 直接返回，避免对图库等无清理回调的任务白等 500ms。
  Future<void> _waitForCancelCleanup(
    String taskId, {
    required bool hadActiveDownload,
  }) async {
    if (!hadActiveDownload) return;

    for (var i = 0; i < 3; i++) {
      final cleanup = _cancelCleanupFutures[taskId];
      if (cleanup != null) {
        try {
          await cleanup;
        } catch (_) {}
        return;
      }
      await Future<void>.delayed(Duration.zero);
    }

    // 图库下载没有 RandomAccessFile 清理回调；视频回调若尚未注册，也给
    // dio/stream 取消路径一个短暂窗口，避免立即重启或删除同一路径。
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  static String _deleteComparisonPath(String rawPath) {
    final normalized = path_lib.normalize(path_lib.absolute(rawPath));
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static bool _sameDeletePath(String left, String right) {
    return _deleteComparisonPath(left) == _deleteComparisonPath(right);
  }

  /// 用户主目录：*nix 走 HOME，Windows 走 USERPROFILE（Windows 上通常没有 HOME）。
  static String? get _userHomeDirectory {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) return home;
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null && userProfile.isNotEmpty) return userProfile;
    return null;
  }

  static bool _isProtectedRecursiveDeletePath(String targetPath) {
    final protectedPaths = <String>[
      path_lib.separator,
      // 文件系统根（含 Windows 盘符根，如 C:\）也视为受保护，避免误删整个磁盘。
      path_lib.rootPrefix(targetPath),
      if (_userHomeDirectory case final home?) ...[
        home,
        path_lib.join(home, 'Desktop'),
        path_lib.join(home, 'Documents'),
        path_lib.join(home, 'Downloads'),
        path_lib.join(home, 'Pictures'),
        path_lib.join(home, 'Movies'),
        path_lib.join(home, 'Music'),
      ],
    ];

    return protectedPaths.any((protectedPath) {
      return protectedPath.isNotEmpty &&
          _sameDeletePath(targetPath, protectedPath);
    });
  }

  static bool isSafeDeleteTarget(
    String rawPath,
    FileSystemEntityType entityType,
  ) {
    if (rawPath.trim().isEmpty) return false;

    final targetPath = _deleteComparisonPath(rawPath);
    final basename = path_lib.basename(targetPath);
    if (basename.isEmpty || basename == '.' || basename == '..') {
      return false;
    }

    final parent = path_lib.dirname(targetPath);
    if (parent == targetPath) return false;

    if (entityType == FileSystemEntityType.directory &&
        _isProtectedRecursiveDeletePath(targetPath)) {
      return false;
    }

    return true;
  }

  Future<List<String>> _knownDownloadRoots() async {
    final roots = <String>[];

    try {
      final defaultDir = await CommonUtils.getAppDirectory(
        pathSuffix: 'downloads',
      );
      roots.add(defaultDir.path);
    } catch (e) {
      LogUtils.w('获取默认下载根目录失败: $e', 'DownloadService');
    }

    try {
      if (Get.isRegistered<ConfigService>()) {
        final configService = Get.find<ConfigService>();
        final isCustomPathEnabled =
            configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
        final customPath =
            configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
        if (isCustomPathEnabled && customPath.trim().isNotEmpty) {
          roots.add(customPath);
        }
      }
    } catch (e) {
      LogUtils.w('获取自定义下载根目录失败: $e', 'DownloadService');
    }

    return roots.toSet().toList();
  }

  Future<bool> _isSafeDeleteTargetForTask(
    DownloadTask task,
    FileSystemEntityType entityType,
  ) async {
    if (!isSafeDeleteTarget(task.savePath, entityType)) return false;
    if (entityType != FileSystemEntityType.directory) return true;

    final roots = await _knownDownloadRoots();
    if (roots.isEmpty) return true;

    return roots.any((root) {
      return DownloadPathService.isPathInsideBase(root, task.savePath);
    });
  }

  // 删除任务
  // 此任务可能在内存中，也可能在数据库中，需要先从内存中获取，如果获取不到，则从数据库中获取
  //
  // 返回值：true 表示任务记录已被移除（删除成功，或目标本就不存在 / 文件已丢失被清理）；
  // false 表示因文件被占用、删除目标不安全等原因未能删除（任务记录仍保留）。
  // [silent] 为 true 时不弹出任何 toast（用于批量删除，避免逐条刷屏）。
  // [notify] 为 true 时在删除成功后递增状态版本触发 UI 刷新；批量删除可置 false，
  // 由调用方在结束后统一刷新一次，避免长任务期间反复重载列表。
  Future<bool> deleteTask(
    String taskId, {
    bool ignoreFileDeleteError = false,
    bool silent = false,
    bool notify = true,
  }) async {
    // 防止重复删除
    if (_processingTaskIds.contains(taskId)) {
      return false;
    }
    _processingTaskIds.add(taskId);

    try {
      LogUtils.i('开始删除下载任务: $taskId', 'DownloadService');
      DownloadTask? task;
      // 获取任务信息
      task =
          store.taskOf(taskId) ??
          _activeTasks[taskId] ??
          await _repository.getTaskById(taskId);

      // 如果内存和数据库中都没有任务信息，则视为已删除（可能已被并发删除）
      if (task == null) {
        LogUtils.w('任务不存在，视为已删除: $taskId', 'DownloadService');
        if (!silent) {
          _showMessage(slang.t.download.errors.taskNotFound, Colors.red);
        }
        // 防止内存问题，清理内存中的信息
        _clearMemoryTask(taskId, '任务不存在时的清理');
        // 库里已经没有它了，内存真源也必须跟着清掉，否则这一行会一直挂在列表上
        // 直到下次启动（这条路径此前直接 return，是「删了还在」的残留来源之一）。
        _publishRemovedTask(taskId, 'removedMissing');
        return true;
      }

      // 如果任务正在下载中，先取消下载并等待资源释放
      if (task.status == DownloadStatus.downloading ||
          _activeDownloads.containsKey(taskId)) {
        LogUtils.d('任务正在下载中，先取消下载: $taskId', 'DownloadService');
        _clearMemoryTask(taskId, '删除任务前取消下载');
        // 等待 whenCancel 真正关闭文件句柄/取消订阅再删文件，避免「句柄未释放」
        // 导致删除失败（Windows 上尤为明显）。拿不到清理 Future 时退回短延时兜底。
        await _waitForCancelCleanup(taskId, hadActiveDownload: true);
      }

      // 尝试删除文件，支持重试
      bool isDeleteSuccess = false;
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 300);
      final deleteTargetType = FileSystemEntity.typeSync(task.savePath);

      if (!await _isSafeDeleteTargetForTask(task, deleteTargetType)) {
        LogUtils.e('拒绝删除不安全的下载目标: ${task.savePath}', tag: 'DownloadService');
        if (!ignoreFileDeleteError) {
          if (!silent) {
            _showMessage(slang.t.download.errors.deleteFileError, Colors.red);
          }
          return false;
        }
        isDeleteSuccess = true;
      }

      while (!isDeleteSuccess && retryCount < maxRetries) {
        final fileOrDir = FileSystemEntity.typeSync(task.savePath);

        if (fileOrDir == FileSystemEntityType.notFound) {
          // 目标不存在，视为已删除
          LogUtils.w('目标不存在，无需删除: ${task.savePath}', 'DownloadService');
          isDeleteSuccess = true;
        } else if (fileOrDir == FileSystemEntityType.directory) {
          // 如果是文件夹则删除整个文件夹
          final dir = Directory(task.savePath);
          if (await dir.exists()) {
            try {
              await dir.delete(recursive: true);
              LogUtils.d('已删除文件夹: ${task.savePath}', 'DownloadService');
              isDeleteSuccess = true;
            } catch (e) {
              // 若并发导致此时目录已不存在，也视为成功
              if (!await dir.exists()) {
                LogUtils.w('删除时目录已不存在: ${task.savePath}', 'DownloadService');
                isDeleteSuccess = true;
              } else {
                LogUtils.e(
                  '删除文件夹失败，可能被占用: ${task.savePath} (重试 $retryCount/$maxRetries)',
                  tag: 'DownloadService',
                  error: e,
                );
                if (retryCount < maxRetries - 1) {
                  retryCount++;
                  await Future.delayed(retryDelay);
                } else {
                  retryCount++;
                }
              }
            }
          } else {
            // 不存在也当做成功
            LogUtils.w('目录不存在，无需删除: ${task.savePath}', 'DownloadService');
            isDeleteSuccess = true;
          }
        } else {
          // 如果是文件则删除文件（包含符号链接等情况）
          final file = File(task.savePath);
          if (await file.exists()) {
            try {
              await file.delete();
              LogUtils.d('已删除文件: ${task.savePath}', 'DownloadService');
              isDeleteSuccess = true;
            } catch (e) {
              // 若并发导致此时文件已不存在，也视为成功
              if (!await file.exists()) {
                LogUtils.w('删除时文件已不存在: ${task.savePath}', 'DownloadService');
                isDeleteSuccess = true;
              } else {
                LogUtils.e(
                  '删除文件失败，可能被占用: ${task.savePath} (重试 $retryCount/$maxRetries)',
                  tag: 'DownloadService',
                  error: e,
                );
                if (retryCount < maxRetries - 1) {
                  retryCount++;
                  await Future.delayed(retryDelay);
                } else {
                  retryCount++;
                }
              }
            }
          } else {
            // 不存在也当做成功
            LogUtils.w('文件不存在，无需删除: ${task.savePath}', 'DownloadService');
            isDeleteSuccess = true;
          }
        }
      }

      if (!isDeleteSuccess && !ignoreFileDeleteError) {
        LogUtils.e('删除文件失败: ${task.savePath}', tag: 'DownloadService');
        if (!silent) {
          _showMessage(slang.t.download.errors.deleteFileError, Colors.red);
        }
        return false;
      }

      // 从数据库删除任务记录
      await _repository.deleteTask(taskId);

      _clearMemoryTask(taskId, '任务已删除');

      // 从内存真源里移除：活跃区那一行立刻消失；若删的是已完成任务，
      // Store 会让历史区精确失效重拉。批量删除时由调用方统一收口（notify=false）。
      if (notify) {
        _publishRemovedTask(taskId, 'removed');
      }
      return true;
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  // 批量删除任务
  Future<void> deleteTasks(
    List<String> taskIds, {
    bool ignoreFileDeleteError = false,
  }) async {
    final removed = <String>[];
    for (final taskId in taskIds) {
      final ok = await deleteTask(
        taskId,
        ignoreFileDeleteError: ignoreFileDeleteError,
        notify: false,
      );
      if (ok) removed.add(taskId);
    }
    // 统一从内存真源移除一次，列表相应的行随之消失（滚动位置不受影响）。
    if (removed.isNotEmpty) {
      store.removeAll(removed);
      DownloadStateLog.emit(
        this,
        'task/removedBatch',
        detail: '${removed.length} 条',
      );
    }
  }

  /// 带进度的批量删除（用于“按日期删除”等耗时批量操作）。
  ///
  /// 逐个删除并通过 [onProgress] 回报进度 `(已处理, 总数)`。删除过程中：
  /// - 文件已不存在但状态未更新的任务：[deleteTask] 会将“目标不存在”视为成功并清理记录；
  /// - 文件被其他进程占用 / 删除目标不安全的任务：跳过并计入 [DeleteTasksResult.skipped]，
  ///   任务记录保留，避免产生“记录已删但文件残留”的孤儿文件。
  ///
  /// 为避免长时间操作期间反复触发列表重载，单条删除不发通知（notify=false），
  /// 全部完成后统一递增一次状态版本触发刷新。
  Future<DeleteTasksResult> deleteTasksWithProgress(
    List<DownloadTask> tasks, {
    void Function(int done, int total)? onProgress,
    bool ignoreFileDeleteError = false,
  }) async {
    final total = tasks.length;
    int deleted = 0;
    int skipped = 0;
    final removedIds = <String>[];

    onProgress?.call(0, total);
    for (var i = 0; i < tasks.length; i++) {
      bool ok;
      try {
        ok = await deleteTask(
          tasks[i].id,
          ignoreFileDeleteError: ignoreFileDeleteError,
          silent: true,
          notify: false,
        );
      } catch (e) {
        ok = false;
        LogUtils.e(
          '按日期批量删除单个任务失败: ${tasks[i].id}',
          tag: 'DownloadService',
          error: e,
        );
      }
      if (ok) {
        deleted++;
        removedIds.add(tasks[i].id);
      } else {
        skipped++;
      }
      onProgress?.call(i + 1, total);
    }

    // 统一从内存真源移除一次。只移除真正删掉的那些——被占用而跳过的任务记录仍在
    // 库里，把它们一并移出内存会让这些行凭空消失，直到下次启动才回来。
    if (total > 0) {
      store.removeAll(removedIds);
      // 即使全部跳过也让历史区重拉，便于回收“文件已丢失”被清理的项。
      store.invalidateCompleted();
      DownloadStateLog.emit(
        this,
        'task/deletedByDate',
        detail: '删除 $deleted / 跳过 $skipped',
      );
    }

    return DeleteTasksResult(total: total, deleted: deleted, skipped: skipped);
  }

  /// 外部（如设置页调高并发数后）主动触发队列检查，立即启动更多等待中任务。
  void kickQueue() => _processQueue();

  // 处理下载队列
  void _processQueue() async {
    // 防止并发调用导致超过最大并发数
    if (_isProcessingQueue) {
      return;
    }
    _isProcessingQueue = true;

    try {
      // 使用 while 循环持续处理队列，直到达到并发上限或队列为空
      while (_activeDownloads.length < maxConcurrentDownloads &&
          _downloadQueue.isNotEmpty) {
        // 先「同步」从队首取出并移除任务 id，再去 await 查库。
        // 关键：不能「读队首 -> await -> removeAt(0)」，因为 await 期间用户
        // pause/delete 会按值 _downloadQueue.remove(taskId)，队首可能已前移，
        // 此时 removeAt(0) 会误删另一个 pending 任务，导致其永不下载（卡死）。
        final taskId = _downloadQueue.removeAt(0);

        // 通过数据库获取最新任务信息，pending 任务不常驻内存
        final task = await _repository.getTaskById(taskId);

        // 仅对仍为 pending 的任务进行下载；否则跳过（已被取出，无需再移除）
        if (task == null ||
            task.status != DownloadStatus.pending ||
            _activeDownloads.containsKey(taskId)) {
          continue; // 继续处理队列中的下一个任务
        }

        // 记录开始下载的时间
        LogUtils.i(
          '开始下载任务: ${task.fileName} (当前活动下载数: ${_activeDownloads.length + 1}/$maxConcurrentDownloads)',
          'DownloadService',
        );

        // 注意：这里不使用 await，让下载任务异步执行
        // 但需要在调用 _startRealDownload 之前就预占位置，防止超过并发数
        final cancelToken = CancelToken();
        _activeDownloads[task.id] = cancelToken;

        // 异步执行下载任务
        _startRealDownload(task, cancelToken);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // 真正的下载任务
  Future<void> _startRealDownload(
    DownloadTask task,
    CancelToken cancelToken,
  ) async {
    // CancelToken 已在 _processQueue 中创建并添加到 _activeDownloads

    // 如果是图库下载
    if (task.extData?.type == DownloadTaskExtDataType.gallery) {
      await _startGalleryDownload(task, cancelToken);
      return;
    }

    RandomAccessFile? raf;
    StreamSubscription? subscription;
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 3);

    // 取消处理只注册一次。绝不能放进重试循环：否则每轮重试都会注册一个
    // whenCancel 回调，取消时会触发 N 次清理与状态写入，造成状态抖动。
    // 闭包按引用捕获 raf/subscription，取消触发时读到的是最新一轮的值。
    bool cancelHandled = false;
    cancelToken.whenCancel.then((_) {
      if (cancelHandled) return;
      cancelHandled = true;
      final cleanup = () async {
        LogUtils.i('下载已取消: ${task.fileName}', 'DownloadService');
        await _cleanupDownload(task, raf, subscription);
        // 取消即视为暂停。pauseTask 可能已先把状态写成 paused，这里幂等确保一次；
        // 但若调用方已将其置为 completed/failed 等终态，则不覆盖。
        if (task.status != DownloadStatus.completed &&
            task.status != DownloadStatus.failed) {
          task.status = DownloadStatus.paused;
          await _updateTaskStatus(task);
        }
      }();
      _cancelCleanupFutures[task.id] = cleanup;
      cleanup.whenComplete(() => _cancelCleanupFutures.remove(task.id));
    });

    while (retryCount < maxRetries) {
      try {
        LogUtils.i(
          '开始下载任务: ${task.fileName} (重试次数: $retryCount)',
          'DownloadService',
        );

        // 验证已下载的部分。
        // downloadedBytes 是每秒节流写库的，崩溃/被杀时磁盘实际字节往往比库里
        // 记录的「多」一点。因此一律以磁盘实际大小为准来续传，而不是因为
        // 「磁盘比记录大」就删档从头下——否则节流写库会让断点续传几乎永远失效。
        final file = File(task.savePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (task.totalBytes > 0 && fileSize > task.totalBytes) {
            // 磁盘文件比总大小还大，说明文件确实损坏，删档重下
            LogUtils.w(
              '本地文件($fileSize)大于总大小(${task.totalBytes})，删档重下: ${task.fileName}',
              'DownloadService',
            );
            task.downloadedBytes = 0;
            await file.delete();
          } else {
            // 以磁盘实际大小为准续传（含 fileSize 大于/小于记录两种情况）
            task.downloadedBytes = fileSize;
          }
        } else {
          task.downloadedBytes = 0;
        }

        task.status = DownloadStatus.downloading;
        await _updateTaskStatus(task);

        // 获取文件大小 - 直接使用 Range 请求获取文件大小
        try {
          final rangeResponse = await dio.get(
            task.url,
            cancelToken: cancelToken,
            options: Options(
              responseType: ResponseType.stream,
              headers: {'Range': 'bytes=0-0'}, // 只请求第一个字节
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

          // 从 content-range 头获取总大小
          final contentRange = rangeResponse.headers.value('content-range');
          if (contentRange != null) {
            // 格式: bytes 0-0/total_size
            final match = RegExp(
              r'bytes \d+-\d+/(\d+)',
            ).firstMatch(contentRange);
            if (match != null) {
              task.totalBytes = int.parse(match.group(1)!);
              LogUtils.d(
                '从Range请求获取文件大小: ${task.totalBytes}',
                'DownloadService',
              );
            }
          }
        } catch (e) {
          // 如果是取消操作，直接返回
          if (e is DioException && e.type == DioExceptionType.cancel) {
            // 取消操作，更新状态
            task.status = DownloadStatus.paused; // [更新内存状态]
            await _updateTaskStatus(task); // [更新持久化信息]
            return;
          }
          LogUtils.w('Range请求获取文件大小失败: $e', 'DownloadService');
        }

        final response = await dio.get(
          task.url,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            followRedirects: true,
            // 仅接受 2xx，避免将 4xx 的错误页当做有效响应来写入
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
            headers: task.downloadedBytes > 0
                ? {
                    'Range': 'bytes=${task.downloadedBytes}-',
                    'Accept-Encoding': 'identity',
                    'Referer': 'https://www.iwara.tv/',
                    'Accept': '*/*',
                    'Connection': 'keep-alive',
                  }
                : {
                    'Accept-Encoding': 'identity',
                    'Referer': 'https://www.iwara.tv/',
                    'Accept': '*/*',
                    'Connection': 'keep-alive',
                  },
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        // 对视频下载进行响应类型校验，避免把 HTML 挑战页/错误页当成视频写入
        final contentType = response.headers.value('content-type') ?? '';
        if (task.extData?.type == DownloadTaskExtDataType.video) {
          if (!contentType.toLowerCase().startsWith('video')) {
            LogUtils.w('下载响应类型异常: $contentType', 'DownloadService');
            throw FileSystemException(
              message: 'Request Response Type Error: $contentType',
              type: FileErrorType.ioError,
            );
          }
        }

        // 验证服务器是否支持断点续传
        if (task.downloadedBytes > 0) {
          final contentRange = response.headers.value('content-range');
          if (contentRange == null || response.statusCode != 206) {
            // 服务器不支持断点续传，需要重新下载
            task.downloadedBytes = 0;
            await file.delete();
            throw DioException(
              requestOptions: response.requestOptions,
              error: '服务器不支持断点续传，需要重新下载',
            );
          }
        }

        // 如果还没获取到总大小,尝试从响应头获取
        if (task.totalBytes == 0) {
          final contentLength = response.headers.value('content-length');
          if (contentLength != null) {
            // 用 tryParse 兜底：content-length 异常/非法时保持 totalBytes=0（按未知大小处理），
            // 而非抛 FormatException 让整个下载以"未知错误"失败
            final parsed = int.tryParse(contentLength.trim());
            if (parsed != null) {
              task.totalBytes = parsed;
              LogUtils.d('从下载响应获取文件大小: ${task.totalBytes}', 'DownloadService');
            } else {
              LogUtils.w(
                '无法解析 content-length: $contentLength',
                'DownloadService',
              );
            }
          }
        }

        await file.parent.create(recursive: true);
        raf = await file.open(
          mode: task.downloadedBytes > 0
              ? FileMode.writeOnlyAppend
              : FileMode.writeOnly,
        );

        LogUtils.d('开始接收数据流', 'DownloadService');

        // 为当前任务创建专用的计时器
        _taskTimers[task.id]?.cancel();
        _taskTimers[task.id] = Timer.periodic(const Duration(seconds: 1), (_) {
          // 如果是图库类型，则用不到taskTimer，因为图库里的图片下载完成会自动触发数据库的更新和内存状态的更新
          if (task.extData?.type == DownloadTaskExtDataType.gallery) {
            return;
          }
          task.updateSpeed(); // [更新下载速度]
          _repository.updateTask(task); // 每隔1秒 [更新一次持久化信息]
        });

        final completer = Completer();

        // 数据流处理
        subscription = response.data.stream.listen(
          (chunk) async {
            try {
              final localRaf = raf;
              if (localRaf != null) {
                // 暂停流背压：异步写盘期间不投递下一个 chunk，保证写入顺序，
                // 同时避免 writeFromSync 同步写大块时卡住 UI 线程（Windows 上
                // 杀毒实时扫描会让同步写偶发阻塞数秒）。
                subscription?.pause();
                try {
                  await localRaf.writeFrom(chunk);
                } finally {
                  subscription?.resume();
                }
                // chunk.length 在该 stream 中被推断为 num，需显式转 int
                task.downloadedBytes += (chunk.length as int);
                // 不再直接更新 _activeTasks以避免触发整个列表的重建
                // _activeTasks[task.id] = task;

                // 而是触发单个任务的进度通知
                _notifyProgress(task.id);
              }
            } catch (e) {
              LogUtils.e('写入文件失败: $e', tag: 'DownloadService', error: e);
              // 释放资源后再通过 completer 传递错误（与 onDone 错误路径一致）。
              // 不能直接 throw：onData 中抛出的异常不会进入 stream 的 onError，
              // 会变成 zone 未捕获错误，且 completer 永不完成 → 任务卡在
              // downloading 状态、raf 与 _taskTimers 泄漏。
              await _releaseResources(task, raf, subscription);
              if (!completer.isCompleted) {
                completer.completeError(
                  FileSystemException(
                    message: slang.t.download.errors.writeFileFailedForMessage(
                      errorInfo: '$e',
                    ),
                    type: FileErrorType.ioError,
                  ),
                );
              }
            }
          },
          onDone: () async {
            LogUtils.i('下载完成: ${task.fileName}', 'DownloadService');

            int finalSize;
            try {
              // 确保缓冲区写入磁盘后再校验大小
              final localRaf = raf;
              try {
                await localRaf?.flush();
              } catch (_) {}
              finalSize = localRaf != null
                  ? await localRaf.length()
                  : await file.length();
              if (task.totalBytes > 0 && finalSize != task.totalBytes) {
                final integrityError = FileSystemException(
                  message: '文件大小不匹配，预期: ${task.totalBytes}，实际: $finalSize',
                  type: FileErrorType.ioError,
                );

                // 先释放资源，再把错误交给外层处理（重试或失败）
                await _releaseResources(task, raf, subscription);
                completer.completeError(integrityError);
                return; // 必须 return，避免继续走“成功完成”的逻辑
              }
            } catch (e) {
              await _releaseResources(task, raf, subscription);
              completer.completeError(e);
              return;
            }

            // 正常完成路径
            await _cleanupDownload(task, raf, subscription);
            task.status = DownloadStatus.completed;
            // 若服务端未提供大小（totalBytes==0，无法做完整性校验），以磁盘
            // 实际写入大小作为最终大小，避免把 downloadedBytes/totalBytes 错误
            // 清零，否则 UI 会显示「0 字节」、缓存判定也会异常。
            if (task.totalBytes > 0) {
              task.downloadedBytes = task.totalBytes;
            } else {
              task.totalBytes = finalSize;
              task.downloadedBytes = finalSize;
              LogUtils.w(
                '下载完成但服务端未提供大小，按实际写入大小记录: $finalSize (${task.fileName})',
                'DownloadService',
              );
            }
            task.completedAt = DateTime.now();
            await _updateTaskStatus(task);
            completer.complete();
            _processQueue();
          },
          onError: (error) async {
            // 取消（pause/delete）会让 stream 抛出 DioException(cancel)。
            // 取消的状态写入统一交给上面的 whenCancel 路径处理，这里绝不能把
            // 取消当成 failed 写库——否则会与 whenCancel 写 paused 形成竞态，
            // 最终状态不确定（“取消后却显示失败”）。
            if (error is DioException &&
                error.type == DioExceptionType.cancel) {
              await _releaseResources(task, raf, subscription);
              if (!completer.isCompleted) {
                completer.completeError(error);
              }
              return;
            }
            LogUtils.e('下载出错: $error', tag: 'DownloadService', error: error);
            try {
              await _releaseResources(task, raf, subscription);

              // 如果是连接中断错误，尝试重试
              if (error is HttpException &&
                  error.message.contains('Connection closed')) {
                if (retryCount < maxRetries - 1) {
                  retryCount++;
                  await Future.delayed(retryDelay);
                  completer.completeError(error); // 通过completer传递错误
                  return;
                }
              }

              task.status = DownloadStatus.failed;
              _recordFailure(task, error);
              await _updateTaskStatus(task);
              completer.completeError(error);
            } catch (e) {
              LogUtils.e('处理下载错误时发生异常: $e', tag: 'DownloadService', error: e);
              task.status = DownloadStatus.failed;
              _recordFailure(task, e);
              await _updateTaskStatus(task);
              completer.completeError(e);
            } finally {
              _processQueue();
            }
          },
          cancelOnError: true,
        );

        try {
          await completer.future;
          break; // 下载成功，跳出重试循环
        } catch (e) {
          // 如果是取消操作，completer.future会抛出DioException(cancel)
          // 但我们已经在whenCancel中处理了取消操作，这里直接返回
          if (e is DioException && e.type == DioExceptionType.cancel) {
            return;
          }

          // 如果是最后一次重试或不是连接中断错误，则抛出错误
          if (retryCount >= maxRetries - 1 ||
              !(e is HttpException &&
                  e.message.contains('Connection closed'))) {
            rethrow;
          }

          // 否则继续重试
          retryCount++;
          await Future.delayed(retryDelay);
          continue;
        }
      } catch (e) {
        // 针对网络类错误做一点「智能重试」：
        // 1) 链接已死（403 签名失效、404/410 资源换了地址）：视频任务必须强制
        //    向 API 重新索取一份下载地址再重试。这类失败重试同一个 URL 永远是
        //    同样的错——判定统一走 [isDeadLinkErrorType]，不要再按状态码零散判断。
        // 2) 连接中断: 尝试像 resumeTask 一样刷新下载链接后再重试一次。
        final isDeadLinkError = isDeadLinkErrorType(classifyError(e));
        final isConnectionClosedError =
            e is HttpException && e.message.contains('Connection closed');
        final isVideoTask = task.extData?.type == DownloadTaskExtDataType.video;

        if (isVideoTask &&
            retryCount < maxRetries - 1 &&
            (isDeadLinkError || isConnectionClosedError)) {
          try {
            final refreshed = await refreshVideoTask(
              task,
              // 链接已死时不能只看 expires：Iwara 的地址会在没到期之前就 404，
              // 「还没过期」的判断会把任务永远钉死在同一个死链上。
              force: isDeadLinkError,
            );
            if (refreshed != null) {
              LogUtils.w(
                isDeadLinkError
                    ? '检测到链接失效(${classifyError(e).name})，已强制刷新视频下载链接，准备重试: ${task.id}'
                    : '检测到连接中断，已刷新视频下载链接，准备重试: ${task.id}',
                'DownloadService',
              );
              task = refreshed;
              retryCount++;
              await Future.delayed(retryDelay);
              continue;
            }
          } catch (refreshError) {
            LogUtils.w(
              '刷新视频任务链接失败，将按照普通错误处理: $refreshError',
              'DownloadService',
            );
          }
        }

        if (retryCount >= maxRetries - 1) {
          if (e is DioException) {
            final errorMsg = _getErrorMessage(e);
            LogUtils.e('下载失败: $errorMsg', tag: 'DownloadService', error: e);
            _showMessage(errorMsg, Colors.red);
          } else if (e is FileSystemException) {
            final errorMsg = slang.t.download.errors.fileSystemError(
              errorInfo: e.message,
            );
            LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
            _showMessage(errorMsg, Colors.red);
          } else {
            final errorMsg = slang.t.download.errors.unknownError(
              errorInfo: e.toString(),
            );
            LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
            _showMessage(errorMsg, Colors.red);
          }

          await _cleanupDownload(task, raf, subscription);
          task.status = DownloadStatus.failed;
          _recordFailure(task, e);
          await _updateTaskStatus(task);
          _processQueue();
          return;
        }

        // 继续重试
        retryCount++;
        await Future.delayed(retryDelay);
        continue;
      }
    }

    // 确保在任务结束时（无论成功还是失败）都会检查队列
    if (_activeDownloads.length < maxConcurrentDownloads &&
        _downloadQueue.isNotEmpty) {
      _processQueue();
    }
  }

  // 释放资源（不移除 activeDownloads）
  Future<void> _releaseResources(
    DownloadTask task,
    RandomAccessFile? raf,
    StreamSubscription? subscription,
  ) async {
    await subscription?.cancel();

    if (raf != null) {
      try {
        await raf.close();
      } catch (e) {
        // 可能已被提前关闭，降级为警告，避免误导
        LogUtils.w('关闭文件失败(可能已关闭): $e', 'DownloadService');
      }
    }

    // 清理任务专用的计时器
    _taskTimers[task.id]?.cancel();
    _taskTimers.remove(task.id);
  }

  // 完全清理下载任务（移除 activeDownloads）
  Future<void> _cleanupDownload(
    DownloadTask task,
    RandomAccessFile? raf,
    StreamSubscription? subscription,
  ) async {
    await _releaseResources(task, raf, subscription);

    _activeDownloads.remove(task.id);

    // 清理进度节流记录
    _lastNotifyTime.remove(task.id);

    // 从内存中移除下载中的任务（pending 不会进入 _activeTasks）
    _activeTasks.remove(task.id);

    // 通知任务状态变更：completed 不属于活跃区，Store 会把它移出活跃集合
    // 并让历史区重拉，于是「刚下完的任务」立刻出现在历史区顶部。
    _publishTask(task, 'completed');
  }

  Future<void> _updateTaskStatus(DownloadTask task) async {
    // 仅在任务处于下载中时保留在内存活跃列表中
    if (task.status == DownloadStatus.downloading) {
      _activeTasks[task.id] = task;
    } else {
      _activeTasks.remove(task.id);
    }
    // 使用完整更新，确保 error、downloadedBytes 等字段也能持久化
    await _repository.updateTask(task);

    // 通知任务状态变更
    _publishTask(task, 'statusChanged');

    // 统一的终态通知派发入口（视频完成/失败、图库 outer-catch 失败均走此处）。
    await _dispatchTerminalNotification(task);
  }

  /// 取任务的展示标题：优先用扩展数据里的媒体标题，回退到文件名。
  String _noticeTitleFor(DownloadTask task) {
    try {
      final ext = task.extData;
      if (ext != null) {
        final title = ext.data['title'] as String?;
        if (title != null && title.trim().isNotEmpty) {
          return title;
        }
      }
    } catch (_) {
      // 忽略解析异常，回退到文件名
    }
    return task.fileName;
  }

  /// 在任务进入终态（完成/失败）时，统一派发：应用内通知中心记录 + 即时 toast +
  /// 系统通知。通过 [_notifiedTerminalTaskIds] 去重，保证每次终态转换仅触发一次；
  /// 非终态调用则重新「武装」该任务，允许后续真正的新终态再次通知。
  ///
  /// 该方法可能从多个站点被调用（_updateTaskStatus、图库主完成路径、续传刷新失败
  /// 路径），去重集合使重复路由无害。
  Future<void> _dispatchTerminalNotification(DownloadTask task) async {
    final isCompleted = task.status == DownloadStatus.completed;
    final isFailed = task.status == DownloadStatus.failed;

    if (!isCompleted && !isFailed) {
      // 非终态：重新武装，允许后续真正的新终态再次通知。
      _notifiedTerminalTaskIds.remove(task.id);
      return;
    }

    // 总开关：统一控制系统通知 + 应用内通知 + toast。
    // 注意要在去重 add 之前判断——关闭时直接返回，不消费去重令牌，
    // 这样后续真正开启后该任务的新终态仍能正常通知。
    try {
      if (Get.isRegistered<ConfigService>()) {
        final enabled =
            Get.find<ConfigService>()[ConfigKey.DOWNLOAD_NOTIFICATIONS_ENABLED]
                as bool? ??
            true;
        if (!enabled) return;
      }
    } catch (e) {
      LogUtils.w('读取下载通知开关失败，按开启处理: $e', 'DownloadService');
    }

    // 去重：同一次终态转换只通知一次。
    if (!_notifiedTerminalTaskIds.add(task.id)) {
      return;
    }

    final title = _noticeTitleFor(task);

    try {
      // 1) 即时应用内 toast
      if (Get.isRegistered<MessageService>()) {
        final messageService = Get.find<MessageService>();
        if (isCompleted) {
          // 下载完成提示固定展示在屏幕下方；若当前已在下载列表页则不展示跳转引导。
          final notificationService =
              Get.isRegistered<DownloadNotificationService>()
              ? Get.find<DownloadNotificationService>()
              : null;
          final showJumpAction =
              notificationService != null &&
              !notificationService.isAlreadyOnDownloadPage();
          messageService.showActionableMessage(
            slang.t.downloadNotifications.completedToast(name: title),
            AppToastType.success,
            onTap: showJumpAction
                ? notificationService.openDownloadTaskList
                : null,
            actionIcon: showJumpAction ? Icons.arrow_forward_ios_rounded : null,
          );
        } else {
          messageService.showMessage(
            slang.t.downloadNotifications.failedToast(name: title),
            AppToastType.error,
          );
        }
      }

      // 2) 系统通知（不 await：Android 首次可能弹权限框，避免阻塞下载队列推进）
      if (Get.isRegistered<DownloadNotificationService>()) {
        final svc = Get.find<DownloadNotificationService>();
        unawaited(
          isCompleted
              ? svc.showDownloadComplete(taskId: task.id, title: title)
              : svc.showDownloadFailed(
                  taskId: task.id,
                  title: title,
                  error: task.error,
                ),
        );
      }
    } catch (e) {
      LogUtils.e('派发下载终态通知失败', tag: 'DownloadService', error: e);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return slang.t.download.errors.connectionTimeout;
        case DioExceptionType.sendTimeout:
          return slang.t.download.errors.sendTimeout;
        case DioExceptionType.receiveTimeout:
          return slang.t.download.errors.receiveTimeout;
        case DioExceptionType.badResponse:
          return slang.t.download.errors.serverError(
            errorInfo: error.response?.statusCode.toString() ?? '',
          );
        case DioExceptionType.connectionError:
          // 处理连接错误，包括 SSL/TLS 握手失败
          final innerError = error.error;
          if (innerError is HandshakeException) {
            return slang.t.download.errors.sslHandshakeFailed;
          } else if (innerError is SocketException) {
            return slang.t.download.errors.connectionFailed;
          }
          return slang.t.download.errors.connectionFailed;
        case DioExceptionType.unknown:
          // 处理未知错误，尝试提取内部错误信息
          final innerError = error.error;
          if (innerError is HandshakeException) {
            return slang.t.download.errors.sslHandshakeFailed;
          } else if (innerError is SocketException) {
            return slang.t.download.errors.connectionFailed;
          } else if (innerError is HttpException) {
            return innerError.message;
          }
          // 如果有消息就返回消息，否则返回未知网络错误
          if (error.message != null && error.message!.isNotEmpty) {
            return error.message!;
          }
          return slang.t.download.errors.unknownNetworkError;
        default:
          return error.message ?? slang.t.download.errors.unknownNetworkError;
      }
    } else if (error is FileSystemException) {
      return slang.t.download.errors.fileSystemError(errorInfo: error.message);
    } else if (error is HandshakeException) {
      return slang.t.download.errors.sslHandshakeFailed;
    } else if (error is SocketException) {
      return slang.t.download.errors.connectionFailed;
    } else if (error is HttpException) {
      return error.message;
    }
    return error.toString();
  }

  /// 把异常归入 [DownloadErrorType]。
  ///
  /// 与 [_getErrorMessage] 的分工：那个产出给人看的原文（会随语言变），这个产出
  /// 给程序用的稳定语义并落库（见 v19 迁移）。失败卡片显示哪句人话、将来「只重试
  /// 网络类失败」这类批量操作，都基于这里的分类，而不是去解析错误文案。
  DownloadErrorType classifyError(Object? error) {
    if (error == null) return DownloadErrorType.unknown;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return DownloadErrorType.cancelled;
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return DownloadErrorType.network;
        case DioExceptionType.badCertificate:
          return DownloadErrorType.network;
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode ?? 0;
          if (code == 404 || code == 410) return DownloadErrorType.notFound;
          if (code == 401 || code == 403) {
            return DownloadErrorType.serverRejected;
          }
          // 5xx 属于服务端临时故障，重试有意义，归入网络类。
          if (code >= 500) return DownloadErrorType.network;
          return DownloadErrorType.serverRejected;
        case DioExceptionType.unknown:
          return classifyError(error.error);
        default:
          return DownloadErrorType.unknown;
      }
    }

    if (error is FileSystemException) {
      switch (error.type) {
        case FileErrorType.accessDenied:
          return DownloadErrorType.permission;
        case FileErrorType.insufficientSpace:
          return DownloadErrorType.diskFull;
        case FileErrorType.notFound:
          return DownloadErrorType.notFound;
        case FileErrorType.alreadyExists:
        case FileErrorType.ioError:
          return DownloadErrorType.fileInUse;
      }
    }

    if (error is io.FileSystemException) {
      // dart:io 的错误码没有跨平台常量，只能按 errno + 文案兜底判断：
      // 28/112 = 空间不足（POSIX/Windows），13/1 = 权限，32/26 = 文件被占用。
      final code = error.osError?.errorCode;
      final message = (error.osError?.message ?? error.message).toLowerCase();
      if (code == 28 || code == 112 || message.contains('no space')) {
        return DownloadErrorType.diskFull;
      }
      if (code == 13 || code == 1 || message.contains('permission denied')) {
        return DownloadErrorType.permission;
      }
      if (code == 32 ||
          code == 26 ||
          message.contains('being used by another process') ||
          message.contains('text file busy')) {
        return DownloadErrorType.fileInUse;
      }
      return DownloadErrorType.unknown;
    }

    if (error is HandshakeException || error is SocketException) {
      return DownloadErrorType.network;
    }

    if (error is NetworkException) {
      switch (error.type) {
        case NetworkErrorType.canceledByUser:
          return DownloadErrorType.cancelled;
        case NetworkErrorType.storageNotEnough:
          return DownloadErrorType.diskFull;
        case NetworkErrorType.serverError:
          return DownloadErrorType.serverRejected;
        case NetworkErrorType.noNetwork:
        case NetworkErrorType.timeout:
        case NetworkErrorType.invalidUrl:
          return DownloadErrorType.network;
      }
    }

    return DownloadErrorType.unknown;
  }

  /// 这次失败是不是「链接本身已经死了」。
  ///
  /// Iwara 的下载地址是带签名与有效期的临时地址：签名失效返回 403，资源被换到
  /// 新地址（重新转码 / CDN 换路径）返回 404、410。这两类失败重试同一个 URL
  /// 永远是同样的错，唯一的出路是向 API 重新索取一份地址——所以判定收在这里，
  /// 下载重试与手动重试共用同一条判断，不要再各自去比状态码。
  static bool isDeadLinkErrorType(DownloadErrorType type) =>
      type == DownloadErrorType.notFound ||
      type == DownloadErrorType.serverRejected;

  /// 两个下载地址是否指向同一份远端文件。
  ///
  /// Iwara 的地址形如 `https://<cdn>/file/<fileId>/<quality>?expires=..&hash=..`：
  /// 换签名只动 query（有时连 CDN 主机也会换），换文件才会动 path。因此只比
  /// path。解析不出来时按「不同文件」处理——宁可重下，也不要把两份文件的字节
  /// 拼在一起。
  static bool isSameRemoteFile(String previousUrl, String newUrl) {
    if (previousUrl == newUrl) return true;
    try {
      final previousPath = Uri.parse(previousUrl).path;
      final newPath = Uri.parse(newUrl).path;
      if (previousPath.isEmpty || newPath.isEmpty) return false;
      return previousPath == newPath;
    } catch (_) {
      return false;
    }
  }

  /// 远端换了一份新文件时，把已下的半截文件删掉并清零进度，让下一轮从头下。
  Future<void> _discardPartialFile(DownloadTask task) async {
    try {
      final partial = File(task.savePath);
      if (await partial.exists()) {
        await partial.delete();
        LogUtils.w(
          '远端已换文件，删除续传不上的半截文件: ${task.fileName}',
          'DownloadService',
        );
      }
    } catch (e) {
      LogUtils.w('删除失效的半截文件失败: $e', 'DownloadService');
    }
    task.downloadedBytes = 0;
    task.totalBytes = 0;
  }

  /// 记录一次失败的原因（文案 + 分类）。
  void _recordFailure(DownloadTask task, Object? error, {String? message}) {
    task.error = message ?? _getErrorMessage(error);
    task.errorType = classifyError(error).name;
  }

  // 添加重试方法
  Future<void> retryTask(String taskId) async {
    // 防止重复点击
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    try {
      // 1) 优先从内存真源取（UI 正显示的那个实例），否则从数据库取
      DownloadTask? task =
          store.taskOf(taskId) ??
          _activeTasks[taskId] ??
          await _repository.getTaskById(taskId);
      if (task == null) {
        LogUtils.d('重试失败：任务不存在: $taskId', 'DownloadService');
        _showMessage(slang.t.download.errors.taskNotFound, Colors.red);
        return;
      }

      // 2) 仅允许对失败任务重试
      if (task.status != DownloadStatus.failed) {
        LogUtils.d('重试忽略：任务非失败状态: $taskId / ${task.status}', 'DownloadService');
        return;
      }

      // 3) 如为视频任务，校验/刷新链接（联网，可能数秒）。先乐观地把它挪出失败区，
      //    刷新失败再退回去——否则这几秒里点了重试的那一行毫无变化。
      final optimisticTask = task;
      task.status = DownloadStatus.pending;
      _publishTask(task, 'retrying');
      if (task.extData?.type == DownloadTaskExtDataType.video) {
        // 上一次就是死链失败的话，必须强制重新索取地址：只按 expires 判断的话，
        // 「还没到期但已经 404」的地址会被原样拿回来，点多少次重试都是 404。
        final wasDeadLink = isDeadLinkErrorType(
          DownloadErrorType.parse(task.errorType),
        );
        final refreshed = await refreshVideoTask(task, force: wasDeadLink);
        if (refreshed == null) {
          // 刷新失败，退回失败状态并提示
          _showMessage(
            slang.t.download.errors.canNotRefreshVideoTask,
            Colors.red,
          );
          optimisticTask.status = DownloadStatus.failed;
          await _repository.updateTask(optimisticTask);
          _publishTask(optimisticTask, 'retryRolledBack');
          return;
        }
        task = refreshed;
      }

      // 4) 清理错误信息，入队并持久化
      LogUtils.i('重试下载任务: ${task.fileName}', 'DownloadService');
      task.error = null;
      task.errorType = null;
      task.status = DownloadStatus.pending;
      // 解除终态通知去重，重下完成/失败时可再次通知。
      _notifiedTerminalTaskIds.remove(taskId);
      _enqueueTaskId(taskId);
      await _repository.updateTask(task);

      // 通知UI并处理队列
      _publishTask(task, 'retried');
      _processQueue();
    } catch (e) {
      LogUtils.e('重试任务失败: $taskId', tag: 'DownloadService', error: e);
      // 回滚乐观更新：重试没成功就得退回失败区，不能让它挂在等待区里空等。
      final stored = store.taskOf(taskId);
      if (stored != null && stored.status == DownloadStatus.pending) {
        stored.status = DownloadStatus.failed;
        _publishTask(stored, 'retryRolledBack');
      }
      _showMessage(slang.t.errors.failedToOperate, Colors.red);
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  // 获取已完成的任务（分页）
  Future<List<DownloadTask>> getCompletedTasks({
    required int offset,
    required int limit,
  }) async {
    return await _repository.getCompletedTasks(offset: offset, limit: limit);
  }

  /// =============================== 重复检查相关接口 ===============================
  /// 检查视频任务是否重复
  /// 返回检查结果，包括是否存在相同视频不同清晰度或相同清晰度的任务
  Future<VideoTaskDuplicateCheckResult> checkVideoTaskDuplicate(
    String videoId,
    String quality,
  ) async {
    try {
      // 使用基于 media_type/media_id 的索引查询，不再做全表遍历
      final mediaTasks = await _repository.getVideoTasksByMedia(videoId);
      bool hasSameVideoDifferentQuality = false;
      bool hasSameVideoSameQuality = false;
      final existingQualities = <String>[];

      for (var task in mediaTasks) {
        final q = task.quality ?? '';
        if (q.isNotEmpty) {
          existingQualities.add(q);
        }

        if (q == quality) {
          hasSameVideoSameQuality = true;
        } else if (q.isNotEmpty) {
          hasSameVideoDifferentQuality = true;
        }
      }

      return VideoTaskDuplicateCheckResult(
        hasSameVideoDifferentQuality: hasSameVideoDifferentQuality,
        hasSameVideoSameQuality: hasSameVideoSameQuality,
        existingQualities: existingQualities.toSet().toList(),
      );
    } catch (e) {
      LogUtils.e('检查视频任务重复失败', tag: 'DownloadService', error: e);
      // 发生异常时返回无重复的结果，降级处理
      return VideoTaskDuplicateCheckResult(
        hasSameVideoDifferentQuality: false,
        hasSameVideoSameQuality: false,
        existingQualities: [],
      );
    }
  }

  /// 检查指定视频是否存在任何下载任务（任意清晰度）
  /// 返回 true 表示存在至少一个下载任务，false 表示不存在
  Future<bool> hasAnyVideoDownloadTask(String videoId) async {
    try {
      // 直接使用基于媒体索引的查询，避免全表遍历
      return await _repository.existsTaskByMedia('video', videoId);
    } catch (e) {
      LogUtils.e('检查视频下载任务失败', tag: 'DownloadService', error: e);
      // 发生异常时返回 false，降级处理
      return false;
    }
  }

  /// 获取已完成的下载任务的本地文件路径
  /// [videoId] 视频ID
  /// [quality] 视频清晰度（如 "Source", "1080", "720" 等）
  /// 返回本地文件路径，如果没有找到或文件不存在则返回 null
  Future<String?> getCompletedVideoLocalPath(
    String videoId,
    String quality,
  ) async {
    try {
      // 获取该视频的所有下载任务
      final tasks = await _repository.getVideoTasksByMedia(videoId);

      // 同一清晰度可能被重复下载，优先选择最新完成且文件存在的任务
      tasks.sort((a, b) {
        final aTs = a.createdAt?.millisecondsSinceEpoch;
        final bTs = b.createdAt?.millisecondsSinceEpoch;
        if (aTs != null && bTs != null) return bTs.compareTo(aTs); // 新的在前
        if (aTs != null) return -1; // 只有 a 有时间戳，a 在前
        if (bTs != null) return 1; // 只有 b 有时间戳，b 在前

        // 没有时间戳时使用雪花 ID 作为时间序排序（ID 越大越新）
        final aId = int.tryParse(a.id);
        final bId = int.tryParse(b.id);
        if (aId != null && bId != null) return bId.compareTo(aId);
        return b.id.compareTo(a.id);
      });

      // 找到匹配清晰度且已完成的任务
      for (final task in tasks) {
        // 不区分大小写比较清晰度
        if (task.quality?.toLowerCase() == quality.toLowerCase() &&
            task.status == DownloadStatus.completed &&
            task.savePath.isNotEmpty) {
          // 验证文件是否存在
          final file = File(task.savePath);
          if (await file.exists()) {
            LogUtils.d(
              '找到本地下载文件: videoId=$videoId, quality=$quality, path=${task.savePath}',
              'DownloadService',
            );
            return task.savePath;
          } else {
            LogUtils.w('本地文件不存在: ${task.savePath}', 'DownloadService');
          }
        }
      }

      LogUtils.d(
        '未找到本地下载文件: videoId=$videoId, quality=$quality',
        'DownloadService',
      );
      return null;
    } catch (e) {
      LogUtils.e(
        '查询本地视频文件失败: videoId=$videoId, quality=$quality',
        tag: 'DownloadService',
        error: e,
      );
      return null;
    }
  }

  /// 检查指定图库是否存在任何下载任务
  /// 返回 true 表示存在至少一个下载任务，false 表示不存在
  Future<bool> hasAnyGalleryDownloadTask(String galleryId) async {
    try {
      // 直接使用基于媒体索引的查询，避免全表遍历
      return await _repository.existsTaskByMedia('gallery', galleryId);
    } catch (e) {
      LogUtils.e('检查图库下载任务失败', tag: 'DownloadService', error: e);
      // 发生异常时返回 false，降级处理
      return false;
    }
  }

  /// 获取已完成的图库下载的本地图片路径映射
  /// [galleryId] 图库ID
  /// 返回 `Map<String, String>`，key 为图片ID，value 为本地文件路径
  /// 如果没有找到已完成的下载任务或文件不存在则返回空 Map
  Future<Map<String, String>> getCompletedGalleryLocalPaths(
    String galleryId,
  ) async {
    try {
      // 走 (media_type, media_id) 索引精确取该图库的任务，避免全表扫描已完成任务
      final tasks = await _repository.getTasksByMedia('gallery', galleryId);

      // 找到匹配图库ID且已完成的任务
      for (final task in tasks) {
        if (task.status == DownloadStatus.completed &&
            task.extData?.type == DownloadTaskExtDataType.gallery) {
          final galleryData = GalleryDownloadExtData.fromJson(
            task.extData!.data,
          );
          final validLocalPaths = <String, String>{};

          // 验证每个本地文件是否存在
          for (final entry in galleryData.localPaths.entries) {
            final imageId = entry.key;
            final localPath = entry.value;

            if (localPath.isNotEmpty) {
              final file = File(localPath);
              if (await file.exists()) {
                validLocalPaths[imageId] = localPath;
              } else {
                LogUtils.w(
                  '本地图片文件不存在: imageId=$imageId, path=$localPath',
                  'DownloadService',
                );
              }
            }
          }

          if (validLocalPaths.isNotEmpty) {
            LogUtils.d(
              '找到图库本地文件: galleryId=$galleryId, 图片数量=${validLocalPaths.length}',
              'DownloadService',
            );
            return validLocalPaths;
          }
        }
      }

      LogUtils.d('未找到图库本地文件: galleryId=$galleryId', 'DownloadService');
      return {};
    } catch (e) {
      LogUtils.e(
        '查询图库本地文件失败: galleryId=$galleryId',
        tag: 'DownloadService',
        error: e,
      );
      return {};
    }
  }

  /// =============================== 统计相关接口 ===============================
  /// 获取下载中 Tab 需要展示的任务数量（downloading + paused + pending）
  Future<int> getActiveTasksCountForTab() async {
    try {
      final counts = await _repository.getTasksCount();
      return counts['active'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// 获取失败任务数量
  Future<int> getFailedTasksCount() async {
    try {
      return await _repository.getCountByStatus(DownloadStatus.failed);
    } catch (_) {
      return 0;
    }
  }

  /// 获取已完成任务数量
  Future<int> getCompletedTasksCount() async {
    try {
      return await _repository.getCountByStatus(DownloadStatus.completed);
    } catch (_) {
      return 0;
    }
  }

  @override
  void onClose() {
    // 取消所有下载
    for (var cancelToken in _activeDownloads.values) {
      cancelToken.cancel(slang.t.download.errors.serviceIsClosing);
    }
    _activeDownloads.clear();

    // 清理所有计时器
    for (var timer in _taskTimers.values) {
      timer.cancel();
    }
    _taskTimers.clear();

    _progressTriggers.clear();
    _lastNotifyTime.clear();

    // 清理其他资源
    _activeTasks.clear();
    _downloadQueue.clear();
    _notifiedTerminalTaskIds.clear();

    super.onClose();
  }

  /// 统一通过 [MessageService] 展示提示，替代散落的原生 SnackBar。
  /// 沿用旧签名（含 [Color]）以免改动十余处调用点：红色映射为 error，其余为 info。
  void _showMessage(String message, Color color) {
    final type = color == Colors.red
        ? AppToastType.error
        : AppToastType.info;
    if (Get.isRegistered<MessageService>()) {
      Get.find<MessageService>().showMessage(message, type);
    } else {
      LogUtils.w('MessageService 未注册，跳过提示: $message', 'DownloadService');
    }
  }

  // 图库下载的方法
  Future<void> _startGalleryDownload(
    DownloadTask task,
    CancelToken cancelToken,
  ) async {
    try {
      final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);
      final savePath = path_lib.normalize(task.savePath);

      // 创建保存目录
      final directory = Directory(savePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 初始化下载进度跟踪
      _galleryDownloadProgress.remove(task.id);
      _galleryImageProgress.remove(task.id);

      // 更新任务状态为下载中
      task.status = DownloadStatus.downloading;
      _refreshGalleryTaskProgress(task, galleryData);

      await _updateTaskStatus(task);

      // 获取待下载的图片列表
      final pendingImages = galleryData.imageList.entries.where((entry) {
        final imageId = entry.key;
        final localPath = galleryData.localPaths[imageId];
        // 如果本地路径不存在，或者文件不存在，则需要下载
        return localPath == null || !File(localPath).existsSync();
      }).toList();

      // 串行下载每个图片
      for (var entry in pendingImages) {
        // 如果任务被取消，则退出循环
        if (_activeDownloads[task.id]?.isCancelled ?? true) {
          LogUtils.i('图库下载任务已取消: ${task.fileName}', 'DownloadService');
          break;
        }

        final imageId = entry.key;
        final imageUrl = entry.value;

        // 下载单个图片，支持重试一次
        bool success = false;
        for (int retry = 0; retry < 2 && !success; retry++) {
          try {
            success = await _downloadGalleryImage(
              task,
              imageUrl,
              imageId,
              cancelToken,
            );

            if (success) {
              // 验证文件确实下载成功
              final latestGalleryData = GalleryDownloadExtData.fromJson(
                task.extData!.data,
              );
              if (_galleryImageExists(latestGalleryData, imageId)) {
                _refreshGalleryTaskProgress(task, latestGalleryData);
                await _repository.updateTask(task);
                // _activeTasks[task.id] = task; // 移除此行
                _notifyProgress(task.id);
              }
            } else if (retry == 1) {
              // 第二次尝试也失败，记录错误
              LogUtils.e('图片下载失败，已重试: $imageUrl', tag: 'DownloadService');
              task.error = slang.t.download.errors.partialDownloadFailed;
              task.errorType = DownloadErrorType.network.name;
            }
          } catch (e) {
            LogUtils.e('下载图片出错: $imageUrl', tag: 'DownloadService', error: e);
            if (retry == 1) {
              task.error = slang.t.download.errors
                  .partialDownloadFailedWithMessage(
                    message: _getErrorMessage(e),
                  );
              task.errorType = classifyError(e).name;
            }
          }

          // 如果是第一次失败，等待后重试
          if (!success && retry == 0) {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }

      // 检查最终状态
      if (_activeDownloads[task.id]?.isCancelled ?? true) {
        // 任务被取消，更新状态为暂停
        task.status = DownloadStatus.paused;
      } else {
        // 重新获取最新的任务数据（因为可能在下载过程中已经更新）
        final latestGalleryData = GalleryDownloadExtData.fromJson(
          task.extData!.data,
        );

        // 检查是否所有图片都下载成功
        final allSuccess = latestGalleryData.imageList.keys.every((imageId) {
          return _galleryImageExists(latestGalleryData, imageId);
        });

        _refreshGalleryTaskProgress(task, latestGalleryData);

        task.status = allSuccess
            ? DownloadStatus.completed
            : DownloadStatus.failed;
        if (allSuccess) {
          task.completedAt = DateTime.now();
        }
        if (!allSuccess) {
          task.error = slang.t.download.errors.partialDownloadFailed;
          // 逐图失败时已按具体异常归过类，这里只兜没归过的情况。
          task.errorType ??= DownloadErrorType.network.name;
          LogUtils.e(
            '图库下载未完全成功: ${task.downloadedBytes}/${task.totalBytes}',
            tag: 'DownloadService',
          );
        } else {
          LogUtils.i(
            '图库下载完成: ${task.downloadedBytes}/${task.totalBytes}',
            'DownloadService',
          );
        }
      }

      // 更新任务状态
      await _repository.updateTask(task);
      if (task.status == DownloadStatus.downloading) {
        _activeTasks[task.id] = task;
      } else {
        _activeTasks.remove(task.id);
      }
      // 状态变更，通知列表刷新
      _publishTask(task, 'galleryStatusChanged');
      _notifyProgress(task.id); // 确保最后一次进度被更新

      // 图库主完成/部分失败路径不经过 _updateTaskStatus，需显式派发终态通知。
      await _dispatchTerminalNotification(task);

      // 等待一段时间后清理进度状态
      await Future.delayed(const Duration(seconds: 1));
      _galleryDownloadProgress.remove(task.id);
      _galleryImageProgress.remove(task.id);
    } catch (e) {
      LogUtils.e('下载图库失败', tag: 'DownloadService', error: e);
      task.status = DownloadStatus.failed;
      _recordFailure(task, e);
      await _updateTaskStatus(task);

      // 清理进度状态
      _galleryDownloadProgress.remove(task.id);
      _galleryImageProgress.remove(task.id);
    } finally {
      // 如果不是暂停状态，清理活跃下载状态
      if (task.status != DownloadStatus.paused) {
        _activeDownloads.remove(task.id);
        _activeTasks.remove(task.id);
      }
    }
  }

  // 下载单张图片
  Future<bool> _downloadGalleryImage(
    DownloadTask task,
    String url,
    String imageId,
    CancelToken cancelToken,
  ) async {
    final savePath = buildGalleryImageSavePath(
      galleryDirectory: task.savePath,
      imageId: imageId,
      url: url,
    );

    RandomAccessFile? raf;
    try {
      // 更新下载状态为下载中
      _updateGalleryProgress(task.id, imageId, false);
      _updateImageProgress(task.id, imageId, 0);
      task.status = DownloadStatus.downloading;
      await _repository.updateTask(task);
      // 图库逐图下载也要过内存真源：只写库不发布，这一行会停在续传前的旧状态。
      _publishTask(task, 'galleryImageStart');

      // 使用流式下载并直接写盘，避免把整张原图（可能数十 MB）读进内存；
      // 同时传入 cancelToken，使暂停能立即中断当前图片下载而非等整张下完。
      final response = await dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
          headers: {'Accept': '*/*'}, // 接受所有类型的响应
        ),
      );

      final total =
          int.tryParse(response.headers.value('content-length') ?? '') ?? -1;
      final file = File(savePath);
      await file.parent.create(recursive: true);
      raf = await file.open(mode: FileMode.writeOnly);
      int received = 0;
      await for (final chunk in (response.data.stream as Stream<List<int>>)) {
        // 异步写入，避免同步写盘在 Windows 上被杀毒实时扫描卡住 UI
        await raf.writeFrom(chunk);
        received += chunk.length;
        if (total > 0) {
          _updateImageProgress(task.id, imageId, received / total);
          _notifyProgress(task.id);
        }
      }
      await raf.close();
      raf = null;

      // 更新进度
      _updateGalleryProgress(task.id, imageId, true);
      _updateImageProgress(task.id, imageId, 1.0);
      _notifyProgress(task.id); // 通知 UI 更新

      // 更新GalleryDownloadExtData中的localPaths
      if (task.extData?.type == DownloadTaskExtDataType.gallery) {
        final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);
        final updatedData = GalleryDownloadExtData(
          id: galleryData.id,
          title: galleryData.title,
          previewUrls: galleryData.previewUrls,
          authorName: galleryData.authorName,
          authorUsername: galleryData.authorUsername,
          authorAvatar: galleryData.authorAvatar,
          totalImages: galleryData.totalImages,
          imageList: galleryData.imageList,
          localPaths: {...galleryData.localPaths, imageId: savePath},
        );
        task.extData = DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: updatedData.toJson(),
        );
        _refreshGalleryTaskProgress(task, updatedData);

        // 立即更新到数据库和内存
        await _repository.updateTask(task);
        if (task.status == DownloadStatus.downloading) {
          _activeTasks[task.id] = task;
        }
      }

      return true;
    } catch (e) {
      // 关闭可能未关闭的文件句柄，避免泄漏
      if (raf != null) {
        try {
          await raf.close();
        } catch (_) {}
      }
      LogUtils.e('下载图片失败: $url', tag: 'DownloadService', error: e);
      _updateGalleryProgress(task.id, imageId, false);
      _updateImageProgress(task.id, imageId, 0);
      return false;
    }
  }

  // 刷新视频任务
  // 用于更新任务的url
  // @return 返回新的任务信息，如果刷新失败则返回null
  Future<DownloadTask?> refreshVideoTask(
    DownloadTask task, {
    bool force = false,
  }) async {
    VideoDownloadExtData videoExtData = VideoDownloadExtData.fromJson(
      task.extData!.data,
    );
    final videoLink = task.url;
    final expireTime = CommonUtils.getVideoLinkExpireTime(videoLink);
    final shouldForceRefresh = force || expireTime == null;

    final isNearlyExpired =
        expireTime != null &&
        DateTime.now().isAfter(expireTime.subtract(const Duration(minutes: 1)));

    if (shouldForceRefresh || isNearlyExpired) {
      // 需要刷新链接
      String? newVideoDownloadUrl = await VideoService.to
          .getVideoDownloadUrlByIdAndQuality(
            videoExtData.id ?? '',
            videoExtData.quality!,
          );

      // 如果获取到新的链接，则更新任务信息
      if (newVideoDownloadUrl != null) {
        if (!isSameRemoteFile(videoLink, newVideoDownloadUrl)) {
          // 换签名只会动 query，动了 path 说明远端换成了另一份文件（重新转码等）：
          // 已下的半截字节续不上，续传会拼出损坏文件，删档从头下。
          await _discardPartialFile(task);
        }
        task.url = newVideoDownloadUrl;
        return task;
      } else {
        _showMessage(
          slang.t.download.errors.linkExpiredTryAgainFailed,
          Colors.red,
        );
        return null;
      }
    }

    // 链接尚未过期，且无需强制刷新
    return task;
  }
}

/// 视频任务重复检查结果
class VideoTaskDuplicateCheckResult {
  /// 是否存在相同视频ID但不同清晰度的任务
  final bool hasSameVideoDifferentQuality;

  /// 是否存在相同视频ID且相同清晰度的任务
  final bool hasSameVideoSameQuality;

  /// 已存在的清晰度列表
  final List<String> existingQualities;

  VideoTaskDuplicateCheckResult({
    required this.hasSameVideoDifferentQuality,
    required this.hasSameVideoSameQuality,
    required this.existingQualities,
  });
}
