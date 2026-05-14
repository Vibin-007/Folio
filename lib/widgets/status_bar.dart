import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pdf_provider.dart';
import '../theme/app_theme.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pdfProvider = context.read<PdfProvider>();
    _pageController.text = pdfProvider.currentPage.toString();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = context.watch<PdfProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bgColor = isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
        color: bgColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pdfProvider.fileName,
              style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PageNavButton(
                icon: Icons.chevron_left,
                onPressed: pdfProvider.previousPage,
                isDark: isDark,
                textSecondary: textSecondary,
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _pageController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final page = int.tryParse(v);
                    if (page != null) {
                      pdfProvider.goToPage(page);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of ${pdfProvider.totalPages}',
                style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(width: 8),
              _PageNavButton(
                icon: Icons.chevron_right,
                onPressed: pdfProvider.nextPage,
                isDark: isDark,
                textSecondary: textSecondary,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 18, color: borderColor),
          const SizedBox(width: 16),
          Text(
            '${(pdfProvider.zoomLevel * 100).toInt()}%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          _ViewModeToggle(
            isSingle: pdfProvider.viewMode == ViewMode.single,
            onToggle: pdfProvider.toggleViewMode,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
            bgElevated: isDark
                ? AppColors.darkBgElevated
                : AppColors.lightBgElevated,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _PageNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;
  final Color textSecondary;

  const _PageNavButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    required this.textSecondary,
  });

  @override
  State<_PageNavButton> createState() => _PageNavButtonState();
}

class _PageNavButtonState extends State<_PageNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final textPrimary = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered ? bgElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 18,
              color: _hovered ? textPrimary : widget.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeToggle extends StatefulWidget {
  final bool isSingle;
  final VoidCallback onToggle;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final Color bgElevated;

  const _ViewModeToggle({
    required this.isSingle,
    required this.onToggle,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.bgElevated,
  });

  @override
  State<_ViewModeToggle> createState() => _ViewModeToggleState();
}

class _ViewModeToggleState extends State<_ViewModeToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered ? widget.borderColor : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isSingle
                      ? widget.bgElevated
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSingle
                        ? widget.textSecondary
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Single',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: widget.isSingle
                        ? widget.textPrimary
                        : widget.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: !widget.isSingle
                      ? widget.bgElevated
                      : Colors.transparent,
                  border: Border.all(
                    color: !widget.isSingle
                        ? widget.textSecondary
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Continuous',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: !widget.isSingle
                        ? widget.textPrimary
                        : widget.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
