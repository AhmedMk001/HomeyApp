import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  final String open;
  final String status;
  final String token;
  final String category;
  final String propertyType;
  final String location;
  final String administrativeArea;
  final String price;
  final String bedroom;
  final String bathroom;
  final String description;
  final String rules;
  final String uid;
  final String postID;
  final DateTime datePublished;
  final String availability;
  final String monthNight;
  final List<String> imgUrls;
  final bool wifi;
  final bool tv;
  final bool washer;
  final bool refrigirator;
  final bool smokeDetector;
  final bool garage;
  final bool pool;
  final bool balcony;
  final bool garden;
  final double ratingCount;
  final double averageRating;

  PostData({
    required this.open,
    required this.administrativeArea,
    required this.status,
    required this.token,
    required this.propertyType,
    required this.category,
    required this.rules,
    required this.availability,
    required this.monthNight,
    required this.location,
    required this.price,
    required this.bedroom,
    required this.bathroom,
    required this.description,
    required this.uid,
    required this.postID,
    required this.datePublished,
    required this.imgUrls,
    required this.wifi,
    required this.tv,
    required this.washer,
    required this.refrigirator,
    required this.smokeDetector,
    required this.garage,
    required this.pool,
    required this.balcony,
    required this.garden,
    required this.ratingCount,
    required this.averageRating,
  });

  // To convert the PostData(Data type) to   Map<String, Object>
  Map<String, dynamic> convert2Map() {
    return {
      "open": open,
      "administrativeArea": administrativeArea,
      "status": status,
      "token": token,
      "location": location,
      "propertyType": propertyType,
      "category": category,
      "rules": rules,
      "availability": availability,
      "monthNight": monthNight,
      "price": price,
      "bedroom": bedroom,
      "bathroom": bathroom,
      "description": description,
      "uid": uid,
      "postID": postID,
      "datePublished": datePublished,
      "imgUrls": imgUrls,
      "wifi": wifi,
      "tv": tv,
      "washer": washer,
      "refrigirator": refrigirator,
      "smokeDetector": smokeDetector,
      "garage": garage,
      "pool": pool,
      "balcony": balcony,
      "garden": garden,
      "ratingCount": ratingCount,
      "averageRating": averageRating,
    };
  }

  static PostData convertSnap2Model(DocumentSnapshot snap) {
    if (!snap.exists) {
      return PostData(
        open: "",
        administrativeArea: "",
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
        availability: '',
        monthNight: '',
      );
    }

    var data = snap.data();
    if (data != null) {
      var snapshot = data as Map<String, dynamic>;
      return PostData(
        status: snapshot["status"],
        administrativeArea: snapshot["administrativeArea"],
        open: snapshot["open"],
        token: snapshot["token"],
        location: snapshot["location"],
        propertyType: snapshot["propertyType"],
        category: snapshot["category"],
        rules: snapshot["rules"],
        monthNight: snapshot["monthNight"],
        uid: snapshot["uid"],
        price: snapshot["price"],
        bedroom: snapshot["bedroom"],
        bathroom: snapshot["bathroom"],
        description: snapshot["description"],
        postID: snapshot["postID"],
        datePublished: snapshot["datePublished"].toDate(),
        availability: snapshot["availability"],
        imgUrls: List<String>.from(snapshot["imgUrls"]),
        wifi: snapshot["wifi"],
        tv: snapshot["tv"],
        washer: snapshot["washer"],
        refrigirator: snapshot["refrigirator"],
        smokeDetector: snapshot["smokeDetector"],
        garage: snapshot["garage"],
        pool: snapshot["pool"],
        balcony: snapshot["balcony"],
        garden: snapshot["garden"],
        ratingCount: snapshot["ratingCount"],
        averageRating: snapshot["averageRating"],
      );
    } else {
      throw Exception('Document does not exist');
    }
  }
}
