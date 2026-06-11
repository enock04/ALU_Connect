// lib/features/feed/screens/event_detail_screen.dart
// Full event detail view — body text, date/time, location, capacity, RSVP.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/event_model.dart';
import '../providers/feed_provider.dart';
import '../widgets/event_card.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref
        .watch(feedProvider)
        .events
        .where((e) => e.id == eventId)
        .firstOrNull;

    if (event == null) {
      return Scaffold(
        backgroundColor: ALUColors.background,
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Event not found',
            style: TextStyle(color: ALUColors.textSecondary),
          ),
        ),
      );
    }

    return _DetailView(event: event);
  }
}

class _DetailView extends ConsumerWidget {
  final EventModel event;
  const _DetailView({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = categoryColor(event.category);
    final dateStr =
        DateFormat('EEEE, MMMM d, yyyy').format(event.eventDate);
    final timeStr = DateFormat('h:mm a').format(event.eventDate);

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: ALUColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.55),
                      ALUColors.surface,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.event,
                      size: 64,
                      color: color.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.category.name.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: ALUColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.organiserName,
                    style: const TextStyle(
                        color: ALUColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: ALUColors.border),
                  const SizedBox(height: 16),
                  _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: '$dateStr  ·  $timeStr'),
                  const SizedBox(height: 10),
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: event.location),
                  const SizedBox(height: 10),
                  if (event.capacity != null)
                    _InfoRow(
                      icon: Icons.people_outline,
                      text: event.isFull
                          ? '${event.rsvpCount} going · Full'
                          : '${event.rsvpCount} going · ${event.spotsLeft} spots left',
                      color: event.isFull ? ALUColors.red : null,
                    )
                  else
                    _InfoRow(
                      icon: Icons.people_outline,
                      text: '${event.rsvpCount} going',
                    ),
                  const SizedBox(height: 20),
                  const Divider(color: ALUColors.border),
                  const SizedBox(height: 16),
                  const Text(
                    'About this event',
                    style: TextStyle(
                      color: ALUColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.body,
                    style: const TextStyle(
                      color: ALUColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _RsvpBar(event: event),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? ALUColors.textMuted, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: color ?? ALUColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _RsvpBar extends ConsumerWidget {
  final EventModel event;
  const _RsvpBar({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRsvped = event.isUserRsvped;
    final isFull = event.isFull && !isRsvped;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: ALUColors.surface,
        border: Border(top: BorderSide(color: ALUColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isFull
              ? null
              : () =>
                  ref.read(feedProvider.notifier).toggleRsvp(event.id),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isRsvped ? ALUColors.card : ALUColors.red,
            foregroundColor:
                isRsvped ? ALUColors.red : Colors.white,
            side: isRsvped
                ? const BorderSide(color: ALUColors.red)
                : null,
            disabledBackgroundColor: ALUColors.card,
          ),
          child: Text(
            isRsvped
                ? 'Cancel RSVP'
                : (isFull ? 'Event Full' : 'RSVP to this Event'),
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
