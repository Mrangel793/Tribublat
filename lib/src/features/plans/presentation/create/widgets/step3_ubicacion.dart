import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
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
          _buildSectionTitle('Ubicacion del plan', Icons.place),
          const SizedBox(height: 8),
          Text(
            'Donde se realizara tu plan?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: DarkFeedColors.textSecondary,
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return DarkFeedColors.primaryGradient.createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DarkFeedColors.textPrimary,
          ),
        ),
      ],
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
            color: DarkFeedColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ciudadController,
          onChanged: controller.setCiudad,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: DarkFeedColors.textPrimary,
          ),
          cursorColor: DarkFeedColors.gradientOrange,
          decoration: InputDecoration(
            hintText: 'Ej: Bogota, Medellin, Cali...',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: DarkFeedColors.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.location_city, color: Colors.white),
            ),
            filled: true,
            fillColor: DarkFeedColors.cardBackground.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: DarkFeedColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: DarkFeedColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: DarkFeedColors.gradientOrange, width: 2),
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
            color: DarkFeedColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ubicacionController,
          onChanged: controller.setUbicacionNombre,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: DarkFeedColors.textPrimary,
          ),
          cursorColor: DarkFeedColors.gradientOrange,
          decoration: InputDecoration(
            hintText: 'Ej: Parque de la 93, Centro Comercial...',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: DarkFeedColors.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.place, color: Colors.white),
            ),
            filled: true,
            fillColor: DarkFeedColors.cardBackground.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: DarkFeedColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: DarkFeedColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: DarkFeedColors.gradientOrange, width: 2),
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
            color: DarkFeedColors.textSecondary,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DarkFeedColors.gradientOrange.withOpacity(0.15)
                      : DarkFeedColors.cardBackground.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? DarkFeedColors.gradientOrange
                        : DarkFeedColors.borderSubtle,
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
                            ? DarkFeedColors.gradientOrange
                            : DarkFeedColors.textPrimary,
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
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Stack(
        children: [
          // Placeholder del mapa
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: DarkFeedColors.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lat != 0.0 && lng != 0.0
                          ? 'Ubicacion seleccionada'
                          : 'Vista previa del mapa',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                    if (lat != 0.0 && lng != 0.0) ...[
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return DarkFeedColors.primaryGradient
                              .createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Boton de seleccionar en mapa
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Seleccion de mapa proximamente',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: DarkFeedColors.gradientViolet,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: DarkFeedColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          DarkFeedColors.gradientOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location,
                        color: Colors.white, size: 16),
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
