import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import '../../../shared/widgets/no_internet_banner.dart';
import '../../auth/providers/profile_provider.dart';
import '../providers/create_post_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Type metadata
// ─────────────────────────────────────────────────────────────────────────────

class _TypeInfo {
  final String label;
  final IconData icon;
  final Color color;
  const _TypeInfo(
      {required this.label, required this.icon, required this.color});
}

const _kTypeInfo = <PostType, _TypeInfo>{
  PostType.schoolEvent: _TypeInfo(
    label: 'School Event',
    icon: Icons.school_rounded,
    color: ALUColors.navyLight,
  ),
  PostType.jobInternship: _TypeInfo(
    label: 'Job / Internship',
    icon: Icons.work_outline_rounded,
    color: ALUColors.teal,
  ),
  PostType.networking: _TypeInfo(
    label: 'Networking',
    icon: Icons.groups_rounded,
    color: ALUColors.gold,
  ),
  PostType.ventureSupport: _TypeInfo(
    label: 'Venture',
    icon: Icons.rocket_launch_rounded,
    color: ALUColors.red,
  ),
  PostType.entertainment: _TypeInfo(
    label: 'Entertainment',
    icon: Icons.celebration_rounded,
    color: Color(0xFF9B59B6),
  ),
  PostType.src: _TypeInfo(
    label: 'SRC',
    icon: Icons.campaign_rounded,
    color: ALUColors.navyLight,
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// Subtype helpers
// ─────────────────────────────────────────────────────────────────────────────

List<PostSubtype> _subtypesFor(PostType type) {
  switch (type) {
    case PostType.schoolEvent:
      return [PostSubtype.hackathon, PostSubtype.workshop, PostSubtype.other];
    case PostType.jobInternship:
      return [PostSubtype.fullTime, PostSubtype.internship, PostSubtype.other];
    case PostType.networking:
      return [PostSubtype.mixer, PostSubtype.debate, PostSubtype.other];
    case PostType.ventureSupport:
      return [PostSubtype.grant, PostSubtype.pitchEvent, PostSubtype.other];
    case PostType.entertainment:
      return [PostSubtype.cultural, PostSubtype.mixer, PostSubtype.other];
    case PostType.src:
      return [];
  }
}

String _subtypeLabel(PostSubtype s) {
  switch (s) {
    case PostSubtype.hackathon:
      return 'Hackathon';
    case PostSubtype.workshop:
      return 'Workshop';
    case PostSubtype.grant:
      return 'Grant';
    case PostSubtype.pitchEvent:
      return 'Pitch Event';
    case PostSubtype.fullTime:
      return 'Full-time';
    case PostSubtype.internship:
      return 'Internship';
    case PostSubtype.mixer:
      return 'Mixer';
    case PostSubtype.debate:
      return 'Debate';
    case PostSubtype.cultural:
      return 'Cultural';
    case PostSubtype.other:
      return 'Other';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conditional field rules
// ─────────────────────────────────────────────────────────────────────────────

bool _hasEventDate(PostType t) => const {
      PostType.schoolEvent,
      PostType.networking,
      PostType.entertainment,
      PostType.src,
    }.contains(t);

bool _hasLocation(PostType t) => const {
      PostType.schoolEvent,
      PostType.networking,
      PostType.entertainment,
    }.contains(t);

bool _hasCapacity(PostType t) => const {
      PostType.schoolEvent,
      PostType.entertainment,
    }.contains(t);

bool _hasDeadline(PostType t) => const {
      PostType.jobInternship,
      PostType.ventureSupport,
    }.contains(t);

bool _hasCompensation(PostType t) => t == PostType.jobInternship;

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _compensationCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    _compensationCtrl.dispose();
    super.dispose();
  }

  // ── date/time picker ───────────────────────────────────────────────────────

  Future<DateTime?> _pickDateTime(DateTime? initial, {bool dateOnly = false}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ALUColors.navyLight,
            onPrimary: Colors.white,
            surface: ALUColors.surface,
            onSurface: ALUColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return null;
    if (dateOnly) {
      return DateTime(date.year, date.month, date.day);
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ALUColors.navyLight,
            onPrimary: Colors.white,
            surface: ALUColors.surface,
            onSurface: ALUColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // ── submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    FocusScope.of(context).unfocus();
    final success =
        await ref.read(createPostProvider.notifier).submit(profile);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published!'),
          duration: Duration(seconds: 2),
        ),
      );
      context.go(AppRoutes.home);
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPostProvider);
    final profile = ref.watch(currentProfileProvider);

    // Show error snackbar if submission fails
    ref.listen<CreatePostState>(createPostProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: ALUColors.redDim,
          ),
        );
      }
    });

    final canPost = state.canSubmit && profile != null;

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: Column(
        children: [
          const NoInternetBanner(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── App bar ─────────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: ALUColors.background,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: ALUColors.textSecondary),
                    tooltip: 'Cancel',
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                  title: const Text(
                    'New Post',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: ALUColors.textPrimary,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: state.submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: ALUColors.navyLight,
                                strokeWidth: 2,
                              ),
                            )
                          : TextButton(
                              onPressed: canPost ? _submit : null,
                              style: TextButton.styleFrom(
                                foregroundColor: ALUColors.navyLight,
                                disabledForegroundColor: ALUColors.textMuted,
                              ),
                              child: const Text(
                                'Post',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Divider(height: 1, color: ALUColors.border),
                  ),
                ),

                // ── Form body ───────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── Author identity ────────────────────────────────────
                      if (profile != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _AuthorHeader(profile: profile),
                        ),

                      // ── Type selector ──────────────────────────────────────
                      const _Label('Post Type'),
                      const SizedBox(height: 10),
                      _TypeSelector(
                        selected: state.type,
                        onSelect: (t) =>
                            ref.read(createPostProvider.notifier).setType(t),
                      ),

                      // ── Subtype chips ──────────────────────────────────────
                      Builder(builder: (_) {
                        final subtypes = _subtypesFor(state.type);
                        if (subtypes.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _SubtypeSelector(
                            subtypes: subtypes,
                            selected: state.subtype,
                            onSelect: (s) => ref
                                .read(createPostProvider.notifier)
                                .setSubtype(s),
                          ),
                        );
                      }),

                      const SizedBox(height: 22),

                      // ── Title ─────────────────────────────────────────────
                      const _Label('Title *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                            color: ALUColors.textPrimary, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Give your post a clear title…',
                        ),
                        onChanged: (v) =>
                            ref.read(createPostProvider.notifier).setTitle(v),
                        maxLength: 120,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                            Text(
                          '$currentLength / ${maxLength ?? 120}',
                          style: const TextStyle(
                              fontSize: 10, color: ALUColors.textMuted),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Body ──────────────────────────────────────────────
                      const _Label('Description *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bodyCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: ALUColors.textPrimary,
                          fontSize: 14,
                          height: 1.55,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Add details, context, or anything people should know…',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 6,
                        minLines: 3,
                        onChanged: (v) =>
                            ref.read(createPostProvider.notifier).setBody(v),
                      ),

                      // ── Conditional: Event Date ────────────────────────────
                      if (_hasEventDate(state.type)) ...[
                        const SizedBox(height: 22),
                        const _Label('Date & Time'),
                        const SizedBox(height: 8),
                        _DateTimeTile(
                          value: state.eventDate,
                          hint: 'Select event date & time',
                          formatPattern: 'EEE, d MMM yyyy  •  HH:mm',
                          onTap: () async {
                            final dt = await _pickDateTime(state.eventDate);
                            if (dt != null) {
                              ref
                                  .read(createPostProvider.notifier)
                                  .setEventDate(dt);
                            }
                          },
                          onClear: () => ref
                              .read(createPostProvider.notifier)
                              .setEventDate(null),
                        ),
                      ],

                      // ── Conditional: Location ──────────────────────────────
                      if (_hasLocation(state.type)) ...[
                        const SizedBox(height: 16),
                        const _Label('Location'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationCtrl,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                              color: ALUColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'e.g. ALU Kigali, Block C',
                            prefixIcon: Icon(Icons.location_on_outlined,
                                size: 18, color: ALUColors.textMuted),
                          ),
                          onChanged: (v) =>
                              ref.read(createPostProvider.notifier).setLocation(v),
                        ),
                      ],

                      // ── Conditional: Capacity ──────────────────────────────
                      if (_hasCapacity(state.type)) ...[
                        const SizedBox(height: 16),
                        const _Label('Capacity (optional)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _capacityCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                              color: ALUColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Max number of attendees',
                            prefixIcon: Icon(Icons.people_outline_rounded,
                                size: 18, color: ALUColors.textMuted),
                          ),
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            ref
                                .read(createPostProvider.notifier)
                                .setCapacity(n);
                          },
                        ),
                      ],

                      // ── Conditional: Application Deadline ─────────────────
                      if (_hasDeadline(state.type)) ...[
                        const SizedBox(height: 22),
                        const _Label('Application Deadline'),
                        const SizedBox(height: 8),
                        _DateTimeTile(
                          value: state.deadline,
                          hint: 'Select deadline date',
                          formatPattern: 'EEE, d MMM yyyy',
                          onTap: () async {
                            final dt = await _pickDateTime(state.deadline,
                                dateOnly: true);
                            if (dt != null) {
                              ref
                                  .read(createPostProvider.notifier)
                                  .setDeadline(dt);
                            }
                          },
                          onClear: () => ref
                              .read(createPostProvider.notifier)
                              .setDeadline(null),
                        ),
                      ],

                      // ── Conditional: Compensation ─────────────────────────
                      if (_hasCompensation(state.type)) ...[
                        const SizedBox(height: 16),
                        const _Label('Compensation / Salary'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _compensationCtrl,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                              color: ALUColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Paid – \$800/month, or Unpaid',
                            prefixIcon: Icon(Icons.attach_money_rounded,
                                size: 18, color: ALUColors.textMuted),
                          ),
                          onChanged: (v) => ref
                              .read(createPostProvider.notifier)
                              .setCompensation(v),
                        ),
                      ],

                      const SizedBox(height: 36),

                      // ── Publish button ─────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: (canPost && !state.submitting) ? _submit : null,
                          icon: state.submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            state.submitting ? 'Publishing…' : 'Publish Post',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ALUColors.red,
                            disabledBackgroundColor: ALUColors.surface,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: ALUColors.textMuted,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Small uppercase section label
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: ALUColors.textMuted,
          letterSpacing: 0.6,
        ),
      );
}

