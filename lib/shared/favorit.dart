import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String postId;
  final String title;
  final String imageUrl;
  final String propertyType;
  final double averageRating;
  final String price;
  final String monthNight;
  final String uid;

  Favorite(
      {required this.postId,
      required this.title,
      required this.imageUrl,
      required this.propertyType,
      required this.averageRating,
      required this.price,
      required this.monthNight,
      required this.uid});
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Favorite &&
        other.postId == postId &&
        other.title == title &&
        other.propertyType == propertyType &&
        other.averageRating == averageRating &&
        other.monthNight == monthNight &&
        other.uid == uid &&
        other.price == price &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode =>
      postId.hashCode ^
      title.hashCode ^
      imageUrl.hashCode ^
      propertyType.hashCode ^
      averageRating.hashCode ^
      monthNight.hashCode ^
      uid.hashCode ^
      price.hashCode;

  // To convert the Favorite (Data type) to   Map<String, Object>
  Map<String, dynamic> convert2Map() {
    return {
      "postId": postId,
      "title": title,
      "imageUrl": imageUrl,
      "propertyType": propertyType,
      "monthNight": monthNight,
      "averageRating": averageRating,
      "price": price,
      "uid": uid,
    };
  }

  static Favorite convertSnap2Model(DocumentSnapshot snap) {
    if (!snap.exists) {
      return Favorite(
        postId: '',
        price: '',
        uid: '',
        averageRating: 0.0,
        propertyType: '',
        monthNight: '',
        title: '',
        imageUrl: '',
      );
    }

    var data = snap.data();
    if (data != null) {
      var snapshot = data as Map<String, dynamic>;
      return Favorite(
        propertyType: snapshot["propertyType"],
        monthNight: snapshot["monthNight"],
        uid: snapshot["uid"],
        price: snapshot["price"],
        averageRating: snapshot["averageRating"],
        postId: snapshot["postId"],
        title: snapshot["title"],
        imageUrl:snapshot["imageUrl"],
      );
    } else {
      throw Exception('Document does not exist');
    }
  }
}
