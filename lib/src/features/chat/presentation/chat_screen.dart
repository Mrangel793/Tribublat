import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/chat/data/chat_repository.dart';
import 'package:myapp/src/features/chat/domain/chat_message_model.dart';
import 'package:myapp/src/features/plans/data/plan_repository.dart';
import 'package:myapp/src/features/plans/domain/models/plan_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String planId;

  const ChatScreen({super.key, required this.planId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  PlanModel? _plan; // Guardamos el plan para acceder a participantes

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planStreamProvider(widget.planId));

    return planAsync.when(
      loading: () => const Scaffold(
        backgroundColor: DarkFeedColors.background,
        body: Center(child: CircularProgressIndicator(color: DarkFeedColors.gradientOrange)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: DarkFeedColors.background,
        appBar: AppBar(backgroundColor: DarkFeedColors.background),
        body: Center(child: Text(e.toString())),
      ),
      data: (plan) {
        if (plan == null) {
          return Scaffold(
            backgroundColor: DarkFeedColors.background,
            appBar: AppBar(backgroundColor: DarkFeedColors.background),
            body: const Center(child: Text('Plan no encontrado')),
          );
        }
        return _buildChat(plan);
      },
    );
  }

  Widget _buildChat(PlanModel plan) {
    _plan = plan; // Guardamos referencia al plan
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return _buildAccessDenied('Debes iniciar sesión');
    }

    final isParticipant = plan.participantesIds.contains(currentUser.uid) ||
        plan.organizadorId == currentUser.uid;

    if (!isParticipant) {
      return _buildAccessDenied('Solo los participantes confirmados pueden acceder al chat');
    }

    // Verificar si el chat está activo (evento + 24h)
    final eventEnd = plan.fechaHora.add(Duration(minutes: plan.duracionMinutos));
    final chatExpiry = eventEnd.add(const Duration(hours: 24));
    final isChatActive = DateTime.now().isBefore(chatExpiry);

    final isCoordinator = plan.organizadorId == currentUser.uid;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.planId));
    final pinnedAsync = ref.watch(pinnedMessagesProvider(widget.planId));

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      appBar: _buildAppBar(plan, isChatActive, chatExpiry),
      body: Column(
        children: [
          // Banner de mensajes fijados
          pinnedAsync.when(
            data: (pinned) => pinned.isNotEmpty
                ? _buildPinnedBanner(pinned.last)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Aviso si el chat está cerrado
          if (!isChatActive) _buildClosedBanner(chatExpiry),

          // Lista de mensajes
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: DarkFeedColors.gradientOrange),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyMessages();
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.userId == currentUser.uid;
                    return _buildMessageBubble(
                      msg,
                      isMe: isMe,
                      isCoordinator: isCoordinator,
                      plan: plan,
                    );
                  },
                );
              },
            ),
          ),

          // Input de mensaje
          if (isChatActive)
            _buildMessageInput(currentUser)
          else
            _buildInputDisabled(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(PlanModel plan, bool isChatActive, DateTime chatExpiry) {
    return AppBar(
      backgroundColor: DarkFeedColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: DarkFeedColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.titulo,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DarkFeedColors.textPrimary,
            ),
          ),
          Text(
            isChatActive
                ? 'Chat activo · ${plan.participantesIds.length + 1} participantes'
                : 'Chat cerrado',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isChatActive
                  ? DarkFeedColors.greenEmerald
                  : DarkFeedColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedBanner(ChatMessageModel msg) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DarkFeedColors.gradientViolet.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: DarkFeedColors.gradientViolet.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin, size: 16, color: DarkFeedColors.gradientViolet),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg.texto,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: DarkFeedColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedBanner(DateTime expiry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: DarkFeedColors.errorRed.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: DarkFeedColors.errorRed),
          const SizedBox(width: 8),
          Text(
            'Chat cerrado el ${DateFormat('dd/MM HH:mm').format(expiry)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: DarkFeedColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline,
              size: 56, color: DarkFeedColors.borderSubtle),
          const SizedBox(height: 16),
          Text(
            '¡Sé el primero en saludar!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: DarkFeedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessageModel msg, {
    required bool isMe,
    required bool isCoordinator,
    required PlanModel plan,
  }) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(msg, isCoordinator),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: DarkFeedColors.gradientViolet.withValues(alpha: 0.3),
                child: Text(
                  msg.userName.isNotEmpty ? msg.userName[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        msg.userName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: msg.userId == plan.organizadorId
                              ? DarkFeedColors.gradientOrange
                              : DarkFeedColors.textSecondary,
                        ),
                      ),
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? DarkFeedColors.primaryGradient
                          : null,
                      color: isMe ? null : DarkFeedColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      border: msg.fijado
                          ? Border.all(
                              color: DarkFeedColors.gradientViolet,
                              width: 1.5)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.fijado)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.push_pin,
                                  size: 12,
                                  color: DarkFeedColors.gradientViolet),
                              const SizedBox(width: 4),
                              Text(
                                'Fijado',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: DarkFeedColors.gradientViolet,
                                ),
                              ),
                            ],
                          ),
                        Text(
                          msg.texto,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isMe
                                ? Colors.white
                                : DarkFeedColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('HH:mm').format(msg.fechaCreacion),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : DarkFeedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessageModel msg, bool isCoordinator) {
    final isMyMessage = msg.userId == FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      backgroundColor: DarkFeedColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: DarkFeedColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Fijar/Desfijar (solo coordinador)
            if (isCoordinator)
              ListTile(
                leading: Icon(
                  msg.fijado ? Icons.push_pin_outlined : Icons.push_pin,
                  color: DarkFeedColors.gradientViolet,
                ),
                title: Text(
                  msg.fijado ? 'Desfijar mensaje' : 'Fijar mensaje',
                  style: GoogleFonts.inter(
                      color: DarkFeedColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(chatRepositoryProvider).togglePin(
                        widget.planId,
                        msg.id,
                        !msg.fijado,
                      );
                },
              ),
            // Reportar mensaje (no propio)
            if (!isMyMessage)
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: DarkFeedColors.errorRed),
                title: Text(
                  'Reportar mensaje',
                  style: GoogleFonts.inter(
                      color: DarkFeedColors.errorRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmReport(msg);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmReport(ChatMessageModel msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DarkFeedColors.surface,
        title: Text('Reportar mensaje',
            style: GoogleFonts.poppins(
                color: DarkFeedColors.textPrimary,
                fontWeight: FontWeight.w600)),
        content: Text(
          '¿Quieres reportar este mensaje como inapropiado?',
          style: GoogleFonts.inter(color: DarkFeedColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    color: DarkFeedColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(chatRepositoryProvider)
                  .reportMessage(widget.planId, msg.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reporte enviado',
                      style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: DarkFeedColors.greenEmerald,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Reportar',
                style: GoogleFonts.inter(
                    color: DarkFeedColors.errorRed,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(User currentUser) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: DarkFeedColors.surface,
        border: const Border(
            top: BorderSide(color: DarkFeedColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: DarkFeedColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DarkFeedColors.borderSubtle),
              ),
              child: TextField(
                controller: _textController,
                style: GoogleFonts.inter(
                    color: DarkFeedColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: GoogleFonts.inter(
                      color: DarkFeedColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(currentUser),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : () => _sendMessage(currentUser),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: DarkFeedColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputDisabled() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      color: DarkFeedColors.surface,
      child: Text(
        'El chat se cerró 24h después del evento',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: DarkFeedColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAccessDenied(String message) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      appBar: AppBar(
        backgroundColor: DarkFeedColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: DarkFeedColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Chat',
            style: GoogleFonts.poppins(color: DarkFeedColors.textPrimary)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: DarkFeedColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(User currentUser) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _textController.clear();

    try {
      final message = ChatMessageModel(
        id: '',
        planId: widget.planId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Usuario',
        userPhoto: currentUser.photoURL ?? '',
        texto: text,
        fechaCreacion: DateTime.now(),
      );
      // Todos los participantes (incluyendo organizador)
      final allParticipants = <String>[
        ...(_plan?.participantesIds ?? []),
        if (_plan?.organizadorId != null) _plan!.organizadorId,
      ];

      await ref.read(chatRepositoryProvider).sendMessage(
            message,
            participantIds: allParticipants,
            planTitle: _plan?.titulo ?? 'el plan',
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
