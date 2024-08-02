import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportScreen1 extends StatefulWidget {
  @override
  _ReportScreen1State createState() => _ReportScreen1State();
}

class _ReportScreen1State extends State<ReportScreen1> {
  late Future<Map<String, dynamic>> reportDetails;

  Future<Map<String, dynamic>> fetchReportDetails(int uId) async {
    final response = await http
        .get(Uri.parse('https://a2zdoctor.com/medicas/api/ps.php?p_id=$uId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load report');
    }
  }

  @override
  void initState() {
    super.initState();
    reportDetails = fetchReportDetails(216); // Pass the u_id to fetch details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Product Name: ${data['pname']}"),
                      Text("Prescription: ${data['prescribe']}"),
                      Image.memory(base64Decode(data['r_image']))
                    ],
                  );
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
