import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/update_info.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/http_client_factory.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/app_version.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class VersionService extends GetxService {
  final ConfigService _configService = Get.find();

  /// 查更新的超时。裸 `Dio()` 默认是**没有超时**的（connect/receive 都是 null），
  /// 一条挂住的连接会让 [isChecking] 永远停在 true——「关于」页进去就查，
  /// 用户看到的是一个永不停的转圈。
  static const Duration _requestTimeout = Duration(seconds: 20);

  late final Dio _dio;

  VersionService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: _requestTimeout,
        receiveTimeout: _requestTimeout,
        sendTimeout: _requestTimeout,
      ),
    );
    _dio.options.persistentConnection = false;
    // ⛔ 必须走应用统一的 HttpClient 工厂。更新日志托管在
    // raw.githubusercontent.com，对相当一部分目标用户来说只有配了代理才连得通，
    // 而那份代理配置就挂在这个工厂上（见 ApiService.init 的同款接法）。
    // 这里以前是一个裸 `Dio()`，于是「用户在设置里配了代理」和「能不能查到更新」
    // 完全是两回事——更新检测对这批人从上线起就没工作过，而且全程静默。
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClientFactory.instance.createHttpClient,
    );
  }

  final currentVersion = ''.obs;
  final latestVersion = ''.obs;
  final hasUpdate = false.obs;
  final isChecking = false.obs;
  final errorMessage = ''.obs;
  final updateInfo = Rxn<UpdateInfo>();

  Future<VersionService> init() async {
    // ⚠️ 这里读的是**手写常量**，不是 pubspec.yaml。（这条注释以前写着
    // "从 pubspec.yaml 读取"，是错的。）版本号在这个仓库里有三份真相
    // （pubspec / constants.dart / update_logs.yaml），全靠手改；
    // test/app/services/version_metadata_test.dart 是挡住"发版漏改"的闸门。
    //
    // ⭐ 带上 build 号（FULL_VERSION 而非 VERSION）：热修重打包只有 build 号会变，
    // 不带的话「关于」页会同屏出现「当前版本 0.5.1」和「发现新版本 0.5.1」，
    // 用户读不出差别，会当成 bug。
    currentVersion.value = CommonConstants.FULL_VERSION;
    return this;
  }

  /// 自动检查之间至少隔这么久。
  ///
  /// 这个节流本来就该有——`LAST_CHECK_UPDATE_TIME` 一直在写，却从来没有人读，
  /// 于是只要有新版且用户没点过「忽略此版本」，**每次冷启动都会被弹一次**。
  /// 手动检查（设置 → 关于）不受这里限制。
  static const Duration autoCheckInterval = Duration(hours: 24);

  /// 纯判断：这次启动该不该自动查更新。抽出来是为了能单测。
  @visibleForTesting
  static bool shouldAutoCheck({
    required bool autoCheckEnabled,
    required bool firstTimeSetupCompleted,
    required int lastCheckMs,
    required int nowMs,
  }) {
    if (!autoCheckEnabled) return false;
    // 首次引导还没走完：更新弹窗和引导页挂在同一个 root navigator 上，
    // 这时候弹就是直接盖在引导流程上。留到引导做完之后的那次启动。
    if (!firstTimeSetupCompleted) return false;
    if (lastCheckMs <= 0) return true;
    final int elapsed = nowMs - lastCheckMs;
    // 用户把系统时间往回调过——别因为一个未来的时间戳把自己锁死。
    if (elapsed < 0) return true;
    return elapsed >= autoCheckInterval.inMilliseconds;
  }

  /// 自动检查更新
  void doAutoCheckUpdate() async {
    final bool due = shouldAutoCheck(
      autoCheckEnabled: _configService[ConfigKey.AUTO_CHECK_UPDATE] == true,
      firstTimeSetupCompleted:
          _configService[ConfigKey.FIRST_TIME_SETUP_COMPLETED] == true,
      lastCheckMs: _configService[ConfigKey.LAST_CHECK_UPDATE_TIME] ?? 0,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (!due) return;
    checkUpdate(showDialog: true);
  }

  /// 检查更新
  Future<void> checkUpdate({bool showDialog = false}) async {
    try {
      isChecking.value = true;
      errorMessage.value = '';

      final response = await _dio.get(
        _configService[ConfigKey.REMOTE_REPO_UPDATE_LOGS_YAML_URL],
      );

      if (response.statusCode != 200) {
        _inconclusive('HTTP ${response.statusCode}');
        return;
      }

      final dynamic yaml = loadYaml(
        response.data is String ? response.data as String : '${response.data}',
      );
      // ⛔ 原样保留远端字符串，**连 build 号一起**。
      // 曾经在这里 `.split('+').first` 剥掉 build 号，有两个后果：
      // 1. [IGNORED_VERSION] 存的是剥过的值，用户忽略过 0.5.1 之后，热修
      //    0.5.1+4 会因为「0.5.1 == 0.5.1」被永久静音；
      // 2. 弹窗标题显示的版本号和用户已装的一模一样，看着像重复弹窗。
      // 匹配 updates 条目时才剥（那里写的是纯 semver），见 [_parseUpdateInfo]。
      final String? remoteVersion = yaml is Map
          ? yaml['currentVersion']?.toString().trim()
          : null;

      LogUtils.d('远程版本: $remoteVersion', 'VersionService');

      if (remoteVersion == null || remoteVersion.isEmpty) {
        // 以前这里是 `if (remoteVersion != null)` 然后什么都不做——yaml 的 key
        // 一改名，检查就静默变成 no-op，还会照常写「已检查」时间戳把自己挡在
        // 24 小时之外。
        _inconclusive('更新日志里取不到 currentVersion 字段');
        return;
      }

      latestVersion.value = remoteVersion;
      final bool updateAvailable = _isRemoteNewer(remoteVersion);

      final UpdateInfo? parsed = _parseUpdateInfo(yaml, remoteVersion);
      if (updateAvailable && parsed == null) {
        // 远端声明了新版，却取不到这一版的更新日志条目（yaml 结构变了，或者
        // 发版时改了 currentVersion 但忘了往 updates 里加条目——那份 yaml 是
        // 手写的，这个漏法很常见）。以前这里会走到 _showUpdateDialog 然后因为
        // updateInfo 为 null 直接 return：hasUpdate 是 true，但弹窗不出现、
        // 也没有任何提示，用户什么都看不到。
        hasUpdate.value = true;
        _inconclusive('远端最新版 v$remoteVersion 在 updates 列表里没有对应条目');
        return;
      }

      hasUpdate.value = updateAvailable;
      if (parsed != null) updateInfo.value = parsed;

      // 只有真正得出结论的一次才算「查过了」。
      _configService[ConfigKey.LAST_CHECK_UPDATE_TIME] =
          DateTime.now().millisecondsSinceEpoch;

      if (updateAvailable &&
          showDialog &&
          latestVersion.value != _configService[ConfigKey.IGNORED_VERSION]) {
        _showUpdateDialog();
      }
    } catch (e, stackTrace) {
      LogUtils.e(
        '检查更新失败',
        error: e,
        stackTrace: stackTrace,
        tag: 'VersionService',
      );
      _inconclusive('$e');
    } finally {
      isChecking.value = false;
    }
  }

  /// 这一次检查没能得出结论。
  ///
  /// ⛔ 这里**不**碰 [hasUpdate]：失败不等于「没有新版本」。以前 catch 里一句
  /// `hasUpdate.value = false`，一次网络抖动就能把已经查到的新版状态抹掉。
  ///
  /// ⛔ 也**不**写 LAST_CHECK_UPDATE_TIME：没查成的一次不该把下一次挡在 24
  /// 小时之外。
  void _inconclusive(String detail) {
    errorMessage.value = t.settings.checkForUpdatesFailed;
    LogUtils.w('检查更新未得出结论：$detail', 'VersionService');
  }

  /// 从**已经拉下来的**那份 yaml 里取出对应版本的更新日志。取不到返回 null。
  ///
  /// 以前这里会拿同一个 URL 再 GET 一次，等于每次检查更新都请求两遍。
  UpdateInfo? _parseUpdateInfo(dynamic yaml, String version) {
    try {
      final dynamic updates = yaml is Map ? yaml['updates'] : null;
      if (updates is! YamlList) {
        // 以前是 `as YamlList` 强转，失败只 log 一行，调用方无从知晓。
        LogUtils.w(
          '更新日志缺少 updates 列表（实际为 ${updates.runtimeType}）',
          'VersionService',
        );
        return null;
      }
      // 两边都剥掉 build 号再比：updates 条目写的是纯 semver（"0.5.1"），
      // 而 currentVersion 在热修时会带上 build 号（"0.5.1+4"）。不剥的话
      // 热修永远匹配不到条目，于是走进「取不到更新日志」那条岔路。
      final String wanted = version.split('+').first;
      for (final update in updates) {
        if (update is Map &&
            update['version']?.toString().split('+').first == wanted) {
          return UpdateInfo.fromYaml(update);
        }
      }
      LogUtils.w('更新日志的 updates 列表里没有 v$wanted 的条目', 'VersionService');
      return null;
    } catch (e, stackTrace) {
      LogUtils.e(
        '解析更新日志失败',
        error: e,
        stackTrace: stackTrace,
        tag: 'VersionService',
      );
      return null;
    }
  }

  /// 显示更新对话框
  void _showUpdateDialog() {
    final update = updateInfo.value;
    if (update == null) {
      LogUtils.e('更新信息为空', tag: 'VersionService');
      return;
    }

    String currentLocale = _configService[ConfigKey.APPLICATION_LOCALE] ?? 'en';
    if (currentLocale == 'system') {
      currentLocale = CommonUtils.getDeviceLocale();
    }
    final changes = update.getLocalizedChanges(currentLocale);

    showAppDialog(
      GlassAlertDialog(
        title: '${t.settings.newVersionAvailable}: ${latestVersion.value}',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.settings.latestVersion}: ${latestVersion.value}'),
              const SizedBox(height: 8),
              Text('${t.settings.releaseDate}: ${update.date}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(t.settings.updateContent),
                  const Spacer(),
                  Builder(
                    builder: (dialogContext) => IconButton(
                      icon: const Icon(Icons.translate),
                      onPressed: () {
                        showTranslationDialog(
                          dialogContext,
                          text: changes.join('\n\n'),
                          barrierDismissible: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
              ...changes.map(
                (change) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(change),
                ),
              ),
            ],
          ),
        ),
        actions: [
          GlassDialogAction(
            label: t.settings.ignoreThisVersion,
            emphasized: false,
            onPressed: () {
              _configService[ConfigKey.IGNORED_VERSION] = latestVersion.value;
              AppService.tryPop();
            },
          ),
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: t.settings.update,
            onPressed: () => _openReleaseUrl(),
          ),
        ],
      ),
    );
  }

  /// 远端这一版是不是**严格新于**本机这一版。
  ///
  /// 本机拿的是 [CommonConstants.FULL_VERSION]（带 build 号），不是
  /// [currentVersion]（展示用的 semver）——否则同 semver 的热修重打包永远看不见。
  /// 比较规则（含对严格 semver 的那处故意偏离）见 [AppVersion]。
  bool _isRemoteNewer(String remoteRaw) => AppVersion.isNewer(
    current: CommonConstants.FULL_VERSION,
    latest: remoteRaw,
  );

  Future<void> _openReleaseUrl() async {
    final url = Uri.parse(_configService[ConfigKey.REMOTE_REPO_RELEASE_URL]);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      LogUtils.e('无法打开更新链接', tag: 'VersionService');
    }
  }

  /// 获取全部更新日志
  Future<List<UpdateInfo>> fetchAllUpdateLogs() async {
    List<UpdateInfo> updatesList = [];
    try {
      final response = await _dio.get(
        _configService[ConfigKey.REMOTE_REPO_UPDATE_LOGS_YAML_URL],
      );
      if (response.statusCode == 200) {
        final yamlData = loadYaml(response.data);
        final yamlUpdates = yamlData['updates'] as YamlList;
        updatesList = yamlUpdates
            .map<UpdateInfo>((update) => UpdateInfo.fromYaml(update))
            .toList();
      }
    } catch (e) {
      LogUtils.e('获取全部更新日志失败', error: e, tag: 'VersionService');
    }
    return updatesList;
  }
}
