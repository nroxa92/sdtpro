// lib/screens/sub_category_screen.dart
import 'package:flutter/material.dart';
import 'package:sdt_final/models/models.dart';

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
        itemCount: category.subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = category.subCategories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(subCategory.name),
              subtitle: subCategory.description != null
                  ? Text(subCategory.description!)
                  : null,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Ovdje se događa navigacija na temelju definirane rute
                Navigator.pushNamed(context, subCategory.routeName);
              },
            ),
          );
        },
      ),
    );
  }
}