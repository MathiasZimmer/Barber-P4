// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'user_service.dart'; // To get the current user's ID

// Defines a class named Booking to represent a booking entity in the application.
class Booking {
  // A final String property to store the unique ID of the booking, typically the Firestore document ID.
  final String id;
  // A final String property to store the ID of the user who made the booking.
  // This comment clarifies that it will be the Firebase UID (permanent or anonymous).
  final String userId; // This will be the Firebase UID (permanent or anonymous)
  // A final String property to store the ID of the barber selected for the booking.
  final String barberId;
  // A final, nullable String property to store the name of the barber.
  // This comment explains that it's optional and denormalized for easier access.
  final String? barberName; // Optional: denormalized for convenience
  // A final String property to store the ID of the service booked.
  final String serviceId;
  // A final DateTime property to store the start time of the booking.
  final DateTime startTime;
  // A final DateTime property to store the end time of the booking.
  final DateTime endTime;
  // A final String property to store the status of the booking (e.g., 'confirmed', 'cancelled').
  final String status; // e.g., 'confirmed', 'cancelled'
  // A final, nullable String property to store contact information for guest bookings (e.g., email or phone).
  final String? guestContactInfo; // For guest's email or phone

  // Constructor for the Booking class.
  // It uses named parameters and requires 'id', 'userId', 'barberId', 'serviceId', 'startTime', and 'endTime'.
  Booking({
    required this.id, // 'id' is a required parameter.
    required this.userId, // 'userId' is a required parameter.
    required this.barberId, // 'barberId' is a required parameter.
    this.barberName, // 'barberName' is an optional parameter.
    required this.serviceId, // 'serviceId' is a required parameter.
    required this.startTime, // 'startTime' is a required parameter.
    required this.endTime, // 'endTime' is a required parameter.
    this.status =
        'confirmed', // 'status' is optional and defaults to 'confirmed'.
    this.guestContactInfo, // 'guestContactInfo' is an optional parameter.
  });

  // Defines a factory constructor named 'fromFirestore'.
  // This constructor is used to create a Booking object from a Firestore DocumentSnapshot.
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    // Casts the document data (doc.data()) to a Map<String, dynamic>.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Returns a new instance of Booking, populated with data from the Firestore document.
    return Booking(
      id: doc.id, // Sets the id from the Firestore document's ID.
      // Retrieves 'user_id' from the data map. Uses the null-coalescing operator '??' to default to an empty string if null.
      userId: data['user_id'] ?? '',
      // Retrieves 'barber_id' from the data map, defaulting to an empty string if null.
      barberId: data['barber_id'] ?? '',
      // Retrieves 'barber_name' from the data map. This can be null.
      barberName: data['barber_name'],
      // Retrieves 'service_id' from the data map, defaulting to an empty string if null.
      serviceId: data['service_id'] ?? '',
      // Retrieves 'start_time' (a Firestore Timestamp) and converts it to a DateTime object.
      startTime: (data['start_time'] as Timestamp).toDate(),
      // Retrieves 'end_time' (a Firestore Timestamp) and converts it to a DateTime object.
      endTime: (data['end_time'] as Timestamp).toDate(),
      // Retrieves 'status' from the data map, defaulting to 'confirmed' if null.
      status: data['status'] ?? 'confirmed',
      // Retrieves 'guest_contact_info' from the data map. This can be null.
      guestContactInfo: data['guest_contact_info'],
    );
  }

  // Defines a method named 'toFirestore' that converts a Booking object into a Map<String, dynamic>.
  // This map is suitable for writing data to a Firestore document.
  Map<String, dynamic> toFirestore() {
    // Returns a map where keys are field names in Firestore and values are from the Booking object.
    return {
      'user_id': userId, // Maps the userId property to the 'user_id' field.
      'barber_id':
          barberId, // Maps the barberId property to the 'barber_id' field.
      // Uses a collection 'if' to include 'barber_name' in the map only if barberName is not null.
      if (barberName != null) 'barber_name': barberName,
      'service_id':
          serviceId, // Maps the serviceId property to the 'service_id' field.
      // Converts the startTime (DateTime) to a Firestore Timestamp before storing.
      'start_time': Timestamp.fromDate(startTime),
      // Converts the endTime (DateTime) to a Firestore Timestamp.
      'end_time': Timestamp.fromDate(endTime),
      'status': status, // Maps the status property to the 'status' field.
      // Uses a collection 'if' to include 'guest_contact_info' only if it's not null.
      if (guestContactInfo != null) 'guest_contact_info': guestContactInfo,
    };
  }
}

