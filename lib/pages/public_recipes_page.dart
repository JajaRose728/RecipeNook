import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';

const _colorCreamBackground = Color(0xFFF0D597);
const _colorCardBeige = Color(0xFFE9DDCB);
const _colorDarkGreen = Color(0xFF4F6D44);
const _colorInputText = Color(0xFF6A5A69);

// Category colors
const Map<String, Color> categoryColors = {
  'All': _colorCardBeige,
  'Breakfast': Color(0xFFFFD580),
  'Lunch': Color(0xFF90CAF9),
  'Dinner': Color(0xFF81C784),
  'Dessert': Color(0xFFF48FB1),
  'Snack': Color(0xFFFFF176),
  'Beverage': Color(0xFFCE93D8),
};

class PublicRecipesPage extends StatefulWidget {
  final String currentUsername;
  final RecipeService _recipeService = RecipeService();

  PublicRecipesPage({required this.currentUsername, super.key});

  @override
  State<PublicRecipesPage> createState() => _PublicRecipesPageState();
}

class _PublicRecipesPageState extends State<PublicRecipesPage> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Beverage',
  ];

  @override
  Widget build(BuildContext context) {
    const double padding = 24.0;
    final double dropdownWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: _colorCreamBackground,
      appBar: AppBar(
        backgroundColor: _colorCardBeige,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Public Recipes',
          style: GoogleFonts.cookie(
            fontSize: 36,
            color: _colorDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar & category dropdown
          Padding(
            padding: const EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _colorCardBeige,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _colorDarkGreen.withOpacity(0.5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: _colorInputText),
                    decoration: InputDecoration(
                      hintText: "Search by recipe title",
                      hintStyle: TextStyle(
                          color: _colorInputText.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, color: _colorDarkGreen),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Category filter
                Container(
                  width: dropdownWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _colorCardBeige,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _colorDarkGreen.withOpacity(0.5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: categories.contains(selectedCategory)
                        ? selectedCategory
                        : 'All',
                    icon: const Icon(Icons.arrow_drop_down,
                        color: _colorDarkGreen),
                    underline: const SizedBox(),
                    isExpanded: true,
                    style: TextStyle(color: _colorDarkGreen, fontSize: 16),
                    dropdownColor: _colorCardBeige,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: categoryColors[category],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Recipes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget._recipeService.getPublicRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No public recipes found.',
                      style: TextStyle(fontSize: 16, color: _colorInputText),
                    ),
                  );
                }

                final filteredRecipes = snapshot.data!.docs.map((doc) {
                  final recipe = doc.data()! as Map<String, dynamic>;
                  recipe['id'] = doc.id;

                  if (!categories.contains(recipe['category'])) {
                    recipe['category'] = 'All';
                  }
                  return recipe;
                }).where((recipe) {
                  final matchesTitle = recipe['title']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery);
                  final matchesCategory = selectedCategory == 'All' ||
                      recipe['category'] == selectedCategory;
                  return matchesTitle && matchesCategory;
                }).toList();

                if (filteredRecipes.isEmpty) {
                  return Center(
                    child: Text(
                      'No recipes match your search.',
                      style: TextStyle(fontSize: 16, color: _colorInputText),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: filteredRecipes.map((recipe) {
                      return RecipeCard(
                        recipe: recipe,
                        currentUsername: widget.currentUsername,
                        categoryColor:
                        categoryColors[recipe['category']] ?? _colorCardBeige,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
