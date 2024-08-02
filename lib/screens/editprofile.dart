import 'dart:convert';
import 'package:drapp/auth/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: '$demail');
  final TextEditingController _phoneController =
      TextEditingController(text: '$dnumber');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Loading state

  Future<void> updateUser(int userId, String email, int number) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    var url = Uri.parse('http://your-server.com/update_user.php');
    try {
      var response = await http.post(url, body: {
        'id': userId.toString(),
        'useremail': email,
        'dnumber': number.toString(),
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Handle the response data
        print(data);
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFF01A7AA),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  int num = int.parse(_phoneController.text);
                  // Save the changes
                  updateUser(userID, _emailController.text, num);
                }
              },
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF01A7AA),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
