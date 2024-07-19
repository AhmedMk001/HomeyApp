import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const SettingCard({super.key, required this.text, required this.icon,});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(
              width: 15,
            ),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 19,
              color: Colors.black,
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          thickness: 1,
        )
      ],
    );
  }
}