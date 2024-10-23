import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../auth/auth.dart';
import 'medication_page.dart';

class NextPillWidget extends StatefulWidget {
  @override
  _NextPillWidgetState createState() => _NextPillWidgetState();
}

class _NextPillWidgetState extends State<NextPillWidget> {
  String _medicationId = '';
  String nextDoseInfo = '';
  String nextDoseTime = '';
  String nextDoseDetails = '';

  @override
  void initState() {
    super.initState();
    _fetchNextMedication();
  }

  Future<void> _fetchNextMedication() async {
    String userId = Auth().userId;
    DateTime now = DateTime.now();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('medications')
        .where('patientId', isEqualTo: userId)
        .where('endDate', isGreaterThan: Timestamp.fromDate(now))
        .get();

    List<Map<String, dynamic>> medications = querySnapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    })
        .toList();

    if (medications.isEmpty) return;

    DateTime? nextDoseDate;
    String? nextTime;
    String? nextName;
    String? nextDose;
    String? nextMeasurement;

    for (var medication in medications) {
      List<String> daysTaken = List<String>.from(medication['daysTaken']);
      List<String> schedules = List<String>.from(medication['schedules']);
      String name = medication['name'];
      String dose = medication['dose'].toString();
      String measurement = medication['measurement'];
      String medicationId = medication['id'];

      DateTime nextDateForMed = _getNextDoseDate(daysTaken, now);

      if (nextDateForMed.isBefore(nextDoseDate ?? DateTime(3000))) {
        String nextScheduleTime = _getNextTime(schedules, now);

        setState(() {
          _medicationId = medicationId;
          nextDoseDate = nextDateForMed;
          nextTime = nextScheduleTime;
          nextName = name;
          nextDose = dose;
          nextMeasurement = measurement;
        });
      }
    }

    if (nextDoseDate != null) {
      String formattedDate = DateFormat('HH:mm').format(nextDoseDate!);
      String dayInfo = nextDoseDate!.difference(now).inDays == 0 ? 'Today' : 'in ${nextDoseDate!.difference(now).inDays} days';

      setState(() {
        nextDoseInfo = dayInfo;
        nextDoseTime = nextTime ?? formattedDate;
        nextDoseDetails = '$nextName, $nextDose $nextMeasurement';
      });
    }
  }

  DateTime _getNextDoseDate(List<String> daysTaken, DateTime now) {
    List<int> daysOfWeek = daysTaken.map((day) {
      switch (day) {
        case 'Mon':
          return DateTime.monday;
        case 'Tue':
          return DateTime.tuesday;
        case 'Wed':
          return DateTime.wednesday;
        case 'Thu':
          return DateTime.thursday;
        case 'Fri':
          return DateTime.friday;
        case 'Sat':
          return DateTime.saturday;
        case 'Sun':
          return DateTime.sunday;
        default:
          return DateTime.monday;
      }
    }).toList();

    for (int i = 0; i < 7; i++) {
      DateTime nextDay = now.add(Duration(days: i));
      if (daysOfWeek.contains(nextDay.weekday)) {
        return nextDay;
      }
    }
    return now;
  }

  String _getNextTime(List<String> schedules, DateTime now) {
    schedules.sort((a, b) => a.compareTo(b));
    for (String time in schedules) {
      DateTime scheduleTime = DateFormat('HH:mm').parse(time);
      if (scheduleTime.isAfter(now)) {
        return time;
      }
    }
    return schedules.first;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationForm(id: _medicationId,),
        ),
      );
    },
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
            nextDoseInfo,
            style: const TextStyle(fontSize: 14, color: Color(0xFFE29E85)),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              nextDoseTime,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 5),
            Icon(Icons.access_time, size: 20),
          ],
        ),
        Text(
          nextDoseDetails,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ));
  }
}
