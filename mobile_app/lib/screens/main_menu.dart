// lib/screens/main_menu.dart
import 'package:flutter/material.dart';
import 'package:sdt_final/data/sensor_database.dart';
import 'package:sdt_final/models/models.dart';
import 'package:sdt_final/screens/sub_category_screen.dart'; // NOVI EKRAN

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SDTpro Glavni Izbornik'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: mainMenuCategories.length,
        itemBuilder: (context, index) {
          final category = mainMenuCategories[index];
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
          // Navigacija na novi ekran koji prikazuje pod-kategorije
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
            Icon(category.icon, size: 50, color: Colors.tealAccent),
            const SizedBox(height: 16),
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