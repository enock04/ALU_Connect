enum UserRole { student, organiser, clubLeader }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? cohort;
  final String? major;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.cohort,
    this.major,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == (json['role'] as String? ?? 'student'),
        orElse: () => UserRole.student,
      ),
      avatarUrl: json['avatar_url'] as String?,
      cohort: json['cohort'] as String?,
      major: json['major'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatar_url': avatarUrl,
        'cohort': cohort,
        'major': major,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    String? cohort,
    String? major,
    UserRole? role,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        cohort: cohort ?? this.cohort,
        major: major ?? this.major,
        createdAt: createdAt,
      );

  // initials from first + last name
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // only organisers and club leaders can post content
  bool get canPost => role == UserRole.organiser || role == UserRole.clubLeader;
}
