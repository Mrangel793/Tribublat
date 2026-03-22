import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/auth/provider/auth_provider.dart';
import 'package:myapp/src/features/notifications/data/notification_repository.dart';
import 'package:myapp/src/features/notifications/domain/notification_model.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: DarkFeedColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: DarkFeedColors.background,
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(backgroundColor: DarkFeedColors.background);
        }

        final notificationsAsync =
            ref.watch(notificationsStreamProvider(user.uid));

        return Scaffold(
          backgroundColor: DarkFeedColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return DarkFeedColors.primaryGradient
                                  .createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Alertas',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'Tus notificaciones',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: DarkFeedColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(notificationRepositoryProvider)
                              .markAllAsRead(user.uid);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: DarkFeedColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: DarkFeedColors.borderSubtle),
                          ),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return DarkFeedColors.primaryGradient
                                  .createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Marcar leídas',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de notificaciones
                Expanded(
                  child: notificationsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: DarkFeedColors.gradientOrange,
                      ),
                    ),
                    error: (_, __) => _buildEmptyState(),
                    data: (notifications) {
                      if (notifications.isEmpty) return _buildEmptyState();

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return GestureDetector(
                            onTap: () {
                              if (!notif.leida) {
                                ref
                                    .read(notificationRepositoryProvider)
                                    .markAsRead(user.uid, notif.id);
                              }
                            },
                            child: _buildNotificationItem(notif),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    DarkFeedColors.gradientOrange.withValues(alpha: 0.1),
                    DarkFeedColors.gradientViolet.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return DarkFeedColors.primaryGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.notifications_none,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin notificaciones',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Te avisaremos cuando haya actividad\nen tus planes',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: DarkFeedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notif) {
    final icon = _iconForType(notif.tipo);
    final color = _colorForType(notif.tipo);
    final timeStr = _formatTime(notif.fechaCreacion);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif.leida
            ? DarkFeedColors.cardBackground.withValues(alpha: 0.6)
            : DarkFeedColors.gradientOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif.leida
              ? DarkFeedColors.borderSubtle
              : DarkFeedColors.gradientOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.titulo,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        notif.leida ? FontWeight.w500 : FontWeight.w600,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notif.cuerpo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DarkFeedColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
              if (!notif.leida) ...[
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: DarkFeedColors.gradientOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForType(NotificationType tipo) {
    switch (tipo) {
      case NotificationType.asistenciaConfirmada:
        return Icons.check_circle_outline;
      case NotificationType.recordatorio:
        return Icons.access_time;
      case NotificationType.planCambiado:
        return Icons.edit_calendar_outlined;
      case NotificationType.planCancelado:
        return Icons.cancel_outlined;
      case NotificationType.listaEspera:
        return Icons.queue_outlined;
    }
  }

  Color _colorForType(NotificationType tipo) {
    switch (tipo) {
      case NotificationType.asistenciaConfirmada:
        return DarkFeedColors.greenEmerald;
      case NotificationType.recordatorio:
        return DarkFeedColors.gradientOrange;
      case NotificationType.planCambiado:
        return const Color(0xFF3498DB);
      case NotificationType.planCancelado:
        return DarkFeedColors.errorRed;
      case NotificationType.listaEspera:
        return DarkFeedColors.gradientViolet;
    }
  }

  String _formatTime(DateTime fecha) {
    final now = DateTime.now();
    final diff = now.difference(fecha);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd/MM').format(fecha);
  }
}
