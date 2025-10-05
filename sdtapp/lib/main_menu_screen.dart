// lib/main_menu_screen.dart - REVIDIRANA VERZIJA (Rješava problem "Uskoro...")
import 'package:flutter/material.dart';

// Uvozimo SVE modele i podatke iz centralnih datoteka
import 'models.dart';
import 'main_scaffold.dart';
import 'sensor_data.dart'; // Uvozi mainMenuCategories i temperatureSensorItems
import 'temperature_sensors_screen.dart';
import 'can_live_screen.dart'; // Uvozimo stvarni ekran za Live CAN podatke

// Privremeni prazni ekrani za neimplementirane funkcionalnosti
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) =>
      MainScaffold(title: title, body: Center(child: Text('$title - Uskoro!')));
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Koristimo centraliziranu listu iz sensor_data.dart
    final menuCategories = mainMenuCategories;

    return MainScaffold(
      title: 'SDT Glavni Izbornik',
      // Koristimo GridView za bolji UX kao što smo planirali ranije
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: menuCategories.length,
        itemBuilder: (context, index) {
          final category = menuCategories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, MainMenuCategory category) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategoryScreen(category: category),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Ekran za prikaz pod-kategorija (SubCategoryScreen)
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
                Widget screen;
                switch (item.routeName) {
                  case AppRoutes.temperatureSensors:
                    // Prosljeđujemo listu senzora ekranu
                    screen = TemperatureSensorsScreen(
                      sensors: temperatureSensorItems,
                    );
                    break;

                  case AppRoutes.canLiveData: // RJEŠENJE ZA CAN BUS LIVE
                    screen = const CanLiveScreen(); // Navigira na stvarni ekran
                    break;

                  default:
                    screen = PlaceholderScreen(title: item.name);
                    break;
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
