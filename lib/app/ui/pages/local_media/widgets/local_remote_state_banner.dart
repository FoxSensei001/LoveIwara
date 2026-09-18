import 'package:flutter/material.dart';

import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// NAS 源此刻用不了：说清原因，出路就摆在原因旁边。
///
/// 以前目录页对此一声不吭——扫描失败只落日志，用户看着旧内容或一句「还没扫描过」，
/// 不知道是连不上，更不知道该去哪修（「重新登录」藏在来源卡的 ⋮ 里）。
///
/// 连不上只给「重试」；登录失效 / 证书变了 / 读不出密码，重试多少次都一样，
/// 所以把「重新登录」放在最前面。
class LocalRemoteStateBanner extends StatelessWidget {
  const LocalRemoteStateBanner({
    super.key,
    required this.source,
    required this.onRetry,
    this.busy = false,
  });

  final LocalMediaSource source;

  /// 重试（重列这一层）。重新登录成功后也走它。
  final VoidCallback onRetry;
  final bool busy;

  /// 这个源该不该挂横幅。
  static bool shouldShow(LocalMediaSource? source) {
    if (source == null || !source.isRemote) return false;
    final state = source.remoteState;
    return state != null && state != LocalMediaRemoteState.ok;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.t.localMedia.webdav;
    final state = source.remoteState ?? LocalMediaRemoteState.unreachable;
    final needsLogin = state != LocalMediaRemoteState.unreachable;
    final text = switch (state) {
      LocalMediaRemoteState.authFailed => t.bannerAuthFailed,
      LocalMediaRemoteState.certUntrusted => t.bannerCertUntrusted,
      LocalMediaRemoteState.credUnreadable => t.bannerCredUnreadable,
      LocalMediaRemoteState.unreachable ||
      LocalMediaRemoteState.ok => t.bannerUnreachable,
    };
    final tone = theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            needsLogin ? Icons.key_off_outlined : Icons.cloud_off_outlined,
            size: 18,
            color: tone,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          const SizedBox(width: 8),
          GlassButtonGroup(
            children: [
              if (needsLogin)
                GlassTextActionButton(
                  label: t.relogin,
                  emphasized: true,
                  onPressed: busy
                      ? null
                      : () async {
                          final ok = await reloginRemoteSource(
                            context: context,
                            source: source,
                          );
                          if (ok) onRetry();
                        },
                ),
              GlassTextActionButton(
                label: slang.t.common.retry,
                emphasized: !needsLogin,
                onPressed: busy ? null : onRetry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
