import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_notifier.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String role; // student | organiser | club_leader
  final String? bio;
  final String? campus;
  final int? cohortYear;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.role = 'student',
    this.bio,
    this.campus,
    this.cohortYear,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'student',
      bio: json['bio'] as String?,
      campus: json['campus'] as String?,
      cohortYear: json['cohort_year'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'username': username,
        'avatar_url': avatarUrl,
        'role': role,
        'bio': bio,
        'campus': campus,
        'cohort_year': cohortYear,
      };

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? avatarUrl,
    String? role,
    String? bio,
    String? campus,
    int? cohortYear,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      campus: campus ?? this.campus,
      cohortYear: cohortYear ?? this.cohortYear,
    );
  }

  /// Display initials (up to 2 chars) for avatar fallback
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get roleLabel {
    switch (role) {
      case 'organiser':
        return 'Organiser';
      case 'club_leader':
        return 'Club Leader';
      default:
        return 'Student';
    }
  }
}

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool saved; // transient success flag for edit form

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? saved,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      saved: saved ?? this.saved,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final SupabaseClient _supabase;
  final String? _userId;

  ProfileNotifier(this._supabase, this._userId)
      : super(const ProfileState()) {
    if (_userId != null) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', _userId)
          .single();
      state = state.copyWith(
        isLoading: false,
        profile: UserProfile.fromJson(data),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load profile.',
      );
    }
  }

  Future<void> updateRole(String role) async {
    if (_userId == null) return;
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _supabase
          .from('profiles')
          .update({'role': role, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', _userId);
      state = state.copyWith(
        isSaving: false,
        profile: state.profile?.copyWith(role: role),
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not update role.',
      );
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? campus,
    int? cohortYear,
  }) async {
    if (_userId == null) return;
    state = state.copyWith(isSaving: true, errorMessage: null, saved: false);
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        if (fullName != null) 'full_name': fullName.trim(),
        if (username != null) 'username': username.trim().toLowerCase(),
        if (bio != null) 'bio': bio.trim(),
        if (campus != null) 'campus': campus.trim(),
        if (cohortYear != null) 'cohort_year': cohortYear,
      };
      await _supabase.from('profiles').update(updates).eq('id', _userId);
      state = state.copyWith(
        isSaving: false,
        saved: true,
        profile: state.profile?.copyWith(
          fullName: fullName ?? state.profile?.fullName,
          username: username ?? state.profile?.username,
          bio: bio ?? state.profile?.bio,
          campus: campus ?? state.profile?.campus,
          cohortYear: cohortYear ?? state.profile?.cohortYear,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not save changes.',
      );
    }
  }

  void clearSaved() {
    state = state.copyWith(saved: false);
  }
}

class MyRsvpStats {
  final int rsvpCount;
  final int ideasBackedCount;
  final int communitiesCount;

  const MyRsvpStats({
    this.rsvpCount = 0,
    this.ideasBackedCount = 0,
    this.communitiesCount = 0,
  });
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authState = ref.watch(authNotifierProvider);
  return ProfileNotifier(client, authState.user?.id);
});

/// Current user's profile — null when not loaded
final currentProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(profileNotifierProvider).profile;
});

/// Async provider: fetch stats (RSVPs, backed ideas) for profile screen
final profileStatsProvider = FutureProvider.autoDispose<MyRsvpStats>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final auth = ref.watch(authNotifierProvider);
  final uid = auth.user?.id;
  if (uid == null) return const MyRsvpStats();

  final rsvpRes = await client
      .from('rsvps')
      .select('id')
      .eq('user_id', uid);

  final backedRes = await client
      .from('idea_backers')
      .select('id')
      .eq('user_id', uid);

  return MyRsvpStats(
    rsvpCount: (rsvpRes as List).length,
    ideasBackedCount: (backedRes as List).length,
    communitiesCount: 0, // populated when Member 4 adds chat rooms
  );
});

/// The currently signed-in user's RSVPed posts
final myRsvpPostsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final uid = ref.watch(authNotifierProvider).user?.id;
  if (uid == null) return [];

  final data = await client
      .from('rsvps')
      .select('post_id, posts(id, title, event_date, location, type)')
      .eq('user_id', uid)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data as List);
});

/// The currently signed-in user's posted ideas
final myIdeasProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final uid = ref.watch(authNotifierProvider).user?.id;
  if (uid == null) return [];

  final data = await client
      .from('ideas')
      .select()
      .eq('founder_id', uid)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data as List);
});

/// Ideas the user has backed
final myBackedIdeasProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final uid = ref.watch(authNotifierProvider).user?.id;
  if (uid == null) return [];

  final data = await client
      .from('idea_backers')
      .select('idea_id, ideas(id, title, domain, backer_count)')
      .eq('user_id', uid)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data as List);
});
