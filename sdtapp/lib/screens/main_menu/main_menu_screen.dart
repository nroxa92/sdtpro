import 'package:flutter/material.dart';
import 'package:sdtapp/data/models.dart';
import 'package:sdtapp/widgets/main_scaffold.dart';
import '../sensor_testing/temperature_sensors_screen.dart';

// Privremeni prazni ekrani da aplikacija radi
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) =>
      MainScaffold(title: title, body: Center(child: Text('$title - Uskoro!')));
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  // Ovdje definiramo cijelu strukturu izbornika
  static final List<MainMenuCategory> menuCategories = [
    MainMenuCategory(
      name: 'Senzori',
      icon: Icons.thermostat,
      subCategories: [
        SubCategoryItem(
            name: 'Senzori Temperature',
            routeName: '/sensors/temperature',
            description: 'Pregled temperatura motora'),
        // Dodaj ostale senzore ovdje...
      ],
    ),
    MainMenuCategory(
      name: 'IN Komponente',
      icon: Icons.input,
      subCategories: [
        SubCategoryItem(
            name: 'Prekidači',
            routeName: '/in/switches',
            description: 'Status prekidača kvačila, kočnice...'),
        // Dodaj ostale IN komponente ovdje...
      ],
    ),
    MainMenuCategory(
      name: 'OUT Komponente',
      icon: Icons.output,
      subCategories: [
        SubCategoryItem(
            name: 'Test Aktuatora',
            routeName: '/out/actuators',
            description: 'Testiranje injektora, pumpe goriva...'),
        // Dodaj ostale OUT komponente ovdje...
      ],
    ),
    MainMenuCategory(
      name: 'CAN Greške',
      icon: Icons.error_outline,
      subCategories: [
        SubCategoryItem(
            name: 'Čitanje Grešaka',
            routeName: '/can/errors_read',
            description: 'Pročitaj spremljene greške'),
        SubCategoryItem(
            name: 'Brisanje Grešaka',
            routeName: '/can/errors_clear',
            description: 'Obriši sve greške iz memorije'),
      ],
    ),
    MainMenuCategory(
      name: 'CAN Live',
      icon: Icons.stream,
      subCategories: [
        SubCategoryItem(
            name: 'Prikaz Uživo',
            routeName: '/can/live',
            description: 'Svi CAN podaci u realnom vremenu'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'SDT Glavni Izbornik',
      body: ListView.builder(
        itemCount: menuCategories.length,
        itemBuilder: (context, index) {
          final category = menuCategories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(category.icon, size: 40),
              title: Text(category.name,
                  style: Theme.of(context).textTheme.headlineSmall),
              onTap: () {
                // Navigacija na ekran koji prikazuje pod-kategorije
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubCategoryScreen(category: category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Ekran za prikaz pod-kategorija
class SubCategoryScreen extends StatelessWidget {
  final MainMenuCategory category;

  const SubCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: category.name,
      body: ListView.builder(
        itemCount: category.subCategories.length,
        itemBuilder: (context, index) {
          final item = category.subCategories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(item.name),
              subtitle:
                  item.description != null ? Text(item.description!) : null,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Ovdje ide navigacija na temelju 'routeName'
                Widget screen;
                switch (item.routeName) {
                  case '/sensors/temperature':
                    screen = const TemperatureSensorsScreen();
                    break;
                  // Dodaj ostale 'case' blokove za druge rute
                  default:
                    screen = PlaceholderScreen(title: item.name);
                }
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => screen));
              },
            ),
          );
        },
      ),
    );
  }
}
