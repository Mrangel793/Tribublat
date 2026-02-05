import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/profile/presentation/setup/controllers/profile_setup_controller.dart';

class Step2Interests extends HookConsumerWidget {
  const Step2Interests({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);
    final searchController = useTextEditingController();

    final filteredInterests = state.busquedaInteres.isEmpty
        ? InterestConstants.interests
        : InterestConstants.search(state.busquedaInteres);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título y contador
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Qué te interesa?',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona tus intereses para encontrar planes perfectos para ti',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Contador de selección
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: state.interesesSeleccionados.length >= 3
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.interesesSeleccionados.length >= 3
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: state.interesesSeleccionados.length >= 3
                          ? Colors.green[700]
                          : Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.interesesSeleccionados.length >= 3
                            ? '${state.interesesSeleccionados.length} seleccionados'
                            : 'Selecciona al menos 3 intereses (${state.interesesSeleccionados.length}/3)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: state.interesesSeleccionados.length >= 3
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                    Text(
                      'Máx. 10',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Barra de búsqueda
              TextField(
                controller: searchController,
                onChanged: controller.setBusquedaInteres,
                decoration: InputDecoration(
                  hintText: 'Buscar intereses...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: state.busquedaInteres.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            controller.setBusquedaInteres('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid de intereses
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredInterests.length,
              itemBuilder: (context, index) {
                final interest = filteredInterests[index];
                final isSelected = state.interesesSeleccionados.contains(interest.id);
                final canSelect = state.interesesSeleccionados.length < 10 || isSelected;

                return _InterestChip(
                  interest: interest,
                  isSelected: isSelected,
                  canSelect: canSelect,
                  onTap: () => controller.toggleInteres(interest.id),
                );
              },
            ),
          ),
        ),

        // Chips de seleccionados
        if (state.interesesSeleccionados.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tus intereses',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearIntereses,
                      child: Text(
                        'Limpiar',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.interesesSeleccionados.map((id) {
                    final interest = InterestConstants.interests
                        .firstWhere((i) => i.id == id);
                    return Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(interest.emoji),
                          const SizedBox(width: 4),
                          Text(interest.nombre),
                        ],
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => controller.toggleInteres(id),
                      backgroundColor: const Color(0xFFF3E8FF),
                      deleteIconColor: const Color(0xFF9B59B6),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9B59B6),
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final InterestInfo interest;
  final bool isSelected;
  final bool canSelect;
  final VoidCallback onTap;

  const _InterestChip({
    required this.interest,
    required this.isSelected,
    required this.canSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSelect ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9B59B6)
                : canSelect
                    ? Colors.white
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF9B59B6)
                  : canSelect
                      ? Colors.grey[300]!
                      : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(
                interest.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  interest.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : canSelect
                            ? const Color(0xFF2D3748)
                            : Colors.grey[400],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
