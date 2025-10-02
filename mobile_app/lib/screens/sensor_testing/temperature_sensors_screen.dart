import 'package:flutter/material.dart';

class TemperatureSensorsScreen extends StatefulWidget {
  const TemperatureSensorsScreen({super.key});

  @override
  State<TemperatureSensorsScreen> createState() => _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SENZORI TEMPERATURE'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ovdje će doći Info Panel
            _buildInfoPanel(),
            const SizedBox(height: 24),
            // Ovdje će doći Panel Mjerenja (Tablica i Graf)
            _buildMeasurementPanel(),
          ],
        ),
      ),
    );
  }

  // Placeholder za Info Panel
  Widget _buildInfoPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Info Panel Placeholder',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  // Placeholder za Panel Mjerenja
  Widget _buildMeasurementPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Measurement Panel Placeholder',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}