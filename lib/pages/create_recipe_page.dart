import 'package:flutter/material.dart';
import 'recipe_form.dart';
import '../services/recipe_service.dart';

class CreateRecipePage extends StatelessWidget {
  final String currentUsername;
  const CreateRecipePage({required this.currentUsername, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Recipe")),
      body: RecipeForm(
        currentUsername: currentUsername,
        onSubmit: (data) async {
          await RecipeService().createRecipe(data);
        },
      ),
    );
  }
}
