import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AdminPatient extends StatefulWidget {
  const AdminPatient({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPatientState createState() => _AdminPatientState();
}

class _AdminPatientState extends State<AdminPatient> {
  List<Patient> patients = [];
  Future<List<Patient>>? futurePatients;

  @override
  void initState() {
    super.initState();
    // Ensure userID is defined or passed appropriately
    futurePatients = _fetchPatients();
  }

  Future<List<Patient>> _fetchPatients() async {
    String url = 'https://a2zdoctor.com/medicas/api/adminfetch.php';
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
      // ignore: avoid_print
      print(e);
      throw Exception('Failed to fetch patients.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01A7AA),
        title: const Text("All Appointments",
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final patient = snapshot.data![index];

                return Card(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF26CBE6), width: 2.0),
                      borderRadius: BorderRadius.circular(4.0)),
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Name: ${patient.pname}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Number: ${patient.pnumber}"),
                        Text("Age: ${patient.duration} years"),
                        Text("Condition: ${patient.specialist}"),
                        Text("Description: ${patient.gender}"),
                        const SizedBox(height: 10),
                        const Text('Status',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        Text(patient.status),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No patients found."));
          }
        },
      ),
    );
  }
}

class Patient {
  int id;
  // ignore: non_constant_identifier_names
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
    required this.id,
    // ignore: non_constant_identifier_names
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
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      u_id: json['u_id'] is int ? json['u_id'] : int.parse(json['u_id']),
      drname: json['drname'].toString(),
      drid: json['drid'].toString(),
      specialist: json['specialist'].toString(),
      pname: json['pname'].toString(),
      pcondition: json['pcondition'].toString(),
      pdesc: json['pdesc'].toString(),
      forwhom: json['forwhom'].toString(),
      udate: json['udate'].toString(),
      duration: json['duration'].toString(),
      pnumber: json['pnumber'].toString(),
      gender: json['gender'].toString(),
      status: json['status'].toString(),
    );
  }
}
