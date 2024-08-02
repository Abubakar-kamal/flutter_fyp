// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:drapp/auth/login.dart';
import 'package:drapp/screens/pres.dart';
import 'package:flutter/material.dart';

class PatientListPage1 extends StatefulWidget {
  const PatientListPage1({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PatientListPage1State createState() => _PatientListPage1State();
}

class _PatientListPage1State extends State<PatientListPage1> {
  List<Patient> patients = [];
  Future<List<Patient>>? futurePatients;

  @override
  void initState() {
    super.initState();
    // Assuming userID is defined somewhere
    futurePatients = _fetchPatients(userID.toString());
  }

  Future<List<Patient>> _fetchPatients(String drid) async {
  String url = 'https://a2zdoctor.com/medicas/api/drfet.php?drid=$drid';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        List<dynamic> patientsJson = jsonResponse['data'];
        List<Patient> patients = patientsJson.map((json) => Patient.fromJson(json)).toList();

        // Sort the patients alphabetically by their name
        patients.sort((a, b) => a.pname.compareTo(b.pname));

        return patients;
      } else {
        throw Exception('Failed to load patients: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to load patients with status code: ${response.statusCode}');
    }
  } catch (e) {
    print(e);
    throw Exception('Failed to fetch patients.');
  }
}


  DateTime? picked;

  // ignore: unused_element
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
        Fluttertoast.showToast(msg: newStatus);
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
        backgroundColor: const Color(0xFF01A7AA),
        title: const Text("Accepted",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Patient>>(
        future: futurePatients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            bool hasPendingKits =
                snapshot.data!.any((patient) => patient.status == "Accepted");
            return hasPendingKits
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final patient = snapshot.data![index];
                      if (patient.status == "Accepted") {
                        return Card(
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color(0xFF26CBE6), width: 2.0),
                              borderRadius: BorderRadius.circular(4.0)),
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Name: ${patient.pname}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text("Number: ${patient.pnumber}"),
                                Text("Age: ${patient.duration} years"),
                                Text("Condition: ${patient.specialist}"),
                                Text("Description: ${patient.gender}"),
                                const SizedBox(height: 10),
                                Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      child: const Text("Complete"),
                                      onPressed: () {
                                        updateStatus(patient.u_id,
                                            userID.toString(), "Completed");
                                        setState(() {
                                          snapshot.data!.removeAt(index);
                                        });
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        updateStatus(patient.u_id,
                                            userID.toString(), "Cancelled");
                                        setState(() {
                                          snapshot.data!.removeAt(index);
                                        });
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text("Postpone"),
                                      onPressed: () {
                                        updateStatus(patient.u_id,
                                            userID.toString(), "Postponed");
                                        setState(() {
                                          snapshot.data!.removeAt(index);
                                        });
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("View Report"),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    ReportScreen(
                                                        uid: patient.p_id))));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(); // Ensure a widget is always returned
                      }
                    },
                  )
                : const Center(child: Text("No patients found."));
          } else {
            return const Center(child: Text("No patients found."));
          }
        },
      ),
    );
  }
}

class Patient {
  int u_id;
  int p_id;
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
    required this.p_id,
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
      p_id: json['u_id'],
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
