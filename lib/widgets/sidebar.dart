import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/thumbnail_list.dart';
import '../widgets/bookmark_list.dart';

class SidebarWidget extends StatefulWidget {
  final VoidCallback onToggle;
  final ValueChanged<int> onPageSelected;
  final int currentPage;
  final int totalPages;

  const SidebarWidget({
    super.key,
    required this.onToggle,
    required this.onPageSelected,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bgSurface = isDark
        ? AppColors.darkBgSurface
        : AppColors.lightBgSurface;

    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
            color: bgSurface,
          ),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  labelColor: textPrimary,
                  unselectedLabelColor: textSecondary,
                  indicatorColor: textPrimary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 2,
                  labelStyle: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Thumbnails'),
                    Tab(text: 'Bookmarks'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ThumbnailList(
                currentPage: widget.currentPage,
                totalPages: widget.totalPages,
                onPageSelected: widget.onPageSelected,
              ),
              BookmarkList(
                currentPage: widget.currentPage,
                onPageSelected: widget.onPageSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
