import 'package:drapp/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportScreen extends StatefulWidget {
  final int uid;
  ReportScreen({super.key, required this.uid});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _prescriptionController = TextEditingController();

  late Future<Map<String, dynamic>> reportDetails;

  Future<void> updatePrescription() async {
    String url = 'https://a2zdoctor.com/medicas/api/presin.php'; // Change to your actual URL

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'p_id': widget.uid.toString(),
          'prescribe': _prescriptionController.text,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] != null) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Success'),
              content: Text('Prescription updated successfully.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));
                  },
                  child: Text('Okay'),
                ),
              ],
            ),
          );
        } else {
          showErrorDialog(jsonResponse['error'] ?? 'Unknown error');
        }
      } else {
        showErrorDialog('Failed to update prescription due to server error.');
      }
    } catch (e) {
      showErrorDialog('An error occurred: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchReportDetails(int uId) async {
    final response = await http.get(Uri.parse('https://a2zdoctor.com/medicas/api/ps.php?p_id=$uId'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } else {
      throw Exception('Failed to load report');
    }
  }

  void _showPrescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Write Prescription'),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF01A7AA), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _prescriptionController,
              maxLines: 10, // Sets a larger field for more text
              decoration: InputDecoration(
                hintText: "Enter your detailed description here...",
                border: InputBorder.none, // Removes default underline border
              ),
              style: TextStyle(
                fontSize: 16, // Bigger font size for better readability
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () {
                // Implement send functionality
                print("Prescription Sent: ${_prescriptionController.text}");
                updatePrescription(); // Close the dialog after sending
                Navigator.of(context).pop(); // Close the dialog after sending
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    reportDetails = fetchReportDetails(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text('Patient Report',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF01A7AA),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: reportDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  var data = snapshot.data!;
                  var imageBase64 = data['r_image'];
                  if (imageBase64 != null && imageBase64 is String && imageBase64.isNotEmpty) {
                    var imageBytes = base64Decode(imageBase64);
                    return Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.memory(imageBytes), // Display the report image
                            SizedBox(height: 20),
                            ElevatedButton(
                              child: Text('Prescribe'),
                              onPressed: () {
                                _showPrescriptionDialog(context);
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Text("No image available");
                  }
                } else {
                  return Text("No data found");
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
