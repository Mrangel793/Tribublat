import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/// Modelo para ciudad de la API Colombia
class ColombianCity {
  final int id;
  final String name;
  final String? departmentName;

  ColombianCity({
    required this.id,
    required this.name,
    this.departmentName,
  });

  factory ColombianCity.fromJson(Map<String, dynamic> json) {
    return ColombianCity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      departmentName: json['department']?['name'],
    );
  }

  String get displayName => departmentName != null
      ? '$name, $departmentName'
      : name;
}

/// Servicio para obtener ciudades de Colombia
class ColombianCityService {
  static const String _baseUrl = 'https://api-colombia.com/api/v1';
  static List<ColombianCity>? _cachedCities;

  /// Obtiene todas las ciudades (con cache)
  static Future<List<ColombianCity>> getAllCities() async {
    if (_cachedCities != null) return _cachedCities!;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/City'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedCities = data.map((e) => ColombianCity.fromJson(e)).toList();
        // Ordenar por nombre
        _cachedCities!.sort((a, b) => a.name.compareTo(b.name));
        return _cachedCities!;
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    }
    return [];
  }

  /// Busca ciudades por nombre
  static Future<List<ColombianCity>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final cities = await getAllCities();
    final queryLower = query.toLowerCase();

    return cities
        .where((city) => city.name.toLowerCase().contains(queryLower))
        .take(10)
        .toList();
  }
}

/// Widget de autocomplete para ciudades usando API Colombia (gratuita)
class CityAutocompleteField extends StatefulWidget {
  final String? initialValue;
  final Function(String cityName, String? placeId) onCitySelected;
  final String? googleApiKey; // Ignorado, mantenido por compatibilidad

  const CityAutocompleteField({
    super.key,
    this.initialValue,
    required this.onCitySelected,
    this.googleApiKey,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<ColombianCity> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _focusNode.addListener(_onFocusChange);
    // Pre-cargar ciudades
    ColombianCityService.getAllCities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _showSuggestions = false);
    }
  }

  void _showOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showSuggestions = true);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final city = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_city,
                      color: Color(0xFF9B59B6),
                      size: 20,
                    ),
                    title: Text(
                      city.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: city.departmentName != null
                        ? Text(
                            city.departmentName!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          )
                        : null,
                    onTap: () => _selectCity(city),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectCity(ColombianCity city) {
    _controller.text = city.name;
    widget.onCitySelected(city.name, city.id.toString());
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();

    if (value.isEmpty) {
      _removeOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      setState(() => _isLoading = true);

      final results = await ColombianCityService.searchCities(value);

      if (!mounted) return;

      setState(() {
        _suggestions = results;
        _isLoading = false;
      });

      if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudad',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF2D3436),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              hintText: 'Busca tu ciudad...',
              hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
              prefixIcon: const Icon(
                Icons.location_city,
                color: Color(0xFF636E72),
              ),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                    )
                  : _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF636E72)),
                          onPressed: () {
                            _controller.clear();
                            _removeOverlay();
                            widget.onCitySelected('', null);
                          },
                        )
                      : null,
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF9B59B6), width: 2),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),
        Text(
          'Escribe el nombre de tu ciudad',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF636E72),
          ),
        ),
      ],
    );
  }
}
