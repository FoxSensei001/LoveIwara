import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_picker_sheet.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_location_card.dart'
    show downloadLocationTitle;
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 全 App **唯一**的「开始下载」入口。
///
/// # 为什么要有这个文件
///
/// 在这之前，下载流程是**内联在页面组件里**的两份拷贝：视频那份在
/// `video_info_tab_widget.dart`（清晰度选择 → 重复任务确认 → 保存路径 →
/// 建任务 → 记住上次清晰度/分类 → toast），图库那份在
/// `image_model_detail_content_widget.dart`。卡片菜单要加下载入口时，
/// 照抄就会变成第三份——同一条流程改一次要改三处，必然有一处忘记跟。
///
/// 所以三个调用点（视频详情页、图库详情页、卡片菜单）现在共用这里。
///
/// # 从卡片进来时多的那一步
///
/// 列表里的 [Video] **没有 `videoSources`**（那是详情接口才给的），
/// [ImageModel] 也**没有 `files`**。所以从卡片下载会先拉一次详情
/// （[_resolveVideoSources] / [_resolveGalleryFiles]）；从详情页进来时把已有的
/// 数据传进来，这一步自动跳过。
///
/// # 统一掉的一处行为差异
///
/// 图库那份原来在建完任务后**直接跳到下载列表页**，视频那份只弹一条带
/// 「查看下载列表」的 toast。现在统一走 toast——正在翻图库的人被弹走一页
/// 是件挺粗暴的事，而 toast 上的动作钮同样一步可达。

/// 视频下载。
///
/// [sources] 给了就直接用（详情页有现成的），没给就拉一次详情。
/// [onTaskCreated] 用来让调用方把自己的「已有下载任务」状态点亮。
Future<void> launchVideoDownload(
  BuildContext context, {
  required Video video,
  List<VideoSource>? sources,

  /// [sources] 是调用方自己已经拉过一遍的结果（卡片菜单在自己那一行转圈拉的，
  /// 见 [prepareVideoDownloadSources]）。传 true 时这里**不再重拉**：空就直接
  /// 按「没有下载源」提示，免得失败路径上白打第二次请求。
  bool sourcesAlreadyResolved = false,
  String? initialQuality,
  DownloadPickerPreselectSource preselectSource =
      DownloadPickerPreselectSource.lastUsed,
  VoidCallback? onTaskCreated,

  /// 「现在最新的源列表」。详情页把 controller 那份实时列表接进来，用于在
  /// 清晰度弹窗关闭之后重新匹配一次——弹窗停留期间源可能已经被刷新过。
  List<VideoSource>? Function()? refreshSources,
}) async {
  final t = slang.Translations.of(context);

  if (!_ensureAuthenticated(t)) return;

  if (video.isExternalVideo) {
    showAppToast(t.download.errors.downloadFailed, type: AppToastType.error);
    return;
  }

  final resolved = sourcesAlreadyResolved
      ? sources
      : await _resolveVideoSources(video, sources);
  if (!context.mounted) return;
  if (resolved == null || resolved.isEmpty) {
    showAppToast(
      t.download.errors.noDownloadSourceNowPleaseWaitInfoLoaded,
      type: AppToastType.error,
    );
    return;
  }

  final result = await showDownloadPickerSheet(
    context,
    video: video,
    sources: resolved,
    initialQuality: initialQuality ?? _lastUsedQuality(resolved),
    preselectSource: preselectSource,
  );
  if (result == null) {
    LogUtils.d('用户取消了下载选择', 'MediaDownloadLauncher');
    return;
  }
  if (!context.mounted) return;

  // ⛔ 弹窗停留期间源列表可能被刷新过（下载链接是带签名、会过期的）。
  // 按清晰度名重新取一次最新的源，别拿弹窗打开那一刻的快照去建任务——
  // 这个仓库有过「下载死链」的旧账，源头就是拿着过期地址。
  // [latestSources] 由调用方通过 [refreshSources] 提供；没提供就沿用原来那份。
  final latest = refreshSources?.call();
  final source = (latest == null || latest.isEmpty)
      ? result.source
      : latest.firstWhereOrNull(
              (s) =>
                  (s.name?.toLowerCase() ?? '') ==
                  (result.source.name?.toLowerCase() ?? ''),
            ) ??
            result.source;

  await _downloadVideoWithSource(
    context,
    video: video,
    source: source,
    categoryId: result.categoryId,
    savePathOverride: result.savePath,
    onTaskCreated: onTaskCreated,
  );
}

