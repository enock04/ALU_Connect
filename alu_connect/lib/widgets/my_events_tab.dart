// lib/widgets/my_events_tab.dart
// This widget is used inside the Profile screen as the "My RSVPs / My Events" tab.

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import '../screens/home_feed_screen.dart'
    show categoryColors, kBg, kCard, kAccentBlue, kAccentRed, kTextPrimary, kTextSecondary, kBorder;

class MyEventsTab extends StatelessWidget {
  // Pass in the set of RSVP'd event IDs from your state management
  final Set<String> rsvpedIds;
  final Function(String) onCancelRsvp;

  const MyEventsTab({
    super.key,
    required this.rsvpedIds,
    required this.onCancelRsvp,
  });

  List<Event> get _myEvents =>
      mockEvents.where((e) => rsvpedIds.contains(e.id)).toList();

  @override
  Widget build(BuildContext context) {
    if (_myEvents.isEmpty) {
      return _EmptyMyEvents();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _myEvents.length,
      itemBuilder: (context, index) {
        final event = _myEvents[index];
        return _MyEventCard(
          event: event,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                event: event,
                isRsvped: true,
                onRsvp: () => onCancelRsvp(event.id),
              ),
            ),
          ),
          onCancel: () => onCancelRsvp(event.id),
        );
      },
    );
  }
}

// ─── My Event card ────────────────────────────────────────────────────────────
class _MyEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _MyEventCard({
    required this.event,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        categoryColors[event.category] ?? const Color(0xFF1D6FA4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: kTextSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date}  ·  ${event.time}',
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: kTextSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          event.location,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // RSVP'd badge + cancel
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kAccentBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: kAccentBlue.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'RSVP\'d',
                      style: TextStyle(
                        color: kAccentBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: kAccentRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyMyEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_outlined,
              size: 52, color: kTextSecondary.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text(
            'No events yet',
            style: TextStyle(color: kTextSecondary, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'RSVP to events from the Home feed',
            style: TextStyle(color: kTextSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
