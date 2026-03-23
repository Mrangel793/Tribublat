import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/features/business/data/business_request_repository.dart';
import 'package:myapp/src/features/business/domain/business_request_model.dart';

class BusinessRequestsScreen extends ConsumerStatefulWidget {
  const BusinessRequestsScreen({super.key});

  @override
  ConsumerState<BusinessRequestsScreen> createState() =>
      _BusinessRequestsScreenState();
}

class _BusinessRequestsScreenState
    extends ConsumerState<BusinessRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['Pendientes', 'Aprobadas', 'Rechazadas'];
  static const _statuses = [
    BusinessRequestStatus.pendiente,
    BusinessRequestStatus.aprobada,
    BusinessRequestStatus.rechazada,
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
        backgroundColor: const Color(0xFF9B59B6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Solicitudes de negocio',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            _statuses.map((status) => _buildTab(status)).toList(),
      ),
    );
  }

  Widget _buildTab(BusinessRequestStatus status) {
    final requestsAsync = ref.watch(allBusinessRequestsProvider(status));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('Sin solicitudes',
                    style: GoogleFonts.inter(
                        color: Colors.grey.shade500, fontSize: 15)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (_, i) => _buildCard(requests[i]),
        );
      },
    );
  }

  Widget _buildCard(BusinessRequestModel request) {
    final isPending = request.estado == BusinessRequestStatus.pendiente;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store,
                      color: Color(0xFF9B59B6), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.nombreEmpresa,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text(
                          BusinessRequestModel.labelForType(
                              request.tipoNegocio),
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(
                    DateFormat('dd/MM/yy')
                        .format(request.fechaSolicitud),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Info
            _row(Icons.person_outline, request.userName),
            _row(Icons.email_outlined, request.userEmail),
            _row(Icons.badge_outlined, 'NIT: ${request.nit}'),
            _row(Icons.phone_outlined, request.telefono),
            if (request.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(request.descripcion,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey.shade700)),
              ),
            ],

            // Nota admin (si ya fue procesada)
            if (request.notaAdmin?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.notes, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Admin: ${request.notaAdmin}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],

            // Botones (solo para pendientes)
            if (isPending) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showRejectDialog(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Rechazar',
                          style: GoogleFonts.inter(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approve(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Aprobar',
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

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.black87)),
            ),
          ],
        ),
      );

  Future<void> _approve(BusinessRequestModel request) async {
    try {
      await ref
          .read(businessRequestRepositoryProvider)
          .approveRequest(request.id, request.userId, '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Solicitud aprobada. Rol cambiado a negocio.'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showRejectDialog(BusinessRequestModel request) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rechazar solicitud',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Rechazar la solicitud de "${request.nombreEmpresa}"?',
                style: GoogleFonts.inter(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                hintText: 'Motivo del rechazo (opcional)',
                hintStyle: GoogleFonts.inter(fontSize: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              maxLines: 2,
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(businessRequestRepositoryProvider)
                  .rejectRequest(
                      request.id, request.userId, noteCtrl.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Solicitud rechazada'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Rechazar',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
