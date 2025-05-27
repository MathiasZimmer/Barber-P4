// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/service_card.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';

// Defines a new class named HomeScreen that extends StatefulWidget.
// StatefulWidget is used for widgets whose UI can change dynamically during their lifetime.
class HomeScreen extends StatefulWidget {
  // Defines a constant constructor for HomeScreen.
  // The 'super.key' passes the optional 'key' parameter to the StatefulWidget constructor.
  // Keys are used by Flutter to identify and differentiate widgets, especially useful in lists or when widgets are moved in the tree.
  const HomeScreen({super.key});

  // Overrides the createState method from StatefulWidget.
  // This method is called by the Flutter framework to create the mutable state object associated with this widget.
  @override
  // Returns an instance of _HomeScreenState, which will manage the state for HomeScreen.
  State<HomeScreen> createState() => _HomeScreenState();
}

// Defines the state class for HomeScreen, named _HomeScreenState.
// It extends State<HomeScreen>, linking it to the HomeScreen widget and allowing it to manage HomeScreen's mutable state.
class _HomeScreenState extends State<HomeScreen> {
  // This comment explains the purpose of the _scrollController.
  // Controller to manage scrolling behavior of the main content
  // Initializes a final ScrollController instance.
  // ScrollControllers are used to control the position of a scrollable widget, like a ListView or SingleChildScrollView.
  final ScrollController _scrollController = ScrollController();

  // This comment explains the purpose of the _contactKey.
  // GlobalKey used to identify and scroll to the contact section
  // Initializes a final GlobalKey instance.
  // GlobalKeys provide a unique identity to a widget across the entire application.
  // Here, it's used to get the context of the contact section for scrolling.
  final _contactKey = GlobalKey();

  // This comment describes the _scrollToContact method.
  // Method to smoothly scroll to the contact section when the KONTAKT button is pressed
  // Defines a method named _scrollToContact that takes no arguments and returns void.
  // This method will handle the smooth scrolling animation to the contact section.
  void _scrollToContact() {
    // Calls Scrollable.ensureVisible to programmatically scroll a widget into view.
    Scrollable.ensureVisible(
      // Gets the BuildContext of the widget associated with _contactKey.
      // The non-null assertion operator (!) is used because we expect the context to be available when this method is called.
      _contactKey.currentContext!,
      // Sets the duration of the scroll animation to 500 milliseconds.
      duration: const Duration(milliseconds: 500),
      // Sets the animation curve to Curves.easeInOut, which provides a smooth acceleration and deceleration effect.
      curve: Curves.easeInOut,
    );
  }

