import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/app/services/external_player_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/desktop_player_manager_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 打开「用其他应用打开」面板，把 [source] 转交给本机其它播放器。
///
/// 面板本身不判断有没有可用播放器（Android 上会数，但空列表也照样把入口摆出来
/// 并在点下去后给一条明确提示）——「装了播放器但没被系统索引到」比「真没装」
/// 更常见，直接隐藏入口会让用户以为功能没做。
Future<void> showExternalPlayerSheet(ExternalPlayerSource source) async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  await showGlassBottomSheet<void>(
    context: context,
    builder: (_) => _ExternalPlayerSheet(source: source),
  );
}

/// 「用其他应用打开」面板。
///
/// # 版式约定：**填色 = 能点，不填色 = 说明**
///
/// 2026-08-30 重做。收口前是「一段总说明 + 三四行 `ListTile`（每行都带副标题）
/// + 底部两条 hint」，问题有三条，都不是靠改文案能解决的：
///
///   1. **说明比动作多**。总说明、每行副标题、两条 hint 一共六块散文，真正的
///      动作只有两三个，读者得先读完一屏字才知道能点什么。
///   2. **点不出来**。`ListTile` 在不透明面板上就是几行左对齐的文字，与上面那
///      段说明视觉重量一样——用户（尤其头显/桌面端）根本看不出那是控件。
///   3. **主次不分**。「管理外部播放器」（跳设置）和「把视频交出去」（本面板
///      唯一目的）同一种行式样、同一个权重。
///
/// 现在的规矩：
///
///   - **动作一律是填色块**（[_ActionTile]）：色块 + 图标底片 + 右侧 `›`，
///     一眼能认出是控件。**几块之间不分档**——曾经给「平台当下最该走的那条
///     路」填过 `primaryContainer`，但那在 M3 里是「已选中容器」的颜色（选中
///     的导航项、选中的 chip 都是它），面板里根本没有选中态，读起来就成了
///     「这一项已经被选上了」。优先级由**顺序**表达，不由颜色表达。
///   - **信息一律不填色**：顶部「交出去的是哪一份」只有一行眉标 + 视频名，
///     底部至多一条脚注。二者都没有边框/底色，与色块自然分层。
///   - **散文预算：两行**。行内说明只留「复制链接」那条（它承载的是 VR 播放器
///     的用法，本功能的立身之本），脚注只在在线直链时出现（时效警告会改变用户
///     的决定：先下载再转交）。总说明、「弹出系统选择器」「交给系统关联的默认
///     视频程序」这类复述标题的副标题、与行内说明重复的 VR hint 全部删掉——
///     对应的 i18n key 仍在词库里，别再接回来。
///
/// 面板壳（[showGlassBottomSheet]）把子树钉在 [GlassBackend.plain]，所以这里
/// 的色块用普通 `Material` + `InkWell`（有水波纹）而不是 `GlassSurface`：
/// 内容装在 `SingleChildScrollView` 里，玻璃不该进滚动容器。
class _ExternalPlayerSheet extends StatefulWidget {
  const _ExternalPlayerSheet({required this.source});

  final ExternalPlayerSource source;

  @override
  State<_ExternalPlayerSheet> createState() => _ExternalPlayerSheetState();
}

class _ExternalPlayerSheetState extends State<_ExternalPlayerSheet> {
  ExternalPlayerSource get source => widget.source;

  /// 桌面端用户自己配的播放器（PCVR 播放器全靠这条路）。移动端恒为空。
  ///
  /// ⛔ 不能是 `late final`：管理弹窗就地开在本面板上面（见 [_openPlayerManager]），
  /// 配完要当场重读，面板才会立刻多出那一行。
  List<DesktopPlayerEntry> _desktopPlayers = GetPlatform.isDesktop
      ? DesktopPlayerStore.load()
      : const [];

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 桌面端没有「用其它应用打开」的选择器，只有「交给系统默认程序」。
    final bool isDesktop = GetPlatform.isDesktop;
    final bool canHandOff = ExternalPlayerService.supports(source);

