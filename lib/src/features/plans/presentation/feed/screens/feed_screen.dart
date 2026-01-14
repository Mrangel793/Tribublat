import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/widgets/tribu_fab.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_header.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/plan_card.dart';

/// Pantalla principal del feed de planes
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final tabs = FeedTab.values;
      ref.read(feedControllerProvider.notifier).setTab(tabs[_tabController.index]);
    }
  }

  void _onSearch(String query) {
    ref.read(feedControllerProvider.notifier).search(query);
  }

  void _onFilterSelected(FeedFilter filter) {
    ref.read(feedControllerProvider.notifier).setFilter(filter);
  }

  Future<void> _onRefresh() async {
    await ref.read(feedControllerProvider.notifier).refresh();
  }

  void _onCreatePlan() {
    // TODO: Navegar a crear plan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crear plan - Proximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onMenuTap() {
    // TODO: Abrir drawer o menú
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu - Proximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onProfileTap() {
    // TODO: Navegar a perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil - Proximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedControllerProvider);

    // Escuchar errores
    ref.listen<FeedState>(
      feedControllerProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(feedControllerProvider.notifier).clearError();
        }
        if (next.successMessage != null && next.successMessage != previous?.successMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: const Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(feedControllerProvider.notifier).clearSuccess();
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FeedHeader(
              searchController: _searchController,
              onSearch: _onSearch,
              onMenuTap: _onMenuTap,
              onProfileTap: _onProfileTap,
              userPhoto: state.currentUser?.foto,
            ),

            const SizedBox(height: 8),

            // Filter chips
            FilterChipsRow(
              selectedFilter: state.currentFilter,
              onFilterSelected: _onFilterSelected,
            ),

            const SizedBox(height: 8),

            // Tab bar
            FeedTabBar(controller: _tabController),

            // Lista de planes
            Expanded(
              child: _buildPlansList(state),
            ),
          ],
        ),
      ),
      floatingActionButton: TribuFab(onPressed: _onCreatePlan),
    );
  }

  Widget _buildPlansList(FeedState state) {
    if (state.isLoading && state.plans.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
        ),
      );
    }

    if (state.plans.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF9B59B6),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.plans.length,
        itemBuilder: (context, index) {
          final plan = state.plans[index];
          final matchScore = state.matchScores[plan.id];
          final controller = ref.read(feedControllerProvider.notifier);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlanCard(
              plan: plan,
              matchPercentage: matchScore,
              onTap: () {
                // TODO: Navegar a detalle del plan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ver plan: ${plan.titulo}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onJoin: () {
                if (controller.isUserInPlan(plan)) {
                  controller.leavePlan(plan.id);
                } else {
                  controller.joinPlan(plan.id);
                }
              },
              isUserJoined: controller.isUserInPlan(plan),
              isInWaitingList: controller.isUserInWaitingList(plan),
              isLoading: state.joiningPlanId == plan.id,
              groupAffinity: matchScore != null ? matchScore / 100 : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;

    switch (ref.read(feedControllerProvider).currentTab) {
      case FeedTab.paraTi:
        message = 'No hay planes recomendados';
        subtitle = 'Intenta completar tu perfil para mejores recomendaciones';
        break;
      case FeedTab.cerca:
        message = 'No hay planes cerca';
        subtitle = 'No encontramos planes en tu ciudad';
        break;
      case FeedTab.instantaneos:
        message = 'No hay planes instantaneos';
        subtitle = 'Vuelve mas tarde o crea un plan espontaneo';
        break;
      case FeedTab.misPlanes:
        message = 'Aun no tienes planes';
        subtitle = 'Explora y unete a planes que te interesen';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy,
                size: 50,
                color: Color(0xFF9B59B6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _onCreatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Crear un plan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
