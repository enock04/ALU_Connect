import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/no_internet_banner.dart';
import '../providers/communities_provider.dart';
import '../widgets/community_card.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(communitiesProvider.notifier).fetchCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communitiesProvider);

    ref.listen<CommunitiesState>(communitiesProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: ALUColors.redDim),
        );
      }
    });

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: Column(
        children: [
          const NoInternetBanner(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: ALUColors.background,
                  title: const Text(
                    'Community',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: ALUColors.textPrimary,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Divider(height: 1, color: ALUColors.border),
                  ),
                ),
                if (state.loading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _SkeletonCard().animate(delay: (i * 60).ms).fadeIn(),
                      childCount: 5,
                    ),
                  )
                else ...[
                  // team chats section (if any)
                  if (state.myTeamChats.isNotEmpty) ...[
                    const _SectionHeader(title: 'My Team Chats', icon: Icons.rocket_launch_rounded, color: ALUColors.gold),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final room = state.myTeamChats[i];
                          return TeamChatCard(
                            room: room,
                            onTap: () => context.push(AppRoutes.chatRoomPath(room.id)),
                          ).animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.04, end: 0);
                        },
                        childCount: state.myTeamChats.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ],

                  // communities section
                  const _SectionHeader(title: 'Communities', icon: Icons.people_rounded, color: ALUColors.navyLight),

                  if (state.communities.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline, size: 56, color: ALUColors.border),
                            const SizedBox(height: 16),
                            const Text(
                              'No communities yet',
                              style: TextStyle(color: ALUColors.textMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref.read(communitiesProvider.notifier).fetchCommunities(),
                              child: const Text('Retry', style: TextStyle(color: ALUColors.navyLight)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final room = state.communities[i];
                          return CommunityCard(
                            room: room,
                            joining: state.joining,
                            onTap: () {
                              ref.read(communitiesProvider.notifier).markRead(room.id);
                              context.push(AppRoutes.chatRoomPath(room.id));
                            },
                            onJoinLeave: () {
                              if (room.isJoined) {
                                ref.read(communitiesProvider.notifier).leaveCommunity(room.id);
                              } else {
                                ref.read(communitiesProvider.notifier).joinCommunity(room.id);
                              }
                            },
                          ).animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.04, end: 0);
                        },
                        childCount: state.communities.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      height: 74,
      decoration: BoxDecoration(
        color: ALUColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ALUColors.border),
      ),
    );
  }
}
