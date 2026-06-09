import '../models/models.dart';

// Offline mock data — used for UI previews and during dev before backend is live.
// Member 3 (Feed) swaps events/communities with Supabase queries.
// Member 5 (Launchpad) swaps ideas with Supabase queries.

final mockEvents = [
  EventModel(
    id: 'evt-001',
    title: 'Startup Pitch Night — Kigali',
    body: 'Present your venture to a panel of investors and ALU faculty. '
        'Selected pitches receive seed funding up to \$5,000.',
    category: EventCategory.venture,
    eventDate: DateTime.now().add(const Duration(days: 7)),
    location: 'ALU Auditorium, Kigali',
    organiserName: 'ALU Ventures Club',
    rsvpCount: 42,
    capacity: 80,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  EventModel(
    id: 'evt-002',
    title: 'LinkedIn Profile Workshop',
    body: 'Optimise your LinkedIn for internship and job hunting. '
        'Bring your laptop — live profile edits with Career Services.',
    category: EventCategory.career,
    eventDate: DateTime.now().add(const Duration(days: 3)),
    location: 'Block B, Seminar Room 3',
    organiserName: 'Career Services',
    rsvpCount: 28,
    capacity: 30,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  EventModel(
    id: 'evt-003',
    title: 'Pan-African Culture Festival 2026',
    body: 'Celebrate ALU\'s diversity with food, music, art, and performances '
        'from across the continent.',
    category: EventCategory.social,
    eventDate: DateTime.now().add(const Duration(days: 14)),
    location: 'ALU Campus Grounds',
    organiserName: 'Student Representative Council',
    rsvpCount: 156,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  EventModel(
    id: 'evt-004',
    title: 'ML Study Circle — Backprop from Scratch',
    body: 'Weekly deep-dive into ML fundamentals. '
        'This week: implementing backpropagation in pure Python.',
    category: EventCategory.academic,
    eventDate: DateTime.now().add(const Duration(days: 2)),
    location: 'Innovation Lab, Floor 2',
    organiserName: 'Tech Crew ALU',
    rsvpCount: 19,
    capacity: 25,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  EventModel(
    id: 'evt-005',
    title: 'SRC Town Hall — Semester 2',
    body: 'Open forum with student leadership. Raise concerns, vote on policy '
        'changes, and hear updates on campus projects.',
    category: EventCategory.student,
    eventDate: DateTime.now().add(const Duration(days: 5)),
    location: 'Main Lecture Hall',
    organiserName: 'Student Representative Council',
    rsvpCount: 87,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

final mockCommunities = [
  CommunityModel(
    id: 'comm-001',
    name: 'Tech Crew ALU',
    description: 'Software engineers, designers, and builders. '
        'Hackathons, projects, and peer mentorship.',
    memberCount: 234,
    isJoined: true,
  ),
  CommunityModel(
    id: 'comm-002',
    name: 'ALU Ventures',
    description: 'Entrepreneurs and startup founders. '
        'Pitch practice, investor connections, and co-founder matching.',
    memberCount: 187,
    isJoined: false,
  ),
  CommunityModel(
    id: 'comm-003',
    name: 'Debate Society',
    description: 'Sharpen your arguments and public speaking. '
        'Weekly sessions and inter-university competitions.',
    memberCount: 95,
    isJoined: true,
  ),
  CommunityModel(
    id: 'comm-004',
    name: 'Finance & Investment Club',
    description: 'Stock market simulations, personal finance workshops, '
        'and connections with finance professionals.',
    memberCount: 142,
    isJoined: false,
  ),
  CommunityModel(
    id: 'comm-005',
    name: 'Wellness & Fitness',
    description: 'Morning runs, meditation, and mental health check-ins. '
        'Because hustle culture is overrated.',
    memberCount: 118,
    isJoined: false,
  ),
];

final mockIdeas = [
  IdeaModel(
    id: 'idea-001',
    title: 'Campus Ride-Share App',
    problemStatement: 'ALU students spend too much on transport between campus '
        'and the city. There is no coordinated way to split rides with peers '
        'going the same direction.',
    domain: IdeaDomain.logistics,
    skillsNeeded: [SkillTag.developer, SkillTag.designer],
    founderId: 'user-001',
    founderName: 'Amara Diallo',
    backerCount: 2,
    isBackedByMe: false,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  IdeaModel(
    id: 'idea-002',
    title: 'Africa Study Abroad Network',
    problemStatement: 'African students rarely do study exchanges within Africa — '
        'most programs are Western-focused. There is no platform connecting '
        'universities continent-wide for intra-Africa exchanges.',
    domain: IdeaDomain.edTech,
    skillsNeeded: [SkillTag.developer, SkillTag.marketer, SkillTag.operations],
    founderId: 'user-002',
    founderName: 'Kofi Mensah',
    backerCount: 5,
    isBackedByMe: true,
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
  ),
  IdeaModel(
    id: 'idea-003',
    title: 'Micro-Lending for Students',
    problemStatement: 'Students facing unexpected expenses have no fast, '
        'zero-interest option. Bank loans are slow; asking friends is awkward. '
        'A peer-backed micro-loan pool could solve this.',
    domain: IdeaDomain.finTech,
    skillsNeeded: [SkillTag.developer, SkillTag.finance, SkillTag.legal],
    founderId: 'user-003',
    founderName: 'Zanele Dube',
    backerCount: 8,
    isBackedByMe: false,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
];
