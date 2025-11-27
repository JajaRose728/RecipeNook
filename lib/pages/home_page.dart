import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/recipe_service.dart';
import 'create_recipe_page.dart';
import '../widgets/recipe_card.dart';
import '../constants.dart';
import 'public_recipes_page.dart';

// Color palette
const _colorCreamBackground = Color(0xFFF0D597);
const _colorCardBeige = Color(0xFFE9DDCB);
const _colorDarkGreen = Color(0xFF4F6D44);
const _colorButtonGreen = Color(0xFFA8C67B);
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

class HomePage extends StatefulWidget {
  final String currentUsername;
  final RecipeService _recipeService = RecipeService();

  HomePage({required this.currentUsername, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    const double buttonHeight = 50;

    return Scaffold(
      backgroundColor: _colorCreamBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Title with Background Image
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/bg.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/whiteLogo.png',
                          width: 120,
                          height: 120,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'RecipeNook',
                          style: GoogleFonts.cookie(
                            fontSize: 75,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Search Bar
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
                  hintStyle: TextStyle(color: _colorInputText.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: _colorDarkGreen),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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

            // Buttons Row: Category + Browse Public Recipes (Flexible)
            Center(
              child: Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: buttonHeight,
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
                  ),

                  const SizedBox(width: 16),

                  // Browse Public Recipes Button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorDarkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                                color: Colors.black26, style: BorderStyle.solid),
                          ),
                          shadowColor: Colors.black45,
                          elevation: 6,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicRecipesPage(
                                  currentUsername: widget.currentUsername),
                            ),
                          );
                        },
                        child: Text(
                          "Browse Public Recipes",
                          style: GoogleFonts.cookie(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // My Recipes Header
            Center(
              child: Text(
                "My Recipes",
                style: GoogleFonts.pacifico(
                  fontSize: 24,
                  color: _colorDarkGreen,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Recipe List
            StreamBuilder<QuerySnapshot>(
              stream:
              widget._recipeService.getUserRecipes(widget.currentUsername),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text(
                    'You have not added any recipes yet.',
                    style: TextStyle(fontSize: 16, color: _colorInputText),
                  );
                }

                final recipes = snapshot.data!.docs.map((doc) {
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

                if (recipes.isEmpty) {
                  return Text(
                    'No recipes match your search.',
                    style: TextStyle(fontSize: 16, color: _colorInputText),
                  );
                }

                return Column(
                  children: recipes.map((recipe) {
                    return RecipeCard(
                      recipe: recipe,
                      currentUsername: widget.currentUsername,
                      categoryColor:
                      categoryColors[recipe['category']] ?? _colorCardBeige,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _colorCardBeige,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateRecipePage(currentUsername: widget.currentUsername),
            ),
          );
        },
      ),
    );
  }
}
