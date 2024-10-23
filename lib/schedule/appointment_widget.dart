import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../auth/auth.dart';

class NextAppointmentWidget extends StatefulWidget {
  const NextAppointmentWidget({Key? key}) : super(key: key);

  @override
  _NextAppointmentWidgetState createState() => _NextAppointmentWidgetState();
}

class _NextAppointmentWidgetState extends State<NextAppointmentWidget> {
  String _appointmentTime = '';
  String _patientName = '';
  String _timeMessage = 'No appointments';

  @override
  void initState() {
    super.initState();
    _fetchNextAppointment();
  }

  Future<void> _fetchNextAppointment() async {
    String doctorId = Auth().userId;

    QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: false)
        .orderBy('timeSlot', descending: false)
        .limit(1)
        .get();

    if (appointmentsSnapshot.docs.isNotEmpty) {
      var appointment = appointmentsSnapshot.docs.first.data() as Map<
          String,
          dynamic>;

      DateTime appointmentDate = (appointment['date'] as Timestamp).toDate();
      String timeSlot = appointment['timeSlot'];
      String patientId = appointment['patientId'];

      DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get();
      String patientName = patientSnapshot['name'];

      DateTime today = DateTime.now();
      Duration difference = appointmentDate.difference(today);
      String timeMessage = difference.inDays == 0
          ? 'Today'
          : 'in ${difference.inDays} days';

      setState(() {
        _appointmentTime = timeSlot;
        _patientName = patientName;
        _timeMessage = timeMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 180,
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE29E85).withOpacity(0.2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 8.0),
              child: Text(_timeMessage,
                style: const TextStyle(fontSize: 14,
                    color: Color(0xFFE29E85)),),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _appointmentTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 5),
                PhosphorIcon(
                  PhosphorIcons.clock(),
                  size: 20,
                ),
              ],
            ),
            Text(
              _patientName,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ));
  }
}