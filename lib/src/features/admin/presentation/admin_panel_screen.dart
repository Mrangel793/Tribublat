import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/reports/data/report_repository.dart';
import 'package:myapp/src/features/business/data/business_request_repository.dart';

/// Pantalla principal del panel de administracion
class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Panel de Administracion',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estas en el panel de administracion. Las acciones aqui afectan a toda la aplicacion.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Estadisticas rapidas
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Menu de opciones
            Text(
              'Gestion',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),

            _buildAdminOption(
              context,
              icon: Icons.people,
              title: 'Gestion de Usuarios',
              subtitle: 'Cambiar roles, ver usuarios, etc.',
              color: const Color(0xFF9B59B6),
              onTap: () => context.push('/admin/users'),
            ),
            Consumer(
              builder: (context, ref, _) {
                final countAsync =
                    ref.watch(pendingBusinessCountProvider);
                final count = countAsync.valueOrNull ?? 0;
                return _buildAdminOption(
                  context,
                  icon: Icons.store_outlined,
                  title: 'Solicitudes de negocio',
                  subtitle: count > 0
                      ? '$count solicitudes pendientes'
                      : 'Aprobar cuentas de negocio',
                  color: const Color(0xFF9B59B6),
                  badge: count > 0 ? count.toString() : null,
                  onTap: () =>
                      context.push('/admin/business-requests'),
                );
              },
            ),
            _buildAdminOption(
              context,
              icon: Icons.event_note,
              title: 'Gestion de Planes',
              subtitle: 'Moderar planes, ver reportes',
              color: const Color(0xFF4ECDC4),
              onTap: () {
                _showComingSoon(context);
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final countAsync = ref.watch(newReportsCountProvider);
                final count = countAsync.valueOrNull ?? 0;
                return _buildAdminOption(
                  context,
                  icon: Icons.flag,
                  title: 'Reportes',
                  subtitle: count > 0
                      ? '$count nuevos reportes pendientes'
                      : 'Ver reportes de usuarios',
                  color: const Color(0xFFFFB347),
                  badge: count > 0 ? count.toString() : null,
                  onTap: () => context.push('/admin/reports'),
                );
              },
            ),
            _buildAdminOption(
              context,
              icon: Icons.bar_chart,
              title: 'Estadisticas Globales',
              subtitle: 'Metricas de la plataforma',
              color: const Color(0xFF2ECC71),
              onTap: () {
                _showComingSoon(context);
              },
            ),
            _buildAdminOption(
              context,
              icon: Icons.settings,
              title: 'Configuracion',
              subtitle: 'Ajustes de la aplicacion',
              color: const Color(0xFF636E72),
              onTap: () {
                _showComingSoon(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            value: '--',
            label: 'Usuarios',
            color: const Color(0xFF9B59B6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event,
            value: '--',
            label: 'Planes',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.flag,
            value: '--',
            label: 'Reportes',
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF636E72),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            if (badge != null) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF636E72)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Funcionalidad en desarrollo',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF636E72),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
