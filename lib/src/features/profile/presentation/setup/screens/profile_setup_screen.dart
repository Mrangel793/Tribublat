import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/features/profile/presentation/setup/controllers/profile_setup_controller.dart';
import 'package:myapp/src/features/profile/presentation/setup/widgets/step1_basic_info.dart';
import 'package:myapp/src/features/profile/presentation/setup/widgets/step2_interests.dart';
import 'package:myapp/src/features/profile/presentation/setup/widgets/step3_energy.dart';

class ProfileSetupScreen extends HookConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);

    // Escuchar cambios de éxito
    ref.listen<ProfileSetupState>(
      profileSetupControllerProvider,
      (previous, next) {
        if (next.isSuccess && previous?.isSuccess != true) {
          context.go('/');
        }
        if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          controller.clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header con progreso
            _buildHeader(context, state, controller),

            // Contenido del paso actual
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildStepContent(state.currentStep),
              ),
            ),

            // Botones de navegación
            _buildBottomNavigation(context, state, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupController controller,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Botón skip y título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón atrás (solo si no es el primer paso)
              if (state.currentStep > 0)
                IconButton(
                  onPressed: controller.previousStep,
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: Colors.grey[600],
                )
              else
                const SizedBox(width: 48),

              // Indicador de paso
              Text(
                'Paso ${state.currentStep + 1} de ${state.totalSteps}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),

              // Botón skip
              TextButton(
                onPressed: () => _showSkipDialog(context, controller),
                child: Text(
                  'Omitir',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra de progreso
          _buildProgressBar(state),

          // Indicadores de pasos
          const SizedBox(height: 16),
          _buildStepIndicators(state),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ProfileSetupState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: state.progress,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
        minHeight: 6,
      ),
    );
  }

  Widget _buildStepIndicators(ProfileSetupState state) {
    final steps = [
      {'icon': Icons.person_outline, 'label': 'Info'},
      {'icon': Icons.favorite_outline, 'label': 'Intereses'},
      {'icon': Icons.bolt_outlined, 'label': 'Energía'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isActive = index == state.currentStep;
        final isCompleted = index < state.currentStep;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF9B59B6)
                    : isActive
                        ? const Color(0xFFF3E8FF)
                        : Colors.grey[100],
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF9B59B6)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : step['icon'] as IconData,
                color: isCompleted
                    ? Colors.white
                    : isActive
                        ? const Color(0xFF9B59B6)
                        : Colors.grey[400],
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step['label'] as String,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF9B59B6) : Colors.grey[500],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const Step1BasicInfo(key: ValueKey(0));
      case 1:
        return const Step2Interests(key: ValueKey(1));
      case 2:
        return const Step3Energy(key: ValueKey(2));
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupController controller,
  ) {
    final canProceed = state.canProceed(state.currentStep);
    final isLastStep = state.currentStep == state.totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Botón atrás
            if (state.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Atrás',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

            if (state.currentStep > 0) const SizedBox(width: 16),

            // Botón siguiente/finalizar
            Expanded(
              flex: state.currentStep > 0 ? 2 : 1,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : canProceed
                        ? () {
                            if (isLastStep) {
                              controller.saveProfile();
                            } else {
                              controller.nextStep();
                            }
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B59B6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canProceed ? 4 : 0,
                  shadowColor: const Color(0xFF9B59B6).withOpacity(0.4),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastStep ? 'Finalizar' : 'Continuar',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isLastStep) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipDialog(BuildContext context, ProfileSetupController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            ),
            const SizedBox(width: 12),
            Text(
              '¿Omitir configuración?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Sin completar tu perfil, las recomendaciones de planes serán menos precisas. Podrás completarlo después desde tu perfil.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continuar configurando',
              style: GoogleFonts.inter(
                color: const Color(0xFF9B59B6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.skipSetup();
            },
            child: Text(
              'Omitir',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
