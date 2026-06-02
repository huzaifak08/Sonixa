# 🎵 Sonixa

A premium, elegantly crafted offline MP3 music player built with Flutter. Designed for audiophiles who value privacy, simplicity, and fluid visual design.

**No ads. No tracking. No login required.**

---

## ✨ Visual Preview

Experience a clean dark-mode interface styled with glassmorphism blending seamlessly into deep-sea ambient gradients.

```text
┌───────────────────────────────────┐
│  Sonixa                           │  ◄── Fluid Minimal App Bar
├───────────────────────────────────┤
│ 📊 Total Songs   ⏳ Playing Time  │  ◄── Real-time Analytics Metric Cards
│      1,247            84h 12m     │
├───────────────────────────────────┤
│  [ All ]    [ Recent ]   [ Favs ] │  ◄── Custom Segmented Filter Track
├───────────────────────────────────┤
│  🎵 Blinding Lights               │  ◄── Dynamic Song List Rows
│  🎵 Starboy                       │      (With real-time animated soundwaves)
├───────────────────────────────────┤
│  ▶ Now Playing...           ⏭  ⏮ │  ◄── Synchronized Bottom Mini Player
└───────────────────────────────────┘
```

---

## 🚀 Key Features

### ⚡ Instant Native Scanning

Queries the Android MediaStore architecture directly via native channels to instantly synchronize your local audio library.

### 🎚 Modern Soundwave Indicator

Displays real-time animated equalizer waves on the currently playing track for an immersive playback experience.

### 🔁 Continuous Playback

Supports automatic song advancement, repeat modes, and shuffle playback powered by a centralized audio service layer.

### 📈 Dynamic Library Analytics

Automatically calculates and displays:

- Total number of songs
- Combined playback duration
- Library insights in real time

### 🔒 100% Private & Clean

- No analytics
- No tracking
- No advertisements
- No account creation
- Fully offline functionality

---

## 🛠 Architecture Overview

Sonixa follows a modern, decoupled multi-layer architecture optimized for performance and maintainability.

### State Management

Powered by **Riverpod 2.0** with code generation using persistent `AsyncNotifier` patterns to efficiently cache and manage local data.

### Playback Pipeline

Built on top of **just_audio** for:

- Smooth playback
- Position streaming
- Background audio support
- Queue management

### Native Interface Layer

Utilizes asynchronous **Kotlin Method Channels** to query Android MediaStore APIs and retrieve audio metadata without blocking UI rendering.

---

## 📦 Installation & Setup

### Prerequisites

- Flutter SDK **3.22.0+**
- Android SDK **API 21+**
- Android device or emulator

---

### Step 1: Clone the Repository

```bash
git clone https://github.com/huzaifak08/Sonixa.git
cd Sonixa
```

---

### Step 2: Install Dependencies

```bash
flutter pub get
```

---

### Step 3: Generate Riverpod Code

Generate the required provider files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Step 4: Launch the Application

```bash
flutter run
```

---

## 🔒 Permissions

Sonixa requests only the permissions necessary to access local audio files.

### Android 12 and Below

```xml
READ_EXTERNAL_STORAGE
```

Used to access music stored on the device.

### Android 13 and Above

```xml
READ_MEDIA_AUDIO
```

Complies with Android's modern privacy-focused media permission model.

---

## 📚 Tech Stack

| Technology             | Purpose                     |
| ---------------------- | --------------------------- |
| Flutter                | Cross-platform UI Framework |
| Riverpod 2.0           | State Management            |
| just_audio             | Audio Playback Engine       |
| Kotlin Method Channels | Native Android Integration  |
| MediaStore API         | Local Music Discovery       |
| build_runner           | Code Generation             |

---

## 🎯 Design Philosophy

Sonixa is built around three principles:

- **Privacy First** — Your music never leaves your device.
- **Performance Focused** — Native media scanning and efficient state management.
- **Minimal Elegance** — A distraction-free listening experience with modern UI aesthetics.

---

## ❤️ Why Sonixa?

Most music players are cluttered with ads, tracking systems, subscriptions, and unnecessary complexity.

Sonixa takes a different approach:

- Own your music
- Keep your privacy
- Enjoy a beautiful interface
- Listen without interruptions

Just open the app and play.

---

## 📄 License

This project is licensed under the MIT License. Feel free to use, modify, and contribute.

---

**Built with Flutter 💙**
