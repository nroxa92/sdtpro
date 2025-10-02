// lib/screens/sub_category_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class SubCategoryScreen extends StatelessWidget {
  final MainMenuCategory category;

  const SubCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: category.subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = category.subCategories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(subCategory.name),
              subtitle: subCategory.description != null
                  ? Text(subCategory.description!)
                  : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigacija na temelju rute definirane u `main.dart`
                if (subCategory.routeName.isNotEmpty) {
                  Navigator.pushNamed(context, subCategory.routeName);
                }
              },
            ),
          );
        },
      ),
    );
  }
}