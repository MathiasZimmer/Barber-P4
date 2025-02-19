// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _contactKey = GlobalKey();

  void _scrollToContact() {
    Scrollable.ensureVisible(
      _contactKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: const [
            Text(
              'SALON LAURA',
              style: TextStyle(
                letterSpacing: 0.8,
                fontSize: 15,
                color: Color.fromARGB(153, 224, 224, 224),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.content_cut,
              size: 16,
              color: Color.fromARGB(153, 224, 224, 224),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/booking'),
            icon: const Text(
              'BOOK TID',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                letterSpacing: 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
            label: Icon(Icons.content_cut, size: 16, color: AppColors.gold),
          ),
          TextButton(
            onPressed: _scrollToContact,
            child: const Text(
              'KONTAKT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/hero.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Text(
                        'Herrefrisør i Aalborg',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.yellow[700],
                          fontSize: 28,
                        ),
                      ),*/
                      const SizedBox(height: 10),
                      Text(
                        'Få et nyt look med Salon Laura',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(24.0),
              padding: const EdgeInsets.all(24.0),
              color: AppColors.black.withAlpha(180),
              child: Text(
                'Velkommen til Salon Laura - din foretrukne herrefrisør i Aalborg. '
                'Vi tilbyder professionel hårklipning og styling til den moderne mand.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: const [
                  ServiceCard(
                    title: 'Hårklipning',
                    description:
                        'Præcis og moderne hårklipning til enhver stil.',
                    imagePath: 'assets/fade.jpg',
                  ),
                  ServiceCard(
                    title: 'Styling',
                    description: 'Professionel styling til enhver lejlighed.',
                    imagePath: 'assets/styling.jpg',
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24.0),
              padding: const EdgeInsets.all(24.0),
              color: AppColors.black.withAlpha(180),
              child: Column(
                children: [
                  Text(
                    'Åbningstider',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mandag - Torsdag: 9:00 - 19:00\n'
                    'Fredag: 9:00 - 20:00\n'
                    'Lørdag: 9:00 - 16:00\n'
                    'Søndag: Lukket',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              key: _contactKey,
              width: double.infinity,
              color: AppColors.black,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KONTAKT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kontakt os: +45 98 12 17 47',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adresse: REBERBANSGADE 6, 9000, Aalborg',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
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
