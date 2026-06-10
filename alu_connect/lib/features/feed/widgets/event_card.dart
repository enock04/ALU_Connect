// lib/features/feed/widgets/event_card.dart
// Reusable event card used in the home feed list.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/event_model.dart';
import '../providers/feed_provider.dart';

Color categoryColor(EventCategory category) {
  switch (category) {
    case EventCategory.academic:
      return ALUColors.blue;
    case EventCategory.career:
      return ALUColors.teal;
    case EventCategory.social:
      return ALUColors.gold;
    case EventCategory.venture:
      return ALUColors.red;
    case EventCategory.student:
      return ALUColors.navyLight;
  }
}

class EventCard extends ConsumerWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = categoryColor(event.category);
    final dateStr = DateFormat('EEE, MMM d').format(event.eventDate);
    final timeStr = DateFormat('h:mm a').format(event.eventDate);
    final isFull = event.isFull;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.eventDetailPath(event.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: ALUColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ALUColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.category.name.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.capacity != null)
                        Text(
                          isFull
                              ? 'FULL'
                              : '${event.spotsLeft} spots left',
                          style: TextStyle(
                            color:
                                isFull ? ALUColors.red : ALUColors.textMuted,
                            fontSize: 11,
                            fontWeight:
                                isFull ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: ALUColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.organiserName,
                    style: const TextStyle(
                        color: ALUColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: ALUColors.textMuted, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '$dateStr  ·  $timeStr',
                        style: const TextStyle(
                            color: ALUColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: ALUColors.textMuted, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                              color: ALUColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          color: ALUColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${event.rsvpCount} going',
                        style: const TextStyle(
                            color: ALUColors.textMuted, fontSize: 12),
                      ),
                      const Spacer(),
                      _RsvpButton(event: event),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RsvpButton extends ConsumerWidget {
  final EventModel event;
  const _RsvpButton({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRsvped = event.isUserRsvped;
    final isFull = event.isFull && !isRsvped;

    return GestureDetector(
      onTap: isFull
          ? null
          : () => ref.read(feedProvider.notifier).toggleRsvp(event.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isRsvped ? ALUColors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFull
                ? ALUColors.border
                : (isRsvped ? ALUColors.red : ALUColors.navyLight),
          ),
        ),
        child: Text(
          isRsvped ? "RSVP'd" : (isFull ? 'Full' : 'RSVP'),
          style: TextStyle(
            color: isRsvped
                ? Colors.white
                : (isFull ? ALUColors.textMuted : ALUColors.navyLight),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