// Defines a class named BookingService that uses the ChangeNotifier mixin.
// This allows the service to notify listeners (e.g., UI widgets) of state changes.
class BookingService with ChangeNotifier {
  // A final instance of FirebaseFirestore, used for interacting with the Firestore database.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // A reference to a UserService instance.
  // This comment indicates it was made non-final to allow updating it.
  UserService _userService; // Made non-final for updateUserService

  // A private list to store the user's bookings. Initializes as an empty list.
  List<Booking> _userBookings = [];
  // A private boolean to track if bookings are currently being loaded. Initializes to false.
  bool _isLoadingBookings = false;
  // A private, nullable String to store any error messages related to booking operations.
  String? _bookingError;
  // A private boolean to track if the service has been disposed.
  // This comment indicates it was added.
  bool _isDisposed = false; // <<< ADDED: Track if the service is disposed

  // A public getter to access the list of user bookings.
  List<Booking> get userBookings => _userBookings;
  // A public getter to access the loading state for bookings.
  bool get isLoadingBookings => _isLoadingBookings;
  // A public getter to access any booking-related error message.
  String? get bookingError => _bookingError;

  // Constructor for the BookingService class.
  // It takes a UserService instance as a required parameter.
  BookingService(this._userService) {
    // Prints a debug message indicating the creation of a BookingService instance and the associated user.
    print(
      "BookingService INSTANCE CREATED for user: ${_userService.currentUser?.uid ?? 'none'}",
    );
    // Checks if the user is currently logged in via the UserService.
    if (_userService.isLoggedIn) {
      // If logged in, immediately fetch the user's bookings.
      fetchUserBookings();
    }
    // Adds a listener to the _userService instance.
    // The _handleUserChange method will be called whenever the UserService notifies its listeners (e.g., on auth state changes).
    _userService.addListener(_handleUserChange);
  }
  // This comment describes the purpose of the _safeNotifyListeners helper method.
  // Helper to safely call notifyListeners
  // Defines a private method named _safeNotifyListeners to prevent calling `notifyListeners` on a disposed object.
  void _safeNotifyListeners() {
    // Checks if the service instance has not been disposed.
    if (!_isDisposed) {
      // If not disposed, call the standard `notifyListeners` method from ChangeNotifier.
      notifyListeners();
    } else {
      // If disposed, print a debug message to the console indicating the attempt.
      print(
        "BookingService: Attempted to notifyListeners on a disposed instance.",
      );
    }
  }

  // This comment explains when and how to use the updateUserService method, typically with ChangeNotifierProxyProvider.
  // Call this from ChangeNotifierProxyProvider's update callback if you want to reuse the instance
  // Defines a public method to update the internal UserService dependency.
  // This is useful when using providers like ChangeNotifierProxyProvider where dependencies can change.
  void updateUserService(UserService newUserService) {
    // If the BookingService instance is already disposed, do nothing and return.
    if (_isDisposed)
      return; // This comment clarifies not to operate if disposed.
    // Checks if the new UserService instance is different from the current one.
    if (_userService != newUserService) {
      // If different, remove the _handleUserChange listener from the old _userService instance to prevent memory leaks.
      _userService.removeListener(
        _handleUserChange,
      ); // This comment clarifies cleaning up the old listener.
      // Update the internal _userService reference to the new instance.
      _userService =
          newUserService; // This comment clarifies updating to the new service.
      // Add the _handleUserChange listener to the new _userService instance.
      _userService.addListener(
        _handleUserChange,
      ); // This comment clarifies adding the listener to the new service.
      // Print a debug message indicating that the UserService dependency has been updated.
      print(
        "BookingService: UserService dependency UPDATED to user: ${_userService.currentUser?.uid ?? 'none'}",
      );
      // Immediately call _handleUserChange to react to the state of the new UserService instance.
      _handleUserChange(); // This comment clarifies immediately reacting to the new user state.
    }
  }

