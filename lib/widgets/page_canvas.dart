import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfx/pdfx.dart';
import '../providers/pdf_provider.dart';
import '../theme/app_theme.dart';

class PageCanvas extends StatefulWidget {
  const PageCanvas({super.key});

  @override
  State<PageCanvas> createState() => _PageCanvasState();
}

class _PageCanvasState extends State<PageCanvas> {
  Uint8List? _currentImage;
  final TransformationController _transformationController = TransformationController();
  PdfProvider? _pdfProvider;
  final ScrollController _scrollController = ScrollController();

  double _pageWidth = 612.0;
  double _pageHeight = 792.0;
  BoxConstraints? _canvasConstraints;
  bool _initialized = false;
  double _currentScale = 1.0;
  int _lastRenderedPage = 0;
  double _renderScale = 1.0;
  int _lastContinuousPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupCallbacks();
    });
    _transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final visualScale = scale * _renderScale;
    if ((_currentScale - visualScale).abs() > 0.005) {
      _currentScale = visualScale;
      _pdfProvider?.setZoomLevel(_currentScale);
    }
  }

  void _setupCallbacks() {
    if (_pdfProvider == null) return;
    _pdfProvider!.setOnFitToWidthRequested(_fitToWidth);
    _pdfProvider!.setOnFitToPageRequested(_fitToPage);
    _pdfProvider!.setOnZoomInRequested(_zoomIn);
    _pdfProvider!.setOnZoomOutRequested(_zoomOut);
    _pdfProvider!.setOnResetZoomRequested(_resetZoom);
    _pdfProvider!.setOnSetZoomRequested(_onSetZoom);
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renderPage();
    });
  }

  void _onSetZoom(double zoom) {
    _currentScale = zoom.clamp(0.25, 5.0);
    final pdfProvider = _pdfProvider ?? context.read<PdfProvider>();
    if (pdfProvider.viewMode == ViewMode.continuous) {
      final sc = _scrollController;
      final offset = sc.hasClients ? sc.position.pixels : null;
      setState(() {});
      if (offset != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && sc.hasClients) {
            final max = sc.position.maxScrollExtent;
            sc.jumpTo(offset > max ? max : offset);
          }
        });
      }
    } else {
      _updateTransform();
    }
    _pdfProvider?.setZoomLevel(_currentScale);
  }

  void _zoomIn() {
    _onSetZoom(_currentScale * 1.25);
  }

  void _zoomOut() {
    _onSetZoom(_currentScale / 1.25);
  }

  void _resetZoom() {
    _onSetZoom(1.0);
  }

  void _updateTransform() {
    final c = _canvasConstraints;
    if (c == null) return;
    if (_pageHeight <= 0 || _pageWidth <= 0) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    final displayScale = _currentScale / _renderScale;
    final pageRatio = _pageHeight / _pageWidth;

    final tx = c.maxWidth * (1 - _currentScale) / 2;
    final ty = max(0.0, (c.maxHeight - c.maxWidth * _currentScale * pageRatio) / 2);

    _transformationController.value = Matrix4.identity()
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty)
      ..setEntry(0, 0, displayScale)
      ..setEntry(1, 1, displayScale)
      ..setEntry(2, 2, displayScale);
  }

  void _fitToWidth() {
    final constraints = _canvasConstraints;
    if (constraints == null) return;

    const padding = 60.0;
    final scale = (constraints.maxWidth - padding) / constraints.maxWidth;
    _onSetZoom(scale.clamp(0.25, 5.0));
  }

  void _fitToPage() {
    final constraints = _canvasConstraints;
    if (constraints == null || _pageHeight <= 0) return;

    const padding = 60.0;
    final scaleW = (constraints.maxWidth - padding) / constraints.maxWidth;
    final imageH = constraints.maxWidth * (_pageHeight / _pageWidth);
    final scaleH = (constraints.maxHeight - padding) / imageH;
    final scale = scaleW < scaleH ? scaleW : scaleH;
    _onSetZoom(scale.clamp(0.25, 5.0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wasInitialized = _initialized;
    _pdfProvider?.removeListener(_onPdfStateChanged);
    _pdfProvider = context.read<PdfProvider>();
    _pdfProvider!.addListener(_onPdfStateChanged);
    if (!_initialized) {
      _setupCallbacks();
    } else if (!wasInitialized && _initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _renderPage();
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _pdfProvider?.removeListener(_onPdfStateChanged);
    _pdfProvider?.setOnFitToWidthRequested(null);
    _pdfProvider?.setOnFitToPageRequested(null);
    _pdfProvider?.setOnZoomInRequested(null);
    _pdfProvider?.setOnZoomOutRequested(null);
    _pdfProvider?.setOnResetZoomRequested(null);
    _pdfProvider?.setOnSetZoomRequested(null);
    _transformationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onPdfStateChanged() {
    if (!mounted) return;
    final pdfProvider = _pdfProvider ?? context.read<PdfProvider>();

    if (pdfProvider.viewMode == ViewMode.continuous) {
      final page = pdfProvider.currentPage;
      if (page != _lastContinuousPage) {
        _lastContinuousPage = page;
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToCurrentPage(page);
        });
      }
    } else {
      _renderPage();
    }
  }

  void _scrollToCurrentPage(int page) {
    if (!_scrollController.hasClients) return;
    final pageWidth = _getPageWidth();
    final itemHeight = pageWidth > 0 ? pageWidth * 1.3 + 40 : 300.0;
    final offset = (page - 1) * itemHeight;
    final maxOffset = _scrollController.position.maxScrollExtent;
    if (offset <= maxOffset) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  double _getPageWidth() {
    final constraints = _canvasConstraints;
    if (constraints == null) return 800.0;
    final base = (constraints.maxWidth - 80).clamp(200.0, 1200.0);
    return base * _currentScale;
  }

  Future<void> _renderPage() async {
    if (!mounted) return;
    final pdfProvider = _pdfProvider ?? context.read<PdfProvider>();
    final doc = pdfProvider.document;
    if (doc == null) return;

    if (pdfProvider.viewMode == ViewMode.continuous) return;

    final pageNum = pdfProvider.currentPage;

    if (pageNum == _lastRenderedPage && _currentImage != null) {
      return;
    }

    _lastRenderedPage = pageNum;
    _currentImage = null;
    setState(() {});

    try {
      final page = await doc.getPage(pageNum);
      _pageWidth = page.width.toDouble();
      _pageHeight = page.height.toDouble();
      pdfProvider.setPageSize(_pageWidth, _pageHeight);

      final constraints = _canvasConstraints;
      final canvasWidth = constraints?.maxWidth ?? 800.0;

      final dpr = MediaQuery.of(context).devicePixelRatio;
      _renderScale = _currentScale;
      final renderWidth = (canvasWidth * dpr * _currentScale).round();
      final renderHeight = (renderWidth * (_pageHeight / _pageWidth)).round();

      final render = await page.render(
        width: renderWidth.toDouble(),
        height: renderHeight.toDouble(),
        format: PdfPageImageFormat.png,
      );

      await page.close();

      if (mounted && render != null) {
        setState(() {
          _currentImage = render.bytes;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateTransform();
        });
      }
    } catch (e) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = context.watch<PdfProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgBase : AppColors.lightBgBase;

    if (!pdfProvider.isDocumentOpen) {
      return const SizedBox.shrink();
    }

    if (pdfProvider.viewMode == ViewMode.continuous) {
      return _buildContinuousScroll(pdfProvider, isDark);
    }

    return _buildSinglePage(pdfProvider, isDark, bgColor);
  }

  Widget _buildSinglePage(PdfProvider pdfProvider, bool isDark, Color bgColor) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      color: bgColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _canvasConstraints = constraints;

          return Listener(
            onPointerSignal: (event) {
              try {
                final dynamic ev = event;
                final delta = ev.scrollDelta;
                if (delta is Offset) {
                  if (delta.dy.abs() > delta.dx.abs()) {
                    if (delta.dy > 0) {
                      pdfProvider.nextPage();
                    } else if (delta.dy < 0) {
                      pdfProvider.previousPage();
                    }
                  }
                }
              } catch (_) {}
            },
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -50) {
                    pdfProvider.nextPage();
                  } else if (details.primaryVelocity! > 50) {
                    pdfProvider.previousPage();
                  }
                }
              },
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.25,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(200),
                constrained: false,
                child: Center(
                  child: _currentImage != null
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Image.memory(
                            _currentImage!,
                            key: ValueKey(pdfProvider.currentPage),
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                            strokeWidth: 1.5,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinuousScroll(PdfProvider pdfProvider, bool isDark) {
    final bgColor = isDark ? AppColors.darkBgBase : AppColors.lightBgBase;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      color: bgColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _canvasConstraints = constraints;
          final pageWidth = _getPageWidth();

          return ListView.builder(
            controller: _scrollController,
            itemCount: pdfProvider.totalPages,
            cacheExtent: 800,
            physics: const PageScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemBuilder: (context, index) {
              final pageNum = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: SizedBox(
                    width: pageWidth,
                    child: _ContinuousPageItem(
                      key: ValueKey(pageNum),
                      pageNum: pageNum,
                      document: pdfProvider.document,
                      pageWidth: pageWidth,
                      isCurrentPage: pageNum == pdfProvider.currentPage,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textColor,
                      borderColor: borderColor,
                      onTap: () {
                        if (pageNum != pdfProvider.currentPage) {
                          pdfProvider.goToPage(pageNum);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ContinuousPageItem extends StatefulWidget {
  final int pageNum;
  final PdfDocument? document;
  final double pageWidth;
  final bool isCurrentPage;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final VoidCallback onTap;

  const _ContinuousPageItem({
    super.key,
    required this.pageNum,
    required this.document,
    required this.pageWidth,
    required this.isCurrentPage,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.onTap,
  });

  @override
  State<_ContinuousPageItem> createState() => _ContinuousPageItemState();
}

class _ContinuousPageItemState extends State<_ContinuousPageItem> {
  Uint8List? _image;
  bool _rendering = false;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _renderPage();
  }

  @override
  void didUpdateWidget(_ContinuousPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNum != widget.pageNum || oldWidget.pageWidth != widget.pageWidth) {
      _renderPage();
    }
  }

  Future<void> _renderPage() async {
    if (widget.document == null) return;
    if (_rendering) return;

    setState(() => _rendering = true);

    try {
      final page = await widget.document!.getPage(widget.pageNum);
      _aspectRatio = page.width / page.height;
      final pageWidth = page.width.toDouble();
      final pageHeight = page.height.toDouble();

      final width = widget.pageWidth;
      final height = width * (pageHeight / pageWidth);

      final dpr = MediaQuery.of(context).devicePixelRatio;
      final render = await page.render(
        width: (width * dpr).round().toDouble(),
        height: (height * dpr).round().toDouble(),
        format: PdfPageImageFormat.png,
      );

      await page.close();

      if (mounted && render != null) {
        setState(() {
          _image = render.bytes;
          _rendering = false;
        });
      } else {
        setState(() => _rendering = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _rendering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isCurrentPage ? widget.textPrimary : widget.borderColor,
            width: widget.isCurrentPage ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _aspectRatio ?? 1.5,
              child: _image != null
                  ? Image.memory(_image!, fit: BoxFit.contain)
                  : Container(
                      color: Colors.white,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.textSecondary,
                            ),
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: widget.borderColor)),
              ),
              child: Text(
                'Page ${widget.pageNum}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'JetBrains Mono',
                  color: widget.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
