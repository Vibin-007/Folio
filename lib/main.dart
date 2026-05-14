import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'services/preferences_service.dart';
import 'providers/theme_provider.dart';
import 'providers/pdf_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/recent_files_provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'folio',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final prefs = await SharedPreferences.getInstance();
  final prefsService = PreferencesService(prefs);

  String? initialFilePath;
  if (args.isNotEmpty) {
    final arg = args.first;
    if (arg.toLowerCase().endsWith('.pdf') && File(arg).existsSync()) {
      initialFilePath = arg;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: prefsService),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefsService)),
        ChangeNotifierProvider(create: (_) => PdfProvider(prefsService)),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(prefsService)),
        ChangeNotifierProvider(
          create: (_) => RecentFilesProvider(prefsService),
        ),
      ],
      child: FolioApp(initialFilePath: initialFilePath),
    ),
  );
}