// lib/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Confirmation')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text('Date: 2023-05-15'),
            Text('Time: 2:00 PM'),
            Text('Service: Haircut'),
            Text('Barber: John Doe'),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    // Handle cancellation
                  },
                ),
                ElevatedButton(
                  child: Text('Reschedule'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/booking');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
