import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/plans/presentation/create/controllers/create_plan_controller.dart';
import 'package:myapp/src/features/plans/presentation/create/widgets/step1_basico.dart';
import 'package:myapp/src/features/plans/presentation/create/widgets/step2_detalles.dart';
import 'package:myapp/src/features/plans/presentation/create/widgets/step3_ubicacion.dart';
import 'package:myapp/src/features/plans/presentation/create/widgets/step4_publicar.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  late ConfettiController _confettiController;
  final PageController _pageController = PageController();

  final _stepTitles = [
    'Basico',
    'Detalles',
    'Ubicacion',
    'Publicar',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPlanControllerProvider);
    final controller = ref.read(createPlanControllerProvider.notifier);

    // Escuchar cambios de paso para animar el PageView
    ref.listen<CreatePlanState>(createPlanControllerProvider, (previous, next) {
      if (previous?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      // Mostrar error si existe
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        controller.clearError();
      }

      // Mostrar éxito
      if (next.isSuccess && !previous!.isSuccess) {
        _showSuccessDialog();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(state.currentStep),
              _buildStepIndicator(state.currentStep),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    // Solo actualizar si viene del swipe (no del controller)
                  },
                  children: const [
                    Step1Basico(),
                    Step2Detalles(),
                    Step3Ubicacion(),
                    Step4Publicar(),
                  ],
                ),
              ),
            ],
          ),
          // Footer con botones de navegación
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFooter(state, controller),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Color(0xFF9B59B6),
                Color(0xFF4ECDC4),
                Color(0xFFFFB347),
                Color(0xFFFF6B9D),
                Color(0xFF6C5CE7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int currentStep) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF2D3436)),
            onPressed: () => _showExitConfirmation(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Crear plan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                Text(
                  _stepTitles[currentStep],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          // Placeholder para balancear el espacio
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                // Círculo del paso
                GestureDetector(
                  onTap: index < currentStep
                      ? () => ref
                          .read(createPlanControllerProvider.notifier)
                          .goToStep(index)
                      : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? const Color(0xFF9B59B6)
                          : const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF636E72),
                              ),
                            ),
                    ),
                  ),
                ),
                // Línea conectora
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF9B59B6)
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter(CreatePlanState state, CreatePlanController controller) {
    final isFirstStep = state.currentStep == 0;
    final isLastStep = state.currentStep == 3;
    final canProceed = state.canProceed(state.currentStep);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón Atrás
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF9B59B6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Atras',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9B59B6),
                  ),
                ),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          // Botón Siguiente/Publicar
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (isLastStep) {
                        _publishPlan();
                      } else {
                        controller.nextStep();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF9B59B6),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: canProceed ? 4 : 0,
                shadowColor: const Color(0xFF9B59B6).withAlpha(100),
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
                  : Text(
                      isLastStep ? 'Publicar plan' : 'Siguiente',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publishPlan() async {
    final controller = ref.read(createPlanControllerProvider.notifier);
    final success = await controller.publishPlan();
    if (success) {
      _confettiController.play();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de éxito
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Color(0xFF4ECDC4),
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Plan creado!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu plan ha sido publicado exitosamente.\nLos usuarios ya pueden verlo y unirse.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF636E72),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Botón Ver plan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B59B6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Ver en el feed',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Botón Crear otro
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(createPlanControllerProvider.notifier).reset();
                  },
                  child: Text(
                    'Crear otro plan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Salir sin guardar?',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        content: Text(
          'Si sales ahora, perderas todo el progreso de tu plan.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF636E72),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Seguir editando',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF636E72),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Salir',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
