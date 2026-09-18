# ML MOOC Practice App

A cross-platform Flutter application for practicing and testing knowledge on **Machine Learning for Earth System Sciences** (NPTEL / MOOC course).

## 🚀 Features

- 📚 **Comprehensive Question Bank**: 80 curated multiple-choice questions covering core ML & Earth System Science topics, including week-wise assignment questions (Weeks 5 through 8).
- 🗓️ **Browse by Week**: Filter questions by individual weeks (Week 1–8) or browse the complete set with on-demand answer toggles.
- ⚡ **Interactive Quiz Mode**:
  - **Randomized Questions**: Test yourself with shuffled question sets.
  - **Instant Feedback & Auto-Lock**: Selecting an option immediately locks your answer and reveals color-coded feedback (green for correct, red for incorrect).
  - **Persistent Score Tracker**: A live score badge remains continuously visible in the header during quiz mode.
  - **Bidirectional Navigation**: Move backward (`Previous`) and forward (`Next`) through questions at any time while preserving your selected answers and score.
  - **Final Results Summary**: Track your score and restart new practice rounds seamlessly.
- 💾 **Local Database**: Built with SQLite (`sqflite` & `sqflite_common_ffi`), ensuring offline performance across desktop (Windows) and mobile platforms.

---

## 💻 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)

### Installation & Execution

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd ML_MOOC
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Run on Desktop (Windows)
   flutter run -d windows

   # Run on connected Mobile device or Emulator
   flutter run
   ```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Database**: SQLite (`sqflite`, `sqflite_common_ffi`)
- **UI Components**: Material 3 Design
