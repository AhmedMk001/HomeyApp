import 'package:flutter/material.dart';
import 'package:homey_app/screens/login.dart';
import 'package:homey_app/screens/register.dart';
import 'package:homey_app/shared/colors.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              const Text(
                "Welcome to Homey",
                style: TextStyle(fontSize: 30, fontFamily: "myfont"),
              ),
              Image.asset(
                "assets/img/techny-augmented-reality-on-phone-screen.png",
                height: 250,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 100)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 11, horizontal: 90)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(fontSize: 19, color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
