// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/barber_list_screen.dart';
import 'screens/barber_profile_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/user_profile_screen.dart';
import 'widgets/background_wrapper.dart';

// Add color scheme constants
class AppColors {
  static const black = Colors.black;
  static const darkGrey = Color(0xFF1A1A1A);
  static const grey = Color(0xFF333333);
  static const gold = Color(0xFFD4AF37); // Classic gold
  static const darkGold = Color(
    0xFFB4941E,
  ); // Darker gold for hover/pressed states
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tmsbjcljgoxelrkmcicg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtc2JqY2xqZ294ZWxya21jaWNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5NTU1NjUsImV4cCI6MjA1NTUzMTU2NX0.d1NebwV6YXsvicrUBAMU5I4FwD0WWYL0BknmgAIN2nI',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbershop App',
      theme: ThemeData(
        primaryColor: AppColors.black,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'sans-serif', // Use system sans-serif font
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.black,
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: AppColors.black),
          bodyMedium: TextStyle(color: AppColors.grey),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BackgroundWrapper(child: HomeScreen()),
        '/barber_list':
            (context) => BackgroundWrapper(child: BarberListScreen()),
        '/barber_profile':
            (context) => BackgroundWrapper(child: BarberProfileScreen()),
        '/booking': (context) => BackgroundWrapper(child: BookingScreen()),
        '/booking_confirmation':
            (context) => BackgroundWrapper(child: BookingConfirmationScreen()),
        '/user_profile':
            (context) => BackgroundWrapper(child: UserProfileScreen()),
      },
    );
  }
}
