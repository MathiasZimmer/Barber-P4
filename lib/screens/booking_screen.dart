// lib/screens/booking_screen.dart
// Import necessary Flutter material widgets and core functionalities.
import 'package:flutter/material.dart';
// Import the BookingService to interact with booking-related logic (e.g., fetching time slots).
import '../services/booking_service.dart';
// Import main.dart, likely for global constants like AppColors if defined there.
import '../main.dart'; // If AppColors is defined in main.dart, otherwise use specific AppColors import
// Import the Service and ServiceOption models to define what a service offering looks like.
import '../models/service.dart';
// Import the AppTheme class to use predefined styles for UI consistency.
import '../theme/app_theme.dart';
// Import the UserService, which might be needed for user context (though not directly used for instantiation here anymore if using Provider).
import '../services/user_service.dart';
// Note: Provider import is missing if you intend to use context.read<BookingService>() later.
// import 'package:provider/provider.dart';

// Defines a StatefulWidget for the booking screen, allowing its UI to change based on state.
class BookingScreen extends StatefulWidget {
  // Constructor for BookingScreen, accepting an optional key.
  const BookingScreen({super.key});

  // Creates the mutable state for this StatefulWidget.
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

// Manages the state for the BookingScreen.
class _BookingScreenState extends State<BookingScreen> {
  // Instance of BookingService.
  // IMPORTANT: This direct instantiation bypasses Provider. If BookingService is meant to be
  // provided globally and depend on a Provider-managed UserService, this should be changed to
  // use context.read<BookingService>() or context.watch<BookingService>() in the build method or relevant callbacks.
  final BookingService _bookingService = BookingService(
    UserService(),
  ); // This UserService instance is also new and not from Provider.

  // Holds the currently selected date for booking, initialized to today.
  DateTime selectedDate = DateTime.now();
  // Holds the ID of the currently selected barber, nullable if none is selected.
  String? selectedBarberId;
  // Holds the ID of the currently selected service, nullable.
  String?
  selectedServiceId; // Note: The screen logic later uses a 'Service' object, not just ID.
  // Holds the currently selected service option, nullable.
  ServiceOption? selectedOption;
  // Holds the currently selected time slot, nullable.
  DateTime? selectedTime;
  // List to store available time slots fetched from the booking service.
  List<DateTime> availableSlots = [];
  // Boolean flag to indicate if time slots are currently being loaded.
  bool isLoading = false;

  // Hardcoded current user ID.
  // IMPORTANT: This should typically come from an authenticated UserService instance (e.g., userService.currentUser.uid).
  final String currentUserId = 'user123';
  // Hardcoded default service duration in minutes.
  // This should ideally be dynamic based on the selected service.
  final int serviceDuration = 30;

  // Static list of barber data. In a real app, this would come from a database or service.
  final List<Map<String, dynamic>> barbers = [
    {
      'id': '7d9fb269-b171-49c5-93ef-7097a99e02e3', // Unique ID for the barber
      'name': 'Frisør 1', // Name of the barber
      'image': 'assets/barber1.jpg', // Path to the barber's image asset
      'specialty': 'Skæg & Fades', // Barber's specialty
    },
    {
      'id': '07fe7f7b-da30-4bc2-aa84-f4bba2eaa0a7',
      'name': 'Frisør 2',
      'image': 'assets/barber2.jpg',
      'specialty': 'Skæg & Fades',
    },
  ];
  // Note: The 'services' list from models/service.dart is implicitly used later but not declared here.

  // Called when this State object is inserted into the tree.
  @override
  void initState() {
    super.initState(); // Always call super.initState() first.
    // Attempts to load available time slots when the screen initializes.
    // This might not load anything if selectedBarberId is null initially.
    loadAvailableSlots();
  }

