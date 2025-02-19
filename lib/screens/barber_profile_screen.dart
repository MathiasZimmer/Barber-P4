// lib/screens/barber_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BarberProfileScreen extends StatelessWidget {
  const BarberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barber Profile')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('https://example.com/barber_image.jpg'),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 4.5,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemBuilder:
                        (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      // Handle rating update
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Services:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ListTile(title: Text('Haircut'), trailing: Text('\$25')),
                  ListTile(title: Text('Beard Trim'), trailing: Text('\$15')),
                  // Add more services
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Book Appointment'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/booking');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
