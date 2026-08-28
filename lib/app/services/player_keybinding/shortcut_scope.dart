/// 快捷键的作用域。
///
/// 一次按键的解析按「当前活动叶子作用域 → global」的顺序进行：
/// - [video] / [gallery] 等叶子界面激活时，优先在该作用域内匹配；
/// - 未命中再回退到 [global]（因此 Esc 返回等全局动作在视频/图库内仍可触发）。
///
/// 新增作用域（如论坛、列表）只需在此追加枚举值并注册对应动作，
/// 解析/冲突/持久化逻辑无需改动——但**必须同时在 [kScopeInputChannels] 里
/// 声明它受理哪些输入通道**，否则闸门测试会失败。
enum ShortcutScope { global, gallery, video }

/// 一个作用域可能受理的输入通道。
///
/// 分两类：
/// - **可绑定通道**（[keyboard] / [mouseButton]）：用户能在设置页录制成快捷键；
/// - **固定手势通道**（其余）：不可改键，设置页以「固定」卡片的形式告知用户。
enum ShortcutInputChannel {
  /// 键盘按下（`KeybindingService.resolve`）。
  keyboard,

  /// 鼠标中键 / 后退键 / 前进键（`KeybindingService.resolvePointer`）。
  mouseButton,

  /// Ctrl + 滚轮缩放画面。
  wheelZoom,

  /// Shift + 滚轮旋转画面。
  wheelRotate,

  /// 双指捏合缩放画面。
  pinchZoom,

  /// 双指旋转画面。
  twoFingerRotate,
}

/// **「作用域 × 输入通道」声明表——本系统的单一真相。**
///
/// 这张表存在的理由：在此之前，「某个作用域到底受理哪些输入通道」这件事没有
/// 权威来源，运行时各自接线、设置页却对所有作用域一视同仁地承诺同一套能力，
/// 于是产生了一整族「设置页答应了、运行时做不到」的缺陷：
/// 在全局/图库绑鼠标侧键能绑上却永不触发、图库设置里写着「旋转画面」而图库
/// 根本没有旋转能力。
///
/// 现在两侧都从这张表推导：
/// - **设置页**据此决定能不能录鼠标键、显不显示鼠标提示、固定手势卡片显示哪几行；
/// - **持久化层**据此在加载与编辑时剔除该作用域根本不受理的绑定；
/// - **闸门测试** `scope_input_channels_test.dart` 反过来校验声明与运行时接线一致
///   （声明了 [ShortcutInputChannel.mouseButton] 就必须真的存在对应的
///   `resolvePointer` 调用点，反之亦然）。
///
/// 改这张表 = 改产品承诺，因此每一项都要有真实接线支撑。
const Map<ShortcutScope, Set<ShortcutInputChannel>> kScopeInputChannels = {
  // 全局只有一个 Focus.onKeyEvent（my_app.dart 的 `_shortCutsWrapper`），
  // 没有任何指针监听，也没有固定手势。
  ShortcutScope.global: {ShortcutInputChannel.keyboard},

  // 图库：键盘走 `_handleKeyPress`；Ctrl+滚轮与双指捏合缩放由 PhotoView 一侧提供。
  // 图库**没有**旋转能力（PhotoView 未开 enableRotation，也没有 Shift+滚轮分支），
  // 因此不声明 wheelRotate / twoFingerRotate。
  ShortcutScope.gallery: {
    ShortcutInputChannel.keyboard,
    ShortcutInputChannel.wheelZoom,
    ShortcutInputChannel.pinchZoom,
  },

  // 视频：全通道。鼠标键是全应用唯一真正受理指针快捷键的作用域。
  ShortcutScope.video: {
    ShortcutInputChannel.keyboard,
    ShortcutInputChannel.mouseButton,
    ShortcutInputChannel.wheelZoom,
    ShortcutInputChannel.wheelRotate,
    ShortcutInputChannel.pinchZoom,
    ShortcutInputChannel.twoFingerRotate,
  },
};

/// 该作用域受理的输入通道（表里必然有值，缺失即为编码错误）。
Set<ShortcutInputChannel> inputChannelsOf(ShortcutScope scope) =>
    kScopeInputChannels[scope] ?? const {};

/// 该作用域是否受理鼠标按键绑定。
///
/// 为 false 时，设置页不得让用户录制鼠标组合——录了也永远不会触发。
bool scopeAcceptsMouseButtons(ShortcutScope scope) =>
    inputChannelsOf(scope).contains(ShortcutInputChannel.mouseButton);

/// 该作用域是否支持「缩放画面」这一组固定手势。
bool scopeSupportsFixedZoom(ShortcutScope scope) {
  final channels = inputChannelsOf(scope);
  return channels.contains(ShortcutInputChannel.wheelZoom) ||
      channels.contains(ShortcutInputChannel.pinchZoom);
}

/// 该作用域是否支持「旋转画面」这一组固定手势。
bool scopeSupportsFixedRotate(ShortcutScope scope) {
  final channels = inputChannelsOf(scope);
  return channels.contains(ShortcutInputChannel.wheelRotate) ||
      channels.contains(ShortcutInputChannel.twoFingerRotate);
}

/// 该作用域是否有任何固定手势可展示（决定设置页要不要渲染那张「固定」卡片）。
bool scopeHasFixedGestures(ShortcutScope scope) =>
    scopeSupportsFixedZoom(scope) || scopeSupportsFixedRotate(scope);
