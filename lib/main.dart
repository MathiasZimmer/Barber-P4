// Import core Flutter package for building material design applications
import 'package:flutter/material.dart';

// Import various screens used in the app
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/login_screen.dart';

// Custom widget that wraps screens with a background style or image
import 'widgets/background_wrapper.dart';

// Custom app-wide theme settings
import 'theme/app_theme.dart';

// Services that handle business logic related to users and bookings
import 'services/user_service.dart';

// Firebase core initialization for Flutter apps
import 'package:firebase_core/firebase_core.dart' as firebase_core;

// Firebase configuration options specific to the platform (iOS, Android, etc.)
import 'firebase_options.dart';

// Provider package for state management
import 'package:provider/provider.dart';

// Service to handle booking functionality
import 'services/booking_service.dart';

// Define custom colors used throughout the app for consistency
class AppColors {
  static const black = Colors.black;
  static const darkGrey = Color(0xFF1A1A1A);
  static const grey = Color(0xFF333333);
  static const gold = Color(0xFFD4AF37); // Classic gold color for branding
  static const darkGold = Color(
    0xFFB4941E,
  ); // Darker gold for hover/pressed UI states
}

void main() async {
  // Ensure Flutter engine is properly initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the platform-specific options
  await firebase_core.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the Flutter app and inject providers for state management
  runApp(
    MultiProvider(
      // MultiProvider allows multiple providers to be registered at once
      providers: [
        // Register UserService as a ChangeNotifier provider
        ChangeNotifierProvider(create: (context) => UserService()),

        // ProxyProvider allows BookingService to depend on UserService
        ChangeNotifierProxyProvider<UserService, BookingService>(
          create: (context) {
            print("MultiProvider: Creating BookingService...");
            // BookingService is created with a reference to the current UserService
            return BookingService(context.read<UserService>());
          },
          update: (context, userService, previousBookingService) {
            print(
              "MultiProvider: Updating BookingService. User logged in: ${userService.isLoggedIn}",
            );
            // Whenever UserService changes, update or recreate BookingService
            return BookingService(userService);
          },
        ),

        // Additional global providers can be added here if needed
      ],
      // Launch the main application widget
      child: const MyApp(),
    ),
  );
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch UserService to get updates about user login state
    final userService = context.watch<UserService>();

    // Log user authentication state to the console
    print(
      "MyApp build: isLoggedIn=${userService.isLoggedIn}, isLoading=${userService.isLoading}, currentUserUID=${userService.currentUser?.uid}, isAnonymous=${userService.currentUser?.isAnonymous}",
    );

    // If user data is still loading, show a loading spinner
    if (userService.isLoading) {
      print("MyApp: UserService is loading. Showing initial loading screen.");
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Once loading is complete, decide which screen to show first
    String determinedInitialRoute;

    if (userService.isLoggedIn) {
      // If logged in, send anonymous users to home, others to user profile
      determinedInitialRoute =
          userService.currentUser!.isAnonymous ? '/' : '/user_profile';
    } else {
      // If not logged in, go to home screen
      determinedInitialRoute = '/';
    }

    // Log which screen the app will navigate to first
    print(
      "MyApp: Determined initialRoute: $determinedInitialRoute for user ${userService.currentUser?.uid}",
    );

    // Return the configured MaterialApp with routes and themes
    return MaterialApp(
      title: 'Barbershop App', // Title shown in app switcher
      theme: AppTheme.theme, // Custom theme settings
      initialRoute: determinedInitialRoute, // First screen to display
      // Define all the app routes and wrap each screen in a background
      routes: {
        '/': (context) => BackgroundWrapper(child: HomeScreen()),
        '/login': (context) => BackgroundWrapper(child: LoginScreen()),
        '/booking': (context) => BackgroundWrapper(child: BookingScreen()),
        '/booking_confirmation':
            (context) => BackgroundWrapper(child: BookingConfirmationScreen()),
        '/user_profile':
            (context) => BackgroundWrapper(child: UserProfileScreen()),
      },

      // Hide the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,
    );
  }
}
