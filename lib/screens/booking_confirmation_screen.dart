// lib/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure this is imported
import '../main.dart'; // For AppColors if used
import '../services/booking_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  final _guestFormKey = GlobalKey<FormState>();
  final _userFormKey = GlobalKey<FormState>();

  // State variables to hold form data
  // These will be populated by the onSaved callbacks of TextFormFields
  String? _name; // For both guest name and new user name
  String? _email; // For new user email (and optionally guest email)
  String? _password; // For new user password

  bool _isLoading = false;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.indexIsChanging ||
          _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access userService via Provider to get the correct isLoggedIn state
    final userService = context.watch<UserService>();
    final isLoggedIn =
        userService.isLoggedIn; // Use the Provider-managed instance

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs == null || routeArgs is! Map<String, dynamic>) {
      // Handle missing arguments, perhaps by navigating back or showing an error
      return Scaffold(
        appBar: AppBar(title: Text('Fejl')),
        body: Center(child: Text('Booking detaljer mangler.')),
      );
    }
    final args = routeArgs; // No cast needed due to the check above

    return Scaffold(
      backgroundColor: AppColors.darkGrey, // Or from your theme
      appBar: AppBar(
        title: Text('BEKRÆFT BOOKING', style: AppTheme.appBarTitleStyle),
        backgroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.goldBorderContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Detaljer:',
                    style: AppTheme.titleStyle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.gold.withAlpha(150),
                            width: 1.5,
                          ),
                          shape:
                              BoxShape.circle, // Ensure circle shape for avatar
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            args['barberId'] ==
                                    '7d9fb269-b171-49c5-93ef-7097a99e02e3'
                                ? 'assets/barber1.jpg' // Ensure these assets exist
                                : 'assets/barber2.jpg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frisør: ${args['barberName'] ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Dato: ${(args['date'] as DateTime).day}/${(args['date'] as DateTime).month}/${(args['date'] as DateTime).year}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Tid: ${(args['time'] as DateTime).hour.toString().padLeft(2, '0')}:${(args['time'] as DateTime).minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isLoggedIn) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: AppTheme.goldBorderContainer,
                child: Column(
                  // Removed DefaultTabController, _tabController is managed by state
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontakt Information:',
                      style: AppTheme.titleStyle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'GÆST'),
                        Tab(text: 'OPRET BRUGER'),
                      ],
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      labelColor: AppColors.gold,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: AppColors.gold,
                      indicatorWeight: 3,
                    ),
                    const SizedBox(height: 16),
                    AnimatedSize(
                      // For smooth height transition
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: IndexedStack(
                        // Use IndexedStack for better performance with TabBarView
                        index: _currentIndex,
                        children: [
                          // Guest Tab (index 0)
                          Visibility(
                            // Ensures form state is preserved
                            visible: _currentIndex == 0,
                            maintainState: true,
                            child: Form(
                              key: _guestFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Navn*',
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) => _name = value?.trim(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast venligst dit navn';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Email eller Telefon*',
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) {
                                      if (value != null &&
                                          value.trim().contains('@')) {
                                        _email =
                                            value
                                                .trim(); // Use _email for guest if they provide email
                                        null;
                                      } else {
                                        value?.trim();
                                        _email =
                                            null; // Clear _email if phone is provided
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Add some bottom padding
                                ],
                              ),
                            ),
                          ),
                          // Create Account Tab (index 1)
                          Visibility(
                            visible: _currentIndex == 1,
                            maintainState: true,
                            child: Form(
                              key: _userFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Navn*',
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) => _name = value?.trim(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast venligst dit navn';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Email*',
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (value) => _email = value?.trim(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast venligst din email';
                                      }
                                      if (!value.trim().contains('@') ||
                                          !value.trim().contains('.')) {
                                        return 'Indtast venligst en gyldig email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Adgangskode* (min 6 tegn)',
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    obscureText: true,
                                    onSaved: (value) => _password = value,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Indtast venligst en adgangskode';
                                      }
                                      if (value.length < 6) {
                                        return 'Adgangskoden skal være mindst 6 tegn';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Add some bottom padding
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Center(
                child: ElevatedButton(
                  // Apply your base gold button style
                  style: AppTheme.goldButtonStyle.copyWith(
                    // You might want to adjust the padding here slightly if the Row's internal
                    // spacing is different from what ElevatedButton.icon provides by default.
                    // Start with the original padding or slightly less horizontal padding.
                    /*padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ), // Example: reduced horizontal
                    ),*/
                  ),
                  onPressed: _isLoading ? null : _confirmBooking,
                  child: Row(
                    mainAxisSize:
                        MainAxisSize
                            .min, // Important: Row takes minimum space needed
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center, // Center content within the button
                    children: <Widget>[
                      // Conditional Icon or Loading Indicator
                      _isLoading
                          ? Container(
                            width: 18, // Should match icon size approximately
                            height: 18,
                            margin: const EdgeInsets.only(
                              right: 8.0,
                            ), // Space between loader and text
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  AppColors
                                      .black, // Use AppColors.black for consistency
                            ),
                          )
                          : Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            // Color will be inherited from button's foregroundColor (AppColors.black from goldButtonStyle)
                          ),
                      // Explicit spacing if not using a loader with margin
                      if (!_isLoading) const SizedBox(width: 8),

                      // Label Text
                      Text(
                        _isLoading ? 'BEHANDLER...' : 'BEKRÆFT BOOKING',
                        // The style for this text should ideally come from AppTheme.goldButtonStyle.textStyle
                        // If you override it here, ensure it's intentional.
                        // style: AppTheme.buttonTextStyle.copyWith(fontWeight: FontWeight.bold), // Example from AppTheme
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Display error message from UserService if any (e.g. registration failed)
            if (userService.errorMessage != null &&
                !isLoggedIn &&
                _currentIndex == 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  userService.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            // Display error message from BookingService if any
            if (context.watch<BookingService>().bookingError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  context.watch<BookingService>().bookingError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (!mounted) return;
    final userService = context.read<UserService>();
    final bookingService = context.read<BookingService>();

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs == null || routeArgs is! Map<String, dynamic>) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking detaljer mangler. Prøv igen.')),
        );
      }
      return;
    }
    // final args = routeArgs; // No cast needed here due to the check above
    // More specific casting for clarity, assuming these keys exist and have these types
    final String barberId = routeArgs['barberId'] as String;
    final String? barberName = routeArgs['barberName'] as String?;
    final DateTime bookingTime = routeArgs['time'] as DateTime;
    final int serviceDuration = routeArgs['serviceDuration'] as int;
    final String serviceId =
        routeArgs['serviceId'] as String? ??
        'default_service_id'; // Ensure serviceId is passed

    setState(() => _isLoading = true);
    userService.clearError();
    bookingService.clearBookingError();

    AppUser? bookingUser;

    if (!userService.isLoggedIn) {
      if (_currentIndex == 0) {
        // Guest Tab
        if (!_guestFormKey.currentState!.validate()) {
          setState(() => _isLoading = false);
          return;
        }
        _guestFormKey.currentState!
            .save(); // Saves to _name, _email (if email provided), _phone
        print(
          'BookingConfirmationScreen: Attempting to sign in anonymously for guest booking (Name: $_name)...',
        );
        bookingUser = await userService.signInAnonymously();

        if (bookingUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gæst session fejlede: ${userService.errorMessage ?? 'Prøv igen'}',
                ),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
        print(
          'BookingConfirmationScreen: Guest signed in anonymously. UID: ${bookingUser.uid}',
        );
        // Optionally update anonymous user's display name if _name is provided
        if (_name != null &&
            _name!.isNotEmpty &&
            (bookingUser.displayName == null ||
                bookingUser.displayName!.isEmpty)) {
          try {
            await userService.updateUserDisplayName(
              _name!,
            ); // This is a FirebaseAuth.User method
            // Re-fetch AppUser to get updated displayName if your AppUser doesn't auto-update
            if (mounted) bookingUser = context.read<UserService>().currentUser;
            print(
              'BookingConfirmationScreen: Updated anonymous user display name to: $_name',
            );
          } catch (e) {
            print(
              'BookingConfirmationScreen: Failed to update anonymous user display name: $e',
            );
          }
        }
      } else {
        // Create Account Tab
        if (!_userFormKey.currentState!.validate()) {
          setState(() => _isLoading = false);
          return;
        }
        _userFormKey.currentState!.save(); // Saves to _name, _email, _password
        print(
          'BookingConfirmationScreen: Attempting to register user with email: $_email, name: $_name',
        );
        // Use the _email, _password, and _name variables that were defined in the State class
        bool success = await userService.registerUser(
          _email!,
          _password!,
          name: _name,
        );

        if (!success || userService.currentUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registrering fejlede: ${userService.errorMessage ?? 'Prøv igen'}',
                ),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
        bookingUser = userService.currentUser;
        print(
          'BookingConfirmationScreen: User registered successfully. UID: ${bookingUser!.uid}',
        );
      }
    } else {
      bookingUser = userService.currentUser;
      if (bookingUser == null) {
        print(
          'BookingConfirmationScreen: Error - User is logged in but currentUser is null.',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fejl: Brugerdata ikke fundet. Prøv at logge ind igen.',
              ),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      print(
        'BookingConfirmationScreen: User already logged in. UID: ${bookingUser.uid}',
      );
    }

    if (bookingUser == null) {
      // This is a final safeguard
      print(
        'BookingConfirmationScreen: Critical error - bookingUser is null before calling createAppointment.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bruger session kunne ikke etableres. Prøv venligst igen.',
            ),
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      print(
        'BookingConfirmationScreen: Calling createAppointment in BookingService...',
      );
      await bookingService.createAppointment(
        barberId: barberId,
        barberName: barberName,
        serviceId: serviceId,
        startTime: bookingTime,
        endTime: bookingTime.add(Duration(minutes: serviceDuration)),
      );
      print('BookingConfirmationScreen: createAppointment call completed.');

      if (bookingService.bookingError != null) {
        print(
          'BookingConfirmationScreen: BookingService reported an error: ${bookingService.bookingError}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking Fejl: ${bookingService.bookingError}'),
            ),
          );
        }
      } else {
        print('BookingConfirmationScreen: Booking appears successful.');
        if (mounted) {
          String successMessage = 'Booking bekræftet!';
          String nextPage = '/user_profile';

          if (bookingUser.isAnonymous) {
            successMessage =
                'Booking bekræftet som gæst! Opret en bruger for at gemme dine bookinger.';
            nextPage = '/';
          } else if (_currentIndex == 1 && !bookingUser.isAnonymous) {
            successMessage = 'Bruger oprettet og booking bekræftet!';
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
          Navigator.of(context).pushReplacementNamed(nextPage);
        }
      }
    } catch (e) {
      print(
        'BookingConfirmationScreen: Exception during booking process: ${e.toString()}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking undtagelse: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} // THIS IS THE END OF THE _BookingConfirmationScreenState CLASS
