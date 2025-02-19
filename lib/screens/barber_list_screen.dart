// lib/screens/barber_list_screen.dart
import 'package:flutter/material.dart';
import '../main.dart'; // Add this import for AppColors

class BarberListScreen extends StatelessWidget {
  const BarberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barbers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildBarberCard(
              context,
              'JD',
              'John Doe',
              'Specializes in classic cuts',
              '4.8',
              'Available today',
            ),
            const SizedBox(height: 12),
            _buildBarberCard(
              context,
              'JS',
              'Jane Smith',
              'Expert in modern styles',
              '4.9',
              'Next available: Tomorrow',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberCard(
    BuildContext context,
    String initials,
    String name,
    String specialty,
    String rating,
    String availability,
  ) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/barber_profile'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.gold,
                radius: 30,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(rating),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          availability,
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
