import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_page.dart';
import 'create_recipe_page.dart';
import '../widgets/recipe_card.dart';

class HomePage extends StatelessWidget {
  final String currentUsername;
  final RecipeService _recipeService = RecipeService();

  HomePage({required this.currentUsername, super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFDF9F5);
    const Color headerColor = Color(0xFFE9DDCB);
    const double padding = 24.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        title: const Text(
          'RecipeNook',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Public Recipes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _recipeService.getPublicRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No public recipes found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                final recipes = snapshot.data!.docs;
                return Column(
                  children: recipes.map((doc) {
                    final recipe = doc.data()! as Map<String, dynamic>;
                    recipe['id'] = doc.id;
                    return RecipeCard(
                        recipe: recipe, currentUsername: currentUsername);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "My Recipes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _recipeService.getUserRecipes(currentUsername),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'You have not added any recipes yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                final recipes = snapshot.data!.docs;
                return Column(
                  children: recipes.map((doc) {
                    final recipe = doc.data()! as Map<String, dynamic>;
                    recipe['id'] = doc.id;
                    return RecipeCard(
                        recipe: recipe, currentUsername: currentUsername);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 60), // extra bottom space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: headerColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateRecipePage(currentUsername: currentUsername),
            ),
          );
        },
      ),
    );
  }
}
