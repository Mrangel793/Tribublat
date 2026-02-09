import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/plans/presentation/create/controllers/create_plan_controller.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

class Step1Basico extends ConsumerWidget {
  const Step1Basico({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPlanControllerProvider);
    final controller = ref.read(createPlanControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informacion basica', Icons.edit_note),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Titulo del plan',
            hint: 'Ej: Cena en restaurante italiano',
            value: state.titulo,
            onChanged: controller.setTitulo,
            maxLength: 60,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Descripcion',
            hint: 'Describe tu plan, que van a hacer, que deben traer...',
            value: state.descripcion,
            onChanged: controller.setDescripcion,
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Categoria', Icons.grid_view_rounded),
          const SizedBox(height: 12),
          _buildCategoryGrid(state.categoria, controller.setCategoria),
          const SizedBox(height: 24),
          _buildSectionTitle('Nivel de energia', Icons.bolt),
          const SizedBox(height: 12),
          _buildEnergyCards(state.nivelEnergia, controller.setNivelEnergia),
          const SizedBox(height: 24),
          _buildSectionTitle('Capacidad', Icons.group),
          const SizedBox(height: 12),
          _buildCapacityPicker(
            state.capacidadMaxima,
            controller.incrementCapacidad,
            controller.decrementCapacidad,
          ),
          const SizedBox(height: 24),
          _buildCostSection(
            state.tieneCosto,
            state.precio,
            controller.setTieneCosto,
            controller.setPrecio,
          ),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: DarkFeedColors.textPrimary,
          ),
          cursorColor: DarkFeedColors.gradientOrange,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: DarkFeedColors.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: DarkFeedColors.cardBackground.withOpacity(0.6),
            counterStyle: GoogleFonts.inter(
              fontSize: 12,
              color: DarkFeedColors.textSecondary,
            ),
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

  Widget _buildCategoryGrid(
      PlanCategory? selected, Function(PlanCategory?) onSelect) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: PlanConstants.categories.length,
      itemBuilder: (context, index) {
        final category = PlanConstants.categories[index];
        final planCategory = PlanCategory.values.firstWhere(
          (e) => e.name == category.id,
          orElse: () => PlanCategory.otros,
        );
        final isSelected = selected == planCategory;

        return GestureDetector(
          onTap: () => onSelect(planCategory),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? category.color.withOpacity(0.15)
                  : DarkFeedColors.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isSelected ? category.color : DarkFeedColors.borderSubtle,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  category.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? category.color
                        : DarkFeedColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyCards(
      EnergyLevel selected, Function(EnergyLevel) onSelect) {
    final energyLevels = [
      _EnergyOption(
        level: EnergyLevel.baja,
        emoji: '😌',
        title: 'Tranquilo',
        description: 'Relajado, sin prisa',
        color: const Color(0xFF4ECDC4),
      ),
      _EnergyOption(
        level: EnergyLevel.media,
        emoji: '😊',
        title: 'Moderado',
        description: 'Equilibrado',
        color: const Color(0xFFFFB347),
      ),
      _EnergyOption(
        level: EnergyLevel.alta,
        emoji: '🔥',
        title: 'Energetico',
        description: 'Activo, dinamico',
        color: const Color(0xFFFF6B6B),
      ),
    ];

    return Row(
      children: energyLevels.map((option) {
        final isSelected = selected == option.level;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(option.level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withOpacity(0.15)
                    : DarkFeedColors.cardBackground.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? option.color
                      : DarkFeedColors.borderSubtle,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(option.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    option.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? option.color
                          : DarkFeedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: DarkFeedColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCapacityPicker(
    int value,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Numero de participantes',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
              Text(
                'Incluye al organizador',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.remove,
                onTap: onDecrement,
                enabled: value > 2,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return DarkFeedColors.primaryGradient
                        .createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    '$value',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _buildCircleButton(
                icon: Icons.add,
                onTap: onIncrement,
                enabled: value < 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: enabled ? DarkFeedColors.primaryGradient : null,
          color: enabled ? null : DarkFeedColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : DarkFeedColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCostSection(
    bool hasCost,
    double price,
    Function(bool) onToggle,
    Function(double) onPriceChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Costo', Icons.attach_money),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DarkFeedColors.cardBackground.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DarkFeedColors.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Este plan tiene costo?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: DarkFeedColors.textPrimary,
                        ),
                      ),
                      Text(
                        hasCost ? 'Precio por persona' : 'Plan gratuito',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DarkFeedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: hasCost,
                    onChanged: onToggle,
                    activeColor: DarkFeedColors.gradientOrange,
                  ),
                ],
              ),
              if (hasCost) ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: price > 0 ? price.toString() : '',
                  onChanged: (v) => onPriceChange(double.tryParse(v) ?? 0),
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: DarkFeedColors.textPrimary,
                  ),
                  cursorColor: DarkFeedColors.gradientOrange,
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DarkFeedColors.textPrimary,
                    ),
                    hintText: '0',
                    hintStyle: GoogleFonts.inter(
                      color: DarkFeedColors.textSecondary.withOpacity(0.5),
                    ),
                    suffixText: 'COP',
                    suffixStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: DarkFeedColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: DarkFeedColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: DarkFeedColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: DarkFeedColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: DarkFeedColors.gradientOrange, width: 2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EnergyOption {
  final EnergyLevel level;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const _EnergyOption({
    required this.level,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
