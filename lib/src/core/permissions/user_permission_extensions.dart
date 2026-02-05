import 'package:flutter/material.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';
import 'permission_service.dart';

/// Extension methods para verificar permisos directamente en UserModel
extension UserPermissions on UserModel {
  /// Puede crear planes destacados/patrocinados
  bool get canCreateSponsoredPlan =>
      PermissionService.canCreateSponsoredPlan(rol);

  /// Puede ver metricas avanzadas
  bool get canViewAdvancedMetrics =>
      PermissionService.canViewAdvancedMetrics(rol);

  /// Puede ver metricas basicas de planes
  bool get canViewPlanMetrics => PermissionService.canViewPlanMetrics(rol);

  /// Puede cambiar roles de usuarios
  bool get canChangeUserRoles => PermissionService.canChangeUserRoles(rol);

  /// Puede acceder al panel de admin
  bool get canAccessAdminPanel => PermissionService.canAccessAdminPanel(rol);

  /// Es negocio o admin
  bool get isBusinessOrHigher => PermissionService.isBusinessOrHigher(rol);

  /// Es coordinador o superior
  bool get isCoordinatorOrHigher => PermissionService.isCoordinatorOrHigher(rol);

  /// Tiene un permiso especifico
  bool hasPermission(AppPermission permission) =>
      PermissionService.hasPermission(rol, permission);

  /// Nivel jerarquico del rol
  int get roleLevel => PermissionService.getRoleLevel(rol);

  /// Nombre legible del rol
  String get roleName {
    switch (rol) {
      case UserRole.usuario:
        return 'Usuario';
      case UserRole.coordinador:
        return 'Coordinador';
      case UserRole.negocio:
        return 'Negocio';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  /// Descripcion del rol
  String get roleDescription {
    switch (rol) {
      case UserRole.usuario:
        return 'Puede crear y unirse a planes';
      case UserRole.coordinador:
        return 'Acceso a metricas de sus planes';
      case UserRole.negocio:
        return 'Planes destacados y metricas avanzadas';
      case UserRole.admin:
        return 'Acceso completo al sistema';
    }
  }

  /// Color asociado al rol
  Color get roleColor {
    switch (rol) {
      case UserRole.usuario:
        return const Color(0xFF9B59B6); // Morado
      case UserRole.coordinador:
        return const Color(0xFF4ECDC4); // Turquesa
      case UserRole.negocio:
        return const Color(0xFFFFB347); // Naranja
      case UserRole.admin:
        return const Color(0xFFFF6B6B); // Rojo
    }
  }

  /// Icono asociado al rol
  IconData get roleIcon {
    switch (rol) {
      case UserRole.usuario:
        return Icons.person;
      case UserRole.coordinador:
        return Icons.group;
      case UserRole.negocio:
        return Icons.store;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}

/// Extension para obtener info de rol desde el enum directamente
extension UserRoleInfo on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.usuario:
        return 'Usuario';
      case UserRole.coordinador:
        return 'Coordinador';
      case UserRole.negocio:
        return 'Negocio';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.usuario:
        return const Color(0xFF9B59B6);
      case UserRole.coordinador:
        return const Color(0xFF4ECDC4);
      case UserRole.negocio:
        return const Color(0xFFFFB347);
      case UserRole.admin:
        return const Color(0xFFFF6B6B);
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.usuario:
        return Icons.person;
      case UserRole.coordinador:
        return Icons.group;
      case UserRole.negocio:
        return Icons.store;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