  // Asynchronous function to fetch available time slots.
  Future<void> loadAvailableSlots() async {
    // Early return if widget is disposed or no barber is selected
    if (!mounted || selectedBarberId == null) return;

    // Show loading indicator while fetching slots
    setState(() => isLoading = true);

    try {
      // Fetch available time slots from the booking service
      // Parameters:
      // - barberId: The selected barber's unique identifier
      // - date: The selected date for the booking
      // - serviceDurationMinutes: How long the service will take
      List<DateTime> slots = await _bookingService.getAvailableTimeSlots(
        barberId: selectedBarberId!,
        date: selectedDate,
        serviceDurationMinutes: serviceDuration,
      );

      // Debug logging to help track slot availability
      print('Available slots: $slots');

      // If the selected date is today, filter out slots that are too close to current time
      // This prevents booking slots that are too soon (within 60 minutes)
      if (selectedDate.year == DateTime.now().year &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.day == DateTime.now().day) {
        final now = DateTime.now();
        final bufferTime = now.add(const Duration(minutes: 60));
        slots = slots.where((slot) => slot.isAfter(bufferTime)).toList();
      }

      // Update the UI with the filtered available slots
      setState(() => availableSlots = slots);
    } catch (e) {
      // Handle errors gracefully if widget is still mounted
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading time slots: $e')));
    }
    // Hide loading indicator regardless of success or failure
    setState(() => isLoading = false);
  }

  void proceedToConfirmation() {
    // Validate that required selections have been made
    if (selectedBarberId == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg venligst en barber, dato og tid')),
      );
      return;
    }

