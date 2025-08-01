# 🐾 Habio

**Habio** is a gamified habit tracker where users build better routines by creating themed habit rooms, each with their own pet companion. Strengthen your habits, unlock new creatures, and compete with friends to grow your personal habit world.

> 🎯 Your habits feed your pet. Your pet reflects your progress.

---

## 🚀 Key Concepts

### 🧩 Rooms

Habit spaces organized by themes (e.g. Fitness, Learning, Wellness), each with its own:

- Pet companion
- Habit list
- Progress tracking
- Social sharing

### 🐶 Pets

Each pet is unique and tied to a specific room. Pets have:

- **Personalities** (e.g. shy, active, curious)
- **Preferences** (e.g. loves running, dislikes junk food)
- **Feelings** that react to your performance
- **Mechanics**: pets evolve, get energized, or become moody based on your habit consistency

### 🧠 Feelings & Emotions

Pets show emotional feedback depending on your habit activity. Their behavior motivates you to keep your streaks alive.

### 👥 Social & Competitive

- Share rooms with friends
- Compete in **habit challenges**
- Track your group streaks
- Show off your pet’s evolution

---

## 🎮 Game Mechanics

| Feature             | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| 🌀 **Roulette**     | Daily or weekly roulette mini-game to win rewards               |
| 🎯 **Challenges**   | Complete group or solo challenges to level up pets              |
| 🪙 **Point System** | Earn points for each habit completed, unlock items and new pets |
| 🧬 **Evolution**    | Pets change visually and gain traits as you progress            |

---

## 📱 Tech Stack

- **Flutter**: cross-platform mobile UI
- **Dart**: main programming language
- **Firebase / Supabase (planned)**: for authentication and real-time data
- **GitHub Actions**: CI/CD (planned)

---

## 🧪 Getting Started

### Prerequisites

- Flutter SDK >= 3.x
- Android Studio or VS Code with Flutter plugin

### Run Locally

```bash
flutter pub get
flutter run
```

---

## 🧱 Feature Template (Mason Brick)

To quickly generate a new feature structure (e.g. `habit`, `room`, `pet`) using Mason:

### Step 1: Install Mason CLI (only once)

```bash
dart pub global activate mason_cli
```

Make sure to add Mason to your path if it's not available as a global command.

### Step 2: Get bricks (only once per clone)

From the root of the project:

```bash
mason get
```

### Step 3: Generate a feature

```bash
mason make feature_brick -o lib/features/
```

When prompted:

```
? feature_name: habit
```

This will generate:

```
lib/features/habit/
├── domain/
├── data/
├── application/
└── presentation/
```

With boilerplate Dart files already filled in.

> 📦 The brick is located at `bricks/feature_brick/` and defined in `mason.yaml`.

---

## 🔒 License

This project is **proprietary software**.

© 2025 **Javier Gómez**. All rights reserved.

No part of this codebase may be copied, distributed, modified, or used in any form without explicit written permission from the author.
