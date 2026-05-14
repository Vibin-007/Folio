import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_theme.dart';

class CustomTitleBar extends StatelessWidget {
  final String? fileName;
  final bool showFileName;

  const CustomTitleBar({super.key, this.fileName, this.showFileName = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            'folio',
            style: AppTextStyles.labelLg.copyWith(
              color: textColor,
              fontFamily: 'DM Serif Display',
            ),
          ),
          if (showFileName && fileName != null) ...[
            const SizedBox(width: 16),
            Container(width: 1, height: 16, color: borderColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                fileName!,
                style: AppTextStyles.labelSm.copyWith(color: textSecondary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ] else
            const Spacer(),
          _WindowButton(
            icon: Icons.remove,
            onPressed: () => windowManager.minimize(),
            isDark: isDark,
          ),
          _WindowButton(
            icon: Icons.crop_square,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
            isDark: isDark,
          ),
          _WindowButton(
            icon: Icons.close,
            onPressed: () => windowManager.close(),
            isDark: isDark,
            isClose: true,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgElevated = widget.isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final textColor = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 36,
          height: 32,
          decoration: BoxDecoration(
            color: _hovered ? bgElevated : Colors.transparent,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered && widget.isClose
                  ? widget.isDark
                        ? AppColors.darkWhite
                        : AppColors.lightTextPrimary
                  : textColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
