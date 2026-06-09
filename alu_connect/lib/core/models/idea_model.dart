enum IdeaDomain { agriTech, healthTech, edTech, finTech, cleanTech, logistics, other }

enum SkillTag { developer, designer, marketer, finance, legal, operations }

class IdeaModel {
  final String id;
  final String title;
  final String problemStatement;
  final IdeaDomain domain;
  final List<SkillTag> skillsNeeded;
  final String founderId;
  final String founderName;
  final String? founderAvatar;
  final int backerCount;
  final bool isBackedByMe;
  final String? teamChatRoomId;
  final DateTime createdAt;

  // 3 backers unlocks the team chat
  static const int backerThreshold = 3;

  const IdeaModel({
    required this.id,
    required this.title,
    required this.problemStatement,
    required this.domain,
    required this.skillsNeeded,
    required this.founderId,
    required this.founderName,
    this.founderAvatar,
    this.backerCount = 0,
    this.isBackedByMe = false,
    this.teamChatRoomId,
    required this.createdAt,
  });

  factory IdeaModel.fromJson(Map<String, dynamic> json) {
    return IdeaModel(
      id: json['id'] as String,
      title: json['title'] as String,
      problemStatement: json['problem_statement'] as String,
      domain: IdeaDomain.values.firstWhere(
        (d) => d.name == (json['domain'] as String? ?? 'other'),
        orElse: () => IdeaDomain.other,
      ),
      skillsNeeded: ((json['skills_needed'] as List<dynamic>?) ?? [])
          .map((s) => SkillTag.values.firstWhere(
                (t) => t.name == s,
                orElse: () => SkillTag.developer,
              ))
          .toList(),
      founderId: json['founder_id'] as String,
      founderName: json['founder_name'] as String? ?? 'Unknown',
      founderAvatar: json['founder_avatar'] as String?,
      backerCount: json['backer_count'] as int? ?? 0,
      isBackedByMe: json['is_backed_by_me'] as bool? ?? false,
      teamChatRoomId: json['team_chat_room_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'problem_statement': problemStatement,
        'domain': domain.name,
        'skills_needed': skillsNeeded.map((s) => s.name).toList(),
        'founder_id': founderId,
        'founder_name': founderName,
        'founder_avatar': founderAvatar,
        'backer_count': backerCount,
        'team_chat_room_id': teamChatRoomId,
        'created_at': createdAt.toIso8601String(),
      };

  IdeaModel copyWith({
    int? backerCount,
    bool? isBackedByMe,
    String? teamChatRoomId,
  }) =>
      IdeaModel(
        id: id,
        title: title,
        problemStatement: problemStatement,
        domain: domain,
        skillsNeeded: skillsNeeded,
        founderId: founderId,
        founderName: founderName,
        founderAvatar: founderAvatar,
        backerCount: backerCount ?? this.backerCount,
        isBackedByMe: isBackedByMe ?? this.isBackedByMe,
        teamChatRoomId: teamChatRoomId ?? this.teamChatRoomId,
        createdAt: createdAt,
      );

  bool get isUnlocked => backerCount >= backerThreshold;
  int get backersNeeded => (backerThreshold - backerCount).clamp(0, backerThreshold);
  double get progress => (backerCount / backerThreshold).clamp(0.0, 1.0);
}
