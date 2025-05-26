// lib/main.dart
import 'package:flutter/material.dart';
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
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'services/booking_service.dart';

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
  await firebase_core.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      // Use MultiProvider for multiple services
      providers: [
        ChangeNotifierProvider(create: (context) => UserService()),
        // ProxyProvider for BookingService because it depends on UserService
        ChangeNotifierProxyProvider<UserService, BookingService>(
          create: (context) {
            print("MultiProvider: Creating BookingService...");
            // Initial creation, gets the UserService instance via context.read
            return BookingService(context.read<UserService>());
          },
          update: (context, userService, previousBookingService) {
            print(
              "MultiProvider: Updating BookingService. User logged in: ${userService.isLoggedIn}",
            );
            // This is called whenever UserService notifies listeners.
            // We can either create a new BookingService or update the existing one.
            // If BookingService's constructor and _handleUserChange correctly
            // re-initialize state based on UserService, creating a new one is simple and safe.
            return BookingService(userService);
            //
            // --- OR --- if you want to reuse the previousBookingService instance:
            // Ensure BookingService has a method like: void updateUserService(UserService newUserService)
            // previousBookingService?..updateUserService(userService);
            // return previousBookingService ?? BookingService(userService);
          },
        ),
        // Add any other global providers here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    print(
      "MyApp build: isLoggedIn=${userService.isLoggedIn}, isLoading=${userService.isLoading}, currentUserUID=${userService.currentUser?.uid}, isAnonymous=${userService.currentUser?.isAnonymous}",
    );

    if (userService.isLoading) {
      print("MyApp: UserService is loading. Showing initial loading screen.");
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // If not loading, then userService.isLoggedIn and userService.currentUser are definitive
    String determinedInitialRoute;
    if (userService.isLoggedIn) {
      determinedInitialRoute =
          userService.currentUser!.isAnonymous ? '/' : '/user_profile';
    } else {
      // If logged out, always go to home screen
      determinedInitialRoute = '/';
    }
    print(
      "MyApp: Determined initialRoute: $determinedInitialRoute for user ${userService.currentUser?.uid}",
    );

    return MaterialApp(
      title: 'Barbershop App',
      theme: AppTheme.theme,
      initialRoute: determinedInitialRoute,
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
      debugShowCheckedModeBanner: false,
    );
  }
}
//   static const FirebaseOptions macos = FirebaseOptions(
//     apiKey: 'AIzaSyC1GXMVTL8m-RqoUMOq-JVpCL9woj-BNog', 