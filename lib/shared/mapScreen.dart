import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:latlong2/latlong.dart';

class FullScreenMap extends StatelessWidget {
  final LatLng initialLocation;

  const FullScreenMap({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
              options: MapOptions(
                initialCenter: initialLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=876e16a5f08d4effa36bb967757cb826',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: "com.example.homey_app",
                  maxZoom: 20,
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                        point: initialLocation,
                        radius: 100,
                        useRadiusInMeter: false,
                        color: transparentColor
                        ),
                  ],
                ),
                MarkerLayer(markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: initialLocation,
                    child:
                        Icon(CupertinoIcons.house_fill, color: red, size: 30.0),
                  )
                ])
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
              margin: EdgeInsets.symmetric(vertical: 80, horizontal: 30),
              padding: EdgeInsets.all(6),
              child: Positioned(
                  top: 80, left: 30, child: Icon(CupertinoIcons.clear)),
            ),
          )
        ],
      ),
    );
  }
}
