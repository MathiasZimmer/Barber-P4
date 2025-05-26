// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/booking_service.dart'; // For Booking class and service type
import '../services/user_service.dart'; // For AppUser and service type
import '../main.dart'; // For AppColors if defined there
import '../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // No need to instantiate services here, Provider will manage them.
  // bool _isLoading = true; // This will be managed by BookingService
  // List<Map<String, dynamic>> _bookings = []; // This will come from BookingService

  @override
  void initState() {
    super.initState();
    // Fetch initial bookings if not already loaded by BookingService's listener
    // This ensures data is loaded if the user navigates directly to this screen
    // after the app has been in the background.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = context.read<UserService>();
      if (userService.isLoggedIn) {
        // Use context.read for one-time action
        context.read<BookingService>().fetchUserBookings();
      } else {
        // Should not happen if routing is correct, but handle defensively
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    });
  }

  // No need for _checkUserAndLoad or _loadBookings methods here.
  // BookingService (Option 1) will manage loading and the list of bookings.

  Future<void> _performLogout() async {
    final userService = context.read<UserService>();
    try {
      print("UserProfileScreen: Calling userService.logout()");
      await userService.logout();
      print(
        "UserProfileScreen: userService.logout() completed. User logged out: ${!userService.isLoggedIn}",
      );

      // After logout, navigate to home screen
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        print("UserProfileScreen: Navigated to '/' after logout.");
      }
    } catch (e) {
      print("UserProfileScreen: Error during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logout fejlede: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _performCancelBooking(String bookingId) async {
    // Get the BookingService from Provider
    final bookingService = context.read<BookingService>();
    try {
      print("Attempting to cancel booking: $bookingId"); // Debug print
      await bookingService.cancelBooking(bookingId);
      print("Booking cancelled successfully"); // Debug print

      // Force a refresh of the bookings list
      await bookingService.fetchUserBookings();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking annulleret')));
      }
    } catch (e) {
      print("Error cancelling booking: $e"); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fejl ved annullering: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make sure we're watching the BookingService
    final bookingService = context.watch<BookingService>();
    print(
      "UserProfileScreen: Rebuilding with ${bookingService.userBookings.length} bookings",
    );

    // Access services from Provider
    // Use context.watch to rebuild the UI when service state changes
    final userService = context.watch<UserService>();

    // If user is somehow not logged in and lands here, redirect (defensive)
    if (!userService.isLoggedIn) {
      // This part ideally shouldn't be reached if your routing logic in MyApp
      // based on userService.isLoggedIn is working correctly.
      // Using a post frame callback to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      });
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ); // Show loading while redirecting
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // No back button if this is a main tab
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0.0), // Adjusted padding
              child: GestureDetector(
                onTap: () {
                  // No async needed for direct navigation
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },
                child: Row(
                  children: const [
                    Text(
                      'SALON LAURA',
                      style: TextStyle(
                        letterSpacing: 0.8,
                        fontSize: 15,
                        color: AppColors.gold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.content_cut, size: 16, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Log ud',
            onPressed: () async {
              final confirmLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text('Log ud', style: AppTheme.dialogTitleStyle),
                    content: Text(
                      'Er du sikker på, at du vil logge ud?',
                      style: AppTheme.dialogContentStyle,
                    ),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('NEJ'),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent[100],
                        ),
                        child: const Text('JA, LOG UD'),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true && mounted) {
                await _performLogout();
              }
            },
          ),
        ],
      ),
      body: Builder(
        // Use Builder to get a new context if needed for ScaffoldMessenger
        builder: (BuildContext innerContext) {
          // innerContext for ScaffoldMessenger
          if (bookingService.isLoadingBookings &&
              bookingService.userBookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bookingService.bookingError != null &&
              bookingService.userBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Fejl: ${bookingService.bookingError}',
                    style: TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<BookingService>()
                          .fetchUserBookings(); // Retry
                    },
                    child: Text("Prøv igen"),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mine Bookinger',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white, fontSize: 18),
                          ),
                          if (bookingService.isLoadingBookings)
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      if (!bookingService.isLoadingBookings &&
                          bookingService.userBookings.isEmpty)
                        const Center(
                          child: Text(
                            'Ingen aktive bookinger',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else if (bookingService.userBookings.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookingService.userBookings.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            // Use the Booking object from BookingService
                            final booking = bookingService.userBookings[index];
                            final startTime =
                                booking.startTime; // Already a DateTime

                            return Card(
                              color: AppColors.black.withAlpha(180),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: AppColors.gold.withAlpha(150),
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    // You might need a way to map barberId to image or store image URL in booking
                                    booking.barberId ==
                                            '7d9fb269-b171-49c5-93ef-7097a99e02e3'
                                        ? 'assets/barber1.jpg'
                                        : 'assets/barber2.jpg',
                                  ),
                                ),
                                title: Text(
                                  // Access barberName from Booking object
                                  'Tid hos ${booking.barberName ?? 'Frisør'}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${startTime.day}/${startTime.month}/${startTime.year} - '
                                  '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red[300],
                                  onPressed:
                                      () => showDialog(
                                        context:
                                            context, // Use the build context
                                        builder:
                                            (dialogContext) => AlertDialog(
                                              // Use dialogContext
                                              backgroundColor: AppColors.black,
                                              title: const Text(
                                                'Annuller Booking',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: const [
                                                  Text(
                                                    'Er du sikker på, at du vil annullere denne booking?',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'OBS: Ved aflysning under 24 timer før bekræftet tid, bedes du ringe til salonen.',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        dialogContext,
                                                      ),
                                                  child: const Text('NEJ'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                    _performCancelBooking(
                                                      booking.id,
                                                    ); // Use booking.id
                                                  },
                                                  child: Text(
                                                    'JA',
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