  // Overrides the build method from the State class.
  // This method is called by the Flutter framework whenever the widget needs to be (re)built,
  // for example, when its state changes or when its parent rebuilds.
  @override
  Widget build(BuildContext context) {
    // Returns a Scaffold widget, which provides a standard Material Design visual layout structure.
    return Scaffold(
      // This comment explains why the background color is set to transparent.
      // Transparent background to allow the app's theme to show through
      // Sets the background color of the Scaffold to transparent.
      // This allows any background color or image set by the parent theme or widget to be visible.
      backgroundColor: Colors.transparent,
      // Defines the AppBar for this Scaffold.
      appBar: AppBar(
        // This comment describes the custom title.
        // Custom title with salon name and scissors icon
        // Sets the title widget for the AppBar. A Padding widget is used for spacing.
        title: Padding(
          // Applies padding only to the left side of the title content.
          padding: const EdgeInsets.only(left: 8.0),
          // A Row widget to arrange the salon name and icon horizontally.
          child: Row(
            // A list of children widgets for the Row.
            children: const [
              // A Text widget displaying "SALON LAURA".
              Text(
                'SALON LAURA',
                // Applies a specific TextStyle to the text.
                style: TextStyle(
                  letterSpacing: 0.8, // Adjusts the spacing between letters.
                  fontSize: 15, // Sets the font size.
                  color: Color.fromARGB(
                    153, // Alpha value (0-255), 153 is ~60% opacity.
                    224, // Red component.
                    224, // Green component.
                    224, // Blue component.
                  ), // This comment clarifies the color. // Semi-transparent white
                ),
              ),
              // A SizedBox to add a fixed amount of horizontal space between the Text and the Icon.
              SizedBox(width: 4),
              // An Icon widget displaying a content_cut (scissors) icon.
              Icon(
                Icons.content_cut, // The specific icon to display.
                size: 16, // Sets the size of the icon.
                // Sets the color of the icon to a semi-transparent white, matching the text.
                color: Color.fromARGB(153, 224, 224, 224),
              ),
            ],
          ),
        ),
        // This comment explains the centerTitle property.
        // Align title to the left
        // If false, the title is aligned to the leading edge (left in LTR languages) of the AppBar.
        centerTitle: false,
        // This comment explains the titleSpacing property.
        // Remove default title spacing
        // Sets the horizontal spacing around the title to 0, removing any default padding.
        titleSpacing: 0,
        // This comment indicates that the following are navigation buttons.
        // Navigation buttons in the app bar
        // Defines a list of widgets to display as actions on the trailing side of the AppBar (typically the right side).
        actions: [
          // This comment describes the booking button.
          // Booking button with gold accent color
          // A TextButton with an icon for navigating to the booking page.
          TextButton.icon(
            // The callback function executed when the button is pressed.
            // It navigates to the '/booking' named route.
            onPressed: () => Navigator.pushNamed(context, '/booking'),
            // The icon part of the TextButton.icon, which is a Text widget here.
            icon: const Text(
              'BOOK TID', // "BOOK TID" means "BOOK APPOINTMENT".
              // Applies a specific TextStyle to the button's text.
              style: TextStyle(
                color:
                    AppColors
                        .gold, // Uses a predefined gold color from AppColors.
                fontSize: 13, // Sets the font size.
                letterSpacing: 0.8, // Adjusts letter spacing.
                fontWeight: FontWeight.bold, // Sets the font weight to bold.
              ),
            ),
            // The label part of the TextButton.icon, which is an Icon widget here.
            label: Icon(
              Icons.content_cut,
              size: 16,
              color: AppColors.gold,
            ), // Scissors icon with gold color.
          ),
          TextButton(
            // Sets the callback function to be executed when this TextButton is pressed.
            // It calls the `_scrollToContact` method (defined earlier in this class) to scroll to the contact section.
            onPressed: _scrollToContact,
            // The child widget of the TextButton, which is a Text widget displaying "KONTAKT".
            child: const Text(
              'KONTAKT', // "KONTAKT" means "CONTACT".
              // Applies a specific TextStyle to the button's text.
              style: TextStyle(
                color: Colors.white, // Sets the text color to white.
                fontSize: 13, // Sets the font size.
                letterSpacing: 0.8, // Adjusts the spacing between letters.
              ),
            ),
          ),
          // Closes the list of 'actions' for the AppBar.
        ],
        // Closes the AppBar definition.
      ),
      // Defines the main content area of the Scaffold.
      // It uses a SingleChildScrollView to allow its content to be scrollable if it exceeds the screen height.
      body: SingleChildScrollView(
        // Assigns the `_scrollController` (initialized earlier) to the controller property of the SingleChildScrollView.
        // This allows programmatic control over the scrolling behavior.
        controller: _scrollController,
        // The child of the SingleChildScrollView, which is a Column widget.
        // A Column arranges its children vertically.
        child: Column(
          // A list of children widgets for the Column. These will be stacked vertically.
          children: [
            // A Stack widget, which allows its children to be layered on top of each other.
            Stack(
              // A list of children for the Stack. The first child is at the bottom, subsequent children are placed on top.
              children: [
                // A Container widget that serves as the background layer of the Stack, typically for an image.
                Container(
                  // Sets the height of the Container to 300 logical pixels.
                  height: 300,
                  // Sets the width of the Container to occupy the full available width.
                  width: double.infinity,
                  // Applies decoration to the Container.
                  decoration: const BoxDecoration(
                    // Sets an image as the background of the Container.
                    image: DecorationImage(
                      // Specifies the image to be used, loading it from the project's assets folder.
                      image: AssetImage('assets/hero.jpg'),
                      // Specifies how the image should be inscribed into the space allocated during layout.
                      // `BoxFit.cover` scales the image to fill the bounds of the container, potentially cropping some parts of the image.
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // A Positioned widget, used within a Stack to explicitly position its child.
                Positioned(
                  // Positions the child 20 logical pixels from the left edge of the Stack.
                  left: 20,
                  // Positions the child 20 logical pixels from the bottom edge of the Stack.
                  bottom: 20,
                  // The child of the Positioned widget, which is a Column.
                  // This Column will contain text elements overlaid on the hero image.
                  child: Column(
                    // Aligns the children of this Column to the start (left for LTR languages) of the cross axis.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // A list of children widgets for this inner Column.
                    children: [
                      // This block of code is commented out, suggesting it was part of a previous design or is temporarily disabled.
                      // It would have displayed a Text widget with the text "Herrefrisør i Aalborg".
                      /* Text(
                        'Herrefrisør i Aalborg', // "Men's hairdresser in Aalborg"
                        style: Theme.of(context).textTheme.titleLarge?.copyWith( // Uses theme's titleLarge style with overrides
                          color: Colors.yellow[700], // Sets text color to a shade of yellow.
                          fontSize: 28, // Sets font size.
                        ),
                      ),*/
                      // A SizedBox widget used to create a fixed amount of vertical space (10 logical pixels).
                      // This likely adds some padding or separation below the (commented out) text.
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),

            // A Padding widget used to add horizontal spacing around its child Column.
            Padding(
              // Applies symmetric padding: 16.0 logical pixels on the left and 16.0 on the right.
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // The child of the Padding widget, which is a Column.
              // This Column will arrange the ServiceCard widgets vertically.
              child: Column(
                // A list of children widgets for this Column. All children are `ServiceCard` widgets.
                // The `const` keyword here indicates that the list itself and its elements (if they are const constructible) are compile-time constants.
                children: const [
                  // An instance of a custom widget named ServiceCard.
                  // This widget likely displays information about a specific service offered.
                  ServiceCard(
                    title: 'SKINFADE', // The title of the service.
                    // A description of the service, including prices. '\n' creates a new line.
                    description:
                        'Skinfade: 250,-\nMed skæg: 300,-', // "Med skæg" means "With beard".
                    imagePath:
                        'assets/fade.jpg', // The path to an image representing this service.
                  ),
                  // Another instance of the ServiceCard widget.
                  ServiceCard(
                    title: 'SKÆG', // "SKÆG" means "BEARD".
                    description:
                        'Skæg: 100,-\nMed Lineup: 150,-', // "Med Lineup" means "With Lineup".
                    imagePath: 'assets/beard.jpg',
                  ),
                  // Another instance of the ServiceCard widget.
                  ServiceCard(
                    title:
                        'BØRNEKLIP', // "BØRNEKLIP" means "CHILDREN'S HAIRCUT".
                    description: 'Børneklip: 150,-\nSkinfade: 200,-',
                    imagePath: 'assets/kids_cut.jpg',
                  ),
                  // Another instance of the ServiceCard widget.
                  ServiceCard(
                    title: 'HERREKLIP', // "HERREKLIP" means "MEN'S HAIRCUT".
                    description: 'Herreklip: 200,-\nMed skæg: 250,-',
                    imagePath: 'assets/styling.jpg',
                  ),
                ],
              ),
            ),
            // A Container widget used to display the opening hours section.
            Container(
              // Applies symmetric vertical margin: 24.0 logical pixels on the top and 24.0 on the bottom.
              margin: const EdgeInsets.symmetric(vertical: 24.0),
              // Applies padding to all sides inside the Container (24.0 logical pixels).
              padding: const EdgeInsets.all(24.0),
              // Sets the background color of the Container to a semi-transparent black.
              // `AppColors.black` is likely a predefined black color, and `.withAlpha(180)` sets its opacity (180 out of 255).
              color: AppColors.black.withAlpha(180),
              // The child of the Container, which is a Column.
              child: Column(
                // A list of children widgets for this Column, arranged vertically.
                children: [
                  // A Text widget displaying the title "Åbningstider" (Opening Hours).
                  Text(
                    'Åbningstider',
                    // Styles the text using the theme's `titleLarge` style, but overrides the color to white.
                    // The `?.copyWith()` is a null-safe way to call `copyWith` if `textTheme.titleLarge` is not null.
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  // A SizedBox to add a fixed amount of vertical space (16 logical pixels) between the title and the opening hours text.
                  const SizedBox(height: 16),
                  // A Text widget displaying the detailed opening hours.
                  Text(
                    // The opening hours string, with '\n' creating new lines for each day. "Lukket" means "Closed".
                    'Mandag - Torsdag: 9:00 - 19:00\n' // Monday - Thursday
                    'Fredag: 9:00 - 20:00\n' // Friday
                    'Lørdag: 9:00 - 16:00\n' // Saturday
                    'Søndag: Lukket', // Sunday
                    // Centers the text horizontally.
                    textAlign: TextAlign.center,
                    // Styles the text using the theme's `bodyLarge` style, but overrides the color to a semi-transparent white.
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withAlpha(
                        200,
                      ), // White with ~78% opacity.
                    ),
                  ),
                ],
              ),
            ),
            // A Container widget for the "KONTAKT" (Contact) section.
            Container(
              // Assigns the `_contactKey` (a GlobalKey initialized earlier) to this Container.
              // This allows the `_scrollToContact` method to find this widget and scroll to it.
              key: _contactKey,
              // Sets the width of the Container to occupy the full available width.
              width: double.infinity,
              // Sets the background color of the Container to black, using a predefined color from AppColors.
              color: AppColors.black,
              // Applies padding to all sides inside the Container (24.0 logical pixels).
              padding: const EdgeInsets.all(24.0),
              // The child of the Container, which is a Column.
              child: Column(
                // Aligns the children of this Column to the center of the cross axis (horizontally, in this case).
                crossAxisAlignment: CrossAxisAlignment.center,
                // A list of children widgets for this Column.
                children: [
                  // A Text widget displaying the title "KONTAKT".
                  Text(
                    'KONTAKT',
                    // Styles the text using the theme's `titleLarge` style, with several overrides.
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white, // Sets the text color to white.
                      fontWeight:
                          FontWeight.bold, // Sets the font weight to bold.
                      letterSpacing:
                          0.8, // Adjusts the spacing between letters.
                    ),
                  ),
                  // A SizedBox widget used to create a fixed amount of vertical space (16 logical pixels).
                  // This adds separation between the "KONTAKT" title and the contact details.
                  const SizedBox(height: 16),
                  // A Text widget displaying the contact phone number.
                  Text(
                    // The contact information string. "Kontakt os:" means "Contact us:".
                    'Kontakt os: +45 98 12 17 47',
                    // Styles the text using the theme's `bodyLarge` style, but overrides the color to white.
                    style: Theme.of(
                      context, // The BuildContext.
                    ).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ), // The ?.copyWith is null-safe.
                  ),
                  // A SizedBox widget used to create a smaller amount of vertical space (8 logical pixels).
                  // This adds separation between the phone number and the address.
                  const SizedBox(height: 8),
                  // A Text widget displaying the address.
                  Text(
                    // The address string. "Adresse:" means "Address:".
                    'Adresse: REBERBANSGADE 6, 9000, Aalborg',
                    // Styles the text using the theme's `bodyLarge` style, with overrides for color and font size.
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white, // Sets the text color to white.
                      fontSize: 14, // Sets the font size to 14.
                    ),
                  ),
                  // Closes the list of children for the "KONTAKT" section's Column.
                ],
                // Closes the Column widget for the "KONTAKT" section.
              ),
              // Closes the Container widget for the "KONTAKT" section.
            ),
            // Closes the list of children for the main Column inside the SingleChildScrollView.
          ],
          // Closes the main Column widget.
        ),
        // Closes the SingleChildScrollView widget.
      ),
      // Defines the FloatingActionButton for the Scaffold.
      // Instead of a direct FAB, a custom Container is used to achieve a specific size and shape.
      floatingActionButton: Container(
        // Sets the width of the container to 40 logical pixels.
        width: 40,
        // Sets the height of the container to 40 logical pixels, making it a square.
        height: 40,
        // Applies decoration to the Container.
        decoration: BoxDecoration(
          // Sets the background color of the container.
          // `AppColors.gold.withAlpha(970)` seems to have an alpha value greater than 255, which might be a typo.
          // Alpha values are typically 0-255. If 970 is intended to mean fully opaque or a specific effect,
          // it might be handled differently by a custom color class or should be clamped to 255. Assuming it means a variant of gold.
          color: AppColors.gold.withAlpha(
            970,
          ), // Alpha value might be a typo, usually 0-255.
          // Applies a circular border radius, making the square container appear as a circle.
          // A radius of 20 on a 40x40 container creates a perfect circle.
          borderRadius: BorderRadius.circular(20),
        ),
        // The child of the Container, which is an IconButton.
        child: IconButton(
          // Sets the icon for the button to a person icon.
          // `AppColors.grey` sets the icon color. `size: 20` sets the icon size.
          icon: const Icon(Icons.person, color: AppColors.grey, size: 20),
          // Defines the callback function to be executed when the IconButton is pressed.
          onPressed: () {
            // Retrieves an instance of UserService from the widget tree using Provider's `context.read`.
            // `context.read` is used for one-time reads, suitable for event handlers.
            final userService = context.read<UserService>();
            // Checks if the user is currently logged in by accessing the 'isLoggedIn' property of the userService.
            if (userService.isLoggedIn) {
              // If the user is logged in, navigate to the '/user_profile' named route.
              Navigator.pushNamed(context, '/user_profile');
            } else {
              // If the user is not logged in, navigate to the '/login' named route.
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
      ),
    );
  }
}
