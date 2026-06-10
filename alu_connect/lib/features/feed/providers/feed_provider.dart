// lib/features/feed/providers/feed_provider.dart
// Manages the home feed event list and RSVP state.
// TODO(Member 3): swap _load() and refresh() with Supabase queries once backend is live.

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  FeedNotifier() : super(const FeedState()) {
    _load();
  }

  void _load() {
    // TODO(Member 3): replace with Supabase query —
    // SELECT posts.*, (rsvps.id IS NOT NULL) AS is_rsvped
    // FROM posts
    // LEFT JOIN rsvps ON rsvps.post_id = posts.id AND rsvps.user_id = auth.uid()
    // WHERE posts.type = 'event'
    // ORDER BY event_date ASC
    state = state.copyWith(events: mockEvents);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    // TODO(Member 3): replace with real Supabase fetch
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(events: mockEvents, isLoading: false);
  }

  void selectCategory(EventCategory? cat) {
    state = state.copyWith(
      selectedCategory: cat,
      clearCategory: cat == null,
    );
  }

  void toggleRsvp(String eventId) {
    // TODO(Member 3): call Supabase rsvps table — insert on RSVP, delete on cancel
    // INSERT INTO rsvps (user_id, post_id) VALUES (uid, eventId)
    // DELETE FROM rsvps WHERE user_id = uid AND post_id = eventId
    final updated = state.events.map((e) {
      if (e.id != eventId) return e;
      final nowRsvped = !e.isUserRsvped;
      return e.copyWith(
        isUserRsvped: nowRsvped,
        rsvpCount: nowRsvped ? e.rsvpCount + 1 : e.rsvpCount - 1,
      );
    }).toList();
    state = state.copyWith(events: updated);
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});
