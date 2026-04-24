# 🧩 Game Sudoku

A Flutter-based Sudoku mobile application integrated with Firebase for authentication and real-time data storage.

---

## 📌 Overview

This project is a complete Sudoku game built using Flutter, demonstrating full-stack mobile development with Firebase backend services.

The app allows users to play Sudoku, track progress, save game states, and compete on leaderboards.

---

## 🚀 Features

- 🔐 User Authentication (Register / Login)
- 🎮 Sudoku gameplay (Easy / Hard modes)
- ⏱️ Real-time game timer
- 💾 Save & resume game state
- 🏆 Leaderboard (Top fastest players)
- 📜 Game history tracking

---

## 🛠️ Tech Stack

### Frontend
- Flutter (Dart)

### Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Functions (optional)

---

## 📂 Project Structure
lib/
├── screens/
├── services/
├── models/
├── widgets/
└── main.dart
## 🔄 How It Works

1. User logs in using Firebase Authentication  
2. Game is generated locally  
3. Game state is saved to Firestore  
4. Score is submitted after completion  
5. Leaderboard displays top players  

---

## ☁️ Database (Firestore)
users/
game_states/
scores/
game_history/

---

## ⚙️ Getting Started

### 1. Clone the repository

---

## ⚙️ Getting Started

### 1. Clone the repository

https://github.com/nguyenduycbhn-cmyk/gamesudoku-git

### 2. Install dependencies


flutter pub get


### 3. Setup Firebase

- Create a Firebase project
- Add Android/iOS app
- Download config files:
  - `google-services.json`
  - `GoogleService-Info.plist`
- Enable:
  - Authentication (Email/Password)
  - Firestore Database

---

### 4. Run the app


flutter run


---

## 📊 Highlights

- Clean architecture (UI - Service - Data)
- Firebase integration (Auth + Firestore)
- Scalable backend design
- Real-time data handling

---

## 🧠 Future Improvements

- Multiplayer mode
- AI Sudoku solver
- Offline support
- UI/UX enhancements

---

## 👨‍💻 Author

**Duy Nguyễn**  
Flutter Developer

---

