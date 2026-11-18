import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/ui/widgets/cached_list_image.dart';

const _url = 'https://example.invalid/thumbnail.jpg';
const _headers = {'Referer': 'https://example.invalid/'};
const _placeholder = Key('thumbnail loading');
const _error = Key('thumbnail failed');

Future<void> _mount(WidgetTester tester, Completer<ImageInfo> pending) async {
  // Intercept the real resize/cache key so the test can drive an asynchronous
  // decode without network, platform plugins or a substitute image widget.
  final provider = ResizeImage(
    const CachedNetworkImageProvider(
      _url,
      headers: _headers,
      maxWidth: 400,
      maxHeight: 400,
    ),
    width: 160,
  );
  final key = await provider.obtainKey(ImageConfiguration.empty);
  PaintingBinding.instance.imageCache.putIfAbsent(
    key,
    () => OneFrameImageStreamCompleter(pending.future),
  );
  addTearDown(() => PaintingBinding.instance.imageCache.evict(key));
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 160,
          height: 90,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedListImage(
              imageUrl: _url,
              httpHeaders: _headers,
              memCacheWidth: 160,
              maxWidthDiskCache: 400,
              maxHeightDiskCache: 400,
              placeholder: (_, _) => const SizedBox.expand(key: _placeholder),
              errorWidget: (_, _, _) => const SizedBox.expand(key: _error),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'an asynchronously decoded thumbnail paints without a fade layer',
    (tester) async {
      final pending = Completer<ImageInfo>();
      await _mount(tester, pending);
      expect(find.byKey(_placeholder), findsOneWidget);
      final resize =
          tester.widget<Image>(find.byType(Image)).image as ResizeImage;
      final cached = resize.imageProvider as CachedNetworkImageProvider;
      expect(resize.width, 160);
      expect(cached.headers, _headers);
      expect(cached.maxWidth, 400);
      expect(cached.maxHeight, 400);

      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(const Color(0xFF22AA33), ui.BlendMode.src);
      final picture = recorder.endRecording();
      pending.complete(ImageInfo(image: picture.toImageSync(2, 2)));
      picture.dispose();
      await tester.pump();
      await tester.pump();

      expect(find.byKey(_placeholder), findsNothing);
      expect(find.byType(RawImage), findsOneWidget);
      expect(tester.layers.whereType<OpacityLayer>(), isEmpty);
      expect(tester.layers.whereType<ClipRRectLayer>(), isEmpty);
    },
  );

  testWidgets(
    'thumbnail failures replace the placeholder with the error slot',
    (tester) async {
      final pending = Completer<ImageInfo>();
      await _mount(tester, pending);
      pending.completeError(StateError('fixture decode failed'));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(_placeholder), findsNothing);
      expect(find.byKey(_error), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
