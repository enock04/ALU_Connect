import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../auth/providers/profile_provider.dart';
import '../../auth/widgets/auth_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _campusCtrl;
  late final TextEditingController _cohortCtrl;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _campusCtrl = TextEditingController();
    _cohortCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _campusCtrl.dispose();
    _cohortCtrl.dispose();
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = profile.fullName;
    _usernameCtrl.text = profile.username;
    _bioCtrl.text = profile.bio ?? '';
    _campusCtrl.text = profile.campus ?? '';
    _cohortCtrl.text = profile.cohortYear?.toString() ?? '';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final cohort = int.tryParse(_cohortCtrl.text.trim());
    ref.read(profileNotifierProvider.notifier).updateProfile(
          fullName: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
          campus:
              _campusCtrl.text.trim().isEmpty ? null : _campusCtrl.text.trim(),
          cohortYear: cohort,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    if (profile != null) {
      _populateFields(profile);
    }

    ref.listen<ProfileState>(profileNotifierProvider, (prev, next) {
      if (next.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated.'),
            backgroundColor: ALUColors.teal,
          ),
        );
        ref.read(profileNotifierProvider.notifier).clearSaved();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: ALUColors.redDim,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: ALUColors.background,
      appBar: AppBar(
        backgroundColor: ALUColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: ALUColors.textSecondary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: ALUColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: profileState.isSaving ? null : _save,
            child: profileState.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: ALUColors.navyLight),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: ALUColors.navyLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: ALUColors.navy,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: ALUColors.navyLight, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            profile?.initials ?? '?',
                            style: const TextStyle(
                              color: ALUColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: ALUColors.navyLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: ALUColors.background, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Photo upload coming soon',
                    style: TextStyle(color: ALUColors.textMuted, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 28),

                AuthTextField(
                  label: 'Full name',
                  hint: 'Your full name',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'Username',
                  hint: 'amara_diallo',
                  controller: _usernameCtrl,
                  prefixIcon: const Icon(Icons.alternate_email_rounded,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Minimum 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontSize: 12,
                        color: ALUColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      maxLength: 200,
                      style: const TextStyle(
                          color: ALUColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            'Tell the community a bit about yourself...',
                        hintStyle: const TextStyle(
                            color: ALUColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: ALUColors.card,
                        contentPadding: const EdgeInsets.all(14),
                        counterStyle:
                            const TextStyle(color: ALUColors.textMuted, fontSize: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: ALUColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: ALUColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: ALUColors.navyLight, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'Campus',
                  hint: 'e.g. Kigali, Mauritius',
                  controller: _campusCtrl,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: ALUColors.textMuted, size: 16),
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'Cohort Year',
                  hint: 'e.g. 2024',
                  controller: _cohortCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final year = int.tryParse(v.trim());
                    if (year == null || year < 2019 || year > 2030) {
                      return 'Enter a valid year';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),
                AuthPrimaryButton(
                  label: 'Save Changes',
                  onPressed: _save,
                  isLoading: profileState.isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
