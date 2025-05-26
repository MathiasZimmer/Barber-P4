// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'user_service.dart'; // To get the current user's ID

class Booking {
  final String id;
  final String userId; // This will be the Firebase UID (permanent or anonymous)
  final String barberId;
  final String? barberName; // Optional: denormalized for convenience
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // e.g., 'confirmed', 'cancelled'
  final String? guestContactInfo; // For guest's email or phone

  Booking({
    required this.id,
    required this.userId,
    required this.barberId,
    this.barberName,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    this.status = 'confirmed',
    this.guestContactInfo,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['user_id'] ?? '',
      barberId: data['barber_id'] ?? '',
      barberName: data['barber_name'],
      serviceId: data['service_id'] ?? '',
      startTime: (data['start_time'] as Timestamp).toDate(),
      endTime: (data['end_time'] as Timestamp).toDate(),
      status: data['status'] ?? 'confirmed',
      guestContactInfo: data['guest_contact_info'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'barber_id': barberId,
      if (barberName != null) 'barber_name': barberName,
      'service_id': serviceId,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'status': status,
      if (guestContactInfo != null) 'guest_contact_info': guestContactInfo,
    };
  }
}

class BookingService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService _userService; // Made non-final for updateUserService

  List<Booking> _userBookings = [];
  bool _isLoadingBookings = false;
  String? _bookingError;
  bool _isDisposed = false; // <<< ADDED: Track if the service is disposed

  List<Booking> get userBookings => _userBookings;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get bookingError => _bookingError;

  BookingService(this._userService) {
    print(
      "BookingService INSTANCE CREATED for user: ${_userService.currentUser?.uid ?? 'none'}",
    );
    if (_userService.isLoggedIn) {
      fetchUserBookings();
    }
    _userService.addListener(_handleUserChange);
  }

