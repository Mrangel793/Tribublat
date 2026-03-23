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
  const FeedState._();

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

    // === FILTROS AVANZADOS ===
    String? selectedCity,                              // Ciudad seleccionada
    PlanCategory? selectedCategory,                    // Categoria seleccionada
    @Default(AgeRange.todos) AgeRange selectedAgeRange, // Rango de edad
    @Default(false) bool filterByPlanRestriction,      // Solo con restriccion de edad

    // Estados de carga
    @Default(true) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isSearching,
    @Default(null) String? joiningPlanId,

    // Manejo de errores
    String? errorMessage,
    String? successMessage,
  }) = _FeedState;

  /// Indica si hay filtros avanzados activos
  bool get hasActiveFilters =>
      selectedCity != null ||
      selectedCategory != null ||
      selectedAgeRange != AgeRange.todos ||
      filterByPlanRestriction;

  /// Conteo de filtros activos
  int get activeFiltersCount {
    int count = 0;
    if (selectedCity != null) count++;
    if (selectedCategory != null) count++;
    if (selectedAgeRange != AgeRange.todos) count++;
    if (filterByPlanRestriction) count++;
    return count;
  }
}

/// Controlador del feed
class FeedController extends StateNotifier<FeedState> {
  final PlanRepository _planRepository;
  final UserRepository _userRepository;
  final String? _currentUserId;
  StreamSubscription<List<PlanModel>>? _plansSubscription;
  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
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

  /// Suscribirse al stream de planes según tab y filtro.
  /// Se actualiza automáticamente cuando Firestore cambia.
  Future<void> loadPlans() async {
    // Cancelar suscripción anterior
    await _plansSubscription?.cancel();
    _plansSubscription = null;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final user = state.currentUser;
    final ciudad = user?.ciudad;

    Stream<List<PlanModel>> stream;

    switch (state.currentTab) {
      case FeedTab.paraTi:
        stream = _planRepository.watchActivePlans();
        break;
      case FeedTab.cerca:
        stream = _planRepository.watchActivePlans(ciudad: ciudad);
        break;
      case FeedTab.instantaneos:
        stream = _planRepository.watchInstantPlans();
        break;
      case FeedTab.misPlanes:
        if (_currentUserId != null) {
          stream = _planRepository.watchUserPlans(_currentUserId);
        } else {
          state = state.copyWith(plans: [], isLoading: false);
          return;
        }
    }

    // Escuchar el stream continuamente
    _plansSubscription = stream.listen(
      (rawPlans) {
        Map<String, int> scores = {};

        // Calcular scores de afinidad para "Para ti"
        if (state.currentTab == FeedTab.paraTi && user != null) {
          for (final plan in rawPlans) {
            scores[plan.id] = _planRepository
                .calculateMatchScore(plan, user.intereses, user.nivelEnergia)
                .toInt();
          }
        }

        final filtered = _applyFilter(rawPlans);

        if (mounted) {
          state = state.copyWith(
            plans: filtered,
            matchScores: scores,
            isLoading: false,
            isRefreshing: false,
          );
        }
      },
      onError: (e) {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Error al cargar planes: ${e.toString()}',
          );
        }
      },
    );
  }

  /// Aplicar filtro actual a la lista de planes
  List<PlanModel> _applyFilter(List<PlanModel> plans) {
    final user = state.currentUser;
    var filtered = plans.toList();

    // Aplicar filtro basico (chip seleccionado)
    switch (state.currentFilter) {
      case FeedFilter.todos:
        break;

      case FeedFilter.hoy:
        filtered = filtered.where((p) => p.esHoy).toList();
        break;

      case FeedFilter.cerca:
        if (user?.ciudad != null) {
          filtered = filtered.where((p) => p.ciudad == user!.ciudad).toList();
        }
        break;

      case FeedFilter.miEnergia:
        if (user != null) {
          filtered = filtered.where((p) => p.nivelEnergia == user.nivelEnergia).toList();
        }
        break;
    }

    // === APLICAR FILTROS AVANZADOS ===

    // Filtro por ciudad seleccionada
    if (state.selectedCity != null && state.selectedCity!.isNotEmpty) {
      filtered = filtered.where((p) => p.ciudad == state.selectedCity).toList();
    }

    // Filtro por categoria
    if (state.selectedCategory != null) {
      filtered = filtered.where((p) => p.categoria == state.selectedCategory).toList();
    }

    // Filtro por rango de edad
    if (state.selectedAgeRange != AgeRange.todos) {
      filtered = filtered.where((p) {
        return p.estaEnRangoEdad(
          state.selectedAgeRange.minAge,
          state.selectedAgeRange.maxAge,
        );
      }).toList();
    }

    // Filtro solo planes con restriccion de edad
    if (state.filterByPlanRestriction) {
      filtered = filtered.where((p) => p.tieneRestriccionEdad).toList();
    }

    return filtered;
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

  // ============ FILTROS AVANZADOS ============

  /// Cambiar ciudad seleccionada
  void setCity(String? city) {
    state = state.copyWith(selectedCity: city);
    loadPlans();
  }

  /// Cambiar categoria seleccionada
  void setCategory(PlanCategory? category) {
    state = state.copyWith(selectedCategory: category);
    loadPlans();
  }

  /// Cambiar rango de edad
  void setAgeRange(AgeRange range) {
    state = state.copyWith(selectedAgeRange: range);
    loadPlans();
  }

  /// Toggle filtro de restriccion de edad
  void togglePlanRestrictionFilter(bool value) {
    state = state.copyWith(filterByPlanRestriction: value);
    loadPlans();
  }

  /// Limpiar todos los filtros avanzados
  void clearAllFilters() {
    state = state.copyWith(
      selectedCity: null,
      selectedCategory: null,
      selectedAgeRange: AgeRange.todos,
      filterByPlanRestriction: false,
    );
    loadPlans();
  }

  /// Aplicar multiples filtros a la vez
  void applyFilters({
    String? city,
    PlanCategory? category,
    AgeRange? ageRange,
    bool? planRestriction,
  }) {
    state = state.copyWith(
      selectedCity: city,
      selectedCategory: category,
      selectedAgeRange: ageRange ?? AgeRange.todos,
      filterByPlanRestriction: planRestriction ?? false,
    );
    loadPlans();
  }

  /// Buscar planes con debounce
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);

    // Cancelar busqueda anterior si existe
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      await loadPlans();
      return;
    }

    // Debounce de 300ms para evitar muchas busquedas
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      state = state.copyWith(isSearching: true);

      try {
        // Usar busqueda avanzada (titulo + descripcion + ubicacion)
        final results = await _planRepository.searchPlansAdvanced(
          query,
          ciudad: state.selectedCity,
          categoria: state.selectedCategory,
        );
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
    });
  }

  /// Buscar planes inmediatamente (sin debounce)
  Future<void> searchImmediate(String query) async {
    state = state.copyWith(searchQuery: query, isSearching: true);

    if (query.isEmpty) {
      await loadPlans();
      return;
    }

    try {
      final results = await _planRepository.searchPlansAdvanced(
        query,
        ciudad: state.selectedCity,
        categoria: state.selectedCategory,
      );
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
