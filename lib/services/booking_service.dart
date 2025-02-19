import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final SupabaseClient client = Supabase.instance.client;

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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // For mock data, we'll just simulate success
      // No actual database call needed
      return;
    } catch (e) {
      print('Booking error details: $e');
      throw Exception('Kunne ikke gennemføre booking: Prøv igen senere');
    }
  }

  /// Gets all appointments for a user
  Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    try {
      final response = await client
          .from('appointments')
          .select('''
            *,
            barbers (
              name,
              profile_image
            ),
            services (
              name,
              duration,
              price
            )
          ''')
          .eq('user_id', userId)
          .order('start_time');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

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
}

class WorkingHours {
  final DateTime start;
  final DateTime end;

  WorkingHours({required this.start, required this.end});
}
