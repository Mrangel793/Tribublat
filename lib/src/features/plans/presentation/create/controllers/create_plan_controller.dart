import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';
import 'package:myapp/src/features/plans/domain/plan_constants.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

part 'create_plan_controller.freezed.dart';

/// Estado del formulario de crear plan
@freezed
class CreatePlanState with _$CreatePlanState {
  const CreatePlanState._();

  const factory CreatePlanState({
    // Paso actual (0-3)
    @Default(0) int currentStep,

    // Step 1: Básico
    @Default('') String titulo,
    @Default('') String descripcion,
    @Default(null) PlanCategory? categoria,
    @Default(EnergyLevel.media) EnergyLevel nivelEnergia,
    @Default(5) int capacidadMaxima,
    @Default(false) bool tieneCosto,
    @Default(0.0) double precio,

    // Step 2: Detalles
    @Default(null) DateTime? fecha,
    @Default(null) DateTime? horaInicio,
    @Default(null) DateTime? horaFin,
    @Default(120) int duracionMinutos,

    // Step 3: Ubicación
    @Default('') String ciudad,
    @Default('') String ubicacionNombre,
    @Default(0.0) double latitud,
    @Default(0.0) double longitud,

    // Step 4: Publicar
    @Default(true) bool esPublico,
    @Default(false) bool requiereAprobacion,
    @Default('') String imagenBase64,

    // Estados
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? errorMessage,
    String? createdPlanId,

    // Datos del usuario
    UserModel? currentUser,
  }) = _CreatePlanState;

  /// Verificar si Step 1 está completo
  bool get isStep1Valid =>
      titulo.trim().isNotEmpty &&
      descripcion.trim().isNotEmpty &&
      categoria != null;

  /// Verificar si Step 2 está completo
  bool get isStep2Valid => fecha != null && horaInicio != null;

  /// Verificar si Step 3 está completo
  bool get isStep3Valid =>
      ciudad.trim().isNotEmpty && ubicacionNombre.trim().isNotEmpty;

  /// Verificar si Step 4 está completo
  bool get isStep4Valid => true; // Imagen es opcional

  /// Verificar si el paso actual puede avanzar
  bool canProceed(int step) {
    switch (step) {
      case 0:
        return isStep1Valid;
      case 1:
        return isStep2Valid;
      case 2:
        return isStep3Valid;
      case 3:
        return isStep4Valid;
      default:
        return false;
    }
  }

  /// Porcentaje de progreso total
  double get progressPercentage {
    int completedSteps = 0;
    if (isStep1Valid) completedSteps++;
    if (isStep2Valid) completedSteps++;
    if (isStep3Valid) completedSteps++;
    if (isStep4Valid) completedSteps++;
    return completedSteps / 4;
  }
}

/// Controlador para crear plan
class CreatePlanController extends StateNotifier<CreatePlanState> {
  final PlanRepository _planRepository;
  final UserRepository _userRepository;
  final String? _currentUserId;

  CreatePlanController(
    this._planRepository,
    this._userRepository,
    this._currentUserId,
  ) : super(const CreatePlanState()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUserId == null) return;

