import 'package:flutter/material.dart';
import 'main_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Pomoćna metoda za prikaz detalja
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'O SDTpro',
      appBar: AppBar(title: const Text('O SDTpro Dijagnostici')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SeaDooTool PRO',
                style: Theme.of(context).textTheme.headlineMedium),
            const Divider(),

            // --- INFORMACIJE O APLIKACIJI ---
            Text('Softver (Flutter App)',
                style: Theme.of(context).textTheme.titleLarge),
            _buildInfoRow('Verzija Aplikacije:', '1.3 (Final UI)'),
            _buildInfoRow('Arhitektura:', 'Flutter / Dart'),
            _buildInfoRow('Upravljanje Stanjem:', 'ValueNotifier / Singleton'),
            const SizedBox(height: 20),

            // --- INFORMACIJE O HARDVERU ---
            Text('Firmware & Hardver',
                style: Theme.of(context).textTheme.titleLarge),
            _buildInfoRow('Core MCU:', 'ESP32-32D'),
            _buildInfoRow('CAN Transceiver:', 'SN65HVD230/VP230 (3.3V)'),
            _buildInfoRow('CAN Brzina:', '500 kbps'),
            _buildInfoRow('Komunikacija:', 'WebSocket na 192.168.4.1/ws'),
            const SizedBox(height: 20),

            // --- LED Status ---
            Text('Status LED Indikatori:',
                style: Theme.of(context).textTheme.titleMedium),
            _buildInfoRow('Zelena (D13):', 'AP Status (Uključeno)'),
            _buildInfoRow('Plava (D12):', 'Klijent Spojen (Aplikacija)'),
            _buildInfoRow('Žuta (D14):', 'CAN Aktivnost (Treperi)'),
          ],
        ),
      ),
    );
  }
}
