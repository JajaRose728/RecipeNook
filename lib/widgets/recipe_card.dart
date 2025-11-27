import 'package:flutter/material.dart';
import '../pages/recipe_detail_page.dart';
import '../constants.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String currentUsername;
  final Color categoryColor; // Keep

  const RecipeCard({
    required this.recipe,
    required this.currentUsername,
    this.categoryColor = const Color(0xFFE9DDCB), // default beige
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const _colorDarkGreen = Color(0xFF4F6D44);
    return Card(
      color: const Color(0xFFE9DDCB), // or keep your theme color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailPage(
                recipeId: recipe['id'],
                currentUsername: currentUsername,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe['imageUrl'] != null && recipe['imageUrl'] != '')
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  recipe['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _colorDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe['category'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
