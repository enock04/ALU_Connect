import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/idea_model.dart';
import '../providers/launchpad_provider.dart';

class IdeaCard extends ConsumerWidget {
  final IdeaModel idea;
  final VoidCallback onTap;
  final void Function(String? chatRoomId)? onChatOpened;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.onTap,
    this.onChatOpened,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ALUColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ALUColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DomainChip(domain: idea.domain),
                const Spacer(),
                if (idea.isUnlocked)
                  const Icon(Icons.lock_open_rounded, size: 14, color: ALUColors.gold),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              idea.title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: ALUColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              idea.problemStatement,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: ALUColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: idea.skillsNeeded.map((s) => SkillChip(skill: s)).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: ALUColors.navyLight,
                  child: Text(
                    idea.founderName.isNotEmpty ? idea.founderName[0] : '?',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    idea.founderName,
                    style: const TextStyle(fontSize: 12, color: ALUColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                BackerButton(idea: idea, onChatOpened: onChatOpened),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class DomainChip extends StatelessWidget {
  final IdeaDomain domain;

  const DomainChip({super.key, required this.domain});

  static const _labels = {
    IdeaDomain.agriTech: 'AgriTech',
    IdeaDomain.healthTech: 'HealthTech',
    IdeaDomain.edTech: 'EdTech',
    IdeaDomain.finTech: 'FinTech',
    IdeaDomain.cleanTech: 'CleanTech',
    IdeaDomain.logistics: 'Logistics',
    IdeaDomain.other: 'Other',
  };

  static const _colors = {
    IdeaDomain.agriTech: Color(0xFF1A6B3C),
    IdeaDomain.healthTech: Color(0xFF0E5E8A),
    IdeaDomain.edTech: Color(0xFF4A2A8A),
    IdeaDomain.finTech: ALUColors.goldDim,
    IdeaDomain.cleanTech: Color(0xFF1A5C3A),
    IdeaDomain.logistics: Color(0xFF5C3A1A),
    IdeaDomain.other: ALUColors.navyDim,
  };

  static const _textColors = {
    IdeaDomain.agriTech: Color(0xFF6EE7A8),
    IdeaDomain.healthTech: Color(0xFF7DD3FC),
    IdeaDomain.edTech: Color(0xFFD8B4FE),
    IdeaDomain.finTech: ALUColors.gold,
    IdeaDomain.cleanTech: Color(0xFF6EE7B7),
    IdeaDomain.logistics: Color(0xFFFBBF77),
    IdeaDomain.other: ALUColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final bg = _colors[domain] ?? ALUColors.navyDim;
    final fg = _textColors[domain] ?? ALUColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labels[domain] ?? 'Other',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final SkillTag skill;

  const SkillChip({super.key, required this.skill});

  static const _labels = {
    SkillTag.developer: 'Developer',
    SkillTag.designer: 'Designer',
    SkillTag.marketer: 'Marketer',
    SkillTag.finance: 'Finance',
    SkillTag.legal: 'Legal',
    SkillTag.operations: 'Operations',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ALUColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ALUColors.border),
      ),
      child: Text(
        _labels[skill] ?? skill.name,
        style: const TextStyle(fontSize: 11, color: ALUColors.textSecondary),
      ),
    );
  }
}

class BackerButton extends ConsumerStatefulWidget {
  final IdeaModel idea;
  final void Function(String? chatRoomId)? onChatOpened;

  const BackerButton({super.key, required this.idea, this.onChatOpened});

  @override
  ConsumerState<BackerButton> createState() => _BackerButtonState();
}

class _BackerButtonState extends ConsumerState<BackerButton> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);

    final notifier = ref.read(launchpadProvider.notifier);
    String? chatRoomId;

    if (widget.idea.isBackedByMe) {
      await notifier.unbackIdea(widget.idea.id);
    } else {
      chatRoomId = await notifier.backIdea(widget.idea.id);
      if (chatRoomId != null && widget.onChatOpened != null) {
        widget.onChatOpened!(chatRoomId);
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final backed = widget.idea.isBackedByMe;
    final count = widget.idea.backerCount;
    const threshold = IdeaModel.backerThreshold;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backed ? ALUColors.red.withValues(alpha: 0.15) : ALUColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: backed ? ALUColors.red : ALUColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: ALUColors.red),
              )
            else
              Icon(
                backed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 14,
                color: backed ? ALUColors.red : ALUColors.textMuted,
              ),
            const SizedBox(width: 5),
            Text(
              '$count / $threshold',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: backed ? ALUColors.red : ALUColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