  // Helper to safely call notifyListeners
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      print(
        "BookingService: Attempted to notifyListeners on a disposed instance.",
      );
    }
  }

  // Call this from ChangeNotifierProxyProvider's update callback if you want to reuse the instance
  void updateUserService(UserService newUserService) {
    if (_isDisposed) return; // Don't operate if disposed
    if (_userService != newUserService) {
      _userService.removeListener(_handleUserChange); // Clean up old listener
      _userService = newUserService; // Update to new service
      _userService.addListener(
        _handleUserChange,
      ); // Add listener to new service
      print(
        "BookingService: UserService dependency UPDATED to user: ${_userService.currentUser?.uid ?? 'none'}",
      );
      _handleUserChange(); // Immediately react to the new user state
    }
  }

  void _handleUserChange() {
    if (_isDisposed) return;
    print(
      "BookingService: _handleUserChange. User logged in: ${_userService.isLoggedIn}",
    );
    if (_userService.isLoggedIn) {
      fetchUserBookings();
    } else {
      _userBookings = [];
      _bookingError = null;
      _isLoadingBookings = false;
      _safeNotifyListeners(); // USE _safeNotifyListeners
    }
  }

  @override
  void dispose() {
    print(
      "BookingService INSTANCE DISPOSED for user: ${_userService.currentUser?.uid ?? 'none'}",
    );
    _isDisposed = true; // <<< SET FLAG
    _userService.removeListener(_handleUserChange);
    super.dispose();
  }

  Future<bool> isTimeSlotAvailable({
    required String barberId,
    required DateTime desiredStart,
    required DateTime desiredEnd,
  }) async {
    if (_isDisposed) {
      return false; // Or throw an error, but returning false is safer for a check
    }
    try {
      // ... (rest of the method is fine as it doesn't call notifyListeners) ...
      final querySnapshot =
          await _firestore
              .collection('appointments')
              .where('barber_id', isEqualTo: barberId)
              .where('status', isEqualTo: 'confirmed')
              .where('start_time', isLessThan: Timestamp.fromDate(desiredEnd))
              .where(
                'end_time',
                isGreaterThan: Timestamp.fromDate(desiredStart),
              )
              .limit(1)
              .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('BookingService: Error checking time slot availability: $e');
      throw Exception('Error checking availability: $e');
    }
  }

  Future<void> createAppointment({
    required String barberId,
    String? barberName,
    required String serviceId,
    required DateTime startTime,
    required DateTime endTime,
    String? guestContactForBooking, // Added for guest flow
  }) async {
    if (_isDisposed) return;
    if (!_userService.isLoggedIn || _userService.currentUser == null) {
      _bookingError = 'Bruger session ikke fundet. Prøv venligst igen.';
      _isLoadingBookings = false;
      _safeNotifyListeners(); // USE _safeNotifyListeners
      print(
        'BookingService: Create appointment failed - user not logged in or no current user.',
      );
      return;
    }
    final String userId = _userService.currentUser!.uid;
    print(
      'BookingService: Creating appointment for user UID: $userId (Anonymous: ${_userService.currentUser!.isAnonymous})',
    );

    _isLoadingBookings = true;
    _bookingError = null;
    _safeNotifyListeners(); // USE _safeNotifyListeners

    try {
      final newBooking = Booking(
        id: '',
        userId: userId,
        barberId: barberId,
        barberName: barberName,
        serviceId: serviceId,
        startTime: startTime,
        endTime: endTime,
        status: 'confirmed',
        guestContactInfo:
            _userService.currentUser!.isAnonymous
                ? guestContactForBooking
                : null,
      );

      DocumentReference docRef = await _firestore
          .collection('appointments')
          .add(newBooking.toFirestore());
      print('BookingService: Appointment created with ID: ${docRef.id}');
      if (!_isDisposed) {
        // Check before another async call that notifies
        await fetchUserBookings();
      }
    } catch (e) {
      if (!_isDisposed) _bookingError = 'Kunne ikke gennemføre booking: $e';
      print('BookingService: Booking error details: $e');
    } finally {
      if (!_isDisposed) {
        // Ensure we only modify state if not disposed
        if (_isLoadingBookings || _bookingError != null) {
          _isLoadingBookings = false;
        }
        _safeNotifyListeners(); // USE _safeNotifyListeners
      }
    }
  }

  Future<void> fetchUserBookings() async {
    if (_isDisposed) return;
    if (!_userService.isLoggedIn || _userService.currentUser == null) {
      _userBookings = [];
      _isLoadingBookings = false;
      _safeNotifyListeners();
      return;
    }
    final String userId = _userService.currentUser!.uid;
    print('BookingService: Fetching bookings for user UID: $userId');

    _isLoadingBookings = true;
    _bookingError = null;
    _safeNotifyListeners(); // Notify that loading has started

    try {
      final querySnapshot =
          await _firestore
              .collection('appointments')
              .where('user_id', isEqualTo: userId)
              .where('status', isEqualTo: 'confirmed')
              .orderBy('start_time', descending: true)
              .get();

      if (!_isDisposed) {
        _userBookings =
            querySnapshot.docs
                .map((doc) => Booking.fromFirestore(doc))
                .toList();
        print(
          'BookingService: Fetched ${_userBookings.length} bookings (now filtering for confirmed).',
        );
      }
    } catch (e) {
      if (!_isDisposed) _bookingError = 'Could not load bookings: $e';
      print('BookingService: Error fetching user bookings: $e');
      _userBookings = []; // Clear on error
    } finally {
      if (!_isDisposed) {
        _isLoadingBookings = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    if (_isDisposed) return;
    if (!_userService.isLoggedIn || _userService.currentUser == null) {
      _bookingError = "Bruger ikke logget ind for at annullere.";
      _safeNotifyListeners(); // USE _safeNotifyListeners
      throw Exception('User not logged in to cancel appointment.');
    }
    print(
      'BookingService: Attempting to cancel booking ID: $bookingId for user UID: ${_userService.currentUser!.uid}',
    );
    _bookingError = null;

    try {
      await _firestore.collection('appointments').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int serviceDurationMinutes,
  }) async {
    if (_isDisposed) return []; // Return empty if disposed
    // ... (rest of the method is fine as it doesn't call notifyListeners)
    final List<DateTime> availableSlots = [];
    if (date.weekday == 7) return [];

    int startHour, endHour;
    switch (date.weekday) {
      case 5:
        startHour = 9;
        endHour = 20;
        break;
      case 6:
        startHour = 9;
        endHour = 16;
        break;
      default:
        startHour = 9;
        endHour = 19;
    }

    final DateTime dayStart = DateTime(
      date.year,
      date.month,
      date.day,
      0,
      0,
      0,
    );
    final DateTime dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    );

    try {
      print(
        'BookingService: Fetching daily bookings for barber $barberId on $date',
      );
      final querySnapshot =
          await _firestore
              .collection('appointments')
              .where('barber_id', isEqualTo: barberId)
              .where('status', isEqualTo: 'confirmed')
              .where(
                'start_time',
                isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
              )
              .where(
                'start_time',
                isLessThanOrEqualTo: Timestamp.fromDate(dayEnd),
              )
              .get();

      if (_isDisposed) return []; // Check again after await

      final List<Booking> dailyBookings =
          querySnapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      print(
        'BookingService: Found ${dailyBookings.length} bookings for the day.',
      );

      DateTime currentTimeSlot = DateTime(
        date.year,
        date.month,
        date.day,
        startHour,
        0,
      );
      final DateTime endOfDayOperation = DateTime(
        date.year,
        date.month,
        date.day,
        endHour,
        0,
      );
      const Duration slotGranularity = Duration(minutes: 15);

      while (currentTimeSlot
              .add(Duration(minutes: serviceDurationMinutes))
              .isBefore(endOfDayOperation) ||
          currentTimeSlot
              .add(Duration(minutes: serviceDurationMinutes))
              .isAtSameMomentAs(endOfDayOperation)) {
        if (_isDisposed) return []; // Check inside loop

        if (currentTimeSlot.hour == 12) {
          currentTimeSlot = DateTime(date.year, date.month, date.day, 13, 0);
          if (!(currentTimeSlot
                  .add(Duration(minutes: serviceDurationMinutes))
                  .isBefore(endOfDayOperation) ||
              currentTimeSlot
                  .add(Duration(minutes: serviceDurationMinutes))
                  .isAtSameMomentAs(endOfDayOperation))) {
            break;
          }
        }

        DateTime slotEnd = currentTimeSlot.add(
          Duration(minutes: serviceDurationMinutes),
        );
        bool isSlotFree = true;

        for (final booking in dailyBookings) {
          if (currentTimeSlot.isBefore(booking.endTime) &&
              slotEnd.isAfter(booking.startTime)) {
            isSlotFree = false;
            break;
          }
        }

        if (isSlotFree) {
          availableSlots.add(DateTime.parse(currentTimeSlot.toIso8601String()));
        }
        currentTimeSlot = currentTimeSlot.add(slotGranularity);
      }
      print('BookingService: Found ${availableSlots.length} available slots.');
      return availableSlots;
    } catch (e) {
      print('BookingService: Error getting available time slots: $e');
      throw Exception('Error generating time slots: $e');
    }
  }

  void clearBookingError() {
    if (_isDisposed) return;
    if (_bookingError != null) {
      _bookingError = null;
      _safeNotifyListeners(); // USE _safeNotifyListeners
    }
  }
}
