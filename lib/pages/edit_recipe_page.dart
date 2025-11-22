import 'package:flutter/material.dart';
import 'recipe_form.dart';
import '../services/recipe_service.dart';

class EditRecipePage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String currentUsername;

  const EditRecipePage({
    super.key,
    required this.recipe,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context) {
    final String recipeId = recipe['id']; // ensure ID is extracted safely

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Recipe"),
      ),
      body: RecipeForm(
        currentUsername: currentUsername,
        initialData: recipe,   // pre-fill form
        isEdit: true,
        onSubmit: (updatedData) async {
          await RecipeService().updateRecipe(recipeId, updatedData);

          // go back after saving
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
