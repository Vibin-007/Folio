import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pdf_provider.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = context.watch<PdfProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final hasResults = pdfProvider.totalMatches > 0;
    final searchActive = pdfProvider.searchQuery.isNotEmpty;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search in document...',
                hintStyle: GoogleFonts.dmSans(fontSize: 13, color: textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (v) => pdfProvider.search(v),
              onSubmitted: (_) {
                if (hasResults) pdfProvider.nextMatch();
              },
            ),
          ),
          if (searchActive) ...[
            if (hasResults) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${pdfProvider.currentMatchIndex + 1} of ${pdfProvider.totalMatches}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SearchButton(
                icon: Icons.keyboard_arrow_up,
                onPressed: hasResults ? pdfProvider.previousMatch : null,
                isDark: isDark,
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              _SearchButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: hasResults ? pdfProvider.nextMatch : null,
                isDark: isDark,
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: borderColor),
              const SizedBox(width: 8),
            ] else ...[
              Text(
                'No results',
                style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: borderColor),
              const SizedBox(width: 8),
            ],
          ],
          _SearchButton(
            icon: Icons.close,
            onPressed: () {
              _controller.clear();
              pdfProvider.closeSearch();
            },
            isDark: isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _SearchButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;
  final Color textSecondary;
  final Color textPrimary;

  const _SearchButton({
    required this.icon,
    this.onPressed,
    required this.isDark,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final isEnabled = widget.onPressed != null;
    final color = !isEnabled
        ? widget.textSecondary.withValues(alpha: 0.3)
        : (_hovered ? widget.textPrimary : widget.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered && isEnabled ? bgElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Icon(widget.icon, size: 18, color: color)),
        ),
      ),
    );
  }
}
