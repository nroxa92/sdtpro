// lib/main_menu_screen.dart - KONAČNA NAVIGACIJA
import 'package:flutter/material.dart';

// Uvozimo SVE modele i podatke iz centralnih datoteka
import 'models.dart';
import 'main_scaffold.dart';
import 'sensor_data.dart'; // Uvozi AppRoutes, mainMenuCategories i temperatureSensorItems
import 'temperature_sensors_screen.dart'; // VRAĆENO
import 'can_live_screen.dart';
import 'settings_screen.dart';

// Pomoćni widget za neimplementirane funkcionalnosti
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
    final menuCategories = mainMenuCategories;

    return MainScaffold(
      title: 'SeaDooTool',
      appBar: AppBar(
        title: const Text('SeaDooTool'),
        centerTitle: true,
      ),
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
      appBar: AppBar(title: Text(category.name)),

      // IMPLEMENTACIJA GRID VIEW-a ZA PODKATEGORIJE
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: category.subCategories.length,
        itemBuilder: (context, index) {
          final item = category.subCategories[index];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Widget screen;
                switch (item.routeName) {
                  case AppRoutes.temperatureSensors:
                    // VRAĆANJE PRAVOG EKRANA ZA SENZORE
                    screen = TemperatureSensorsScreen(
                      sensors: temperatureSensorItems,
                    );
                    break;

                  case AppRoutes.canLiveData:
                    screen = const CanLiveScreen();
                    break;

                  case AppRoutes.settings:
                    screen = const SettingsScreen();
                    break;

                  default:
                    screen = PlaceholderScreen(title: item.name);
                    break;
                }
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => screen));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build,
                      size: 48, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
