import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../services/preferences_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  List<Bookmark> _bookmarks = [];
  String? _currentFilePath;

  BookmarkProvider(this._prefs);

  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  bool get hasBookmarks => _bookmarks.isNotEmpty;

  void loadForFile(String filePath) {
    _currentFilePath = filePath;
    _bookmarks = _prefs.getBookmarks(filePath);
    notifyListeners();
  }

  void clear() {
    _bookmarks = [];
    _currentFilePath = null;
    notifyListeners();
  }

  void addBookmark(int pageNumber, {String label = ''}) {
    final exists = _bookmarks.any((b) => b.pageNumber == pageNumber);
    if (exists) return;

    _bookmarks.add(Bookmark(
      pageNumber: pageNumber,
      label: label.isEmpty ? 'Page $pageNumber' : label,
    ));
    _save();
    notifyListeners();
  }

  void removeBookmark(int pageNumber) {
    _bookmarks.removeWhere((b) => b.pageNumber == pageNumber);
    _save();
    notifyListeners();
  }

  void updateLabel(int pageNumber, String label) {
    final index = _bookmarks.indexWhere((b) => b.pageNumber == pageNumber);
    if (index != -1) {
      _bookmarks[index].label = label;
      _save();
      notifyListeners();
    }
  }

  bool isBookmarked(int pageNumber) {
    return _bookmarks.any((b) => b.pageNumber == pageNumber);
  }

  void toggleBookmark(int pageNumber, {String label = ''}) {
    if (isBookmarked(pageNumber)) {
      removeBookmark(pageNumber);
    } else {
      addBookmark(pageNumber, label: label);
    }
  }

  void _save() {
    if (_currentFilePath != null) {
      _prefs.setBookmarks(_currentFilePath!, _bookmarks);
    }
  }
}
