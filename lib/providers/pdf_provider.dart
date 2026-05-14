import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../services/preferences_service.dart';

enum ViewMode { single, continuous }

class PdfProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  PdfDocument? _document;
  String? _filePath;
  int _currentPage = 1;
  int _totalPages = 0;
  double _zoomLevel = 1.0;
  double _pageWidth = 0;
  ViewMode _viewMode = ViewMode.single;
  bool _isLoading = false;
  String? _error;
  bool _isSearchOpen = false;
  String _searchQuery = '';
  int _currentMatchIndex = 0;
  List<int> _matchPages = [];
  bool _isFullscreen = false;
  String _fileName = '';
  VoidCallback? _onFitToWidthRequested;
  VoidCallback? _onFitToPageRequested;
  VoidCallback? _onZoomInRequested;
  VoidCallback? _onZoomOutRequested;
  VoidCallback? _onResetZoomRequested;
  ValueChanged<double>? _onSetZoomRequested;

  PdfProvider(this._prefs) {
    _zoomLevel = _prefs.zoomLevel;
    _viewMode = _prefs.viewMode == 'continuous'
        ? ViewMode.continuous
        : ViewMode.single;
  }

  PdfDocument? get document => _document;
  String? get filePath => _filePath;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  double get zoomLevel => _zoomLevel;
  ViewMode get viewMode => _viewMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSearchOpen => _isSearchOpen;
  String get searchQuery => _searchQuery;
  int get currentMatchIndex => _currentMatchIndex;
  List<int> get matchPages => _matchPages;
  int get totalMatches => _matchPages.length;
  bool get isFullscreen => _isFullscreen;
  String get fileName => _fileName;
  bool get isDocumentOpen => _document != null;
  double get pageWidth => _pageWidth;

  void setOnFitToWidthRequested(VoidCallback? callback) {
    _onFitToWidthRequested = callback;
  }

  void setPageWidth(double width) {
    _pageWidth = width;
  }

  void setPageSize(double width, double height) {
    _pageWidth = width;
  }

  void setOnFitToPageRequested(VoidCallback? callback) {
    _onFitToPageRequested = callback;
  }

  void setOnZoomInRequested(VoidCallback? callback) {
    _onZoomInRequested = callback;
  }

  void setOnZoomOutRequested(VoidCallback? callback) {
    _onZoomOutRequested = callback;
  }

  void setOnResetZoomRequested(VoidCallback? callback) {
    _onResetZoomRequested = callback;
  }

  Future<void> openFile(String path) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _document?.close();
      _document = await PdfDocument.openFile(path);
      _filePath = path;
      _totalPages = _document!.pagesCount;
      _currentPage = 1;
      _zoomLevel = 1.0;
      _fileName = path.split('\\').last.split('/').last;

      final savedPage = _prefs.getLastPage(path);
      if (savedPage != null && _prefs.rememberLastPage) {
        _currentPage = savedPage.clamp(1, _totalPages);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to open PDF: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> closeDocument() async {
    await _document?.close();
    _document = null;
    _filePath = null;
    _currentPage = 1;
    _totalPages = 0;
    _fileName = '';
    _matchPages = [];
    _searchQuery = '';
    _isSearchOpen = false;
    notifyListeners();
  }

  void goToPage(int page) {
    if (_document == null) return;
    _currentPage = page.clamp(1, _totalPages);
    if (_prefs.rememberLastPage && _filePath != null) {
      _prefs.setLastPage(_filePath!, _currentPage);
    }
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      goToPage(_currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      goToPage(_currentPage - 1);
    }
  }

  void zoomIn() {
    _onZoomInRequested?.call();
  }

  void zoomOut() {
    _onZoomOutRequested?.call();
  }

  void resetZoom() {
    _onResetZoomRequested?.call();
  }

  void fitToWidth() {
    _onFitToWidthRequested?.call();
  }

  void fitToPage() {
    _onFitToPageRequested?.call();
  }

  void setOnSetZoomRequested(ValueChanged<double>? callback) {
    _onSetZoomRequested = callback;
  }

  void applyZoom(double zoom) {
    _zoomLevel = zoom.clamp(0.25, 5.0);
    _prefs.zoomLevel = _zoomLevel;
    _onSetZoomRequested?.call(_zoomLevel);
    notifyListeners();
  }

  void setZoomLevel(double zoom) {
    _zoomLevel = zoom.clamp(0.25, 5.0);
    notifyListeners();
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.single
        ? ViewMode.continuous
        : ViewMode.single;
    _prefs.viewMode = _viewMode.name;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    _prefs.viewMode = mode.name;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearchOpen = !_isSearchOpen;
    if (!_isSearchOpen) {
      _searchQuery = '';
      _matchPages = [];
      _currentMatchIndex = 0;
    }
    notifyListeners();
  }

  void closeSearch() {
    _isSearchOpen = false;
    _searchQuery = '';
    _matchPages = [];
    _currentMatchIndex = 0;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _matchPages = [];
    _currentMatchIndex = 0;

    if (query.isEmpty) {
      notifyListeners();
      return;
    }

    for (int i = 1; i <= _totalPages; i++) {
      _matchPages.add(i);
    }

    if (_matchPages.isNotEmpty) {
      goToPage(_matchPages.first);
    }
    notifyListeners();
  }

  void nextMatch() {
    if (_matchPages.isEmpty) return;
    _currentMatchIndex = (_currentMatchIndex + 1) % _matchPages.length;
    goToPage(_matchPages[_currentMatchIndex]);
    notifyListeners();
  }

  void previousMatch() {
    if (_matchPages.isEmpty) return;
    _currentMatchIndex =
        (_currentMatchIndex - 1 + _matchPages.length) % _matchPages.length;
    goToPage(_matchPages[_currentMatchIndex]);
    notifyListeners();
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  void exitFullscreen() {
    if (_isFullscreen) {
      _isFullscreen = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _document?.close();
    super.dispose();
  }
}
