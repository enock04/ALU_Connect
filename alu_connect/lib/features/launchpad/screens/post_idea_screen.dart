import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/idea_model.dart';
import '../../../shared/widgets/alu_button.dart';
import '../providers/launchpad_provider.dart';

class PostIdeaScreen extends ConsumerStatefulWidget {
  const PostIdeaScreen({super.key});

  @override
  ConsumerState<PostIdeaScreen> createState() => _PostIdeaScreenState();
}

class _PostIdeaScreenState extends ConsumerState<PostIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();

  IdeaDomain _selectedDomain = IdeaDomain.other;
  final Set<SkillTag> _selectedSkills = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _problemCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one skill needed.')),
      );
      return;
    }

    await ref.read(launchpadProvider.notifier).postIdea(
          title: _titleCtrl.text,
          problemStatement: _problemCtrl.text,
          domain: _selectedDomain,
          skillsNeeded: _selectedSkills.toList(),
        );

    if (!mounted) return;

    final error = ref.read(launchpadProvider).error;
    if (error == null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(launchpadProvider).submitting;

    return Scaffold(
      backgroundColor: ALUColors.background,
      appBar: AppBar(
        backgroundColor: ALUColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: ALUColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post an Idea',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: ALUColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Idea title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: ALUColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. Campus Ride-Share App',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 5) return 'Title is too short';
                  return null;
                },
              ).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 20),

              _sectionLabel('The Problem'),
              const SizedBox(height: 4),
              const Text(
                'Describe the problem you are solving. Be specific.',
                style: TextStyle(fontSize: 12, color: ALUColors.textMuted),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _problemCtrl,
                style: const TextStyle(color: ALUColors.textPrimary, height: 1.5),
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Students spend too much time on...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Describe the problem';
                  if (v.trim().length < 20) return 'Please be more specific';
                  return null;
                },
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              _sectionLabel('Domain'),
              const SizedBox(height: 10),
              _DomainSelector(
                selected: _selectedDomain,
                onChanged: (d) => setState(() => _selectedDomain = d),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 24),

              _sectionLabel('Skills Needed'),
              const SizedBox(height: 4),
              const Text(
                'What roles are you looking for?',
                style: TextStyle(fontSize: 12, color: ALUColors.textMuted),
              ),
              const SizedBox(height: 10),
              _SkillSelector(
                selected: _selectedSkills,
                onToggle: (skill) => setState(() {
                  if (_selectedSkills.contains(skill)) {
                    _selectedSkills.remove(skill);
                  } else {
                    _selectedSkills.add(skill);
                  }
                }),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),

              ALUButton(
                label: 'Post Idea',
                loading: submitting,
                onPressed: _submit,
                icon: Icons.rocket_launch_rounded,
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: ALUColors.textSecondary,
          letterSpacing: 0.4,
        ),
      );
}

class _DomainSelector extends StatelessWidget {
  final IdeaDomain selected;
  final ValueChanged<IdeaDomain> onChanged;

  const _DomainSelector({required this.selected, required this.onChanged});

  static const _options = IdeaDomain.values;

  static const _labels = {
    IdeaDomain.agriTech: 'AgriTech',
    IdeaDomain.healthTech: 'HealthTech',
    IdeaDomain.edTech: 'EdTech',
    IdeaDomain.finTech: 'FinTech',
    IdeaDomain.cleanTech: 'CleanTech',
    IdeaDomain.logistics: 'Logistics',
    IdeaDomain.other: 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((d) {
        final isSelected = d == selected;
        return GestureDetector(
          onTap: () => onChanged(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? ALUColors.red.withValues(alpha: 0.15) : ALUColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? ALUColors.red : ALUColors.border,
              ),
            ),
            child: Text(
              _labels[d] ?? d.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? ALUColors.red : ALUColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SkillSelector extends StatelessWidget {
  final Set<SkillTag> selected;
  final ValueChanged<SkillTag> onToggle;

  const _SkillSelector({required this.selected, required this.onToggle});

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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SkillTag.values.map((s) {
        final isSelected = selected.contains(s);
        return GestureDetector(
          onTap: () => onToggle(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? ALUColors.navyLight.withValues(alpha: 0.2) : ALUColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? ALUColors.navyLight : ALUColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Icon(Icons.check_rounded, size: 12, color: ALUColors.navyLight),
                if (isSelected) const SizedBox(width: 4),
                Text(
                  _labels[s] ?? s.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ALUColors.navyLight : ALUColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
