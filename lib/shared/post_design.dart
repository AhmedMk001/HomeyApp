import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/provider/favorite_provider.dart';
import 'package:homey_app/screens/post_details.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/favorit.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostDesign extends StatefulWidget {
  final Map data;

  const PostDesign({
    super.key,
    required this.data,
  });

  @override
  State<PostDesign> createState() => _PostDesignState();
}

class _PostDesignState extends State<PostDesign> {
  bool isLoading = false;
  late Future<int> distance;
  late PageController _pageController;
  // ignore: unused_field
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    distance = initUserLocation();
    _pageController = PageController();
  }

  Future<int> initUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position userPosition = await Geolocator.getCurrentPosition();
    return calculateDistance(userPosition, widget.data["location"]);
  }

  Future<int> calculateDistance(
      Position userPosition, String postLocation) async {
    List<String> postLocationSplit = postLocation.split(', ');

    List<Location> postLocationList = await locationFromAddress(
        postLocationSplit[1] + ', ' + postLocationSplit[0]);

    if (postLocationList.isEmpty) {
      throw Exception('Could not find post location');
    }

    double distanceInMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      postLocationList[0].latitude,
      postLocationList[0].longitude,
    );

    return (distanceInMeters / 1000).floor();
  }

  @override
  Widget build(BuildContext context) {
    final providerF = Provider.of<FavoriteProvider>(context);

    List<String> imgUrls = List<String>.from(widget.data["imgUrls"]);

    final favorite = Favorite(
      postId: widget.data["postID"],
      title: widget.data["location"],
      imageUrl: imgUrls[0],
      propertyType: widget.data["propertyType"],
      averageRating: widget.data["averageRating"],
      price: "${widget.data["price"]} DT",
      monthNight: widget.data["monthNight"],
      uid: widget.data["uid"],
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostDetails(
                    property: PostData(
                      open: widget.data["open"],
                      status: widget.data["status"],
                      token: widget.data["token"],
                      location: widget.data["location"],
                      price: widget.data["price"],
                      bedroom: widget.data["bedroom"],
                      bathroom: widget.data["bathroom"],
                      description: widget.data["description"],
                      uid: widget.data["uid"],
                      postID: widget.data["postID"],
                      datePublished: widget.data["datePublished"].toDate(),
                      imgUrls: imgUrls,
                      wifi: widget.data["wifi"],
                      tv: widget.data["tv"],
                      washer: widget.data["washer"],
                      refrigirator: widget.data["refrigirator"],
                      smokeDetector: widget.data["smokeDetector"],
                      garage: widget.data["garage"],
                      pool: widget.data["pool"],
                      balcony: widget.data["balcony"],
                      garden: widget.data["garden"],
                      ratingCount: widget.data["ratingCount"],
                      averageRating: widget.data["averageRating"],
                      propertyType: widget.data["propertyType"],
                      category: widget.data["category"],
                      rules: widget.data["rules"],
                      availability: widget.data["availability"],
                      monthNight: widget.data["monthNight"],
                      administrativeArea: widget.data["administrativeArea"],
                    ),
                    hostUid: widget.data["uid"],
                  )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.97,
                child: PageView.builder(
                    itemCount: imgUrls.length,
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              child: AspectRatio(
                                  aspectRatio: 1.6,
                                  child: BlurHash(
                                    hash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
                                    image: imgUrls[index],
                                  ))),
                          Positioned(
                            bottom: 6,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              color: Colors.black.withOpacity(0.7),
                              child: Text(
                                '${index + 1}/${imgUrls.length}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: widget.data["imgUrls"].length,
                                effect: ExpandingDotsEffect(
                                  activeDotColor: Colors.blue,
                                  dotColor: Colors.grey,
                                  dotHeight: 8.0,
                                  dotWidth: 8.0,
                                  expansionFactor: 2.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 8,
                            child: IconButton(
                                onPressed: () {
                                  providerF.toggleFavorite(favorite);
                                },
                                icon: providerF.isExist(favorite)
                                    ? Icon(
                                        CupertinoIcons.heart_fill,
                                        color: red,
                                      )
                                    : Icon(
                                        CupertinoIcons.heart,
                                        color: primaryColor,
                                      )),
                          ),
                        ],
                      );
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 18,
                        ),
                        Text(
                          widget.data["location"],
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          Row(
                            children: [
                              Text(
                                '${widget.data['propertyType']} for ${widget.data["category"]}',
                                style:
                                    TextStyle(color: textColor, fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('postss')
                                  .doc(widget.data["postID"])
                                  .collection('reviews')
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Something went wrong');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: LoadingAnimationWidget
                                          .staggeredDotsWave(
                                              color: textColor, size: 20));
                                }
                                if (snapshot.data!.docs.isEmpty) {
                                  return Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.star_fill,
                                        size: 15,
                                      ),
                                      Text(
                                        "New ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                double averageRating = 0;
                                int reviewCount = 0;
                                for (var doc in snapshot.data!.docs) {
                                  Map<String, dynamic> data =
                                      doc.data()! as Map<String, dynamic>;
                                  averageRating += data['rating'];
                                  reviewCount++;
                                }
                                if (reviewCount > 0) {
                                  averageRating /= reviewCount;
                                  averageRating = double.parse(
                                      averageRating.toStringAsFixed(2));
                                }
                                return Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.star_fill,
                                      size: 15,
                                    ),
                                    Text(
                                      averageRating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          FutureBuilder<int>(
                            future: distance,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return LoadingAnimationWidget.staggeredDotsWave(
                                    color: textColor, size: 16);
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text('${snapshot.data!} kilometers away',
                                    style: TextStyle(
                                        color: textColor2, fontSize: 16));
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 4),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.data["availability"]}",
                          style: TextStyle(
                              fontSize: 16,
                              color: textColor2,
                              fontWeight: FontWeight.bold),
                        ),
                        widget.data["open"] == "Available"
                            ? Text(
                                "${widget.data["open"]}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 18, 211, 25),
                                    fontWeight: FontWeight.bold),
                              )
                            : widget.data["open"] ==
                                    "In progress of reservation..."
                                ? Text("${widget.data["open"]}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold))
                                : Text("${widget.data["open"]}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: red,
                                        fontWeight: FontWeight.bold))
                      ])),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${widget.data["price"]}dt",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        Text(" ${widget.data["monthNight"]}",
                            style:
                                TextStyle(fontSize: 18, color: primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
