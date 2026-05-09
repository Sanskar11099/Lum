# lüm

A glass-morphism social media app built with Flutter — featuring an aurora animated background, infinite-scroll masonry feed, stories, post detail modal, explore search, and a profile page, all backed by Supabase.

---

## Features

- **Aurora Background** — animated radial gradient blobs that pulse and drift
- **Masonry Feed** — two-column staggered grid with infinite scroll and shimmer placeholders
- **Stories** — horizontal story bubbles with full-screen viewer, progress bars, and tap navigation
- **Like & Save** — double-tap to like, save posts; animated heart burst
- **Post Detail Sheet** — modal with full image, stats, and threaded comments
- **Explore / Search** — trending tags, 3-column discover grid, live search field
- **Profile Page** — cover photo, avatar, follower stats, posts/saved tab grid
- **Supabase Backend** — real feed data, comments, likes, image uploads via Supabase Storage
- **Riverpod State Management** — providers for feed, comments, likes
- **Glass Morphism UI** — `BackdropFilter` blur cards, frosted nav bar, glowing borders

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x (Dart 3.5+) |
| State Management | flutter_riverpod ^2.5.1 |
| Backend | Supabase (PostgreSQL + Storage + Auth) |
| Image Loading | cached_network_image + shimmer |
| Fonts | Google Fonts |
| Networking | dio ^5.4.3 |
| Models | freezed + json_serializable |
| Connectivity | connectivity_plus |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.5.0`
- Dart `^3.5.0`
- A [Supabase](https://supabase.com) project with the schema set up (see below)
- Android Studio / Xcode for device deployment

### 1. Clone the repo

```bash
git clone git@github.com:Sanskar11099/Lum.git
cd Lum
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Supabase

Create a Supabase project and run the following SQL to create the required tables:

```sql
-- Posts table
create table posts (
  id uuid primary key default gen_random_uuid(),
  image_url text not null,
  caption text,
  user_name text not null,
  user_avatar_url text,
  likes_count int default 0,
  created_at timestamptz default now()
);

-- Comments table
create table comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade,
  user_name text not null,
  content text not null,
  created_at timestamptz default now()
);

-- Likes table
create table likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade,
  user_id text not null,
  created_at timestamptz default now(),
  unique(post_id, user_id)
);
```

### 4. Configure environment

Never hardcode your Supabase credentials. Pass them at run time via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<your-project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

For VS Code, add to `.vscode/launch.json`:

```json
{
  "configurations": [
    {
      "name": "lüm",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://<your-project>.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=<your-anon-key>"
      ]
    }
  ]
}
```

### 5. Run

```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants.dart          # App-wide constants (Supabase URL/key via dart-define)
│   └── supabase_client.dart    # Supabase client singleton
├── data/
│   ├── models/
│   │   ├── post_model.dart     # Post data model (freezed)
│   │   └── comment_model.dart  # Comment data model (freezed)
│   └── repositories/
│       ├── feed_repository.dart
│       ├── comments_repository.dart
│       └── upload_repository.dart
├── providers/
│   ├── feed_provider.dart      # Riverpod feed state
│   ├── comments_provider.dart
│   └── like_provider.dart
├── ui/
│   ├── feed/
│   │   ├── feed_screen.dart    # Main feed screen (Supabase-backed)
│   │   └── post_card.dart
│   └── detail/
│       ├── detail_screen.dart
│       └── comments_sheet.dart
├── lum/                        # lüm glass UI layer
│   ├── theme.dart              # Design tokens (Lum color palette)
│   ├── widgets.dart            # Shared widgets, data models, sample data
│   ├── feed_page.dart          # LumFeedPage — root tab navigator + masonry feed
│   ├── story_viewer.dart       # Full-screen story with progress bars
│   ├── post_sheet.dart         # Post detail bottom sheet
│   ├── search_page.dart        # Explore / search screen
│   └── profile_page.dart       # User profile screen
└── main.dart                   # App entry point
```

---

## Design System

All design tokens live in `lib/lum/theme.dart`:

| Token | Color | Usage |
|---|---|---|
| `Lum.bg` | `#05050A` | App background |
| `Lum.violet` | `#A78BFA` | Primary accent |
| `Lum.aqua` | `#34D399` | Secondary accent |
| `Lum.rose` | `#F472B6` | Tertiary accent |
| `Lum.amber` | `#FBBF24` | Warm accent |
| `Lum.glass` | `#0EFFFFFF` | Frosted card fill |
| `Lum.glassBorder` | `#17FFFFFF` | Frosted card border |

---

## License

MIT License. See [LICENSE](LICENSE) for details.
