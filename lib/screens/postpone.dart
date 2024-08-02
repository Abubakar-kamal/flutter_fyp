// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:drapp/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientListPage3 extends StatefulWidget {
  @override
  _PatientListPage3State createState() => _PatientListPage3State();
}

class _PatientListPage3State extends State<PatientListPage3> {
  List<Patient> patients = [];
  Future<List<Patient>>? futurePatients;
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    // Ensure userID is defined or passed appropriately
    futurePatients = _fetchPatients(userID.toString());
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<List<Patient>> _fetchPatients(String drid) async {
    String url = 'https://a2zdoctor.com/medicas/api/drfet.php?drid=$drid';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          List<dynamic> patientsJson = jsonResponse['data'];
          return patientsJson.map((json) => Patient.fromJson(json)).toList();
        } else {
          throw Exception(
              'Failed to load patients: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
            'Failed to load patients with status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch patients.');
    }
  }

  DateTime? picked;

  Future<void> _selectDate(BuildContext context, Patient patient) async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2025, 7));
    if (picked != null) {
      setState(() {
        // Implement the logic to handle the selected date
        print("Date selected: ${picked.toString()}");
      });
    }
  }

  Future<void> updateAppointmentStatus11(
      int id, String drid, String status, String udate) async {
    final String url =
        'https://a2zdoctor.com/medicas/api/postpone.php'; // Update with your actual URL
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id': id.toString(),
          'drid': drid,
          'status': status,
          'udate': udate,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          Fluttertoast.showToast(
              msg: 'Appointment Rescheduled Successfully to $udate');
          print(
              'Update Successful: ${jsonResponse['status']} on ${jsonResponse['udate']}');
        } else {
          print('Update Failed: ${jsonResponse['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making HTTP call: $e');
    }
  }

  Future<void> updateStatus(int id, String drid, String newStatus) async {
    var url = Uri.parse(
        'https://a2zdoctor.com/medicas/api/drup.php'); // Replace with your actual URL
    var response = await http.post(url, body: {
      'id': id.toString(),
      'drid': drid,
      'status': newStatus,
    });

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        print('Status updated to: ${jsonResponse['status']}');
        Fluttertoast.showToast(msg: '$newStatus');
      } else {
        print('Failed to update status: ${jsonResponse['message']}');
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  Future<void> updateAppointmentStatus(
      int id, String drid, String newStatus, String newDate) async {
    var url = Uri.parse(
        'https://a2zdoctor.com/medicas/api/postpone.php'); // Replace with your actual URL
    var response = await http.post(url, body: {
      'id': id.toString(),
      'drid': drid,
      'status': newStatus,
      'udate': newDate,
    });

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        print(
            'Update successful: ${jsonResponse['status']}, Date: ${jsonResponse['udate']}');

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Appointment updated and removed from the list.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Failed to update appointment: ${jsonResponse['message']}")));
      }
    } else {
      print('Server error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01A7AA),
        title: Text("Postponed",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Patient>>(
        future: futurePatients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            bool hasPendingKits =
                snapshot.data!.any((patient) => patient.status == "Postponed");
            return hasPendingKits
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final patient = snapshot.data![index];
                      if (patient.status == "Postponed") {
                        return Card(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xFF26CBE6), width: 2.0),
                              borderRadius: BorderRadius.circular(4.0)),
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Name: " + patient.pname,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text("Number: " + patient.pnumber),
                                Text("Age: ${patient.duration} years"),
                                Text("Condition: " + patient.specialist),
                                Text("Description: " + patient.gender),
                                SizedBox(height: 10),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        selectedDate == null
                                            ? 'No date chosen!'
                                            : 'Selected Date: ${selectedDate!.toIso8601String()}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await selectDate(context);
                                        },
                                        child: Text('Select Date'),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      child: Text("Reschedule"),
                                      onPressed: selectedDate !=
                                              null // Ensure the button is enabled only when a date is selected
                                          ? () {
                                              String formattedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(selectedDate!);
                                              updateAppointmentStatus11(
                                                patient.u_id,
                                                userID.toString(),
                                                "Accepted",
                                                selectedDate.toString(),
                                              );
                                              setState(() {
                                                
                                                snapshot.data!.removeAt(index);
                                              });
                                            }
                                          : null, 
                                    ),
                                    ElevatedButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        updateStatus(patient.u_id,
                                            userID.toString(), "Cancelled");
                                        setState(() {
                                          snapshot.data!.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(); 
                      }
                    },
                  )
                : Center(child: Text("No patients found."));
          } else {
            return Center(child: Text("No patients found."));
          }
        },
      ),
    );
  }
}

class Patient {
  int u_id;
  String drname;
  String drid;
  String specialist;
  String pname;
  String pcondition;
  String pdesc;
  String forwhom;
  String udate;
  String duration;
  String pnumber;
  String gender;
  String status;

  Patient({
    required this.u_id,
    required this.drname,
    required this.drid,
    required this.specialist,
    required this.pname,
    required this.pcondition,
    required this.pdesc,
    required this.forwhom,
    required this.udate,
    required this.duration,
    required this.pnumber,
    required this.gender,
    required this.status,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      u_id: json['id'],
      drname: json['drname'],
      drid: json['drid'],
      specialist: json['specialist'],
      pname: json['pname'],
      pcondition: json['pcondition'],
      pdesc: json['pdesc'],
      forwhom: json['forwhom'],
      udate: json['udate'],
      duration: json['duration'],
      pnumber: json['pnumber'],
      gender: json['gender'],
      status: json['status'],
    );
  }
}
