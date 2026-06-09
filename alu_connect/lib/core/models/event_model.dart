// A focused model for calendar-style events shown in the home feed.
// PostModel handles the Supabase write side; EventModel is the read-optimised
// shape that Member 3 (Feed) consumes directly.

enum EventCategory { academic, career, social, venture, student }

class EventModel {
  final String id;
  final String title;
  final String body;
  final EventCategory category;
  final DateTime eventDate;
  final String location;
  final String? imageUrl;
  final String organiserName;
  final String? organiserAvatar;
  final int rsvpCount;
  final int? capacity;
  final bool isUserRsvped;
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.eventDate,
    required this.location,
    this.imageUrl,
    required this.organiserName,
    this.organiserAvatar,
    this.rsvpCount = 0,
    this.capacity,
    this.isUserRsvped = false,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, {bool isRsvped = false}) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: EventCategory.values.firstWhere(
        (c) => c.name == (json['category'] as String? ?? 'academic'),
        orElse: () => EventCategory.academic,
      ),
      eventDate: DateTime.parse(json['event_date'] as String),
      location: json['location'] as String? ?? 'TBD',
      imageUrl: json['image_url'] as String?,
      organiserName: json['author_name'] as String? ?? 'ALU',
      organiserAvatar: json['author_avatar'] as String?,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      capacity: json['capacity'] as int?,
      isUserRsvped: isRsvped,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isFull => capacity != null && rsvpCount >= capacity!;
  int? get spotsLeft => capacity != null ? capacity! - rsvpCount : null;

  EventModel copyWith({bool? isUserRsvped, int? rsvpCount}) => EventModel(
        id: id,
        title: title,
        body: body,
        category: category,
        eventDate: eventDate,
        location: location,
        imageUrl: imageUrl,
        organiserName: organiserName,
        organiserAvatar: organiserAvatar,
        rsvpCount: rsvpCount ?? this.rsvpCount,
        capacity: capacity,
        isUserRsvped: isUserRsvped ?? this.isUserRsvped,
        createdAt: createdAt,
      );
}

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final int memberCount;
  final bool isJoined;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.avatarUrl,
    this.memberCount = 0,
    this.isJoined = false,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) => CommunityModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        memberCount: json['member_count'] as int? ?? 0,
        isJoined: json['is_joined'] as bool? ?? false,
      );
}
