import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

part 'profile_setup_controller.freezed.dart';

/// Estado del formulario de configuración de perfil
@freezed
class ProfileSetupState with _$ProfileSetupState {
  const ProfileSetupState._();

  const factory ProfileSetupState({
    // Paso actual (0-2)
    @Default(0) int currentStep,

    // Step 1: Info Básica
    @Default('') String ciudad,
    @Default('') String ciudadQuery,
    @Default([]) List<String> ciudadesSugeridas,
    @Default(18) int edad,
    @Default('') String fotoBase64,

    // Step 2: Intereses
    @Default([]) List<String> interesesSeleccionados,
    @Default('') String busquedaInteres,

    // Step 3: Energía Social
    @Default(EnergyLevel.media) EnergyLevel nivelEnergia,

    // Estados
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default(false) bool isBuscandoCiudades,
    String? errorMessage,
  }) = _ProfileSetupState;

  /// Número total de pasos
  int get totalSteps => 3;

  /// Porcentaje de progreso
  double get progress => (currentStep + 1) / totalSteps;

  /// Verificar si Step 1 está completo
  /// Acepta ciudad seleccionada de la lista O escrita manualmente
  bool get isStep1Valid {
    final ciudadFinal = ciudad.isNotEmpty ? ciudad : ciudadQuery;
    return ciudadFinal.trim().isNotEmpty && edad >= 13 && edad <= 120;
  }

  /// Verificar si Step 2 está completo (mínimo 3 intereses)
  bool get isStep2Valid => interesesSeleccionados.length >= 3;

  /// Verificar si Step 3 está completo
  bool get isStep3Valid => true; // Siempre válido ya que tiene valor por defecto

  /// Verificar si el paso actual puede avanzar
  bool canProceed(int step) {
    switch (step) {
      case 0:
        return isStep1Valid;
      case 1:
        return isStep2Valid;
      case 2:
        return isStep3Valid;
      default:
        return false;
    }
  }

  /// Verificar si se puede hacer skip del paso actual
  bool canSkip(int step) {
    // Solo se puede saltar el paso de foto en step 1
    // Los demás pasos son obligatorios
    return false;
  }
}

/// Lista de intereses disponibles
class InterestInfo {
  final String id;
  final String nombre;
  final String emoji;

  const InterestInfo({
    required this.id,
    required this.nombre,
    required this.emoji,
  });
}

/// Constantes de intereses
class InterestConstants {
  static const List<InterestInfo> interests = [
    InterestInfo(id: 'gastronomia', nombre: 'Gastronomía', emoji: '🍽️'),
    InterestInfo(id: 'deportes', nombre: 'Deportes', emoji: '⚽'),
    InterestInfo(id: 'cultura', nombre: 'Cultura', emoji: '🏛️'),
    InterestInfo(id: 'vidaNocturna', nombre: 'Vida Nocturna', emoji: '🌙'),
    InterestInfo(id: 'naturaleza', nombre: 'Naturaleza', emoji: '🌿'),
    InterestInfo(id: 'tecnologia', nombre: 'Tecnología', emoji: '💻'),
    InterestInfo(id: 'arte', nombre: 'Arte', emoji: '🎨'),
    InterestInfo(id: 'musica', nombre: 'Música', emoji: '🎵'),
    InterestInfo(id: 'cine', nombre: 'Cine', emoji: '🎬'),
    InterestInfo(id: 'viajes', nombre: 'Viajes', emoji: '✈️'),
    InterestInfo(id: 'gaming', nombre: 'Gaming', emoji: '🎮'),
    InterestInfo(id: 'lectura', nombre: 'Lectura', emoji: '📚'),
    InterestInfo(id: 'fitness', nombre: 'Fitness', emoji: '💪'),
    InterestInfo(id: 'fotografia', nombre: 'Fotografía', emoji: '📷'),
    InterestInfo(id: 'cocina', nombre: 'Cocina', emoji: '👨‍🍳'),
    InterestInfo(id: 'mascotas', nombre: 'Mascotas', emoji: '🐕'),
    InterestInfo(id: 'yoga', nombre: 'Yoga', emoji: '🧘'),
    InterestInfo(id: 'baile', nombre: 'Baile', emoji: '💃'),
    InterestInfo(id: 'senderismo', nombre: 'Senderismo', emoji: '🥾'),
    InterestInfo(id: 'cafe', nombre: 'Café', emoji: '☕'),
  ];

