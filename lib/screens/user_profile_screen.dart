// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/booking_service.dart'; // For Booking class and service type
import '../services/user_service.dart'; // For AppUser and service type
import '../main.dart'; // For AppColors
import '../theme/app_theme.dart';

// Defines a new class named UserProfileScreen that extends StatefulWidget.
// StatefulWidget is used for widgets whose state can change over time (e.g., due to user interaction or data fetching).
class UserProfileScreen extends StatefulWidget {
  // Defines a constant constructor for UserProfileScreen.
  // The 'key' parameter is passed to the superclass (StatefulWidget) constructor.
  // Keys are used by Flutter to identify and differentiate widgets, especially in lists or when widgets are moved around the tree.
  const UserProfileScreen({super.key});

  // Overrides the createState method from StatefulWidget.
  // This method is called by the Flutter framework to create the mutable state object associated with this widget.
  @override
  // Returns an instance of _UserProfileScreenState, which will manage the state for UserProfileScreen.
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

// Defines the state class for UserProfileScreen, named _UserProfileScreenState.
// It extends State<UserProfileScreen>, linking it to the UserProfileScreen widget.
class _UserProfileScreenState extends State<UserProfileScreen> {
  // Overrides the initState method from the State class.
  // This method is called once when the stateful widget is inserted into the widget tree.
  // It's typically used for one-time initialization tasks, like setting up listeners or fetching initial data.
  @override
  void initState() {
    // Calls the initState method of the superclass (State). It's crucial to call this first.
    super.initState();
    // This comment explains the rationale for the code within addPostFrameCallback:
    // to fetch bookings if they haven't been loaded, especially if the user navigates directly
    // to this screen or returns to it after the app was in the background.
    // Fetch initial bookings if not already loaded by BookingService's listener
    // This ensures data is loaded if the user navigates directly to this screen
    // after the app has been in the background.
    // Schedules a callback to be executed after the current frame has been rendered.
    // This is useful for performing actions that depend on the widget tree being fully built or need access to BuildContext safely.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Retrieves an instance of UserService from the widget tree using Provider's `context.read`.
      // `context.read` is used for one-time reads of a provider, typically in callbacks like initState or event handlers.
      final userService = context.read<UserService>();
      // Checks if the user is currently logged in by accessing the 'isLoggedIn' property of the userService.
      if (userService.isLoggedIn) {
        // This comment clarifies the use of context.read for a one-time action.
        // Use context.read for one-time action
        // Retrieves an instance of BookingService using `context.read` and calls its `fetchUserBookings` method.
        // This initiates the fetching of bookings associated with the current user.
        context.read<BookingService>().fetchUserBookings();
      } else {
        // This comment explains that this 'else' block is a defensive measure, as correct routing should prevent this state.
        // Should not happen if routing is correct, but handle defensively
        // Checks if the widget is still mounted (i.e., part of the widget tree).
        // This is important before performing navigation or showing UI elements to avoid errors if the widget was disposed.
        if (mounted) {
          // Navigates to the '/login' route and removes all previous routes from the navigation stack.
          // `(route) => false` ensures that all routes below the new '/login' route are removed.
          // This is typically done when the user is not authenticated and needs to be redirected to the login screen.
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    });
  }

