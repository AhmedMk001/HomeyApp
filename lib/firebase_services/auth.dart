import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homey_app/models/user.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AuthMethods {
  Future<void> register({
    required emailll,
    required passworddd,
    required context,
    required usernameee,
    required phone,
    required locationnn,
    required userAdministrativeArea
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailll,
        password: passworddd,
      );

      CollectionReference users =
          FirebaseFirestore.instance.collection('userss');

      UserData userr = UserData(
          username: usernameee,
          email: emailll,
          password: passworddd,
          uid: credential.user!.uid,
          phone: phone,
          location: locationnn,
          userAdministrativeArea: userAdministrativeArea,
          role: 'user');

      await users
          .doc(credential.user!.uid)
          .set(userr.convert2Map())
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error...',
          text: 'Email used!',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Check your informations please!',
      );
    }
  }

  Future<UserCredential?> login(
      {required emaill, required passwordd, required context}) async {
    try {
      final user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emaill, password: passwordd);
      final userDoc = await FirebaseFirestore.instance
          .collection('userss')
          .doc(user.user!.uid)
          .get();

      if (!userDoc.exists) {
        // User doesn't exist in the database, show an error message
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'User not found. Please sign up.',
        );
        return null;
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'user not found! please sign_up',
        );
      } else if (e.code == 'wrong-password') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'wrong password!',
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'Check Your Email or Password!',
        );
      }
      return null;
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Error logging in!',
      );

      return null;
    }
  }

  // function to get user details from Firestore (Database)
  Future<UserData> getUserDetails() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('userss')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return UserData.convertSnap2Model(snap);
  }
}
