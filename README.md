# 🔒 Impulse Control

> **Stop the 1-click economy. Every purchase you want enters a mandatory 48-hour cooling off queue.**

A smart, beautifully designed Flutter app that helps you fight impulse buying by forcing a 48-hour waiting period before you can buy anything. If you still want it after 48 hours, go ahead — but most of the time, you won't.

---

## ✨ Flagship Features (2026 Edition)

### 🧠 The Anti-Impulse Engine
- **Adaptive Cooling Queue** — Dynamic timers (24h, 48h, 72h, or 7 Days) automatically scaled to the purchase price to let dopamine subside.
- **⚡ Life Energy Calculator** — Enter your hourly wage once; every item instantly translates into the exact hours or workdays of your life needed to pay for it.
- **📈 20-Year Opportunity Cost** — Live projection of what that money would grow into at an 8% index return (e.g., "$150 today = $699 in 20 yrs").
- **🛡️ 15-Second Reality Check** — Before locking an item, an interactive interrogation challenges you: *Will you care in 3 months? Do you already own something similar?*
- **✨ AI Devil's Advocate** — Optional Groq (LLaMA 3.1) or Google Gemini integration for instant, witty roasts and reality checks. Works **100% offline** with built-in heuristic templates if no API key is provided.
- **🏆 Victory & Brag Cards** — Whenever you pass on a purchase, celebrate with a sleek shareable card showing dollars and work hours saved.

### 🎨 Premium UI/UX
- **Category System** — Tag items with icons (💻 Tech, 👕 Fashion, 🎧 Gadgets, 🎮 Gaming, 🍔 Dining, 📚 Books).
- **Cooling Progress Indicator** — Visual progress bars on each card tracking elapsed cooling time.
- **Hero Image Cards** — Paste an image URL to render rich dynamic backgrounds with gradient overlays.
- **Desire Level Badges** — Rate impulse urgency Low / Medium / High with reactive color-coded borders.
- **Dark Mode & Light Mode** — Seamless toggle between sleek dark neon aesthetic and clean professional light mode.

### 🌍 Global Ready & 100% Private
- **Zero Server Costs & Local-First** — Your financial data stays entirely on your device. Zero servers to maintain, zero privacy tracking.
- **Dynamic Currency Picker** — Searchable offline database with 150+ global currencies (NGN ₦, EUR €, GBP £, USD $, and more).
- **Persistent Preferences** — Themes, hourly wage, currency, and AI keys are remembered across sessions.

### 🔔 Smart Notifications *(Android & iOS)*
- **Halfway Reminder** — "Halfway through your cooling period! Still thinking about it?"
- **1-Hour Warning** — "Almost time to decide."
- **Unlock Alert** — "Your item is ready! Buy it or pass and save?"
- Notifications automatically cancel when you decide early.

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