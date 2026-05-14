import 'package:flutter/material.dart';
import '../models/recent_file.dart';
import '../services/preferences_service.dart';

class RecentFilesProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  List<RecentFile> _files = [];

  RecentFilesProvider(this._prefs) {
    _files = _prefs.recentFiles;
  }

  List<RecentFile> get files => List.unmodifiable(_files);

  void addFile(String path, String name, {int lastPage = 1}) {
    _files.removeWhere((f) => f.path == path);
    _files.insert(
      0,
      RecentFile(
        path: path,
        name: name,
        lastOpened: DateTime.now(),
        lastPage: lastPage,
      ),
    );
    if (_files.length > 10) {
      _files = _files.sublist(0, 10);
    }
    _prefs.recentFiles = _files;
    notifyListeners();
  }

  void updateLastPage(String path, int page) {
    final index = _files.indexWhere((f) => f.path == path);
    if (index != -1) {
      _files[index] = RecentFile(
        path: _files[index].path,
        name: _files[index].name,
        lastOpened: DateTime.now(),
        lastPage: page,
      );
      _prefs.recentFiles = _files;
      notifyListeners();
    }
  }

  void clearHistory() {
    _files.clear();
    _prefs.recentFiles = _files;
    notifyListeners();
  }

  void removeFile(String path) {
    _files.removeWhere((f) => f.path == path);
    _prefs.recentFiles = _files;
    notifyListeners();
  }

  String? get lastOpenedFilePath {
    if (_files.isEmpty) return null;
    return _files.first.path;
  }
}
