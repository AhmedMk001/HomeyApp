import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homey_app/shared/favorit.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Favorite> _favorites = [];

  FavoriteProvider() {
    loadFavorites();
  }

  List<Favorite> get favorites => _favorites;

  void toggleFavorite(Favorite favorite) async{
    print('Toggling favorite...');
    final isExist = _favorites.contains(favorite);
    if (isExist) {
      _favorites.remove(favorite);
    } else {
      _favorites.add(favorite);
    }
    notifyListeners();

    // Save favorites to Firestore
  await  saveFavorites(_favorites);
  }

  bool isExist(Favorite favorite) {
    final isExist = _favorites.contains(favorite);
    return isExist;
  }

  Future<void> saveFavorites(List<Favorite> favorites) async {
     print('Saving favorites...');
    final userFavoritesCollection = FirebaseFirestore.instance.collection('userFavorites');

    // Start a batch
    final batch = FirebaseFirestore.instance.batch();

  try {
  // Clear existing favorites
  var snapshot = await userFavoritesCollection.get();
  for (DocumentSnapshot ds in snapshot.docs) {
    batch.delete(ds.reference);
  }
} catch (e) {
  print('Failed to delete existing favorites: $e');
}

  try {
  // Add new favorites
  for (var favorite in favorites) {
    var docRef = userFavoritesCollection.doc(favorite.postId);
    batch.set(docRef, favorite.convert2Map());
  }
} catch (e) {
  print('Failed to add new favorites: $e');
}

    // Commit the batch
    try {
  await batch.commit();
} catch (e) {
  print('Failed to update favorites: $e');
}
  }

  Future<void> loadFavorites() async {
    print('Loading favorites...');
    final userFavoritesCollection = FirebaseFirestore.instance.collection('userFavorites');

    // Get the favorites from Firestore
    final snapshot = await userFavoritesCollection.get();

    // Convert the documents to Favorite objects
    _favorites = snapshot.docs.map((doc) => Favorite.convertSnap2Model(doc)).toList();

    notifyListeners();
  } 
}
