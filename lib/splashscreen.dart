import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:drapp/admin/mainpage.dart';
import 'package:drapp/auth/login.dart';
import 'package:drapp/connect.dart';
import 'package:drapp/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  // Add this variable to track if the user is already logged in
  bool isLoggedIn = false;
  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    var res = await http.post(Uri.parse(Api.login),
        headers: {"Accept": "application/json"},
        body: {"demail": email, "dpassword": password});

    try {
      if (res.statusCode == 200) {
        log('response: ${res.body}');
        var data = json.decode(res.body);

        // Check if `u_id` is present and valid
        if (data['u_id'] != null) {
          // Store user ID. Assuming it is sent as an integer from the server.
          userID = data['u_id'];
          drname = data['drname'];
          drtype = data['drtype'];
          pmdc = data['pmdc'];
          demail = data['demail'];
          dnumber = data['dnumber'];

          debugPrint(
              "MY ID == $userID"); // Directly use the integer in a string template
          debugPrint("MY ID == $drname");
          debugPrint("MY ID == $drtype");
          debugPrint("MY ID == $pmdc");
          debugPrint("MY ID == $demail");

          // Save email and password to shared preferences

          // Navigate to the next page
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HomePage()));

          Fluttertoast.showToast(msg: "Signin Successfully");
        } else {
          Fluttertoast.showToast(msg: "Invalid credentials provided.");
        }
      } else {
        Fluttertoast.showToast(
            msg:
                "Error while logging into your account, status code: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      Fluttertoast.showToast(msg: 'Error during login: $e');
    }
  }

  Future<void> _loadAndNavigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email == null || password == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else if (email == 'abubakar12@admin.com') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminScreen()),
      );
      Fluttertoast.showToast(msg: "Signin Successfully as Admin");
    } else {
      login();
    }
  }

  void checkAutoLogin() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    _loadAndNavigate();
  }

  @override
  void initState() {
    super.initState();
    checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 150.0,
                ),
                child: Center(
                  child: Image.asset(
                    'asset/1.png',
                    height: 200,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
