import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/event_model.dart';
import '../../auth/providers/profile_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../../feed/widgets/event_card.dart' show categoryColor;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final profileState = ref.watch(profileNotifierProvider);

    if (profileState.isLoading) {
      return const Scaffold(
        backgroundColor: ALUColors.background,
        body: Center(child: CircularProgressIndicator(color: ALUColors.navy)),
      );
    }

    if (profile == null) {
      return const Scaffold(
        backgroundColor: ALUColors.background,
        body: Center(
          child: Text(
            'Profile not found.',
            style: TextStyle(color: ALUColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: ALUColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: ALUColors.textSecondary, size: 22),
                    onPressed: () => context.push(AppRoutes.settings),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _ProfileHero(profile: profile),

                    _ProfileStats(profile: profile),

                    const SizedBox(height: 6),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: ALUColors.red,
                        unselectedLabelColor: ALUColors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        indicatorColor: ALUColors.red,
                        indicatorWeight: 2,
                        dividerColor: ALUColors.border,
                        tabs: const [
                          Tab(text: 'My Events'),
                          Tab(text: 'My Ideas'),
                          Tab(text: 'Backed'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 400, // fixed height for nested scroll
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _MyEventsTab(),
                          _MyIdeasTab(),
                          _BackedIdeasTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.editProfile),
            child: Stack(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: ALUColors.navy,
                    shape: BoxShape.circle,
                    border: Border.all(color: ALUColors.navyLight, width: 2.5),
                  ),
                  child: Center(
                    child: profile.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 62,
                              height: 62,
                            ),
                          )
                        : Text(
                            profile.initials,
                            style: const TextStyle(
                              color: ALUColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ALUColors.navyLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: ALUColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: ALUColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                _RoleBadge(role: profile.role, cohortYear: profile.cohortYear),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.bio!,
                    style: const TextStyle(
                      color: ALUColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final int? cohortYear;
  const _RoleBadge({required this.role, this.cohortYear});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (role) {
      case 'organiser':
        icon = Icons.event_note_outlined;
        break;
      case 'club_leader':
        icon = Icons.groups_outlined;
        break;
      default:
        icon = Icons.school_outlined;
    }

    final label = role == 'club_leader'
        ? 'Club Leader'
        : role == 'organiser'
            ? 'Organiser'
            : 'Student';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: ALUColors.redDim,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: ALUColors.redLight),
          const SizedBox(width: 4),
          Text(
            cohortYear != null ? '$label · $cohortYear' : label,
            style: const TextStyle(
              color: ALUColors.redLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileStats({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (_, _) => const SizedBox(),
      data: (stats) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          decoration: BoxDecoration(
            color: ALUColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ALUColors.border),
          ),
          child: Row(
            children: [
              _StatCell(
                value: stats.rsvpCount.toString(),
                label: "Events RSVP'd",
                color: ALUColors.red,
              ),
              _StatDivider(),
              _StatCell(
                value: stats.ideasBackedCount.toString(),
                label: 'Ideas Backed',
                color: ALUColors.gold,
              ),
              _StatDivider(),
              _StatCell(
                value: stats.communitiesCount.toString(),
                label: 'Communities',
                color: ALUColors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCell(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: ALUColors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: ALUColors.border);
  }
}

class _MyEventsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reads RSVPs from in-memory feed state while the feed is still
    // mock-data. TODO: switch to myRsvpPostsProvider once the feed
    // provider writes RSVP inserts/deletes to the Supabase rsvps table.
    final rsvped = ref
        .watch(feedProvider)
        .events
        .where((e) => e.isUserRsvped)
        .toList();

    if (rsvped.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_outlined,
        message: 'No events yet.\nRSVP to events from the home feed.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: rsvped.length,
      itemBuilder: (ctx, i) => _EventModelRow(event: rsvped[i]),
    );
  }
}

class _EventModelRow extends StatelessWidget {
  final EventModel event;
  const _EventModelRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(event.category);
    final dateStr = DateFormat('MMM d, yyyy  ·  h:mm a').format(event.eventDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ALUColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ALUColors.border),
      ),
      child: Row(
        children: [
          // category colour dot
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.event_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: ALUColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr · ${event.location}',
                  style: const TextStyle(
                    color: ALUColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2816),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "RSVP'd",
              style: TextStyle(
                color: Color(0xFF22A855),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final Map<String, dynamic> post;
  const _EventRow({required this.post});

  @override
  Widget build(BuildContext context) {
    final title = post['title'] as String? ?? '';
    final date = post['event_date'] as String?;
    final location = post['location'] as String?;

    String? formattedDate;
    if (date != null) {
      try {
        final dt = DateTime.parse(date);
        formattedDate =
            '${_monthAbbr(dt.month)} ${dt.day} · ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ALUColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ALUColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ALUColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_outlined,
                color: ALUColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ALUColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (formattedDate != null || location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        ?formattedDate,
                        ?location,
                      ].join(' · '),
                      style: const TextStyle(
                          color: ALUColors.textSecondary, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2816),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Confirmed',
              style: TextStyle(
                color: Color(0xFF22A855),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}

class _MyIdeasTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(myIdeasProvider);

    return ideasAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: ALUColors.navy)),
      error: (_, _) => const Center(
        child: Text('Could not load ideas.',
            style: TextStyle(color: ALUColors.textSecondary)),
      ),
      data: (ideas) {
        if (ideas.isEmpty) {
          return const _EmptyState(
            icon: Icons.lightbulb_outline_rounded,
            message: 'No ideas posted yet.\nShare your first idea on the Launchpad.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: ideas.length,
          itemBuilder: (ctx, i) => _IdeaRow(idea: ideas[i]),
        );
      },
    );
  }
}

class _IdeaRow extends StatelessWidget {
  final Map<String, dynamic> idea;
  const _IdeaRow({required this.idea});

  @override
  Widget build(BuildContext context) {
    final title = idea['title'] as String? ?? '';
    final backers = idea['backer_count'] as int? ?? 0;
    final domain = idea['domain'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ALUColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ALUColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ALUColors.goldDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.tips_and_updates_outlined, color: ALUColors.gold, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ALUColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  domain.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    color: ALUColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  color: ALUColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                '$backers',
                style: const TextStyle(
                  color: ALUColors.textSecondary,
                  fontSize: 12,
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

class _BackedIdeasTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backedAsync = ref.watch(myBackedIdeasProvider);

    return backedAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: ALUColors.navy)),
      error: (_, _) => const Center(
        child: Text('Could not load backed ideas.',
            style: TextStyle(color: ALUColors.textSecondary)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.star_outline_rounded,
            message: 'No ideas backed yet.\nExplore the Launchpad and support a founder.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final idea = items[i]['ideas'] as Map<String, dynamic>? ?? {};
            return _IdeaRow(idea: idea);
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ALUColors.textMuted, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ALUColors.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
