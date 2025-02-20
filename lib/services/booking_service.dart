import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final SupabaseClient client = Supabase.instance.client;
  // Add a map to store mock bookings
  final Map<String, List<Map<String, dynamic>>> _mockBookings = {};

  /// Checks if a given time slot is available for a barber.
  Future<bool> isTimeSlotAvailable({
    required String barberId,
    required DateTime desiredStart,
    required DateTime desiredEnd,
  }) async {
    try {
      final response = await client
          .from('appointments')
          .select('start_time, end_time')
          .eq('barber_id', barberId)
          .lte('start_time', desiredEnd.toIso8601String())
          .gte('end_time', desiredStart.toIso8601String());

      return (response as List).isEmpty;
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  /// Creates a new appointment.
  Future<void> createAppointment({
    required String userId,
    required String barberId,
    required String serviceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      print('DEBUG: Creating appointment for user: $userId');
      print('DEBUG: Current mock bookings before: $_mockBookings');

      if (!_mockBookings.containsKey(userId)) {
        _mockBookings[userId] = [];
      }

      _mockBookings[userId]!.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'barber_id': barberId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'barbers': {
          'name':
              barberId == '7d9fb269-b171-49c5-93ef-7097a99e02e3'
                  ? 'Frisør 1'
                  : 'Frisør 2',
        },
      });

      print('DEBUG: Current mock bookings after: $_mockBookings');

      await Future.delayed(const Duration(milliseconds: 500));
      return;
    } catch (e) {
      print('Booking error details: $e');
      throw Exception('Kunne ikke gennemføre booking: Prøv igen senere');
    }
  }

  /// Gets all appointments for a user
  // Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
  // ...
  // }

  /// Cancels an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId);
    } catch (e) {
      throw Exception('Error cancelling appointment: $e');
    }
  }

  /// Gets available time slots for a barber on a specific date
  Future<List<DateTime>> getAvailableTimeSlots({
    required String barberId,
    required DateTime date,
    required int serviceDuration,
  }) async {
    try {
      final List<DateTime> availableSlots = [];

      // Check if it's Sunday (where 7 is Sunday)
      if (date.weekday == 7) {
        return []; // Closed on Sundays
      }

      // Different hours for different days
      int startHour;
      int endHour;

      switch (date.weekday) {
        case 5: // Friday
          startHour = 9;
          endHour = 20; // Open later on Fridays
          break;
        case 6: // Saturday
          startHour = 9;
          endHour = 16; // Shorter day
          break;
        default: // Monday-Thursday
          startHour = 9;
          endHour = 19;
      }

      // Mock some slots as already booked
      final bookedSlots = {
        // Format: 'year-month-day-hour-minute'
        '${date.year}-${date.month}-${date.day}-10-30', // 10:30 is booked
        '${date.year}-${date.month}-${date.day}-11-00', // 11:00 is booked
        '${date.year}-${date.month}-${date.day}-14-30', // 14:30 is booked
      };

      for (int hour = startHour; hour < endHour; hour++) {
        // Morning break
        if (hour == 12) continue; // Lunch break

        // Add available slots if not in bookedSlots
        final slot1 = DateTime(date.year, date.month, date.day, hour, 0);
        final slot2 = DateTime(date.year, date.month, date.day, hour, 30);

        final slot1Key = '${date.year}-${date.month}-${date.day}-$hour-0';
        final slot2Key = '${date.year}-${date.month}-${date.day}-$hour-30';

        if (!bookedSlots.contains(slot1Key)) {
          availableSlots.add(slot1);
        }
        if (!bookedSlots.contains(slot2Key)) {
          availableSlots.add(slot2);
        }
      }

      return availableSlots;
    } catch (e) {
      throw Exception('Error generating time slots: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      print('Fetching bookings for user: $userId'); // Debug print
      final bookings = _mockBookings[userId] ?? [];
      print('Found bookings: ${bookings.length}'); // Debug print
      print('All mock bookings: $_mockBookings'); // Debug print

      return bookings.map((booking) {
        return {
          'id': booking['id'],
          'barber_id': booking['barber_id'],
          'barber_name': booking['barbers']['name'],
          'start_time': DateTime.parse(booking['start_time']),
          'end_time': DateTime.parse(booking['end_time']),
        };
      }).toList();
    } catch (e) {
      print('Error in getUserBookings: $e'); // Debug print
      throw 'Could not load bookings: $e';
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      // Remove from mock bookings
      final currentUser = UserService().currentUserId;
      if (currentUser != null && _mockBookings.containsKey(currentUser)) {
        _mockBookings[currentUser]!.removeWhere(
          (booking) => booking['id'] == bookingId,
        );
      }
      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
    } catch (e) {
      throw 'Could not cancel booking: $e';
    }
  }
}

class WorkingHours {
  final DateTime start;
  final DateTime end;

  WorkingHours({required this.start, required this.end});
}
