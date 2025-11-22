import 'package:flutter/material.dart';
import '../pages/recipe_detail_page.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String currentUsername;

  const RecipeCard({required this.recipe, required this.currentUsername, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: recipe['imageUrl'] != null && recipe['imageUrl'] != ''
            ? Image.network(recipe['imageUrl'], width: 60, height: 60, fit: BoxFit.cover)
            : const SizedBox(width: 60, height: 60),
        title: Text(recipe['title'] ?? ''),
        subtitle: Text(recipe['category'] ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailPage(
                recipeId: recipe['id'], // <-- updated here
                currentUsername: currentUsername,
              ),
            ),
          );
        },
      ),
    );
  }
}
