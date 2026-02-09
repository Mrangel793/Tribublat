import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
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
          _buildSectionTitle('Configuracion de privacidad', Icons.shield),
          const SizedBox(height: 16),
          _buildPrivacyOptions(state, controller),

          // Widget de opciones de destacado (solo visible para negocios)
          const SponsorOptionsWidget(),

          const SizedBox(height: 24),
          _buildSectionTitle('Imagen del plan', Icons.image),
          const SizedBox(height: 8),
          Text(
            'Agrega una imagen para que tu plan sea mas atractivo',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: DarkFeedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildImagePicker(context, state.imagenBase64, controller),
          const SizedBox(height: 32),
          _buildSectionTitle('Vista previa', Icons.preview),
          const SizedBox(height: 16),
          _buildPreviewCard(state),
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

  Widget _buildPrivacyOptions(
      CreatePlanState state, CreatePlanController controller) {
    return Container(
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkFeedColors.borderSubtle),
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
          Divider(
            height: 1,
            indent: 56,
            color: DarkFeedColors.borderSubtle.withOpacity(0.5),
          ),
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
              color: DarkFeedColors.gradientViolet.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
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
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: DarkFeedColors.gradientOrange,
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
          color: hasImage
              ? null
              : DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? DarkFeedColors.gradientOrange
                : DarkFeedColors.borderSubtle,
            width: hasImage ? 2 : 1,
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
                          color: Colors.black.withOpacity(0.6),
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
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit,
                              color: Colors.white, size: 16),
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
                      gradient: LinearGradient(
                        colors: [
                          DarkFeedColors.gradientOrange.withOpacity(0.15),
                          DarkFeedColors.gradientViolet.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return DarkFeedColors.primaryGradient
                          .createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'Agregar imagen',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para seleccionar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: DarkFeedColors.textSecondary,
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
      backgroundColor: DarkFeedColors.cardBackground,
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
                  color: DarkFeedColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar imagen',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: DarkFeedColors.textPrimary,
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
          color: DarkFeedColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DarkFeedColors.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DarkFeedColors.gradientOrange.withOpacity(0.15),
                    DarkFeedColors.gradientViolet.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return DarkFeedColors.primaryGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DarkFeedColors.textPrimary,
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
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del plan
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: categoryInfo?.color.withOpacity(0.1) ??
                  DarkFeedColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              image: state.imagenBase64.isNotEmpty
                  ? DecorationImage(
                      image:
                          MemoryImage(base64Decode(state.imagenBase64)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: state.imagenBase64.isEmpty
                ? Center(
                    child: Icon(
                      categoryInfo?.icon ?? Icons.event,
                      size: 48,
                      color: categoryInfo?.color.withOpacity(0.5) ??
                          DarkFeedColors.textSecondary,
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
                // Categoria badge
                if (categoryInfo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withOpacity(0.15),
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
                // Titulo
                Text(
                  state.titulo.isNotEmpty
                      ? state.titulo
                      : 'Titulo del plan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DarkFeedColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Fecha y hora
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14,
                        color: DarkFeedColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      state.fecha != null
                          ? dateFormat.format(state.fecha!)
                          : 'Fecha',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time,
                        size: 14,
                        color: DarkFeedColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      state.horaInicio != null
                          ? timeFormat.format(state.horaInicio!)
                          : 'Hora',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DarkFeedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ubicacion
                Row(
                  children: [
                    Icon(Icons.place,
                        size: 14,
                        color: DarkFeedColors.textSecondary),
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
                          color: DarkFeedColors.textSecondary,
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
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return DarkFeedColors.primaryGradient
                                .createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: const Icon(Icons.group,
                              size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1/${state.capacidadMaxima} plazas',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DarkFeedColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: state.tieneCosto
                            ? DarkFeedColors.warningOrange.withOpacity(0.15)
                            : DarkFeedColors.greenEmerald.withOpacity(0.15),
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
                              ? DarkFeedColors.warningOrange
                              : DarkFeedColors.greenEmerald,
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
