import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentallica/schedule/appointment_list.dart';
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
  String _timeMessage = 'Приемов нет';

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
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('date', descending: false)
        .get();

    if (appointmentsSnapshot.docs.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime? closestDateTime;
      Map<String, dynamic>? closestAppointment;

      for (var doc in appointmentsSnapshot.docs) {
        var appointment = doc.data() as Map<String, dynamic>;
        DateTime appointmentDate = (appointment['date'] as Timestamp).toDate();
        String timeSlot = appointment['timeSlot'];

        DateTime timeSlotDateTime = DateFormat.jm('ru_RU').parse(timeSlot);
        DateTime fullAppointmentDate = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          timeSlotDateTime.hour,
          timeSlotDateTime.minute,
        );

        if (fullAppointmentDate.isAfter(now) &&
            (closestDateTime == null || fullAppointmentDate.isBefore(closestDateTime))) {
          closestDateTime = fullAppointmentDate;
          closestAppointment = appointment;
        }
      }

      if (closestAppointment != null) {
        String patientId = closestAppointment['patientId'];
        DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(patientId)
            .get();
        String patientName = patientSnapshot['name'];

        String dayInfo;
        if (now.year == closestDateTime!.year && now.month == closestDateTime!.month && now.day == closestDateTime!.day) {
          dayInfo = 'Сегодня';
        } else {
          int daysDifference = closestDateTime!.difference(now).inDays;
          dayInfo = 'через ${daysDifference + 1} ${daysDifference == 0 ? 'день' : daysDifference > 0 && daysDifference < 4 ? 'дня' : 'дней'}';
        }

        setState(() {
          _appointmentTime = closestAppointment?['timeSlot'];
          _patientName = patientName;
          _timeMessage = dayInfo;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const AppointmentsPage()));
    },
    child: Container(
      width: 180,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
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
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Text(
              _timeMessage,
              style: const TextStyle(fontSize: 14, color: Color(0xFFE29E85)),
            ),
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
      ),
    ));
  }
}