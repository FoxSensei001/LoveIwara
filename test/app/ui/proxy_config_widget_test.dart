import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/proxy_config_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class _MemoryConfig extends ConfigService {
  _MemoryConfig(String address) {
    for (final key in ConfigKey.values) {
      settings[key] = Rx<dynamic>(key.defaultValue);
    }
    settings[ConfigKey.PROXY_URL]!.value = address;
  }

  @override
  Future<void> saveSetting(ConfigKey key, dynamic value) async {}
}

Future<void> _pump(
  WidgetTester tester,
  ConfigService config, {
  bool compact = false,
  Brightness brightness = Brightness.light,
  double textScale = 1,
  GlobalKey? screenshotKey,
}) async {
  await tester.pumpWidget(
    InheritedLocaleData<AppLocale, Translations>(
      translations: t,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: brightness,
          fontFamily: 'ProxyProbeFont',
        ),
        home: Scaffold(
          body: RepaintBoundary(
            key: screenshotKey,
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: SingleChildScrollView(
                child: ProxyConfigWidget(
                  configService: config,
                  compactMode: compact,
                  wrapWithCard: !compact,
                  showTitle: !compact,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await LocaleSettings.instance.loadAllLocales();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = File('/System/Library/Fonts/Supplemental/Arial Unicode.ttf');
    if (font.existsSync()) {
      await (FontLoader('ProxyProbeFont')..addFont(
            Future.value(ByteData.sublistView(await font.readAsBytes())),
          ))
          .load();
    }
  });
  setUp(() async => LocaleSettings.setLocale(AppLocale.en));
  tearDown(() async {
    Get.reset();
    await LocaleSettings.setLocale(AppLocale.en);
  });

  final hostInput = find.byKey(const ValueKey('proxy-host-input'));
  final portInput = find.byKey(const ValueKey('proxy-port-input'));
  final saveButton = find.byKey(const ValueKey('proxy-save'));

  testWidgets(
    'saves separate server and port fields as a normalized endpoint',
    (tester) async {
      final config = _MemoryConfig('localhost:8080');
      await _pump(tester, config);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Server address'), findsOneWidget);
      expect(find.text('Port'), findsOneWidget);
      await tester.enterText(hostInput, ' Proxy.Example ');
      await tester.enterText(portInput, '7890');
      await tester.pump();
      expect(config[ConfigKey.PROXY_URL], 'localhost:8080');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(config[ConfigKey.PROXY_URL], 'proxy.example:7890');
      expect(config[ConfigKey.USE_PROXY], false);
      expect(
        tester.widget<TextField>(hostInput).controller!.text,
        'proxy.example',
      );
      expect(tester.widget<TextField>(portInput).controller!.text, '7890');
    },
  );

  testWidgets('pasted URLs and host:port split without saving or enabling', (
    tester,
  ) async {
    final config = _MemoryConfig('localhost:8080');
    await _pump(tester, config);
    for (final address in [' http://127.0.0.1:7890/ ', 'proxy.example:80']) {
      await tester.enterText(hostInput, address);
      await tester.pump();
      final parts = address.contains('127.0.0.1')
          ? ['127.0.0.1', '7890']
          : ['proxy.example', '80'];
      expect(tester.widget<TextField>(hostInput).controller!.text, parts[0]);
      expect(tester.widget<TextField>(portInput).controller!.text, parts[1]);
      expect(config[ConfigKey.PROXY_URL], 'localhost:8080');
      expect(config[ConfigKey.USE_PROXY], false);
    }
  });

  testWidgets('typing an address does not split at the first port digit', (
    tester,
  ) async {
    final config = _MemoryConfig('localhost:8080');
    await _pump(tester, config);
    await tester.showKeyboard(hostInput);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'localhost:',
        selection: TextSelection.collapsed(offset: 10),
      ),
    );
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'localhost:7',
        selection: TextSelection.collapsed(offset: 11),
      ),
    );
    await tester.pump();
    expect(tester.widget<TextField>(hostInput).controller!.text, 'localhost:7');
    expect(tester.widget<TextField>(portInput).controller!.text, '8080');
  });

  testWidgets('legacy URL initializes both fields and can be normalized', (
    tester,
  ) async {
    final config = _MemoryConfig('http://localhost:7890');
    config.settings[ConfigKey.USE_PROXY]!.value = true;
    await _pump(tester, config);
    expect(tester.widget<TextField>(hostInput).controller!.text, 'localhost');
    expect(tester.widget<TextField>(portInput).controller!.text, '7890');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(config[ConfigKey.PROXY_URL], 'localhost:7890');
    expect(config[ConfigKey.USE_PROXY], true);
  });

  testWidgets('invalid server cannot enable or overwrite the saved endpoint', (
    tester,
  ) async {
    final config = _MemoryConfig('localhost:8080');
    await _pump(tester, config);
    await tester.enterText(hostInput, 'https://example.com/subscription');
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(config[ConfigKey.USE_PROXY], false);
    expect(config[ConfigKey.PROXY_URL], 'localhost:8080');
    expect(find.text(t.settings.proxyEditor.invalidHost), findsOneWidget);
    await tester.enterText(hostInput, 'localhost');
    await tester.enterText(portInput, '7890');
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(config[ConfigKey.USE_PROXY], true);
    expect(config[ConfigKey.PROXY_URL], 'localhost:7890');
  });

  testWidgets('invalid and missing ports are reported beside the port field', (
    tester,
  ) async {
    final config = _MemoryConfig('localhost:8080');
    await _pump(tester, config);
    for (final port in ['0', '65536', '']) {
      await tester.enterText(portInput, port);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(
        find.text(
          port.isEmpty
              ? t.settings.proxyEditor.portRequired
              : t.settings.proxyEditor.invalidPort,
        ),
        findsOneWidget,
      );
      expect(config[ConfigKey.PROXY_URL], 'localhost:8080');
      expect(config[ConfigKey.USE_PROXY], false);
    }
  });

  testWidgets('blank server cannot enable and points to the server field', (
    tester,
  ) async {
    final config = _MemoryConfig('localhost:8080');
    await _pump(tester, config);
    await tester.enterText(hostInput, '');
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(config[ConfigKey.USE_PROXY], false);
    expect(find.text(t.settings.proxyEditor.hostRequired), findsOneWidget);
  });

  testWidgets('short pasted URL replaces a fully selected long server name', (
    tester,
  ) async {
    final config = _MemoryConfig('very-long-proxy-server.example:8080');
    await _pump(tester, config);
    await tester.showKeyboard(hostInput);
    final controller = tester.widget<TextField>(hostInput).controller!;
    controller.selection = TextSelection(
      baseOffset: controller.text.length,
      extentOffset: 0,
    );
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'http://a:80',
        selection: TextSelection.collapsed(offset: 11),
      ),
    );
    await tester.pump();
    expect(tester.widget<TextField>(hostInput).controller!.text, 'a');
    expect(tester.widget<TextField>(portInput).controller!.text, '80');
    expect(config[ConfigKey.PROXY_URL], 'very-long-proxy-server.example:8080');
  });

  testWidgets(
    'a URL without a port is not labeled saved as a bare server name',
    (tester) async {
      final config = _MemoryConfig('localhost:8080');
      await _pump(tester, config);
      await tester.enterText(hostInput, 'http://localhost');
      await tester.pump();
      final button = tester.widget<FilledButton>(saveButton);
      expect(button.onPressed, isNotNull);
      expect(
        find.descendant(
          of: saveButton,
          matching: find.text(t.settings.proxyEditor.saved),
        ),
        findsNothing,
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(find.text(t.settings.proxyEditor.invalidHost), findsOneWidget);
      expect(config[ConfigKey.PROXY_URL], 'localhost:8080');
    },
  );

  testWidgets('all locales fit narrow and wide screens and onboarding', (
    tester,
  ) async {
    for (final locale in AppLocale.values) {
      await LocaleSettings.setLocale(locale);
      for (final compact in [false, true]) {
        for (final brightness in Brightness.values) {
          for (final size in [const Size(320, 800), const Size(760, 800)]) {
            await tester.binding.setSurfaceSize(size);
            await _pump(
              tester,
              _MemoryConfig('localhost:7890'),
              compact: compact,
              brightness: brightness,
              textScale: size.width < 480 ? 1.6 : 1,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '${locale.languageTag} compact=$compact $brightness',
            );
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  final shotDir = Platform.environment['PROXY_SHOT_DIR'];
  if (shotDir != null) {
    testWidgets('proxy editor visual evidence', (tester) async {
      Directory(shotDir).createSync(recursive: true);
      await LocaleSettings.setLocale(AppLocale.zhCn);
      for (final brightness in Brightness.values) {
        final size = brightness == Brightness.light
            ? const Size(390, 800)
            : const Size(760, 800);
        await tester.binding.setSurfaceSize(size);
        final key = GlobalKey();
        await _pump(
          tester,
          _MemoryConfig('localhost:7890'),
          brightness: brightness,
          screenshotKey: key,
        );
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '$shotDir/proxy_${brightness.name}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.binding.setSurfaceSize(null);
    });
  }
}
