// lib/screens/booking_screen.dart
import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../main.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  DateTime selectedDate = DateTime.now();
  DateTime? selectedTime;
  String? selectedBarberId;
  List<DateTime> availableSlots = [];
  bool isLoading = false;

  final String currentUserId = 'user123';
  final String selectedServiceId = 'haircut-service'; // Simple mock ID
  final int serviceDuration = 30;

  // Add barber data with actual Supabase IDs
  final List<Map<String, dynamic>> barbers = [
    {
      'id': '7d9fb269-b171-49c5-93ef-7097a99e02e3',
      'name': 'Frisør 1',
      'image': 'assets/barber1.jpg',
      'specialty': 'Skæg & Fades',
    },
    {
      'id': '07fe7f7b-da30-4bc2-aa84-f4bba2eaa0a7',
      'name': 'Frisør 2',
      'image': 'assets/barber2.jpg',
      'specialty': 'Skæg & Fades',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadAvailableSlots();
  }

  Future<void> loadAvailableSlots() async {
    if (!mounted || selectedBarberId == null) return;
    setState(() => isLoading = true);
    try {
      availableSlots = await _bookingService.getAvailableTimeSlots(
        barberId: selectedBarberId!,
        date: selectedDate,
        serviceDuration: serviceDuration,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading time slots: $e')));
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void proceedToConfirmation() {
    if (selectedBarberId == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg venligst en barber, dato og tid')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/booking_confirmation',
      arguments: {
        'barberId': selectedBarberId,
        'barberName':
            barbers.firstWhere((b) => b['id'] == selectedBarberId)['name'],
        'date': selectedDate,
        'time': selectedTime,
        'serviceDuration': serviceDuration,
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
      loadAvailableSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'BOOK TID',
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
                children: [
                  Text(
                    'Vælg Barber',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          barbers.map((barber) {
                            final isSelected = selectedBarberId == barber['id'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedBarberId = barber['id'];
                                    selectedTime = null;
                                    loadAvailableSlots();
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.gold
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundImage: AssetImage(
                                          barber['image'],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      barber['name'],
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? AppColors.gold
                                                : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      barber['specialty'],
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(179),
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (selectedBarberId != null) ...[
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
                child: Column(
                  children: [
                    Text(
                      'Vælg dato',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ingen ledige tider på den valgte dato',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              else
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
                    children: [
                      Text(
                        'Vælg tid',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            availableSlots.map((time) {
                              final isSelected = selectedTime == time;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSelected
                                          ? AppColors.gold
                                          : AppColors.black,
                                  foregroundColor:
                                      isSelected ? Colors.black : Colors.white,
                                ),
                                onPressed:
                                    () => setState(() => selectedTime = time),
                                child: Text(
                                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              if (selectedTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : proceedToConfirmation,
                      icon: const Icon(Icons.content_cut, size: 16),
                      label: Text(
                        isLoading ? 'Behandler...' : 'BEKRÆFT',
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
          ],
        ),
      ),
    );
  }
}
