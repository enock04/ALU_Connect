import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/event_model.dart';
import 'event_card.dart' show categoryColor;

class MyEventsTab extends StatelessWidget {
  final Set<String> rsvpedIds;
  final Function(String) onCancelRsvp;

  const MyEventsTab({
    super.key,
    required this.rsvpedIds,
    required this.onCancelRsvp,
  });

  List<EventModel> get _myEvents =>
      mockEvents.where((e) => rsvpedIds.contains(e.id)).toList();

  @override
  Widget build(BuildContext context) {
    if (_myEvents.isEmpty) return const _EmptyMyEvents();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _myEvents.length,
      itemBuilder: (context, index) {
        final event = _myEvents[index];
        return _MyEventCard(
          event: event,
          onTap: () => context.push(AppRoutes.eventDetailPath(event.id)),
          onCancel: () => onCancelRsvp(event.id),
        );
      },
    );
  }
}

class _MyEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _MyEventCard({
    required this.event,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(event.category);
    final dateStr = DateFormat('MMM d, yyyy').format(event.eventDate);
    final timeStr = DateFormat('h:mm a').format(event.eventDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: ALUColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ALUColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: ALUColors.textPrimary,
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
                            color: ALUColors.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '$dateStr  ·  $timeStr',
                          style: const TextStyle(
                            color: ALUColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: ALUColors.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              color: ALUColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ALUColors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ALUColors.blue.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      "RSVP'd",
                      style: TextStyle(
                        color: ALUColors.blue,
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
                        color: ALUColors.red,
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

class _EmptyMyEvents extends StatelessWidget {
  const _EmptyMyEvents();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_outlined,
            size: 52,
            color: ALUColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'No events yet',
            style: TextStyle(color: ALUColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'RSVP to events from the Home feed',
            style: TextStyle(color: ALUColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
