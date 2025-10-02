// lib/screens/can_live_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/websocket_service.dart';

class CanLiveScreen extends StatefulWidget {
  const CanLiveScreen({super.key});

  @override
  State<CanLiveScreen> createState() => _CanLiveScreenState();
}

class _CanLiveScreenState extends State<CanLiveScreen> {
  // Dohvaćamo instancu servisa
  final SdmTService _sdmTService = SdmTService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live CAN Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Slušamo promjene na liveDataNotifier-u i automatski
        // ponovno iscrtavamo sučelje s novim podacima
        child: ValueListenableBuilder<LiveData>(
          valueListenable: _sdmTService.liveDataNotifier,
          builder: (context, liveData, child) {
            return GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              // Prikazujemo samo podatke koji su definirani u našem novom LiveData modelu
              children: [
                _buildDataCard('RPM', liveData.rpm.toStringAsFixed(0), 'rpm'),
                _buildDataCard('Gas', liveData.throttle.toStringAsFixed(1), '%'),
                _buildDataCard('Temp. Vode', liveData.coolantTemp.toStringAsFixed(1), '°C'),
                // Ovdje se lako mogu dodati nove kartice kada proširite LiveData model
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, String unit) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
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