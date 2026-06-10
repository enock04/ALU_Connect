import '../models/models.dart';

// Offline mock data — used for UI previews and during dev before backend is live.
// Member 3 (Feed) swaps events/communities with Supabase queries.
// Member 5 (Launchpad) swaps ideas with Supabase queries.

// Real ALU announcements sourced from the community WhatsApp channel (June 2026).
// Member 3: swap this list with a Supabase query once posts are seeded.
final mockEvents = [
  EventModel(
    id: 'evt-001',
    title: 'Internship Season 101',
    body: 'Still figuring out how to land an internship? Already have one and '
        'wondering how to make it count?\n\n'
        'Join us for Internship Season 101 — a practical conversation on how to '
        'secure internship opportunities, maximise your experience, and turn '
        'internships into long-term career growth.\n\n'
        'Featuring:\n'
        '• Seyifunmi Olafioye — Senior Product Manager at Renmoney MFB & '
        'Founder of The Product Notebook\n'
        '• Dolapo Oshikoya — Product Manager at PaidHR & 2025 Lagos State '
        'Youth Ambassador\n\n'
        'What you\'ll learn:\n'
        '• How to find and secure internship opportunities\n'
        '• How to make the most of your internship experience\n'
        '• How to build skills and relationships that support long-term growth '
        'in tech\n'
        '• Lessons from real internship and early-career journeys',
    category: EventCategory.career,
    eventDate: DateTime(2026, 6, 11, 19, 0),
    location: 'Online — link shared via community channel',
    organiserName: 'ALU Career Services',
    rsvpCount: 61,
    createdAt: DateTime(2026, 6, 5, 20, 43),
  ),
  EventModel(
    id: 'evt-002',
    title: 'Arts & Culture for Climate — London Climate Action Week',
    body: 'Arts & Culture for Climate takes place on Wednesday 24 June 2026 at '
        'SOAS University of London during London Climate Action Week 2026. '
        'Hosted by The Ramphal Institute in collaboration with the Royal African '
        'Society.\n\n'
        'The event brings together artists, cultural leaders, youth advocates, '
        'and diplomats to explore how art, culture, and heritage can shape our '
        'response to the climate crisis.\n\n'
        'The organisers are looking for a Rwandan creative to contribute:\n'
        '• Photographer, visual artist, or filmmaker — a photo essay, artwork, '
        'or short film that tells Rwanda\'s climate story. This could capture '
        'Rwanda\'s reforestation, its plastic-free streets, recycling and waste '
        'innovation, community environmental practice, or its relationship with '
        'the natural landscape.\n\n'
        'Selected work will be screened or displayed on the night. This is a '
        'free opportunity to showcase your talent on an international stage.\n\n'
        'Interested? Reach out to Paul Udah directly to be connected with the '
        'organising team.',
    category: EventCategory.social,
    eventDate: DateTime(2026, 6, 24, 18, 0),
    location: 'SOAS University of London, UK',
    organiserName: 'The Ramphal Institute',
    rsvpCount: 14,
    createdAt: DateTime(2026, 6, 9, 22, 6),
  ),
  EventModel(
    id: 'evt-003',
    title: 'LadX is Hiring — Intra-African Trade Infrastructure',
    body: 'LadX is building the infrastructure for intra-African trade — and '
        'they\'re looking for sharp, driven people to grow with them.\n\n'
        'Based in Kigali, Rwanda.\n\n'
        'To apply:\n'
        '• Send your CV to: dominion@ladx.io\n'
        '• View all open roles via the link in the community channel\n\n'
        'This is a ground-floor opportunity to work on infrastructure that '
        'matters for the continent.',
    category: EventCategory.career,
    eventDate: DateTime(2026, 6, 20, 9, 0),
    location: 'Kigali, Rwanda',
    organiserName: 'LadX',
    rsvpCount: 23,
    createdAt: DateTime(2026, 6, 10, 14, 29),
  ),
  EventModel(
    id: 'evt-004',
    title: 'CMU Info Session — On Campus',
    body: 'Carnegie Mellon University held an info session for ALU students '
        'across the Kenya and Burundi campuses. Recordings and materials will '
        'be shared through the community channel for those who missed it.',
    category: EventCategory.academic,
    eventDate: DateTime(2026, 6, 5, 10, 13),
    location: 'ALU Campuses — Kenya & Burundi',
    organiserName: 'ALU',
    rsvpCount: 38,
    createdAt: DateTime(2026, 6, 5, 10, 13),
  ),
];

final mockCommunities = [
  const CommunityModel(
    id: 'comm-001',
    name: 'Tech Crew ALU',
    description: 'Software engineers, designers, and builders. '
        'Hackathons, projects, and peer mentorship.',
    memberCount: 234,
    isJoined: true,
  ),
  const CommunityModel(
    id: 'comm-002',
    name: 'ALU Ventures',
    description: 'Entrepreneurs and startup founders. '
        'Pitch practice, investor connections, and co-founder matching.',
    memberCount: 187,
    isJoined: false,
  ),
  const CommunityModel(
    id: 'comm-003',
    name: 'Debate Society',
    description: 'Sharpen your arguments and public speaking. '
        'Weekly sessions and inter-university competitions.',
    memberCount: 95,
    isJoined: true,
  ),
  const CommunityModel(
    id: 'comm-004',
    name: 'Finance & Investment Club',
    description: 'Stock market simulations, personal finance workshops, '
        'and connections with finance professionals.',
    memberCount: 142,
    isJoined: false,
  ),
  const CommunityModel(
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
