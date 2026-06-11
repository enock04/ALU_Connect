import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/app_router.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/no_internet_banner.dart';
import '../providers/launchpad_provider.dart';
import '../widgets/idea_card.dart';

class LaunchpadScreen extends ConsumerStatefulWidget {
  const LaunchpadScreen({super.key});

  @override
  ConsumerState<LaunchpadScreen> createState() => _LaunchpadScreenState();
}

class _LaunchpadScreenState extends ConsumerState<LaunchpadScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(launchpadProvider.notifier).fetchIdeas());
  }

  void _openChat(String chatRoomId) {
    context.push(AppRoutes.chatRoomPath(chatRoomId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(launchpadProvider);

    ref.listen<LaunchpadState>(launchpadProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: ALUColors.redDim,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: ALUColors.textPrimary,
              onPressed: () => ref.read(launchpadProvider.notifier).clearError(),
            ),
          ),
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
                  backgroundColor: ALUColors.background,
                  floating: true,
                  snap: true,
                  title: const Text(
                    'Launchpad',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: ALUColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: ALUColors.textPrimary),
                      onPressed: () => context.push(AppRoutes.postIdea),
                      tooltip: 'Post an idea',
                    ),
                  ],
                ),
                if (state.loading)
                  const SliverToBoxAdapter(child: FeedSkeletonList(count: 4))
                else if (state.ideas.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyIdeas(
                      onPost: () => context.push(AppRoutes.postIdea),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => IdeaCard(
                        idea: state.ideas[i],
                        onTap: () => context.push(
                          AppRoutes.ideaDetailPath(state.ideas[i].id),
                        ),
                        onChatOpened: (chatRoomId) {
                          if (chatRoomId != null) _openChat(chatRoomId);
                        },
                      ),
                      childCount: state.ideas.length,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ALUColors.red,
        onPressed: () => context.push(AppRoutes.postIdea),
        icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
        label: const Text(
          'Post Idea',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ).animate().slideY(begin: 1, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}

class _EmptyIdeas extends StatelessWidget {
  final VoidCallback onPost;
  const _EmptyIdeas({required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_outlined, size: 56, color: ALUColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'No ideas yet',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: ALUColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to post a venture idea and find your co-founders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ALUColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPost,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Post your idea'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
