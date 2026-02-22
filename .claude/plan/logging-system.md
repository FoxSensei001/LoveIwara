# 实施计划：日志收集与诊断反馈系统

> 综合 Codex（后端架构）+ Gemini（UI/UX 设计）双模型分析，由 Claude 最终整合

## 背景

### 问题来源
- **Issue #80**：Windows 11 视频播放时应用卡死（黑屏有音频，整个 UI 无响应），用户只能强制关闭
- **Issue #79**：Android/Xiaomi 设备拉取视频后闪退，约每 5 次播放崩溃 1 次

### 根本原因
当前日志系统（`LogUtils`）仅支持控制台输出，**零持久化**。崩溃/卡死后所有日志证据丢失，开发者无法远程诊断，用户无法提供有效反馈。

### 现状分析
| 组件 | 状态 | 文件 |
|------|------|------|
| `LogUtils` | 仅控制台输出，`getRecentLogs()`/`exportLogFileEnhanced()` 为占位实现 | `lib/utils/logger_utils.dart` |
| 全局错误捕获 | 存在但未持久化（`runZonedGuarded` + `FlutterError.onError`） | `lib/main.dart:59-132` |
| SQLite 日志 | 已在 migration_v10 中移除 | `lib/db/migrations/migration_v10_remove_logs.dart` |
| 视频播放器 | 错误处理完善但仅输出到控制台 | `lib/app/ui/pages/video_detail/controllers/my_video_state_controller.dart` |

---

## 任务类型
- [x] 后端 (日志服务核心架构)
- [x] 前端 (诊断页面、日志查看器、崩溃恢复对话框)

---

## 技术方案

### 核心决策
1. **异步队列 + JSONL 文件轮转**（非数据库方案）
2. **内存环形缓冲（500 条）** + 异步写队列 + Isolate 文件 I/O
3. **按大小轮转**：单文件 5MB，保留 3 个文件（总上限 ~15MB）
4. **Error/Fatal 立即 flush**，普通日志批量刷盘
5. **统一脱敏管线**：自动遮蔽 token/email/手机号/URL query
6. **崩溃标记文件**：启动写入 → 正常退出删除 → 异常退出保留 → 下次启动检测

### 数据流

```
LogUtils.d/i/w/e (现有 API 不变)
  → LogService.log()
    → LogProcessor.sanitize + throttle + dedup
      → LogBuffer (ring:500 + async queue)
        → LogFileSink (Isolate append JSONL)
          → rotate (5MB, keep 3)
```

---

## 实施步骤

### Step 1：定义数据模型与常量

**新建文件**：`lib/app/services/logging/log_models.dart`

- `LogLevel` 枚举：debug, info, warning, error, fatal
- `LogEvent` 数据类：timestamp, level, tag, message, error, stackTrace, sessionId
- 常量配置：
  - `maxFileBytes = 5 * 1024 * 1024` (5MB)
  - `maxRotatedFiles = 3`
  - `ringBufferCapacity = 500`
  - `maxLogsPerSecond = 100`
  - `dedupWindowDuration = Duration(seconds: 5)`
  - 文件名：`app.log`, `app.log.1`, `app.log.2`
  - 崩溃标记：`crash_marker.json`

**新建文件**：`lib/app/services/logging/log_paths.dart`
- 基于 `path_provider` 的跨平台路径解析
- 日志目录：`{appDocDir}/logs/`
- 崩溃标记：`{appDocDir}/logs/crash_marker.json`

### Step 2：实现日志处理器（LogProcessor）

**新建文件**：`lib/app/services/logging/log_processor.dart`

处理流水线：
1. **标准化**：统一时间戳（UTC ISO8601）、附加 sessionId/platform/version
2. **脱敏**（正则替换）：
   - Authorization Bearer → `Bearer ***`
   - token/api_key/password/cookie → `***`
   - Email → `***@***`
   - URL query params → `?<redacted>`
   - 手机号 → `<phone_redacted>`
3. **速率限制**：滑动窗口 100 logs/sec，超限丢弃 debug/info 保留 warn/error
4. **错误去重**：5 秒窗口内相同 fingerprint 的 error 仅保留首条，窗口结束补 suppressed 计数
5. **输出**：序列化为 JSONL 行字符串

### Step 3：实现内存缓冲（LogBuffer）

**新建文件**：`lib/app/services/logging/log_buffer.dart`

