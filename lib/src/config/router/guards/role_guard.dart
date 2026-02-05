import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/core/permissions/permission_service.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

/// Guard que verifica si el usuario tiene el rol requerido para acceder a una ruta
class RoleGuard {
  final UserRepository _userRepository;

  RoleGuard(this._userRepository);

  /// Obtiene el usuario actual desde Firestore
  Future<UserModel?> _getCurrentUser() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    return await _userRepository.getUserProfile(userId);
  }

  /// Verifica si el usuario actual tiene el rol minimo requerido
  Future<bool> hasMinimumRole(UserRole minimumRole) async {
    final user = await _getCurrentUser();
    if (user == null) return false;
    return PermissionService.hasMinimumRole(user.rol, minimumRole);
  }

  /// Verifica si el usuario tiene un permiso especifico
  Future<bool> hasPermission(AppPermission permission) async {
    final user = await _getCurrentUser();
    if (user == null) return false;
    return PermissionService.hasPermission(user.rol, permission);
  }

  /// Verifica si el usuario es negocio o admin
  Future<bool> isBusinessOrAdmin() async {
    return await hasMinimumRole(UserRole.negocio);
  }

  /// Verifica si el usuario es coordinador o superior
  Future<bool> isCoordinatorOrHigher() async {
    return await hasMinimumRole(UserRole.coordinador);
  }

  /// Verifica si el usuario es admin
  Future<bool> isAdmin() async {
    return await hasMinimumRole(UserRole.admin);
  }

  /// Verifica si el usuario puede ver metricas
  Future<bool> canViewMetrics() async {
    return await hasPermission(AppPermission.viewPlanMetrics);
  }

  /// Verifica si el usuario puede ver metricas avanzadas
  Future<bool> canViewAdvancedMetrics() async {
    return await hasPermission(AppPermission.viewAdvancedMetrics);
  }

  /// Verifica si el usuario puede acceder al panel de admin
  Future<bool> canAccessAdminPanel() async {
    return await hasPermission(AppPermission.accessAdminPanel);
  }
}

/// Provider del RoleGuard
final roleGuardProvider = Provider<RoleGuard>((ref) {
  return RoleGuard(ref.watch(userRepositoryProvider));
});