  // Defines an asynchronous method named _performLogout that returns a Future<void> (i.e., no return value).
  // This method will handle the user logout process.
  Future<void> _performLogout() async {
    // Retrieves an instance of UserService from the widget tree using `context.read`.
    // This instance will be used to call the logout method.
    final userService = context.read<UserService>();
    // Starts a 'try' block to handle potential exceptions that might occur during the logout process.
    try {
      // Prints a debug message to the console indicating that the logout process is starting.
      print("UserProfileScreen: Calling userService.logout()");
      // Asynchronously calls the 'logout' method on the userService instance.
      // The 'await' keyword pauses execution until the logout operation completes.
      await userService.logout();
      // Prints a debug message to the console indicating that the logout method has completed.
      // It also logs the current login status (which should be false after a successful logout).
      print(
        "UserProfileScreen: userService.logout() completed. User logged out: ${!userService.isLoggedIn}",
      );

      // This comment explains the next step: navigating to the home screen after logout.
      // After logout, navigate to home screen
      // Checks if the widget is still mounted before attempting navigation.
      if (mounted) {
        // Navigates to the '/' (home) route and removes all previous routes from the navigation stack.
        // This ensures the user cannot go back to the profile screen after logging out.
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        // Prints a debug message indicating successful navigation to the home screen.
        print("UserProfileScreen: Navigated to '/' after logout.");
      }
      // Catches any exceptions (e) that occur within the 'try' block.
    } catch (e) {
      // Prints an error message to the console, including the exception details.
      print("UserProfileScreen: Error during logout: $e");
      // Checks if the widget is still mounted before showing a SnackBar.
      if (mounted) {
        // Accesses the ScaffoldMessenger to display a SnackBar with an error message.
        ScaffoldMessenger.of(context).showSnackBar(
          // Creates a SnackBar widget to show the logout failure message.
          SnackBar(
            // Sets the content of the SnackBar, which is a Text widget.
            content: Text(
              // Displays an error message in Danish: "Logout failed:" followed by the error string.
              'Logout fejlede: ${e.toString()}',
              // Sets the style for the text, making it white.
              style: const TextStyle(color: Colors.white),
            ),
            // Sets the background color of the SnackBar to redAccent to indicate an error.
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Defines an asynchronous method named _performCancelBooking that takes a String 'bookingId' as a parameter.
  // This method is responsible for handling the logic to cancel a booking.
  // It returns a Future<void>, indicating that it performs an asynchronous operation and does not return a value.
  Future<void> _performCancelBooking(String bookingId) async {
    // This comment indicates that the BookingService instance is being retrieved using Provider.
    // Get the BookingService from Provider
    // Retrieves an instance of BookingService from the widget tree using `context.read<BookingService>()`.
    // `context.read` is used here because this is a one-time action within an event handler,
    // and we don't need this specific part of the code to rebuild if BookingService changes.
    final bookingService = context.read<BookingService>();
    // Starts a 'try' block to handle potential exceptions that might occur during the booking cancellation process.
    try {
      // Prints a debug message to the console indicating the attempt to cancel a specific booking.
      // The '$bookingId' uses string interpolation to include the booking ID in the message.
      print("Attempting to cancel booking: $bookingId"); // Debug print
      // Asynchronously calls the 'cancelBooking' method on the 'bookingService' instance, passing the 'bookingId'.
      // The 'await' keyword pauses execution of this method until the 'cancelBooking' Future completes.
      await bookingService.cancelBooking(bookingId);
      // Prints a debug message to the console confirming that the booking was cancelled successfully.
      print("Booking cancelled successfully"); // Debug print

      // This comment explains that the next line is intended to refresh the list of bookings.
      // Force a refresh of the bookings list
      // Asynchronously calls 'fetchUserBookings' on the 'bookingService' instance.
      // This is done to update the list of user bookings after a cancellation, ensuring the UI reflects the change.
      await bookingService.fetchUserBookings();

      // Checks if the widget is still mounted (i.e., part of the widget tree).
      // This is a crucial check before interacting with the BuildContext (e.g., showing a SnackBar)
      // in asynchronous callbacks to prevent errors if the widget has been disposed.
      if (mounted) {
        // Accesses the ScaffoldMessenger associated with the current BuildContext.
        ScaffoldMessenger.of(
          context,
          // Shows a SnackBar to provide feedback to the user.
          // The 'const' keyword is used because the SnackBar's content is static.
        ).showSnackBar(
          const SnackBar(content: Text('Booking annulleret')),
        ); // 'Booking annulleret' means 'Booking cancelled'
      }
      // Catches any exceptions 'e' that occur within the 'try' block.
    } catch (e) {
      // Prints an error message to the console, including the booking ID and the exception details.
      print("Error cancelling booking: $e"); // Debug print
      // Checks if the widget is still mounted before attempting to show a SnackBar.
      if (mounted) {
        // Accesses the ScaffoldMessenger to display an error message.
        ScaffoldMessenger.of(
          context,
          // Shows a SnackBar containing an error message.
          // The message "Fejl ved annullering: " means "Error during cancellation: ".
        ).showSnackBar(SnackBar(content: Text('Fejl ved annullering: $e')));
      }
    }
  }

  // Overrides the 'build' method from the State class.
  // This method is called by the Flutter framework whenever the widget needs to be (re)built,
  // for example, when its state changes or when its parent rebuilds.
  @override
  Widget build(BuildContext context) {
    // This comment indicates that BookingService is being watched for changes.
    // Make sure we're watching the BookingService
    // Retrieves an instance of BookingService from the widget tree using `context.watch<BookingService>()`.
    // `context.watch` is crucial here: it subscribes this widget to changes in BookingService.
    // If BookingService notifies its listeners (e.g., after bookings are fetched or updated), this 'build' method will be re-run.
    final bookingService = context.watch<BookingService>();
    // Prints a debug message to the console every time the UserProfileScreen rebuilds.
    // It includes the number of bookings currently held by the bookingService, which is useful for debugging UI updates.
    print(
      "UserProfileScreen: Rebuilding with ${bookingService.userBookings.length} bookings",
    );

    // This comment explains that services are being accessed from Provider.
    // Access services from Provider
    // This comment further clarifies that `context.watch` is used to trigger UI rebuilds on state changes.
    // Use context.watch to rebuild the UI when service state changes
    // Retrieves an instance of UserService using `context.watch<UserService>()`.
    // Similar to BookingService, this subscribes the widget to changes in UserService.
    // If UserService's state changes (e.g., user logs in/out, profile updates), this 'build' method will be re-run.
    final userService = context.watch<UserService>();

    // This comment describes a defensive programming measure:
    // If, for some reason, a user who is not logged in reaches this screen, they should be redirected.
    // If user is somehow not logged in and lands here, redirect (defensive)
    // Checks the 'isLoggedIn' status from the 'userService' (which was obtained using context.watch).
    if (!userService.isLoggedIn) {
      // This multi-line comment explains that this code block is a fallback.
      // Ideally, the routing logic in the main application (MyApp) should prevent unauthenticated users
      // from reaching this screen.
      // This part ideally shouldn't be reached if your routing logic in MyApp
      // based on userService.isLoggedIn is working correctly.
      // This comment explains why `addPostFrameCallback` is used: to avoid calling `setState` or performing
      // navigation (which can implicitly call `setState`) directly within the `build` method.
      // Using a post frame callback to avoid setState during build.
      // Schedules a callback to be executed after the current frame has finished rendering.
      // This is a safe way to perform navigation or other actions that might affect the widget tree's state
      // without causing errors related to modifying state during a build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Checks if the widget is still mounted in the widget tree.
        // This is essential before attempting navigation to prevent errors if the widget has been disposed.
        if (mounted) {
          // Performs navigation to the '/login' route.
          // `pushNamedAndRemoveUntil` replaces the current route stack with the '/login' route,
          // and `(route) => false` ensures all previous routes are removed, preventing the user from navigating back.
          Navigator.pushNamedAndRemoveUntil(
            context, // The BuildContext of the current widget.
            '/login', // The named route to navigate to.
            (route) => false, // A predicate that removes all existing routes.
          );
        }
      });
      // Returns a basic Scaffold with a loading indicator.
      // This provides immediate visual feedback to the user while the redirection (scheduled in `addPostFrameCallback`) occurs.
      return const Scaffold(
        // Sets the background color of the Scaffold to transparent.
        backgroundColor: Colors.transparent,
        // The main content of the Scaffold.
        body: Center(
          child: CircularProgressIndicator(),
        ), // Displays a centered circular progress indicator.
      ); // This comment clarifies that a loading indicator is shown during redirection. // Show loading while redirecting
    }

    // If the user is logged in (the above 'if' condition was false), this Scaffold is returned, representing the main UI of the UserProfileScreen.
    return Scaffold(
      // Sets the background color of the Scaffold to transparent.
      // This might be used if the screen is intended to overlay another widget or have a custom background managed elsewhere.
      backgroundColor: Colors.transparent,
      // Defines the AppBar for this Scaffold.
      appBar: AppBar(
        // Prevents the AppBar from automatically adding a leading widget (like a back button).
        // This is often set to false for top-level screens in a tabbed navigation setup.
        automaticallyImplyLeading:
            false, // This comment explains the reason for disabling the automatic leading widget. // No back button if this is a main tab
        // Defines the title widget for the AppBar. Here, it's a Row to allow for multiple elements.
        title: Row(
          // A list of children widgets for the Row.
          children: [
            // A Padding widget to add some space around its child.
            Padding(
              // Specifies padding only on the left side (though it's set to 0.0, which might be an adjustment point).
              padding: const EdgeInsets.only(
                left: 0.0,
              ), // This comment indicates the padding was adjusted. // Adjusted padding
              // A GestureDetector to make its child (another Row) tappable.
              child: GestureDetector(
                // The callback function that is executed when the GestureDetector is tapped.
                onTap: () {
                  // This comment clarifies that an async operation is not needed for this simple navigation.
                  // No async needed for direct navigation
                  // Checks if the widget is still mounted before attempting navigation.
                  if (mounted) {
                    // Navigates to the '/' (home) route and removes all previous routes.
                    // This effectively takes the user to the main/home screen of the app.
                    Navigator.pushNamedAndRemoveUntil(
                      context, // The BuildContext.
                      '/', // The named route for the home screen.
                      (route) => false, // Removes all previous routes.
                    );
                  }
                },
                // The child of the GestureDetector, which is another Row containing text and an icon.
                child: Row(
                  // A list of children widgets for this inner Row.
                  children: const [
                    // A Text widget displaying "SALON LAURA".
                    Text(
                      'SALON LAURA',
                      // Applies a specific TextStyle to the text.
                      style: TextStyle(
                        letterSpacing:
                            0.8, // Adjusts the spacing between letters.
                        fontSize: 15, // Sets the font size.
                        color:
                            AppColors
                                .gold, // Sets the text color using a predefined AppColors constant.
                      ),
                    ),
                    // A SizedBox to add a fixed amount of horizontal space between the Text and the Icon.
                    SizedBox(width: 4),
                    // An Icon widget displaying a content_cut (scissors) icon.
                    Icon(
                      Icons.content_cut,
                      size: 16,
                      color: AppColors.gold,
                    ), // Sets the icon size and color.
                  ],
                ),
              ),
            ),
          ],
        ),
        // Defines a list of widgets to display as actions on the trailing side of the AppBar (typically the right side).
        actions: [
          // Defines an IconButton widget to be placed in the AppBar's actions.
          IconButton(
            // Sets the icon for the button to be a logout icon (an outline version).
            // The 'const' keyword optimizes performance as the icon itself is static.
            icon: const Icon(Icons.logout_outlined),
            // Sets the tooltip text that appears when the user hovers over the button (on web/desktop) or long-presses (on mobile).
            // 'Log ud' means 'Log out'.
            tooltip: 'Log ud',
            // Defines the asynchronous callback function that is executed when the IconButton is pressed.
            onPressed: () async {
              // Shows a dialog to confirm if the user really wants to log out.
              // `showDialog<bool>` expects the dialog to return a boolean value (true for confirm, false for cancel).
              // The 'await' keyword pauses execution until the dialog is dismissed and returns a value.
              final confirmLogout = await showDialog<bool>(
                // Provides the BuildContext of the current widget, necessary for `showDialog`.
                context: context,
                // The builder function that constructs the dialog's UI.
                // It receives a 'dialogContext', which is specific to the dialog.
                builder: (BuildContext dialogContext) {
                  // Returns an AlertDialog widget, a standard Material Design dialog.
                  return AlertDialog(
                    // Sets the title of the dialog.
                    // 'Log ud' means 'Log out'. The style is taken from `AppTheme.dialogTitleStyle`.
                    title: Text('Log ud', style: AppTheme.dialogTitleStyle),
                    // Sets the main content/message of the dialog.
                    // 'Er du sikker på, at du vil logge ud?' means 'Are you sure you want to log out?'.
                    // The style is taken from `AppTheme.dialogContentStyle`.
                    content: Text(
                      'Er du sikker på, at du vil logge ud?',
                      style: AppTheme.dialogContentStyle,
                    ),
                    // Defines a list of actions (buttons) at the bottom of the dialog.
                    actions: <Widget>[
                      // A TextButton for the 'NO' option.
                      TextButton(
                        // Styles the TextButton, setting its foreground (text) color.
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Colors
                                  .white70, // A slightly transparent white color.
                        ),
                        // The text displayed on the 'NO' button.
                        child: const Text('NEJ'),
                        // The callback function executed when the 'NO' button is pressed.
                        // It closes the dialog by calling `Navigator.of(dialogContext).pop(false)`, returning `false`.
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                      // A TextButton for the 'YES, LOG OUT' option.
                      TextButton(
                        // Styles the TextButton, setting its foreground (text) color to a light red accent.
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent[100],
                        ),
                        // The text displayed on the 'YES' button.
                        child: const Text('JA, LOG UD'),
                        // The callback function executed when the 'YES' button is pressed.
                        // It closes the dialog by calling `Navigator.of(dialogContext).pop(true)`, returning `true`.
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ],
                  );
                },
              );

              // Checks if the 'confirmLogout' variable is true (meaning the user confirmed logout)
              // AND if the widget is still mounted in the widget tree.
              if (confirmLogout == true && mounted) {
                // If both conditions are true, call the `_performLogout` method (defined earlier)
                // to handle the actual logout logic. 'await' ensures this completes before proceeding.
                await _performLogout();
              }
            },
          ),
          // Closes the list of 'actions' for the AppBar.
        ],
        // Closes the AppBar definition.
      ),
      // Defines the main content area of the Scaffold.
      // It uses a Builder widget.
      body: Builder(
        // This comment explains the purpose of using a Builder widget:
        // to obtain a new BuildContext (`innerContext`) that is a descendant of the Scaffold.
        // This can be useful for operations like showing a SnackBar via ScaffoldMessenger.of(innerContext).
        // Use Builder to get a new context if needed for ScaffoldMessenger
        // The builder function for the Builder widget. It receives 'innerContext'.
        builder: (BuildContext innerContext) {
          // This comment indicates that 'innerContext' can be used with ScaffoldMessenger.
          // innerContext for ScaffoldMessenger
          // Checks if bookings are currently being loaded AND if the list of user bookings is empty.
          // This indicates an initial loading state.
          if (bookingService.isLoadingBookings &&
              bookingService.userBookings.isEmpty) {
            // If true, display a centered CircularProgressIndicator.
            return const Center(child: CircularProgressIndicator());
          }
          // Checks if there was a booking error AND if the list of user bookings is empty.
          // This indicates an error state where no data could be loaded.
          if (bookingService.bookingError != null &&
              bookingService.userBookings.isEmpty) {
            // If true, display an error message and a retry button.
            return Center(
              child: Column(
                // Centers the column's children vertically.
                mainAxisAlignment: MainAxisAlignment.center,
                // The children of the Column.
                children: [
                  // Displays the error message from `bookingService.bookingError`.
                  Text(
                    'Fejl: ${bookingService.bookingError}', // 'Fejl:' means 'Error:'
                    // Styles the error text with a red color.
                    style: TextStyle(color: Colors.red),
                  ),
                  // An ElevatedButton that allows the user to retry fetching bookings.
                  ElevatedButton(
                    // The callback function executed when the button is pressed.
                    onPressed: () {
                      // Retrieves the BookingService instance using `context.read` (one-time read)
                      // and calls `fetchUserBookings()` to attempt fetching data again.
                      context
                          .read<BookingService>()
                          .fetchUserBookings(); // This comment indicates it's a retry action. // Retry
                    },
                    // The text displayed on the retry button. "Prøv igen" means "Try again".
                    child: Text("Prøv igen"),
                  ),
                ],
              ),
            );
          }

          // If none of the above conditions (loading or error with no data) are met,
          // this SingleChildScrollView is returned, displaying the main content.
          return SingleChildScrollView(
            // This comment indicates that padding is added around the entire scrollable content.
            // Add padding around the entire content
            // Applies padding to all sides of the SingleChildScrollView's content.
            padding: const EdgeInsets.all(16.0),
            // The child of the SingleChildScrollView, which is a Column.
            child: Column(
              // This comment explains that children of this Column will stretch to the full width.
              // Make children stretch to full width
              // Aligns the children of the Column to stretch horizontally to fill the Column's width.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // A list of children widgets for the Column.
              children: [
                // A Container widget used to group and style a section of the UI.
                Container(
                  // This comment indicates that padding is added inside this container.
                  // Add padding inside the container
                  // Applies padding to all sides inside the Container.
                  padding: const EdgeInsets.all(16.0),
                  // This comment explains that a gold border decoration from the app's theme is applied.
                  // Apply gold border decoration from theme
                  // Sets the decoration for the Container, likely providing a border and/or background style.
                  // `AppTheme.goldBorderContainer` is presumably a predefined BoxDecoration.
                  decoration: AppTheme.goldBorderContainer,
                  // The child of the Container, which is another Column.
                  child: Column(
                    // This comment explains that children of this inner Column will be aligned to the left.
                    // Align children to the left
                    // Aligns the children of this Column to the start (left for LTR languages) of the cross axis.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // A list of children widgets for this inner Column.
                    children: [
                      // This comment describes this Row as a header with a title and a loading indicator.
                      // Header row with title and loading indicator
                      // A Row widget to arrange its children horizontally.
                      Row(
                        // This comment explains that this property creates space between the title and the loading indicator.
                        // Space between title and loading indicator
                        // Distributes space evenly between the children, pushing them to the opposite ends of the Row.
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // The children of the Row.
                        children: [
                          // A Text widget displaying "Mine Bookinger" (My Bookings).
                          Text(
                            'Mine Bookinger',
                            // This comment explains the styling applied to the text.
                            // Use theme's title style but override color and size
                            // Gets the `titleLarge` text style from the current theme and then overrides its color and fontSize.
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white, fontSize: 18),
                          ),
                          // This comment explains that the loading spinner is shown conditionally.
                          // Show loading spinner only when fetching bookings
                          // A conditional check: if `bookingService.isLoadingBookings` is true...
                          if (bookingService.isLoadingBookings)
                            // ...then display a SizedBox containing a CircularProgressIndicator.
                            // The SizedBox constrains the size of the loading indicator.
                            SizedBox(
                              height: 20, // Sets the height of the SizedBox.
                              width: 20, // Sets the width of the SizedBox.
                              // A CircularProgressIndicator to show that data is being loaded.
                              // `strokeWidth: 2` makes the indicator's line thinner.
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Conditional rendering based on booking state
                      if (!bookingService.isLoadingBookings &&
                          bookingService.userBookings.isEmpty)
                        // Show message when no bookings exist
                        const Center(
                          child: Text(
                            'Ingen aktive bookinger',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else if (bookingService.userBookings.isNotEmpty)
                        // Display list of bookings when they exist
                        ListView.separated(
                          // Allow ListView to size itself based on content
                          shrinkWrap: true,
                          // Disable scrolling since this is inside a SingleChildScrollView
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookingService.userBookings.length,
                          // Add spacing between booking cards
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            // Get booking data for current index
                            final booking = bookingService.userBookings[index];
                            final startTime = booking.startTime;

                            return Card(
                              // Semi-transparent black background
                              color: AppColors.black.withAlpha(180),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                // Add gold border with reduced opacity
                                side: BorderSide(
                                  color: AppColors.gold.withAlpha(150),
                                  width: 1.5,
                                ),
                              ),
                              // ListTile is a Material Design widget that provides a standard layout for a row containing text, an icon, and other widgets.
                              child: ListTile(
                                // The 'leading' widget is displayed at the beginning of the ListTile.
                                // Here, it's a CircleAvatar, commonly used for profile pictures or icons.
                                leading: CircleAvatar(
                                  // Sets the background image for the CircleAvatar.
                                  // AssetImage is used to load an image from the project's assets folder.
                                  backgroundImage: AssetImage(
                                    // This comment suggests a potential improvement: mapping barberId to an image or storing an image URL in the booking data.
                                    // You might need a way to map barberId to image or store image URL in booking
                                    // This is a conditional (ternary) operator to select an image based on the 'booking.barberId'.
                                    // It checks if the barberId matches a specific ID.
                                    booking.barberId ==
                                            '7d9fb269-b171-49c5-93ef-7097a99e02e3' // A specific barber ID.
                                        ? 'assets/barber1.jpg' // If the ID matches, use 'barber1.jpg'.
                                        : 'assets/barber2.jpg', // Otherwise, use 'barber2.jpg' as a fallback or for other barbers.
                                  ),
                                ),
                                // The 'title' widget is the primary content of the ListTile, typically a single line of text.
                                title: Text(
                                  // This comment clarifies that 'barberName' is accessed from the 'booking' object.
                                  // Access barberName from Booking object
                                  // Constructs the title string. "Tid hos" means "Appointment with".
                                  // It uses the 'booking.barberName'. If 'booking.barberName' is null, it defaults to 'Frisør' (Barber)
                                  // using the null-coalescing operator '??'.
                                  'Tid hos ${booking.barberName ?? 'Frisør'}',
                                  // Applies a style to the title text, setting its color to white.
                                  style: const TextStyle(color: Colors.white),
                                ),
                                // The 'subtitle' widget is displayed below the title, typically for additional information.
                                subtitle: Text(
                                  // Formats the start time of the booking as 'day/month/year - hour:minute'.
                                  // `startTime.minute.toString().padLeft(2, '0')` ensures the minute is always two digits (e.g., '05' instead of '5').
                                  '${startTime.day}/${startTime.month}/${startTime.year} - '
                                  '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                                  // Applies a style to the subtitle text, setting its color to a slightly transparent white.
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                // The 'trailing' widget is displayed at the end of the ListTile.
                                // Here, it's an IconButton to allow users to delete/cancel the booking.
                                trailing: IconButton(
                                  // Sets the icon for the button to a delete outline icon.
                                  icon: const Icon(Icons.delete_outline),
                                  // Sets the color of the icon to a light red.
                                  color: Colors.red[300],
                                  // The callback function executed when the delete IconButton is pressed.
                                  // It calls `showDialog` to display a confirmation dialog.
                                  onPressed:
                                      () => showDialog(
                                        // The arrow function immediately calls showDialog.
                                        // Provides the BuildContext of the current widget (from the parent build method).
                                        context:
                                            context, // This comment clarifies which context is being used. // Use the build context
                                        // The builder function that constructs the dialog's UI.
                                        // It receives 'dialogContext', which is specific to the dialog.
                                        builder:
                                            (dialogContext) => AlertDialog(
                                              // Uses dialogContext for the AlertDialog.
                                              // This comment indicates that dialogContext is used here. // Use dialogContext
                                              // Sets the background color of the AlertDialog using a predefined color from AppColors.
                                              backgroundColor: AppColors.black,
                                              // Sets the title of the confirmation dialog.
                                              title: const Text(
                                                'Annuller Booking', // "Annuller Booking" means "Cancel Booking".
                                                // Styles the title text with a white color.
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              // Sets the main content of the dialog, which is a Column here to include multiple text elements.
                                              content: Column(
                                                // `mainAxisSize: MainAxisSize.min` makes the Column take up only as much vertical space as its children need.
                                                mainAxisSize: MainAxisSize.min,
                                                // Aligns the children of the Column to the start (left) of the cross axis.
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                // A list of children widgets for the Column.
                                                children: const [
                                                  // The primary confirmation question.
                                                  Text(
                                                    // "Er du sikker på, at du vil annullere denne booking?" means "Are you sure you want to cancel this booking?".
                                                    'Er du sikker på, at du vil annullere denne booking?',
                                                    // Styles the text with a slightly transparent white color.
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                  // A SizedBox to add some vertical spacing.
                                                  SizedBox(height: 16),
                                                  // An important notice or warning.
                                                  Text(
                                                    // "OBS: Ved aflysning under 24 timer før bekræftet tid, bedes du ringe til salonen."
                                                    // means "NOTE: For cancellations less than 24 hours before the confirmed time, please call the salon."
                                                    'OBS: Ved aflysning under 24 timer før bekræftet tid, bedes du ringe til salonen.',
                                                    // Styles the warning text with a red color and smaller font size.
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Defines a list of actions (buttons) at the bottom of the dialog.
                                              actions: [
                                                // A TextButton for the 'NO' option (to not cancel).
                                                TextButton(
                                                  // The callback function executed when the 'NO' button is pressed.
                                                  // It closes the dialog by calling `Navigator.pop(dialogContext)`, without returning any specific value (or returning null).
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        dialogContext, // The context specific to the dialog.
                                                      ),
                                                  // The text displayed on the 'NO' button.
                                                  child: const Text('NEJ'),
                                                ),
                                                // A TextButton for the 'YES' option (to confirm cancellation).
                                                TextButton(
                                                  // The callback function executed when the 'YES' button is pressed.
                                                  onPressed: () {
                                                    // First, close the confirmation dialog.
                                                    Navigator.pop(
                                                      dialogContext, // The context specific to the dialog.
                                                    );
                                                    // Then, call the `_performCancelBooking` method (defined elsewhere in the class)
                                                    // to actually cancel the booking, passing the `booking.id`.
                                                    _performCancelBooking(
                                                      booking
                                                          .id, // This comment clarifies that booking.id is used. // Use booking.id
                                                    );
                                                  },
                                                  // The text displayed on the 'YES' button.
                                                  child: Text(
                                                    'JA',
                                                    // Styles the 'JA' text with a light red color to indicate a potentially destructive action.
                                                    style: TextStyle(
                                                      color: Colors.red[300],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      // If still loading but there are already some bookings, you might show a smaller indicator or nothing
                      // else if (bookingService.isLoadingBookings)
                      //    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Opdaterer...", style: TextStyle(color: Colors.white70)))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
