# 🔒 Impulse Control

> **Stop the 1-click economy. Every purchase you want enters a mandatory 48-hour cooling off queue.**

A smart, beautifully designed Flutter app that helps you fight impulse buying by forcing a 48-hour waiting period before you can buy anything. If you still want it after 48 hours, go ahead — but most of the time, you won't.

---

## ✨ Features

### 🧠 The Core Mechanic
- **48-Hour Cooling Queue** — Add any item you want to buy. It locks for 48 hours with a live countdown timer.
- **Buy or Pass** — Once unlocked, you decide. Hit "Pass" and the money is counted as saved.
- **Money Saved Dashboard** — A real-time total of every purchase you successfully passed on.

### 🎨 Premium UI/UX
- **Dark Mode & Light Mode** — Toggle between a sleek dark neon aesthetic and a clean professional light mode.
- **Hero Image Cards** — Paste an image URL when adding an item and the card renders it as a beautiful background with gradient overlay.
- **Desire Level Badges** — Rate your impulse Low / Medium / High. Cards color-code themselves (green, orange, red) to reflect your urgency.

### 🌍 Global Ready
- **Dynamic Currency Picker** — On first launch, pick your local currency from a searchable offline database (NGN ₦, EUR €, GBP £, USD $, and 150+ more). No APIs. No costs.
- **Persistent Settings** — Your theme and currency choices are saved locally and remembered across sessions.

### 🔔 Smart Notifications *(Android & iOS)*
- **24-Hour Reminder** — "Halfway there! Still thinking about it?"
- **1-Hour Warning** — "Almost time to decide."
- **Unlock Alert** — "Your item is ready! Buy it or pass and save?"
- Notifications are **automatically cancelled** if you decide early.

---

## 📸 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Provider (`ChangeNotifier`) |
| Local Storage | `shared_preferences` |
| Notifications | `flutter_local_notifications` + `timezone` |
| Currency Data | `currency_picker` |
| ID Generation | `uuid` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`^3.9.0`)
- Dart SDK (`^3.9.0`)
- A connected device, emulator, or Chrome browser

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/impulse-control.git

# Navigate into the project
cd impulse-control

# Install dependencies
flutter pub get

# Run the app (Chrome for web, or connect a device)
flutter run -d chrome
```

> **Windows Users**: Ensure **Developer Mode** is enabled in Settings → System → Developer Settings before running `flutter pub get`.

---

## 🗂️ Project Structure

```
lib/
├── main.dart                  # App entry point, theme engine
├── settings_provider.dart     # Global state: theme + currency
├── models/
│   └── wish_item.dart         # WishItem data model (with DesireLevel)
├── screens/
│   ├── welcome_screen.dart    # Animated landing + currency onboarding
│   ├── home_screen.dart       # Main dashboard + queue
│   └── add_wish_screen.dart   # Add item form
├── widgets/
│   └── wish_tile.dart         # Rich card with countdown timer
└── services/
    └── notification_service.dart  # Local notification scheduling
```

---

## 🗺️ Roadmap

- [ ] Analytics screen (spending habits over time)
- [ ] Category tags for wish items
- [ ] Social sharing ("I just saved $X on a [item]!")
- [ ] Export/import queue as JSON
- [ ] Widget for home screen (Android/iOS)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Made with ❤️ using Flutter** — *Because your wallet deserves a bodyguard.*