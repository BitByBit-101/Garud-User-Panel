# 🛡️ Garud - User Panel

Welcome to **Garud** — a smart, location-aware **transportation app** built specifically to meet the real-world challenges of **Himachal Pradesh**, with special focus on **IIT Mandi**. This repository contains the **User Panel** Flutter application, which allows passengers to book and track buses, receive emergency alerts, and improve overall campus mobility.

Garud is a **two-panel system**:
- 🧑‍💼 **Admin / Driver Panel** (separate repo)
- 🙋‍♂️ **User Panel** (this repo)

---

## 🚀 Features

- 📍 **Live Bus Tracking**
- 📅 **Bus Booking System**
- 🔔 **Emergency Notification Alerts**
- 📖 **Bus Schedules and Stops**
- 🧭 **Location-aware Services**
- ⚙️ Fully integrated with **Firebase**

---

## 🧑‍💻 Tech Stack

| Tech            | Usage                          |
|-----------------|---------------------------------|
| 🔧 Flutter       | Cross-platform mobile frontend  |
| 💙 Firebase      | Auth, Firestore, Realtime DB    |
| 🌐 Dart          | App logic & backend comms       |
| 🎯 Android/iOS   | Platform deployment             |

---

## 📲 Getting Started

### 📦 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK (comes with Flutter)
- Firebase CLI (optional, for emulators)

### 🛠️ Clone the Repo

```bash
git clone https://github.com/BitByBit-101/Garud-User-Panel.git
cd Garud-User-Panel/dp  # assuming the Flutter app is inside the "dp" folder

⚙️ Install Dependencies

flutter pub get
🔑 Firebase Setup

Make sure you’ve run:
flutterfire configure

Or copy the provided firebase_options.dart (already generated) into your lib/ folder.

Ensure your Firebase project is active and configured.

🧪 Running the App

flutter run
To run on a specific platform:

flutter run -d chrome         # for web
flutter run -d android        # for Android device/emulator
flutter run -d windows        # for Windows app


🧰 Folder Structure

Garud-User-Panel/
│
├── dp/                     # Main Flutter App Folder
│   ├── lib/                # Dart source code
│   ├── android/            # Android-specific files
│   ├── ios/                # iOS-specific files
│   ├── firebase_options.dart  # Firebase config
│   └── pubspec.yaml        # Flutter package config
│
└── README.md


🧑‍🎓 Author
Made with ❤️ by Bhumika

🧑‍💻 GitHub: BitByBit-101

🛡️ Why Garud?
Garud was built by students, for students, especially for the IIT Mandi community, which faces daily transportation challenges due to hilly terrain and remote access.

📶 Works even in poor connectivity (caches data intelligently)

🛑 Sends critical alerts to all users in real time

📍 Optimized for Himachal’s unique geography

Garud means "protector" — and this app lives up to its name.

📬 Feedback & Contributions
We welcome contributions and feedback!

Fork this repo

Create your feature branch: git checkout -b my-feature

Commit changes: git commit -m "Added feature"

Push to the branch: git push origin my-feature

Open a pull request

📜 License
This project is licensed under the MIT License.

