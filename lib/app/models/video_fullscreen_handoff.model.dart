/// 「全屏连播换片」时，旧页交给新页的那一点点上下文。
///
/// ⛔ 这里**不再携带窗口几何**。快照一度是 controller 的私有字段、靠这个交接件
/// 一页页传下去，只要有一次没传到就永远消失——而「换到一条播不了的片子」
/// （站外短链 / 私密视频）恰恰就是那一次：新页不接手全屏，交接件被有意丢掉，
/// 窗口于是铺满屏幕再也回不去（2026-08-31 用户报障）。
///
/// 全屏是**窗口**的状态而不是某一页的状态，几何快照现在归
/// `DesktopNativeFullscreen` 这个进程级会话所有，谁来问都答得出。这里只留一句
/// 「你接手的时候窗口已经是全屏了」——新页据此跳过"重拍进全屏前几何"那一步。
class VideoFullscreenHandoff {
  final bool nativeFullscreenActive;

  const VideoFullscreenHandoff({this.nativeFullscreenActive = true});
}
