import 'package:drapp/auth/login.dart';
import 'package:drapp/screens/accept.dart';
import 'package:drapp/screens/history.dart';
import 'package:drapp/screens/home.dart';
import 'package:drapp/screens/postpone.dart';
import 'package:drapp/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01A7AA),
        title: const Text('Home',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF01A7AA),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => DoctorProfileScreen())));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.pending,
              ),
              title: Text('Accepted Appointments'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => PatientListPage1())));
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => PatientListPage2())));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Image.asset(
              'asset/2.jpeg', // Path to your image
              fit: BoxFit.cover,
              width: MediaQuery.of(context)
                  .size
                  .width, // Ensures it covers the full width
            ),
          ),
          Expanded(
            flex:
                1, // Takes the remaining half of the screen space for the grid
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 0.8,
              children: <Widget>[
                createLifestyleCard('asset/1.jpeg', 'Pending Appointments', () {
                  print('Lifestyle Sale clicked');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => PatientListPage())));
                }, 'View'),
                createLifestyleCard('asset/4.jpeg', 'Postpone Appointments',
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => PatientListPage3())));
                  print('Summer Deals clicked');
                }, 'Set'),
                createLifestyleCard('asset/3.jpeg', 'Accepted Appointments',
                    () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => PatientListPage1())));
                  print('New Arrivals clicked');
                }, 'View'),
                createLifestyleCard('asset/5.jpeg', 'History', () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => PatientListPage2())));
                  print('Limited Offer clicked');
                }, 'View'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createLifestyleCard(
      String imagePath, String saleText, VoidCallback onPressed, String text) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            width: double.infinity,
            color: Color(0xFF01A7AA).withOpacity(0.45),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
              ),
              onPressed: onPressed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    saleText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
