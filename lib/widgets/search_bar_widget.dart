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
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final hasResults = pdfProvider.totalMatches > 0;
    final searchActive = pdfProvider.searchQuery.isNotEmpty;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: GoogleFonts.dmSans(fontSize: 13.5, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search pages\u2026',
                hintStyle: GoogleFonts.dmSans(fontSize: 13.5, color: textMuted),
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
              _MatchBadge(
                text: '${pdfProvider.currentMatchIndex + 1}/${pdfProvider.totalMatches}',
                isDark: isDark,
                borderColor: borderColor,
                textSecondary: textSecondary,
              ),
              const SizedBox(width: 4),
              _NavButton(
                icon: Icons.keyboard_arrow_up_rounded,
                onPressed: pdfProvider.previousMatch,
                isDark: isDark,
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              _NavButton(
                icon: Icons.keyboard_arrow_down_rounded,
                onPressed: pdfProvider.nextMatch,
                isDark: isDark,
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              const SizedBox(width: 4),
              _Divider(height: 20, color: borderColor),
              const SizedBox(width: 4),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'No results',
                  style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
                ),
              ),
              _Divider(height: 20, color: borderColor),
              const SizedBox(width: 4),
            ],
          ],
          _CloseButton(
            onPressed: () {
              _controller.clear();
              pdfProvider.closeSearch();
            },
            isDark: isDark,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
          ),
        ],
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color borderColor;
  final Color textSecondary;

  const _MatchBadge({
    required this.text,
    required this.isDark,
    required this.borderColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: textSecondary, height: 1.3),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;
  final Color textSecondary;
  final Color textPrimary;

  const _NavButton({
    required this.icon,
    this.onPressed,
    required this.isDark,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;
    final isEnabled = widget.onPressed != null;
    final color = !isEnabled
        ? widget.textSecondary.withValues(alpha: 0.25)
        : (_hovered ? widget.textPrimary : widget.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered && isEnabled ? bgElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Icon(widget.icon, size: 20, color: color)),
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;
  final Color textSecondary;
  final Color textPrimary;

  const _CloseButton({
    required this.onPressed,
    required this.isDark,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;
    final color = _hovered ? widget.textPrimary : widget.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered ? bgElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Icon(Icons.close_rounded, size: 18, color: color)),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final double height;
  final Color color;

  const _Divider({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: height, color: color);
  }
}