  static List<InterestInfo> search(String query) {
    if (query.isEmpty) return interests;
    final queryLower = query.toLowerCase();
    return interests
        .where((i) => i.nombre.toLowerCase().contains(queryLower))
        .toList();
  }
}

/// Ciudades de Colombia para autocompletado
class CityConstants {
  static const List<String> colombianCities = [
    // Capitales y ciudades principales
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Cúcuta',
    'Pereira',
    'Santa Marta',
    'Ibagué',
    'Manizales',
    'Villavicencio',
    'Pasto',
    'Montería',
    'Neiva',
    'Armenia',
    'Valledupar',
    'Popayán',
    'Sincelejo',
    'Tunja',
    'Florencia',
    'Riohacha',
    'Quibdó',
    'Yopal',
    'Mocoa',
    'Leticia',
    'Mitú',
    'Puerto Carreño',
    'Inírida',
    'San José del Guaviare',
    // Santander
    'Piedecuesta',
    'Floridablanca',
    'Girón',
    'Barrancabermeja',
    'San Gil',
    'Socorro',
    'Barbosa',
    'Lebrija',
    // Antioquia
    'Envigado',
    'Itagüí',
    'Bello',
    'Rionegro',
    'Sabaneta',
    'La Estrella',
    'Copacabana',
    'Apartadó',
    'Turbo',
    'Caucasia',
    // Cundinamarca
    'Soacha',
    'Zipaquirá',
    'Facatativá',
    'Chía',
    'Fusagasugá',
    'Girardot',
    'Madrid',
    'Mosquera',
    'Funza',
    'Cajicá',
    'La Calera',
    'Cota',
    // Valle del Cauca
    'Palmira',
    'Buenaventura',
    'Tuluá',
    'Cartago',
    'Buga',
    'Yumbo',
    'Jamundí',
    // Atlántico
    'Soledad',
    'Malambo',
    'Sabanalarga',
    'Puerto Colombia',
    // Bolívar
    'Magangué',
    'Turbaco',
    'Arjona',
    // Norte de Santander
    'Ocaña',
    'Pamplona',
    'Villa del Rosario',
    'Los Patios',
    // Córdoba
    'Cereté',
    'Lorica',
    'Sahagún',
    // Tolima
    'Espinal',
    'Melgar',
    'Honda',
    'Mariquita',
    // Boyacá
    'Duitama',
    'Sogamoso',
    'Chiquinquirá',
    'Paipa',
    // Meta
    'Acacías',
    'Granada',
    // Risaralda
    'Dosquebradas',
    'Santa Rosa de Cabal',
    // Caldas
    'La Dorada',
    'Chinchiná',
    // Huila
    'Pitalito',
    'Garzón',
    // Nariño
    'Tumaco',
    'Ipiales',
    // Magdalena
    'Ciénaga',
    'Fundación',
    // Cesar
    'Aguachica',
    'Codazzi',
    // Cauca
    'Santander de Quilichao',
    // Quindío
    'Calarcá',
    'La Tebaida',
    // Casanare
    'Aguazul',
    'Tauramena',
    // Sucre
    'Corozal',
    // La Guajira
    'Maicao',
    'Uribia',
    // Arauca
    'Arauca',
    'Saravena',
    // Putumayo
    'Puerto Asís',
    // Caquetá
    'San Vicente del Caguán',
  ];

  static List<String> search(String query) {
    if (query.isEmpty) return [];
    final queryLower = query.toLowerCase();
    return colombianCities
        .where((c) => c.toLowerCase().contains(queryLower))
        .take(5)
        .toList();
  }
}

/// Controlador para configuración de perfil
class ProfileSetupController extends StateNotifier<ProfileSetupState> {
  final UserRepository _userRepository;
  final String? _currentUserId;

