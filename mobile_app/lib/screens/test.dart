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
    // Dohvaćamo cijeli 'sensor' objekt koji je poslan kao argument s prethodnog ekrana
    final sensor = ModalRoute.of(context)!.settings.arguments as BaseSensorData;

    return Scaffold(
      appBar: AppBar(
        title: Text(sensor.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildInfoCard(sensor),
          if (sensor.pinout != null && sensor.pinout!.isNotEmpty) 
            _buildPinoutCard(sensor.pinout!),
          
          if (sensor.resistanceTest != null) 
            _buildResistanceTestCard(sensor.resistanceTest!),
          
          // Ovdje možete dodati izgradnju kartica za ostale tipove testova
          // if (sensor.voltageTest != null) _buildVoltageTestCard(sensor.voltageTest!),
          // if (sensor is NtcSensor) _buildNtcTableCard(sensor),
        ],
      ),
    );
  }

  // Prikazuje osnovne informacije o senzoru
  Widget _buildInfoCard(BaseSensorData sensor) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informacije o komponenti", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            _InfoRow(title: "ID:", value: sensor.id),
            _InfoRow(title: "Tip:", value: sensor.typeDescription),
            if (sensor.principleOfOperation.isNotEmpty)
              _InfoRow(title: "Princip rada:", value: sensor.principleOfOperation),
          ],
        ),
      ),
    );
  }
  
  // Prikazuje pinout senzora
  Widget _buildPinoutCard(List<PinoutDetail> pinout) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pinout", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            // Koristimo Column umjesto ...spread operatora za bolju kontrolu
            Column(
              children: pinout.map((p) => _InfoRow(title: "Pin ${p.pin}:", value: p.description)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Prikazuje karticu za test otpora
  Widget _buildResistanceTestCard(ResistanceTest test) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Test Otpora", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            _InfoRow(title: "Referentna vrijednost:", value: "${test.refMin} - ${test.refMax} ${test.unit}"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Izmjereno: $liveValue", style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton(
                  onPressed: () {
                    //Ovdje pozvati funkciju za pokretanje testa otpora
                    // Primjer: SdmTService.instance.sendCommand('START_RESISTANCE_TEST:1,2');
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

// Pomoćni widget za elegantan prikaz redaka "Naslov: Vrijednost"
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
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}