    final actions = <Widget>[
      // 桌面端：先列用户配置的播放器（本地文件和在线直链都能交给它们），
      // 「系统默认程序」反而是次选——PCVR 播放器不是系统默认关联程序。
      for (final player in _desktopPlayers)
        _ActionTile(
          icon: Icons.smart_display_outlined,
          label: t.externalPlayer.openWithNamed(name: player.name),
          onTap: () => _handOffToDesktopPlayer(context, t, player),
        ),
      if (canHandOff)
        _ActionTile(
          icon: isDesktop ? Icons.play_circle_outline : Icons.apps,
          label: isDesktop
              ? t.externalPlayer.openWithSystemPlayer
              : t.externalPlayer.openWithOtherApp,
          onTap: () => _handOff(context, t),
        ),
      if (!source.isLocalFile)
        _ActionTile(
          icon: Icons.link,
          label: t.externalPlayer.copyLink,
          // 唯一保留的行内说明：它就是 VR 播放器（Skybox / DeoVR）的用法，
          // 放在它解释的那个控件旁边，而不是塞进面板底部当第七块散文。
          note: t.externalPlayer.copyLinkDescription,
          showChevron: false,
          onTap: () => _copyLink(context, t),
        ),
      // 一个播放器都没配的桌面端：这条不是「设置入口」而是**唯一出路**
      // （PCVR 播放器够不着系统关联），所以留在动作区、按动作的样子画。
      // 已经配过的情况下它退成底部的一行文字（见下面的 _ManageFooter）。
      if (isDesktop && _desktopPlayers.isEmpty)
        _ActionTile(
          icon: Icons.add,
          label: t.externalPlayer.managePlayers,
          note: t.externalPlayer.noPlayerConfigured,
          onTap: _openPlayerManager,
        ),
    ];

    return GlassBottomSheet(
      title: t.externalPlayer.title,
      scrollable: true,
      maxHeightFactor: 0.8,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SourceLine(source: source),
          const SizedBox(height: 16),
          for (final (index, action) in actions.indexed) ...[
            if (index > 0) const SizedBox(height: 8),
            action,
          ],
          // 在线直链的时效警告是唯一会改变用户决定的提示（先下载再转交），
          // 所以它留下；本地文件没有这个问题，那一档下面板干净收尾。
          if (!source.isLocalFile) ...[
            const SizedBox(height: 14),
            _Footnote(text: t.externalPlayer.onlineLinkExpiryHint),
          ],
          if (isDesktop && _desktopPlayers.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ManageFooter(
              label: t.externalPlayer.managePlayers,
              detail: t.externalPlayer.playerCount(
                count: _desktopPlayers.length,
              ),
              onTap: _openPlayerManager,
            ),
          ],
        ],
      ),
    );
  }

  /// 就地开管理弹窗，**不离开播放页**。
  ///
  /// ⛔ 上一版是 `Navigator.pop()` 关掉本面板 + `appRouter.push(设置页)`：用户
  /// 正在看视频，点一下「管理外部播放器」就被整页扔进设置里，还得自己在那儿再
  /// 点一次才弹出这只弹窗——两层跳转换来的是同一个弹窗，而视频那边的上下文全丢了
  /// （2026-08-30 用户报障：「点击后跳到设置页就不明所谓了」）。
  ///
  /// 配完当场重读列表：新配的播放器要立刻出现在上面的动作区，否则用户配完回到
  /// 面板发现什么也没变，只会以为没配上。无条件重读——配置就在内存里，一次小
  /// JSON 解码而已，比让弹窗回传一个「改过没」的信号可靠（那个信号会在关闭钮
  /// 那条路上丢，见 [showDesktopPlayerManagerDialog]）。
  Future<void> _openPlayerManager() async {
    await showDesktopPlayerManagerDialog(context);
    if (!mounted) return;
    setState(() => _desktopPlayers = DesktopPlayerStore.load());
  }

  Future<void> _copyLink(
    BuildContext context,
    slang.Translations t,
  ) async {
    await Clipboard.setData(ClipboardData(text: source.value));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    showGlassToast(t.externalPlayer.linkCopied);
  }

  Future<void> _handOffToDesktopPlayer(
    BuildContext context,
    slang.Translations t,
    DesktopPlayerEntry player,
  ) async {
    final navigator = Navigator.of(context);
    final result = await ExternalPlayerService.openWithDesktopPlayer(
      player,
      source,
    );
    if (navigator.mounted) navigator.pop();
    _reportResult(t, result);
  }

  Future<void> _handOff(BuildContext context, slang.Translations t) async {
    final navigator = Navigator.of(context);
    final result = await ExternalPlayerService.open(
      source,
      chooserTitle: t.externalPlayer.title,
    );
    if (navigator.mounted) navigator.pop();
    _reportResult(t, result);
  }

  void _reportResult(
    slang.Translations t,
    ExternalPlayerHandoffResult result,
  ) {
    switch (result.status) {
      case ExternalPlayerHandoffStatus.handedOff:
        showGlassToast(t.externalPlayer.handedOff);
      case ExternalPlayerHandoffStatus.noHandler:
        showGlassToast(
          t.externalPlayer.noHandler,
          type: GlassToastType.warning,
        );
      case ExternalPlayerHandoffStatus.unsupported:
        showGlassToast(
          t.externalPlayer.noHandler,
          type: GlassToastType.warning,
        );
      case ExternalPlayerHandoffStatus.fileMissing:
        showGlassToast(
          t.externalPlayer.localFileMissing,
          type: GlassToastType.error,
        );
      case ExternalPlayerHandoffStatus.executableMissing:
        showGlassToast(
          t.externalPlayer.executableMissing,
          type: GlassToastType.error,
        );
      case ExternalPlayerHandoffStatus.failed:
        final message = result.message;
        showGlassToast(
          message == null || message.isEmpty
              ? t.externalPlayer.handoffFailedUnknown
              : t.externalPlayer.handoffFailed(message: message),
          type: GlassToastType.error,
        );
    }
  }
}

