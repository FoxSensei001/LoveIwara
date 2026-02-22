# Android Predictive Back Gesture - 方案 A 实施计划

## 概述
在保留现有功能（双击退出、视频自动暂停、亮度恢复）的前提下，启用 Android 预测式返回手势。

## 改动文件清单

### 1. AndroidManifest.xml
- 在 `<application>` 标签添加 `android:enableOnBackInvokedCallback="true"`

### 2. home_navigation_layout.dart（核心改动）

#### 2a. 嵌套 Navigator 包裹 NavigatorPopHandler
- 在 `Navigator(key: AppService.homeNavigatorKey, ...)` 外包裹 `NavigatorPopHandler`
- `onPopWithResult` 回调中调用 `homeNavigatorKey.currentState!.pop()`
- 确保 HomeNavigatorObserver 仍被正确注册

#### 2b. _NaviPopScope 重构
- `canPop` 从固定 `false` 改为动态计算：
  - 有 overlay（Dialog/BottomSheet）→ `true`（让系统处理）
  - 嵌套 Navigator 可 pop → `true`（由 NavigatorPopHandler 消费）
  - Home 根态 → `false`（保留双击退出，此场景无预测式预览）
- `onPopInvokedWithResult` 中：
  - `didPop == true` → 直接 return
  - 嵌套 Navigator 可 pop → return（避免与 NavigatorPopHandler 重复 pop）
  - 否则 → 走 ExitConfirmUtil.handleExit

#### 2c. HomeNavigatorObserver 空栈防护
- `didPop` 中 `removeLast()` 前判空
- `isHomeRoute` 相关方法增加空栈安全检查

### 3. exit_confirm_util.dart
- `isHomeRoute()` 增加空栈防护（routes 为空时返回 false）
- `handleExit()` 收敛作用域：仅在 Home 根态 + 无 overlay + 嵌套不可 pop 时触发双击确认

### 4. grid_speed_dial.dart
- `WillPopScope` → `PopScope`
- `canPop: !_open`（菜单展开时阻止返回）
- `onPopInvokedWithResult: (didPop, _) { if (!didPop && _open) _toggleChildren(); }`

### 5. app_service.dart（可选优化）
- `tryPop()` 返回 bool 表示是否已消费
- 拆分内部逻辑为小函数便于组合

### 6. settings_page.dart - 无改动
- 现有 `canPop` 动态计算已兼容预测式返回

### 7. my_video_screen.dart - 无改动
- 现有 PopScope 逻辑兼容，全屏时允许 pop

### 8. oreno3d_video_card.dart - 无改动
- `canPop: false` 的加载弹窗保留现有行为

## 不受影响的功能
- 视频自动暂停：HomeNavigatorObserver routeChangeCallback 链路不变
- 亮度恢复：setDefaultBrightness/resetBrightness 触发条件不变
- 全屏视频返回：my_video_screen PopScope 不修改
- 设置页内部导航：动态 canPop 已兼容

## 预期行为
| 场景 | 预测式动画 | 行为 |
|------|-----------|------|
| App 内子页面返回 | 有 | 滑动预览上一页，松手确认 |
| Home 根态退出 | 无（回弹） | 首次返回弹 Toast，5秒内再按退出 |
| 视频全屏返回 | 有 | 退出全屏 |
| 设置页内部返回 | 有 | 返回上一级设置 |
| SpeedDial 展开 | 无（回弹） | 关闭菜单 |
| Dialog/弹窗 | 有 | 关闭弹窗 |

## 实施顺序
1. AndroidManifest.xml
2. exit_confirm_util.dart（空栈防护）
3. home_navigation_layout.dart（NavigatorPopHandler + _NaviPopScope 重构）
4. grid_speed_dial.dart（WillPopScope 迁移）
5. app_service.dart（可选优化）
