import 'package:flutter/material.dart';

class ParticipantTile extends StatelessWidget {
  final String name;
  final String id;
  final bool checkedIn;
  final String checkinTime;

  const ParticipantTile({
    super.key,
    required this.name,
    required this.id,
    required this.checkedIn,
    required this.checkinTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: checkedIn ? Colors.green : Colors.grey,
          child: Icon(
            checkedIn ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('ID: $id\nStatus: ${checkedIn ? 'Checked-in' : 'Not checked-in'}\nTime: $checkinTime'),
        isThreeLine: true,
      ),
    );
  }
}
