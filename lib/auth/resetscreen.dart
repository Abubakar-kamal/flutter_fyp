import 'dart:convert';
import 'dart:developer';

import 'package:drapp/auth/login.dart';
import 'package:drapp/auth/otp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class PasswordScreen extends StatefulWidget {
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController pass1 = TextEditingController();

  final TextEditingController pass2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  Future<void> updatePassword(
    String email,
    String password,
  ) async {
    final url =
        'https://a2zdoctor.com/medicas/api/forget.php'; // Replace with your server URL

    final response = await http.post(
      Uri.parse(url),
      body: {
        'demail': email,
        'dpassword': password,
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      log('response: ${response.body}');
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        Fluttertoast.showToast(msg: "Password Updated Successfully");
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginScreen()));

        print(responseData['message']);
        // Handle success response
      } else {
        print(responseData['message']);
        // Handle error response
      }
    } else {
      throw Exception('Failed to update password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF01A7AA),
          title: Text('Reset Password'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Stack(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.password,
                            color: const Color(0xFF01A7AA),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "New Pssword",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green.shade900),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        controller: pass1,
                        obscureText: !_passwordVisible,
                        validator: (value) {
                          RegExp regex = RegExp(r'^.{6,}$');
                          if (value!.isEmpty) {
                            return ("Password is required for login");
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Enter Valid Password(Min. 6 Character)");
                          }
                          return null;
                        },

                        onSaved: (value) {
                          pass1.text = value!;
                        },
                        // decoration: InputDecoration(
                        //   hintText: 'Username',
                        //   prefixIcon: Icon(Icons.person),
                        // ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 250.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF01A7AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Stack(
                    children: [
                      TextFormField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          prefixIcon: Icon(
                            Icons.password,
                            color: const Color(0xFF01A7AA),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 53, 187, 62)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        controller: pass2,
                        validator: (value) {
                          if (pass1.text != pass2.text) {
                            return "Password don't match";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          pass2.text = value!;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 250.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF01A7AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01A7AA),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //await login();

                      updatePassword(
                        email.text,
                        pass1.text,
                      );
                    }
                    // Perform actions upon button click
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
