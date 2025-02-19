// lib/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _phone;
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

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final BookingService bookingService = BookingService();
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      await bookingService.createAppointment(
        userId: _email ?? _phone!, // Use email or phone as guest ID
        barberId: args['barberId'],
        serviceId: 'service789', // You might want to make this dynamic
        startTime: args['time'],
        endTime: (args['time'] as DateTime).add(
          Duration(minutes: args['serviceDuration']),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking bekræftet!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fejl ved booking: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'BEKRÆFT BOOKING',
          style: TextStyle(
            letterSpacing: 0.8,
            fontSize: 15,
            color: Color.fromARGB(153, 224, 224, 224),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gold.withAlpha(150),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Detaljer:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gold.withAlpha(150),
                  width: 1.5,
                ),
              ),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontakt Information:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
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
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
