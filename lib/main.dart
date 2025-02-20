// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/barber_list_screen.dart';
import 'screens/barber_profile_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/background_wrapper.dart';
import 'theme/app_theme.dart';
import 'services/user_service.dart';

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
    url: 'https://hguueqkvvtfsrcwybqmk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhndXVlcWt2dnRmc3Jjd3licW1rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5NzQ2NjUsImV4cCI6MjA1NTU1MDY2NX0.EeEoLm-I_kPaZkzSQy1rDz3da3Zs9fyWLwQkYElN8HM',
  );
  await UserService().initSession(); // Initialize user session

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbershop App',
      theme: AppTheme.theme, // Use global theme
      initialRoute: '/',
      routes: {
        '/': (context) => BackgroundWrapper(child: HomeScreen()),
        '/login': (context) => BackgroundWrapper(child: LoginScreen()),
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
