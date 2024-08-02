import 'package:drapp/model/doctormodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDoctor extends StatefulWidget {
  const AdminDoctor({super.key});

  @override
  State<AdminDoctor> createState() => _AdminDoctorState();
}

class _AdminDoctorState extends State<AdminDoctor> {
  Future<List<Doctor>>? futureDoctors;
  Future<List<Doctor>> fetchDoctors() async {
    final response = await http
        .get(Uri.parse('https://a2zdoctor.com/medicas/api/drlist.php'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((doctorJson) => Doctor.fromJson(doctorJson)).toList();
      } else {
        throw Exception('Failed to load doctors: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load doctors with status code: ${response.statusCode}');
    }
  }

  Future<void> deleteDoctor(String uId) async {
    final response = await http.post(
      Uri.parse('https://a2zdoctor.com/medicas/api/delete_doctor.php'),
      body: {'u_id': uId},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      Fluttertoast.showToast(msg: "Doctor Deleted");
      if (!jsonResponse['success']) {
        throw Exception('Failed to delete doctor: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to delete doctor with status code: ${response.statusCode}');
    }
  }

  void _removeDoctorFromList(String uId) {
    setState(() {
      futureDoctors = futureDoctors!.then(
          (doctors) => doctors.where((doctor) => doctor.uId != uId).toList());
    });
  }

  Future<void> editDoctor(Doctor doctor) async {
    final response = await http.post(
      Uri.parse('https://a2zdoctor.com/medicas/api/edit_doctor.php'),
      body: {
        'u_id': doctor.uId,
        'drname': doctor.drName,
        'drtype': doctor.drType,
        'pmdc': doctor.pmdc,
        'experience': doctor.experience,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      Fluttertoast.showToast(msg: "Doctor Updated");
      if (!jsonResponse['success']) {
        throw Exception('Failed to edit doctor: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to edit doctor with status code: ${response.statusCode}');
    }
  }

  void _updateDoctorInList(Doctor updatedDoctor) {
    setState(() {
      futureDoctors = futureDoctors!.then((doctors) {
        int index =
            doctors.indexWhere((doctor) => doctor.uId == updatedDoctor.uId);
        if (index != -1) {
          doctors[index] = updatedDoctor;
        }
        return doctors;
      });
    });
  }

  void _showEditDialog(Doctor doctor) {
    TextEditingController nameController =
        TextEditingController(text: doctor.drName);
    TextEditingController typeController =
        TextEditingController(text: doctor.drType);
    TextEditingController pmdcController =
        TextEditingController(text: doctor.pmdc);
    TextEditingController experienceController =
        TextEditingController(text: doctor.experience);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Doctor'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: pmdcController,
                  decoration: const InputDecoration(labelText: 'PMDC Number'),
                ),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Doctor updatedDoctor = Doctor(
                  uId: doctor.uId,
                  drName: nameController.text,
                  drType: typeController.text,
                  pmdc: pmdcController.text,
                  experience: experienceController.text,
                );

                await editDoctor(updatedDoctor);
                _updateDoctorInList(updatedDoctor);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureDoctors = fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01A7AA),
        title: const Text("Doctors",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: futureDoctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doctors found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final doctor = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DoctorCard(
                    doctor: doctor,
                    onDelete: () async {
                      await deleteDoctor(doctor.uId);
                      _removeDoctorFromList(doctor.uId);
                      // ignore: invalid_use_of_protected_member
                      (context as Element).reassemble();
                    },
                    onEdit: () {
                      _showEditDialog(doctor);
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

class Doctor {
  final String uId;
  final String drName;
  final String drType;
  final String pmdc;
  final String experience;

  Doctor({
    required this.uId,
    required this.drName,
    required this.drType,
    required this.pmdc,
    required this.experience,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      uId: json['u_id'] ?? '',
      drName: json['drname'] ?? '',
      drType: json['drtype'] ?? '',
      pmdc: json['pmdc'] ?? '',
      experience: json['experiance'] ?? '',
    );
  }
}
