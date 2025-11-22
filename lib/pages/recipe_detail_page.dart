import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/recipe_service.dart';
import 'edit_recipe_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;
  final String currentUsername;

  const RecipeDetailPage({
    required this.recipeId,
    required this.currentUsername,
    super.key,
  });

  bool isOwner(Map<String, dynamic> recipe) => recipe['owner'] == currentUsername;

  void openFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullImageView(imageUrl: imageUrl),
      ),
    );
  }

  // --------------------------
  // Helper: safely parse ingredients/steps
  // --------------------------
  List<String> parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      // Split by new lines or commas if needed
      return value.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    const Color headerColor = Color(0xFFE9DDCB);
    const Color lightBoxColor = Color(0xFFF7F1EC);
    const Color dottedColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: AppBar(
        backgroundColor: headerColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Recipe Detail",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final doc = snapshot.data!;
          if (!doc.exists) return const Center(child: Text("Recipe not found"));
          final recipe = doc.data() as Map<String, dynamic>;
          recipe['id'] = doc.id;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Banner Image
                  if (recipe['imageUrl'] != null && recipe['imageUrl'] != '')
                    GestureDetector(
                      onTap: () => openFullImage(context, recipe['imageUrl']),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          recipe['imageUrl'],
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Title with dotted border
                  DottedBorder(
                    color: dottedColor,
                    strokeWidth: 2,
                    dashPattern: const [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      color: headerColor,
                      child: Text(
                        recipe['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cookie(
                          fontSize: 42,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Edit & Delete buttons (only owner)
                  if (isOwner(recipe))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditRecipePage(
                                  recipe: recipe,
                                  currentUsername: currentUsername,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                          onPressed: () async {
                            bool confirmed = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Recipe'),
                                content: const Text(
                                    'Are you sure you want to delete this recipe?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete')),
                                ],
                              ),
                            );

                            if (confirmed) {
                              await RecipeService().deleteRecipe(recipe['id']);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  if (isOwner(recipe)) const SizedBox(height: 20),

                  // Info Boxes
                  buildInfoBox(title: "Description", content: recipe['description'] ?? '', boxColor: lightBoxColor),
                  buildInfoBox(title: "Category", content: recipe['category'] ?? '', boxColor: lightBoxColor),
                  buildListBox(
                    title: "Ingredients",
                    items: parseList(recipe['ingredients']).map((e) => "• $e").toList(),
                    boxColor: lightBoxColor,
                  ),
                  buildListBox(
                    title: "Steps",
                    items: parseList(recipe['steps']).map((e) => "• $e").toList(),
                    boxColor: lightBoxColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoBox({
    required String title,
    required String content,
    required Color boxColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }

  Widget buildListBox({
    required String title,
    required List<String> items,
    required Color boxColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...items.map((i) => Text(i)).toList(),
        ],
      ),
    );
  }
}

class FullImageView extends StatelessWidget {
  final String imageUrl;
  const FullImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
