// lib/screens/can_live_screen.dart

import 'package.flutter/material.dart';
import '../models/models.dart'; // ISPRAVAN IMPORT
import '../services/websocket_service.dart'; // ISPRAVAN IMPORT

class CanLiveScreen extends StatefulWidget {
  const CanLiveScreen({super.key});

  @override
  State<CanLiveScreen> createState() => _CanLiveScreenState();
}

class _CanLiveScreenState extends State<CanLiveScreen> {
  final SdmTService _sdmTService = SdmTService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live CAN Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Koristimo ValueListenableBuilder da se ekran automatski
        // ažurira kada stignu novi podaci
        child: ValueListenableBuilder<LiveData>(
          valueListenable: _sdmTService.liveDataNotifier,
          builder: (context, liveData, child) {
            // Gradimo prikaz s pristiglim podacima
            return GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              children: [
                _buildDataCard('RPM', liveData.rpm.toStringAsFixed(0), 'rpm'),
                _buildDataCard('Gas', liveData.throttle.toStringAsFixed(1), '%'),
                _buildDataCard('Brzina', liveData.speed.toStringAsFixed(1), 'km/h'),
                _buildDataCard('Gorivo', liveData.fuelLevel.toStringAsFixed(1), '%'),
                _buildDataCard('Temp. Vode', liveData.coolantTemp.toStringAsFixed(1), '°C'),
                _buildDataCard('Temp. Ulja', liveData.oilTemp.toStringAsFixed(1), '°C'),
                _buildDataCard('Temp. Usisa', liveData.intakeTemp.toStringAsFixed(1), '°C'),
                _buildDataCard('MAP Tlak', liveData.mapPressure.toStringAsFixed(0), 'hPa'),
              ],
            );
          },
        ),
      ),
    );
  }

  // Pomoćni widget za prikaz jedne kartice s podacima
  Widget _buildDataCard(String title, String value, String unit) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(unit, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}