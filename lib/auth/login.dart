import 'dart:convert';
import 'dart:developer';

import 'package:drapp/admin/mainpage.dart';
import 'package:drapp/auth/otp.dart';

import 'package:drapp/connect.dart';
import 'package:drapp/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

int userID = 0;
String drname = '';
String drtype = '';
String pmdc = '';
String demail = '';
String dnumber = '';
TextEditingController emailController = TextEditingController();
TextEditingController passController = TextEditingController();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool flag = true;
  bool _isLoading = false; // Loading state

  login() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    var res = await http.post(Uri.parse(Api.login), headers: {
      "Accept": "application/json"
    }, body: {
      "demail": emailController.text,
      "dpassword": passController.text,
    });

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
          await _saveCredentials(emailController.text, passController.text);

          // Navigate to the next page
          if (emailController.text == 'abubakar12@admin.com') {
            Fluttertoast.showToast(
              msg: "Login Successful! As Admin",
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomePage()));
            Fluttertoast.showToast(msg: "Signin Successfully");
          }
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
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process data.
      login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF01A7AA),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'asset/1.png', // Replace with a valid image URL
                    height: 250, // Set an appropriate height for the image
                    fit: BoxFit
                        .cover, // This will cover the space allocated without distortion
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the rounded corner radius here
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Color(0xFF26CBE6),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF26CBE6), width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF26CBE6), width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }

                      String pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passController,
                    obscureText: flag,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the rounded corner radius here
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF26CBE6), width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF26CBE6), width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: Icon(
                        Icons.password,
                        color: Color(0xFF26CBE6),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              flag = !flag;
                            });
                          },
                          icon: Icon(
                            !flag ? Icons.visibility : Icons.visibility_off,
                            color: !flag ? Color(0xFF26CBE6) : Colors.black,
                          )),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) => password = value ?? '',
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) => MyOtpScreen()),
                          ),
                        );
                        // Navigator.push to registration screen or another action
                      },
                      child: Text("Forget Password"),
                    ),
                  ),
                  // SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF01A7AA),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submit,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text('Login'),
                    ),
                  ),
                  // SizedBox(height: 20),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: ((context) => SignUpPage()),
                  //       ),
                  //     );
                  //     // Navigator.push to registration screen or another action
                  //   },
                  //   child: Text("Don't have an account? Sign up"),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
