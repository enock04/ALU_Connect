import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/message_model.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/profile_provider.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool loading;
  final bool sending;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.loading = false,
    this.sending = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? loading,
    bool? sending,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        loading: loading ?? this.loading,
        sending: sending ?? this.sending,
        error: error,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SupabaseClient _db;
  final String _roomId;
  final String? _userId;
  final String? _displayName;

  RealtimeChannel? _channel;

  ChatNotifier(this._db, this._roomId, this._userId, this._displayName)
      : super(const ChatState());

  Future<void> initialise() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _loadHistory();
      _subscribeRealtime();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _loadHistory() async {
    final res = await _db
        .from(SupabaseTables.messages)
        .select('id, room_id, sender_id, sender_name, sender_avatar, body, sent_at')
        .eq('room_id', _roomId)
        .order('sent_at')
        .limit(80);

    final msgs = (res as List)
        .map((m) => MessageModel.fromJson(m as Map<String, dynamic>, currentUserId: _userId))
        .toList();

    state = state.copyWith(messages: msgs, loading: false);
  }

  void _subscribeRealtime() {
    _channel = _db.channel(SupabaseChannels.chatRoom(_roomId));

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.messages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: _roomId,
          ),
          callback: (payload) {
            final newMsg = MessageModel.fromJson(
              payload.newRecord,
              currentUserId: _userId,
            );
            // avoid duplicates (optimistic messages already in list)
            final alreadyIn = state.messages.any((m) => m.id == newMsg.id);
            if (!alreadyIn) {
              state = state.copyWith(messages: [...state.messages, newMsg]);
            }
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _userId == null) return;

    state = state.copyWith(sending: true, error: null);

    // optimistic insert
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      roomId: _roomId,
      senderId: _userId,
      senderName: _displayName ?? 'You',
      body: trimmed,
      sentAt: DateTime.now(),
      isMe: true,
    );
    state = state.copyWith(
      messages: [...state.messages, optimistic],
      sending: false,
    );

    try {
      await _db.from(SupabaseTables.messages).insert({
        'room_id': _roomId,
        'sender_id': _userId,
        'sender_name': _displayName ?? 'Student',
        'body': trimmed,
        'sent_at': DateTime.now().toIso8601String(),
      });
      // realtime callback will add the real message; remove temp
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempId).toList(),
      );
    } catch (e) {
      // remove optimistic message on failure
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempId).toList(),
        sending: false,
        error: 'Failed to send: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

// Family provider — one instance per roomId, auto-disposed when screen leaves
final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>((ref, roomId) {
  final db = Supabase.instance.client;
  final uid = ref.watch(authNotifierProvider).user?.id;
  final profile = ref.watch(currentProfileProvider);
  final displayName = profile?.fullName;
  final notifier = ChatNotifier(db, roomId, uid, displayName);
  notifier.initialise();
  return notifier;
});
