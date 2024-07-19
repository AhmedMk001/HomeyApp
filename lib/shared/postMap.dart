import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:latlong2/latlong.dart';

class PostsMapScreen extends StatefulWidget {
  const PostsMapScreen({
    super.key,
  });

  @override
  State<PostsMapScreen> createState() => _PostsMapScreenState();
}

class _PostsMapScreenState extends State<PostsMapScreen> {
  late Position _currentPosition;
  List<Map<String, dynamic>> postDataList = [];
  List<Location> _locations = [];
  late MapController _mapController;

  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPostData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('postss')
          .where("status", isEqualTo: "approved")
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          postDataList.add(doc.data());
        }
        
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postLocations() async {
    var tempList = List<Map<String, dynamic>>.from(postDataList);
    for (var postData in tempList) {
      if (postData.isNotEmpty && postData["location"] != null) {
        List<Location> locations =
            await locationFromAddress(postData["location"]);
        if (locations.isNotEmpty) {
          _locations.add(locations.first);
        } else {
          throw Exception('Could not find post location');
        }
      } else {
        throw Exception('Post data is empty or location is null');
      }
    }
  }
  Future<void> initializeData() async {
  await getCurrentLocation();
  await getPostData();
  await postLocations();
}

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    getCurrentLocation().then((_) => getPostData()
        .then((_) => postLocations().then((_) => setState(() {}))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initializeData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: SpinKitFadingCircle(
                color: primaryColor,
                size: 35,
              ));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Stack(
                children: [
                  FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:LatLng(_currentPosition.latitude, _currentPosition.longitude),
                        initialZoom: 5.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=876e16a5f08d4effa36bb967757cb826',
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: "com.example.homey_app",
                          maxZoom: 22,
                        ),
                        MarkerLayer(
                            markers: _locations.map((location) {
                          return Marker(
                            width: 80.0,
                            height: 80.0,
                            point:
                                LatLng(location.latitude, location.longitude),
                            child: Icon(CupertinoIcons.map_pin_ellipse,
                                color: primaryColor, size: 30.0),
                          );
                        }).toList())
                      ]),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
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
                      margin:
                          EdgeInsets.symmetric(vertical: 80, horizontal: 30),
                      padding: EdgeInsets.all(6),
                      child: Positioned(
                          top: 80, left: 30, child: Icon(CupertinoIcons.clear)),
                    ),
                  )
                ],
              );
            }
          }),
    );
  }
}
