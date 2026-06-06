# Quiz App 🎯

A mobile quiz application built with Flutter that uses the [Open Trivia Database](https://opentdb.com/) API.

## Features

- 📚 Thousands of questions across dozens of categories
- 🎯 Three difficulty levels: Easy, Medium, Hard
- ❤️ Save favorite questions for later review
- 📊 Track your quiz history with charts, stats and quiz history
- 🌙 Dark and light theme support
- 📴 Offline mode – play previously loaded quizzes without internet
- 🔄 Manual data refresh with pull-to-refresh

## Screens

1. **Home** – select category, difficulty and number of questions
2. **Quiz** – answer questions with instant feedback
3. **Result** – see your score and feedback after each quiz
4. **Favorites** – browse and manage saved questions
5. **Profile & Settings** – view stats, charts, toggle dark mode, reset history

## Tech Stack

- **Flutter** – mobile framework
- **REST API** – Open Trivia Database (`/api.php`, `/api_category.php`)
- **SQLite** – local database for offline mode, favorites and history
- **Firebase Analytics** – tracks `quiz_started`, `quiz_completed`, `question_answered`, `question_favorited` events
- **Firebase Crashlytics** – automatic crash reporting
- **Firebase Performance** – API call monitoring

## Project Structure

lib/  
├── main.dart  
├── models/  
│   ├── question.dart  
│   └── quiz_result.dart  
├── services/  
│   ├── api_service.dart  
│   ├── database_service.dart  
│   └── firebase_service.dart  
└── screens/  
│   ├── home_screen.dart  
│   ├── quiz_screen.dart  
│   ├── result_screen.dart  
│   ├── favorites_screen.dart  
│   └── profile_screen.dart  

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

> Firebase configuration (`google-services.json`) is required for Analytics, Crashlytics and Performance features.