/// 图库下载（整册）。
///
/// [gallery] 里没有 `files` 时会先拉一次详情——列表数据不带文件清单，
/// 而整册下载正是靠这份清单一张张排队的。
Future<void> launchGalleryDownload(
  BuildContext context, {
  required ImageModel gallery,
  VoidCallback? onTaskCreated,
}) async {
  final t = slang.Translations.of(context);

  final resolved = await _resolveGalleryFiles(gallery);
  if (!context.mounted) return;
  if (resolved == null || resolved.files.isEmpty) {
    showAppToast(
      t.download.errors.imageModelNotFound,
      type: AppToastType.error,
    );
    return;
  }

  // 下载前选择分类（无分类时不弹框，直接用记住的默认值）。
  // 顺手算一份只读的「将保存到」预览段给确认框展示（不写首见名缓存）。
  final galleryPreview = Get.isRegistered<DownloadPathService>()
      ? Get.find<DownloadPathService>().previewGalleryRelativeSegments(
          gallery: resolved,
        )
      : const <String>[];
  final categoryChoice = await showDownloadCategoryDialog(
    context,
    previewSegments: galleryPreview,
  );
  if (!categoryChoice.confirmed) return;
  if (!context.mounted) return;

  try {
    final extData = GalleryDownloadExtData(
      id: resolved.id,
      title: resolved.title,
      // 存静图海报，理由同 `batch_download_service.dart` 里那一处。
      previewUrls: resolved.files.take(3).map((e) => e.getPosterUrl()).toList(),
      authorName: resolved.user?.name,
      authorUsername: resolved.user?.username,
      authorAvatar: resolved.user?.avatar?.avatarUrl,
      totalImages: resolved.files.length,
      imageList: {
        for (final e in resolved.files) e.id: e.getOriginalImageUrl(),
      },
      localPaths: const {},
    );

    final savePath = await Get.find<DownloadPathService>()
        .getGalleryDownloadPath(gallery: resolved);
    if (savePath == null) {
      showAppToast(t.common.operationCancelled, type: AppToastType.info);
      return;
    }

    final task = DownloadTask(
      url: resolved.files.first.getOriginalImageUrl(),
      downloadedBytes: 0,
      totalBytes: resolved.files.length,
      savePath: savePath,
      fileName: '${resolved.title}_${resolved.id}',
      extData: DownloadTaskExtData(
        type: DownloadTaskExtDataType.gallery,
        data: extData.toJson(),
      ),
      mediaType: 'gallery',
      mediaId: resolved.id,
    );
    task.categoryId = categoryChoice.categoryId;

    await DownloadService.to.addTask(task);
    onTaskCreated?.call();
    await _showDownloadStartedToast(t, savePath: savePath);
  } catch (e) {
    LogUtils.e('添加图库下载任务失败', tag: 'MediaDownloadLauncher', error: e);
    showAppToast(t.download.errors.downloadFailed, type: AppToastType.error);
  }
}

// ---------------------------------------------------------------- 内部

bool _ensureAuthenticated(slang.Translations t) {
  if (Get.find<UserService>().isAuthenticated) return true;
  LogUtils.w('用户未登录，无法下载', 'MediaDownloadLauncher');
  showAppToast(t.errors.pleaseLoginFirst, type: AppToastType.error);
  LoginService.showLogin();
  return false;
}

