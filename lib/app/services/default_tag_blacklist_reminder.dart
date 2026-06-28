import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 网站会给每个新注册用户默认加上一批标签黑名单，很多用户并不知情。
/// 本工具检测当前账号是否仍处于这套默认黑名单，若是且该用户名此前未被
/// 提醒过，则弹窗提示用户前往黑名单管理页处理。
///
/// 触发场景：
/// 1. 手动登录成功后（[checkAndRemind] 无参，自行拉取资料）；
/// 2. 启动时自动恢复已登录会话、静默刷新资料后（[checkAndRemind] 传入
///    已拿到的 [Tag] 列表，零额外请求）—— 覆盖不会再走手动登录的老用户。
class DefaultTagBlacklistReminder {
  DefaultTagBlacklistReminder._();

  static const String _tag = 'DefaultTagBlacklistReminder';

  /// 本次运行内已处理过的用户名（内存级去重）。
  /// 登录与启动两条路径可能并发触发，借此避免重复弹窗；跨会话的"只提醒
  /// 一次"则由持久化的 [ConfigKey.DEFAULT_BLACKLIST_REMINDER_SEEN_USERS] 保证。
  static final Set<String> _handledUsernames = <String>{};

  /// 网站为新用户默认设置的标签黑名单（tag id 集合）。
  /// 数据来源：GET /user 返回的 tagBlacklist 字段。
  static const List<String> defaultBlacklistTagIds = [
    'beastiality',
    'guro',
    'loli',
    'pee',
    'rape',
    'ryona',
    'scat',
    'shota',
  ];

  /// 判断给定的标签黑名单是否与网站默认黑名单「完全一致」。
  /// 只要用户增删过任意标签（集合不等），就视为用户已自行管理过，不再提醒。
  static bool isDefaultBlacklist(List<Tag> tags) {
    final ids = tags.map((t) => t.id).toSet();
    if (ids.length != defaultBlacklistTagIds.length) return false;
    return ids.containsAll(defaultBlacklistTagIds);
  }

  /// 检测并按需提醒（fire-and-forget）。
  /// 满足：已登录 + 该用户名未被提醒过 + 当前黑名单等于网站默认黑名单，
  /// 三者同时成立时弹窗提醒，并把该用户名记入「已提醒」列表（只提醒一次）。
  ///
  /// [blacklist] 若调用方已持有当前账号的标签黑名单（如启动静默刷新时
  /// /user 响应里已带 tagBlacklist），可直接传入以省去一次额外请求；
  /// 不传则内部自行调用 [UserService.fetchProfileUser] 拉取。
  static Future<void> checkAndRemind({List<Tag>? blacklist}) async {
    try {
      final userService = Get.find<UserService>();
      final username = userService.currentUser.value?.username;
      if (username == null || username.isEmpty) return;

      // 本次运行已处理过则跳过（同步判断，避免登录/启动并发双弹窗）。
      if (_handledUsernames.contains(username)) return;

      final configService = Get.find<ConfigService>();
      final seenUsers = List<String>.from(
        configService[ConfigKey.DEFAULT_BLACKLIST_REMINDER_SEEN_USERS]
                as List? ??
            const [],
      );
      // 该用户名已经见过这个提醒，不再打扰。
      if (seenUsers.contains(username)) {
        _handledUsernames.add(username);
        return;
      }

      // 在首个 await 之前同步占位，确保并发触发只有一条路径继续往下走。
      _handledUsernames.add(username);

      final List<Tag> tags;
      if (blacklist != null) {
        tags = blacklist;
      } else {
        // 拉取包含 tagBlacklist 的完整资料（fetchUserProfile 不解析该字段）。
        final result = await userService.fetchProfileUser();
        if (!result.isSuccess || result.data == null) return;
        tags = result.data!.tagBlacklist ?? const <Tag>[];
      }

      if (!isDefaultBlacklist(tags)) return;

      // 先记录「已提醒」，避免重复触发；无论用户选择去管理还是关闭，都只提醒一次。
      seenUsers.add(username);
      await configService.setSetting(
        ConfigKey.DEFAULT_BLACKLIST_REMINDER_SEEN_USERS,
        seenUsers,
      );

      await _showReminderDialog();
    } catch (e, s) {
      LogUtils.e('默认标签黑名单提醒检查失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  static Future<void> _showReminderDialog() async {
    await showAppDialog(
      AlertDialog(
        title: Text(t.defaultBlacklistReminder.title),
        content: Text(t.defaultBlacklistReminder.content),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(t.defaultBlacklistReminder.dismiss),
          ),
          FilledButton(
            onPressed: () {
              AppService.tryPop();
              NaviService.navigateToTagBlacklistPage();
            },
            child: Text(t.defaultBlacklistReminder.goManage),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
