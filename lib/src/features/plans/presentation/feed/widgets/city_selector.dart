import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/plans/domain/city_constants.dart';

/// Selector de ciudad con dropdown y busqueda
class CitySelector extends StatefulWidget {
  final String? selectedCity;
  final ValueChanged<String?> onCitySelected;
  final bool compact;

  const CitySelector({
    super.key,
    this.selectedCity,
    required this.onCitySelected,
    this.compact = false,
  });

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final _searchController = TextEditingController();
  List<String> _filteredCities = CityConstants.colombianCities;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      _filteredCities = CityConstants.searchCities(query);
    });
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CityPickerSheet(
        selectedCity: widget.selectedCity,
        onCitySelected: (city) {
          widget.onCitySelected(city);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactSelector();
    }
    return _buildFullSelector();
  }

  Widget _buildCompactSelector() {
    return GestureDetector(
      onTap: _showCityPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.selectedCity != null
              ? const Color(0xFF9B59B6).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.selectedCity != null
                ? const Color(0xFF9B59B6)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: widget.selectedCity != null
                  ? const Color(0xFF9B59B6)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              widget.selectedCity ?? 'Ciudad',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: widget.selectedCity != null
                    ? const Color(0xFF9B59B6)
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: widget.selectedCity != null
                  ? const Color(0xFF9B59B6)
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudad',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showCityPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.selectedCity != null
                    ? const Color(0xFF9B59B6)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 20,
                  color: widget.selectedCity != null
                      ? const Color(0xFF9B59B6)
                      : Colors.grey[500],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedCity ?? 'Seleccionar ciudad',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: widget.selectedCity != null
                          ? const Color(0xFF2D3436)
                          : Colors.grey[500],
                    ),
                  ),
                ),
                if (widget.selectedCity != null)
                  GestureDetector(
                    onTap: () => widget.onCitySelected(null),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.grey[500],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet para seleccionar ciudad
class _CityPickerSheet extends StatefulWidget {
  final String? selectedCity;
  final ValueChanged<String?> onCitySelected;

  const _CityPickerSheet({
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchController = TextEditingController();
  List<String> _filteredCities = CityConstants.colombianCities;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      _filteredCities = CityConstants.searchCities(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
                Text(
                  'Seleccionar ciudad',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                if (widget.selectedCity != null)
                  TextButton(
                    onPressed: () => widget.onCitySelected(null),
                    child: Text(
                      'Limpiar',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9B59B6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCities,
              decoration: InputDecoration(
                hintText: 'Buscar ciudad...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9B59B6)),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Cities list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected = city == widget.selectedCity;

                return ListTile(
                  onTap: () => widget.onCitySelected(city),
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected
                        ? const Color(0xFF9B59B6)
                        : Colors.grey[400],
                  ),
                  title: Text(
                    city,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF9B59B6)
                          : const Color(0xFF2D3436),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF9B59B6))
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
