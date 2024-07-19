import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String username;
  String email;
  String password;
  String uid;
  String phone;
  String location;
  String role;
  String userAdministrativeArea;

  UserData({
    required this.username,
    required this.userAdministrativeArea,
    required this.email,
    required this.password,
    required this.uid,
    required this.phone,
    required this.location,
    required this.role,
  });

  // To convert the UserData(Data type) to   Map<String, Object>
  Map<String, dynamic> convert2Map() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "uid": uid,
      "phone": phone,
      "location": location,
      "role": role,
      "userAdministrativeArea": userAdministrativeArea,

    };
  }

  static convertSnap2Model(
    DocumentSnapshot snap,
  ) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserData(
      email: snapshot["email"],
      username: snapshot["username"],
      password: snapshot["password"],
      uid: snapshot["uid"],
      phone: snapshot["phone"],
      location: snapshot["location"],
      userAdministrativeArea: snapshot["userAdministrativeArea"],
      role: snapshot["role"],
    );
  }
}
