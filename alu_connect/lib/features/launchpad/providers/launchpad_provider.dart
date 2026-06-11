import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/idea_model.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/profile_provider.dart';

class LaunchpadState {
  final List<IdeaModel> ideas;
  final bool loading;
  final bool submitting;
  final String? error;

  const LaunchpadState({
    this.ideas = const [],
    this.loading = false,
    this.submitting = false,
    this.error,
  });

  LaunchpadState copyWith({
    List<IdeaModel>? ideas,
    bool? loading,
    bool? submitting,
    String? error,
  }) =>
      LaunchpadState(
        ideas: ideas ?? this.ideas,
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        error: error,
      );
}

class LaunchpadNotifier extends StateNotifier<LaunchpadState> {
  final SupabaseClient _db;
  final String? _userId;

  LaunchpadNotifier(this._db, this._userId) : super(const LaunchpadState());

  Future<void> fetchIdeas() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final rows = await _db
          .from(SupabaseTables.ideas)
          .select('*, idea_backers(user_id)')
          .order('created_at', ascending: false);

      final ideas = (rows as List).map((row) {
        final backers = (row['idea_backers'] as List?) ?? [];
        final isBackedByMe = _userId != null &&
            backers.any((b) => b['user_id'] == _userId);
        return IdeaModel.fromJson({
          ...row,
          'is_backed_by_me': isBackedByMe,
        });
      }).toList();

      // fall back to mock data when DB is empty (dev / before seeding)
      state = state.copyWith(
        loading: false,
        ideas: ideas.isEmpty ? mockIdeas : ideas,
      );
    } catch (e) {
      // fall back to mock data on any network / query error
      state = state.copyWith(loading: false, ideas: mockIdeas, error: e.toString());
    }
  }

  Future<void> postIdea({
    required String title,
    required String problemStatement,
    required IdeaDomain domain,
    required List<SkillTag> skillsNeeded,
    required UserProfile profile,
  }) async {
    if (_userId == null) return;
    state = state.copyWith(submitting: true, error: null);
    try {
      final row = await _db.from(SupabaseTables.ideas).insert({
        'title': title.trim(),
        'problem_statement': problemStatement.trim(),
        'domain': domain.name,
        'skills_needed': skillsNeeded.map((s) => s.name).toList(),
        'founder_id': _userId,
        'founder_name': profile.fullName,
        'founder_avatar': profile.avatarUrl,
      }).select().single();

      final newIdea = IdeaModel.fromJson(row);
      state = state.copyWith(
        submitting: false,
        ideas: [newIdea, ...state.ideas],
      );
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
    }
  }

  // returns the team chat room id if the threshold is reached, null otherwise
  Future<String?> backIdea(String ideaId) async {
    if (_userId == null) return null;
    try {
      await _db.from(SupabaseTables.backers).insert({
        'idea_id': ideaId,
        'user_id': _userId,
      });

      // refresh just this idea's backer count from db
      final row = await _db
          .from(SupabaseTables.ideas)
          .select('backer_count, team_chat_room_id')
          .eq('id', ideaId)
          .single();

      final newCount = row['backer_count'] as int? ?? 0;
      final chatRoomId = row['team_chat_room_id'] as String?;

      _updateIdeaLocally(
        ideaId,
        backerCount: newCount,
        isBackedByMe: true,
        chatRoomId: chatRoomId,
      );

      // if threshold just reached and no room yet, create one
      if (newCount >= IdeaModel.backerThreshold && chatRoomId == null) {
        return await _createTeamChat(ideaId);
      }
      return chatRoomId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> unbackIdea(String ideaId) async {
    if (_userId == null) return;
    try {
      await _db
          .from(SupabaseTables.backers)
          .delete()
          .eq('idea_id', ideaId)
          .eq('user_id', _userId);

      final row = await _db
          .from(SupabaseTables.ideas)
          .select('backer_count')
          .eq('id', ideaId)
          .single();

      _updateIdeaLocally(
        ideaId,
        backerCount: row['backer_count'] as int? ?? 0,
        isBackedByMe: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String?> _createTeamChat(String ideaId) async {
    try {
      final idea = state.ideas.firstWhere((i) => i.id == ideaId);
      final row = await _db.from(SupabaseTables.chatRooms).insert({
        'name': '${idea.title} — Team Chat',
        'idea_id': ideaId,
        'type': 'team_chat',
      }).select().single();

      final roomId = row['id'] as String;

      // update the idea row with the new chat room id
      await _db
          .from(SupabaseTables.ideas)
          .update({'team_chat_room_id': roomId})
          .eq('id', ideaId);

      _updateIdeaLocally(ideaId, chatRoomId: roomId);
      return roomId;
    } catch (_) {
      return null;
    }
  }

  void _updateIdeaLocally(
    String ideaId, {
    int? backerCount,
    bool? isBackedByMe,
    String? chatRoomId,
  }) {
    state = state.copyWith(
      ideas: state.ideas.map((idea) {
        if (idea.id != ideaId) return idea;
        return idea.copyWith(
          backerCount: backerCount,
          isBackedByMe: isBackedByMe,
          teamChatRoomId: chatRoomId ?? idea.teamChatRoomId,
        );
      }).toList(),
    );
  }

  void clearError() => state = state.copyWith(error: null);
}

final launchpadProvider =
    StateNotifierProvider<LaunchpadNotifier, LaunchpadState>((ref) {
  final db = Supabase.instance.client;
  final userId = db.auth.currentUser?.id;
  return LaunchpadNotifier(db, userId);
});
