import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/pdf_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/recent_files_provider.dart';
import '../providers/theme_provider.dart';
import '../services/file_service.dart';
import '../theme/app_theme.dart';
import '../widgets/title_bar.dart';
import '../widgets/toolbar.dart';
import '../widgets/sidebar.dart';
import '../widgets/page_canvas.dart';
import '../widgets/status_bar.dart';
import '../widgets/search_bar_widget.dart';
import 'settings_page.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage({super.key});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;
  bool _sidebarOpen = true;
  bool _isFullscreen = false;
  bool _toolbarVisible = false;
  double _lastCanvasWidth = 0;
  Timer? _toolbarHideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prefs = context.read<BookmarkProvider>();
        final pdfProvider = context.read<PdfProvider>();
        if (pdfProvider.filePath != null) {
          prefs.loadForFile(pdfProvider.filePath!);
        }
      }
    });
    _sidebarController.value = 1.0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _toolbarHideTimer?.cancel();
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void _toggleSidebar() {
    if (_sidebarOpen) {
      _sidebarController.reverse();
    } else {
      _sidebarController.forward();
    }
    _sidebarOpen = !_sidebarOpen;
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
    setState(() {
      _isFullscreen = !_isFullscreen;
      _toolbarVisible = false;
    });
  }

  void _showToolbar() {
    _toolbarHideTimer?.cancel();
    setState(() => _toolbarVisible = true);
  }

  void _hideToolbar() {
    _toolbarHideTimer?.cancel();
    _toolbarHideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _toolbarVisible = false);
      }
    });
  }

  void _onHoverTopZone(bool hovering) {
    if (hovering) {
      _showToolbar();
      _hideToolbar();
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = context.watch<PdfProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgBase : AppColors.lightBgBase;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyO, control: true): () =>
            _pickFile(context),
        SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
            pdfProvider.toggleSearch(),
        SingleActivator(LogicalKeyboardKey.escape): () =>
            _handleEscape(pdfProvider),
        SingleActivator(LogicalKeyboardKey.f11): () => _toggleFullscreen(),
        SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            pdfProvider.nextPage(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            pdfProvider.previousPage(),
        SingleActivator(LogicalKeyboardKey.pageDown): () =>
            pdfProvider.nextPage(),
        SingleActivator(LogicalKeyboardKey.pageUp): () =>
            pdfProvider.previousPage(),
        SingleActivator(LogicalKeyboardKey.equal, control: true): () =>
            pdfProvider.zoomIn(),
        SingleActivator(LogicalKeyboardKey.minus, control: true): () =>
            pdfProvider.zoomOut(),
        SingleActivator(LogicalKeyboardKey.digit0, control: true): () =>
            pdfProvider.resetZoom(),
        SingleActivator(LogicalKeyboardKey.keyW, control: true): () =>
            pdfProvider.fitToWidth(),
        SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
            _toggleBookmark(pdfProvider),
        SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
            context.read<ThemeProvider>().toggleTheme(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              Column(
                children: [
                  if (!_isFullscreen)
                    CustomTitleBar(
                      showFileName: true,
                      fileName: pdfProvider.fileName,
                    ),
                  if (!_isFullscreen) ...[
                    _buildToolbar(context, pdfProvider, isDark, borderColor),
                    AnimatedSlide(
                      offset: pdfProvider.isSearchOpen
                          ? Offset.zero
                          : const Offset(0, -1),
                      duration: const Duration(milliseconds: 150),
                      child: pdfProvider.isSearchOpen
                          ? const SearchBarWidget()
                          : const SizedBox.shrink(),
                    ),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        if (!_isFullscreen)
                          _buildSidebar(
                            context,
                            pdfProvider,
                            isDark,
                            borderColor,
                          ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              if (w > 0 && w != _lastCanvasWidth && mounted) {
                                _lastCanvasWidth = w;
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted && context.read<PdfProvider>().isDocumentOpen) {
                                    context.read<PdfProvider>().fitToWidth();
                                  }
                                });
                              }
                              return Container(
                                child: pdfProvider.isLoading
                                    ? _buildLoading(isDark)
                                    : pdfProvider.error != null
                                    ? _buildError(context, pdfProvider, isDark)
                                    : pdfProvider.isDocumentOpen
                                    ? const PageCanvas()
                                    : _buildEmptyState(context, isDark),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isFullscreen) const StatusBar(),
                ],
              ),
              if (_isFullscreen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: MouseRegion(
                    onEnter: (_) => _onHoverTopZone(true),
                    onExit: (_) => _onHoverTopZone(false),
                    child: AnimatedOpacity(
                      opacity: _toolbarVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildFloatingToolbar(
                        context,
                        pdfProvider,
                        isDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEscape(PdfProvider pdfProvider) async {
    if (pdfProvider.isSearchOpen) {
      pdfProvider.closeSearch();
    } else if (_isFullscreen) {
      await _toggleFullscreen();
    }
  }

  void _pickFile(BuildContext context) async {
    final fileService = FileService();
    final path = await fileService.pickPdfFile();
    if (path != null) {
      final pdfProvider = context.read<PdfProvider>();
      final recentFilesProvider = context.read<RecentFilesProvider>();
      final bookmarkProvider = context.read<BookmarkProvider>();
      recentFilesProvider.addFile(path, fileService.getFileName(path));
      await pdfProvider.openFile(path);
      bookmarkProvider.loadForFile(path);
      _lastCanvasWidth = 0;
      setState(() {});
    }
  }

  void _toggleBookmark(PdfProvider pdfProvider) {
    if (pdfProvider.isDocumentOpen) {
      context.read<BookmarkProvider>().toggleBookmark(
        pdfProvider.currentPage,
        label: 'Page ${pdfProvider.currentPage}',
      );
    }
  }

  Widget _buildFloatingToolbar(
    BuildContext context,
    PdfProvider pdfProvider,
    bool isDark,
  ) {
    final bgColor = isDark
        ? AppColors.darkBgBase.withValues(alpha: 0.9)
        : AppColors.lightBgBase.withValues(alpha: 0.9);
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await _toggleFullscreen();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: Icon(Icons.arrow_back, size: 18, color: textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              pdfProvider.fileName,
              style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => context.read<ThemeProvider>().toggleTheme(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 18,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await _toggleFullscreen();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: Icon(
                Icons.fullscreen_exit,
                size: 18,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    PdfProvider pdfProvider,
    bool isDark,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: ToolbarWidget(
        sidebarOpen: _sidebarOpen,
        onToggleSidebar: _toggleSidebar,
        onOpenFile: () => _pickFile(context),
        onZoomIn: pdfProvider.zoomIn,
        onZoomOut: pdfProvider.zoomOut,
        onResetZoom: pdfProvider.resetZoom,
        onFitToWidth: pdfProvider.fitToWidth,
        onFitToPage: pdfProvider.fitToPage,
        onSetZoom: (zoom) => pdfProvider.applyZoom(zoom),
        onSearch: pdfProvider.toggleSearch,
        onBookmark: () => _toggleBookmark(pdfProvider),
        onToggleTheme: () => context.read<ThemeProvider>().toggleTheme(),
        onSettings: _openSettings,
        onToggleFullscreen: _toggleFullscreen,
        onBack: () => Navigator.of(context).pop(),
        onHome: () => Navigator.of(context).pop(),
        zoomLevel: pdfProvider.zoomLevel,
        isBookmarked: pdfProvider.isDocumentOpen
            ? context.watch<BookmarkProvider>().isBookmarked(
                pdfProvider.currentPage,
              )
            : false,
        isDark: isDark,
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    PdfProvider pdfProvider,
    bool isDark,
    Color borderColor,
  ) {
    return SizeTransition(
      sizeFactor: _sidebarAnimation,
      axis: Axis.horizontal,
      axisAlignment: -1.0,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: borderColor)),
          color: isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface,
        ),
        child: SidebarWidget(
          onToggle: _toggleSidebar,
          onPageSelected: pdfProvider.goToPage,
          currentPage: pdfProvider.currentPage,
          totalPages: pdfProvider.totalPages,
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(textSecondary),
          strokeWidth: 1.5,
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    PdfProvider pdfProvider,
    bool isDark,
  ) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bgElevated = isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
          color: bgElevated,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: textSecondary),
            const SizedBox(height: 16),
            Text(
              pdfProvider.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: textPrimary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ErrorButton(
                  label: 'Locate file',
                  icon: Icons.folder_open,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  borderColor: borderColor,
                  onPressed: () => _pickFile(context),
                ),
                const SizedBox(width: 12),
                _ErrorButton(
                  label: 'Back to home',
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf_outlined,
              size: 24,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No PDF open',
            style: GoogleFonts.dmSans(fontSize: 16, color: textMuted),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickFile(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Open PDF',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isDark;
  final Color textPrimary;
  final Color? textSecondary;
  final Color borderColor;
  final VoidCallback onPressed;

  const _ErrorButton({
    required this.label,
    this.icon,
    required this.isDark,
    required this.textPrimary,
    this.textSecondary,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  State<_ErrorButton> createState() => _ErrorButtonState();
}

class _ErrorButtonState extends State<_ErrorButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: widget.borderColor),
            borderRadius: BorderRadius.circular(4),
            color: _hovered ? bgElevated : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: widget.textPrimary),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.textSecondary ?? widget.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
