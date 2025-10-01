import 'package:flutter/material.dart';
import 'package:sdmt_final/data/models.dart';
import 'package:sdmt_final/data/sensor_database.dart';

class TestListScreen extends StatelessWidget {
  const TestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dohvaćanje argumenta (kategorije) poslanog s prethodnog ekrana (MainMenuScreen)
    final category = ModalRoute.of(context)!.settings.arguments as TestCategory;
    
    // Filtriranje senzora na temelju odabrane kategorije iz mape 'groupedSensors'
    final sensors = groupedSensors[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Testovi za: ${category.displayName}'),
      ),
      body: ListView.builder(
        itemCount: sensors.length,
        itemBuilder: (context, index) {
          final sensor = sensors[index];
          return ListTile(
            title: Text(sensor.name),
            subtitle: Text(sensor.typeDescription),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigacija na ekran za pojedinačni test, šaljemo cijeli objekt senzora
              Navigator.pushNamed(context, '/testScreen', arguments: sensor);
            },
          );
        },
      ),
    );
  }
}