    // Navigate to the booking confirmation screen with all necessary booking details
    // The arguments map contains all information needed to display and process the booking
    Navigator.pushNamed(
      context,
      '/booking_confirmation',
      arguments: {
        'barberId': selectedBarberId,
        'barberName':
            barbers.firstWhere((b) => b['id'] == selectedBarberId)['name'],
        'date': selectedDate,
        'time': selectedTime,
        'serviceDuration': serviceDuration,
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Show the date picker dialog with custom styling
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Can't book dates in the past
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ), // Can book up to 30 days ahead
      builder: (context, child) {
        // Customize the date picker's appearance to match app theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.gold, // Selected date color
              onPrimary: Colors.black, // Text color on selected date
              surface: AppColors.black, // Background color
              onSurface: Colors.white, // Text color
            ),
          ),
          child: child!,
        );
      },
    );

    // Only update if a new date was selected
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTime = null; // Reset time selection when date changes
      });
      // Fetch available slots for the new date
      loadAvailableSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Main scaffold that provides the basic app structure
    return Scaffold(
      // Transparent background to allow for custom background effects
      backgroundColor: Colors.transparent,
      // App bar with styled title
      appBar: AppBar(title: Text('BOOK TID', style: AppTheme.appBarTitleStyle)),
      // Scrollable body to handle overflow content
      body: SingleChildScrollView(
        // Add padding around all content
        padding: const EdgeInsets.all(16.0),
        // Main column that stretches children horizontally
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container for barber selection section
            Container(
              padding: const EdgeInsets.all(16.0),
              // Apply gold border decoration from theme
              decoration: AppTheme.goldBorderContainer,
              child: Column(
                children: [
                  // Section title
                  Text(
                    'Vælg Frisør',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Horizontally scrollable list of barbers
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Map barber data to UI elements
                      children:
                          barbers.map((barber) {
                            // Track if this barber is currently selected
                            final isSelected = selectedBarberId == barber['id'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              // Make entire barber card tappable
                              child: GestureDetector(
                                onTap: () {
                                  // Update selected barber and reset time selection
                                  setState(() {
                                    selectedBarberId = barber['id'];
                                    selectedTime = null;
                                  });
                                  // Show service selection dialog
                                  _showServiceSelectionDialog();
                                  // Load available time slots for selected barber
                                  loadAvailableSlots();
                                },
                                // Barber card layout
                                child: Column(
                                  children: [
                                    // Barber image container with conditional styling
                                    Container(
                                      decoration:
                                          isSelected
                                              ? AppTheme.selectedBarberContainer
                                              : AppTheme
                                                  .unselectedBarberContainer,
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundImage: AssetImage(
                                          barber['image'],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Barber name with conditional styling
                                    Text(
                                      barber['name'],
                                      style:
                                          isSelected
                                              ? AppTheme.selectedBarberNameStyle
                                              : AppTheme
                                                  .unselectedBarberNameStyle,
                                    ),
                                    // Barber specialty text
                                    Text(
                                      barber['specialty'],
                                      style: AppTheme.barberSpecialtyStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Only show date selection section if a barber has been selected
            if (selectedBarberId != null) ...[
              // Add vertical spacing between sections
              const SizedBox(height: 24),
              // Container for date selection section
              Container(
                // Add padding inside the container
                padding: const EdgeInsets.all(16.0),
                // Style the container with semi-transparent black background and gold border
                decoration: BoxDecoration(
                  color: AppColors.black.withAlpha(
                    180,
                  ), // Semi-transparent black
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  border: Border.all(
                    color: AppColors.gold.withAlpha(
                      150,
                    ), // Semi-transparent gold border
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Section title
                    Text(
                      'Vælg dato',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // Date selection button
                    ElevatedButton(
                      // Customize button appearance
                      style: AppTheme.goldButtonStyle.copyWith(
                        // Semi-transparent grey background
                        backgroundColor: WidgetStateProperty.all(
                          AppColors.grey.withOpacity(0.8),
                        ),
                        // White text and icon color
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        // Custom padding for better touch target
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      // Open date picker when pressed
                      onPressed: () => _selectDate(context),
                      // Button content layout
                      child: Row(
                        // Make row only as wide as its content
                        mainAxisSize: MainAxisSize.min,
                        // Center content horizontally
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Calendar icon
                          const Icon(
                            Icons.calendar_today,
                            size: 18, // Smaller icon size for better proportion
                          ),
                          // Spacing between icon and text
                          const SizedBox(width: 8),
                          // Display selected date in DD/MM/YYYY format
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Show loading indicator while fetching time slots
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              // Show message if no time slots are available
              else if (availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(
                      180,
                    ), // Semi-transparent black
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ingen ledige tider på den valgte dato',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              // Show available time slots if any exist
              else
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(
                      180,
                    ), // Semi-transparent black
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.gold.withAlpha(
                        150,
                      ), // Semi-transparent gold border
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Section title
                      Text(
                        'Vælg tid',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      // Grid of time slot buttons
                      Wrap(
                        spacing: 8, // Horizontal spacing between buttons
                        runSpacing: 8, // Vertical spacing between rows
                        children:
                            availableSlots.map((time) {
                              // Track if this time slot is currently selected
                              final isSelected = selectedTime == time;
                              return ElevatedButton(
                                // Apply different styles based on selection state
                                style:
                                    isSelected
                                        ? AppTheme.selectedTimeSlotButtonStyle
                                        : AppTheme.timeSlotButtonStyle,
                                // Update selected time when pressed
                                onPressed:
                                    () => setState(() => selectedTime = time),
                                // Display time in HH:MM format
                                child: Text(
                                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              // Show confirmation button only when a time slot is selected
              if (selectedTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Center(
                    child: Container(
                      // Gold background for the button container
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: AppTheme.goldButtonStyle,
                        // Disable button while loading
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  // Proceed to confirmation screen
                                  proceedToConfirmation();
                                  // Show booking confirmation snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tid booket: ${selectedTime!.day}/${selectedTime!.month} kl. ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                                      ),
                                      // Add undo action to the snackbar
                                      action: SnackBarAction(
                                        label: 'Fortryd',
                                        onPressed: () {
                                          // Handle undo action
                                        },
                                      ),
                                    ),
                                  );
                                },
                        // Show loading state or confirmation text
                        child: Text(
                          isLoading ? 'Behandler...' : 'BEKRÆFT',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(Service service) {
    // Display a dialog for selecting service options
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            // Dark theme background
            backgroundColor: AppColors.black,
            // Dialog title
            title: Text(
              'Tilføj Option',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            // Dialog content
            content: Column(
              mainAxisSize: MainAxisSize.min, // Keep dialog compact
              children: [
                // Option for no additional services
                ListTile(
                  title: Text(
                    'Uden tilvalg: ${service.price},-',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Clear selected option and close dialog
                    setState(() => selectedOption = null);
                    Navigator.pop(context);
                  },
                ),
                // Map through available options
                ...service.options!.map(
                  (option) => ListTile(
                    title: Text(
                      '${option.name}: +${option.additionalPrice},-',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Set selected option and close dialog
                      setState(() => selectedOption = option);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showServiceSelectionDialog() {
    // Display a dialog for selecting the main service
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            // Dark theme background
            backgroundColor: AppColors.black,
            // Dialog title
            title: Text(
              'Vælg Service',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            // Scrollable content for many services
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keep dialog compact
                children:
                    services.map((service) {
                      return Column(
                        children: [
                          // Service selection tile
                          ListTile(
                            title: Text(
                              '${service.name}: ${service.price},-',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              // Update selected service and clear any previous option
                              setState(() {
                                selectedServiceId = service.id;
                                selectedOption = null;
                              });
                              // Show options dialog if service has options
                              if (service.options != null) {
                                Navigator.pop(context);
                                _showOptionsDialog(service);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          // Add divider between services
                          Divider(color: AppColors.gold.withAlpha(100)),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }
}
