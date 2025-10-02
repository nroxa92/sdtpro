import 'package:flutter/material.dart';

class TemperatureSensorsScreen extends StatefulWidget {
  const TemperatureSensorsScreen({super.key});

  @override
  State<TemperatureSensorsScreen> createState() => _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  
  // SVE POMOĆNE METODE IDU UNUTAR OVE KLASE

  // Pomoćna metoda za kreiranje jednog retka u info panelu
  Widget _buildInfoRow(String label, String value) {
    final valueStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          SelectableText(value, style: valueStyle),
        ],
      ),
    );
  }
  
  // Metoda koja gradi gornji Info Panel
  Widget _buildInfoPanel() {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    final subtitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueAccent);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Referentni Podaci', style: titleStyle),
            const SizedBox(height: 16),
            
            Text('Otpor (NTC Senzori)', style: subtitleStyle),
            const SizedBox(height: 8),
            _buildInfoRow('20°C:', '~2500 Ω'),
            _buildInfoRow('25°C:', '~2100 Ω'),
            _buildInfoRow('30°C:', '~1700 Ω'),
            _buildInfoRow('35°C:', '~1450 Ω'),
            _buildInfoRow('40°C:', '~1200 Ω'),
            
            const Divider(height: 32, thickness: 1),

            Text('ECU Pinout', style: subtitleStyle),
            const SizedBox(height: 8),
            _buildInfoRow('EGTS:', 'B-G4 / F3'),
            _buildInfoRow('ECTS:', 'A-A1 / J2'),
            _buildInfoRow('EOTS:', 'A-H4 / J4'),
            _buildInfoRow('MATS:', 'A-H2 / H3'),
            _buildInfoRow('LTS:', 'B-E2 / G2'),
          ],
        ),
      ),
    );
  }

  // Metoda koja gradi donji Panel Mjerenja (trenutno placeholder)
  Widget _buildMeasurementPanel() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Measurement Panel Placeholder',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  // Glavna build metoda koja gradi cijeli ekran
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
            _buildInfoPanel(),
            const SizedBox(height: 24),
            _buildMeasurementPanel(),
          ],
        ),
      ),
    );
  }
}