// lib/screens/booking_screen.dart
import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../main.dart';
import '../models/service.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService(UserService());
  DateTime selectedDate = DateTime.now();
  String? selectedBarberId;
  String? selectedServiceId;
  ServiceOption? selectedOption;
  DateTime? selectedTime;
  List<DateTime> availableSlots = [];
  bool isLoading = false;

  final String currentUserId = 'user123';
  final int serviceDuration = 30;

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
      List<DateTime> slots = await _bookingService.getAvailableTimeSlots(
        barberId: selectedBarberId!,
        date: selectedDate,
        serviceDurationMinutes: serviceDuration,
      );

      // Add debug print to check if slots are being returned
      print('Available slots: $slots');

      // Filter out past time slots if the selected date is today
      if (selectedDate.year == DateTime.now().year &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.day == DateTime.now().day) {
        final now = DateTime.now();
        // Add 30 minutes buffer
        final bufferTime = now.add(const Duration(minutes: 60));
        slots = slots.where((slot) => slot.isAfter(bufferTime)).toList();
      }

      setState(() => availableSlots = slots);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading time slots: $e')));
    }
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
      appBar: AppBar(title: Text('BOOK TID', style: AppTheme.appBarTitleStyle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.goldBorderContainer,
              child: Column(
                children: [
                  Text(
                    'Vælg Frisør',
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
                                  });
                                  _showServiceSelectionDialog();
                                  loadAvailableSlots();
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration:
                                          isSelected
                                              ? AppTheme.selectedBarberContainer
                                              : AppTheme
                                                  .unselectedBarberContainer,
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
                                      style:
                                          isSelected
                                              ? AppTheme.selectedBarberNameStyle
                                              : AppTheme
                                                  .unselectedBarberNameStyle,
                                    ),
                                    Text(
                                      barber['specialty'],
                                      style: AppTheme.barberSpecialtyStyle,
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
                    ElevatedButton(
                      // Apply your chosen style. Let's use a modified goldButtonStyle for this example,
                      // or use the new datePickerButtonStyle if you created one.
                      style: AppTheme.goldButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          AppColors.grey.withOpacity(0.8),
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ), // Custom padding
                      ),
                      onPressed: () => _selectDate(context),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min, // Crucial: makes the Row only as wide as its content
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center, // Center content if button is wider
                        children: <Widget>[
                          const Icon(
                            Icons.calendar_today,
                            size: 18, // Adjust icon size as needed
                            // Color will be inherited from button's foregroundColor
                          ),
                          const SizedBox(
                            width: 8,
                          ), // Adjust spacing between icon and text
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            // Text style will be inherited from the button's textStyle
                          ),
                        ],
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
                                style:
                                    isSelected
                                        ? AppTheme.selectedTimeSlotButtonStyle
                                        : AppTheme.timeSlotButtonStyle,
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: AppTheme.goldButtonStyle,
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  proceedToConfirmation();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tid booket: ${selectedTime!.day}/${selectedTime!.month} kl. ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                                      ),
                                      action: SnackBarAction(
                                        label: 'Fortryd',
                                        onPressed: () {
                                          // Handle undo action
                                        },
                                      ),
                                    ),
                                  );
                                },
                        child: Text(
                          isLoading ? 'Behandler...' : 'BEKRÆFT',
                          style: const TextStyle(fontSize: 14),
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

  void _showOptionsDialog(Service service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.black,
            title: Text(
              'Tilføj Option',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Uden tilvalg: ${service.price},-',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() => selectedOption = null);
                    Navigator.pop(context);
                  },
                ),
                ...service.options!.map(
                  (option) => ListTile(
                    title: Text(
                      '${option.name}: +${option.additionalPrice},-',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() => selectedOption = option);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showServiceSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.black,
            title: Text(
              'Vælg Service',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    services.map((service) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              '${service.name}: ${service.price},-',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              setState(() {
                                selectedServiceId = service.id;
                                selectedOption = null;
                              });
                              // Show options dialog if service has options
                              if (service.options != null) {
                                Navigator.pop(context);
                                _showOptionsDialog(service);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          Divider(color: AppColors.gold.withAlpha(100)),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }
}
