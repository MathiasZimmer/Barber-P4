// lib/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  final _guestFormKey = GlobalKey<FormState>();
  final _userFormKey = GlobalKey<FormState>();
  String? _email;
  String? _phone;
  String? _name;
  String? _password;
  bool _isLoading = false;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = UserService().isLoggedIn;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('BEKRÆFT BOOKING', style: AppTheme.appBarTitleStyle),
      ),
      body: SingleChildScrollView(
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
                  Text('Booking Detaljer:', style: AppTheme.titleStyle),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.gold.withAlpha(150),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            args['barberId'] ==
                                    '7d9fb269-b171-49c5-93ef-7097a99e02e3'
                                ? 'assets/barber1.jpg'
                                : 'assets/barber2.jpg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barber: ${args['barberName']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Dato: ${args['date'].day}/${args['date'].month}/${args['date'].year}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Tid: ${(args['time'] as DateTime).hour}:${(args['time'] as DateTime).minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isLoggedIn) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: AppTheme.goldBorderContainer,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kontakt Information:', style: AppTheme.titleStyle),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'GÆST'),
                          Tab(text: 'OPRET BRUGER'),
                        ],
                        labelColor: AppColors.gold,
                        unselectedLabelColor: Colors.white,
                        indicatorColor: AppColors.gold,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: _currentIndex == 0 ? 140 : 200,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Guest Tab
                            Form(
                              key: _guestFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Navn',
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) => _email = value,
                                    validator: (value) {
                                      if (_phone?.isNotEmpty ?? false) {
                                        return null;
                                      }
                                      if (value?.isEmpty ?? true) {
                                        return 'Indtast venligst email eller telefonnummer';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Telefon',
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) => _phone = value,
                                    validator: (value) {
                                      if (_email?.isNotEmpty ?? false) {
                                        return null;
                                      }
                                      if (value?.isEmpty ?? true) {
                                        return 'Indtast venligst email eller telefonnummer';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Create Account Tab
                            Form(
                              key: _userFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Navn',
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) => _name = value,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Indtast venligst dit navn';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSaved: (value) => _email = value,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Indtast venligst din email';
                                      }
                                      if (!value!.contains('@') ||
                                          !value.contains('.')) {
                                        return 'Indtast venligst en gyldig email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Adgangskode',
                                      labelStyle: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    obscureText: true,
                                    onSaved: (value) => _password = value,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Indtast venligst en adgangskode';
                                      }
                                      if (value!.length < 6) {
                                        return 'Adgangskoden skal være mindst 6 tegn';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _confirmBooking,
                  icon: const Icon(Icons.content_cut, size: 16),
                  label: Text(
                    _isLoading ? 'Behandler...' : 'BEKRÆFT',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: AppTheme.goldButtonStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (!UserService().isLoggedIn) {
      if (_currentIndex == 0) {
        if (!_guestFormKey.currentState!.validate()) return;
        _guestFormKey.currentState!.save();
      } else {
        if (!_userFormKey.currentState!.validate()) return;
        _userFormKey.currentState!.save();
        print('Registering user with email: $_email'); // Debug print
        UserService().registerUser(_email!, _password!, name: _name);
      }
    }

    setState(() => _isLoading = true);

    try {
      final BookingService bookingService = BookingService();
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      final userId =
          UserService().isLoggedIn
              ? UserService().currentUserId!
              : (_currentIndex == 0 ? (_email ?? _phone!) : _email!);

      await bookingService.createAppointment(
        userId: userId,
        barberId: args['barberId'],
        serviceId: 'service789',
        startTime: args['time'],
        endTime: (args['time'] as DateTime).add(
          Duration(minutes: args['serviceDuration']),
        ),
      );

      print('DEBUG: Created booking for user: $userId'); // Add this

      if (!mounted) return;

      if (_currentIndex == 1) {
        // Registered user
        UserService().login(_email!, _password!);
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/user_profile',
          (route) => false,
          arguments: {'userId': _email},
        );
      } else {
        // Guest user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking bekræftet! Opret en bruger for at se dine bookinger.',
            ),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fejl ved booking: $e')));
    }

    setState(() => _isLoading = false);
  }
}
