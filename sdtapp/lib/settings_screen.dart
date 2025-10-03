import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Potrebno za izlaz iz aplikacije
import 'about_screen.dart'; // Import za "O Aplikaciji" ekran
import 'main_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Postavke',
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O aplikaciji SDT'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red.shade700),
            title: Text('Izlaz', style: TextStyle(color: Colors.red.shade700)),
            onTap: () {
              // Ova naredba gasi aplikaciju
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
