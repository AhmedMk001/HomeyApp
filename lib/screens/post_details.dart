import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:homey_app/screens/addReview.dart';
import 'package:homey_app/screens/edit_post.dart';
import 'package:homey_app/screens/request.dart';
import 'package:homey_app/screens/reservation.dart';
import 'package:homey_app/screens/reviews.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/mapScreen.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:latlong2/latlong.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class PostDetails extends StatefulWidget {
  late final PostData property;
  final String hostUid;

  PostDetails({
    super.key,
    required this.property,
    required this.hostUid,
  });

  @override
  State<PostDetails> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PostDetails> {
  bool isLoading = true;
  bool isShowMore = true;
  int activeIndex = 0;
  final credential = FirebaseAuth.instance.currentUser;

  late List<Location> _location;
  late MapController _mapController;

  Map postData = {};
  Map userData = {};

  final controller = TextEditingController();

  Future<void> getPostData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('postss')
          .doc(widget.property.postID)
          .get();

      postData = snapshot.data()!;
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('userss')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = snapshot.data()!;
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  sendMessage({required String title, required String message}) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAACFtIais:APA91bGDMPL2IldEvu2qVLIfDCbz-DN2CeT_pdCqh5WixVRm3jNK_xlJFu0N1lrRsysq3n1EA_Yk5mUUQZiaNsfV0z2mzTvXq3U4KZLHVVVwuwUXgLBvBQYJj__1jVuB8rr4ATwvlCZh'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": widget.property.token,
      "notification": {
        "title": title,
        "body": message,
        // "mutable_content": true,
        // "sound": "Tri-tone"
      }
    };

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    } else {
      print(res.reasonPhrase);
    }
  }

  Future<void> showImages() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: GridView.builder(
            itemCount: widget.property.imgUrls.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    activeIndex = index;
                  });
                },
                child: Image.network(
                  widget.property.imgUrls[index],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
              );
            },
          ),
        );
      },
    );
  }

  postLocation() async {
    List<String> postLocationSplit = widget.property.location.split(', ');

    _location = await locationFromAddress(
        postLocationSplit[1] + ', ' + postLocationSplit[0]);
    if (_location.isEmpty) {
      throw Exception('Could not find post location');
    }
  }

  @override
  void initState() {
    getPostData();
    getUserData();
    postLocation();
    _mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final allUserDataFromDB = Provider.of<UserProvider>(context).getUser;
    // final allPostDataFromDB = Provider.of<PostProvider>(context).getPost;

    return SafeArea(
      child: Scaffold(
          backgroundColor: backgroundColor,
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showImages();
                          },
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.25,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  activeIndex = index;
                                });
                              },
                            ),
                            itemCount: widget.property.imgUrls.length,
                            itemBuilder: (context, index, realIndex) {
                              return Image.network(
                                widget.property.imgUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 15,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black87),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 12.0),
                              child: Text(
                                '${activeIndex + 1}/${widget.property.imgUrls.length}',
                                style: const TextStyle(
                                    fontFamily: 'myFont',
                                    color: Colors.white,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            top: 18,
                            left: 15,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.property.location,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(
                                          "Entire ${widget.property.propertyType} for ${widget.property.category}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Published on ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor2),
                                        ),
                                        Text(
                                          DateFormat.yMMMMd().format(
                                              widget.property.datePublished),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor2),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${widget.property.averageRating.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Icon(
                                          CupertinoIcons.star_fill,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Reviews(
                                                        postDetails:
                                                            widget.property,
                                                        postId: widget
                                                            .property.postID,
                                                      )));
                                        },
                                        child: Text(
                                          '${widget.property.ratingCount.ceil()} reviews',
                                          style: TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w500),
                                        ))
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                              color: blackcolor,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Expanded(
                                child: StreamBuilder<
                                    DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('userss')
                                      .doc(widget.hostUid)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Something went wrong');
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.data() == null) {
                                      return Text('');
                                    }

                                    Map<String, dynamic> data =
                                        snapshot.data!.data()!;
                                    return Row(
                                      children: [
                                        Text(
                                          "Hosted by ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${data['username']}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: 85,
                                  width:
                                      MediaQuery.of(context).size.width * 0.27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.black45)),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        child: SvgPicture.asset(
                                          "assets/icons/bedroom-sleep-svgrepo-com.svg",
                                          height: 40,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "${widget.property.bedroom} bedroom",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 85,
                                  width:
                                      MediaQuery.of(context).size.width * 0.27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.black45)),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        child: SvgPicture.asset(
                                          "assets/icons/bathroom-bathtub-bubble-foam-water-svgrepo-com.svg",
                                          height: 40,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "${widget.property.bathroom} bathroom",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "Availabalility: ${widget.property.availability}",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "About this property : ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          widget.property.description,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: isShowMore ? 3 : null,
                          overflow: TextOverflow.fade,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                isShowMore = !isShowMore;
                              });
                            },
                            child: Text(
                              isShowMore ? "Show more" : "Show less",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            )),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "Amenities : ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Refrigerator',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.refrigirator
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/refrigerator1.svg",
                                height: 32,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Washer',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.washer
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/washing.svg",
                                height: 30,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Wifi',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.wifi
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/wifi.svg",
                                height: 30,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Tv',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.tv
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/tv.svg",
                                height: 32,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Smoke detector',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.smokeDetector
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/smoke.svg",
                                height: 32,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Garage',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.garage
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/garage.svg",
                                height: 32,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Pool',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.pool
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/pool-stairs-svgrepo-com.svg",
                                height: 32,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Balcony',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.balcony
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/balcony-svgrepo-com.svg",
                                height: 32,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Garden',
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: widget.property.garden
                                        ? TextDecoration.none
                                        : TextDecoration.lineThrough),
                              ),
                              leading: SvgPicture.asset(
                                "assets/icons/garden-planting-flower-svgrepo-com.svg",
                                height: 35,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  "Where you'll be",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              FutureBuilder(
                                future: postLocation(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: SpinKitFadingCircle(
                                      color: primaryColor,
                                      size: 35,
                                    ));
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 4,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 10),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.33,
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.centerLeft,
                                      child: FlutterMap(
                                        mapController: _mapController,
                                        options: MapOptions(
                                          onTap: (tapPosition, point) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FullScreenMap(
                                                  initialLocation: LatLng(
                                                      _location.first.latitude,
                                                      _location
                                                          .first.longitude),
                                                ),
                                              ),
                                            );
                                          },
                                          initialCenter: LatLng(
                                              _location.first.latitude,
                                              _location.first.longitude),
                                          initialZoom: 15,
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=876e16a5f08d4effa36bb967757cb826',
                                            subdomains: ['a', 'b', 'c'],
                                            userAgentPackageName:
                                                "com.example.homey_app",
                                            maxZoom: 22,
                                          ),
                                          CircleLayer(
                                            circles: [
                                              CircleMarker(
                                                  point: LatLng(
                                                      _location.first.latitude,
                                                      _location
                                                          .first.longitude),
                                                  radius: 80,
                                                  useRadiusInMeter: false,
                                                  color: transparentColor),
                                            ],
                                          ),
                                          MarkerLayer(markers: [
                                            Marker(
                                              width: 80.0,
                                              height: 80.0,
                                              point: LatLng(
                                                  _location.first.latitude,
                                                  _location.first.longitude),
                                              child: Icon(
                                                  CupertinoIcons.house_fill,
                                                  color: red,
                                                  size: 30.0),
                                            )
                                          ])
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  "${widget.property.administrativeArea}, ${widget.property.location}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "House rules :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          widget.property.rules,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: isShowMore ? 3 : null,
                          overflow: TextOverflow.fade,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                isShowMore = !isShowMore;
                              });
                            },
                            child: Text(
                              isShowMore ? "Show more" : "Show less",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            )),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        widget.property.uid ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? const SizedBox(
                                width: 5,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(12)),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddReview(
                                                  postId:
                                                      widget.property.postID,
                                                  postOwnerId:
                                                      widget.property.uid,
                                                )));
                                  },
                                  style: ButtonStyle(
                                      elevation: WidgetStateProperty.all(0),
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.black),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                      shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))),
                                  child: const Text(
                                    'Add Your Review',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                        const Gap(20),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(12)),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Reviews(
                                            postDetails: widget.property,
                                            postId: widget.property.postID,
                                          )));
                            },
                            style: ButtonStyle(
                                elevation: WidgetStateProperty.all(0),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.black),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            child: const Text(
                              'Show All Reviews',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: blackcolor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: widget.property.uid ==
                  FirebaseAuth.instance.currentUser!.uid
              ? PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: BottomAppBar(
                      color: Colors.white30,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Spacer(),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Delete this post?',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(height: 20),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty.all(
                                                        primaryColor),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('postss')
                                                      .doc(widget
                                                          .property.postID)
                                                      .delete();
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  print(e.toString());
                                                }
                                              },
                                              child: Text('Yes'),
                                            ),
                                            SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              CupertinoIcons.delete,
                              size: 25,
                              color: red,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Request(
                                    post: widget.property,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(primaryColor),
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 35)),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                            ),
                            child: Text(
                              "Requests",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            child: IconButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPost(post: widget.property),
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    widget.property = result;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 35,
                                color: Colors.green,
                              ),
                            ),
                          )
                        ],
                      )),
                )
              : PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    notchMargin: 5,
                    color: Colors.white30,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: userData['role'] == 'user'
                          ? ListView(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      widget.property.open == 'Reserved'
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          '${widget.property.price} dt ${widget.property.monthNight}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          widget.property.availability,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      child: widget.property.open == 'Reserved'
                                          ? Text("")
                                          : widget.property.open ==
                                                  'In progress of reservation...'
                                              ? SizedBox(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: Center(
                                                    child: Text(
                                                      "In progress of reservation...",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: blueColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Reservation(
                                                          post: widget.property,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty.all(
                                                            primaryColor),
                                                    padding:
                                                        WidgetStateProperty.all(
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        35)),
                                                    shape: WidgetStateProperty.all(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8))),
                                                  ),
                                                  child: Text(
                                                    "Reserve",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment:
                                  widget.property.status != 'pending'
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    String newNotifId = const Uuid().v1();

                                    await sendMessage(
                                        title: 'Failed',
                                        message:
                                            'We regret to inform you that your post has not met our publication criteria and has been rejected. We appreciate your submission and try to add new one.');

                                    await FirebaseFirestore.instance
                                        .collection('userss')
                                        .doc(widget.property.uid)
                                        .collection('notifications')
                                        .doc(newNotifId)
                                        .set({
                                      'notifId': newNotifId,
                                      'notifSender': userData['username'],
                                      'notifTitle': "Failed",
                                      'notifBody':
                                          'We regret to inform you that your post has not met our publication criteria and has been rejected. We appreciate your submission and try to add new one.',
                                      'notifDate': DateTime.now(),
                                      'token': widget.property.token,
                                    });

                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.success,
                                      title: 'Done',
                                      text: 'Post rejected!',
                                      onConfirmBtnTap: () async {
                                        setState(() {
                                          FirebaseFirestore.instance
                                              .collection('postss')
                                              .doc(widget.property.postID)
                                              .update({
                                            'status': 'rejected',
                                          });
                                        });
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MobileScreen()));
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      CupertinoIcons.clear_circled,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                widget.property.status != 'pending'
                                    ? SizedBox(
                                        child: Text(
                                          "You can Delete This Post",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          String newNotifId = const Uuid().v1();
                                          sendMessage(
                                              title: 'Succes',
                                              message:
                                                  'Thank you for your submission. Your new post has been successfully received and added to our platform. We appreciate your contribution!');
                                          await FirebaseFirestore.instance
                                              .collection('userss')
                                              .doc(widget.property.uid)
                                              .collection('notifications')
                                              .doc(newNotifId)
                                              .set({
                                            'notifId': newNotifId,
                                            'notifSender': userData['username'],
                                            'notifTitle': 'succes',
                                            'notifBody':
                                                'Thank you for your submission. Your new post has been successfully received and added to our platform. We appreciate your contribution!',
                                            'notifDate': DateTime.now(),
                                            'token': widget.property.token,
                                          });

                                          setState(() {
                                            FirebaseFirestore.instance
                                                .collection('postss')
                                                .doc(widget.property.postID)
                                                .update({
                                              'status': 'approved',
                                            });
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            CupertinoIcons.checkmark_alt_circle,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                    ),
                  ),
                )),
    );
  }
}
