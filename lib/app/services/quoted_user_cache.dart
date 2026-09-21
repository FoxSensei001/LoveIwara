import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_request_access.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 按 **username** 认人的一张缓存表。
///
/// # 为什么需要它
///
/// 引用头在发出去的原文里只有 `Reply #7: @bob` 这么多（格式契约见
/// `CommentMarkup`，⛔ 不能为了多塞两个字段就改它——那串字会被 iwara 网页端
/// 和别的客户端原样显示出来）。可是引用条要画头像和昵称，这两样原文里都没有。
///
/// 实测过 iwara 的两条接口（2026-09-21）：
///
/// | 接口 | 返回 | 头像 |
/// |---|---|---|
/// | `/light/profile/{username}` | `{name, username}` | ❌ 没有 |
/// | `/profile/{username}` | 完整 user 对象 + header + body | ✅ `user.avatar` |
///
/// 所以要头像就**只能**走 `/profile/`，而它一次就把昵称一起给了——不必先
/// light 再详情。
///
/// # 为什么是缓存而不是「去列表里找」
///
/// 「在当前已加载的回复里按楼层找那一条」和这张表是同一件事的两种写法，但
/// 缓存这一种不必让引用条知道自己长在哪个列表上：帖子每加载一页就把那一页的
/// user 全 [seed] 进来，于是
///
/// - 同一页里的引用：命中，零网络；
/// - 跨页但那个人在之前翻过的页里出现过：也命中，零网络；
/// - 都落空（楼层在没加载过的页 / 那条已被删）：才真去查一次，且只查一次。
///
/// 进程内缓存，不落盘：用户资料会变，而这点数据重新拉一次很便宜。
class QuotedUserCache {
  QuotedUserCache._();

  static final Map<String, User> _cache = {};

  /// 正在飞的请求。同一屏里若有五条引用都指向同一个人，只该发一次。
  static final Map<String, Future<User?>> _inflight = {};

  /// 查过但确实不存在（服务端明确回了「没有这个人」：已注销 / 改名）。
  ///
  /// ⛔ 必须单独记一笔：没有它的话，一个被删掉的用户会让**每一次重建**都去
  /// 打一次接口，而列表滚动时重建是常态。
  ///
  /// ⛔ 只装**服务端说了没有**的那些。请求失败（断网、超时、被 CF 拦）不进
  /// 这张表，它们归 [_cooldown]——理由见那里。
  static final Set<String> _misses = {};

  /// 因为**网络原因**没查成的那些，记下失败时刻。
  ///
  /// ⛔ 这一类不能和 [_misses] 混为一谈。早先它们一起进 `_misses`，于是滚动时
  /// 的一次超时就把那个人**永久**判成「不存在」：网络恢复之后引用条照旧只剩一
  /// 个灰圆和 `@username`，重启应用才好得了（2026-09-21 审查查出）。
  ///
  /// 也不能干脆不记——那样一个连不上的接口会让每一次重建都重发一遍请求，正是
  /// [_misses] 当初要防的事。所以记一个**冷却期**：这段时间里不再问，过了就给
  /// 它下一次机会。
  static final Map<String, DateTime> _cooldown = {};

  /// 网络失败之后隔多久才允许再问一次。够短，用户滚回来时基本已经过了；
  /// 够长，一屏之内不会把同一个坏请求重发几十遍。
  static const Duration _retryAfter = Duration(seconds: 30);

  static String _norm(String username) => username.trim().toLowerCase();

  static bool _coolingDown(String key) {
    final failedAt = _cooldown[key];
    if (failedAt == null) return false;
    if (DateTime.now().difference(failedAt) < _retryAfter) return true;
    // 冷却期过了，销掉这一笔：下一次 resolve 就是一次干净的重试。
    _cooldown.remove(key);
    return false;
  }

  /// 已经认识的那些。拿得到就同步画，拿不到才谈异步。
  static User? cached(String username) => _cache[_norm(username)];

  /// 现在别再问这个人了：要么服务端说了没有，要么刚失败过还在冷却期。
  static bool isMiss(String username) {
    final key = _norm(username);
    return _misses.contains(key) || _coolingDown(key);
  }

  /// 把手上现成的用户喂进来（列表加载完一页就喂一次）。零成本，来者不拒。
  static void seed(Iterable<User?> users) {
    for (final user in users) {
      if (user == null) continue;
      final key = _norm(user.username);
      if (key.isEmpty) continue;
      _cache[key] = user;
      _misses.remove(key);
      _cooldown.remove(key);
    }
  }

  /// 按 username 拿人。缓存命中就同步返回，否则查一次 `/profile/{username}`。
  static Future<User?> resolve(String username) {
    final key = _norm(username);
    if (key.isEmpty) return Future.value(null);

    final hit = _cache[key];
    if (hit != null) return Future.value(hit);
    if (_misses.contains(key) || _coolingDown(key)) return Future.value(null);

    final flying = _inflight[key];
    if (flying != null) return flying;

    final future = _fetch(username, key);
    _inflight[key] = future;
    // ⛔ 不要写成 `whenComplete(() => _inflight.remove(key))`：箭头函数体
    // 返回的是 remove 的结果（一个 User?），whenComplete 会把它当成要等的
    // Future 去 await，于是这条 future 永不完成。用花括号。
    future.whenComplete(() {
      _inflight.remove(key);
    });
    return future;
  }

  static Future<User?> _fetch(String username, String key) async {
    try {
      final response = await Get.find<ApiService>().get(
        ApiConstants.userProfile(username),
        requestAccess: ApiRequestAccess.optionalAuthShortWait,
      );
      final raw = response.data?['user'];
      if (raw == null) {
        _misses.add(key);
        return null;
      }
      final user = User.fromJson(raw);
      _cache[key] = user;
      return user;
    } catch (e) {
      // 查不到就是查不到：引用条退回只有楼层和 username 的样子，不报错弹窗。
      //
      // ⛔ 但**记的是冷却期，不是 miss**。对这块界面来说「被删的用户」和「网络
      // 不通」长得一样，可它们的寿命完全不同：前者以后也不会有，后者过一会儿
      // 就好了。混在一起记的后果是一次超时让那个人永久没有头像（见 [_cooldown]）。
      LogUtils.w('引用用户解析失败（@$username）：$e', 'QuotedUserCache');
      _cooldown[key] = DateTime.now();
      return null;
    }
  }

  /// 测试用：清空。
  static void debugClear() {
    _cache.clear();
    _inflight.clear();
    _misses.clear();
    _cooldown.clear();
  }
}
