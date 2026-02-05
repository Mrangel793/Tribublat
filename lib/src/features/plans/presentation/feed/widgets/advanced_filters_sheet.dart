import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'city_selector.dart';
import 'age_range_filter.dart';
import 'category_filter_chips.dart';

/// Modelo para los filtros seleccionados
class AdvancedFilters {
  final String? city;
  final PlanCategory? category;
  final AgeRange ageRange;
  final bool filterByRestriction;

  const AdvancedFilters({
    this.city,
    this.category,
    this.ageRange = AgeRange.todos,
    this.filterByRestriction = false,
  });

  AdvancedFilters copyWith({
    String? city,
    PlanCategory? category,
    AgeRange? ageRange,
    bool? filterByRestriction,
    bool clearCity = false,
    bool clearCategory = false,
  }) {
    return AdvancedFilters(
      city: clearCity ? null : (city ?? this.city),
      category: clearCategory ? null : (category ?? this.category),
      ageRange: ageRange ?? this.ageRange,
      filterByRestriction: filterByRestriction ?? this.filterByRestriction,
    );
  }

  bool get hasActiveFilters =>
      city != null ||
      category != null ||
      ageRange != AgeRange.todos ||
      filterByRestriction;

  int get activeCount {
    int count = 0;
    if (city != null) count++;
    if (category != null) count++;
    if (ageRange != AgeRange.todos) count++;
    if (filterByRestriction) count++;
    return count;
  }

  static const empty = AdvancedFilters();
}

/// Bottom sheet de filtros avanzados
class AdvancedFiltersSheet extends StatefulWidget {
  final String? selectedCity;
  final PlanCategory? selectedCategory;
  final AgeRange selectedAgeRange;
  final bool filterByRestriction;
  final void Function(AdvancedFilters filters) onApply;
  final VoidCallback onClear;

  const AdvancedFiltersSheet({
    super.key,
    this.selectedCity,
    this.selectedCategory,
    this.selectedAgeRange = AgeRange.todos,
    this.filterByRestriction = false,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  late String? _city;
  late PlanCategory? _category;
  late AgeRange _ageRange;
  late bool _filterByRestriction;

  @override
  void initState() {
    super.initState();
    _city = widget.selectedCity;
    _category = widget.selectedCategory;
    _ageRange = widget.selectedAgeRange;
    _filterByRestriction = widget.filterByRestriction;
  }

  bool get _hasChanges =>
      _city != widget.selectedCity ||
      _category != widget.selectedCategory ||
      _ageRange != widget.selectedAgeRange ||
      _filterByRestriction != widget.filterByRestriction;

  bool get _hasActiveFilters =>
      _city != null ||
      _category != null ||
      _ageRange != AgeRange.todos ||
      _filterByRestriction;

  void _clearAll() {
    setState(() {
      _city = null;
      _category = null;
      _ageRange = AgeRange.todos;
      _filterByRestriction = false;
    });
  }

  void _apply() {
    widget.onApply(AdvancedFilters(
      city: _city,
      category: _category,
      ageRange: _ageRange,
      filterByRestriction: _filterByRestriction,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFF9B59B6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filtros avanzados',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ciudad
                  CitySelector(
                    selectedCity: _city,
                    onCitySelected: (city) => setState(() => _city = city),
                  ),
                  const SizedBox(height: 24),
                  // Categoria
                  CategoryFilterChips(
                    selectedCategory: _category,
                    onCategorySelected: (category) =>
                        setState(() => _category = category),
                  ),
                  const SizedBox(height: 24),
                  // Rango de edad
                  AgeRangeFilter(
                    selectedRange: _ageRange,
                    onRangeSelected: (range) =>
                        setState(() => _ageRange = range),
                    showRestrictionToggle: true,
                    filterByRestriction: _filterByRestriction,
                    onRestrictionToggle: (value) =>
                        setState(() => _filterByRestriction = value),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Limpiar
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _hasActiveFilters ? _clearAll : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF636E72),
                        side: BorderSide(
                          color: _hasActiveFilters
                              ? const Color(0xFF636E72)
                              : Colors.grey[300]!,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Limpiar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Aplicar
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _hasActiveFilters
                            ? 'Aplicar filtros'
                            : 'Ver todos',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Funcion helper para mostrar el bottom sheet
Future<AdvancedFilters?> showAdvancedFiltersSheet({
  required BuildContext context,
  String? selectedCity,
  PlanCategory? selectedCategory,
  AgeRange selectedAgeRange = AgeRange.todos,
  bool filterByRestriction = false,
}) async {
  AdvancedFilters? result;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => AdvancedFiltersSheet(
        selectedCity: selectedCity,
        selectedCategory: selectedCategory,
        selectedAgeRange: selectedAgeRange,
        filterByRestriction: filterByRestriction,
        onApply: (filters) => result = filters,
        onClear: () => result = AdvancedFilters.empty,
      ),
    ),
  );

  return result;
}
