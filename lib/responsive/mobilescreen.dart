import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/admin/pending.dart';
import 'package:homey_app/admin/setting.dart';
import 'package:homey_app/provider/favorite_provider.dart';
import 'package:homey_app/screens/add_post.dart';
import 'package:homey_app/screens/favorite.dart';
import 'package:homey_app/screens/home.dart';
import 'package:homey_app/screens/notification.dart';
import 'package:homey_app/screens/profile.dart';
import 'package:homey_app/shared/colors.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final FavoriteProvider favoriteProvider = FavoriteProvider();
  final PageController _pageController = PageController();
  bool isLoading = true;
  Map<String, dynamic> userData = {};
  int currentPage = 0;


  Future<void> getUserData() async {
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
  }

  @override
  void initState() {
    getUserData();
    super.initState();
    
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CupertinoTabBar(
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            currentPage = index;
          });
        },
        backgroundColor: backgroundColor,
        items: [
          userData['role'] == 'admin'
              ? BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.check_mark_circled,
                    color: currentPage == 0 ? primaryColor : secondaryColor,
                  ),
                  // label: "Confirmed",
                )
              : BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    color: currentPage == 0 ? primaryColor : secondaryColor,
                  ),
                  // label: "Home",
                ),
          userData['role'] == 'admin'
              ? BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.timer,
                    color: currentPage == 1 ? primaryColor : secondaryColor,
                  ),
                  // label: "Pending",
                )
              : BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.heart,
                    color: currentPage == 1 ? primaryColor : secondaryColor,
                  ),
                ),
          userData['role'] == 'admin'
              ? BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings,
                    color: currentPage == 2 ? primaryColor : secondaryColor,
                  ),
                  // label: "Setting",
                )
              : BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.add_circled,
                    color: currentPage == 2 ? primaryColor : secondaryColor,
                  ),
                  // label: "Add",
                ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.bell,
              color: currentPage == 3 ? primaryColor : secondaryColor,
            ),
            // label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.person,
              color: currentPage == 4 ? primaryColor : secondaryColor,
            ),
            // label: "Profile",
          )
        ],
      ),
      body: PageView(
        onPageChanged: (index) {},
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          Home(),
          userData['role'] == 'admin' ? PendingPosts() : FavoriteWidget(),
          userData['role'] == 'admin' ? SettingPage() : AddPost(),
          Notifications(),
          Profile(
            uiddd: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ],
      ),
    );
  }
}
