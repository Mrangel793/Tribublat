import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/profile/presentation/setup/controllers/profile_setup_controller.dart';
import 'package:myapp/src/features/user/presentation/profile_setup/widgets/city_autocomplete_field.dart';

class Step1BasicInfo extends ConsumerWidget {
  const Step1BasicInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Cuéntanos sobre ti',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta información nos ayudará a personalizar tu experiencia',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Foto de perfil
          _buildPhotoSection(context, state, controller),
          const SizedBox(height: 32),

          // Ciudad con Google Places
          _buildCitySection(context, state, controller),
          const SizedBox(height: 24),

          // Edad
          _buildAgeSection(context, state, controller),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto de perfil',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Opcional - Puedes agregarla después',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => _pickImage(context, controller),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3E8FF),
                border: Border.all(
                  color: const Color(0xFF9B59B6),
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                image: state.fotoBase64.isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(state.fotoBase64)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: state.fotoBase64.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 40,
                          color: const Color(0xFF9B59B6).withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agregar foto',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9B59B6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        if (state.fotoBase64.isNotEmpty) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: controller.removeFoto,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar foto'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[400],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCitySection(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF9B59B6), size: 20),
            const SizedBox(width: 8),
            Text(
              'Ciudad',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        // Google Places Autocomplete
        CityAutocompleteField(
          initialValue: state.ciudad.isNotEmpty ? state.ciudad : null,
          onCitySelected: (cityName, placeId) {
            controller.setCiudad(cityName);
            controller.setCiudadQuery(cityName);
          },
          googleApiKey: 'AIzaSyAZSgqUXXP9bk9SdbrnB0NUIF5siaS5614',
        ),
      ],
    );
  }

  Widget _buildAgeSection(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cake, color: Color(0xFF9B59B6), size: 20),
            const SizedBox(width: 8),
            Text(
              'Edad',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAgeButton(
                icon: Icons.remove,
                onPressed: state.edad > 13 ? controller.decrementEdad : null,
              ),
              Column(
                children: [
                  Text(
                    '${state.edad}',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
                  Text(
                    'años',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              _buildAgeButton(
                icon: Icons.add,
                onPressed: state.edad < 120 ? controller.incrementEdad : null,
              ),
            ],
          ),
        ),
        if (state.edad < 18) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Debes tener al menos 13 años para usar la app',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAgeButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Material(
      color: isEnabled ? const Color(0xFF9B59B6) : Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.grey[500],
            size: 28,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    ProfileSetupController controller,
  ) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF9B59B6)),
                ),
                title: Text(
                  'Tomar foto',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    controller.setFotoFromBytes(bytes);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF9B59B6)),
                ),
                title: Text(
                  'Elegir de galería',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    controller.setFotoFromBytes(bytes);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
