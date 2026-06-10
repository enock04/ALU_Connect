//screens/home_feed_screen.dart

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

// ─── Theme constants (import from theme.dart in your project) ─────────────────
const Color kBg = Color(0xFF0D1B2A);
const Color kCard = Color(0xFF152032);
const Color kAccentRed = Color(0xFFE63946);
const Color kAccentBlue = Color(0xFF1D6FA4);
const Color kTextPrimary = Color(0xFFEEF2FF);
const Color kTextSecondary = Color(0xFF8A9BB0);
const Color kBorder = Color(0xFF1E3148);

const Map<String, Color> categoryColors = {
  'Hackathon': Color(0xFF6A3DE8),
  'Internship': Color(0xFF1D6FA4),
  'Workshop': Color(0xFF2A9D8F),
  'Event': Color(0xFFE9C46A),
  'Leadership': Color(0xFFE76F51),
  'Community': Color(0xFF457B9D),
  'All': Color(0xFF8A9BB0),
};

// ─── Home Feed Screen ─────────────────────────────────────────────────────────
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = false;
  // Track RSVPed event IDs
  final Set<String> _rsvpedIds = {};

  List<Event> get _featured =>
      mockEvents.where((e) => e.isFeatured).toList();

  List<Event> get _filtered => _selectedCategory == 'All'
      ? mockEvents
      : mockEvents
          .where((e) => e.category == _selectedCategory)
          .toList();

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  void _onRsvp(String eventId) {
    setState(() {
      if (_rsvpedIds.contains(eventId)) {
        _rsvpedIds.remove(eventId);
      } else {
        _rsvpedIds.add(eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: kAccentBlue,
          backgroundColor: kCard,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _TopBar()),
              SliverToBoxAdapter(child: const SizedBox(height: 16)),
              // Featured carousel
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: const [
                          Text(
                            'Featured',
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FeaturedCarousel(events: _featured),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 20)),
              // Category filter
              SliverToBoxAdapter(
                child: _CategoryFilter(
                  selected: _selectedCategory,
                  onSelect: (cat) =>
                      setState(() => _selectedCategory = cat),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 14)),
              // Event list
              _isLoading
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => const _SkeletonCard(),
                        childCount: 4,
                      ),
                    )
                  : _filtered.isEmpty
                      ? SliverToBoxAdapter(child: _EmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final event = _filtered[index];
                              return EventCard(
                                event: event,
                                isRsvped: _rsvpedIds.contains(event.id),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                      event: event,
                                      isRsvped:
                                          _rsvpedIds.contains(event.id),
                                      onRsvp: () => _onRsvp(event.id),
                                    ),
                                  ),
                                ),
                                onRsvp: () => _showRsvpDialog(
                                    context, event),
                              );
                            },
                            childCount: _filtered.length,
                          ),
                        ),
              SliverToBoxAdapter(child: const SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: kAccentRed,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }

  void _showRsvpDialog(BuildContext context, Event event) {
    final alreadyRsvped = _rsvpedIds.contains(event.id);
    showDialog(
      context: context,
      builder: (_) => RsvpConfirmDialog(
        event: event,
        isRsvped: alreadyRsvped,
        onConfirm: () {
          _onRsvp(event.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                alreadyRsvped
                    ? 'RSVP cancelled for ${event.title}'
                    : 'You\'re registered for ${event.title}!',
              ),
              backgroundColor: alreadyRsvped ? kTextSecondary : kAccentBlue,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good morning 👋',
                style: TextStyle(color: kTextSecondary, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Discover Opportunities',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search,
                color: kTextSecondary, size: 24),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: kTextSecondary, size: 24),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Featured horizontal carousel ─────────────────────────────────────────────
class _FeaturedCarousel extends StatelessWidget {
  final List<Event> events;
  const _FeaturedCarousel({required this.events});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final color =
              categoryColors[event.category] ?? const Color(0xFF1D6FA4);
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.85),
                  color.withOpacity(0.4),
                ],
              ),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryBadge(
                          label: event.category, color: color),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white70, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        event.date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (event.isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kAccentRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Full',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Text(
                          '${event.capacity - event.attendees} spots left',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Category filter chips ────────────────────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryFilter(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: eventCategories.length,
        itemBuilder: (_, index) {
          final cat = eventCategories[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kAccentBlue : kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? kAccentBlue : kBorder,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : kTextSecondary,
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Event card widget ────────────────────────────────────────────────────────
class EventCard extends StatelessWidget {
  final Event event;
  final bool isRsvped;
  final VoidCallback onTap;
  final VoidCallback onRsvp;

  const EventCard({
    super.key,
    required this.event,
    required this.isRsvped,
    required this.onTap,
    required this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        categoryColors[event.category] ?? const Color(0xFF1D6FA4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category + location
              Row(
                children: [
                  _CategoryBadge(label: event.category, color: color),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on_outlined,
                      color: kTextSecondary, size: 13),
                  const SizedBox(width: 2),
                  Text(
                    event.location,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (event.isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kAccentRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: kAccentRed.withOpacity(0.4)),
                      ),
                      child: const Text(
                        'Full',
                        style:
                            TextStyle(color: kAccentRed, fontSize: 11),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                event.title,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Date + time
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: kTextSecondary, size: 13),
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
              const SizedBox(height: 10),
              // Capacity bar
              _CapacityBar(event: event),
              const SizedBox(height: 10),
              // Attendee avatars + RSVP button
              Row(
                children: [
                  _AttendeeAvatars(initials: event.attendeeAvatars),
                  const Spacer(),
                  _RsvpButton(
                    isRsvped: isRsvped,
                    isFull: event.isFull && !isRsvped,
                    onTap: onRsvp,
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

// ─── Capacity progress bar ────────────────────────────────────────────────────
class _CapacityBar extends StatelessWidget {
  final Event event;
  const _CapacityBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final pct = event.capacityPercent.clamp(0.0, 1.0);
    final barColor = pct >= 0.9
        ? kAccentRed
        : pct >= 0.6
            ? const Color(0xFFE9C46A)
            : kAccentBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${event.attendees}/${event.capacity} attending',
              style:
                  const TextStyle(color: kTextSecondary, fontSize: 11),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: TextStyle(color: barColor, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ─── Attendee avatars row ─────────────────────────────────────────────────────
class _AttendeeAvatars extends StatelessWidget {
  final List<String> initials;
  const _AttendeeAvatars({required this.initials});

  static const List<Color> _colors = [
    Color(0xFF6A3DE8),
    Color(0xFF1D6FA4),
    Color(0xFF2A9D8F),
    Color(0xFFE76F51),
  ];

  @override
  Widget build(BuildContext context) {
    final show = initials.take(3).toList();
    return Row(
      children: [
        SizedBox(
          width: show.length * 20.0 + 8,
          height: 26,
          child: Stack(
            children: List.generate(show.length, (i) {
              return Positioned(
                left: i * 20.0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colors[i % _colors.length],
                    border: Border.all(color: kCard, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      show[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '+${initials.length} attending',
          style: const TextStyle(color: kTextSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

// ─── RSVP button ──────────────────────────────────────────────────────────────
class _RsvpButton extends StatelessWidget {
  final bool isRsvped;
  final bool isFull;
  final VoidCallback onTap;

  const _RsvpButton(
      {required this.isRsvped,
      required this.isFull,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isFull) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kBorder,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Full',
          style: TextStyle(color: kTextSecondary, fontSize: 13),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isRsvped ? kCard : kAccentBlue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRsvped ? kAccentBlue : Colors.transparent,
          ),
        ),
        child: Text(
          isRsvped ? 'Cancel RSVP' : 'RSVP',
          style: TextStyle(
            color: isRsvped ? kAccentBlue : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── RSVP confirm dialog ──────────────────────────────────────────────────────
class RsvpConfirmDialog extends StatelessWidget {
  final Event event;
  final bool isRsvped;
  final VoidCallback onConfirm;

  const RsvpConfirmDialog({
    super.key,
    required this.event,
    required this.isRsvped,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kCard,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRsvped ? 'Cancel RSVP?' : 'Confirm RSVP',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRsvped
                  ? 'Remove your registration for "${event.title}"?'
                  : 'Register for "${event.title}" on ${event.date}?',
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: kTextSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isRsvped ? kAccentRed : kAccentBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isRsvped ? 'Remove' : 'Confirm',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category badge ───────────────────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Skeleton loader card ─────────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(width: 80, height: 20, opacity: _anim.value),
            const SizedBox(height: 10),
            _SkeletonBox(
                width: double.infinity, height: 16, opacity: _anim.value),
            const SizedBox(height: 6),
            _SkeletonBox(width: 200, height: 14, opacity: _anim.value),
            const SizedBox(height: 12),
            _SkeletonBox(
                width: double.infinity, height: 5, opacity: _anim.value),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const _SkeletonBox(
      {required this.width,
      required this.height,
      required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kBorder.withOpacity(opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined,
                size: 52, color: kTextSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text(
              'No events in this category',
              style: TextStyle(color: kTextSecondary, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different filter',
              style: TextStyle(color: kTextSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom nav (shared — move to widgets/bottom_nav.dart) ───────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        border: Border(top: BorderSide(color: kBorder, width: 1)),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  selected: currentIndex == 0),
              _NavItem(
                  icon: Icons.explore_outlined,
                  label: 'Explore',
                  selected: currentIndex == 1),
              const SizedBox(width: 48),
              _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                  selected: currentIndex == 2),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  selected: currentIndex == 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _NavItem(
      {required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: selected ? kAccentBlue : kTextSecondary, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? kAccentBlue : kTextSecondary,
              fontSize: 11,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
