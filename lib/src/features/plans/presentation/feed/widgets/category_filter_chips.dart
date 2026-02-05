import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';

/// Chips de categorias seleccionables para filtrar planes
class CategoryFilterChips extends StatelessWidget {
  final PlanCategory? selectedCategory;
  final ValueChanged<PlanCategory?> onCategorySelected;
  final bool allowMultiple;
  final Set<PlanCategory>? selectedCategories;
  final ValueChanged<Set<PlanCategory>>? onCategoriesChanged;

  const CategoryFilterChips({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.allowMultiple = false,
    this.selectedCategories,
    this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Opcion "Todas"
            _CategoryChip(
              label: 'Todas',
              emoji: '✨',
              color: const Color(0xFF9B59B6),
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            ),
            // Categorias individuales
            ...PlanConstants.categories.map((category) {
              final planCategory = PlanCategory.values.firstWhere(
                (c) => c.name == category.id,
                orElse: () => PlanCategory.otros,
              );
              final isSelected = allowMultiple
                  ? selectedCategories?.contains(planCategory) ?? false
                  : selectedCategory == planCategory;

              return _CategoryChip(
                label: category.nombre,
                emoji: category.emoji,
                color: category.color,
                isSelected: isSelected,
                onTap: () {
                  if (allowMultiple && onCategoriesChanged != null) {
                    final newSet = Set<PlanCategory>.from(
                      selectedCategories ?? <PlanCategory>{},
                    );
                    if (isSelected) {
                      newSet.remove(planCategory);
                    } else {
                      newSet.add(planCategory);
                    }
                    onCategoriesChanged!(newSet);
                  } else {
                    onCategorySelected(
                      isSelected ? null : planCategory,
                    );
                  }
                },
              );
            }),
          ],
        ),
      ],
    );
  }
}

/// Chip individual de categoria
class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Version compacta para header (chip simple que abre selector)
class CategoryFilterCompact extends StatelessWidget {
  final PlanCategory? selectedCategory;
  final VoidCallback onTap;

  const CategoryFilterCompact({
    super.key,
    this.selectedCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryInfo = selectedCategory != null
        ? PlanConstants.getCategoryByEnum(selectedCategory!)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectedCategory != null
              ? (categoryInfo?.color ?? const Color(0xFF9B59B6)).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedCategory != null
                ? (categoryInfo?.color ?? const Color(0xFF9B59B6))
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categoryInfo != null)
              Text(categoryInfo.emoji, style: const TextStyle(fontSize: 14))
            else
              Icon(
                Icons.category,
                size: 16,
                color: Colors.grey[600],
              ),
            const SizedBox(width: 6),
            Text(
              categoryInfo?.nombre ?? 'Categoria',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selectedCategory != null
                    ? (categoryInfo?.color ?? const Color(0xFF9B59B6))
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: selectedCategory != null
                  ? (categoryInfo?.color ?? const Color(0xFF9B59B6))
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid horizontal de categorias (scroll horizontal)
class CategoryFilterHorizontal extends StatelessWidget {
  final PlanCategory? selectedCategory;
  final ValueChanged<PlanCategory?> onCategorySelected;

  const CategoryFilterHorizontal({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Opcion "Todas"
          _CategoryChip(
            label: 'Todas',
            emoji: '✨',
            color: const Color(0xFF9B59B6),
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          // Categorias
          ...PlanConstants.categories.map((category) {
            final planCategory = PlanCategory.values.firstWhere(
              (c) => c.name == category.id,
              orElse: () => PlanCategory.otros,
            );

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: category.nombre,
                emoji: category.emoji,
                color: category.color,
                isSelected: selectedCategory == planCategory,
                onTap: () => onCategorySelected(
                  selectedCategory == planCategory ? null : planCategory,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
