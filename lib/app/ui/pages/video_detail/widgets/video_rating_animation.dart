import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VideoRatingAnimation extends StatelessWidget {
  const VideoRatingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Animate(
          effects: [
            FadeEffect(
              duration: .8.seconds,
              curve: Curves.linear,
              begin: 1,
              end: 0.5,
            ),
          ],
          onComplete: (controller) => controller.repeat(reverse: true),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
        ),
        // Second play arrow
        Animate(
          effects: [
            FadeEffect(
              duration: .8.seconds,
              curve: Curves.linear,
              begin: 0.5,
              end: 1,
            ),
          ],
          onComplete: (controller) => controller.repeat(reverse: true),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}