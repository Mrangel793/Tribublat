import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/user/data/user_repository.dart' show UserRepository, userRepositoryProvider;
import 'package:myapp/src/features/user/domain/user_model.dart';

part 'feed_controller.freezed.dart';

/// Estado del feed
@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    // Tab y filtro actual
    @Default(FeedTab.paraTi) FeedTab currentTab,
    @Default(FeedFilter.todos) FeedFilter currentFilter,
    @Default('') String searchQuery,

    // Datos de planes
    @Default([]) List<PlanModel> plans,
    @Default({}) Map<String, int> matchScores,

    // Datos del usuario para matching
    UserModel? currentUser,

    // Estados de carga
    @Default(true) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isSearching,
    @Default(null) String? joiningPlanId,

    // Manejo de errores
    String? errorMessage,
    String? successMessage,
  }) = _FeedState;
}

/// Controlador del feed
class FeedController extends StateNotifier<FeedState> {
  final PlanRepository _planRepository;
  final UserRepository _userRepository;
  final String? _currentUserId;
  StreamSubscription<List<PlanModel>>? _plansSubscription;

  FeedController(
    this._planRepository,
    this._userRepository,
    this._currentUserId,
  ) : super(const FeedState()) {
    _initialize();
  }

  @override
  void dispose() {
    _plansSubscription?.cancel();
    super.dispose();
  }

  /// Inicializar feed
  Future<void> _initialize() async {
    if (_currentUserId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Usuario no autenticado',
      );
      return;
    }

    try {
      // Cargar perfil del usuario para personalización
      final user = await _userRepository.getUserProfile(_currentUserId);
      state = state.copyWith(currentUser: user);

      // Cargar planes iniciales
      await loadPlans();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar el feed: ${e.toString()}',
      );
    }
  }

  /// Cargar planes según tab y filtro actual
  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      List<PlanModel> plans;
      Map<String, int> scores = {};

      final user = state.currentUser;
      final ciudad = user?.ciudad;

      switch (state.currentTab) {
        case FeedTab.paraTi:
          if (user != null) {
            plans = await _planRepository.getPersonalizedPlans(
              userInterests: user.intereses,
              userEnergyLevel: user.nivelEnergia,
              ciudad: ciudad,
            );
            // Calcular scores para mostrar
            for (final plan in plans) {
              final score = _planRepository.calculateMatchScore(
                plan,
                user.intereses,
                user.nivelEnergia,
              );
              scores[plan.id] = score.toInt();
            }
          } else {
            plans = await _planRepository.watchActivePlans(ciudad: ciudad).first;
          }
          break;

        case FeedTab.cerca:
          plans = await _planRepository.watchActivePlans(ciudad: ciudad).first;
          break;

        case FeedTab.instantaneos:
          plans = await _planRepository.watchInstantPlans(ciudad: ciudad).first;
          break;

        case FeedTab.misPlanes:
          if (_currentUserId != null) {
            plans = await _planRepository.watchUserPlans(_currentUserId).first;
          } else {
            plans = [];
          }
          break;
      }

      // Aplicar filtro
      plans = _applyFilter(plans);

      state = state.copyWith(
        plans: plans,
        matchScores: scores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar planes: ${e.toString()}',
      );
    }
  }

  /// Aplicar filtro actual a la lista de planes
  List<PlanModel> _applyFilter(List<PlanModel> plans) {
    final user = state.currentUser;

    switch (state.currentFilter) {
      case FeedFilter.todos:
        return plans;

      case FeedFilter.hoy:
        return plans.where((p) => p.esHoy).toList();

      case FeedFilter.cerca:
        if (user?.ciudad != null) {
          return plans.where((p) => p.ciudad == user!.ciudad).toList();
        }
        return plans;

      case FeedFilter.miEnergia:
        if (user != null) {
          return plans.where((p) => p.nivelEnergia == user.nivelEnergia).toList();
        }
        return plans;
    }
  }

  /// Cambiar tab actual
  void setTab(FeedTab tab) {
    if (state.currentTab != tab) {
      state = state.copyWith(currentTab: tab, plans: []);
      loadPlans();
    }
  }

  /// Cambiar filtro actual
  void setFilter(FeedFilter filter) {
    if (state.currentFilter != filter) {
      state = state.copyWith(currentFilter: filter);
      loadPlans();
    }
  }

  /// Buscar planes
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);

    if (query.isEmpty) {
      await loadPlans();
      return;
    }

    state = state.copyWith(isSearching: true);

    try {
      final results = await _planRepository.searchPlans(query);
      state = state.copyWith(
        plans: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Error en la busqueda: ${e.toString()}',
      );
    }
  }

  /// Unirse a un plan
  Future<bool> joinPlan(String planId) async {
    if (_currentUserId == null) return false;

    state = state.copyWith(joiningPlanId: planId);

    try {
      await _planRepository.joinPlan(planId, _currentUserId);
      state = state.copyWith(
        joiningPlanId: null,
        successMessage: 'Te has unido al plan',
      );
      await loadPlans();
      return true;
    } on PlanRepositoryException catch (e) {
      state = state.copyWith(
        joiningPlanId: null,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        joiningPlanId: null,
        errorMessage: 'Error al unirse: ${e.toString()}',
      );
      return false;
    }
  }

  /// Salir de un plan
  Future<bool> leavePlan(String planId) async {
    if (_currentUserId == null) return false;

    state = state.copyWith(joiningPlanId: planId);

    try {
      await _planRepository.leavePlan(planId, _currentUserId);
      state = state.copyWith(
        joiningPlanId: null,
        successMessage: 'Has salido del plan',
      );
      await loadPlans();
      return true;
    } on PlanRepositoryException catch (e) {
      state = state.copyWith(
        joiningPlanId: null,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        joiningPlanId: null,
        errorMessage: 'Error al salir: ${e.toString()}',
      );
      return false;
    }
  }

  /// Verificar si el usuario está en un plan
  bool isUserInPlan(PlanModel plan) {
    return plan.isUserParticipant(_currentUserId ?? '');
  }

  /// Verificar si el usuario está en lista de espera
  bool isUserInWaitingList(PlanModel plan) {
    return plan.isUserInWaitingList(_currentUserId ?? '');
  }

  /// Limpiar mensaje de error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Limpiar mensaje de éxito
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  /// Refrescar feed
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await loadPlans();
    state = state.copyWith(isRefreshing: false);
  }
}

/// Provider del controlador del feed
final feedControllerProvider =
    StateNotifierProvider.autoDispose<FeedController, FeedState>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userId = authState.value?.uid;

  return FeedController(
    ref.watch(planRepositoryProvider),
    ref.watch(userRepositoryProvider),
    userId,
  );
});
