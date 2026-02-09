import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
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

    ref.listen<CreatePlanState>(createPlanControllerProvider, (previous, next) {
      if (previous?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        controller.clearError();
      }

      if (next.isSuccess && !previous!.isSuccess) {
        _showSuccessDialog();
      }
    });

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
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
          // Footer
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
                DarkFeedColors.gradientOrange,
                DarkFeedColors.gradientViolet,
                Color(0xFF4ECDC4),
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
      decoration: BoxDecoration(
        color: DarkFeedColors.background,
        border: Border(
          bottom: BorderSide(
            color: DarkFeedColors.borderSubtle.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: DarkFeedColors.textSecondary),
            onPressed: () => _showExitConfirmation(),
          ),
          Expanded(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return DarkFeedColors.primaryGradient
                        .createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Crear plan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  _stepTitles[currentStep],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
                // Circulo del paso
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
                      gradient: isCompleted || isCurrent
                          ? DarkFeedColors.primaryGradient
                          : null,
                      color: isCompleted || isCurrent
                          ? null
                          : DarkFeedColors.surface,
                      shape: BoxShape.circle,
                      border: isCompleted || isCurrent
                          ? null
                          : Border.all(color: DarkFeedColors.borderSubtle),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? Colors.white
                                    : DarkFeedColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                ),
                // Linea conectora
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient:
                            isCompleted ? DarkFeedColors.primaryGradient : null,
                        color: isCompleted ? null : DarkFeedColors.surface,
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DarkFeedColors.background.withOpacity(0.0),
            DarkFeedColors.background.withOpacity(0.9),
            DarkFeedColors.background,
          ],
          stops: const [0.0, 0.3, 0.5],
        ),
      ),
      child: Row(
        children: [
          // Boton Atras
          if (!isFirstStep)
            Expanded(
              child: GestureDetector(
                onTap: controller.previousStep,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: DarkFeedColors.borderSubtle),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'Atras',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          // Boton Siguiente/Publicar
          Expanded(
            child: GestureDetector(
              onTap: canProceed
                  ? () {
                      if (isLastStep) {
                        _publishPlan();
                      } else {
                        controller.nextStep();
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: canProceed
                      ? DarkFeedColors.primaryGradient
                      : null,
                  color: canProceed ? null : DarkFeedColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: canProceed
                      ? [
                          BoxShadow(
                            color: DarkFeedColors.gradientOrange
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
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
                            color: canProceed
                                ? Colors.white
                                : DarkFeedColors.textSecondary,
                          ),
                        ),
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
        backgroundColor: DarkFeedColors.cardBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DarkFeedColors.greenEmerald.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: DarkFeedColors.greenEmerald,
                  size: 45,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Plan creado!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu plan ha sido publicado exitosamente.\nLos usuarios ya pueden verlo y unirse.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: DarkFeedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Boton Ver en feed
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: DarkFeedColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color:
                            DarkFeedColors.gradientOrange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
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
              ),
              const SizedBox(height: 12),
              // Boton Crear otro
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ref.read(createPlanControllerProvider.notifier).reset();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'Crear otro plan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
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
        backgroundColor: DarkFeedColors.cardBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Salir sin guardar?',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        content: Text(
          'Si sales ahora, perderas todo el progreso de tu plan.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Seguir editando',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: DarkFeedColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: DarkFeedColors.errorRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Salir',
                style: GoogleFonts.poppins(
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
}