- `ListQueue<LogEvent>` 环形缓冲，容量 500（供 UI 即时查看）
- `Queue<String>` 写入队列（JSONL 行）
- 批量 flush 触发条件：
  - 队列达到 50 条
  - 定时器 300ms
  - 遇到 error/fatal → 立即触发
- 高水位策略：队列 > 5000 时丢弃 debug/info，保留 warn/error

### Step 4：实现文件写入器（LogFileSink）

**新建文件**：`lib/app/services/logging/log_file_sink.dart`
**新建文件**：`lib/app/services/logging/log_isolate_worker.dart`

- Isolate 独立执行文件 I/O（主线程零阻塞）
- 主 Isolate 通过 SendPort/ReceivePort 发送批量 JSONL
- 轮转逻辑：
  - `app.log` 超 5MB → 删除 `app.log.2` → `app.log.1` 重命名为 `app.log.2` → `app.log` 重命名为 `app.log.1` → 新建空 `app.log`
- 容错：
  - 文件写入失败 → 降级到控制台 + 内存缓冲
  - Isolate 异常退出 → 自动重启一次，再失败则禁用持久化并告警
  - 损坏 JSONL → 逐行解析，跳过坏行并计数

### Step 5：实现崩溃检测服务（CrashDetectionService）

**新建文件**：`lib/app/services/logging/crash_detection_service.dart`

- **启动**：写入 `crash_marker.json`（含 sessionId, startAt, version, platform）
- **正常退出**：删除 marker 文件
- **崩溃恢复**：下次启动检测 marker 文件
  - 存在 → 读取上次会话信息 → 标记 `hadUncleanExit = true`
  - 弹出恢复对话框（见 Step 9）
  - 覆盖写入新会话 marker

### Step 6：实现日志导出服务（LogExportService）

**新建文件**：`lib/app/services/logging/log_export_service.dart`

导出 ZIP 包内容：
```
loveiwara_logs_{timestamp}.zip
├── logs/
│   ├── app.log
│   ├── app.log.1
│   └── app.log.2
├── meta/
│   ├── device.json      (平台、机型、OS 版本、屏幕分辨率)
│   ├── app.json          (应用版本、build number、session ID)
│   └── export.json       (导出时间、日志条数、覆盖时间范围)
└── crash/
    └── last_crash.json   (上次崩溃信息，如有)
```

- 导出路径：`getTemporaryDirectory()` 下生成 ZIP
- 平台适配：
  - Mobile → `Share.shareXFiles([XFile(path)])` (share_plus)
  - Desktop → `FilePicker.platform.saveFile()` (file_selector)

### Step 7：实现日志服务主体（LogService）

**新建文件**：`lib/app/services/logging/log_service.dart`

```dart
class LogService extends GetxService {
  // 组件持有
  late LogProcessor _processor;
  late LogBuffer _buffer;
  late LogFileSink _sink;
  late LogExportService _export;
  late CrashDetectionService _crash;
  late String _sessionId;

  // 公开 API
  Future<LogService> init();
  void log({required LogLevel level, required String message, ...});
  Future<void> flush();
  Future<void> close();
  List<LogEvent> getRecentLogs({int count = 500});
  Future<File> exportLogs({int days = 7});
  CrashRecoveryResult? get lastCrashInfo;
}
```

初始化流程：
1. 生成 sessionId (UUID)
2. 解析日志路径
3. 初始化 LogProcessor、LogBuffer、LogFileSink(Isolate)
4. 初始化 CrashDetectionService → 检测并恢复
5. 绑定 Buffer → Sink 数据管道
6. 标记初始化完成

### Step 8：改造现有代码（集成点）

#### 8.1 `lib/utils/logger_utils.dart`
- **保留**现有 `d/i/w/e` 签名和控制台输出
- **新增**：在每个方法中检查 `Get.isRegistered<LogService>()`，找到则委托
- **修复** `getRecentLogs()`：委托 `LogService.getRecentLogs()`
- **修复** `exportLogFileEnhanced()`：委托 `LogService.exportLogs()`

#### 8.2 `lib/main.dart`
- 在 `WidgetsFlutterBinding.ensureInitialized()` 后注册 `LogService`（需在其他业务服务前）
- 新增 `PlatformDispatcher.instance.onError` 全局捕获
- `runZonedGuarded` 和 `FlutterError.onError` 转发到 `LogService.log(level: error, ...)`
- 退出流程 `_closeServices()` 增加：`await logService.flush()` + `logService.crash.markCleanExit()`
- 启动后检查崩溃恢复状态 → 弹出 CrashRecoveryDialog