/// 面板里的一个动作：填色块 + 图标底片 + 标题（+ 一行说明）+ 右侧 `›`。
///
/// 「点不出来」是这张面板被返工的直接原因，所以可点性由三样东西同时表达：
/// 填色（与不填色的说明区分层）、图标底片（主色，动作的身份）、右侧箭头
/// （「按下去会开出点什么」）。少任何一样都退回成「一行字」。
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.note,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;

  /// 行内说明。**只在标题真的说不清时才给**——复述标题的副标题一律不要。
  final String? note;

  final VoidCallback onTap;

  /// 右侧的 `›`。会「开出另一个界面」的动作才有（系统选择器、外部播放器、
  /// 跳设置）；就地完成的动作（复制链接）没有。
  final bool showChevron;

  /// 内外圆角同心：外 20 = 图标底片 12 + 竖向内边距 8。
  static const double _radius = 20;
  static const double _badgeRadius = 12;
  static const double _badgeSize = 40;
  static const double _verticalPadding = 8;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ⛔ 别再按「推荐/次要」给这里分档色。主色容器 = 选中态，面板里没有选中态。
    // 主色只出现在图标底片上（每块都一样，占比约一成），它表达的是「这是个
    // 动作」的身份，不是「这一个被挑中了」。
    final Color background = cs.surfaceContainerHighest.withValues(alpha: 0.5);
    final Color foreground = cs.onSurface;
    final Color badgeBackground = cs.primary.withValues(alpha: 0.12);
    final Color badgeForeground = cs.primary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: _verticalPadding,
          ),
          child: Row(
            children: [
              Container(
                width: _badgeSize,
                height: _badgeSize,
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(_badgeRadius),
                ),
                child: Icon(icon, size: 20, color: badgeForeground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                    if (note != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        note!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: foreground.withValues(alpha: 0.68),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: foreground.withValues(alpha: 0.45),
                ),
              ],
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// 交出去的到底是哪一份：本地文件，还是当前清晰度的在线直链。
///
/// 这是面板里唯一「用户不知道、又必须知道」的事实（转交走的是离线优先的那一
/// 份，不一定是他以为的那份），所以它留在最上面；但它是信息不是控件，因此
/// **不填色、不描边**——收口前那枚 primaryContainer 药丸看起来像个能点的按钮。
class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source});

  final ExternalPlayerSource source;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final String kind;
    if (source.isLocalFile) {
      kind = t.externalPlayer.sourceLocal;
    } else if (source.qualityTag != null && source.qualityTag!.isNotEmpty) {
      kind = t.externalPlayer.sourceOnlineWithQuality(
        quality: source.qualityTag!,
      );
    } else {
      kind = t.externalPlayer.sourceOnline;
    }

    final String? title = source.title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              source.isLocalFile
                  ? Icons.sd_storage_outlined
                  : Icons.cloud_queue,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                kind,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (title != null && title.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// 面板底部的单条脚注。**至多一条**——多了就退回成收口前那种「读完一屏字才
/// 知道能点什么」。
class _Footnote extends StatelessWidget {
  const _Footnote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline,
            size: 13,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: cs.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

/// 「管理外部播放器」：已经配过播放器时它只是个设置入口，不该和转交动作抢
/// 权重，所以退成一行可点的文字（仍留 44 高的点击区）。
class _ManageFooter extends StatelessWidget {
  const _ManageFooter({
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
