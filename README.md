# Smart Expense Tracker

A simple and clean Flutter app to track your daily expenses. Built with Flutter and Dart, this app allows you to add, view, and delete expenses with local storage support.

## Features

- ✅ **Welcome Screen**: Beautiful animated welcome page with smooth transitions
- ✅ **Add Expenses**: Easily add new expenses with title and amount
- ✅ **View Expenses**: See all your expenses in a clean, organized list
- ✅ **Delete Expenses**: Remove expenses you no longer need
- ✅ **Total Calculation**: Automatically calculates and displays total expenses
- ✅ **Local Storage**: All data is saved locally using SharedPreferences
- ✅ **Responsive UI**: Works perfectly on both Android and iOS
- ✅ **Clean Design**: Simple, intuitive interface for easy expense tracking

## Tech Stack

- **Flutter** - UI framework
- **Dart** - Programming language
- **SharedPreferences** - Local data storage
- **Provider** - State management (ready for future enhancements)

## Screenshots

*Screenshots will be added here*

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine
- Android Studio or VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart_expense_tracker.git
   cd smart_expense_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── expense.dart         # Expense data model
├── screens/
│   ├── welcome_screen.dart  # Beautiful welcome screen with animations
│   ├── home_screen.dart     # Main screen with expense list
│   └── add_expense_screen.dart # Form to add new expenses
└── widgets/
    └── expense_tile.dart    # Reusable expense display widget
```

## How to Use

1. **Welcome**: Launch the app to see the beautiful welcome screen with animations
2. **Start**: Tap the "Start" button to enter the main app with smooth transition
3. **Adding an Expense**: Tap the floating action button (+) to open the add expense form
4. **Viewing Expenses**: All expenses are displayed on the home screen with date and amount
5. **Deleting an Expense**: Tap the delete icon (🗑️) next to any expense to remove it
6. **Total Amount**: The total of all expenses is displayed at the top of the screen

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Pushing to GitHub

To push this project to GitHub:

1. **Create a new repository on GitHub** (don't initialize with README)

2. **Initialize git and add remote**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Smart Expense Tracker"
   git branch -M main
   git remote add origin https://github.com/yourusername/smart_expense_tracker.git
   git push -u origin main
   ```

## Future Enhancements

- 📊 Expense categories and filtering
- 📈 Charts and analytics
- 💾 Export data to CSV
- 🔄 Cloud sync support
- 🎨 Dark mode theme
- 📅 Date range filtering

## License

This project is open source and available under the [MIT License](LICENSE).

---

**Made with ❤️ using Flutter**