  ProfileSetupController(
    this._userRepository,
    this._currentUserId,
  ) : super(const ProfileSetupState());

  // ============ NAVEGACIÓN DE PASOS ============

  void nextStep() {
    if (state.currentStep < 2 && state.canProceed(state.currentStep)) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  // ============ STEP 1: INFO BÁSICA ============

  void setCiudad(String value) {
    state = state.copyWith(ciudad: value);
  }

  void setCiudadQuery(String value) {
    state = state.copyWith(
      ciudadQuery: value,
      ciudadesSugeridas: CityConstants.search(value),
    );
  }

  void selectCiudad(String ciudad) {
    state = state.copyWith(
      ciudad: ciudad,
      ciudadQuery: ciudad,
      ciudadesSugeridas: [],
    );
  }

  void setEdad(int value) {
    state = state.copyWith(edad: value.clamp(13, 120));
  }

  void incrementEdad() {
    setEdad(state.edad + 1);
  }

  void decrementEdad() {
    setEdad(state.edad - 1);
  }

  void setFotoBase64(String value) {
    state = state.copyWith(fotoBase64: value);
  }

  void setFotoFromBytes(Uint8List bytes) {
    final base64String = base64Encode(bytes);
    state = state.copyWith(fotoBase64: base64String);
  }

  void removeFoto() {
    state = state.copyWith(fotoBase64: '');
  }

  // ============ STEP 2: INTERESES ============

  void setBusquedaInteres(String value) {
    state = state.copyWith(busquedaInteres: value);
  }

  void toggleInteres(String interesId) {
    final current = List<String>.from(state.interesesSeleccionados);
    if (current.contains(interesId)) {
      current.remove(interesId);
    } else if (current.length < 10) {
      current.add(interesId);
    }
    state = state.copyWith(interesesSeleccionados: current);
  }

  void clearIntereses() {
    state = state.copyWith(interesesSeleccionados: []);
  }

  // ============ STEP 3: ENERGÍA SOCIAL ============

  void setNivelEnergia(EnergyLevel value) {
    state = state.copyWith(nivelEnergia: value);
  }

  // ============ GUARDAR PERFIL ============

  Future<bool> saveProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      state = state.copyWith(
        errorMessage: 'Debes iniciar sesión para completar tu perfil',
      );
      return false;
    }

    if (!state.isStep1Valid) {
      state = state.copyWith(
        errorMessage: 'Por favor completa la información básica',
      );
      return false;
    }

    if (!state.isStep2Valid) {
      state = state.copyWith(
        errorMessage: 'Selecciona al menos 3 intereses',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Usar ciudad seleccionada o la escrita manualmente
      final ciudadFinal = state.ciudad.isNotEmpty
          ? state.ciudad.trim()
          : state.ciudadQuery.trim();

      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        nombre: firebaseUser.displayName ?? 'Usuario',
        edad: state.edad,
        ciudad: ciudadFinal,
        foto: state.fotoBase64,
        intereses: state.interesesSeleccionados,
        nivelEnergia: state.nivelEnergia,
        fechaCreacion: DateTime.now(),
        ultimaConexion: DateTime.now(),
      );

      await _userRepository.createUserProfile(user);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al guardar el perfil: ${e.toString()}',
      );
      return false;
    }
  }

  /// Saltar configuración (guardar perfil mínimo)
  Future<bool> skipSetup() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        nombre: firebaseUser.displayName ?? 'Usuario',
        edad: 18,
        ciudad: '',
        foto: '',
        intereses: [],
        nivelEnergia: EnergyLevel.media,
        fechaCreacion: DateTime.now(),
        ultimaConexion: DateTime.now(),
      );

      await _userRepository.createUserProfile(user);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al guardar el perfil',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = const ProfileSetupState();
  }
}

/// Provider del controlador de configuración de perfil
final profileSetupControllerProvider =
    StateNotifierProvider.autoDispose<ProfileSetupController, ProfileSetupState>(
        (ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  return ProfileSetupController(
    ref.watch(userRepositoryProvider),
    userId,
  );
});
