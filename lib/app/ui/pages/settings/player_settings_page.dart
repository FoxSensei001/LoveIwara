import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/player_settings_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_gesture_guide.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class PlayerSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const PlayerSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double maxWidth = MediaQuery.of(context).size.width > 800
        ? 800
        : MediaQuery.of(context).size.width;
    // 仅使用 CustomScrollView 一层滚动，避免内嵌 SingleChildScrollView 造成
    // 「外层 margin 区与内层列表各自滚动」的双层滚动冲突。
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.playerSettings,
            isWideScreen: isWideScreen,
            actions: [
              IconButton(
                tooltip: t.videoDetail.gestureGuide.viewGuide,
                icon: const Icon(Icons.help_outline),
                onPressed: () => VideoGestureGuideDialog.show(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: PlayerSettingsWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