  // Defines a private method to handle changes in the user's authentication state from UserService.
  void _handleUserChange() {
    // If the BookingService instance is disposed, do nothing and return.
    if (_isDisposed) return;
    // Print a debug message indicating that _handleUserChange was called and the current login status.
    print(
      "BookingService: _handleUserChange. User logged in: ${_userService.isLoggedIn}",
    );
    // Checks if the user is currently logged in via the _userService.
    if (_userService.isLoggedIn) {
      // If logged in, fetch the user's bookings.
      fetchUserBookings();
    } else {
      // If not logged in (e.g., user logged out), clear the local list of user bookings.
      _userBookings = [];
      // Clear any existing booking error messages.
      _bookingError = null;
      // Set the loading state for bookings to false.
      _isLoadingBookings = false;
      // Safely notify listeners about these state changes (empty bookings, no error, not loading).
      _safeNotifyListeners(); // This comment highlights the use of _safeNotifyListeners.
    }
  }

  // Overrides the dispose method from ChangeNotifier.
  // This method is called when the ChangeNotifier is no longer needed and should release its resources.
  @override
  void dispose() {
    // Print a debug message indicating that the BookingService instance is being disposed.
    print(
      "BookingService INSTANCE DISPOSED for user: ${_userService.currentUser?.uid ?? 'none'}",
    );
    // Set the _isDisposed flag to true, indicating that this instance has been disposed.
    _isDisposed =
        true; // This comment indicates setting the flag. // <<< SET FLAG
    // Remove the _handleUserChange listener from the _userService instance to prevent memory leaks
    // and to stop reacting to further user changes on a disposed service.
    _userService.removeListener(_handleUserChange);
    // Call the dispose method of the superclass (ChangeNotifier).
    super.dispose();
  }

  // Defines an asynchronous public method to check if a specific time slot is available for a given barber.
  // It returns a Future<bool>: true if available, false otherwise.
  Future<bool> isTimeSlotAvailable({
    required String barberId, // The ID of the barber.
    required DateTime
    desiredStart, // The desired start time of the appointment.
    required DateTime desiredEnd, // The desired end time of the appointment.
  }) async {
    // Checks if the service instance has been disposed.
    if (_isDisposed) {
      // If disposed, return false. The comment suggests throwing an error is an alternative but returning false is safer for a check.
      return false; // Or throw an error, but returning false is safer for a check
    }
    // Starts a 'try' block to handle potential exceptions during the Firestore query.
    try {
      // This comment indicates that the rest of the method (the Firestore query part) is fine
      // because it doesn't call notifyListeners directly, which is the main concern with disposed objects.
      // ... (rest of the method is fine as it doesn't call notifyListeners) ...
      // Performs a Firestore query to find any existing appointments that overlap with the desired time slot for the given barber.
      final querySnapshot =
          await _firestore // Accesses the Firestore instance.
              .collection(
                'appointments',
              ) // Targets the 'appointments' collection.
              .where(
                'barber_id',
                isEqualTo: barberId,
              ) // Filters by the specified barberId.
              .where(
                'status',
                isEqualTo: 'confirmed',
              ) // Filters for appointments with 'confirmed' status.
              // Filters for appointments whose start time is before the desired end time.
              // This helps find appointments that start before or during the desired slot and might overlap.
              .where('start_time', isLessThan: Timestamp.fromDate(desiredEnd))
              // Filters for appointments whose end time is after the desired start time.
              // This helps find appointments that end during or after the desired slot and might overlap.
              .where(
                'end_time',
                isGreaterThan: Timestamp.fromDate(desiredStart),
              )
              .limit(
                1,
              ) // Limits the result to 1 document, as we only need to know if *any* overlap exists.
              .get(); // Executes the query and gets the QuerySnapshot.
      // Returns true if querySnapshot.docs is empty (meaning no overlapping appointments were found),
      // indicating the time slot is available. Otherwise, returns false.
      return querySnapshot.docs.isEmpty;
      // Catches any exceptions that occur during the Firestore query.
    } catch (e) {
      // Prints an error message to the console.
      print('BookingService: Error checking time slot availability: $e');
      // Throws a new Exception with a more user-friendly message, wrapping the original error.
      // This allows the caller to handle the error more specifically if needed.
      throw Exception('Error checking availability: $e');
    }
  }

