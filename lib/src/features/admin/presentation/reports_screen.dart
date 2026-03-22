import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/features/notifications/data/notification_repository.dart';
import 'package:myapp/src/features/reports/data/report_repository.dart';
import 'package:myapp/src/features/reports/domain/report_model.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['Nuevos', 'Revisando', 'Resueltos'];
  static const _statuses = [
    ReportStatus.nuevo,
    ReportStatus.revisando,
    ReportStatus.resuelto,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reportes de usuarios',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) => _buildTab(status)).toList(),
      ),
    );
  }

  Widget _buildTab(ReportStatus status) {
    final reportsAsync = ref.watch(allReportsProvider(status));

    return reportsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Sin reportes en esta categoría',
                  style: GoogleFonts.inter(
                      color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (_, i) => _buildReportCard(reports[i]),
        );
      },
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final color = _colorForStatus(report.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tipo + estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ReportModel.labelForType(report.tipo),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labelForStatus(report.estado),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reportado
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Reportado: ',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  report.reportedUserName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Reportado por
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Por: ',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  report.reporterName,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yy HH:mm').format(report.fechaCreacion),
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),

            // Descripción
            if (report.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${report.descripcion}"',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],

            // Acción tomada (si está resuelto)
            if (report.accionTomada != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.gavel_outlined,
                      size: 15, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    ReportModel.labelForAction(report.accionTomada!),
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.green.shade700),
                  ),
                ],
              ),
            ],

            // Botones de acción (solo para nuevos/revisando)
            if (report.estado != ReportStatus.resuelto) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (report.estado == ReportStatus.nuevo)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _markReviewing(report.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Revisar',
                            style: GoogleFonts.inter(fontSize: 13)),
                      ),
                    ),
                  if (report.estado == ReportStatus.nuevo)
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showResolveDialog(report),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Resolver',
                          style: GoogleFonts.inter(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _markReviewing(String reportId) async {
    await ref.read(reportRepositoryProvider).markAsReviewing(reportId);
  }

  void _showResolveDialog(ReportModel report) {
    ReportAction selectedAction = ReportAction.sinAccion;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Resolver reporte',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acción sobre ${report.reportedUserName}:',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              ...ReportAction.values.map((action) => RadioListTile<ReportAction>(
                    title: Text(ReportModel.labelForAction(action),
                        style: GoogleFonts.inter(fontSize: 13)),
                    value: action,
                    groupValue: selectedAction,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setDialogState(() => selectedAction = v!),
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Nota interna (opcional)',
                  hintStyle: GoogleFonts.inter(fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                style: GoogleFonts.inter(fontSize: 13),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar',
                  style: GoogleFonts.inter(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(reportRepositoryProvider).resolveReport(
                      reportId: report.id,
                      reporterId: report.reporterId,
                      accion: selectedAction,
                      notaAdmin: noteController.text.trim(),
                      notificationRepo:
                          ref.read(notificationRepositoryProvider),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reporte resuelto'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B)),
              child: Text('Confirmar',
                  style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.nuevo:
        return const Color(0xFFFF6B6B);
      case ReportStatus.revisando:
        return Colors.orange;
      case ReportStatus.resuelto:
        return Colors.green;
    }
  }

  String _labelForStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.nuevo:
        return 'Nuevo';
      case ReportStatus.revisando:
        return 'Revisando';
      case ReportStatus.resuelto:
        return 'Resuelto';
    }
  }
}
