//screens/event_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'home_feed_screen.dart'
    show RsvpConfirmDialog, categoryColors, kBg, kCard, kAccentRed, kAccentBlue, kTextPrimary, kTextSecondary, kBorder;

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final bool isRsvped;
  final VoidCallback onRsvp;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.isRsvped,
    required this.onRsvp,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late bool _isRsvped;

  @override
  void initState() {
    super.initState();
    _isRsvped = widget.isRsvped;
  }

  void _handleRsvp() {
    showDialog(
      context: context,
      builder: (_) => RsvpConfirmDialog(
        event: widget.event,
        isRsvped: _isRsvped,
        onConfirm: () {
          setState(() => _isRsvped = !_isRsvped);
          widget.onRsvp();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isRsvped
                    ? 'You\'re registered for ${widget.event.title}!'
                    : 'RSVP cancelled',
              ),
              backgroundColor: _isRsvped ? kAccentBlue : kTextSecondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final color =
        categoryColors[event.category] ?? const Color(0xFF1D6FA4);
    final pct = event.capacityPercent.clamp(0.0, 1.0);
    final barColor = pct >= 0.9
        ? kAccentRed
        : pct >= 0.6
            ? const Color(0xFFE9C46A)
            : kAccentBlue;

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: kCard,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () {},
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.9),
                      color.withOpacity(0.5),
                      kBg,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroBadge(label: event.category, color: color),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body content ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta row
                  _MetaRow(event: event),
                  const SizedBox(height: 20),

                  // Capacity
                  _SectionLabel(label: 'Capacity'),
                  const SizedBox(height: 8),
                  _DetailCapacityBar(
                      event: event, barColor: barColor, pct: pct),
                  const SizedBox(height: 20),

                  // Attendees
                  _SectionLabel(label: 'Attendees'),
                  const SizedBox(height: 10),
                  _DetailAttendeeRow(initials: event.attendeeAvatars),
                  const SizedBox(height: 20),

                  // About
                  _SectionLabel(label: 'About this event'),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Organizer
                  _OrganizerCard(organizer: event.organizer),
                  const SizedBox(height: 32),

                  // RSVP button
                  _DetailRsvpButton(
                    isRsvped: _isRsvped,
                    isFull: event.isFull && !_isRsvped,
                    onTap: _handleRsvp,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero badge ───────────────────────────────────────────────────────────────
class _HeroBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _HeroBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Meta row (date, time, location) ─────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final Event event;
  const _MetaRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          _MetaItem(
              icon: Icons.calendar_today_outlined, text: event.date),
          _MetaDivider(),
          _MetaItem(
              icon: Icons.access_time_outlined, text: event.time),
          _MetaDivider(),
          Expanded(
            child: _MetaItem(
                icon: Icons.location_on_outlined, text: event.location),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: kAccentBlue, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: kTextPrimary, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: kBorder,
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: kTextPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Capacity bar (detail version) ───────────────────────────────────────────
class _DetailCapacityBar extends StatelessWidget {
  final Event event;
  final Color barColor;
  final double pct;
  const _DetailCapacityBar(
      {required this.event,
      required this.barColor,
      required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${event.attendees} registered',
              style:
                  const TextStyle(color: kTextSecondary, fontSize: 13)),
            Text(
              '${event.capacity - event.attendees} spots remaining',
              style: TextStyle(color: barColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─── Attendee row (detail version) ───────────────────────────────────────────
class _DetailAttendeeRow extends StatelessWidget {
  final List<String> initials;
  const _DetailAttendeeRow({required this.initials});

  static const List<Color> _colors = [
    Color(0xFF6A3DE8),
    Color(0xFF1D6FA4),
    Color(0xFF2A9D8F),
    Color(0xFFE76F51),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...initials.take(5).toList().asMap().entries.map((e) {
          return Transform.translate(
            offset: Offset(e.key * -6.0, 0),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colors[e.key % _colors.length],
                border: Border.all(color: kBg, width: 2),
              ),
              child: Center(
                child: Text(
                  e.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${initials.length} people attending',
          style:
              const TextStyle(color: kTextSecondary, fontSize: 13)),
      ],
    );
  }
}

// ─── Organizer card ───────────────────────────────────────────────────────────
class _OrganizerCard extends StatelessWidget {
  final String organizer;
  const _OrganizerCard({required this.organizer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kAccentBlue.withOpacity(0.2),
            ),
            child: const Icon(Icons.groups_outlined,
                color: kAccentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organized by',
                style:
                    TextStyle(color: kTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                organizer,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── RSVP button (detail page) ────────────────────────────────────────────────
class _DetailRsvpButton extends StatelessWidget {
  final bool isRsvped;
  final bool isFull;
  final VoidCallback onTap;

  const _DetailRsvpButton(
      {required this.isRsvped,
      required this.isFull,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFull ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRsvped
              ? kCard
              : isFull
                  ? kBorder
                  : kAccentBlue,
          side: isRsvped
              ? const BorderSide(color: kAccentBlue, width: 1.5)
              : BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          isFull
              ? 'Event is Full'
              : isRsvped
                  ? 'Cancel RSVP'
                  : 'RSVP for this Event',
          style: TextStyle(
            color: isRsvped ? kAccentBlue : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
