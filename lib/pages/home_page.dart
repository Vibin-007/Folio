import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pdf_provider.dart';
import '../providers/recent_files_provider.dart';
import '../services/file_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/title_bar.dart';
import '../models/recent_file.dart';
import 'viewer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FileService _fileService = FileService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleAutoOpen();
  }

  void _handleAutoOpen() {
    final pdfProvider = context.read<PdfProvider>();
    final recentFiles = context.read<RecentFilesProvider>();
    final prefsService = context.read<PreferencesService>();
    if (pdfProvider.filePath == null && prefsService.autoOpenLastFile) {
      final lastFile = recentFiles.lastOpenedFilePath;
      if (lastFile != null) {
        _openFile(lastFile);
      }
    }
  }

  Future<void> _pickFile() async {
    final path = await _fileService.pickPdfFile();
    if (path != null) {
      _openFile(path);
    }
  }

  void _openFile(String path) {
    final pdfProvider = context.read<PdfProvider>();
    final recentFilesProvider = context.read<RecentFilesProvider>();
    final fileName = _fileService.getFileName(path);
    recentFilesProvider.addFile(path, fileName);
    pdfProvider.openFile(path).then((_) {
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ViewerPage()));
      }
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgBase : AppColors.lightBgBase;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bgElevated = isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final bgOverlay = isDark
        ? AppColors.darkBgOverlay
        : AppColors.lightBgOverlay;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const CustomTitleBar(showFileName: false),
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                SingleActivator(LogicalKeyboardKey.keyO, control: true):
                    _pickFile,
              },
              child: Focus(
                autofocus: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 48,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            'folio',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 48,
                              fontWeight: FontWeight.w400,
                              color: textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your documents, beautifully read.',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _OpenPdfButton(
                            onPressed: _pickFile,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            bgOverlay: bgOverlay,
                          ),
                          const SizedBox(height: 64),
                          _buildRecentFiles(
                            context,
                            isDark,
                            textPrimary,
                            textSecondary,
                            textMuted,
                            borderColor,
                            bgElevated,
                            bgOverlay,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFiles(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color textMuted,
    Color borderColor,
    Color bgElevated,
    Color bgOverlay,
  ) {
    final recentFiles = context.watch<RecentFilesProvider>();

    if (recentFiles.files.isEmpty) {
      return Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, size: 24, color: textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            'No recent files',
            style: GoogleFonts.dmSans(fontSize: 13, color: textMuted),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Recent',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...recentFiles.files.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;
          final isLast = index == recentFiles.files.length - 1;
          return _RecentFileItem(
            file: file,
            timeAgo: _formatTimeAgo(file.lastOpened),
            isLast: isLast,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            textMuted: textMuted,
            borderColor: borderColor,
            bgElevated: bgElevated,
            bgOverlay: bgOverlay,
            onTap: () => _openFile(file.path),
            onRemove: () {
              context.read<RecentFilesProvider>().removeFile(file.path);
            },
            onShowInExplorer: () {
              final dir = File(file.path).parent.path;
              Process.run('explorer.exe', [dir]);
            },
          );
        }),
      ],
    );
  }
}

class _OpenPdfButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;
  final Color textPrimary;
  final Color bgOverlay;

  const _OpenPdfButton({
    required this.onPressed,
    required this.isDark,
    required this.textPrimary,
    required this.bgOverlay,
  });

  @override
  State<_OpenPdfButton> createState() => _OpenPdfButtonState();
}

class _OpenPdfButtonState extends State<_OpenPdfButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 200,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered ? widget.textPrimary : Colors.transparent,
            border: Border.all(color: widget.textPrimary, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_outlined,
                size: 16,
                color: _hovered
                    ? (widget.isDark
                          ? AppColors.darkBgBase
                          : AppColors.lightBgBase)
                    : widget.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Open PDF',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _hovered
                      ? (widget.isDark
                            ? AppColors.darkBgBase
                            : AppColors.lightBgBase)
                      : widget.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentFileItem extends StatefulWidget {
  final RecentFile file;
  final String timeAgo;
  final bool isLast;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderColor;
  final Color bgElevated;
  final Color bgOverlay;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onShowInExplorer;

  const _RecentFileItem({
    required this.file,
    required this.timeAgo,
    required this.isLast,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderColor,
    required this.bgElevated,
    required this.bgOverlay,
    required this.onTap,
    required this.onRemove,
    required this.onShowInExplorer,
  });

  @override
  State<_RecentFileItem> createState() => _RecentFileItemState();
}

class _RecentFileItemState extends State<_RecentFileItem> {
  bool _hovered = false;


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,

        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isLast ? Colors.transparent : widget.borderColor,
                width: 1,
              ),
            ),
            borderRadius: _hovered
                ? BorderRadius.circular(4)
                : BorderRadius.zero,
            color: _hovered ? widget.bgElevated : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: widget.textSecondary),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 12,
                  color: widget.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      widget.file.path,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: widget.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.timeAgo,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: widget.textMuted,
                ),
              ),
              if (_hovered) ...[
                const SizedBox(width: 8),
                _ContextMenuButton(
                  isDark: widget.isDark,
                  bgOverlay: widget.bgOverlay,
                  borderColor: widget.borderColor,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                  onOpen: widget.onTap,
                  onRemove: widget.onRemove,
                  onShowInExplorer: widget.onShowInExplorer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  final bool isDark;
  final Color bgOverlay;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onShowInExplorer;

  const _ContextMenuButton({
    required this.isDark,
    required this.bgOverlay,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onOpen,
    required this.onRemove,
    required this.onShowInExplorer,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: borderColor),
      ),
      color: bgOverlay,
      padding: EdgeInsets.zero,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        child: Icon(Icons.more_vert, size: 16, color: textSecondary),
      ),
      onSelected: (value) {
        if (value == 'open') onOpen();
        if (value == 'remove') onRemove();
        if (value == 'explorer') onShowInExplorer();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'open',
          height: 36,
          child: Text(
            'Open',
            style: GoogleFonts.dmSans(fontSize: 12, color: textPrimary),
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          height: 36,
          child: Text(
            'Remove from recent',
            style: GoogleFonts.dmSans(fontSize: 12, color: textPrimary),
          ),
        ),
        PopupMenuItem(
          value: 'explorer',
          height: 36,
          child: Text(
            'Show in Explorer',
            style: GoogleFonts.dmSans(fontSize: 12, color: textPrimary),
          ),
        ),
      ],
    );
  }
}
