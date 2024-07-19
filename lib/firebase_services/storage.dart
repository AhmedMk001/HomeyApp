import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<List<String>> uploadImagesToFirebaseStorage(List<File> images) async {
  final List<String> urls = [];
  final currentUser = FirebaseAuth.instance.currentUser;
  for (var img in images) {
    final storageRef = FirebaseStorage.instance
        .ref("postImages/${currentUser!.uid}/${Path.basename(img.path)}");

    try {
      await storageRef.putFile(img);
      final url = await storageRef.getDownloadURL();
      urls.add(url);
    } catch (e) {
      print('Error uploading image: $e');
    }

    // await storageRef.putFile(img).whenComplete(() async {
    //   await storageRef.getDownloadURL().then((value) {
    //     urls.add(value);
    //   });
    // });
  }
  return urls;
}
