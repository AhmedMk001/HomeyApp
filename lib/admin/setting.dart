import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/shared/setting_card.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'myFont',
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SettingCard(
                text: 'Terms of services', icon: CupertinoIcons.book_circle),
            const SizedBox(
              height: 10,
            ),
            const SettingCard(
                text: 'Privacy Policy',
                icon: CupertinoIcons.arrow_right_arrow_left_circle),
            const SizedBox(
              height: 10,
            ),
            const SettingCard(
                text: 'Cookies Policy', icon: CupertinoIcons.chart_bar_circle),
            const SizedBox(
              height: 10,
            ),
            const SettingCard(
                text: 'Community Standars',
                icon: CupertinoIcons.check_mark_circled),
            const SizedBox(
              height: 10,
            ),
            const SettingCard(text: 'About', icon: CupertinoIcons.info_circle),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    ));
  }
}