/// 拿到按清晰度排好序的视频源。列表数据里没有 `videoSources`，此时拉一次详情。
///
/// ⛔ **详情接口给的是 `fileUrl`，不是源清单**（`Video.fromJson` 里 `videoSources`
/// 恒为 null）。所以拉完详情还得照着 `fileUrl` 再要一次源——少了这一步，从卡片
/// 点下载**必定**立刻弹「暂无下载源，请等待信息加载」，而且再等也不会有。
Future<List<VideoSource>?> _resolveVideoSources(
  Video video,
  List<VideoSource>? provided,
) async {
  if (provided != null && provided.isNotEmpty) {
    return CommonUtils.sortVideoSourcesByQuality(provided);
  }
  if (video.videoSources != null && video.videoSources!.isNotEmpty) {
    return CommonUtils.sortVideoSourcesByQuality(video.videoSources!);
  }

  final videoService = Get.find<VideoService>();

  // 列表数据里带的 fileUrl 先试一次，省掉一次详情请求。它是带签名、会过期的，
  // 所以拿不到源时**不能**当成「这视频没有源」——退回去拉一次详情要个新的。
  final String? listed = video.fileUrl;
  if (listed != null && listed.isNotEmpty) {
    final sources = await videoService.getVideoSourcesBy(listed);
    if (sources.isNotEmpty) {
      return CommonUtils.sortVideoSourcesByQuality(sources);
    }
  }

  final detail = await videoService.fetchVideoInfoResult(video.id);
  if (!detail.isSuccess || detail.data == null) return null;
  final String? fresh = detail.data!.fileUrl;
  if (fresh == null || fresh.isEmpty) return null;

  final sources = await videoService.getVideoSourcesBy(fresh);
  if (sources.isEmpty) return null;
  return CommonUtils.sortVideoSourcesByQuality(sources);
}

/// 「拉视频源」这一步单独拎出来，好让调用方在自己的界面上先转圈再进下载流程。
///
/// 卡片菜单用它：点了「下载」之后菜单不立刻关，那一行先转圈拉源，拉完再关面板
/// 进清晰度选择（见 media_action_menu.dart）。拉到的结果原样回传给
/// [launchVideoDownload] 的 `sources`，配合 `sourcesAlreadyResolved: true`。
Future<List<VideoSource>?> prepareVideoDownloadSources(Video video) =>
    _resolveVideoSources(video, null);

/// 「拉图库文件清单」这一步，同 [prepareVideoDownloadSources]。
///
/// 回传的 [ImageModel] 直接交给 [launchGalleryDownload] 即可——它自带
/// 「已经有 files 就不再拉」的短路。
Future<ImageModel?> prepareGalleryDownloadFiles(ImageModel gallery) =>
    _resolveGalleryFiles(gallery);

/// 拿到带文件清单的图库。列表数据里 `files` 是空的。
Future<ImageModel?> _resolveGalleryFiles(ImageModel gallery) async {
  if (gallery.files.isNotEmpty) return gallery;
  final detail = await Get.find<GalleryService>().fetchGalleryDetail(
    gallery.id,
  );
  return detail.isSuccess ? detail.data : null;
}

/// 「上次下载用的那一档」，找不到就按优先级挑一个存在的。
String? _lastUsedQuality(List<VideoSource> sources) {
  if (sources.isEmpty) return null;
  final lastQuality =
      (Get.find<ConfigService>()[ConfigKey.LAST_DOWNLOAD_QUALITY] as String)
          .toLowerCase();

  final matching = sources.firstWhereOrNull(
    (source) => (source.name?.toLowerCase() ?? '') == lastQuality,
  );
  if (matching != null) return matching.name;

  for (final quality in const [
    'source',
    '1080',
    '720',
    '540',
    '360',
    'preview',
  ]) {
    final hit = sources.firstWhereOrNull(
      (source) => (source.name?.toLowerCase() ?? '') == quality,
    );
    if (hit != null) return hit.name;
  }
  return sources.firstOrNull?.name;
}

