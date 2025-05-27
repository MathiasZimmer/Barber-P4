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
  // Form keys to manage form state and validation
  final _guestFormKey = GlobalKey<FormState>();
  final _userFormKey = GlobalKey<FormState>();

  // State variables to hold form data
  // These will be populated by the onSaved callbacks of TextFormFields
  String? _name; // For both guest name and new user name
  String? _email; // For new user email (and optionally guest email)
  String? _password; // For new user password

  // Loading state to handle async operations
  bool _isLoading = false;

  // Tab controller for switching between guest and new user forms
  late TabController _tabController;
  int _currentIndex = 0; // Tracks the current active tab

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with 2 tabs (Guest and Create Account)
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to handle tab changes and update state
    _tabController.addListener(() {
      // Only update if widget is mounted and tab is actually changing
      if (mounted &&
          (_tabController.indexIsChanging ||
              _tabController.index != _currentIndex)) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up tab controller resources
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Override the base class build method to describe this widget’s UI.

    // Use Provider to listen for changes in UserService (e.g., login state).
    final userService = context.watch<UserService>();
    // Read the current login status from the service.
    final isLoggedIn = userService.isLoggedIn;

    // Retrieve any arguments passed to this route (e.g., booking details).
    final routeArgs = ModalRoute.of(context)?.settings.arguments;

    // If no arguments were passed, or they’re not the expected type, show an error screen.
    if (routeArgs == null || routeArgs is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: Text('Fejl')), // AppBar with "Error" title
        body: Center(
          child: Text('Booking detaljer mangler.'),
        ), // Inform the user
      );
    }
    // At this point we know routeArgs is a Map<String, dynamic>, so assign it.
    final args = routeArgs;

    // Build the main booking confirmation UI.
    return Scaffold(
      backgroundColor:
          AppColors.darkGrey, // Set the scaffold’s background color
      appBar: AppBar(
        title: Text(
          'BEKRÆFT BOOKING',
          style: AppTheme.appBarTitleStyle, // Use a custom text style
        ),
        backgroundColor: AppColors.black, // Dark AppBar
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            Container(
              padding: const EdgeInsets.all(16.0), // Inner padding
              decoration:
                  AppTheme.goldBorderContainer, // Custom border decoration
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the left
                children: [
                  Text(
                    'Booking Detaljer:',
                    style: AppTheme.titleStyle.copyWith(
                      color: Colors.white,
                    ), // White title text
                  ),
                  const SizedBox(height: 16), // Vertical spacing

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.gold.withAlpha(
                              150,
                            ), // Semi-transparent gold border
                            width: 1.5,
                          ),
                          shape: BoxShape.circle, // Circular border shape
                        ),
                        child: CircleAvatar(
                          radius: 35, // Fixed avatar radius
                          backgroundImage: AssetImage(
                            // Choose barber image based on barberId
                            args['barberId'] ==
                                    '7d9fb269-b171-49c5-93ef-7097a99e02e3'
                                ? 'assets/barber1.jpg'
                                : 'assets/barber2.jpg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Horizontal spacing

                      Expanded(
                        // Allow this column to take remaining space
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // Display barber’s name, or 'N/A' if missing
                              'Frisør: ${args['barberName'] ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              // Format and display the booking date (DD/MM/YYYY)
                              'Dato: ${(args['date'] as DateTime).day}/${(args['date'] as DateTime).month}/${(args['date'] as DateTime).year}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              // Format and display the booking time (HH:MM)
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
              // If the user is NOT logged in, spread the following widgets into the parent list
              const SizedBox(
                height: 24,
              ), // Adds 24 pixels of vertical space before the contact section

              Container(
                // Wraps the contact form in a styled container
                padding: const EdgeInsets.all(
                  16.0,
                ), // Inner padding of 16 pixels on all sides
                decoration:
                    AppTheme
                        .goldBorderContainer, // Applies a gold-colored border and background as defined in your theme

                child: Column(
                  // Vertical layout for the contact header, tabs, and form
                  // Removed DefaultTabController, _tabController is managed by state
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start, // Align children (header text, tabs, etc.) to the start (left)

                  children: [
                    Text(
                      // Section header
                      'Kontakt Information:',
                      style: AppTheme.titleStyle.copyWith(
                        color: Colors.white,
                      ), // Use title style with overridden white color
                    ),
                    const SizedBox(
                      height: 16,
                    ), // Space between header and tab bar

                    TabBar(
                      // Tab bar widget for switching between “Guest” and “Create User”
                      controller:
                          _tabController, // Uses the externally managed TabController
                      tabs: const [
                        // Two tabs with localized labels
                        Tab(text: 'GÆST'),
                        Tab(text: 'OPRET BRUGER'),
                      ],
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ), // Bold text for selected tab labels
                      labelColor:
                          AppColors.gold, // Gold color for selected tab text
                      unselectedLabelColor:
                          Colors
                              .white70, // Semi-transparent white for unselected tabs
                      indicatorColor:
                          AppColors.gold, // Gold underline indicator color
                      indicatorWeight: 3, // Thickness of the indicator line
                    ),
                    const SizedBox(
                      height: 16,
                    ), // Space between TabBar and the form content

                    AnimatedSize(
                      // Animates changes in the child’s size (height) smoothly
                      duration: const Duration(
                        milliseconds: 300,
                      ), // Animation lasts 300ms
                      curve:
                          Curves
                              .easeInOut, // Easing curve for a natural transition

                      child: IndexedStack(
                        // Stacks all tab views but shows only the one at index _currentIndex
                        index:
                            _currentIndex, // Determines which child is visible
                        children: [
                          // Guest Tab (index 0)
                          Visibility(
                            // Wraps the guest form to preserve its state even when hidden
                            visible:
                                _currentIndex ==
                                0, // Only visible when the first tab is selected
                            maintainState:
                                true, // Keep form state alive when switching tabs

                            child: Form(
                              // Form widget to validate and save guest input
                              key:
                                  _guestFormKey, // Unique key to identify this form
                              child: Column(
                                // Layout the form fields vertically
                                mainAxisSize:
                                    MainAxisSize
                                        .min, // Shrink-wraps to contents’ height
                                children: [
                                  TextFormField(
                                    // Name input field
                                    decoration: AppTheme.inputDecoration(
                                      'Navn*',
                                    ), // Uses a standardized input decoration
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ), // White text color
                                    onSaved:
                                        (value) =>
                                            _name =
                                                value
                                                    ?.trim(), // Save trimmed name to _name variable
                                    validator: (value) {
                                      // Validate that name is not empty
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast venligst dit navn'; // Error message if validation fails
                                      }
                                      return null; // Return null if input is valid
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Space between fields

                                  TextFormField(
                                    // Email or phone input field
                                    decoration: AppTheme.inputDecoration(
                                      'Email eller Telefon*',
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) {
                                      // If input contains '@', treat as email; otherwise clear email field
                                      if (value != null &&
                                          value.trim().contains('@')) {
                                        _email = value.trim();
                                      } else {
                                        _email = null;
                                      }
                                    },
                                    validator: (value) {
                                      // Ensure the field is not left empty
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast email'; // Prompt user to enter email or phone
                                      }
                                      return null; // No error if input is present
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Sizedbox for space
                                ],
                              ),
                            ),
                          ),
                          // Create Account Tab (index 1)
                          Visibility(
                            visible:
                                _currentIndex ==
                                1, // Only show this Form when the second tab ("OPRET BRUGER") is selected
                            maintainState:
                                true, // Keep the form’s internal state (e.g., entered text) alive when switching tabs
                            child: Form(
                              key:
                                  _userFormKey, // Unique GlobalKey to identify and validate this registration form
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize
                                        .min, // Shrink-wrap the column to fit its children’s total height
                                children: [
                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Navn*', // Label and placeholder text: "Navn*" (Name, required)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ), // White text for the input
                                    onSaved:
                                        (value) =>
                                            _name =
                                                value
                                                    ?.trim(), // When form is saved, store the trimmed name into _name
                                    validator: (value) {
                                      // Validation logic for the name field
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast venligst dit navn'; // Error message if name is empty
                                      }
                                      return null; // Return null if validation passes
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Vertical spacing of 8 pixels between fields

                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Email*', // Label: "Email*" (required)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ), // White input text
                                    keyboardType:
                                        TextInputType
                                            .emailAddress, // Bring up email-optimized keyboard on mobile
                                    onSaved:
                                        (value) =>
                                            _email =
                                                value
                                                    ?.trim(), // Save the trimmed email into _email
                                    validator: (value) {
                                      // Validation logic for email field
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Indtast venligst din email'; // Error if left blank
                                      }
                                      final trimmed = value.trim();
                                      if (!trimmed.contains('@') ||
                                          !trimmed.contains('.')) {
                                        return 'Indtast venligst en gyldig email'; // Error if missing basic email structure
                                      }
                                      return null; // No error if valid format
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // Space before the password field

                                  TextFormField(
                                    decoration: AppTheme.inputDecoration(
                                      'Adgangskode* (min 6 tegn)', // Label: "Adgangskode*" with a note about min length
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ), // White text color for the password input
                                    obscureText:
                                        true, // Hide the entered text for privacy/security
                                    onSaved:
                                        (value) =>
                                            _password =
                                                value, // Save the raw password into _password
                                    validator: (value) {
                                      // Validation logic for password field
                                      if (value == null || value.isEmpty) {
                                        return 'Indtast venligst en adgangskode'; // Error if left empty
                                      }
                                      if (value.length < 6) {
                                        return 'Adgangskoden skal være mindst 6 tegn'; // Error if shorter than 6 characters
                                      }
                                      return null; // No error if password meets criteria
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ), // SizedBox for spacing
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
            const SizedBox(
              height: 24,
            ), // Adds 24 pixels of vertical space before the button section

            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                bottom: 16.0,
              ), // Adds 16px padding above and below its child
              child: Center(
                // Centers its child horizontally within the available space
                child: ElevatedButton(
                  // Apply your base gold button style
                  style: AppTheme.goldButtonStyle.copyWith(
                    // (Optional) Adjust internal padding if needed:
                    /*padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Example: reduced horizontal padding
        ),*/
                  ),
                  onPressed:
                      _isLoading
                          ? null
                          : _confirmBooking, // Disable button while loading; otherwise call _confirmBooking

                  child: Row(
                    mainAxisSize:
                        MainAxisSize
                            .min, // Shrink the Row to fit its children exactly
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center, // Center children inside the Row

                    children: <Widget>[
                      // Show a loading spinner if _isLoading, otherwise show a check icon
                      _isLoading
                          ? Container(
                            width:
                                18, // Fixed width roughly matching the icon size
                            height: 18, // Fixed height
                            margin: const EdgeInsets.only(
                              right: 8.0,
                            ), // Space between spinner and text
                            child: const CircularProgressIndicator(
                              strokeWidth: 2, // Slim spinner line
                              color:
                                  AppColors.black, // Spinner color for contrast
                            ),
                          )
                          : Icon(
                            Icons
                                .check_circle_outline, // Check-circle outline icon
                            size: 20, // Icon size
                            // Color inherits from the button’s foregroundColor (AppColors.black)
                          ),

                      if (!_isLoading) // Only add extra space when not loading
                        const SizedBox(
                          width: 8,
                        ), // 8px horizontal gap between icon and text

                      Text(
                        _isLoading
                            ? 'BEHANDLER...'
                            : 'BEKRÆFT BOOKING', // Dynamic label based on loading state
                        // If you need to override the text style, you can do so here:
                        // style: AppTheme.buttonTextStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // If there is an error message from UserService, and user is not logged in on the "Create User" tab:
            if (userService.errorMessage != null &&
                !isLoggedIn &&
                _currentIndex == 1)
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                ), // Small gap above the error text
                child: Text(
                  userService.errorMessage!, // Display the actual error message
                  style: const TextStyle(
                    color: Colors.redAccent, // Red accent color for visibility
                    fontSize: 13, // Slightly smaller font size
                  ),
                  textAlign:
                      TextAlign.center, // Center the error text horizontally
                ),
              ),
            // If BookingService has an error message, display it below the form
            if (context.watch<BookingService>().bookingError != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                ), // 8px space above the error text
                child: Text(
                  context
                      .watch<BookingService>()
                      .bookingError!, // Read and display the non-null error message
                  style: const TextStyle(
                    color:
                        Colors
                            .redAccent, // Use a red accent color to highlight the error
                    fontSize: 13, // Slightly smaller font for secondary text
                  ),
                  textAlign:
                      TextAlign.center, // Center the error text horizontally
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Confirmation button handler that performs the booking logic
  Future<void> _confirmBooking() async {
    if (!mounted) return; // If widget is no longer in the tree, abort

    final userService =
        context
            .read<
              UserService
            >(); // Get UserService without listening for changes
    final bookingService =
        context.read<BookingService>(); // Get BookingService similarly

    // Re-fetch the route arguments passed into this screen
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs == null || routeArgs is! Map<String, dynamic>) {
      // If arguments are missing or of the wrong type, show a SnackBar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking detaljer mangler. Prøv igen.',
            ), // Inform the user to try again
          ),
        );
      }
      return; // Abort further execution
    }

    // Extract and cast expected booking details from the route arguments
    final String barberId = routeArgs['barberId'] as String;
    final String? barberName = routeArgs['barberName'] as String?;
    final DateTime bookingTime = routeArgs['time'] as DateTime;
    final int serviceDuration = routeArgs['serviceDuration'] as int;
    final String serviceId =
        routeArgs['serviceId'] as String? ??
        'default_service_id'; // Provide a fallback ID if none was passed

    setState(() => _isLoading = true); // Show loading state in UI
    userService.clearError(); // Clear any prior user errors
    bookingService.clearBookingError(); // Clear prior booking errors

    AppUser? bookingUser; // Placeholder for the user making the booking

    // If the user is not logged in, we handle guest vs. registration flows
    if (!userService.isLoggedIn) {
      if (_currentIndex == 0) {
        // === Guest booking ===
        if (!_guestFormKey.currentState!.validate()) {
          // Validate guest form fields
          setState(
            () => _isLoading = false,
          ); // Stop loading if validation fails
          return;
        }
        _guestFormKey.currentState!
            .save(); // Save form inputs to _name, _email, etc.

        print(
          'BookingConfirmationScreen: Attempting to sign in anonymously for guest booking (Name: $_name)...',
        );
        bookingUser =
            await userService
                .signInAnonymously(); // Perform anonymous Firebase sign-in

        if (bookingUser == null) {
          // If sign-in failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gæst session fejlede: ${userService.errorMessage ?? 'Prøv igen'}',
                ),
              ),
            );
          }
          setState(() => _isLoading = false); // End loading state
          return;
        }

        print(
          'BookingConfirmationScreen: Guest signed in anonymously. UID: ${bookingUser.uid}',
        );

        // Optionally set the anonymous user's display name
        if (_name != null &&
            _name!.isNotEmpty &&
            (bookingUser.displayName == null ||
                bookingUser.displayName!.isEmpty)) {
          try {
            await userService.updateUserDisplayName(
              _name!,
            ); // Update Firebase displayName
            if (mounted)
              bookingUser =
                  context
                      .read<UserService>()
                      .currentUser; // Refresh local user data
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
        // === Create Account Tab ===
        if (!_userFormKey.currentState!.validate()) {
          // Validate registration form
          setState(
            () => _isLoading = false,
          ); // Stop loading on validation failure
          return;
        }
        _userFormKey.currentState!
            .save(); // Save inputs to _name, _email, _password

        print(
          'BookingConfirmationScreen: Attempting to register user with email: $_email, name: $_name',
        );
        // Use the _email, _password, and _name variables that were defined in the State class
        // Asynchronously call the registerUser method of the userService.
        // This attempts to register a new user with the provided email, password, and name.
        // The 'await' keyword pauses execution until the Future returned by registerUser completes.
        // The result (true for success, false for failure) is stored in the 'success' boolean variable.
        bool success = await userService.registerUser(
          // Pass the _email variable (non-null asserted with '!') as the email for registration.
          _email!,
          // Pass the _password variable (non-null asserted with '!') as the password for registration.
          _password!,
          // Pass the _name variable as an optional named parameter 'name' for registration.
          name: _name,
        );

        // Check if the registration was unsuccessful OR if the currentUser on userService is still null after the attempt.
        // This condition handles cases where registration failed or succeeded but didn't set the currentUser properly.
        if (!success || userService.currentUser == null) {
          // Check if the widget is still mounted in the widget tree.
          // This is a crucial check before interacting with BuildContext or calling setState in asynchronous callbacks
          // to prevent errors if the widget has been disposed.
          if (mounted) {
            // Access the ScaffoldMessenger associated with the current BuildContext and display a SnackBar.
            // SnackBars are used to show brief messages at the bottom of the screen.
            ScaffoldMessenger.of(context).showSnackBar(
              // Define the SnackBar to be displayed.
              SnackBar(
                // Set the content of the SnackBar, which is a Text widget.
                content: Text(
                  // Display an error message. "Registrering fejlede:" means "Registration failed:".
                  // It appends the specific error message from userService.errorMessage if available,
                  // otherwise, it defaults to "Prøv igen" (Try again) using the null-coalescing operator '??'.
                  'Registrering fejlede: ${userService.errorMessage ?? 'Prøv igen'}',
                ),
              ),
            );
          }
          // Update the state to set _isLoading to false, typically to hide a loading indicator.
          // setState triggers a rebuild of the widget.
          setState(() => _isLoading = false);
          // Exit the current function early as registration failed.
          return;
        }
        // If registration was successful and userService.currentUser is populated,
        // assign the newly registered/logged-in user object to the bookingUser variable.
        bookingUser = userService.currentUser;
        // Print a debug message to the console indicating successful user registration.
        print(
          // The message includes the context (BookingConfirmationScreen) and the UID of the registered user.
          // bookingUser is non-null asserted here because success implies currentUser is also not null.
          'BookingConfirmationScreen: User registered successfully. UID: ${bookingUser!.uid}',
        );
        // This curly brace likely closes an 'if' block that checks if the user was in a registration flow (e.g., if (_isRegistering)).
      }
      // This 'else' block executes if the condition of the preceding 'if' (e.g., _isRegistering) was false.
      // This implies the user is not registering now, so we check if they are already logged in.
    } else {
      // Assign the current user from userService to the bookingUser variable.
      // This assumes the user might already be logged in.
      bookingUser = userService.currentUser;
      // Check if bookingUser is null, which means no user is currently logged in via userService.
      // This is an error condition if the flow expects a logged-in user at this point.
      if (bookingUser == null) {
        // Print an error message to the console indicating an unexpected state:
        // The logic implies a user should be logged in, but currentUser is null.
        print(
          'BookingConfirmationScreen: Error - User is logged in but currentUser is null.',
        );
        // Check if the widget is still mounted before showing UI elements.
        if (mounted) {
          // Show a SnackBar to inform the user about the error.
          ScaffoldMessenger.of(context).showSnackBar(
            // Define a constant SnackBar for performance, as its content is static.
            const SnackBar(
              // Set the content of the SnackBar.
              content: Text(
                // Error message in Danish: "Error: User data not found. Try logging in again."
                'Fejl: Brugerdata ikke fundet. Prøv at logge ind igen.',
              ),
            ),
          );
        }
        // Update the state to set _isLoading to false, typically to hide a loading indicator.
        setState(() => _isLoading = false);
        // Exit the current function due to the error.
        return;
      }
      // Print a debug message indicating that the user was already logged in.
      print(
        // The message includes the context and the UID of the already logged-in user.
        // bookingUser is guaranteed to be non-null here due to the preceding null check.
        'BookingConfirmationScreen: User already logged in. UID: ${bookingUser.uid}',
      );
    }

    // Final validation check to ensure we have a valid user before proceeding
    // Check if the 'bookingUser' variable is null.
    // This is a crucial safety net to prevent errors if, despite previous checks, 'bookingUser' somehow ended up null.
    if (bookingUser == null) {
      // This comment explains that reaching this point signifies a critical failure in the preceding logic.
      // This is a final safeguard - should never happen if previous checks worked
      // Print a critical error message to the console.
      // This helps in debugging by indicating that 'bookingUser' was unexpectedly null before a critical operation.
      print(
        'BookingConfirmationScreen: Critical error - bookingUser is null before calling createAppointment.',
      );
      // Check if the widget is still mounted in the widget tree.
      // This prevents calling `ScaffoldMessenger.of(context)` or `setState` on a disposed widget, which would cause an error.
      if (mounted) {
        // Access the ScaffoldMessenger for the current BuildContext to display a SnackBar.
        // SnackBars are used for brief messages to the user.
        ScaffoldMessenger.of(context).showSnackBar(
          // Create a SnackBar widget. The 'const' keyword is used for optimization as the SnackBar's content is static.
          const SnackBar(
            // Set the content of the SnackBar, which is a Text widget.
            content: Text(
              // Display an error message to the user in Danish: "User session could not be established. Please try again."
              'Bruger session kunne ikke etableres. Prøv venligst igen.',
            ),
          ),
        );
      }
      // Update the UI state to set _isLoading to false.
      // This is typically done to hide a loading indicator.
      setState(() => _isLoading = false);
      // Exit the current function, as the required user data is missing, preventing further action.
      return;
    }

    // 'try' block to handle potential exceptions that might occur during the appointment creation process.
    try {
      //  log the initiation of the booking process.
      // Log the start of the booking creation process
      // Print a debug message to the console indicating that the 'createAppointment' method is about to be called.
      print(
        'BookingConfirmationScreen: Calling createAppointment in BookingService...',
      );

      // creating the appointment with all details.
      // It also notes how 'endTime' is calculated.
      // Create the appointment with all necessary details
      // Note: endTime is calculated by adding serviceDuration minutes to the start time
      // Asynchronously call the 'createAppointment' method on the 'bookingService' object.
      // The 'await' keyword pauses execution here until the Future returned by 'createAppointment' completes.
      await bookingService.createAppointment(
        // Pass the 'barberId' variable as the ID of the barber.
        barberId: barberId,
        // Pass the 'barberName' variable as the name of the barber.
        barberName: barberName,
        // Pass the 'serviceId' variable as the ID of the service being booked.
        serviceId: serviceId,
        // Pass the 'bookingTime' variable (presumably a DateTime object) as the start time of the appointment.
        startTime: bookingTime,
        // Calculate the end time of the appointment by adding 'serviceDuration' (in minutes) to the 'bookingTime'.
        // 'Duration(minutes: serviceDuration)' creates a Duration object representing the service's length.
        endTime: bookingTime.add(Duration(minutes: serviceDuration)),
      );
      // Print a debug message to the console indicating that the 'createAppointment' call has finished.
      print('BookingConfirmationScreen: createAppointment call completed.');

      // Check if the 'bookingService' has reported an error after the 'createAppointment' call.
      // 'bookingError' is likely a property on 'bookingService' that gets populated if something went wrong internally.
      if (bookingService.bookingError != null) {
        // Print a debug message to the console, including the specific error message from 'bookingService.bookingError'.
        print(
          'BookingConfirmationScreen: BookingService reported an error: ${bookingService.bookingError}',
        );
        // Check if the widget is still mounted before attempting to show a SnackBar.
        if (mounted) {
          // Display a SnackBar to inform the user about the booking error.
          ScaffoldMessenger.of(context).showSnackBar(
            // Create a SnackBar widget.
            SnackBar(
              // Set the content of the SnackBar to a Text widget.
              // It displays "Booking Fejl:" (Booking Error:) followed by the specific error message.
              content: Text('Booking Fejl: ${bookingService.bookingError}'),
            ),
          );
        }
      } else {
        // Booking was successful - handle different success scenarios
        print('BookingConfirmationScreen: Booking appears successful.');
        if (mounted) {
          // Default success message and navigation path
          String successMessage = 'Booking bekræftet!';
          String nextPage = '/user_profile';

          // Customize message and navigation based on user type
          if (bookingUser.isAnonymous) {
            // Guest users get a message encouraging them to create an account
            successMessage =
                'Booking bekræftet som gæst! Opret en bruger for at gemme dine bookinger.';
            nextPage = '/'; // Return to home page for guests
          } else if (_currentIndex == 1 && !bookingUser.isAnonymous) {
            // Special message for newly registered users
            successMessage = 'Bruger oprettet og booking bekræftet!';
          }

          // Show success message and navigate to appropriate page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
          Navigator.of(context).pushReplacementNamed(nextPage);
        }
      }
    } catch (e) {
      // Handle any unexpected errors during the booking process
      print(
        'BookingConfirmationScreen: Exception during booking process: ${e.toString()}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking undtagelse: ${e.toString()}')),
        );
      }
    } finally {
      // Always ensure loading state is reset, even if an error occurred
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
