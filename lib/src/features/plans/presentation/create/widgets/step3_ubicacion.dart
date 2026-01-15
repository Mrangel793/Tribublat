import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/plans/presentation/create/controllers/create_plan_controller.dart';

class Step3Ubicacion extends ConsumerStatefulWidget {
  const Step3Ubicacion({super.key});

  @override
  ConsumerState<Step3Ubicacion> createState() => _Step3UbicacionState();
}

class _Step3UbicacionState extends ConsumerState<Step3Ubicacion> {
  final _ciudadController = TextEditingController();
  final _ubicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(createPlanControllerProvider);
    _ciudadController.text = state.ciudad;
    _ubicacionController.text = state.ubicacionNombre;
  }

  @override
  void dispose() {
    _ciudadController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPlanControllerProvider);
    final controller = ref.read(createPlanControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ubicacion del plan'),
          const SizedBox(height: 8),
          Text(
            'Donde se realizara tu plan?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 24),
          _buildCityField(controller),
          const SizedBox(height: 16),
          _buildLocationField(controller),
          const SizedBox(height: 24),
          _buildPopularCities(controller),
          const SizedBox(height: 24),
          _buildMapPreview(state.latitud, state.longitud),
          const SizedBox(height: 100), // Espacio para el footer
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3436),
      ),
    );
  }

  Widget _buildCityField(CreatePlanController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudad',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF636E72),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ciudadController,
          onChanged: controller.setCiudad,
          decoration: InputDecoration(
            hintText: 'Ej: Bogota, Medellin, Cali...',
            hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
            prefixIcon: const Icon(Icons.location_city, color: Color(0xFF636E72)),
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
      ],
    );
  }

  Widget _buildLocationField(CreatePlanController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lugar especifico',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF636E72),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ubicacionController,
          onChanged: controller.setUbicacionNombre,
          decoration: InputDecoration(
            hintText: 'Ej: Parque de la 93, Centro Comercial...',
            hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
            prefixIcon: const Icon(Icons.place, color: Color(0xFF636E72)),
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
      ],
    );
  }

  Widget _buildPopularCities(CreatePlanController controller) {
    final cities = [
      _CityOption(name: 'Bogota', icon: '🏙️'),
      _CityOption(name: 'Medellin', icon: '🌸'),
      _CityOption(name: 'Cali', icon: '💃'),
      _CityOption(name: 'Barranquilla', icon: '🎭'),
      _CityOption(name: 'Cartagena', icon: '🏖️'),
      _CityOption(name: 'Bucaramanga', icon: '🌄'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudades populares',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF636E72),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cities.map((city) {
            final isSelected = _ciudadController.text == city.name;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _ciudadController.text = city.name;
                });
                controller.setCiudad(city.name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF9B59B6).withAlpha(26)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9B59B6)
                        : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(city.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      city.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF9B59B6)
                            : const Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMapPreview(double lat, double lng) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Stack(
        children: [
          // Placeholder del mapa
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: const Color(0xFFE8F4F8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: const Color(0xFF9B59B6).withAlpha(128),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lat != 0.0 && lng != 0.0
                          ? 'Ubicacion seleccionada'
                          : 'Vista previa del mapa',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF636E72),
                      ),
                    ),
                    if (lat != 0.0 && lng != 0.0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9B59B6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Botón de seleccionar en mapa
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                // TODO: Implementar selección en mapa
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Seleccion de mapa proximamente',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: const Color(0xFF9B59B6),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Seleccionar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityOption {
  final String name;
  final String icon;

  const _CityOption({required this.name, required this.icon});
}
