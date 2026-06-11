import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/message_model.dart';
import '../../auth/providers/auth_notifier.dart';

// mock communities for dev / offline fallback
final _mockCommunities = [
  const ChatRoom(
    id: 'mock-1',
    name: 'Tech & Innovation',
    description: 'Discussion around software, hardware, and cutting-edge ideas.',
    memberCount: 142,
    isJoined: true,
    isTeamChat: false,
  ),
  const ChatRoom(
    id: 'mock-2',
    name: 'Entrepreneurship Hub',
    description: 'Founders, aspiring founders, and everyone in between.',
    memberCount: 89,
    isJoined: false,
    isTeamChat: false,
  ),
  const ChatRoom(
    id: 'mock-3',
    name: 'Creative Arts & Media',
    description: 'Photography, design, music, and storytelling at ALU.',
    memberCount: 67,
    isJoined: true,
    isTeamChat: false,
  ),
  const ChatRoom(
    id: 'mock-4',
    name: 'Sports & Wellness',
    description: 'Football, basketball, yoga — stay active, stay healthy.',
    memberCount: 201,
    isJoined: false,
    isTeamChat: false,
  ),
  const ChatRoom(
    id: 'mock-5',
    name: 'SRC Updates',
    description: 'Official announcements from the Student Representative Council.',
    memberCount: 480,
    isJoined: true,
    isTeamChat: false,
  ),
];

class CommunitiesState {
  final List<ChatRoom> communities;
  final List<ChatRoom> myTeamChats;
  final bool loading;
  final String? joiningRoomId;
  final String? error;

  const CommunitiesState({
    this.communities = const [],
    this.myTeamChats = const [],
    this.loading = false,
    this.joiningRoomId,
    this.error,
  });

  CommunitiesState copyWith({
    List<ChatRoom>? communities,
    List<ChatRoom>? myTeamChats,
    bool? loading,
    String? joiningRoomId,
    bool clearJoining = false,
    String? error,
  }) =>
      CommunitiesState(
        communities: communities ?? this.communities,
        myTeamChats: myTeamChats ?? this.myTeamChats,
        loading: loading ?? this.loading,
        joiningRoomId: clearJoining ? null : (joiningRoomId ?? this.joiningRoomId),
        error: error,
      );
}

class CommunitiesNotifier extends StateNotifier<CommunitiesState> {
  final SupabaseClient _db;
  final String? _userId;

  CommunitiesNotifier(this._db, this._userId) : super(const CommunitiesState());

  Future<void> fetchCommunities() async {
    state = state.copyWith(loading: true, error: null);
    try {
      // load all community-type rooms
      final roomsRes = await _db
          .from(SupabaseTables.chatRooms)
          .select('id, name, description, member_count, type, idea_id, last_message, last_message_at')
          .eq('type', 'community')
          .order('name');

      // load rooms the current user has joined
      Set<String> joinedIds = {};
      if (_userId != null) {
        final joinedRes = await _db
            .from(SupabaseTables.communityMembers)
            .select('room_id')
            .eq('user_id', _userId);
        joinedIds = {for (final r in joinedRes) r['room_id'] as String};
      }

      final communities = (roomsRes as List).map((r) {
        return ChatRoom.fromJson({
          ...r as Map<String, dynamic>,
          'is_joined': joinedIds.contains(r['id']),
        });
      }).toList();

      // load team chats for this user (backed ideas)
      List<ChatRoom> teamChats = [];
      if (_userId != null) {
        final tcRes = await _db
            .from(SupabaseTables.chatRooms)
            .select('id, name, idea_id, last_message, last_message_at, member_count')
            .eq('type', 'team_chat')
            .order('last_message_at', ascending: false);
        teamChats = (tcRes as List).map((r) => ChatRoom.fromJson({
              ...r as Map<String, dynamic>,
              'is_joined': true,
            })).toList();
      }

      state = state.copyWith(
        communities: communities,
        myTeamChats: teamChats,
        loading: false,
      );
    } catch (_) {
      // graceful fallback to mock data during dev
      state = state.copyWith(
        communities: _mockCommunities,
        myTeamChats: const [],
        loading: false,
      );
    }
  }

  Future<void> joinCommunity(String roomId) async {
    if (_userId == null) return;
    state = state.copyWith(joiningRoomId: roomId, error: null);
    try {
      await _db.from(SupabaseTables.communityMembers).upsert({
        'room_id': roomId,
        'user_id': _userId,
      });
      // best-effort increment — if the DB function doesn't exist, swallow it
      await _db.rpc('increment_member_count', params: {'room_id': roomId}).catchError((_) => null);

      state = state.copyWith(
        clearJoining: true,
        communities: state.communities.map((c) {
          if (c.id == roomId) {
            return c.copyWith(isJoined: true, memberCount: c.memberCount + 1);
          }
          return c;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(clearJoining: true, error: e.toString());
    }
  }

  Future<void> leaveCommunity(String roomId) async {
    if (_userId == null) return;
    state = state.copyWith(joiningRoomId: roomId, error: null);
    try {
      await _db
          .from(SupabaseTables.communityMembers)
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', _userId);

      state = state.copyWith(
        clearJoining: true,
        communities: state.communities.map((c) {
          if (c.id == roomId) {
            return c.copyWith(
              isJoined: false,
              memberCount: c.memberCount > 0 ? c.memberCount - 1 : 0,
            );
          }
          return c;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(clearJoining: true, error: e.toString());
    }
  }

  void markRead(String roomId) {
    state = state.copyWith(
      communities: state.communities.map((c) {
        if (c.id == roomId) return c.copyWith(unreadCount: 0);
        return c;
      }).toList(),
      myTeamChats: state.myTeamChats.map((c) {
        if (c.id == roomId) return c.copyWith(unreadCount: 0);
        return c;
      }).toList(),
    );
  }
}

final communitiesProvider =
    StateNotifierProvider<CommunitiesNotifier, CommunitiesState>((ref) {
  final db = Supabase.instance.client;
  final uid = ref.watch(authNotifierProvider).user?.id;
  return CommunitiesNotifier(db, uid);
});
