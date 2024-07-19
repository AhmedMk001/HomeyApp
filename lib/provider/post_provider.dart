import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class PostProvider with ChangeNotifier {
  List<DocumentSnapshot> _posts = [];

  List<DocumentSnapshot> get posts => _posts;

  void setPosts(List<DocumentSnapshot> posts) {
    _posts = posts;
    notifyListeners();
  }
}