  // Defines an asynchronous public method to create a new appointment (booking).
  // It takes various details about the appointment as required and optional parameters.
  Future<void> createAppointment({
    required String barberId, // The ID of the barber for the appointment.
    String? barberName, // Optional: The name of the barber.
    required String serviceId, // The ID of the service being booked.
    required DateTime startTime, // The start time of the appointment.
    required DateTime endTime, // The end time of the appointment.
    String?
    guestContactForBooking, // This comment indicates it was added for guest flow. // Added for guest flow
  }) async {
    // If the BookingService instance has been disposed, do nothing and return to prevent errors.
    if (_isDisposed) return;
    // Checks if the user is not logged in or if the currentUser object in UserService is null.
    // This is a crucial precondition for creating a booking associated with a user.
    if (!_userService.isLoggedIn || _userService.currentUser == null) {
      // Sets a user-facing error message in Danish: "User session not found. Please try again."
      _bookingError = 'Bruger session ikke fundet. Prøv venligst igen.';
      // Sets the loading state for bookings to false as the operation cannot proceed.
      _isLoadingBookings = false;
      // Safely notifies listeners about the state changes (error message set, loading is false).
      _safeNotifyListeners(); // This comment highlights the use of _safeNotifyListeners.
      // Prints a debug message to the console indicating why the appointment creation failed.
      print(
        'BookingService: Create appointment failed - user not logged in or no current user.',
      );
      // Exits the method as the preconditions are not met.
      return;
    }
    // Retrieves the UID of the currently logged-in user from UserService.
    // The '!' non-null assertion operator is used on _userService.currentUser because its nullity was checked above.
    final String userId = _userService.currentUser!.uid;
    // Prints a debug message indicating for which user the appointment is being created, and if they are anonymous.
    print(
      'BookingService: Creating appointment for user UID: $userId (Anonymous: ${_userService.currentUser!.isAnonymous})',
    );

    // Sets the loading state for bookings to true, indicating an operation is in progress.
    _isLoadingBookings = true;
    // Clears any pre-existing booking error message.
    _bookingError = null;
    // Safely notifies listeners about these state changes.
    _safeNotifyListeners(); // This comment highlights the use of _safeNotifyListeners.

    // Starts a 'try' block to handle potential exceptions during the Firestore operation.
    try {
      // Creates a new Booking object with the provided details.
      // The 'id' is initially empty as Firestore will generate it.
      final newBooking = Booking(
        id: '', // Firestore will generate this ID.
        userId: userId, // The UID of the user making the booking.
        barberId: barberId, // The ID of the selected barber.
        barberName: barberName, // The name of the barber (optional).
        serviceId: serviceId, // The ID of the selected service.
        startTime: startTime, // The start time of the appointment.
        endTime: endTime, // The end time of the appointment.
        status:
            'confirmed', // Sets the initial status of the booking to 'confirmed'.
        // Sets guestContactInfo only if the current user is anonymous and guestContactForBooking is provided.
        // Otherwise, it's set to null.
        guestContactInfo:
            _userService
                    .currentUser!
                    .isAnonymous // Check if the user is anonymous.
                ? guestContactForBooking // If anonymous, use the provided guest contact info.
                : null, // Otherwise, set to null (for registered users).
      );

      // Asynchronously adds the new booking to the 'appointments' collection in Firestore.
      // `newBooking.toFirestore()` converts the Booking object to a Map suitable for Firestore.
      // The `add` method returns a DocumentReference to the newly created document.
      DocumentReference docRef = await _firestore
          .collection('appointments')
          .add(newBooking.toFirestore());
      // Prints a debug message indicating successful appointment creation and the ID of the new document.
      print('BookingService: Appointment created with ID: ${docRef.id}');
      // Checks if the service is not disposed before making another asynchronous call that might notify listeners.
      if (!_isDisposed) {
        // This comment clarifies the check before an async call that notifies.
        // Check before another async call that notifies
        // After successfully creating the appointment, re-fetch the user's bookings to update the local list.
        await fetchUserBookings();
      }
      // Catches any exceptions that occur during the try block (e.g., Firestore errors).
    } catch (e) {
      // If the service is not disposed, set a user-facing error message in Danish: "Could not complete booking: [error]".
      if (!_isDisposed) _bookingError = 'Kunne ikke gennemføre booking: $e';
      // Prints detailed error information to the console for debugging.
      print('BookingService: Booking error details: $e');
      // The 'finally' block executes regardless of whether an exception occurred or not.
      // It's used here for cleanup and ensuring consistent state updates.
    } finally {
      // Checks if the service instance has not been disposed before modifying its state.
      if (!_isDisposed) {
        // This comment clarifies ensuring state modification only if not disposed.
        // Ensure we only modify state if not disposed
        // If bookings were being loaded OR an error occurred, set loading to false.
        // This ensures _isLoadingBookings is reset after the operation.
        if (_isLoadingBookings || _bookingError != null) {
          _isLoadingBookings = false;
        }
        // Safely notify listeners about the final state changes (loading status, potential error message).
        _safeNotifyListeners(); // This comment highlights the use of _safeNotifyListeners.
      }
    }
  }

