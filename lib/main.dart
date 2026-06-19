import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'settings_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const ImpulseControlApp(),
    ),
  );
}

class ImpulseControlApp extends StatelessWidget {
  const ImpulseControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Impulse Control',
          themeMode: settingsProvider.themeMode,
          // Light Theme: Clean, professional, Apple/Stripe inspired
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F9FC),
            primaryColor: const Color(0xFF2C3E50),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF), // iOS Blue
              secondary: Color(0xFF34C759), // iOS Green
              surface: Colors.white,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
              titleTextStyle: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Dark Theme: Sleek, neon accents, glassmorphism
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF12121D),
            primaryColor: const Color(0xFF00E5FF), // Neon Blue
            cardColor: const Color(0xFF1E1E2C),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E5FF),
              secondary: Color(0xFF39FF14), // Neon Green
              surface: Color(0xFF1E1E2C),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: const WelcomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}