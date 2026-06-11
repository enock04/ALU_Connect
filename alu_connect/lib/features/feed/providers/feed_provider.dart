// lib/features/feed/providers/feed_provider.dart
// Home feed backed by Supabase posts table.
// Falls back to mock data when the table is empty or unreachable.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/event_model.dart';

class FeedState {
  final List<EventModel> events;
  final bool isLoading;
  final String? error;
  final EventCategory? selectedCategory;

  const FeedState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  List<EventModel> get filtered => selectedCategory == null
      ? events
      : events.where((e) => e.category == selectedCategory).toList();

  FeedState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    String? error,
    EventCategory? selectedCategory,
    bool clearCategory = false,
    bool clearError = false,
  }) =>
      FeedState(
        events: events ?? this.events,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        selectedCategory:
            clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      );
}

class FeedNotifier extends StateNotifier<FeedState> {
  final SupabaseClient _db;
  final String? _userId;

  FeedNotifier(this._db, this._userId) : super(const FeedState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Fetch all event-type posts ordered by soonest event first.
      // Left-join rsvps to know if the current user has RSVP'd each one.
      final rows = await _db
          .from(SupabaseTables.posts)
          .select('*, rsvps(user_id)')
          .not('event_date', 'is', null)          // only posts that are events
          .order('event_date', ascending: true);

      final events = (rows as List).map((row) {
        final rsvps = (row['rsvps'] as List?) ?? [];
        final isRsvped = _userId != null &&
            rsvps.any((r) => r['user_id'] == _userId);
        return EventModel.fromJson(
          row as Map<String, dynamic>,
          isRsvped: isRsvped,
        );
      }).toList();

      // Fall back to mock data when DB is empty (before seeding)
      state = state.copyWith(
        isLoading: false,
        events: events.isEmpty ? mockEvents : events,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, events: mockEvents);
    }
  }

  Future<void> refresh() async {
    await _load();
  }

  void selectCategory(EventCategory? cat) {
    state = state.copyWith(
      selectedCategory: cat,
      clearCategory: cat == null,
    );
  }

  Future<void> toggleRsvp(String eventId) async {
    final event = state.events.firstWhere((e) => e.id == eventId,
        orElse: () => throw StateError('Event not found'));

    // Optimistic update first
    final nowRsvped = !event.isUserRsvped;
    final updated = state.events.map((e) {
      if (e.id != eventId) return e;
      return e.copyWith(
        isUserRsvped: nowRsvped,
        rsvpCount: nowRsvped ? e.rsvpCount + 1 : e.rsvpCount - 1,
      );
    }).toList();
    state = state.copyWith(events: updated);

    // Persist to Supabase
    if (_userId == null) return;
    try {
      if (nowRsvped) {
        await _db.from(SupabaseTables.rsvps).insert({
          'post_id': eventId,
          'user_id': _userId,
        });
      } else {
        await _db
            .from(SupabaseTables.rsvps)
            .delete()
            .eq('post_id', eventId)
            .eq('user_id', _userId);
      }
    } catch (_) {
      // Roll back optimistic update on failure
      final rolledBack = state.events.map((e) {
        if (e.id != eventId) return e;
        return e.copyWith(
          isUserRsvped: !nowRsvped,
          rsvpCount: nowRsvped ? e.rsvpCount - 1 : e.rsvpCount + 1,
        );
      }).toList();
      state = state.copyWith(events: rolledBack);
    }
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final db = Supabase.instance.client;
  final userId = db.auth.currentUser?.id;
  return FeedNotifier(db, userId);
});
