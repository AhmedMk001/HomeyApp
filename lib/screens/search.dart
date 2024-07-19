import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/screens/post_details.dart';
import 'package:homey_app/shared/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late String searchQuery;
  RangeValues _currentPriceRange = const RangeValues(0, 5000);
  double _currentMinBedrooms = 0;
  double _currentMinBathrooms = 0;
  bool wifi = false;
  bool tv = false;
  bool washer = false;
  bool refrigirator = false;
  bool smokeDetector = false;
  bool garage = false;
  bool pool = false;
  bool balcony = false;
  bool garden = false;
  List<PostData> posts = [];
  List<PostData> postsPosts = [];
  List<PostData> originalPosts = [];
  bool _showAmenities = false;
  String? _propertyType;
  String? _category;

  late StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot<Map<String, dynamic>>> postsSnapshotList = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    searchQuery = '';
    _currentPriceRange = const RangeValues(0, 5000);
    _currentMinBedrooms = 0;
    _currentMinBathrooms = 0;
    wifi = false;
    tv = false;
    washer = false;
    refrigirator = false;
    smokeDetector = false;
    garage = false;
    pool = false;
    balcony = false;
    garden = false;
    posts = [];
    originalPosts = [];
    _propertyType = null;
    _category = null;
    // Get the first page of posts
    subscription = FirebaseFirestore.instance
        .collection('postss')
        .orderBy('datePublished', descending: true)
        .limit(8)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        postsSnapshotList = querySnapshot.docs;
        posts = postsSnapshotList
            .map((doc) => PostData.convertSnap2Model(doc))
            .toList();
        originalPosts = List.from(posts);
        postsPosts = List.from(posts);
      });
    });
  }

  List<PostData> filterPosts() {
    if (searchQuery.isNotEmpty) {
      posts = posts
          .where((post) =>
              post.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
              post.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }

    posts = posts.where((post) {
      final postPrice =
          double.tryParse(post.price.replaceAll(RegExp(r'[^\d.]'), ''));
      return postPrice != null &&
          postPrice >= _currentPriceRange.start &&
          postPrice <= _currentPriceRange.end;
    }).toList();

    posts = posts
        .where((post) => num.parse(post.bedroom) >= _currentMinBedrooms)
        .toList();

    posts = posts
        .where((post) => num.parse(post.bathroom) >= _currentMinBathrooms)
        .toList();

    if (_propertyType != null && _propertyType != 'Any') {
      posts =
          posts.where((post) => post.propertyType == _propertyType).toList();
    }

    if (_category != null && _category != 'Any') {
      posts = posts.where((post) => post.category == _category).toList();
    }

    if (wifi) {
      posts = posts.where((post) => post.wifi).toList();
    }

    if (tv) {
      posts = posts.where((post) => post.tv).toList();
    }

    if (washer) {
      posts = posts.where((post) => post.washer).toList();
    }

    if (refrigirator) {
      posts = posts.where((post) => post.refrigirator).toList();
    }

    if (smokeDetector) {
      posts = posts.where((post) => post.smokeDetector).toList();
    }

    if (garage) {
      posts = posts.where((post) => post.garage).toList();
    }

    if (pool) {
      posts = posts.where((post) => post.pool).toList();
    }

    if (balcony) {
      posts = posts.where((post) => post.balcony).toList();
    }

    if (garden) {
      posts = posts.where((post) => post.garden).toList();
    }

    return posts;
  }

  void resetFilters() {
    setState(() {
      searchQuery.isEmpty;
      _currentPriceRange = const RangeValues(0, 5000);
      _currentMinBedrooms = 0;
      _currentMinBathrooms = 0;
      wifi = false;
      tv = false;
      washer = false;
      refrigirator = false;
      smokeDetector = false;
      garage = false;
      pool = false;
      balcony = false;
      garden = false;
      _propertyType = null;
      _category = null;
      postsPosts = List.from(originalPosts);
    });
  }
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Explore more places',
              style: TextStyle(fontFamily: "myfont", color: Colors.black),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                CupertinoIcons.arrow_left,
                color: textColor,
              ),
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                        postsPosts.clear();
                        postsPosts.addAll(originalPosts);
                        if (searchQuery.isNotEmpty) {
                          postsPosts = postsPosts
                              .where((post) =>
                                  post.location
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()) ||
                                  post.description
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()))
                              .toList();
                        }
                        if (_currentPriceRange.start > 0 ||
                            _currentPriceRange.end < 5000) {
                          postsPosts = postsPosts.where((post) {
                            final postPrice = double.tryParse(
                                post.price.replaceAll(RegExp(r'[^\d.]'), ''));
                            return postPrice != null &&
                                postPrice >= _currentPriceRange.start &&
                                postPrice <= _currentPriceRange.end;
                          }).toList();
                        }
                        if (_currentMinBedrooms > 0) {
                          postsPosts = postsPosts
                              .where((post) =>
                                  num.parse(post.bedroom) >=
                                  _currentMinBedrooms)
                              .toList();
                        }
                        if (_currentMinBathrooms > 0) {
                          postsPosts = postsPosts
                              .where((post) =>
                                  num.parse(post.bathroom) >=
                                  _currentMinBathrooms)
                              .toList();
                        }
                        if (_propertyType != null && _propertyType != 'Any') {
                          postsPosts = postsPosts
                              .where(
                                  (post) => post.propertyType == _propertyType)
                              .toList();
                        }
                        if (_category != null && _category != 'Any') {
                          postsPosts = postsPosts
                              .where((post) => post.category == _category)
                              .toList();
                        }
                        if (wifi) {
                          postsPosts =
                              postsPosts.where((post) => post.wifi).toList();
                        }
                        if (tv) {
                          postsPosts =
                              postsPosts.where((post) => post.tv).toList();
                        }
                        if (washer) {
                          postsPosts =
                              postsPosts.where((post) => post.washer).toList();
                        }
                        if (refrigirator) {
                          postsPosts = postsPosts
                              .where((post) => post.refrigirator)
                              .toList();
                        }
                        if (smokeDetector) {
                          postsPosts = postsPosts
                              .where((post) => post.smokeDetector)
                              .toList();
                        }
                        if (garage) {
                          postsPosts =
                              postsPosts.where((post) => post.garage).toList();
                        }
                        if (pool) {
                          postsPosts =
                              postsPosts.where((post) => post.pool).toList();
                        }
                        if (balcony) {
                          postsPosts =
                              postsPosts.where((post) => post.balcony).toList();
                        }
                        if (garden) {
                          postsPosts =
                              postsPosts.where((post) => post.garden).toList();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: textColor, fontSize: 16),
                      labelText: 'Where to?',
                      hintText: 'Where to?',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      child: ListTile(
                        title: Center(
                            child: const Text(
                          'Price Range',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        subtitle: RangeSlider(
                          values: _currentPriceRange,
                          min: 0,
                          max: 5000,
                          divisions: 100,
                          labels: RangeLabels(
                            '\$${_currentPriceRange.start.round()}',
                            '\$${_currentPriceRange.end.round()}',
                          ),
                          onChanged: (RangeValues values) {
                            // setState(() {
                            //   _currentPriceRange = values;
                            //   postsPosts = filterPosts();
                            // });
                            setState(() {
                              _currentPriceRange = values;
                              postsPosts.clear();
                              postsPosts.addAll(originalPosts);
                              if (searchQuery.isNotEmpty) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        post.location.toLowerCase().contains(
                                            searchQuery.toLowerCase()) ||
                                        post.description.toLowerCase().contains(
                                            searchQuery.toLowerCase()))
                                    .toList();
                              }
                              if (_currentPriceRange.start > 0 ||
                                  _currentPriceRange.end < 5000) {
                                postsPosts = postsPosts.where((post) {
                                  final postPrice = double.tryParse(post.price
                                      .replaceAll(RegExp(r'[^\d.]'), ''));
                                  return postPrice != null &&
                                      postPrice >= _currentPriceRange.start &&
                                      postPrice <= _currentPriceRange.end;
                                }).toList();
                              }
                              if (_currentMinBedrooms > 0) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        num.parse(post.bedroom) >=
                                        _currentMinBedrooms)
                                    .toList();
                              }
                              if (_currentMinBathrooms > 0) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        num.parse(post.bathroom) >=
                                        _currentMinBathrooms)
                                    .toList();
                              }
                              if (_category != null && _category != 'Any') {
                                postsPosts = postsPosts
                                    .where((post) => post.category == _category)
                                    .toList();
                              }
                              if (_propertyType != null &&
                                  _propertyType != 'Any') {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        post.propertyType == _propertyType)
                                    .toList();
                              }
                              if (wifi) {
                                postsPosts = postsPosts
                                    .where((post) => post.wifi)
                                    .toList();
                              }
                              if (tv) {
                                postsPosts = postsPosts
                                    .where((post) => post.tv)
                                    .toList();
                              }
                              if (washer) {
                                postsPosts = postsPosts
                                    .where((post) => post.washer)
                                    .toList();
                              }
                              if (refrigirator) {
                                postsPosts = postsPosts
                                    .where((post) => post.refrigirator)
                                    .toList();
                              }
                              if (smokeDetector) {
                                postsPosts = postsPosts
                                    .where((post) => post.smokeDetector)
                                    .toList();
                              }
                              if (garage) {
                                postsPosts = postsPosts
                                    .where((post) => post.garage)
                                    .toList();
                              }
                              if (pool) {
                                postsPosts = postsPosts
                                    .where((post) => post.pool)
                                    .toList();
                              }
                              if (balcony) {
                                postsPosts = postsPosts
                                    .where((post) => post.balcony)
                                    .toList();
                              }
                              if (garden) {
                                postsPosts = postsPosts
                                    .where((post) => post.garden)
                                    .toList();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      child: ListTile(
                        title: Center(
                            child: const Text(
                          'Bedrooms',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        subtitle: Slider(
                          value: _currentMinBedrooms,
                          min: 0,
                          max: 10,
                          divisions: 10,
                          label: _currentMinBedrooms.round().toString(),
                          onChanged: (double value) {
                            // setState(() {
                            //   _currentMinBedrooms = value;
                            //   postsPosts = filterPosts();
                            // });
                            setState(() {
                              _currentMinBedrooms = value;
                              postsPosts.clear();
                              postsPosts.addAll(originalPosts);
                              if (searchQuery.isNotEmpty) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        post.location.toLowerCase().contains(
                                            searchQuery.toLowerCase()) ||
                                        post.description.toLowerCase().contains(
                                            searchQuery.toLowerCase()))
                                    .toList();
                              }
                              if (_currentPriceRange.start > 0 ||
                                  _currentPriceRange.end < 5000) {
                                postsPosts = postsPosts.where((post) {
                                  final postPrice = double.tryParse(post.price
                                      .replaceAll(RegExp(r'[^\d.]'), ''));
                                  return postPrice != null &&
                                      postPrice >= _currentPriceRange.start &&
                                      postPrice <= _currentPriceRange.end;
                                }).toList();
                              }
                              if (_currentMinBedrooms > 0) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        num.parse(post.bedroom) >=
                                        _currentMinBedrooms)
                                    .toList();
                              }
                              if (_currentMinBathrooms > 0) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        num.parse(post.bathroom) >=
                                        _currentMinBathrooms)
                                    .toList();
                              }
                              if (_propertyType != null &&
                                  _propertyType != 'Any') {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        post.propertyType == _propertyType)
                                    .toList();
                              }
                              if (_category != null && _category != 'Any') {
                                postsPosts = postsPosts
                                    .where((post) => post.category == _category)
                                    .toList();
                              }
                              if (wifi) {
                                postsPosts = postsPosts
                                    .where((post) => post.wifi)
                                    .toList();
                              }
                              if (tv) {
                                postsPosts = postsPosts
                                    .where((post) => post.tv)
                                    .toList();
                              }
                              if (washer) {
                                postsPosts = postsPosts
                                    .where((post) => post.washer)
                                    .toList();
                              }
                              if (refrigirator) {
                                postsPosts = postsPosts
                                    .where((post) => post.refrigirator)
                                    .toList();
                              }
                              if (smokeDetector) {
                                postsPosts = postsPosts
                                    .where((post) => post.smokeDetector)
                                    .toList();
                              }
                              if (garage) {
                                postsPosts = postsPosts
                                    .where((post) => post.garage)
                                    .toList();
                              }
                              if (pool) {
                                postsPosts = postsPosts
                                    .where((post) => post.pool)
                                    .toList();
                              }
                              if (balcony) {
                                postsPosts = postsPosts
                                    .where((post) => post.balcony)
                                    .toList();
                              }
                              if (garden) {
                                postsPosts = postsPosts
                                    .where((post) => post.garden)
                                    .toList();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      child: ListTile(
                        title: Center(
                            child: const Text(
                          'Bathrooms',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        subtitle: Slider(
                          value: _currentMinBathrooms,
                          min: 0,
                          max: 10,
                          divisions: 10,
                          label: _currentMinBathrooms.round().toString(),
                          onChanged: (double value) {
                            // setState(() {
                            //   _currentMinBathrooms = value;
                            //   postsPosts = filterPosts();
                            // });
                            setState(() {
                              _currentMinBathrooms = value;
                              postsPosts.clear();
                              postsPosts.addAll(originalPosts);
                              if (searchQuery.isNotEmpty) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        post.location.toLowerCase().contains(
                                            searchQuery.toLowerCase()) ||
                                        post.description.toLowerCase().contains(
                                            searchQuery.toLowerCase()))
                                    .toList();
                              }
                              if (_currentPriceRange.start > 0 ||
                                  _currentPriceRange.end < 5000) {
                                postsPosts = postsPosts.where((post) {
                                  final postPrice = double.tryParse(post.price
                                      .replaceAll(RegExp(r'[^\d.]'), ''));
                                  return postPrice != null &&
                                      postPrice >= _currentPriceRange.start &&
                                      postPrice <= _currentPriceRange.end;
                                }).toList();
                              }
                              if (_currentMinBedrooms > 0) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        num.parse(post.bedroom) >=
                                        _currentMinBedrooms)
                                    .toList();
                              }
                              if (_currentMinBathrooms > 0) {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        num.parse(post.bathroom) >=
                                        _currentMinBathrooms)
                                    .toList();
                              }
                              if (_category != null && _category != 'Any') {
                                postsPosts = postsPosts
                                    .where((post) => post.category == _category)
                                    .toList();
                              }
                              if (_propertyType != null &&
                                  _propertyType != 'Any') {
                                postsPosts = postsPosts
                                    .where((post) =>
                                        post.propertyType == _propertyType)
                                    .toList();
                              }
                              if (wifi) {
                                postsPosts = postsPosts
                                    .where((post) => post.wifi)
                                    .toList();
                              }
                              if (tv) {
                                postsPosts = postsPosts
                                    .where((post) => post.tv)
                                    .toList();
                              }
                              if (washer) {
                                postsPosts = postsPosts
                                    .where((post) => post.washer)
                                    .toList();
                              }
                              if (refrigirator) {
                                postsPosts = postsPosts
                                    .where((post) => post.refrigirator)
                                    .toList();
                              }
                              if (smokeDetector) {
                                postsPosts = postsPosts
                                    .where((post) => post.smokeDetector)
                                    .toList();
                              }
                              if (garage) {
                                postsPosts = postsPosts
                                    .where((post) => post.garage)
                                    .toList();
                              }
                              if (pool) {
                                postsPosts = postsPosts
                                    .where((post) => post.pool)
                                    .toList();
                              }
                              if (balcony) {
                                postsPosts = postsPosts
                                    .where((post) => post.balcony)
                                    .toList();
                              }
                              if (garden) {
                                postsPosts = postsPosts
                                    .where((post) => post.garden)
                                    .toList();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          child: ListTile(
                            title: Center(
                                child: const Text(
                              'Property Type',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            trailing: DropdownButton<String>(
                              value: _propertyType,
                              items: [
                                DropdownMenuItem(
                                  child: Text('Any'),
                                  value: 'Any',
                                ),
                                DropdownMenuItem(
                                  child: Text('Apartment'),
                                  value: 'Apartment',
                                ),
                                DropdownMenuItem(
                                  child: Text('Villa'),
                                  value: 'Villa',
                                ),
                                DropdownMenuItem(
                                  child: Text('Cabin'),
                                  value: 'Cabin',
                                ),
                                DropdownMenuItem(
                                  child: Text('Townhouse'),
                                  value: 'Townhouse',
                                ),
                                DropdownMenuItem(
                                  child: Text('House'),
                                  value: 'House',
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _propertyType = value;
                                  postsPosts.clear();
                                  postsPosts.addAll(originalPosts);
                                  if (searchQuery.isNotEmpty) {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            post.location
                                                .toLowerCase()
                                                .contains(searchQuery) ||
                                            post.description
                                                .toLowerCase()
                                                .contains(searchQuery))
                                        .toList();
                                  }
                                  if (_currentPriceRange.start > 0 ||
                                      _currentPriceRange.end < 5000) {
                                    postsPosts = postsPosts.where((post) {
                                      final postPrice = double.tryParse(post
                                          .price
                                          .replaceAll(RegExp(r'[^\d.]'), ''));
                                      return postPrice != null &&
                                          postPrice >=
                                              _currentPriceRange.start &&
                                          postPrice <= _currentPriceRange.end;
                                    }).toList();
                                  }
                                  if (_currentMinBedrooms > 0) {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            num.parse(post.bedroom) >=
                                            _currentMinBedrooms)
                                        .toList();
                                  }
                                  if (_currentMinBathrooms > 0) {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            num.parse(post.bathroom) >=
                                            _currentMinBathrooms)
                                        .toList();
                                  }
                                  if (value != 'Any') {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            post.propertyType == value)
                                        .toList();
                                  }
                                  if (_category != null && _category != 'Any') {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            post.category == _category)
                                        .toList();
                                  }
                                  if (wifi) {
                                    postsPosts = postsPosts
                                        .where((post) => post.wifi)
                                        .toList();
                                  }
                                  if (tv) {
                                    postsPosts = postsPosts
                                        .where((post) => post.tv)
                                        .toList();
                                  }
                                  if (washer) {
                                    postsPosts = postsPosts
                                        .where((post) => post.washer)
                                        .toList();
                                  }
                                  if (refrigirator) {
                                    postsPosts = postsPosts
                                        .where((post) => post.refrigirator)
                                        .toList();
                                  }
                                  if (smokeDetector) {
                                    postsPosts = postsPosts
                                        .where((post) => post.smokeDetector)
                                        .toList();
                                  }
                                  if (garage) {
                                    postsPosts = postsPosts
                                        .where((post) => post.garage)
                                        .toList();
                                  }
                                  if (pool) {
                                    postsPosts = postsPosts
                                        .where((post) => post.pool)
                                        .toList();
                                  }
                                  if (balcony) {
                                    postsPosts = postsPosts
                                        .where((post) => post.balcony)
                                        .toList();
                                  }
                                  if (garden) {
                                    postsPosts = postsPosts
                                        .where((post) => post.garden)
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          child: ListTile(
                            title: Center(
                                child: const Text(
                              'Category',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            trailing: DropdownButton<String>(
                              value: _category,
                              items: [
                                DropdownMenuItem(
                                  child: Text('Any'),
                                  value: 'Any',
                                ),
                                DropdownMenuItem(
                                  child: Text('Couple'),
                                  value: 'Couple',
                                ),
                                DropdownMenuItem(
                                  child: Text('Family'),
                                  value: 'Family',
                                ),
                                DropdownMenuItem(
                                  child: Text('Students'),
                                  value: 'Students',
                                ),
                                DropdownMenuItem(
                                  child: Text('Single'),
                                  value: 'Single',
                                ),
                                DropdownMenuItem(
                                  child: Text('Girls'),
                                  value: 'Girls',
                                ),
                                DropdownMenuItem(
                                  child: Text('Boys'),
                                  value: 'Boys',
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _category = value;
                                  postsPosts.clear();
                                  postsPosts.addAll(originalPosts);
                                  if (searchQuery.isNotEmpty) {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            post.location
                                                .toLowerCase()
                                                .contains(searchQuery) ||
                                            post.description
                                                .toLowerCase()
                                                .contains(searchQuery))
                                        .toList();
                                  }
                                  if (_currentPriceRange.start > 0 ||
                                      _currentPriceRange.end < 5000) {
                                    postsPosts = postsPosts.where((post) {
                                      final postPrice = double.tryParse(post
                                          .price
                                          .replaceAll(RegExp(r'[^\d.]'), ''));
                                      return postPrice != null &&
                                          postPrice >=
                                              _currentPriceRange.start &&
                                          postPrice <= _currentPriceRange.end;
                                    }).toList();
                                  }
                                  if (_currentMinBedrooms > 0) {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            num.parse(post.bedroom) >=
                                            _currentMinBedrooms)
                                        .toList();
                                  }
                                  if (_currentMinBathrooms > 0) {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            num.parse(post.bathroom) >=
                                            _currentMinBathrooms)
                                        .toList();
                                  }
                                  if (_propertyType != null &&
                                      _propertyType != 'Any') {
                                    postsPosts = postsPosts
                                        .where((post) =>
                                            post.propertyType == _propertyType)
                                        .toList();
                                  }
                                  if (value != 'Any') {
                                    postsPosts = postsPosts
                                        .where((post) => post.category == value)
                                        .toList();
                                  }
                                  if (wifi) {
                                    postsPosts = postsPosts
                                        .where((post) => post.wifi)
                                        .toList();
                                  }
                                  if (tv) {
                                    postsPosts = postsPosts
                                        .where((post) => post.tv)
                                        .toList();
                                  }
                                  if (washer) {
                                    postsPosts = postsPosts
                                        .where((post) => post.washer)
                                        .toList();
                                  }
                                  if (refrigirator) {
                                    postsPosts = postsPosts
                                        .where((post) => post.refrigirator)
                                        .toList();
                                  }
                                  if (smokeDetector) {
                                    postsPosts = postsPosts
                                        .where((post) => post.smokeDetector)
                                        .toList();
                                  }
                                  if (garage) {
                                    postsPosts = postsPosts
                                        .where((post) => post.garage)
                                        .toList();
                                  }
                                  if (pool) {
                                    postsPosts = postsPosts
                                        .where((post) => post.pool)
                                        .toList();
                                  }
                                  if (balcony) {
                                    postsPosts = postsPosts
                                        .where((post) => post.balcony)
                                        .toList();
                                  }
                                  if (garden) {
                                    postsPosts = postsPosts
                                        .where((post) => post.garden)
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showAmenities)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                        child: ListTile(
                          title: Center(
                              child: const Text(
                            'Amenities',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          subtitle: GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            children: <Widget>[
                              CheckboxListTile(
                                title: const Text(
                                  'Wifi',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: wifi,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   wifi = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    wifi = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  "TV",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: tv,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   tv = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    tv = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Washer',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: washer,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   washer = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    washer = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Refrigerator',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: refrigirator,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   refrigirator = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    refrigirator = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Smoke Detector',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: smokeDetector,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   smokeDetector = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    smokeDetector = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Garage',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: garage,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   garage = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    garage = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Pool',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: pool,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   pool = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    pool = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Balcony',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: balcony,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   balcony = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    balcony = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  'Garden',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: garden,
                                onChanged: (bool? value) {
                                  // setState(() {
                                  //   garden = value!;
                                  //   postsPosts = filterPosts();
                                  // });
                                  setState(() {
                                    garden = value!;
                                    postsPosts.clear();
                                    postsPosts.addAll(originalPosts);
                                    if (searchQuery.isNotEmpty) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.location
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()) ||
                                              post.description
                                                  .toLowerCase()
                                                  .contains(searchQuery
                                                      .toLowerCase()))
                                          .toList();
                                    }
                                    if (_currentPriceRange.start > 0 ||
                                        _currentPriceRange.end < 5000) {
                                      postsPosts = postsPosts.where((post) {
                                        final postPrice = double.tryParse(post
                                            .price
                                            .replaceAll(RegExp(r'[^\d.]'), ''));
                                        return postPrice != null &&
                                            postPrice >=
                                                _currentPriceRange.start &&
                                            postPrice <= _currentPriceRange.end;
                                      }).toList();
                                    }
                                    if (_currentMinBedrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bedroom) >=
                                              _currentMinBedrooms)
                                          .toList();
                                    }
                                    if (_currentMinBathrooms > 0) {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              num.parse(post.bathroom) >=
                                              _currentMinBathrooms)
                                          .toList();
                                    }
                                    if (_propertyType != null &&
                                        _propertyType != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.propertyType ==
                                              _propertyType)
                                          .toList();
                                    }
                                    if (_category != null &&
                                        _category != 'Any') {
                                      postsPosts = postsPosts
                                          .where((post) =>
                                              post.category == _category)
                                          .toList();
                                    }
                                    if (wifi) {
                                      postsPosts = postsPosts
                                          .where((post) => post.wifi)
                                          .toList();
                                    }
                                    if (tv) {
                                      postsPosts = postsPosts
                                          .where((post) => post.tv)
                                          .toList();
                                    }
                                    if (washer) {
                                      postsPosts = postsPosts
                                          .where((post) => post.washer)
                                          .toList();
                                    }
                                    if (refrigirator) {
                                      postsPosts = postsPosts
                                          .where((post) => post.refrigirator)
                                          .toList();
                                    }
                                    if (smokeDetector) {
                                      postsPosts = postsPosts
                                          .where((post) => post.smokeDetector)
                                          .toList();
                                    }
                                    if (garage) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garage)
                                          .toList();
                                    }
                                    if (pool) {
                                      postsPosts = postsPosts
                                          .where((post) => post.pool)
                                          .toList();
                                    }
                                    if (balcony) {
                                      postsPosts = postsPosts
                                          .where((post) => post.balcony)
                                          .toList();
                                    }
                                    if (garden) {
                                      postsPosts = postsPosts
                                          .where((post) => post.garden)
                                          .toList();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showAmenities = !_showAmenities;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(primaryColor)),
                        child: _showAmenities
                            ? Text('Hide Amenities')
                            : Text('Show Amenities')),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          resetFilters();
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(primaryColor)),
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Posts found",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: backgroundColor),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: postsPosts.length,
                            itemBuilder: (context, index) {
                              final post = postsPosts[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: backgroundColor.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: ListTile(
                                  leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image(
                                        image: NetworkImage(post.imgUrls[0]),
                                        fit: BoxFit.cover,
                                        width: 80,
                                      )),
                                  title: Text(
                                      '${post.location}'),
                                  subtitle:Text("${post.price} dt per${post.monthNight}"),
                                  trailing: Text(post.propertyType),
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PostDetails(
                                            property: post,
                                            hostUid: post.uid,
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