#### 8.3 `lib/app/ui/pages/settings/settings_page.dart`
- 在 "其他设置" 分组新增 "诊断与反馈" 入口项（index 9）
- `_getSettingsPage()` 增加 case 9 → `DiagnosticsPage`

### Step 9：实现诊断页面（DiagnosticsPage）

**新建文件**：`lib/app/ui/pages/settings/diagnostics_page.dart`

布局：遵循现有设置子页面模式
- **响应式**：mobile (单列 ListView) / desktop (双列 Grid)
- **分区**：

| 区块 | 图标 | 标题 | 说明 | 操作 |
|------|------|------|------|------|
| 诊断信息 | `info_outline` | 诊断信息 | 显示设备型号、OS、应用版本、内存 | 展示 Card |
| 导出日志 | `upload_file` | 导出日志 | 保存或分享调试日志文件 | 一键导出 → 分享/保存 |
| 查看日志 | `visibility` | 查看日志 | 实时查看应用运行日志 | 跳转 LogViewerPage |
| 反馈问题 | `bug_report` | 反馈问题 | 提交 Bug 或功能建议 | 打开 GitHub Issues 或内部反馈 |

导出流程：
1. 显示加载指示器（CircularProgressIndicator）
2. 调用 `LogService.exportLogs()` 生成 ZIP
3. 平台判断 → share_plus / file_selector
4. 结果通知 → MDToastWidget (success/error)

### Step 10：实现日志查看器（LogViewerPage）

**新建文件**：`lib/app/ui/pages/settings/log_viewer_page.dart`

**功能**：
- **搜索栏**：AppBar 内 TextField，实时过滤
- **级别筛选**：FilterChip 行（全部 / Error / Warning / Info / Debug）
- **日志列表**：`ListView.builder` 虚拟化滚动
  - 颜色编码：Error=红色, Warning=橙色, Info=蓝色, Debug=灰色
  - 等宽字体 (`monospace`)，支持选中复制 (`SelectableText`)
  - 行格式：`[HH:mm:ss.SSS] [LEVEL] [TAG] message`
- **FAB**：跳转到底部
- **AppBar 操作**：
  - 分享按钮（导出当前过滤视图）
  - 自动滚动开关

**状态管理**：GetX Controller
- `logs: RxList<LogEvent>` 来自 LogService 的环形缓冲
- `filterLevel: Rx<LogLevel?>` 当前筛选级别
- `searchQuery: RxString` 搜索关键词
- `autoScroll: RxBool` 自动滚动到底

### Step 11：实现崩溃恢复对话框（CrashRecoveryDialog）

**新建文件**：`lib/app/ui/pages/settings/widgets/crash_recovery_dialog.dart`

- 使用 `ResponsiveDialog`（>600px 弹窗, ≤600px 全屏 Scaffold）
- 标题：「应用异常退出」
- 正文：「我们检测到应用上次异常退出。您可以将崩溃报告分享给开发者，帮助我们修复问题。」
- 隐私声明：「报告包含设备信息和应用日志，不包含个人数据」
- 操作按钮：
  - 「忽略」(TextButton) → 关闭对话框
  - 「查看详情」(OutlinedButton) → 打开 LogViewerPage
  - 「分享报告」(FilledButton) → 触发导出分享流程

### Step 12：上下文错误引导

在视频播放控制器 `my_video_state_controller.dart` 中：
- 维护错误计数器 `_playbackErrorCount`
- 当连续播放失败 ≥ 3 次时，显示 SnackBar：
  - 「播放持续遇到问题？」+ 「反馈问题」按钮
  - 点击跳转到诊断页面或直接触发日志导出

---

