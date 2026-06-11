# ALU Intercampus Connect

> **Connect. Collaborate. Lead together.**

A mobile-first Flutter application built for the African Leadership University (ALU) ecosystem. ALU Intercampus Connect helps students discover events, join communities, RSVP to activities, and communicate — all in one place.

---

## Overview

ALU Intercampus Connect is a student engagement platform designed to solve a real problem at ALU: students miss out on events, opportunities, and community activities because there is no central place to find them. This app brings together event discovery, RSVP management, community spaces, and peer communication in a single, intuitive mobile experience tailored specifically for the ALU context across both campuses — Kigali and Mauritius.

---

## Features

### Authentication & Onboarding
- 3-slide onboarding flow introducing the app to new users
- Sign in with ALU student email
- Sign up with name, email, and interest selection for personalized feed
- Session persistence using SharedPreferences — login survives app restarts
- Role-based access: Student, Organizer, Admin

### Home Feed & Discovery
- Dynamic feed of events and opportunities
- Featured event banner with highlighted upcoming activities
- Category filter chips: Events, Hackathons, Workshops, Internships, Startups
- Live search across all events and opportunities
- Personalized "For You" section based on joined communities

### Events & RSVP
- Full event detail screen with date, time, location, description
- Live countdown timer to event start
- RSVP management: Going / Interested / Not Going
- RSVP state persisted with SharedPreferences — survives app restarts
- Attendee avatar stack showing who is going
- My RSVPs screen with Going / Interested tabs
- Create Post form for organizers (role-gated)

### Communities
- Browse all ALU clubs and communities
- My Clubs tab showing joined communities
- Club detail screen with member list and club events
- Join / Leave with state saved locally

### Chat & Messaging
- Community chat rooms
- Direct messages between students
- Message history stored with sqflite local database
- Messages persist across app restarts

### Profile
- Student profile with avatar, stats (events, communities, connections)
- Edit profile (name, bio, campus)
- My Posts, Saved Opportunities, My RSVPs quick access
- Settings and logout

### Bonus Features
- Launchpad - an entreprenurial meetup joint for students with ideas
- In-app notifications for RSVP confirmations and announcements
- Smooth animations using flutter_animate
- Hero transitions between feed and event detail

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter / Dart | Mobile app framework |
| SharedPreferences | RSVP state, login session, onboarding completion |
| Supabase | Local SQLite database for chat message persistence |
| Provider | State management across screens |
| flutter_animate | Animations and transitions |
| google_fonts | Plus Jakarta Sans typography |

---

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio with an emulator, or a physical Android/iOS device
- Git

### Installation

```bash
# Clone the repository
git clone git@github.com:enock04/ALU_Connect.git

# Move into the project folder
cd alu_connect

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running on Emulator
1. Open Android Studio
2. Go to Virtual Device Manager
3. Click Play on any available emulator
4. Run `flutter run` in the terminal

---

## Team & Branch Structure

| Member | Role | Branch |
|---|---|---|
| Enock | Theme, Widgets & Feed | `feature/theme_widget` |
|Armstrong| Feed & Discovery | `feature/feed-discovery` |
| Jotham | Events & RSVP | `feature/events-rsvp` |
| Neville| Auth, Onboarding & Config | `feature/auth-onboarding` |

---


## Rubric Alignment

| Criterion | How we address it |
|---|---|
| UI/UX Design | Dark theme redesigned beyond sample, ALU gold accent, consistent typography |
| Critical Thinking | Features justified for ALU context (dual campus filter, role-gated posting) |
| Navigation | Bottom nav with 5 tabs, Hero transitions, named routes |
| State Handling | Provider + SharedPreferences + sqflite for full state persistence |
| Technical Initiative | SupaBase, flutter_animate, role-based access |
| Code Quality | Modular structure, reusable widgets, consistent naming conventions |
| Error Handling | Empty states, form validation, loading indicators, error messages |

---

## License

Built for ALU Mobile Application Development 
