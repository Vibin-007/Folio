import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/pdf_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/recent_files_provider.dart';
import 'pages/home_page.dart';
import 'pages/viewer_page.dart';

class FolioApp extends StatefulWidget {
  final String? initialFilePath;

  const FolioApp({super.key, this.initialFilePath});

  @override
  State<FolioApp> createState() => _FolioAppState();
}

class _FolioAppState extends State<FolioApp> {
  bool _openedInitialFile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialFilePath != null && !_openedInitialFile) {
      _openedInitialFile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openInitialFile();
      });
    }
  }

  Future<void> _openInitialFile() async {
    if (widget.initialFilePath == null) return;
    
    final pdfProvider = context.read<PdfProvider>();
    final recentFilesProvider = context.read<RecentFilesProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();
    
    final fileName = widget.initialFilePath!.split('\\').last.split('/').last;
    recentFilesProvider.addFile(widget.initialFilePath!, fileName);
    
    await pdfProvider.openFile(widget.initialFilePath!);
    bookmarkProvider.loadForFile(widget.initialFilePath!);
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ViewerPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Folio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomePage(),
    );
  }
}