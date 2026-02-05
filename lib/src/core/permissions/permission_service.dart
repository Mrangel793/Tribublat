import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

/// Define los permisos disponibles en la aplicacion
enum AppPermission {
  // Planes
  createPlan,
  editOwnPlan,
  deleteOwnPlan,
  markPlanAsSponsored,
  viewPlanMetrics,
  viewAdvancedMetrics,

  // Usuarios
  viewOwnProfile,
  editOwnProfile,
  changeUserRole,
  viewAllUsers,

  // Admin
  accessAdminPanel,
  manageAppSettings,
}

/// Servicio que valida permisos segun el rol del usuario
class PermissionService {
  /// Mapa de permisos por rol
  static final Map<UserRole, Set<AppPermission>> _rolePermissions = {
    UserRole.usuario: {
      AppPermission.createPlan,
      AppPermission.editOwnPlan,
      AppPermission.deleteOwnPlan,
      AppPermission.viewOwnProfile,
      AppPermission.editOwnProfile,
    },
    UserRole.coordinador: {
      AppPermission.createPlan,
      AppPermission.editOwnPlan,
      AppPermission.deleteOwnPlan,
      AppPermission.viewOwnProfile,
      AppPermission.editOwnProfile,
      AppPermission.viewPlanMetrics,
    },
    UserRole.negocio: {
      AppPermission.createPlan,
      AppPermission.editOwnPlan,
      AppPermission.deleteOwnPlan,
      AppPermission.viewOwnProfile,
      AppPermission.editOwnProfile,
      AppPermission.markPlanAsSponsored,
      AppPermission.viewPlanMetrics,
      AppPermission.viewAdvancedMetrics,
    },
    UserRole.admin: {
      ...AppPermission.values.toSet(), // Admin tiene todos los permisos
    },
  };

  /// Verifica si un rol tiene un permiso especifico
  static bool hasPermission(UserRole role, AppPermission permission) {
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Verifica si el usuario puede crear planes destacados
  static bool canCreateSponsoredPlan(UserRole role) {
    return hasPermission(role, AppPermission.markPlanAsSponsored);
  }

  /// Verifica si el usuario puede ver metricas avanzadas
  static bool canViewAdvancedMetrics(UserRole role) {
    return hasPermission(role, AppPermission.viewAdvancedMetrics);
  }

  /// Verifica si el usuario puede ver metricas basicas
  static bool canViewPlanMetrics(UserRole role) {
    return hasPermission(role, AppPermission.viewPlanMetrics);
  }

  /// Verifica si el usuario puede cambiar roles de otros usuarios
  static bool canChangeUserRoles(UserRole role) {
    return hasPermission(role, AppPermission.changeUserRole);
  }

  /// Verifica si el usuario puede acceder al panel de admin
  static bool canAccessAdminPanel(UserRole role) {
    return hasPermission(role, AppPermission.accessAdminPanel);
  }

  /// Verifica si es un rol de negocio o superior
  static bool isBusinessOrHigher(UserRole role) {
    return role == UserRole.negocio || role == UserRole.admin;
  }

  /// Verifica si es coordinador o superior
  static bool isCoordinatorOrHigher(UserRole role) {
    return role == UserRole.coordinador ||
        role == UserRole.negocio ||
        role == UserRole.admin;
  }

  /// Obtiene la lista de permisos de un rol
  static Set<AppPermission> getPermissionsForRole(UserRole role) {
    return _rolePermissions[role] ?? {};
  }

  /// Obtiene el nivel jerarquico del rol (mayor = mas permisos)
  static int getRoleLevel(UserRole role) {
    switch (role) {
      case UserRole.usuario:
        return 0;
      case UserRole.coordinador:
        return 1;
      case UserRole.negocio:
        return 2;
      case UserRole.admin:
        return 3;
    }
  }

  /// Verifica si un rol tiene nivel minimo requerido
  static bool hasMinimumRole(UserRole userRole, UserRole minimumRole) {
    return getRoleLevel(userRole) >= getRoleLevel(minimumRole);
  }
}

/// Provider para verificar un permiso especifico
final permissionProvider =
    Provider.family<bool, ({UserRole? role, AppPermission permission})>(
        (ref, params) {
  if (params.role == null) return false;
  return PermissionService.hasPermission(params.role!, params.permission);
});
