import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_file.dart';
import '../models/bookmark.dart';

class PreferencesService {
  static const _themeKey = 'theme_dark';
  static const _recentFilesKey = 'recent_files';
  static const _lastPagePrefix = 'last_page_';
  static const _bookmarksPrefix = 'bookmarks_';
  static const _sidebarOpenKey = 'sidebar_open';
  static const _zoomLevelKey = 'zoom_level';
  static const _viewModeKey = 'view_mode';
  static const _fontSizeKey = 'font_size';
  static const _defaultZoomKey = 'default_zoom';
  static const _defaultViewModeKey = 'default_view_mode';
  static const _rememberLastPageKey = 'remember_last_page';
  static const _autoOpenLastFileKey = 'auto_open_last_file';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;
  set isDarkMode(bool value) => _prefs.setBool(_themeKey, value);

  List<RecentFile> get recentFiles {
    final json = _prefs.getString(_recentFilesKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => RecentFile.fromJson(e as Map<String, dynamic>)).toList();
  }

  set recentFiles(List<RecentFile> files) {
    final json = jsonEncode(files.map((f) => f.toJson()).toList());
    _prefs.setString(_recentFilesKey, json);
  }

  int? getLastPage(String filePath) {
    final page = _prefs.getInt('$_lastPagePrefix$filePath');
    return page;
  }

  void setLastPage(String filePath, int page) {
    _prefs.setInt('$_lastPagePrefix$filePath', page);
  }

  List<Bookmark> getBookmarks(String filePath) {
    final json = _prefs.getString('$_bookmarksPrefix$filePath');
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList();
  }

  void setBookmarks(String filePath, List<Bookmark> bookmarks) {
    final json = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    _prefs.setString('$_bookmarksPrefix$filePath', json);
  }

  bool get sidebarOpen => _prefs.getBool(_sidebarOpenKey) ?? true;
  set sidebarOpen(bool value) => _prefs.setBool(_sidebarOpenKey, value);

  double get zoomLevel => _prefs.getDouble(_zoomLevelKey) ?? 1.0;
  set zoomLevel(double value) => _prefs.setDouble(_zoomLevelKey, value);

  String get viewMode => _prefs.getString(_viewModeKey) ?? 'single';
  set viewMode(String value) => _prefs.setString(_viewModeKey, value);

  String get fontSize => _prefs.getString(_fontSizeKey) ?? 'medium';
  set fontSize(String value) => _prefs.setString(_fontSizeKey, value);

  double get defaultZoom => _prefs.getDouble(_defaultZoomKey) ?? 1.0;
  set defaultZoom(double value) => _prefs.setDouble(_defaultZoomKey, value);

  String get defaultViewMode => _prefs.getString(_defaultViewModeKey) ?? 'single';
  set defaultViewMode(String value) => _prefs.setString(_defaultViewModeKey, value);

  bool get rememberLastPage => _prefs.getBool(_rememberLastPageKey) ?? true;
  set rememberLastPage(bool value) => _prefs.setBool(_rememberLastPageKey, value);

  bool get autoOpenLastFile => _prefs.getBool(_autoOpenLastFileKey) ?? false;
  set autoOpenLastFile(bool value) => _prefs.setBool(_autoOpenLastFileKey, value);
}
