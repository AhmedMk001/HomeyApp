


import 'package:flutter/material.dart';
import 'package:homey_app/firebase_services/auth.dart';
import 'package:homey_app/models/user.dart';

class UserProvider with ChangeNotifier {
  UserData? _userData;
  UserData? get getUser => _userData;
  
  refreshUser() async {
    UserData userData = await AuthMethods().getUserDetails();
    _userData = userData;
    notifyListeners();
  }
 }