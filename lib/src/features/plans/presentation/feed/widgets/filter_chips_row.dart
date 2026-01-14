import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';

/// Fila de chips de filtro con scroll horizontal
class FilterChipsRow extends StatelessWidget {
  final FeedFilter selectedFilter;
  final Function(FeedFilter) onFilterSelected;

  const FilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: 'Todos',
            icon: Icons.check,
            filter: FeedFilter.todos,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Hoy',
            icon: Icons.calendar_today,
            filter: FeedFilter.hoy,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Cerca',
            icon: Icons.location_on,
            filter: FeedFilter.cerca,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Mi energia',
            icon: Icons.bolt,
            filter: FeedFilter.miEnergia,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required FeedFilter filter,
  }) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => onFilterSelected(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9B59B6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF9B59B6)
                : const Color(0xFFE0E0E0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9B59B6).withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF636E72),
            ),
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
