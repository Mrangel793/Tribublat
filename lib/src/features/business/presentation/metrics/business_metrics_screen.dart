import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/features/business/data/metrics_repository.dart';
import 'package:myapp/src/features/business/domain/plan_metrics_model.dart';

/// Provider para las metricas del negocio actual
final businessMetricsProvider = StreamProvider<BusinessMetricsSummary>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(const BusinessMetricsSummary());
  }
  return ref.watch(metricsRepositoryProvider).watchBusinessMetrics(userId);
});

/// Pantalla de metricas para negocios
class BusinessMetricsScreen extends ConsumerWidget {
  const BusinessMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(businessMetricsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Metricas de Negocio',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFFB347),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: metricsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB347)),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar metricas', style: GoogleFonts.inter()),
            ],
          ),
        ),
        data: (metrics) => _buildContent(context, metrics),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessMetricsSummary metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumen
          _buildSummaryCards(metrics),
          const SizedBox(height: 24),

          // Informacion del periodo
          _buildPeriodInfo(),
          const SizedBox(height: 24),

          // Top planes
          _buildTopPlansSection(context, metrics),
          const SizedBox(height: 24),

          // Tips para mejorar
          _buildTipsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BusinessMetricsSummary metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          title: 'Impresiones',
          value: _formatNumber(metrics.totalImpresiones),
          subtitle: 'veces visto',
          icon: Icons.visibility,
          color: const Color(0xFF9B59B6),
        ),
        _buildMetricCard(
          title: 'Conversiones',
          value: _formatNumber(metrics.totalConversiones),
          subtitle: 'personas unidas',
          icon: Icons.people,
          color: const Color(0xFF4ECDC4),
        ),
        _buildMetricCard(
          title: 'Tasa Conv.',
          value: '${metrics.tasaConversionPromedio.toStringAsFixed(1)}%',
          subtitle: 'efectividad',
          icon: Icons.trending_up,
          color: const Color(0xFFFFB347),
        ),
        _buildMetricCard(
          title: 'Ingresos',
          value: '\$${_formatNumber(metrics.ingresosTotales.toInt())}',
          subtitle: 'COP generados',
          icon: Icons.attach_money,
          color: const Color(0xFF2ECC71),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.info_outline, color: Colors.grey[300], size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB347).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB347).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFFFFB347), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metricas totales',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                Text(
                  'Datos desde que comenzaste a usar la plataforma',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlansSection(
      BuildContext context, BusinessMetricsSummary metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Planes con mejor rendimiento',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            Text(
              '${metrics.totalPlanes} planes',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF636E72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (metrics.topPlanes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_note, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Aun no tienes planes',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Crea tu primer plan para ver las metricas',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...metrics.topPlanes
              .asMap()
              .entries
              .map((entry) => _buildPlanMetricTile(entry.key + 1, entry.value)),
      ],
    );
  }

  Widget _buildPlanMetricTile(int position, PlanMetricsModel plan) {
    final positionColor = position == 1
        ? const Color(0xFFFFD700)
        : position == 2
            ? const Color(0xFFC0C0C0)
            : position == 3
                ? const Color(0xFFCD7F32)
                : const Color(0xFF636E72);

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
          // Posicion
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: positionColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$position',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: positionColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info del plan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.planTitulo.isNotEmpty ? plan.planTitulo : 'Plan sin titulo',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniStat(Icons.visibility, '${plan.impresiones}'),
                    const SizedBox(width: 12),
                    _buildMiniStat(Icons.people, '${plan.conversiones}'),
                    const SizedBox(width: 12),
                    _buildMiniStat(
                      Icons.trending_up,
                      '${plan.conversionRate.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Flecha
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF636E72),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF636E72)),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF636E72),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9B59B6).withOpacity(0.1),
            const Color(0xFF4ECDC4).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFFFFB347), size: 24),
              const SizedBox(width: 10),
              Text(
                'Tips para mejorar',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Agrega imagenes atractivas a tus planes'),
          _buildTip('Usa titulos claros y descriptivos'),
          _buildTip('Destaca tus planes para mayor visibilidad'),
          _buildTip('Responde rapido a las solicitudes de union'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4ECDC4), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF636E72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
