import 'package:drapp/admin/doctor.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  DoctorCard({
    required this.doctor,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF01A7AA),
      child: Card(
        child: ListTile(
          title: Text(doctor.drName),
          subtitle: Text(
              'Experience: ${doctor.experience}\nPMDC: ${doctor.pmdc}\nType: ${doctor.drType}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