## 关键文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/app/services/logging/log_models.dart` | 新建 | 数据模型与常量定义 |
| `lib/app/services/logging/log_paths.dart` | 新建 | 跨平台路径解析 |
| `lib/app/services/logging/log_processor.dart` | 新建 | 脱敏、限流、去重处理器 |
| `lib/app/services/logging/log_buffer.dart` | 新建 | 内存环形缓冲 + 异步写队列 |
| `lib/app/services/logging/log_file_sink.dart` | 新建 | JSONL 文件写入器 |
| `lib/app/services/logging/log_isolate_worker.dart` | 新建 | Isolate 文件 I/O 工作者 |
| `lib/app/services/logging/crash_detection_service.dart` | 新建 | 崩溃标记与恢复检测 |
| `lib/app/services/logging/log_export_service.dart` | 新建 | ZIP 打包导出服务 |
| `lib/app/services/logging/log_service.dart` | 新建 | 日志服务主体（GetxService） |
| `lib/app/ui/pages/settings/diagnostics_page.dart` | 新建 | 诊断页面 UI |
| `lib/app/ui/pages/settings/log_viewer_page.dart` | 新建 | 日志查看器页面 |
| `lib/app/ui/pages/settings/widgets/crash_recovery_dialog.dart` | 新建 | 崩溃恢复对话框 |
| `lib/utils/logger_utils.dart` | 修改 | 委托到 LogService，修复占位方法 |
| `lib/main.dart` | 修改 | 注册 LogService、崩溃标记生命周期、PlatformDispatcher.onError |
| `lib/app/ui/pages/settings/settings_page.dart` | 修改 | 新增 "诊断与反馈" 导航入口 |
| `lib/app/ui/pages/video_detail/controllers/my_video_state_controller.dart` | 修改 | 添加上下文错误引导（播放失败 3 次提示反馈） |

---

## 隐私与性能

### 隐私脱敏规则
| 类型 | 正则模式 | 替换为 |
|------|---------|--------|
| Bearer Token | `(?i)(authorization\s*[:=]\s*bearer\s+)[a-z0-9\-._~+/]+=*` | `$1***` |
| 凭证键值 | `(?i)\b(access_token\|refresh_token\|token\|api_key\|secret\|password\|cookie)\b\s*[:=]\s*['"]?([^\s,'"}]+)` | `$1=***` |
| Email | `(?i)\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}\b` | `***@***` |
| URL Query | `(https?://[^\s?]+)\?[^\s]+` | `$1?<redacted>` |
| 手机号 | `(?<!\d)(?:\+?\d{1,3}[\s-]?)?(?:1[3-9]\d{9}\|\d{3}[\s-]?\d{3}[\s-]?\d{4})(?!\d)` | `<phone_redacted>` |

### 性能保障
- 主线程零文件 I/O（全部 Isolate 执行）
- 全局限流 100 logs/sec
- 5 秒窗口错误去重
- 视频播放器日志仅记录"状态变化"和关键错误，不记录高频帧事件
- 队列高水位丢弃策略：优先丢 debug/info，保留 warn/error
- 日志子系统内部错误使用 `debugPrint`，禁止递归调用 `LogUtils`

---

## 风险与缓解

| 风险 | 严重程度 | 缓解措施 |
|------|---------|----------|
| 视频播放时 I/O 抖动 | 高 | Isolate 隔离、批量写入、限流 |
| 导出日志包含敏感信息 | 高 | 统一脱敏管线，默认不记录请求 body |
| 进程被杀时丢失最后日志 | 中 | Error 立即 flush、崩溃标记文件 |
| 多平台路径/权限差异 | 中 | path_provider 统一 + 权限校验 |
| Isolate 异常退出 | 中 | 自动重启一次，再失败降级到控制台 |
| 磁盘空间不足 | 低 | 轮转策略总上限 15MB，导出前检查空间 |

---

## 测试策略

```
test/app/services/logging/
  log_processor_test.dart       # 脱敏、限流、去重
  log_buffer_test.dart          # 环形缓冲、flush 触发条件
  log_file_sink_test.dart       # 文件写入、轮转、恢复
  crash_detection_test.dart     # marker 读写、恢复流程
  log_export_service_test.dart  # ZIP 打包、空日志场景
  log_service_test.dart         # 端到端集成、降级行为
```

---

## 验收标准

1. 崩溃后重启可检测到异常退出，并可导出日志包
2. `LogUtils` 旧调用点零改动、零编译错误
3. 视频播放 30 分钟场景下，日志系统不引入可感知卡顿
4. 导出日志不包含明文 token、邮箱、手机号、URL query
5. 单文件最大 5MB，总保留不超过 3 文件
6. 设置页面可一键导出日志 ZIP 并分享
7. 日志查看器可按级别筛选、搜索、滚动浏览
8. 崩溃恢复对话框在异常退出后正确弹出

---

## SESSION_ID（供 /ccg:execute 使用）
- CODEX_SESSION: 019c7fa2-5b28-7e01-993c-d534b6c14b4b
- GEMINI_SESSION: 0b9b7e46-a34c-47b9-be50-6eb9b9b29a4c
