import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/recipe_service.dart';
import 'edit_recipe_page.dart';
import '../constants.dart';

// Color palette matching login screen
const _colorCreamBackground = Color(0xFFF0D597);
const _colorCardBeige = Color(0xFFE9DDCB);
const _colorDarkGreen = Color(0xFF4F6D44);
const _colorButtonGreen = Color(0xFFA8C67B);
const _colorInputText = Color(0xFF6A5A69);
const _colorWhite = Colors.white;
const _colorTitlePop = Color(0xFFC9B186); // slightly pop for title

// Category colors matching HomePage
const Map<String, Color> categoryColors = {
  'All': _colorCardBeige,
  'Breakfast': Color(0xFFFFD580), // Light Orange
  'Lunch': Color(0xFF90CAF9),     // Light Blue
  'Dinner': Color(0xFF81C784),    // Light Green
  'Dessert': Color(0xFFF48FB1),   // Pink
  'Snack': Color(0xFFFFF176),     // Yellow
  'Beverage': Color(0xFFCE93D8),  // Purple
  'Other': _colorCardBeige,
};

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

  List<String> parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      return value.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorCreamBackground,
      appBar: AppBar(
        backgroundColor: _colorCardBeige,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Recipe Detail",
          style: GoogleFonts.montserrat(
            color: _colorDarkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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

                  // Title with dotted border & green background
                  DottedBorder(
                    color: _colorWhite,
                    strokeWidth: 2,
                    dashPattern: const [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _colorDarkGreen, // green background
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        recipe['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cookie(
                          fontSize: 48,
                          color: _colorWhite,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category badge with color from mapping
                  if (recipe['category'] != null && recipe['category'] != '')
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: categoryColors[recipe['category']] ?? _colorButtonGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recipe['category'],
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
                            backgroundColor: _colorDarkGreen,
                          ),
                          icon: const Icon(Icons.edit, color: _colorWhite),
                          label: const Text("Edit", style: TextStyle(color: _colorWhite)),
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
                          icon: const Icon(Icons.delete, color: _colorWhite),
                          label: const Text("Delete", style: TextStyle(color: _colorWhite)),
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
                  buildInfoBox(
                      title: "Description",
                      content: recipe['description'] ?? '',
                      boxColor: _colorCardBeige,
                      fontSize: 18),
                  buildListBox(
                      title: "Ingredients",
                      items: parseList(recipe['ingredients']).map((e) => "• $e").toList(),
                      boxColor: _colorCardBeige,
                      fontSize: 18),
                  buildListBox(
                      title: "Steps",
                      items: parseList(recipe['steps']).map((e) => "• $e").toList(),
                      boxColor: _colorCardBeige,
                      fontSize: 18),
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
    double fontSize = 16,
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
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: _colorDarkGreen)),
          const SizedBox(height: 8),
          Text(content,
              style: TextStyle(fontSize: fontSize, color: _colorInputText)),
        ],
      ),
    );
  }

  Widget buildListBox({
    required String title,
    required List<String> items,
    required Color boxColor,
    double fontSize = 16,
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
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: _colorDarkGreen)),
          const SizedBox(height: 8),
          ...items.map((i) => Text(i,
              style: TextStyle(fontSize: fontSize, color: _colorInputText))).toList(),
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
