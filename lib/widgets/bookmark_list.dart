import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';

class BookmarkList extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const BookmarkList({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    if (!bookmarkProvider.hasBookmarks) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 32,
              color: textColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Press Ctrl+B to bookmark',
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bookmarkProvider.bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarkProvider.bookmarks[index];
        final isCurrent = bookmark.pageNumber == currentPage;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => onPageSelected(bookmark.pageNumber),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCurrent ? textColor : borderColor,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Page ${bookmark.pageNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: textColor,
                          ),
                        ),
                        if (bookmark.label.isNotEmpty)
                          Text(
                            bookmark.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 14,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    onPressed: () =>
                        bookmarkProvider.removeBookmark(bookmark.pageNumber),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
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
