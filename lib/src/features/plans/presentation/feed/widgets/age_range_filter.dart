import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';

/// Filtro de rango de edad con chips seleccionables
class AgeRangeFilter extends StatelessWidget {
  final AgeRange selectedRange;
  final ValueChanged<AgeRange> onRangeSelected;
  final bool showRestrictionToggle;
  final bool filterByRestriction;
  final ValueChanged<bool>? onRestrictionToggle;

  const AgeRangeFilter({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
    this.showRestrictionToggle = false,
    this.filterByRestriction = false,
    this.onRestrictionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de edad',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        // Chips de rango de edad
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AgeRange.values.map((range) {
            return _AgeRangeChip(
              range: range,
              isSelected: selectedRange == range,
              onTap: () => onRangeSelected(range),
            );
          }).toList(),
        ),
        // Toggle de restriccion de edad
        if (showRestrictionToggle) ...[
          const SizedBox(height: 16),
          _RestrictionToggle(
            value: filterByRestriction,
            onChanged: onRestrictionToggle ?? (_) {},
          ),
        ],
      ],
    );
  }
}

/// Chip individual de rango de edad
class _AgeRangeChip extends StatelessWidget {
  final AgeRange range;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeRangeChip({
    required this.range,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? range.color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? range.color : const Color(0xFFE0E0E0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: range.color.withOpacity(0.3),
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
              range.icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF636E72),
            ),
            const SizedBox(width: 6),
            Text(
              range.nombreCorto,
              style: GoogleFonts.inter(
                fontSize: 14,
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

/// Toggle para filtrar solo planes con restriccion de edad
class _RestrictionToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RestrictionToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF9B59B6).withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? const Color(0xFF9B59B6) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 22,
              color: value ? const Color(0xFF9B59B6) : Colors.grey[500],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solo planes con restriccion de edad',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value
                          ? const Color(0xFF9B59B6)
                          : const Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    'Planes que especifican edad minima o maxima',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Version compacta del filtro de edad (chip simple)
class AgeRangeFilterCompact extends StatelessWidget {
  final AgeRange selectedRange;
  final VoidCallback onTap;

  const AgeRangeFilterCompact({
    super.key,
    required this.selectedRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selectedRange != AgeRange.todos;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? selectedRange.color.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? selectedRange.color : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people,
              size: 16,
              color: isActive ? selectedRange.color : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? selectedRange.nombreCorto : 'Edad',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? selectedRange.color : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isActive ? selectedRange.color : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
