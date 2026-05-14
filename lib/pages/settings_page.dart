import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pdf_provider.dart';
import '../providers/theme_provider.dart';
import '../services/preferences_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedFontSize = 'medium';
  double _selectedDefaultZoom = 1.0;
  String _selectedDefaultViewMode = 'single';
  bool _rememberLastPage = true;
  bool _autoOpenLastFile = false;

  static const Color pureBlack = Color(0xFF000000);
  static const Color innerBg = Color(0xFF0D0D0D);
  static const Color sectionDivider = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _selectedFontSize = prefs.fontSize;
    _selectedDefaultZoom = prefs.defaultZoom;
    _selectedDefaultViewMode = prefs.defaultViewMode;
    _rememberLastPage = prefs.rememberLastPage;
    _autoOpenLastFile = prefs.autoOpenLastFile;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          color: pureBlack,
          child: Column(
            children: [
              Container(
                color: pureBlack,
                padding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
                child: Row(
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: borderColor),
              Expanded(
                child: Container(
                  color: pureBlack,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      _sectionHeader('Appearance'),
                      const SizedBox(height: 12),
                      _buildThemeToggle(context),
                      const SizedBox(height: 12),
                      _buildFontSizeSetting(),
                      const SizedBox(height: 24),
                      _sectionHeader('Reading'),
                      const SizedBox(height: 12),
                      _buildDefaultZoomSetting(),
                      const SizedBox(height: 12),
                      _buildDefaultViewModeSetting(),
                      const SizedBox(height: 12),
                      _buildToggleSetting(
                        'Remember last page per file',
                        _rememberLastPage,
                        (v) {
                          setState(() => _rememberLastPage = v);
                          context.read<PreferencesService>().rememberLastPage =
                              v;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildToggleSetting(
                        'Auto-open last file on launch',
                        _autoOpenLastFile,
                        (v) {
                          setState(() => _autoOpenLastFile = v);
                          context.read<PreferencesService>().autoOpenLastFile =
                              v;
                        },
                      ),
                      const SizedBox(height: 24),
                      _sectionHeader('Keyboard Shortcuts'),
                      const SizedBox(height: 12),
                      _buildShortcutsList(),
                      const SizedBox(height: 24),
                      _sectionHeader('About'),
                      const SizedBox(height: 12),
                      _buildAbout(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<ThemeProvider>().setDarkMode(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isDark ? textPrimary : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.light_mode,
                      size: 16,
                      color: !isDark ? pureBlack : textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Light',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: !isDark ? pureBlack : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<ThemeProvider>().setDarkMode(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? textPrimary : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dark_mode,
                      size: 16,
                      color: isDark ? pureBlack : textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dark',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: isDark ? pureBlack : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSetting() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: ['small', 'medium', 'large'].map((size) {
          final selected = _selectedFontSize == size;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFontSize = size);
                context.read<PreferencesService>().fontSize = size;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? textPrimary : Colors.transparent,
                ),
                child: Text(
                  size[0].toUpperCase() + size.substring(1),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: selected ? pureBlack : textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDefaultZoomSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            'Default zoom level',
            style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary),
          ),
          const Spacer(),
          DropdownButton<double>(
            value: _selectedDefaultZoom,
            dropdownColor: innerBg,
            underline: const SizedBox(),
            style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary),
            items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((z) {
              return DropdownMenuItem(
                value: z,
                child: Text('${(z * 100).toInt()}%'),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedDefaultZoom = v);
                context.read<PreferencesService>().defaultZoom = v;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultViewModeSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            'Default view mode',
            style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedDefaultViewMode,
            dropdownColor: innerBg,
            underline: const SizedBox(),
            style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary),
            items: const [
              DropdownMenuItem(value: 'single', child: Text('Single Page')),
              DropdownMenuItem(
                value: 'continuous',
                child: Text('Continuous Scroll'),
              ),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedDefaultViewMode = v);
                context.read<PreferencesService>().defaultViewMode = v;
                context.read<PdfProvider>().setViewMode(
                  v == 'continuous' ? ViewMode.continuous : ViewMode.single,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: textSecondary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: textPrimary,
            inactiveThumbColor: textSecondary.withValues(alpha: 0.5),
            inactiveTrackColor: textSecondary.withValues(alpha: 0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsList() {
    final shortcuts = [
      ('Ctrl+O', 'Open file'),
      ('Ctrl+F', 'Open search'),
      ('Escape', 'Close search / Exit fullscreen'),
      ('F11', 'Toggle fullscreen'),
      ('Arrow Right / Page Down', 'Next page'),
      ('Arrow Left / Page Up', 'Previous page'),
      ('Ctrl++', 'Zoom in'),
      ('Ctrl+-', 'Zoom out'),
      ('Ctrl+0', 'Reset zoom'),
      ('Ctrl+W', 'Fit to width'),
      ('Ctrl+B', 'Bookmark current page'),
      ('Ctrl+T', 'Toggle theme'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: shortcuts.map((s) {
          final isLast = s == shortcuts.last;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : sectionDivider,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: textSecondary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    s.$1,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  s.$2,
                  style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAbout() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folio',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Built with Flutter',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
