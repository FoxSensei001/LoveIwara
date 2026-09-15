import 'package:flutter/services.dart' show appFlavor;
import 'package:get/get.dart';

import 'package:i_iwara/app/services/xr_immersive_service.dart';

/// 「这台机器上，空间形态在不在」的统一问法。
///
/// # 两种问法，各有各的场合
///
/// - [xrImmersiveAvailableNow]：**能力判定**，问的是沉浸场景此刻活着没有。UI 上
///   一切「露不露这枚钮 / 这块设置」都用它 —— 它在普通安卓与桌面上恒为 false
///   （那条通道根本没注册），所以调用点不必知道自己跑在什么设备上。这是本仓库
///   一贯的规矩，见 `XrPanelSettingsButton` 的注释。
/// - [kIsQuestBuild]：**编译期变体**。只在「答案必须当场拿到、等不起那次异步
///   询问」的地方用 —— 场景可用性是 [XrImmersiveService.refreshAvailability] 异步
///   问出来的，冷启动头几帧它还是 false。首次启动引导页恰好长在那几帧里，步骤
///   清单只装配一次，所以那里问变体而不是问能力。
const bool kIsQuestBuild = appFlavor == 'quest';

/// 沉浸场景此刻可用。**非响应式**：这是一次普通读取，不会让调用方随场景生死重建。
///
/// 够用的理由：场景的生死只发生在「进 / 出沉浸空间」那一刻，而那一刻整块 Flutter
/// 面板都跟着走，不存在「用户正盯着设置页、场景在他眼皮底下没了」这回事。要响应式
/// 的地方（如侧栏那枚面板钮）直接在 `Obx` 里读 [XrImmersiveService.available]，
/// 并记得把 `Get.isRegistered` 那半句留在 `Obx` **外面**（短路会让 Obx 首帧读不到
/// 任何 Rx，GetX 会抛 improper use）。
bool get xrImmersiveAvailableNow =>
    Get.isRegistered<XrImmersiveService>() &&
    Get.find<XrImmersiveService>().available.value;

/// 首次启动引导那类「冷启动就要定形、等不起异步答复」的场合专用。
///
/// quest 变体永远为真；其余平台退回能力判定（测试里可以注册一只假服务把它点亮）。
bool get xrSpatialFormFactor => kIsQuestBuild || xrImmersiveAvailableNow;