/// Horizontal scrolling type chip row
class _TypeSelector extends StatelessWidget {
  final PostType selected;
  final ValueChanged<PostType> onSelect;
  const _TypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: PostType.values.length,
        itemBuilder: (_, i) {
          final type = PostType.values[i];
          final info = _kTypeInfo[type]!;
          final isSelected = type == selected;

          return GestureDetector(
            onTap: () => onSelect(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? info.color.withValues(alpha: 0.14)
                    : ALUColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? info.color : ALUColors.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(info.icon,
                      size: 13,
                      color: isSelected ? info.color : ALUColors.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    info.label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                      color: isSelected ? info.color : ALUColors.textSecondary,
                    ),
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

/// Wrap of subtype chips; tapping the selected one deselects it
class _SubtypeSelector extends StatelessWidget {
  final List<PostSubtype> subtypes;
  final PostSubtype? selected;
  final ValueChanged<PostSubtype?> onSelect;

  const _SubtypeSelector({
    required this.subtypes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: subtypes.map((s) {
        final isSelected = s == selected;
        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? ALUColors.navyLight.withValues(alpha: 0.14)
                  : ALUColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? ALUColors.navyLight : ALUColors.border,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              _subtypeLabel(s),
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? ALUColors.navyLight
                    : ALUColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Role badge color helper ───────────────────────────────────────────────────

Color _roleColor(String role) {
  switch (role) {
    case 'organiser':
      return ALUColors.gold;
    case 'club_leader':
      return ALUColors.teal;
    default:
      return ALUColors.navyLight;
  }
}

/// Shows the posting user's avatar, name, and role — appears at the top of
/// the form so authors know which identity their post will carry.
class _AuthorHeader extends StatelessWidget {
  final UserProfile profile;
  const _AuthorHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(profile.role);

    return Row(
      children: [
        // avatar / initials
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: profile.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    profile.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        profile.initials,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    profile.initials,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        // name + role badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.fullName,
              style: const TextStyle(
                color: ALUColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Text(
                profile.roleLabel.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        const Text(
          'Posting as',
          style: TextStyle(fontSize: 11, color: ALUColors.textMuted),
        ),
      ],
    );
  }
}

/// Tappable date/time display tile with optional clear button
class _DateTimeTile extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final String formatPattern;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateTimeTile({
    required this.value,
    required this.hint,
    required this.formatPattern,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final formatted =
        value != null ? DateFormat(formatPattern).format(value!) : null;
    final hasValue = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ALUColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? ALUColors.navyLight : ALUColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: hasValue ? ALUColors.navyLight : ALUColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatted ?? hint,
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue
                      ? ALUColors.textPrimary
                      : ALUColors.textMuted,
                ),
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: ALUColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
