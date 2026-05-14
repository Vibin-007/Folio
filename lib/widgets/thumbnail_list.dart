import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfx/pdfx.dart';
import '../providers/pdf_provider.dart';
import '../theme/app_theme.dart';

class ThumbnailList extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;

  const ThumbnailList({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final pdfProvider = context.watch<PdfProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final surfaceColor = isDark
        ? AppColors.darkBgSurface
        : AppColors.lightBgSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (!pdfProvider.isDocumentOpen || pdfProvider.document == null) {
      return Center(
        child: Text(
          'No PDF open',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: totalPages,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        final isCurrent = pageNum == currentPage;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onPageSelected(pageNum),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCurrent ? textColor : borderColor,
                  width: isCurrent ? 2 : 1,
                ),
                color: surfaceColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: _ThumbnailImage(
                      document: pdfProvider.document,
                      pageNum: pageNum,
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: Text(
                      'Page $pageNum',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'JetBrains Mono',
                        color: textColor,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThumbnailImage extends StatefulWidget {
  final PdfDocument? document;
  final int pageNum;
  final bool isDark;
  final Color textColor;

  const _ThumbnailImage({
    required this.document,
    required this.pageNum,
    required this.isDark,
    required this.textColor,
  });

  @override
  State<_ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<_ThumbnailImage> {
  Uint8List? _thumbnail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(_ThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNum != widget.pageNum ||
        oldWidget.document != widget.document) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    if (widget.document == null) return;

    setState(() => _loading = true);

    try {
      final page = await widget.document!.getPage(widget.pageNum);
      final render = await page.render(
        width: 150.0,
        height: 200.0,
        format: PdfPageImageFormat.png,
      );
      await page.close();

      if (mounted && render != null) {
        setState(() {
          _thumbnail = render.bytes;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    if (_loading) {
      return Container(
        color: surfaceColor,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(textSecondary),
            ),
          ),
        ),
      );
    }

    if (_thumbnail != null) {
      return Container(
        color: Colors.white,
        child: Image.memory(_thumbnail!, fit: BoxFit.contain),
      );
    }

    return Container(
      color: surfaceColor,
      child: Center(
        child: Icon(
          Icons.description_outlined,
          size: 32,
          color: widget.textColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
