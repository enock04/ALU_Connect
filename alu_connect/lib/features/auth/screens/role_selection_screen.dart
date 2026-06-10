import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../widgets/auth_widgets.dart';

class _RoleOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const _roles = [
  _RoleOption(
    value: 'student',
    label: 'Student',
    description:
        'Discover events, RSVP, join chats, and back Launchpad ideas.',
    icon: Icons.school_outlined,
  ),
  _RoleOption(
    value: 'club_leader',
    label: 'Club Leader',
    description:
        'Post club events and manage member communities.',
    icon: Icons.groups_outlined,
  ),
  _RoleOption(
    value: 'organiser',
    label: 'Event Organiser',
    description:
        'Post and manage official campus events and opportunities.',
    icon: Icons.event_note_outlined,
  ),
];

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState
    extends ConsumerState<RoleSelectionScreen> {
  String _selected = 'student';

  void _confirm() async {
    await ref
        .read(profileNotifierProvider.notifier)
        .updateRole(_selected);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final isSaving = profileState.isSaving;

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const AluBrandMark(),
              const SizedBox(height: 32),

              const Text(
                'Who are you\nat ALU?',
                style: TextStyle(
                  color: ALUColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your role determines what you can post on the platform.',
                style: TextStyle(color: ALUColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),

              ..._roles.map((role) => _RoleCard(
                    role: role,
                    isSelected: _selected == role.value,
                    onTap: () => setState(() => _selected = role.value),
                  )),

              const SizedBox(height: 20),

              AuthPrimaryButton(
                label: 'Start Exploring',
                onPressed: _confirm,
                isLoading: isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _RoleOption role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF001A42)
              : const Color(0xFF001433),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A4FA0)
                : const Color(0xFF1A3A6B),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF002E6D)
                    : const Color(0xFF001A42),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                role.icon,
                color: isSelected
                    ? const Color(0xFF90AACC)
                    : const Color(0xFF4D6A99),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFF0F4FF)
                          : const Color(0xFF90AACC),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    role.description,
                    style: const TextStyle(
                      color: Color(0xFF4D6A99),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? Container(
                      key: const ValueKey('check'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A4FA0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF1A3A6B), width: 1.5),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
