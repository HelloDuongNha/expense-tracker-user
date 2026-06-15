# Expense Tracker - User Application (Flutter)

An offline-first cross-platform mobile application built with Flutter for individual financial tracking, featuring local data queuing and automated cloud synchronization.

## Key Features
* Offline-First: Uses Room DB / Local SQLite for full functionality without network.
* Sync Queue: Caches local transactions and syncs automatically via Firebase once online.
* Real-time Backend: Integrated with Firebase Auth, Firestore, and Realtime DB.

## Tech Stack
* Flutter (Dart) | Firebase Ecosystem | macOS & Windows Compatibility

## Setup & Run

1. Clone project:
   git clone https://github.com/HelloDuongNha/expense-tracker-user.git

2. Install Packages & Dependencies:
   Navigate to the project root and run the following command to download all flutter packages and libraries:
   flutter pub get

3. Firebase Configuration:
    * For Android: Place the google-services.json file in /android/app/
    * For iOS (macOS users only): Place the GoogleService-Info.plist file in /ios/Runner/

4. Run the Application:
   Ensure you have an active emulator or connected device.
    * To run on Android Emulator / Physical Device (macOS & Windows):
      flutter run -d android
    * To run on iOS Simulator (macOS only):
      flutter run -d ios

## System Ecosystem
Administrative and Android Native dashboard repository:
https://github.com/HelloDuongNha/expense-tracker-admin.git