// lib/widgets/main_scaffold.dart

import 'package:flutter/material.dart';
import '../screens/main_menu_screen.dart';
import '../services/websocket_service.dart';

// Pretpostavka je da imate i druge ekrane definirane negdje
// npr. placeholderi za 'live' i 'postavke'
const Widget placeholderScreen1 =
    Center(child: Text('Live Screen Placeholder'));
const Widget placeholderScreen2 =
    Center(child: Text('Settings Screen Placeholder'));

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final SdmTService _sdmTService = SdmTService();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainMenuScreen(),
    placeholderScreen1,
    placeholderScreen2,
  ];

  @override
  void initState() {
    super.initState();
    // Pozivamo connect bez argumenta, koristit će defaultnu IP adresu
    _sdmTService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Izbornik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Postavke',
          ),
        ],
      ),
    );
  }
}
