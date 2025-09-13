# 🛡️ Garud - User Panel

Welcome to **Garud** — a smart, location-aware **transportation app** built specifically to meet the real-world challenges of **Himachal Pradesh**, with special focus on **IIT Mandi**.  

This repository contains the **User Panel** Flutter application, which allows passengers to:  
- 🚍 Book and track buses in real-time  
- 🔔 Receive emergency alerts instantly  
- 📍 Access schedules and stops with location-aware services  

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
- ⚙️ Integrated with **Firebase**  

---

## 🎥 Demo Video

👉 [Watch Demo](https://drive.google.com/uc?id=YOUR_DEMO_VIDEO_ID&export=download)

---

## 📸 Demo Photos

<p align="center">
  <img src="dp/assets/demo/demo1.png" width="30%" style="margin: 10px;" />
  <img src="dp/assets/demo/demo2.png" width="30%" style="margin: 10px;" />
  <img src="dp/assets/demo/demo3.png" width="30%" style="margin: 10px;" />
</p>

---

## 🧑‍💻 Tech Stack

| Tech        | Usage                          |
|-------------|--------------------------------|
| 🔧 Flutter  | Cross-platform mobile frontend  |
| 💙 Firebase | Auth, Firestore, Realtime DB    |
| 🌐 Dart     | App logic & backend comms       |
| 🎯 Android/iOS | Platform deployment          |

---

## 📲 Getting Started

### 📦 Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)  
- Dart SDK (comes with Flutter)  
- Firebase CLI (optional, for emulators)  

### 🛠️ Clone the Repo
```bash
git clone https://github.com/BitByBit-101/Garud-User-Panel.git
cd Garud-User-Panel/dp
```

### ⚙️ Install Dependencies
```bash
flutter pub get
```

### 🔑 Firebase Setup
- Run:
  ```bash
  flutterfire configure
  ```
- Or copy the provided `firebase_options.dart` into your `lib/` folder.  
- Ensure your Firebase project is active and configured.  

### 🧪 Running the App
```bash
flutter run
```
To run on a specific platform:
```bash
flutter run -d chrome      # Web
flutter run -d android     # Android device/emulator
flutter run -d windows     # Windows app
```

---

## 🧰 Folder Structure

```
Garud-User-Panel/
│
├── dp/                        # Main Flutter App Folder
│   ├── lib/                   # Dart source code
│   ├── android/               # Android-specific files
│   ├── ios/                   # iOS-specific files
│   ├── firebase_options.dart  # Firebase config
│   └── pubspec.yaml           # Flutter package config
│
└── README.md
```

---

## 🛡️ Why Garud?

Garud was built **by students, for students**, especially for the **IIT Mandi community**, which faces daily transportation challenges due to hilly terrain and remote access.  

- 📶 Works even in poor connectivity (caches data intelligently)  
- 🛑 Sends critical alerts to all users in real time  
- 📍 Optimized for Himachal’s unique geography  

The name **Garud** means *protector* — and this app lives up to its name.  

---

## 🧑‍🎓 Author

Made with ❤️ by **Bhumika**  

- 🧑‍💻 GitHub: [BitByBit-101](https://github.com/BitByBit-101)  

---

## 📬 Feedback & Contributions

We welcome contributions and feedback!  

1. Fork this repo  
2. Create your feature branch:  
   ```bash
   git checkout -b my-feature
   ```
3. Commit your changes:  
   ```bash
   git commit -m "Added feature"
   ```
4. Push to the branch:  
   ```bash
   git push origin my-feature
   ```
5. Open a pull request  

---

## 📜 License

This project is licensed under the **MIT License**.
