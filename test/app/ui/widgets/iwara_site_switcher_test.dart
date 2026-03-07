import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/ui/widgets/iwara_site_switcher.dart';
import 'package:i_iwara/i18n/strings.g.dart';

void main() {
  ThemeData buildTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );

  group('IwaraSiteSwitcher', () {
    setUp(() {
      LocaleSettings.setLocale(AppLocale.en);
    });

    testWidgets('uses a Material 3 anchored menu in compact mode', (
      tester,
    ) async {
      IwaraSite? selectedSite;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: Center(
              child: IwaraSiteSwitcher(
                currentSite: IwaraSite.main,
                forceCompact: true,
                onChanged: (site) => selectedSite = site,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MenuAnchor), findsOneWidget);
      expect(find.byType(PopupMenuButton), findsNothing);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.byType(MenuItemButton), findsNWidgets(2));

      await tester.tap(find.text(t.siteMode.aiSite).last);
      await tester.pumpAndSettle();

      expect(selectedSite, IwaraSite.ai);
    });

    testWidgets('uses segmented control outside compact mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: Center(
              child: IwaraSiteSwitcher(
                currentSite: IwaraSite.main,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SegmentedButton<IwaraSite>), findsOneWidget);
      expect(find.byType(MenuAnchor), findsNothing);
    });
  });
}
