// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    initialValue: _name,
                    onSaved: (value) => _name = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    initialValue: _email,
                    onSaved: (value) => _email = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Save Changes'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Save user data
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Booking History:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListTile(
              title: Text('Haircut'),
              subtitle: Text('2023-05-01 2:00 PM'),
            ),
            ListTile(
              title: Text('Beard Trim'),
              subtitle: Text('2023-04-15 3:30 PM'),
            ),
            // Add more booking history items
            SizedBox(height: 32),
            Text(
              'Preferences:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile(
              title: Text('Receive notifications'),
              value: true,
              onChanged: (bool value) {
                // Handle preference change
              },
            ),
            SwitchListTile(
              title: Text('Dark mode'),
              value: false,
              onChanged: (bool value) {
                // Handle preference change
              },
            ),
          ],
        ),
      ),
    );
  }
}
