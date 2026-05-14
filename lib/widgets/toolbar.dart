import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ToolbarWidget extends StatefulWidget {
  final bool sidebarOpen;
  final VoidCallback onToggleSidebar;
  final VoidCallback? onOpenFile;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetZoom;
  final VoidCallback? onFitToWidth;
  final VoidCallback? onFitToPage;
  final ValueChanged<double>? onSetZoom;
  final VoidCallback? onSearch;
  final VoidCallback? onBookmark;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onSettings;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final double zoomLevel;
  final bool isBookmarked;
  final bool isDark;

  const ToolbarWidget({
    super.key,
    required this.sidebarOpen,
    required this.onToggleSidebar,
    this.onOpenFile,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetZoom,
    this.onFitToWidth,
    this.onFitToPage,
    this.onSetZoom,
    this.onSearch,
    this.onBookmark,
    this.onToggleTheme,
    this.onSettings,
    this.onToggleFullscreen,
    this.onBack,
    this.onHome,
    required this.zoomLevel,
    required this.isBookmarked,
    required this.isDark,
  });

  @override
  State<ToolbarWidget> createState() => _ToolbarWidgetState();
}

class _ToolbarWidgetState extends State<ToolbarWidget> {
  bool _zoomFocused = false;
  final TextEditingController _zoomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _zoomController.text = '${(widget.zoomLevel * 100).toInt()}%';
  }

  @override
  void didUpdateWidget(ToolbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoomLevel != widget.zoomLevel) {
      _zoomController.text = '${(widget.zoomLevel * 100).toInt()}%';
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark
        ? AppColors.darkBgSurface
        : AppColors.lightBgSurface;
    final borderColor = widget.isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final textPrimary = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final borderFocus = widget.isDark
        ? AppColors.darkBorderFocus
        : AppColors.lightBorderFocus;

    return Container(
      height: 48,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ToolbarIconButton(
            icon: widget.sidebarOpen ? Icons.chevron_left : Icons.chevron_right,
            tooltip: widget.sidebarOpen ? 'Close sidebar' : 'Open sidebar',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onToggleSidebar,
          ),
          const SizedBox(width: 4),
          _ToolbarIconButton(
            icon: Icons.home_outlined,
            tooltip: 'Home',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onHome,
          ),
          _verticalSeparator(borderColor),
          _ToolbarIconButton(
            icon: Icons.folder_open_outlined,
            tooltip: 'Open (Ctrl+O)',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onOpenFile,
          ),
          _verticalSeparator(borderColor),
          _ToolbarIconButton(
            icon: Icons.remove,
            tooltip: 'Zoom out',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onZoomOut,
          ),
          const SizedBox(width: 8),
          Container(
            width: 56,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(
                color: _zoomFocused ? borderFocus : borderColor,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Focus(
              onFocusChange: (focused) =>
                  setState(() => _zoomFocused = focused),
              child: TextField(
                controller: _zoomController,
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: textPrimary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  final parsed = int.tryParse(value.replaceAll('%', ''));
                  if (parsed != null && parsed > 0) {
                    final zoom = parsed / 100.0;
                    widget.onSetZoom?.call(zoom);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ToolbarIconButton(
            icon: Icons.add,
            tooltip: 'Zoom in',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onZoomIn,
          ),
          const SizedBox(width: 4),
          _ToolbarIconButton(
            icon: Icons.fit_screen_outlined,
            tooltip: 'Fit to width',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onFitToWidth,
          ),
          _ToolbarIconButton(
            icon: Icons.fullscreen_outlined,
            tooltip: 'Fit to page',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onFitToPage,
          ),
          _verticalSeparator(borderColor),
          _ToolbarIconButton(
            icon: Icons.search,
            tooltip: 'Search (Ctrl+F)',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onSearch,
          ),
          _ToolbarIconButton(
            icon: widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            tooltip: 'Bookmark (Ctrl+B)',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onBookmark,
            isActive: widget.isBookmarked,
          ),
          _verticalSeparator(borderColor),
          const Spacer(),
          _ToolbarIconButton(
            icon: widget.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            tooltip: 'Toggle theme (Ctrl+T)',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onToggleTheme,
          ),
          _ToolbarIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onSettings,
          ),
          _ToolbarIconButton(
            icon: Icons.fullscreen,
            tooltip: 'Fullscreen (F11)',
            isDark: widget.isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            onPressed: widget.onToggleFullscreen,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _verticalSeparator(Color color) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: color,
    );
  }
}

class _ToolbarIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isDark;
  final Color textSecondary;
  final Color textPrimary;
  final VoidCallback? onPressed;
  final bool isActive;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.isDark,
    required this.textSecondary,
    required this.textPrimary,
    this.onPressed,
    this.isActive = false,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

class _ToolbarIconButtonState extends State<_ToolbarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final bgOverlay = widget.isDark
        ? AppColors.darkBgOverlay
        : AppColors.lightBgOverlay;

    Color iconColor;
    if (widget.isActive) {
      iconColor = widget.textPrimary;
    } else if (_hovered) {
      iconColor = widget.textPrimary;
    } else {
      iconColor = widget.textSecondary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          waitDuration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: bgOverlay,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 11,
            color: widget.textPrimary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hovered ? bgElevated : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Icon(widget.icon, size: 18, color: iconColor)),
          ),
        ),
      ),
    );
  }
}
