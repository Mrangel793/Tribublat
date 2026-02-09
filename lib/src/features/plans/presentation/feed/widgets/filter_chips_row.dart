import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';

/// Unified dark-mode chip row that combines feed tabs and category filters
/// into a single horizontally-scrollable strip.
class DarkFilterChipsRow extends StatelessWidget {
  final FeedFilter selectedFilter;
  final FeedTab selectedTab;
  final PlanCategory? selectedCategory;
  final Function(FeedFilter) onFilterSelected;
  final Function(FeedTab) onTabSelected;
  final Function(PlanCategory?) onCategorySelected;

  const DarkFilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.selectedTab,
    required this.selectedCategory,
    required this.onFilterSelected,
    required this.onTabSelected,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Para ti" chip
          _buildChip(
            label: '✨ Para ti',
            isActive: selectedTab == FeedTab.paraTi &&
                selectedCategory == null &&
                selectedFilter != FeedFilter.hoy,
            onTap: () {
              onTabSelected(FeedTab.paraTi);
              onFilterSelected(FeedFilter.todos);
              onCategorySelected(null);
            },
          ),
          const SizedBox(width: 8),

          // "Populares" chip
          _buildChip(
            label: '🔥 Populares',
            isActive: selectedFilter == FeedFilter.todos &&
                selectedTab == FeedTab.paraTi &&
                selectedCategory == null,
            onTap: () {
              onTabSelected(FeedTab.paraTi);
              onFilterSelected(FeedFilter.todos);
              onCategorySelected(null);
            },
          ),
          const SizedBox(width: 8),

          // "Esta noche" chip
          _buildChip(
            label: '🌙 Esta noche',
            isActive: selectedFilter == FeedFilter.hoy,
            onTap: () {
              onFilterSelected(FeedFilter.hoy);
              onCategorySelected(null);
            },
          ),
          const SizedBox(width: 8),

          // Category chips
          ...PlanConstants.categories.map((categoryInfo) {
            final category = PlanCategory.values.firstWhere(
              (e) => e.name == categoryInfo.id,
            );
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: '${categoryInfo.emoji} ${categoryInfo.nombre}',
                isActive: selectedCategory == category,
                onTap: () {
                  onCategorySelected(category);
                  onFilterSelected(FeedFilter.todos);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? DarkFeedColors.primaryGradient : null,
          color: isActive ? null : DarkFeedColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? DarkFeedColors.textPrimary
                  : DarkFeedColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
