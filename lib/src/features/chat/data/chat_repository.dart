import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/chat/domain/chat_message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _messagesRef(String planId) =>
      _firestore.collection('plans').doc(planId).collection('messages');

  /// Stream de mensajes del plan, ordenados por fecha
  Stream<List<ChatMessageModel>> watchMessages(String planId) {
    return _messagesRef(planId)
        .orderBy('fechaCreacion', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                ChatMessageModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Stream de mensajes fijados
  Stream<List<ChatMessageModel>> watchPinnedMessages(String planId) {
    return _messagesRef(planId)
        .where('fijado', isEqualTo: true)
        .orderBy('fechaCreacion', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                ChatMessageModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Envía un mensaje al chat
  Future<void> sendMessage(ChatMessageModel message) async {
    final docRef = _messagesRef(message.planId).doc();
    await docRef.set({...message.toJson(), 'id': docRef.id});
  }

  /// Fija o desfija un mensaje (solo coordinador)
  Future<void> togglePin(String planId, String messageId, bool pin) async {
    await _messagesRef(planId).doc(messageId).update({'fijado': pin});
  }

  /// Reporta un mensaje
  Future<void> reportMessage(String planId, String messageId) async {
    await _messagesRef(planId).doc(messageId).update({'reportado': true});
  }

  /// Elimina todos los mensajes del plan (para Cloud Functions / limpieza 24h)
  Future<void> deleteAllMessages(String planId) async {
    final batch = _firestore.batch();
    final docs = await _messagesRef(planId).get();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, planId) {
  return ref.watch(chatRepositoryProvider).watchMessages(planId);
});

final pinnedMessagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, planId) {
  return ref.watch(chatRepositoryProvider).watchPinnedMessages(planId);
});