Future<void> _downloadVideoWithSource(
  BuildContext context, {
  required Video video,
  required VideoSource source,
  String? categoryId,

  /// 弹层里「更改…」挑过的本次落盘路径；给了就不再按配置算路径（也不再弹框）。
  String? savePathOverride,
  VoidCallback? onTaskCreated,
}) async {
  final t = slang.Translations.of(context);

  if (source.download == null) {
    LogUtils.w('所选质量没有下载链接', 'MediaDownloadLauncher');
    showAppToast(t.videoDetail.noDownloadUrl, type: AppToastType.error);
    return;
  }

  try {
    final duplicateCheck = await DownloadService.to.checkVideoTaskDuplicate(
      video.id,
      source.name ?? 'unknown',
    );

    if (duplicateCheck.hasSameVideoSameQuality ||
        duplicateCheck.hasSameVideoDifferentQuality) {
      if (!context.mounted) {
        LogUtils.d('Context 已失效，取消下载操作', 'MediaDownloadLauncher');
        return;
      }
      final shouldContinue = await _confirmDuplicateTask(
        context,
        hasSameQuality: duplicateCheck.hasSameVideoSameQuality,
        existingQualities: duplicateCheck.existingQualities,
      );
      if (!shouldContinue) return;
    }

    final savePath =
        savePathOverride ??
        await Get.find<DownloadPathService>().getVideoDownloadPath(
          video: Video(
            id: video.id,
            title: video.title ?? 'video',
            user: video.user,
          ),
          quality: source.name ?? 'unknown',
          downloadUrl: source.download ?? 'unknown',
        );
    if (savePath == null) {
      LogUtils.d('用户取消了下载操作', 'MediaDownloadLauncher');
      showAppToast(t.common.operationCancelled, type: AppToastType.info);
      return;
    }

    final task = DownloadTask(
      url: source.download!,
      savePath: savePath,
      fileName: '${video.title ?? 'video'}_${source.name}.mp4',
      supportsRange: true,
      extData: DownloadTaskExtData(
        type: DownloadTaskExtDataType.video,
        data: VideoDownloadExtData(
          id: video.id,
          title: video.title,
          thumbnail: video.thumbnailUrl,
          authorName: video.user?.name,
          authorUsername: video.user?.username,
          authorAvatar: video.user?.avatar?.avatarUrl,
          duration: video.file?.duration,
          quality: source.name,
        ).toJson(),
      ),
      mediaType: 'video',
      mediaId: video.id,
      quality: source.name,
    );
    task.categoryId = categoryId;

    await DownloadService.to.addTask(task);
    onTaskCreated?.call();

    // 记住这次成功下载用的清晰度 + 分类，作为下次默认值。
    // ⛔ 必须放在 addTask 成功**之后**：放在前面的话，用户在重复任务确认 /
    // 保存路径这些后续步骤里中途取消，默认值却已经被改掉，按钮下次会显示一个
    // 从未真正下载过的清晰度。
    final configService = Get.find<ConfigService>();
    configService.setSetting(
      ConfigKey.LAST_DOWNLOAD_QUALITY,
      source.name ?? 'unknown',
    );
    configService.setSetting(
      ConfigKey.LAST_DOWNLOAD_CATEGORY_ID,
      categoryId ?? '',
    );

    await _showDownloadStartedToast(
      t,
      savePath: savePath,
      userPickedLocation: savePathOverride != null,
    );
  } catch (e) {
    LogUtils.e('添加下载任务失败: $e', tag: 'MediaDownloadLauncher', error: e);
    String message;
    if (e.toString().contains(t.download.errors.downloadTaskAlreadyExists)) {
      message = t.download.errors.downloadTaskAlreadyExists;
    } else if (e.toString().contains(
      t.download.errors.videoAlreadyDownloaded,
    )) {
      message = t.download.errors.videoAlreadyDownloaded;
    } else {
      message = t.download.errors.downloadFailed;
    }
    showAppToast(message, type: AppToastType.error);
  }
}

