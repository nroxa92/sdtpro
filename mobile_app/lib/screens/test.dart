import 'package:flutter/material.dart';
import 'package:sdmt_final/data/models.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // Ovdje ćemo spremati live podatke za test koji je u tijeku
  String liveValue = "N/A";

  @override
  Widget build(BuildContext context) {
    // Dohvaćamo cijeli 'sensor' objekt koji je poslan kao argument
    final sensor = ModalRoute.of(context)!.settings.arguments as BaseSensorData;

    return Scaffold(
      appBar: AppBar(
        title: Text(sensor.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard(sensor),
          if (sensor.pinout != null) _buildPinoutCard(sensor.pinout!),
          if (sensor.resistanceTest != null) _buildResistanceTestCard(sensor.resistanceTest!),
          // TODO: Dodati kartice za ostale tipove testova (Voltage, Current, itd.)
        ],
      ),
    );
  }

  Widget _buildInfoCard(BaseSensorData sensor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informacije o komponenti", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            _InfoRow(title: "ID:", value: sensor.id),
            _InfoRow(title: "Tip:", value: sensor.typeDescription),
            if (sensor.principleOfOperation.isNotEmpty)
              _InfoRow(title: "Princip rada:", value: sensor.principleOfOperation),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPinoutCard(List<PinoutDetail> pinout) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pinout", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            ...pinout.map((p) => _InfoRow(title: "Pin ${p.pin}:", value: p.description)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResistanceTestCard(ResistanceTest test) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Test Otpora", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            _InfoRow(title: "Referentna vrijednost:", value: "${test.refMin} - ${test.refMax} ${test.unit}"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Izmjereno: $liveValue", style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Ovdje pozvati funkciju za pokretanje testa
                    // SdmTService.instance.sendCommand('START_RESISTANCE_TEST');
                    debugPrint("Pokreni test otpora...");
                  },
                  child: const Text("Pokreni Test"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Pomoćni widget za prikazivanje redaka "Naslov: Vrijednost"
class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}