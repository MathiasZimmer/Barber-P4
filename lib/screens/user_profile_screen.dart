// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/user_service.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUserAndLoad());
  }

  void _checkUserAndLoad() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = args?['userId'] ?? UserService().currentUserId;

    if (userId == null) {
      if (!mounted) return; // Check after potential async gap

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log ind for at se dine bookinger')),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _loadBookings(userId);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fejl: $e')));
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBookings(String userId) async {
    try {
      final bookings = await _bookingService.getUserBookings(userId);

      if (!mounted) return;

      setState(() => _bookings = bookings);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved indlæsning af bookinger: $e')),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await _bookingService.cancelBooking(bookingId);
      await _loadBookings(UserService().currentUserId!);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking annulleret')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fejl ved annullering: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: GestureDetector(
                onTap: () async {
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      'SALON LAURA',
                      style: TextStyle(
                        letterSpacing: 0.8,
                        fontSize: 15,
                        color: AppColors.gold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.content_cut, size: 16, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserService().logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                          Text(
                            'Mine Bookinger',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          if (_bookings.isEmpty)
                            const Center(
                              child: Text(
                                'Ingen aktive bookinger',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _bookings.length,
                              separatorBuilder:
                                  (context, index) =>
                                      const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final booking = _bookings[index];
                                final startTime =
                                    booking['start_time'] as DateTime;

                                return Card(
                                  color: AppColors.black.withAlpha(180),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: AppColors.gold.withAlpha(150),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: AssetImage(
                                        booking['barber_id'] ==
                                                '7d9fb269-b171-49c5-93ef-7097a99e02e3'
                                            ? 'assets/barber1.jpg'
                                            : 'assets/barber2.jpg',
                                      ),
                                    ),
                                    title: Text(
                                      'Tid hos ${booking['barber_name']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${startTime.day}/${startTime.month}/${startTime.year} - '
                                      '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red[300],
                                      onPressed:
                                          () => showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  backgroundColor:
                                                      AppColors.black,
                                                  title: const Text(
                                                    'Annuller Booking',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: const [
                                                      Text(
                                                        'Er du sikker på, at du vil annullere denne booking?',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text(
                                                        'OBS: Ved aflysning under 24 timer før bekræftet tid, bedes du ringe til salonen.',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text('NEJ'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _cancelBooking(
                                                          booking['id'],
                                                        );
                                                      },
                                                      child: Text(
                                                        'JA',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.red[300],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ),
                                    ),
                                  ),
                                );
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
