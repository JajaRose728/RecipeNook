import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of all public recipes (owner == 'public')
  Stream<QuerySnapshot> getPublicRecipes() {
    return _db
        .collection('recipes')
        .where('owner', isEqualTo: 'public')
        .snapshots();
  }

  /// Stream of recipes for the current user
  Stream<QuerySnapshot> getUserRecipes(String username) {
    return _db
        .collection('recipes')
        .where('owner', isEqualTo: username)
        .snapshots();
  }

  /// Create a new recipe
  Future<void> createRecipe(Map<String, dynamic> data) async {
    await _db.collection('recipes').add(data);
  }

  /// Update an existing recipe
  Future<void> updateRecipe(String id, Map<String, dynamic> data) async {
    await _db.collection('recipes').doc(id).update(data);
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String id) async {
    await _db.collection('recipes').doc(id).delete();
  }
}
