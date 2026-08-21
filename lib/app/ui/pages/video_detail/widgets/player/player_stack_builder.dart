import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Builds the player stack with reactive tracking only when its topology can
/// actually change. GetX rejects an [Obx] builder that reads no Rx values.
class PlayerStackBuilder extends StatelessWidget {
  final bool observeChanges;
  final Widget Function() builder;

  const PlayerStackBuilder({
    super.key,
    required this.observeChanges,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (!observeChanges) {
      return builder();
    }
    return Obx(builder);
  }
}