Future<bool> _confirmDuplicateTask(
  BuildContext context, {
  required bool hasSameQuality,
  required List<String> existingQualities,
}) async {
  if (!context.mounted) return false;
  final t = slang.Translations.of(context);

  final String message;
  if (hasSameQuality) {
    message = t.download.alreadyDownloadedWithQuality;
  } else {
    final qualitiesText = existingQualities.isNotEmpty
        ? existingQualities.join('、')
        : t.download.otherQualities;
    message = t.download.alreadyDownloadedWithQualities(
      qualities: qualitiesText,
    );
  }

  // 走 showAppDialog 而不是裸 showDialog：液态档与出入场都供在那条路由上
  // （glass_style_guard_test 有零容忍闸门）。搬家之前那份用的是裸 showDialog，
  // 属于基线里的历史欠账，这次一并还掉。
  final result = await showAppDialog<bool>(
    Builder(
      builder: (dialogContext) => GlassAlertDialog(
        title: t.common.tips,
        content: Text(message),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          GlassDialogAction(
            label: t.common.confirm,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    ),
    dialogContext: context,
  );
  return result ?? false;
}

/// 统一的「开始下载」提示：一条带「查看下载列表」动作的玻璃 toast。
/// [userPickedLocation]：这次是用户自己在「另存为」里挑的位置，不需要再告诉他
/// 存到了哪。
Future<void> _showDownloadStartedToast(
  slang.Translations t, {
  required String savePath,
  bool userPickedLocation = false,
}) async {
  if (!userPickedLocation &&
      await _showFirstDownloadLocationNotice(t, savePath)) {
    return;
  }
  showAppToast(
    t.videoDetail.startDownloading,
    type: AppToastType.success,
    position: AppToastPosition.bottom,
    actionLabel: t.download.viewDownloadList,
    onAction: NaviService.navigateToDownloadTaskListPage,
  );
}

/// 桌面固定目录模式下的第一次下载：告诉用户文件存到了哪、在哪改。只出一次。
///
/// 桌面默认以前是每次弹「另存为」，2026-10-31 起改成直接存进 下载/LoveIwara
/// （见 [DownloadPathService.asksEveryTime]）。老用户点下载后没看到对话框，
/// 不说一声就会去找文件。返回是否出了这条提示（出了就不再叠「开始下载」那条）。
///
/// 只给落在默认目录的人：自己开过自定义目录的人知道文件在哪。
/// 「在不在目标目录里」按这次真实的 [savePath] 判，不看路径状态的 Rx 快照——
/// 目录不可用时 `_getBasePath` 会悄悄回落到应用专属空间，而状态刷新是异步的，
/// 快照这时多半还是旧的，会对用户报错地方。
Future<bool> _showFirstDownloadLocationNotice(
  slang.Translations t,
  String savePath,
) async {
  if (!GetPlatform.isDesktop || !Get.isRegistered<DownloadPathService>()) {
    return false;
  }
  final pathService = DownloadPathService.to;
  if (pathService.asksEveryTime) return false;
  final config = Get.find<ConfigService>();
  if (config[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool) return false;
  if (config[ConfigKey.DOWNLOAD_LOCATION_NOTICE_SHOWN] as bool) return false;
  try {
    final directory = await pathService.targetDownloadDirectory();
    if (!p.isWithin(directory, savePath) && !p.equals(directory, savePath)) {
      return false;
    }
    final location = await pathService.describeLocation(directory);
    config[ConfigKey.DOWNLOAD_LOCATION_NOTICE_SHOWN] = true;
    showAppToast(
      t.download.location.firstDownloadNotice(
        location: downloadLocationTitle(location),
      ),
      type: AppToastType.success,
      position: AppToastPosition.bottom,
      duration: const Duration(seconds: 8),
      actionLabel: t.download.location.changeLocation,
      onAction: NaviService.navigateToDownloadSettingsPage,
    );
    return true;
  } catch (e) {
    LogUtils.w('首次下载位置提示失败: $e', 'MediaDownloadLauncher');
    return false;
  }
}