  // Defines an asynchronous public method to fetch bookings for the currently logged-in user.
  Future<void> fetchUserBookings() async {
    // If the BookingService instance has been disposed, do nothing and return to prevent errors.
    if (_isDisposed) return;
    // Checks if the user is not logged in or if the currentUser object in UserService is null.
    // If so, there are no user-specific bookings to fetch.
    if (!_userService.isLoggedIn || _userService.currentUser == null) {
      // Clears the local list of user bookings.
      _userBookings = [];
      // Sets the loading state for bookings to false.
      _isLoadingBookings = false;
      // Safely notifies listeners about these state changes (empty bookings, not loading).
      _safeNotifyListeners();
      // Exits the method as there's no user to fetch bookings for.
      return;
    }
    // Retrieves the UID of the currently logged-in user from UserService.
    // The '!' non-null assertion operator is used on _userService.currentUser because its nullity was checked above.
    final String userId = _userService.currentUser!.uid;
    // Prints a debug message indicating for which user bookings are being fetched.
    print('BookingService: Fetching bookings for user UID: $userId');

    // Sets the loading state for bookings to true, indicating an operation is in progress.
    _isLoadingBookings = true;
    // Clears any pre-existing booking error message.
    _bookingError = null;
    // Safely notifies listeners that loading has started and the state has changed.
    _safeNotifyListeners(); // This comment clarifies the purpose of this notification.

    // Starts a 'try' block to handle potential exceptions during the Firestore query.
    try {
      // Performs a Firestore query to get appointments for the current user.
      final querySnapshot =
          await _firestore // Accesses the Firestore instance.
              .collection(
                'appointments',
              ) // Targets the 'appointments' collection.
              .where(
                'user_id',
                isEqualTo: userId,
              ) // Filters by the current user's ID.
              .where(
                'status',
                isEqualTo: 'confirmed',
              ) // Filters for appointments with 'confirmed' status.
              // Orders the results by 'start_time' in descending order (newest first).
              .orderBy('start_time', descending: true)
              .get(); // Executes the query and gets the QuerySnapshot.

      // Checks if the service instance has not been disposed before updating its state.
      if (!_isDisposed) {
        // Converts the fetched Firestore documents into a list of Booking objects.
        // `querySnapshot.docs` is a list of DocumentSnapshot.
        // `.map((doc) => Booking.fromFirestore(doc))` iterates over each document and creates a Booking object using the factory constructor.
        // `.toList()` converts the resulting iterable into a List.
        _userBookings =
            querySnapshot.docs
                .map((doc) => Booking.fromFirestore(doc))
                .toList();
        // Prints a debug message indicating the number of bookings fetched.
        // The comment "(now filtering for confirmed)" seems to be a leftover or slightly inaccurate,
        // as the filtering for 'confirmed' status was done in the Firestore query itself.
        print(
          'BookingService: Fetched ${_userBookings.length} bookings (now filtering for confirmed).',
        );
      }
      // Catches any exceptions that occur during the Firestore query or data processing.
    } catch (e) {
      // If the service is not disposed, set a user-facing error message.
      if (!_isDisposed) _bookingError = 'Could not load bookings: $e';
      // Prints detailed error information to the console for debugging.
      print('BookingService: Error fetching user bookings: $e');
      // Clears the user bookings list on error to ensure no stale or incorrect data is shown.
      // The 'finally' block executes regardless of whether an exception occurred or not.
      // It's used here for cleanup, specifically to reset the loading state.
    } finally {
      // Checks if the service instance has not been disposed before modifying its state.
      if (!_isDisposed) {
        // Sets the loading state for bookings to false, as the fetching operation (successful or failed) has concluded.
        _isLoadingBookings = false;
        // Safely notifies listeners about the final state changes (loading status, updated bookings list, or error message).
        _safeNotifyListeners();
      }
    }
    // Closes the fetchUserBookings method.
  }

