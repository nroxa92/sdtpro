// lib/screens/sensor_testing/temperature_sensors_screen.dart
import 'package:flutter/material.dart';
import '../../data/models.dart';

class TemperatureSensorsScreen extends StatefulWidget {
  final List<SubCategoryItem> sensors;
  const TemperatureSensorsScreen({super.key, required this.sensors});

  @override
  State<TemperatureSensorsScreen> createState() =>
      _TemperatureSensorsScreenState();
}

class _TemperatureSensorsScreenState extends State<TemperatureSensorsScreen> {
  SubCategoryItem? _selectedSensor;

  @override
  void initState() {
    super.initState();
    _fetchAllResistances();
    if (widget.sensors.isNotEmpty) _selectedSensor = widget.sensors.first;
  }

  void _fetchAllResistances() {
    // Simulacija dohvaćanja podataka s firmvera
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        for (var sensor in widget.sensors) {
          switch (sensor.name) {
            case 'EGTS':
              sensor.measuredValue = 150;
              sensor.status = 'error';
              break;
            case 'ECTS':
              sensor.measuredValue = 2480;
              sensor.status = 'ok';
              break;
            case 'EOTS':
              sensor.measuredValue = 2510;
              sensor.status = 'ok';
              break;
            case 'MATS':
              sensor.measuredValue = 9999;
              sensor.status = 'error';
              break;
            case 'LTS':
              sensor.measuredValue = null;
              sensor.status = 'pending';
              break;
          }
        }
        _selectedSensor = widget.sensors.firstWhere((s) => s.status == 'ok',
            orElse: () => widget.sensors.first);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SENZORI TEMPERATURE')),
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

  Widget _buildInfoPanel() {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.bold);
    final subtitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.8));
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
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.bold);
    const currentExpectedRange = '1500 - 1900 Ω';
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
                      if (isSelected ?? false)
                        setState(() => _selectedSensor = sensor);
                    },
                    cells: [
                      DataCell(_buildStatusIcon(sensor.status)),
                      DataCell(Text(sensor.name)),
                      const DataCell(Text(currentExpectedRange)),
                      DataCell(Text(sensor.measuredValue?.toString() ?? '---')),
                    ],
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 32),
            Center(
                child: Text(
                    'Graf za: ${_selectedSensor?.name ?? "Nije odabran"}',
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final valueStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge!),
          SelectableText(value, style: valueStyle)
        ],
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
}
