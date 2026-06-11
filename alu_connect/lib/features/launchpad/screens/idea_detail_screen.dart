import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/router/app_router.dart';
import '../providers/launchpad_provider.dart';
import '../widgets/idea_card.dart';

class IdeaDetailScreen extends ConsumerWidget {
  final String ideaId;
  const IdeaDetailScreen({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launchpadProvider);
    final idea = state.ideas.where((i) => i.id == ideaId).firstOrNull;

    if (idea == null) {
      return Scaffold(
        backgroundColor: ALUColors.background,
        appBar: AppBar(backgroundColor: ALUColors.background),
        body: const Center(
          child: Text('Idea not found', style: TextStyle(color: ALUColors.textSecondary)),
        ),
      );
    }

    final progress = idea.progress;
    final isUnlocked = idea.isUnlocked;

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ALUColors.background,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ALUColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              idea.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ALUColors.textPrimary,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // domain + unlock badge
                  Row(
                    children: [
                      DomainChip(domain: idea.domain),
                      const SizedBox(width: 8),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ALUColors.goldDim,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_open_rounded, size: 11, color: ALUColors.gold),
                              SizedBox(width: 4),
                              Text('Team chat unlocked', style: TextStyle(fontSize: 11, color: ALUColors.gold, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // founder row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: ALUColors.navyLight,
                        child: Text(
                          idea.founderName.isNotEmpty ? idea.founderName[0] : '?',
                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idea.founderName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ALUColors.textPrimary,
                            ),
                          ),
                          const Text('Founder', style: TextStyle(fontSize: 11, color: ALUColors.textMuted)),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 50.ms),

                  const SizedBox(height: 24),

                  // problem statement
                  const Text(
                    'The Problem',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: ALUColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    idea.problemStatement,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ALUColors.textPrimary,
                      height: 1.65,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 28),

                  // skills needed
                  const Text(
                    'Skills Needed',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: ALUColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: idea.skillsNeeded.map((s) => SkillChip(skill: s)).toList(),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 28),

                  // backer progress
                  const Text(
                    'Backers',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: ALUColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BackerProgress(idea: idea, progress: progress),

                  const SizedBox(height: 28),

                  // back / unback CTA
                  BackerButton(
                    idea: idea,
                    onChatOpened: (chatRoomId) {
                      if (chatRoomId != null) {
                        context.push(AppRoutes.chatRoomPath(chatRoomId));
                      }
                    },
                  ),

                  // team chat button once unlocked
                  if (isUnlocked && idea.teamChatRoomId != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        AppRoutes.chatRoomPath(idea.teamChatRoomId!),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Open team chat'),
                    ),
                  ],

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

class _BackerProgress extends StatelessWidget {
  final dynamic idea;
  final double progress;
  const _BackerProgress({required this.idea, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${idea.backerCount} / ${idea.backerThreshold ?? 3} backers',
              style: const TextStyle(fontSize: 13, color: ALUColors.textSecondary),
            ),
            Text(
              idea.isUnlocked ? 'Chat unlocked 🎉' : '${idea.backersNeeded} more to unlock',
              style: TextStyle(
                fontSize: 12,
                color: idea.isUnlocked ? ALUColors.gold : ALUColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: ALUColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              idea.isUnlocked ? ALUColors.gold : ALUColors.red,
            ),
            minHeight: 6,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}
