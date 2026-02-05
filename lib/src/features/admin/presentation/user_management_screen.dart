import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';
import 'package:myapp/src/core/permissions/user_permission_extensions.dart';

/// Provider para listar usuarios
final usersListProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('fechaCreacion', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            // Parsear el rol correctamente
            UserRole rol = UserRole.usuario;
            if (data['rol'] != null) {
              final rolStr = data['rol'].toString();
              rol = UserRole.values.firstWhere(
                (r) => r.name == rolStr,
                orElse: () => UserRole.usuario,
              );
            }

            return UserModel(
              id: doc.id,
              email: data['email'] ?? '',
              nombre: data['nombre'] ?? '',
              edad: data['edad'] ?? 0,
              ciudad: data['ciudad'] ?? '',
              foto: data['foto'] ?? '',
              rol: rol,
              fechaCreacion: data['fechaCreacion'] != null
                  ? DateTime.parse(data['fechaCreacion'])
                  : DateTime.now(),
              ultimaConexion: data['ultimaConexion'] != null
                  ? DateTime.parse(data['ultimaConexion'])
                  : DateTime.now(),
              verificado: data['verificado'] ?? false,
              reputacion: (data['reputacion'] ?? 0.0).toDouble(),
            );
          }).toList());
});

/// Pantalla de gestion de usuarios
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Gestion de Usuarios',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Barra de busqueda y filtros
          _buildSearchAndFilters(),

          // Lista de usuarios
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              data: (users) {
                final filteredUsers = _filterUsers(users);

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron usuarios',
                          style: GoogleFonts.inter(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) =>
                      _buildUserTile(filteredUsers[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Campo de busqueda
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o email...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFFB2BEC3)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF636E72)),
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Filtros por rol
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Todos'),
                const SizedBox(width: 8),
                ...UserRole.values.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(role, role.displayName),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(UserRole? role, String label) {
    final isSelected = _filterRole == role;
    final color = role?.color ?? const Color(0xFF636E72);

    return GestureDetector(
      onTap: () => setState(() => _filterRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF636E72),
          ),
        ),
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _filterRole == null || user.rol == _filterRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Widget _buildUserTile(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: user.roleColor.withOpacity(0.2),
            child: Text(
              user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: user.roleColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.nombre.isNotEmpty ? user.nombre : 'Sin nombre',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.verificado)
                      const Icon(Icons.verified, color: Color(0xFF4ECDC4), size: 16),
                  ],
                ),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF636E72),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: user.roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(user.roleIcon, size: 12, color: user.roleColor),
                const SizedBox(width: 4),
                Text(
                  user.roleName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: user.roleColor,
                  ),
                ),
              ],
            ),
          ),
          // Menu de acciones
          PopupMenuButton<UserRole>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF636E72)),
            onSelected: (newRole) => _changeUserRole(user, newRole),
            itemBuilder: (context) => UserRole.values
                .where((role) => role != user.rol)
                .map(
                  (role) => PopupMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(role.icon, color: role.color, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Cambiar a ${role.displayName}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _changeUserRole(UserModel user, UserRole newRole) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: newRole.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.swap_horiz, color: newRole.color),
            ),
            const SizedBox(width: 12),
            Text(
              'Cambiar rol',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF2D3436),
            ),
            children: [
              const TextSpan(text: 'Cambiar el rol de '),
              TextSpan(
                text: user.nombre,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: ' de '),
              TextSpan(
                text: user.roleName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: user.roleColor,
                ),
              ),
              const TextSpan(text: ' a '),
              TextSpan(
                text: newRole.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: newRole.color,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: const Color(0xFF636E72)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newRole.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirmar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({'rol': newRole.name});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Rol actualizado a ${newRole.displayName}',
                    style: GoogleFonts.inter(),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4ECDC4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al cambiar rol: $e',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}
