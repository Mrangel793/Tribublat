import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/plans/presentation/create/controllers/create_plan_controller.dart';
import 'package:myapp/src/features/plans/presentation/create/widgets/sponsor_options_widget.dart';

class Step4Publicar extends ConsumerWidget {
  const Step4Publicar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPlanControllerProvider);
    final controller = ref.read(createPlanControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Configuracion de privacidad'),
          const SizedBox(height: 16),
          _buildPrivacyOptions(state, controller),

          // Widget de opciones de destacado (solo visible para negocios)
          const SponsorOptionsWidget(),

          const SizedBox(height: 24),
          _buildSectionTitle('Imagen del plan'),
          const SizedBox(height: 8),
          Text(
            'Agrega una imagen para que tu plan sea mas atractivo',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 16),
          _buildImagePicker(context, state.imagenBase64, controller),
          const SizedBox(height: 32),
          _buildSectionTitle('Vista previa'),
          const SizedBox(height: 16),
          _buildPreviewCard(state),
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

  Widget _buildPrivacyOptions(
      CreatePlanState state, CreatePlanController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildPrivacyTile(
            icon: Icons.public,
            title: 'Plan publico',
            subtitle: 'Cualquier persona puede ver y unirse',
            value: state.esPublico,
            onChanged: controller.setEsPublico,
          ),
          const Divider(height: 1, indent: 56),
          _buildPrivacyTile(
            icon: Icons.approval,
            title: 'Requiere aprobacion',
            subtitle: 'Tu apruebas quien se une',
            value: state.requiereAprobacion,
            onChanged: controller.setRequiereAprobacion,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF9B59B6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    String imagenBase64,
    CreatePlanController controller,
  ) {
    final hasImage = imagenBase64.isNotEmpty;

    return GestureDetector(
      onTap: () => _showImagePickerDialog(context, controller),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasImage ? null : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? const Color(0xFF9B59B6) : const Color(0xFFE0E0E0),
            width: hasImage ? 2 : 1,
            style: hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
          image: hasImage
              ? DecorationImage(
                  image: MemoryImage(base64Decode(imagenBase64)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage
            ? Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: controller.removeImagen,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(128),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Cambiar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6).withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF9B59B6),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Agregar imagen',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para seleccionar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImagePickerDialog(
      BuildContext context, CreatePlanController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar imagen',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camara',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, controller);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeria',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, controller);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF9B59B6), size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
      ImageSource source, CreatePlanController controller) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      controller.setImagenFromBytes(bytes);
    }
  }

  Widget _buildPreviewCard(CreatePlanState state) {
    final categoryInfo = state.categoria != null
        ? PlanConstants.getCategoryByEnum(state.categoria!)
        : null;

    final dateFormat = DateFormat('EEE, d MMM', 'es');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(38),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del plan
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: categoryInfo?.color.withAlpha(50) ??
                  const Color(0xFFF8F9FA),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              image: state.imagenBase64.isNotEmpty
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(state.imagenBase64)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: state.imagenBase64.isEmpty
                ? Center(
                    child: Icon(
                      categoryInfo?.icon ?? Icons.event,
                      size: 48,
                      color: categoryInfo?.color ?? const Color(0xFF9B59B6),
                    ),
                  )
                : null,
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría badge
                if (categoryInfo != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(categoryInfo.emoji),
                        const SizedBox(width: 4),
                        Text(
                          categoryInfo.nombre,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: categoryInfo.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Título
                Text(
                  state.titulo.isNotEmpty ? state.titulo : 'Titulo del plan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Fecha y hora
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF636E72)),
                    const SizedBox(width: 4),
                    Text(
                      state.fecha != null
                          ? dateFormat.format(state.fecha!)
                          : 'Fecha',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time,
                        size: 14, color: Color(0xFF636E72)),
                    const SizedBox(width: 4),
                    Text(
                      state.horaInicio != null
                          ? timeFormat.format(state.horaInicio!)
                          : 'Hora',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF636E72),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ubicación
                Row(
                  children: [
                    const Icon(Icons.place, size: 14, color: Color(0xFF636E72)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        state.ubicacionNombre.isNotEmpty
                            ? '${state.ubicacionNombre}, ${state.ciudad}'
                            : state.ciudad.isNotEmpty
                                ? state.ciudad
                                : 'Ubicacion',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF636E72),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Capacidad y precio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group,
                            size: 16, color: Color(0xFF9B59B6)),
                        const SizedBox(width: 4),
                        Text(
                          '1/${state.capacidadMaxima} plazas',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: state.tieneCosto
                            ? const Color(0xFFFFB347).withAlpha(26)
                            : const Color(0xFF4ECDC4).withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.tieneCosto
                            ? '\$${state.precio.toStringAsFixed(0)} COP'
                            : 'Gratis',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: state.tieneCosto
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF4ECDC4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
