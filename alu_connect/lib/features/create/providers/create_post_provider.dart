import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/post_model.dart';
import '../../auth/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class CreatePostState {
  final PostType type;
  final PostSubtype? subtype;
  final String title;
  final String body;
  final DateTime? eventDate;
  final String? location;
  final int? capacity;
  final DateTime? deadline;
  final String? compensationInfo;
  final bool submitting;
  final bool submitted;
  final String? error;

  const CreatePostState({
    this.type = PostType.schoolEvent,
    this.subtype,
    this.title = '',
    this.body = '',
    this.eventDate,
    this.location,
    this.capacity,
    this.deadline,
    this.compensationInfo,
    this.submitting = false,
    this.submitted = false,
    this.error,
  });

  /// True when the minimum required fields are filled and no submit is in flight.
  bool get canSubmit =>
      title.trim().isNotEmpty && body.trim().isNotEmpty && !submitting;

  CreatePostState copyWith({
    PostType? type,
    PostSubtype? subtype,
    bool clearSubtype = false,
    String? title,
    String? body,
    DateTime? eventDate,
    bool clearEventDate = false,
    String? location,
    bool clearLocation = false,
    int? capacity,
    bool clearCapacity = false,
    DateTime? deadline,
    bool clearDeadline = false,
    String? compensationInfo,
    bool clearCompensation = false,
    bool? submitting,
    bool? submitted,
    String? error,
    bool clearError = false,
  }) =>
      CreatePostState(
        type: type ?? this.type,
        subtype: clearSubtype ? null : (subtype ?? this.subtype),
        title: title ?? this.title,
        body: body ?? this.body,
        eventDate: clearEventDate ? null : (eventDate ?? this.eventDate),
        location: clearLocation ? null : (location ?? this.location),
        capacity: clearCapacity ? null : (capacity ?? this.capacity),
        deadline: clearDeadline ? null : (deadline ?? this.deadline),
        compensationInfo: clearCompensation
            ? null
            : (compensationInfo ?? this.compensationInfo),
        submitting: submitting ?? this.submitting,
        submitted: submitted ?? this.submitted,
        error: clearError ? null : (error ?? this.error),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class CreatePostNotifier extends StateNotifier<CreatePostState> {
  final SupabaseClient _db;

  CreatePostNotifier(this._db) : super(const CreatePostState());

  // field setters ─────────────────────────────────────────────────────────────

  void setType(PostType type) =>
      state = state.copyWith(type: type, clearSubtype: true);

  void setSubtype(PostSubtype? subtype) => state = state.copyWith(
        subtype: subtype,
        clearSubtype: subtype == null,
      );

  void setTitle(String v) => state = state.copyWith(title: v, clearError: true);
  void setBody(String v) => state = state.copyWith(body: v, clearError: true);

  void setEventDate(DateTime? v) =>
      state = state.copyWith(eventDate: v, clearEventDate: v == null);

  void setLocation(String v) => state = state.copyWith(location: v);

  void setCapacity(int? v) =>
      state = state.copyWith(capacity: v, clearCapacity: v == null);

  void setDeadline(DateTime? v) =>
      state = state.copyWith(deadline: v, clearDeadline: v == null);

  void setCompensation(String v) => state = state.copyWith(compensationInfo: v);

  // submit ────────────────────────────────────────────────────────────────────

  Future<void> submit(UserProfile profile) async {
    if (!state.canSubmit) return;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await _db.from(SupabaseTables.posts).insert({
        'author_id': profile.id,
        'author_name': profile.fullName,
        'author_avatar': profile.avatarUrl,
        'author_role': profile.role,
        'type': state.type.name,
        if (state.subtype != null) 'subtype': state.subtype!.name,
        'title': state.title.trim(),
        'body': state.body.trim(),
        if (state.eventDate != null)
          'event_date': state.eventDate!.toIso8601String(),
        if (state.location != null && state.location!.trim().isNotEmpty)
          'location': state.location!.trim(),
        if (state.capacity != null) 'capacity': state.capacity,
        if (state.deadline != null)
          'deadline': state.deadline!.toIso8601String(),
        if (state.compensationInfo != null &&
            state.compensationInfo!.trim().isNotEmpty)
          'compensation_info': state.compensationInfo!.trim(),
      });
      state = state.copyWith(submitting: false, submitted: true);
    } catch (_) {
      state = state.copyWith(
        submitting: false,
        error: 'Could not publish post. Please try again.',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// autoDispose so the form resets cleanly whenever the screen is left.
final createPostProvider =
    StateNotifierProvider.autoDispose<CreatePostNotifier, CreatePostState>(
  (ref) => CreatePostNotifier(Supabase.instance.client),
);
