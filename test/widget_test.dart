import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:folio/app.dart';
import 'package:folio/services/preferences_service.dart';
import 'package:folio/providers/theme_provider.dart';
import 'package:folio/providers/pdf_provider.dart';
import 'package:folio/providers/bookmark_provider.dart';
import 'package:folio/providers/recent_files_provider.dart';

void main() {
  testWidgets('App launches with home page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final prefsService = PreferencesService(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefsService)),
          ChangeNotifierProvider(create: (_) => PdfProvider(prefsService)),
          ChangeNotifierProvider(create: (_) => BookmarkProvider(prefsService)),
          ChangeNotifierProvider(create: (_) => RecentFilesProvider(prefsService)),
        ],
        child: const FolioApp(),
      ),
    );

    expect(find.text('Folio'), findsOneWidget);
    expect(find.text('Minimalist PDF Reader'), findsOneWidget);
  });
}
