// lib/settings_screen.dart - KOMPLETNA IMPLEMENTACIJA POSTAVKI
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_scaffold.dart';
import 'websocket_service.dart'; // Za slanje komandi
import 'about_screen.dart'; // Za navigaciju na About

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SdmTService _sdmTService = SdmTService();
  final _formKey = GlobalKey<FormState>();

  // Kontroleri za AP konfiguraciju (Točka 11: Mogućnost promjene AP-a i lozinke)
  // NAPOMENA: Ovdje su trenutne vrijednosti hardkodirane. Ažurirale bi se
  // stvarnim podacima nakon implementacije logike za dohvaćanje statusa hardvera.
  final TextEditingController _ssidController =
      TextEditingController(text: 'SeaDoo_Tool_AP');
  final TextEditingController _passwordController =
      TextEditingController(text: '');

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _sendCommand(String command) {
    _sdmTService.sendCommand(command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Poslana komanda: $command')),
    );
  }

  void _saveApSettings() {
    // Točka 11: Ako je lozinka prazna, šalje se prazna (tj., bez lozinke)
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();

    // Provjera da SSID nije prazan
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AP Naziv (SSID) ne može biti prazan.')),
      );
      return;
    }

    // FORMAT: CMD:AP_CONFIG:NEW_SSID:NEW_PASSWORD
    final command = 'CMD:AP_CONFIG:$ssid:$password';
    _sendCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Postavke SDTpro',
      appBar: AppBar(title: const Text('POSTAVKE')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 1. WiFi AP KONFIGURACIJA ---
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WiFi Access Point',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _ssidController,
                          decoration: const InputDecoration(
                              labelText: 'Novi AP Naziv (SSID)'),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                              labelText:
                                  'Lozinka (ostaviti prazno za otvorenu mrežu)'),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('SPREMI & RESTARTAJ AP'),
                    onPressed: _saveApSettings,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- 2. HARDVERSKA KONTROLA (RESET I TEST) ---
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hardverska Kontrola',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Gumb za Reset Hardvera
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('SOFT RESET'),
                        onPressed: () => _sendCommand('CMD:SOFT_RESET'),
                      ),
                      // Gumb za Test Hardvera
                      ElevatedButton.icon(
                        icon: const Icon(Icons.assessment),
                        label: const Text('TEST MOD'),
                        onPressed: () => _sendCommand('CMD:TEST_MODE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- 3. INFORMACIJE I IZLAZ ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O SDTpro / Hardveru'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const Divider(),
          // Gumb za Gašenje Hardvera i Izlaz (Točka 11)
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.red.shade700),
            title: Text('Gašenje hardvera i Izlaz',
                style: TextStyle(color: Colors.red.shade700)),
            onTap: () {
              // 1. Šaljemo komandu hardveru za gašenje/Deep Sleep (CMD:SHUTDOWN)
              _sendCommand('CMD:SHUTDOWN');
              // 2. Gasimo aplikaciju
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
