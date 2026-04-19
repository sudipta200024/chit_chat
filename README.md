# 💬 Chit Chat — Real-Time Flutter Chat App

A full-featured, real-time chat application built with Flutter and Firebase, supporting Google Sign-In, live messaging, user profiles, and online/offline status tracking.

---
# 💬 Chit Chat — Real-Time Flutter Chat App

![GitHub repo size](https://img.shields.io/github/repo-size/sudipta200024/chit_chat)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)

**Currently in active development** — Core messaging, Google Auth, real-time sync, read/unread, and online status are fully working.

A full-featured real-time chat application built with Flutter and Firebase...

## ✨ Features

- 🔐 **Google Sign-In** — Secure authentication via Firebase Auth
- 💬 **Real-Time Messaging** — Instant message delivery using Cloud Firestore StreamBuilder
- 🖼️ **Image & Text Messages** — Support for both text and image message types
- 👤 **User Profiles** — View and edit your profile (name, about, profile picture)
- 🟢 **Online / Offline Status** — Live last active tracking for each user
- 🔍 **User Search** — Search users by name or email in real time
- 🔔 **Push Notifications** — Firebase Cloud Messaging (FCM) for message alerts
- 📋 **Chat User List** — Displays all connected users with last message preview
- 🧹 **Clean Architecture** — Separated models, APIs, widgets, and screens

---

## 🛠️ Built With

| Technology | Purpose |
|---|---|
| Flutter & Dart | Cross-platform mobile UI |
| Firebase Auth | Google Sign-In & user management |
| Cloud Firestore | Real-time database & message storage |
| Cloudinary | Profile picture & image uploads |
| Firebase Cloud Messaging | Push notifications |
| Google Sign-In | OAuth authentication |
| Cached Network Image | Efficient image loading & caching |

---

## 📁 Project Structure

```
lib/
├── api/
│   └── apis.dart              # All Firebase API calls
├── models/
│   ├── chat_user.dart         # ChatUser data model
│   └── chat_message_model.dart # Message data model with Type enum
├── view/
│   ├── auth/
│   │   └── login_screen.dart  # Google Sign-In screen
│   ├── home_screen.dart       # User list with search
│   ├── chat_screen.dart       # Real-time chat screen
│   ├── profile_screen.dart    # User profile screen
│   └── splash_screen.dart     # Splash with auth check
├── widget/
│   ├── chat_user_card.dart    # User list item widget
│   └── message_card.dart      # Chat bubble widget (sent/received)
└── main.dart
```

---

## 🔄 App Flow

```
Splash Screen
     │
     ├── Authenticated → Home Screen (User List)
     │                        │
     │                        ├── Search Users
     │                        ├── View Profile
     │                        └── Open Chat → Chat Screen
     │                                            │
     │                                            ├── Send Text Message
     │                                            ├── Send Image Message
     │                                            └── View Online Status
     │
     └── Not Authenticated → Login Screen → Google Sign-In
```

---

## 💡 Technical Highlights

- **StreamBuilder** — Real-time UI updates from Firestore without manual refresh
- **Enum for Message Types** — `Type.text` / `Type.image` for safe type handling
- **OOP Model Classes** — `ChatUser.fromJson()` and `ChatMessageModel.fromJson()` for clean data mapping
- **`widget.` pattern** — Proper StatefulWidget data passing across screens
- **SafeArea + AppBar** — Correct status bar handling for all Android devices
- **ListView.builder** — Lazy rendering for efficient large list performance
- **`?? ''` null safety** — Safe Firestore data parsing across all fields
- **Cloudinary** — Used instead of Firebase Storage for free-tier image hosting and management

---

## 🗄️ Firestore Structure

```
users (collection)
└── {userId} (document)
    ├── id           : String
    ├── name         : String
    ├── email        : String
    ├── image        : String  (Cloudinary URL)
    ├── about        : String
    ├── created_at   : String
    ├── last_active  : String
    ├── is_online    : Boolean
    └── push_token   : String

messages (collection)
└── {conversationId} (document)
    └── messages (subcollection)
        └── {messageId} (document)
            ├── msg      : String
            ├── toId     : String
            ├── fromId   : String
            ├── read     : String
            ├── type     : String  ("text" or "image")
            └── sent     : String
```

> ⚠️ Firestore does NOT auto-create collections. You must manually create `users` and `messages` collections in your Firebase console after setup.

---

## 🚀 Setup & Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sudipta200024/chit_chat.git
   cd chit_chat
   ```

2. **Firebase Setup**
   - Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Authentication** → Google Sign-In
   - Enable **Cloud Firestore**
   - Enable **Cloud Messaging**
   - Download `google-services.json` and place it in `android/app/`
   - Create a **Cloudinary** account at [cloudinary.com](https://cloudinary.com) for image uploads

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---



---

## 👨‍💻 Author

**Sudipta Das**
Flutter App Developer

📧 sudiptadas200024@gmail.com
🔗 [LinkedIn](https://linkedin.com/in/sudipta-das2025)
🌐 [GitHub](https://github.com/sudipta200024)
