import 'package:flutter/material.dart';
import 'package:sdmt_final/data/models.dart';
import 'package:sdmt_final/data/sensor_database.dart';
import 'package:sdmt_final/widgets/main_scaffold.dart'; // <-- NOVI IMPORT

class TestListScreen extends StatelessWidget {
  const TestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as TestCategory;
    final sensors = groupedSensors[category] ?? [];

    // Sada vraćamo MainScaffold umjesto običnog Scaffold-a
    return MainScaffold(
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
              Navigator.pushNamed(context, '/testScreen', arguments: sensor);
            },
          );
        },
      ),
    );
  }
}