  // Defines an asynchronous public method to cancel a specific booking.
  // It takes the 'bookingId' (a String) of the booking to be cancelled as input.
  Future<void> cancelBooking(String bookingId) async {
    // If the BookingService instance has been disposed, do nothing and return.
    if (_isDisposed) return;
    // Checks if the user is not logged in or if the currentUser object in UserService is null.
    // A user must be logged in to cancel their own bookings.
    if (!_userService.isLoggedIn || _userService.currentUser == null) {
      // Sets a user-facing error message in Danish: "User not logged in to cancel."
      _bookingError = "Bruger ikke logget ind for at annullere.";
      // Safely notifies listeners about the error.
      _safeNotifyListeners(); // This comment highlights the use of _safeNotifyListeners.
      // Throws an Exception to indicate a critical precondition failure.
      // The caller of this method might want to catch this and handle it appropriately.
      throw Exception('User not logged in to cancel appointment.');
    }
    // Prints a debug message indicating the attempt to cancel a booking, including the booking ID and user UID.
    print(
      'BookingService: Attempting to cancel booking ID: $bookingId for user UID: ${_userService.currentUser!.uid}',
    );
    // Clears any pre-existing booking error message.
    _bookingError =
        null; // It might be better to notify listeners here if _bookingError was previously set.

    // Starts a 'try' block to handle potential exceptions during the Firestore update operation.
    try {
      // Asynchronously updates the specified booking document in the 'appointments' collection in Firestore.
      await _firestore.collection('appointments').doc(bookingId).update({
        // Sets the 'status' field of the booking to 'cancelled'.
        'status': 'cancelled',
        // Adds or updates an 'updatedAt' field with the server's timestamp, indicating when the cancellation occurred.
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Prints a debug message indicating that the booking status was successfully updated in Firestore.
      print(
        'BookingService: Booking ID: $bookingId status updated to cancelled in Firestore.',
      );

      if (!_isDisposed) {
        // Check before updating state
        int index = _userBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _userBookings[index] = Booking(
            id: _userBookings[index].id,
            userId: _userBookings[index].userId,
            barberId: _userBookings[index].barberId,
            barberName: _userBookings[index].barberName,
            serviceId: _userBookings[index].serviceId,
            startTime: _userBookings[index].startTime,
            endTime: _userBookings[index].endTime,
            status: 'cancelled',
          );
          print(
            'BookingService: Local booking ID: $bookingId status updated to cancelled.',
          );
          notifyListeners(); // Make sure this is called after updating local state
        } else {
          await fetchUserBookings(); // Refetch if not found, ensure fetchUserBookings is also safe
        }
        _safeNotifyListeners(); // Notify after local update
      }
    } catch (e) {
      if (!_isDisposed) _bookingError = 'Error cancelling booking: $e';
      print('BookingService: Error cancelling booking: $e');
      if (!_isDisposed) _safeNotifyListeners();
      throw Exception('Error cancelling booking: $e');
    }
  }

  // Defines an asynchronous public method to get a list of available time slots for a given barber, date, and service duration.
  // It returns a Future<List<DateTime>>, where each DateTime represents the start time of an available slot.
  Future<List<DateTime>> getAvailableTimeSlots({
    required String
    barberId, // The ID of the barber for whom to find available slots.
    required DateTime
    date, // The specific date for which to find available slots.
    required int
    serviceDurationMinutes, // The duration of the service in minutes, needed to check for continuous availability.
  }) async {
    // If the BookingService instance has been disposed, return an empty list immediately to prevent errors.
    if (_isDisposed)
      return []; // This comment clarifies returning empty if disposed.

    // Initializes an empty list to store the available time slots that will be identified.
    final List<DateTime> availableSlots = [];
    // Checks if the selected date is a Sunday (weekday 7). If so, returns an empty list as the salon is closed.
    if (date.weekday == 7) return []; // Sunday is weekday 7.

    // Declares variables to store the start and end hours of operation for the selected date.
    int startHour, endHour;
    // Uses a switch statement based on the day of the week (date.weekday) to set the operating hours.
    // Monday is 1, Tuesday is 2, ..., Sunday is 7.
    switch (date.weekday) {
      case 5: // Friday (weekday 5)
        startHour = 9; // Salon opens at 9 AM.
        endHour = 20; // Salon closes at 8 PM.
        break; // Exits the switch statement.
      case 6: // Saturday (weekday 6)
        startHour = 9; // Salon opens at 9 AM.
        endHour = 16; // Salon closes at 4 PM.
        break; // Exits the switch statement.
      default: // For all other weekdays (Monday to Thursday)
        startHour = 9; // Salon opens at 9 AM.
        endHour = 19; // Salon closes at 7 PM.
    }

    // Creates a DateTime object representing the very beginning of the selected date (00:00:00).
    // This is used as the lower bound for querying daily bookings.
    final DateTime dayStart = DateTime(
      date.year,
      date.month,
      date.day,
      0, // Hour
      0, // Minute
      0, // Second
    );
    // Creates a DateTime object representing the very end of the selected date (23:59:59).
    // This is used as the upper bound for querying daily bookings.
    final DateTime dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      23, // Hour
      59, // Minute
      59, // Second
    );

    // Starts a 'try' block to handle potential exceptions during the Firestore query.
    try {
      // Prints a debug message indicating the attempt to fetch daily bookings.
      print(
        'BookingService: Fetching daily bookings for barber $barberId on $date',
      );
      // Performs a Firestore query to get all confirmed appointments for the specified barber on the given date.
      final querySnapshot =
          await _firestore // Accesses the Firestore instance.
              .collection(
                'appointments',
              ) // Targets the 'appointments' collection.
              .where(
                'barber_id',
                isEqualTo: barberId,
              ) // Filters by the specified barberId.
              .where(
                'status',
                isEqualTo: 'confirmed',
              ) // Filters for appointments with 'confirmed' status.
              // Filters for appointments whose start time is on or after the beginning of the selected day.
              .where(
                'start_time',
                isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
              )
              // Filters for appointments whose start time is on or before the end of the selected day.
              .where(
                'start_time',
                isLessThanOrEqualTo: Timestamp.fromDate(dayEnd),
              )
              .get(); // Executes the query and gets the QuerySnapshot.

      // Checks again if the service instance has been disposed after an `await` call,
      // as the widget using this service might have been disposed while waiting.
      if (_isDisposed)
        return []; // This comment clarifies checking again after await.

      // Converts the fetched Firestore documents into a list of Booking objects.
      final List<Booking> dailyBookings =
          querySnapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      // Prints a debug message indicating how many bookings were found for the day.
      print(
        'BookingService: Found ${dailyBookings.length} bookings for the day.',
      );

      // Initializes `currentTimeSlot` to the start of the salon's operating hours on the selected date.
      // This variable will be iterated through the day at `slotGranularity` intervals.
      DateTime currentTimeSlot = DateTime(
        date.year,
        date.month,
        date.day,
        startHour, // The determined start hour of operation.
        0, // Start at the beginning of the hour.
      );
      // Defines `endOfDayOperation` as the time when the salon closes on the selected date.
      // This is used as the upper limit for checking available slots.
      final DateTime endOfDayOperation = DateTime(
        date.year,
        date.month,
        date.day,
        endHour, // The determined end hour of operation.
        0, // End at the beginning of the hour.
      );
      // Defines the granularity for checking time slots (e.g., every 15 minutes).
      // This means potential appointment start times will be considered at these intervals.
      const Duration slotGranularity = Duration(minutes: 15);
      // The logic for iterating through time slots and checking availability against `dailyBookings`

      // Starts a 'while' loop to iterate through potential time slots within the salon's operating hours.
      // The loop continues as long as the end of the potential service (currentTimeSlot + serviceDurationMinutes)
      // is before or at the same moment as the end of the day's operation (endOfDayOperation).
      while (currentTimeSlot // The current potential start time being checked.
              .add(
                Duration(minutes: serviceDurationMinutes),
              ) // Calculates the end time of a service starting at currentTimeSlot.
              .isBefore(
                endOfDayOperation,
              ) || // Checks if this service end time is before the salon closes.
          currentTimeSlot // The current potential start time.
              .add(
                Duration(minutes: serviceDurationMinutes),
              ) // Calculates the service end time again.
              .isAtSameMomentAs(endOfDayOperation)) {
        // Checks if this service end time is exactly when the salon closes.
        // Checks if the service instance has been disposed during the loop's execution.
        // This is important for long-running loops or loops with await calls (though none here).
        if (_isDisposed)
          return []; // This comment clarifies checking inside the loop.

        // Checks if the current hour of `currentTimeSlot` is 12 (noon).
        // This is likely to implement a lunch break or a specific non-bookable period.
        if (currentTimeSlot.hour == 12) {
          // If it's noon, advance `currentTimeSlot` to 1 PM (13:00) of the same day.
          currentTimeSlot = DateTime(date.year, date.month, date.day, 13, 0);
          // After advancing past the 12 PM hour, re-check if the new `currentTimeSlot` (now 1 PM)
          // plus the service duration still fits within the operating hours.
          if (!(currentTimeSlot // The new currentTimeSlot (1 PM).
                  .add(
                    Duration(minutes: serviceDurationMinutes),
                  ) // Its corresponding service end time.
                  .isBefore(
                    endOfDayOperation,
                  ) || // Check if it's before closing.
              currentTimeSlot // The new currentTimeSlot (1 PM).
                  .add(
                    Duration(minutes: serviceDurationMinutes),
                  ) // Its corresponding service end time.
                  .isAtSameMomentAs(endOfDayOperation))) {
            // Check if it's exactly at closing.
            // If the service starting at 1 PM (after skipping the 12 PM hour) no longer fits,
            // break out of the main 'while' loop as no further slots will be available.
            break;
          }
        }

        // Calculates the end time (`slotEnd`) for a potential service starting at `currentTimeSlot`
        // and lasting for `serviceDurationMinutes`.
        DateTime slotEnd = currentTimeSlot.add(
          Duration(minutes: serviceDurationMinutes),
        );
        // Initializes a boolean flag `isSlotFree` to true, assuming the slot is available until proven otherwise.
        bool isSlotFree = true;

        // Iterates through the `dailyBookings` (list of existing confirmed bookings for the day)
        // to check for overlaps with the current potential time slot (`currentTimeSlot` to `slotEnd`).
        for (final booking in dailyBookings) {
          // Checks for overlap:
          // A slot overlaps with an existing booking if:
          // 1. The slot's start time (`currentTimeSlot`) is before the booking's end time, AND
          // 2. The slot's end time (`slotEnd`) is after the booking's start time.
          if (currentTimeSlot.isBefore(booking.endTime) &&
              slotEnd.isAfter(booking.startTime)) {
            // If an overlap is found, set `isSlotFree` to false.
            isSlotFree = false;
            // Break out of the inner 'for' loop as we've already determined the slot is not free.
            break;
          }
        }

        // After checking against all existing bookings, if `isSlotFree` is still true,
        // it means the current time slot is available.
        if (isSlotFree) {
          // Adds the `currentTimeSlot` to the `availableSlots` list.
          // `DateTime.parse(currentTimeSlot.toIso8601String())` is used to create a new DateTime object
          // from the ISO 8601 string representation. This ensures a distinct object is added to the list,
          // which can be important if DateTime objects are mutable or if identity matters later.
          availableSlots.add(DateTime.parse(currentTimeSlot.toIso8601String()));
        }
        // Advances `currentTimeSlot` by `slotGranularity` (e.g., 15 minutes)
        // to check the next potential start time in the main 'while' loop.
        currentTimeSlot = currentTimeSlot.add(slotGranularity);
      } // End of the main 'while' loop.
      // Prints a debug message indicating the number of available slots found.
      print('BookingService: Found ${availableSlots.length} available slots.');
      // Returns the list of identified available time slots.
      return availableSlots;
      // Catches any exceptions that might occur within the 'try' block.
    } catch (e) {
      // Prints an error message to the console.
      print('BookingService: Error getting available time slots: $e');
      // Throws a new Exception with a more user-friendly message, wrapping the original error.
      // This allows the caller to handle the error more specifically.
      throw Exception('Error generating time slots: $e');
    }
    // Closes the getAvailableTimeSlots method.
  }

  // Defines a public method to clear any existing booking error message.
  void clearBookingError() {
    // If the BookingService instance has been disposed, do nothing and return.
    if (_isDisposed) return;
    // Checks if there is currently a booking error message set.
    if (_bookingError != null) {
      // If an error message exists, set `_bookingError` to null.
      _bookingError = null;
      // Safely notifies listeners that the booking error state has changed.
      _safeNotifyListeners();
    }
  }
}
