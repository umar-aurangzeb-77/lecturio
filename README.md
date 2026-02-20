# Lecturio - AI Powered Academic Management

A modern, powerful Flutter application designed for students to manage their academic life with AI-driven insights and smart organization.

## ✨ Key Features

- **🚀 Smart Dashboard**: At-a-glance view of upcoming exams, deadlines, and smart reminders.
- **🧠 AI Note Generator**: Leverage Google's Gemini Pro to transform lecture texts into concise summaries and key concepts.
- **📁 Lecture Vault**: Organised storage for all your subjects, notes, and study materials.
- **🔔 Exam Tracker**: Never miss an exam with local notifications and countdown badges.
- **🌓 Modern UI**: Premium dark-themed interface with smooth animations and responsive design.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Local Database**: [Hive](https://pub.dev/packages/hive)
- **AI Integration**: [Google Generative AI (Gemini Pro)](https://ai.google.dev/)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Typography**: [Google Fonts (Outfit)](https://fonts.google.com/specimen/Outfit)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- Android Studio / VS Code
- A Gemini API Key from [Google AI Studio](https://aistudio.google.com/)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Shabby6466/Lecturio.git
   ```
2. Navigate to project directory:
   ```bash
   cd lecturio
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Generate Hive adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── core/             # Design tokens, theme, and shared logic
├── features/         # Feature-based architecture
│   ├── dashboard/    # Overview and stats
│   ├── navigation/   # App skeleton and routing
│   ├── study/        # Note taking and AI generation
│   └── vault/        # Subject and file management
└── main.dart         # Entry point and initialization
```
