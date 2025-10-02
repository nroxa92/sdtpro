// lib/screens/sensor_testing/temperature_sensors_screen.dart

import 'package:flutter/material.dart';
import '../../models/models.dart'; // ISPRAVLJENA PUTANJA

class TemperatureSensorsScreen extends StatefulWidget {
  final List<SensorSubCategory> sensors;

  const TemperatureSensorsScreen({
    super.key,
    required this.sensors,
  });

  @override
  State<TemperatureSensorsScreen> createState() => _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  SensorSubCategory? _selectedSensor;

  @override
  void initState() {
    super.initState();
    _fetchAllResistances();
    if (widget.sensors.isNotEmpty) {
      _selectedSensor = widget.sensors.first;
    }
  }

  void _fetchAllResistances() {
    // Simulacija dohvaćanja podataka s firmvera
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // Provjera ako je widget još uvijek u stablu
      setState(() {
        for (var sensor in widget.sensors) {
          switch (sensor.name) {
            case 'EGTS':
              sensor.measuredResistance = 150;
              sensor.status = 'error';
              break;
            case 'ECTS':
              sensor.measuredResistance = 2480;
              sensor.status = 'ok';
              break;
            case 'EOTS':
              sensor.measuredResistance = 2510;
              sensor.status = 'ok';
              break;
            case 'MATS':
              sensor.measuredResistance = 9999;
              sensor.status = 'error';
              break;
            case 'LTS':
              sensor.measuredResistance = null;
              sensor.status = 'pending';
              break;
          }
        }
        _selectedSensor = widget.sensors.firstWhere((s) => s.status == 'ok', orElse: () => widget.sensors.first);
      });
    });
  }
  
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

  Widget _buildMeasurementPanel() {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    const currentExpectedRange = '1500 - 1900 Ω'; // Privremeno, dok ne postane dinamički

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mjerenje Otpora', style: titleStyle),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16.0,
                columns: const [
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Senzor')),
                  DataColumn(label: Text('Očekivano (Ω)')),
                  DataColumn(label: Text('Izmjereno (Ω)'), numeric: true),
                ],
                rows: widget.sensors.map((sensor) {
                  return DataRow(
                    selected: _selectedSensor == sensor,
                    onSelectChanged: (isSelected) {
                      if (isSelected ?? false) {
                        setState(() { _selectedSensor = sensor; });
                      }
                    },
                    cells: [
                      DataCell(_buildStatusIcon(sensor.status)),
                      DataCell(Text(sensor.name)),
                      DataCell(Text(currentExpectedRange)),
                      DataCell(Text(sensor.measuredResistance?.toString() ?? '---')),
                    ],
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 32),
            Center(
              child: Text(
                'Graf za: ${_selectedSensor?.name ?? "Nije odabran"}',
                 style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIcon(String status) {
    Color color;
    switch (status) {
      case 'ok':
        color = Colors.green;
        break;
      case 'error':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Icon(Icons.circle, color: color, size: 18);
  }

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