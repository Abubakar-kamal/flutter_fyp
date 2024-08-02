import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewPatient extends StatefulWidget {
  const ViewPatient({super.key});

  @override
  _ViewPatientState createState() => _ViewPatientState();
}

class _ViewPatientState extends State<ViewPatient> {
  late Future<List<Patient>> futurePatients;

  @override
  void initState() {
    super.initState();
    futurePatients = fetchPatients();
  }

  Future<List<Patient>> fetchPatients() async {
    final response =
        await http.get(Uri.parse('https://a2zdoctor.com/medicas/api/user.php'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        List<dynamic> data = jsonResponse['data'];

        return data
            .map((patientJson) => Patient.fromJson(patientJson))
            .toList();
      } else {
        throw Exception('Failed to load patients: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load patients with status code: ${response.statusCode}');
    }
  }

  Future<void> deletePatient(String id) async {
    final response = await http.post(
      Uri.parse('https://a2zdoctor.com/medicas/api/delete_patient.php'),
      body: {'id': id},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      Fluttertoast.showToast(msg: "Patient Deleted");
      if (!jsonResponse['success']) {
        throw Exception('Failed to delete patient: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to delete patient with status code: ${response.statusCode}');
    }
  }

  void _removePatientFromList(String id) {
    setState(() {
      futurePatients = futurePatients.then(
          (patients) => patients.where((patient) => patient.id != id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01A7AA),
        title: Text("Patients",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Patient>>(
        future: futurePatients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No patients found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final patient = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PatientCard(
                    patient: patient,
                    onDelete: () async {
                      await deletePatient(patient.id);
                      _removePatientFromList(patient.id);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Patient {
  final String id;
  final String userName;
  final String userLastname;
  final String userEmail;
  final String userCnic;
  final String gender;

  Patient({
    required this.id,
    required this.userName,
    required this.userLastname,
    required this.userEmail,
    required this.userCnic,
    required this.gender,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      userLastname: json['userLastname'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userCnic: json['userCnic'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onDelete;

  PatientCard({
    required this.patient,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${patient.userName} ${patient.userLastname}'),
        subtitle: Text(
            'Email: ${patient.userEmail}\nCNIC: ${patient.userCnic}\nGender: ${patient.gender}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
