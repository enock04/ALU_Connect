//models/event_model.dart

class Event {
  final String id;
  final String title;
  final String category;
  final String location;
  final String date;
  final String time;
  final String description;
  final int capacity;
  final int attendees;
  final List<String> attendeeAvatars; // initials for mock
  final bool isFeatured;
  final String organizer;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.description,
    required this.capacity,
    required this.attendees,
    required this.attendeeAvatars,
    this.isFeatured = false,
    required this.organizer,
  });

  double get capacityPercent => attendees / capacity;
  bool get isFull => attendees >= capacity;
}

const List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'ALU Hackathon 2026 — Build for Africa',
    category: 'Hackathon',
    location: 'Kigali',
    date: 'Oct 24, 2026',
    time: '08:00 AM',
    description:
        'A 48-hour hackathon challenging ALU students to build solutions for real African challenges. Teams of up to 4. Prizes worth \$3,000.',
    capacity: 120,
    attendees: 104,
    attendeeAvatars: ['AD', 'KN', 'SM', 'RB'],
    isFeatured: true,
    organizer: 'ALU Innovation Hub',
  ),
  Event(
    id: '2',
    title: 'Mastercard Foundation — Apply Now',
    category: 'Internship',
    location: 'Mauritius',
    date: 'Jan 2027',
    time: '09:00 AM',
    description:
        'Mastercard Foundation is offering fully funded internship opportunities for ALU students across Africa.',
    capacity: 50,
    attendees: 38,
    attendeeAvatars: ['JM', 'AK', 'BB'],
    isFeatured: true,
    organizer: 'Mastercard Foundation',
  ),
  Event(
    id: '3',
    title: 'AI & Machine Learning Workshop',
    category: 'Workshop',
    location: 'ALU Kigali — LT3',
    date: 'Jun 18, 2026',
    time: '02:00 PM',
    description:
        'Hands-on intro to ML fundamentals using Python and scikit-learn. Bring your laptop. No prior ML experience required.',
    capacity: 40,
    attendees: 40,
    attendeeAvatars: ['NM', 'TK', 'LW', 'PO'],
    isFeatured: false,
    organizer: 'ALU Tech Club',
  ),
  Event(
    id: '4',
    title: 'Entrepreneurship Pitch Night',
    category: 'Event',
    location: 'ALU Kigali — Main Hall',
    date: 'Jun 20, 2026',
    time: '06:00 PM',
    description:
        'Students pitch their startup ideas to a panel of investors and industry mentors. Open for audience attendance.',
    capacity: 200,
    attendees: 87,
    attendeeAvatars: ['CD', 'FK', 'AM'],
    isFeatured: false,
    organizer: 'Entrepreneurship Club',
  ),
  Event(
    id: '5',
    title: 'Leadership Summit 2026',
    category: 'Leadership',
    location: 'ALU Kigali',
    date: 'Jul 5, 2026',
    time: '09:00 AM',
    description:
        'A full-day summit bringing together student leaders, faculty, and ALU alumni to discuss impact-driven leadership.',
    capacity: 150,
    attendees: 62,
    attendeeAvatars: ['BN', 'SK'],
    isFeatured: false,
    organizer: 'Campus Leaders Network',
  ),
  Event(
    id: '6',
    title: 'Community Health Drive',
    category: 'Community',
    location: 'Kigali — Gisozi',
    date: 'Jun 22, 2026',
    time: '08:00 AM',
    description:
        'Join ALU students in a community health outreach event in Gisozi. Free medical checkups and health education sessions.',
    capacity: 60,
    attendees: 24,
    attendeeAvatars: ['NJ', 'PK', 'AM'],
    isFeatured: false,
    organizer: 'ALU Community Impact',
  ),
];

const List<String> eventCategories = [
  'All',
  'Events',
  'Hackathon',
  'Workshop',
  'Internship',
  'Leadership',
  'Community',
];
