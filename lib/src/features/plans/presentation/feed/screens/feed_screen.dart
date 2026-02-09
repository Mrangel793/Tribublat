import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_header.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/express_plans_section.dart';
import '../widgets/plan_card.dart';
import '../widgets/advanced_filters_sheet.dart';

/// Pantalla principal del feed de planes (Dark Mode)
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(feedControllerProvider.notifier).search(query);
  }

  void _onFilterSelected(FeedFilter filter) {
    ref.read(feedControllerProvider.notifier).setFilter(filter);
  }

  void _onTabSelected(FeedTab tab) {
    ref.read(feedControllerProvider.notifier).setTab(tab);
  }

  void _onCategorySelected(PlanCategory? category) {
    ref.read(feedControllerProvider.notifier).setCategory(category);
  }

  Future<void> _onRefresh() async {
    await ref.read(feedControllerProvider.notifier).refresh();
  }

  void _showAdvancedFilters() async {
    final state = ref.read(feedControllerProvider);
    final filters = await showAdvancedFiltersSheet(
      context: context,
      selectedCity: state.selectedCity,
      selectedCategory: state.selectedCategory,
      selectedAgeRange: state.selectedAgeRange,
      filterByRestriction: state.filterByPlanRestriction,
    );

    if (filters != null) {
      ref.read(feedControllerProvider.notifier).applyFilters(
        city: filters.city,
        category: filters.category,
        ageRange: filters.ageRange,
        planRestriction: filters.filterByRestriction,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedControllerProvider);

    // Escuchar errores y mensajes de exito
    ref.listen<FeedState>(
      feedControllerProvider,
      (previous, next) {
        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage!,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: DarkFeedColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          ref.read(feedControllerProvider.notifier).clearError();
        }
        if (next.successMessage != null &&
            next.successMessage != previous?.successMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.successMessage!,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: DarkFeedColors.greenEmerald,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          ref.read(feedControllerProvider.notifier).clearSuccess();
        }
      },
    );

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: DarkFeedColors.gradientOrange,
          backgroundColor: DarkFeedColors.cardBackground,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: FeedHeader(
                  searchController: _searchController,
                  onSearch: _onSearch,
                  onFilterTap: _showAdvancedFilters,
                  activeFiltersCount: state.activeFiltersCount,
                  userName: state.currentUser?.nombre,
                  userPhotoBase64: state.currentUser?.foto,
                  onNotificationTap: () {
                    // TODO: navegar a notificaciones
                  },
                  onAvatarTap: () {
                    // TODO: navegar a perfil
                  },
                ),
              ),

              // ── Express Plans ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ExpressPlansSection(
                    plans: state.plans
                        .where((p) => p.esInstantaneo)
                        .toList(),
                    onPlanTap: (plan) {
                      context.push('/plan/${plan.id}');
                    },
                  ),
                ),
              ),

              // ── Filter Chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: DarkFilterChipsRow(
                    selectedFilter: state.currentFilter,
                    selectedTab: state.currentTab,
                    selectedCategory: state.selectedCategory,
                    onFilterSelected: _onFilterSelected,
                    onTabSelected: _onTabSelected,
                    onCategorySelected: _onCategorySelected,
                  ),
                ),
              ),

              // ── Plans List ──
              if (state.isLoading && state.plans.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DarkFeedColors.gradientOrange,
                      ),
                    ),
                  ),
                )
              else if (state.plans.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(state.currentTab),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final plan = state.plans[index];
                        final matchScore = state.matchScores[plan.id];
                        final controller =
                            ref.read(feedControllerProvider.notifier);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PlanCard(
                            plan: plan,
                            matchPercentage: matchScore,
                            onTap: () {
                              context.push('/plan/${plan.id}');
                            },
                            onJoin: () {
                              if (controller.isUserInPlan(plan)) {
                                controller.leavePlan(plan.id);
                              } else {
                                controller.joinPlan(plan.id);
                              }
                            },
                            isUserJoined: controller.isUserInPlan(plan),
                            isInWaitingList:
                                controller.isUserInWaitingList(plan),
                            isLoading: state.joiningPlanId == plan.id,
                            groupAffinity: matchScore != null
                                ? matchScore / 100
                                : null,
                          ),
                        );
                      },
                      childCount: state.plans.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(FeedTab currentTab) {
    String message;
    String subtitle;
    IconData icon;

    switch (currentTab) {
      case FeedTab.paraTi:
        message = 'No hay planes recomendados';
        subtitle = 'Completa tu perfil para mejores recomendaciones';
        icon = Icons.auto_awesome;
      case FeedTab.cerca:
        message = 'No hay planes cerca';
        subtitle = 'No encontramos planes en tu ciudad';
        icon = Icons.location_off;
      case FeedTab.instantaneos:
        message = 'No hay planes express';
        subtitle = 'Vuelve mas tarde o crea un plan espontaneo';
        icon = Icons.bolt;
      case FeedTab.misPlanes:
        message = 'Aun no tienes planes';
        subtitle = 'Explora y unete a planes que te interesen';
        icon = Icons.event_busy;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DarkFeedColors.gradientViolet.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: DarkFeedColors.gradientViolet,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: DarkFeedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                'Toca + para crear un plan',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
