enum PostType { schoolEvent, jobInternship, networking, ventureSupport, entertainment, src }

enum PostSubtype { hackathon, workshop, grant, pitchEvent, fullTime, internship, mixer, debate, cultural, other }

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? authorRole;
  final PostType type;
  final PostSubtype? subtype;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? eventDate;
  final String? location;
  final int rsvpCount;
  final int? capacity;
  final DateTime? deadline;
  final String? compensationInfo;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.authorRole,
    required this.type,
    this.subtype,
    required this.title,
    required this.body,
    this.imageUrl,
    this.eventDate,
    this.location,
    this.rsvpCount = 0,
    this.capacity,
    this.deadline,
    this.compensationInfo,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? 'Unknown',
      authorAvatar: json['author_avatar'] as String?,
      authorRole: json['author_role'] as String?,
      type: PostType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? 'schoolEvent'),
        orElse: () => PostType.schoolEvent,
      ),
      subtype: json['subtype'] != null
          ? PostSubtype.values.firstWhere(
              (s) => s.name == json['subtype'],
              orElse: () => PostSubtype.other,
            )
          : null,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      eventDate: json['event_date'] != null ? DateTime.parse(json['event_date'] as String) : null,
      location: json['location'] as String?,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      capacity: json['capacity'] as int?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      compensationInfo: json['compensation_info'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_id': authorId,
        'author_name': authorName,
        'author_avatar': authorAvatar,
        'author_role': authorRole,
        'type': type.name,
        'subtype': subtype?.name,
        'title': title,
        'body': body,
        'image_url': imageUrl,
        'event_date': eventDate?.toIso8601String(),
        'location': location,
        'rsvp_count': rsvpCount,
        'capacity': capacity,
        'deadline': deadline?.toIso8601String(),
        'compensation_info': compensationInfo,
        'created_at': createdAt.toIso8601String(),
      };

  bool get hasCapacity => capacity == null || rsvpCount < capacity!;
  int? get spotsLeft => capacity != null ? capacity! - rsvpCount : null;
}
