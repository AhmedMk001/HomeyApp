import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homey_app/firebase_services/storage.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/shared/snackar.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  String newId = const Uuid().v1();
  Map userData = {};

  // CollectionReference posts = FirebaseFirestore.instance.collection('postss');

Future<void>  uploadPost({
    required availability,
    required location,
    required administrativeArea,
    required context,
    required uid,
    required price,
    required bedroom,
    required bathroom,
    required description,
    required images,
    required wifi,
    required tv,
    required washer,
    required refrigirator,
    required smokeDetector,
    required garage,
    required pool,
    required balcony,
    required garden,
    required monthNight,
    required rules,
    required category,
    required propertyType,
    required token,
  }) async {
    try {
      // Parse the availability date from the string
      // DateTime parsedAvailability = DateTime.parse(availability);

      List<String> urls = await uploadImagesToFirebaseStorage(images);

      CollectionReference posts =
          FirebaseFirestore.instance.collection('postss');

      PostData postt = PostData(
        open: 'Available',
        administrativeArea: administrativeArea,
        status: 'pending',
        token: token,
        location: location,
        price: price,
        bedroom: bedroom,
        bathroom: bathroom,
        description: description,
        uid: FirebaseAuth.instance.currentUser!.uid,
        postID: newId,
        datePublished: DateTime.now(),
        imgUrls: urls,
        wifi: wifi,
        tv: tv,
        washer: washer,
        refrigirator: refrigirator,
        smokeDetector: smokeDetector,
        garage: garage,
        pool: pool,
        balcony: balcony,
        garden: garden,
        averageRating: 0.0, // Default rating
        ratingCount: 0,
        propertyType: propertyType,
        category: category,
        rules: rules,
        availability: availability,
        monthNight: monthNight, // Default rating count
      );

      posts
          .doc(newId)
          .set(postt.convert2Map())
          .then((value) => print("Done........"))
          .catchError((error) => print("Failed to post: $error"));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      showSnackBar(context, 'Failed to upload post: $e');
    }
  }

  // function to get post details from Firestore (Database)

  Future<PostData> getPostDetails() async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('postss')
          .doc(newId)
          .get();

      if (snap.exists) {
        return PostData.convertSnap2Model(snap);
      } else {
        return PostData(
          open: '',
          administrativeArea: '',
          status: '',
          token: '',
          location: '',
          price: '',
          bedroom: '',
          bathroom: '',
          description: '',
          uid: '',
          postID: '',
          datePublished: DateTime.now(),
          imgUrls: [],
          wifi: false,
          tv: false,
          washer: false,
          refrigirator: false,
          smokeDetector: false,
          garage: false,
          pool: false,
          balcony: false,
          garden: false,
          ratingCount: 0.0,
          averageRating: 0.0,
          propertyType: '',
          category: '',
          rules: '',
          availability:'',
          monthNight: '',
        );
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }
}