    try {
      final user = await _userRepository.getUserProfile(_currentUserId);
      if (user != null) {
        state = state.copyWith(
          currentUser: user,
          ciudad: user.ciudad,
        );
      } else {
        // Si no hay perfil en Firestore, crear uno temporal desde Firebase Auth
        _createFallbackUser();
      }
    } catch (e) {
      // Si falla la carga, crear usuario temporal desde Firebase Auth
      _createFallbackUser();
    }
  }

  void _createFallbackUser() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final fallbackUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        nombre: firebaseUser.displayName ?? 'Usuario',
        edad: 18,
        ciudad: '',
        foto: firebaseUser.photoURL ?? '',
        fechaCreacion: DateTime.now(),
        ultimaConexion: DateTime.now(),
      );
      state = state.copyWith(currentUser: fallbackUser);
    }
  }

  // ============ NAVEGACIÓN DE PASOS ============

  void nextStep() {
    if (state.currentStep < 3 && state.canProceed(state.currentStep)) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  // ============ STEP 1: BÁSICO ============

  void setTitulo(String value) {
    state = state.copyWith(titulo: value);
  }

  void setDescripcion(String value) {
    state = state.copyWith(descripcion: value);
  }

  void setCategoria(PlanCategory? value) {
    state = state.copyWith(categoria: value);
  }

  void setNivelEnergia(EnergyLevel value) {
    state = state.copyWith(nivelEnergia: value);
  }

  void setCapacidadMaxima(int value) {
    state = state.copyWith(capacidadMaxima: value.clamp(2, 50));
  }

  void incrementCapacidad() {
    setCapacidadMaxima(state.capacidadMaxima + 1);
  }

  void decrementCapacidad() {
    setCapacidadMaxima(state.capacidadMaxima - 1);
  }

  void setTieneCosto(bool value) {
    state = state.copyWith(
      tieneCosto: value,
      precio: value ? state.precio : 0.0,
    );
  }

  void setPrecio(double value) {
    state = state.copyWith(precio: value);
  }

  // ============ STEP 2: DETALLES ============

  void setFecha(DateTime? value) {
    state = state.copyWith(fecha: value);
  }

  void setHoraInicio(DateTime? value) {
    state = state.copyWith(horaInicio: value);
    _calculateDuration();
  }

  void setHoraFin(DateTime? value) {
    state = state.copyWith(horaFin: value);
    _calculateDuration();
  }

  void _calculateDuration() {
    if (state.horaInicio != null && state.horaFin != null) {
      final duration = state.horaFin!.difference(state.horaInicio!);
      if (duration.inMinutes > 0) {
        state = state.copyWith(duracionMinutos: duration.inMinutes);
      }
    }
  }

  // ============ STEP 3: UBICACIÓN ============

  void setCiudad(String value) {
    state = state.copyWith(ciudad: value);
  }

  void setUbicacionNombre(String value) {
    state = state.copyWith(ubicacionNombre: value);
  }

  void setCoordinates(double lat, double lng) {
    state = state.copyWith(latitud: lat, longitud: lng);
  }

  // ============ STEP 4: PUBLICAR ============

  void setEsPublico(bool value) {
    state = state.copyWith(esPublico: value);
  }

  void setRequiereAprobacion(bool value) {
    state = state.copyWith(requiereAprobacion: value);
  }

  void setImagenBase64(String value) {
    state = state.copyWith(imagenBase64: value);
  }

  void setImagenFromBytes(Uint8List bytes) {
    final base64String = base64Encode(bytes);
    state = state.copyWith(imagenBase64: base64String);
  }

  void removeImagen() {
    state = state.copyWith(imagenBase64: '');
  }

  // ============ PUBLICAR PLAN ============

  Future<bool> publishPlan() async {
    // Intentar obtener el usuario de Firebase Auth si no tenemos uno
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      state = state.copyWith(
        errorMessage: 'Debes iniciar sesion para crear un plan',
      );
      return false;
    }

    // Si no tenemos currentUser en el estado, crearlo ahora
    if (state.currentUser == null) {
      _createFallbackUser();
    }

    if (!state.isStep1Valid || !state.isStep2Valid || !state.isStep3Valid) {
      state = state.copyWith(
        errorMessage: 'Por favor completa todos los campos requeridos',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Usar datos de Firebase Auth directamente como fallback
      final userName = state.currentUser?.nombre ?? firebaseUser.displayName ?? 'Usuario';
      final userPhoto = state.currentUser?.foto ?? firebaseUser.photoURL ?? '';
      final userReputation = state.currentUser?.reputacion ?? 0.0;

      // Combinar fecha y hora
      final fechaHora = DateTime(
        state.fecha!.year,
        state.fecha!.month,
        state.fecha!.day,
        state.horaInicio!.hour,
        state.horaInicio!.minute,
      );

      final plan = PlanModel(
        id: '', // Se generará en Firestore
        titulo: state.titulo.trim(),
        descripcion: state.descripcion.trim(),
        imagenBase64: state.imagenBase64,
        categoria: state.categoria!,
        estado: PlanStatus.activo,
        organizadorId: firebaseUser.uid,
        organizadorNombre: userName,
        organizadorFoto: userPhoto,
        organizadorReputacion: userReputation,
        fechaHora: fechaHora,
        fechaCreacion: DateTime.now(),
        duracionMinutos: state.duracionMinutos,
        ciudad: state.ciudad.trim(),
        ubicacionNombre: state.ubicacionNombre.trim(),
        latitud: state.latitud,
        longitud: state.longitud,
        capacidadMaxima: state.capacidadMaxima,
        capacidadActual: 1, // El creador cuenta como participante
        participantesIds: [firebaseUser.uid], // El creador se une automáticamente
        nivelEnergia: state.nivelEnergia,
        tipoPrecio: state.tieneCosto ? PlanPriceType.fijo : PlanPriceType.gratis,
        precio: state.tieneCosto ? state.precio : 0.0,
        interesesRelacionados: [state.categoria!.name],
        esPublico: state.esPublico,
        requiereAprobacion: state.requiereAprobacion,
      );

      final planId = await _planRepository.createPlan(plan);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdPlanId: planId,
      );

      return true;
    } on PlanRepositoryException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al crear el plan: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    final user = state.currentUser;
    state = CreatePlanState(
      currentUser: user,
      ciudad: user?.ciudad ?? '',
    );
  }
}

/// Provider del controlador de crear plan
final createPlanControllerProvider =
    StateNotifierProvider.autoDispose<CreatePlanController, CreatePlanState>(
        (ref) {
  // Usar currentUser directamente para obtener el ID de forma síncrona
  final userId = FirebaseAuth.instance.currentUser?.uid;

  return CreatePlanController(
    ref.watch(planRepositoryProvider),
    ref.watch(userRepositoryProvider),
    userId,
  );
});
