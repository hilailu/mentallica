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
  String nextDoseInfo = 'Today';
  String nextDoseTime = '12:00';
  String nextDoseDetails = 'Ibuprofen, 2 pills';

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

    List<Map<String, dynamic>> medications = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    if (medications.isEmpty) return;

    DateTime? closestDoseDateTime;
    String? nextName;
    String? nextDose;
    String? nextMeasurement;
    String? nextTime;

    for (var medication in medications) {
      List<String> daysTaken = List<String>.from(medication['daysTaken']);
      List<String> schedules = List<String>.from(medication['schedules']);
      String name = medication['name'];
      String dose = medication['dose'].toString();
      String measurement = medication['measurement'];
      String medicationId = medication['id'];

      DateTime? nextDoseDateTime = _getNextDoseDateTime(daysTaken, schedules, now);

      if (nextDoseDateTime != null &&
          (closestDoseDateTime == null || nextDoseDateTime.isBefore(closestDoseDateTime!))) {
        setState(() {
          _medicationId = medicationId;
          closestDoseDateTime = nextDoseDateTime;
          nextName = name;
          nextDose = dose;
          nextMeasurement = measurement;
          nextTime = DateFormat('h:mm a').format(nextDoseDateTime);
        });
      }
    }

    if (closestDoseDateTime != null) {
      String dayInfo;
      if (now.year == closestDoseDateTime!.year && now.month == closestDoseDateTime!.month && now.day == closestDoseDateTime!.day) {
        dayInfo = 'Today';
      } else {
        int daysDifference = closestDoseDateTime!.difference(now).inDays;
        dayInfo = 'in ${daysDifference + 1} day(s)';
      }

      setState(() {
        nextDoseInfo = dayInfo;
        nextDoseTime = nextTime ?? dayInfo;
        nextDoseDetails = '$nextName, $nextDose $nextMeasurement';
      });
    }
  }

  DateTime? _getNextDoseDateTime(List<String> daysTaken, List<String> schedules, DateTime now) {
    // Convert daysTaken to weekdays
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

    DateTime? closestDateTime;

    // Iterate over the next 7 days to find the nearest dose
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));

      if (daysOfWeek.contains(date.weekday)) {
        for (String schedule in schedules) {
          DateTime scheduleTime = DateFormat('h:mm a').parse(schedule);
          DateTime fullDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            scheduleTime.hour,
            scheduleTime.minute,
          );

          if (fullDateTime.isAfter(now) &&
              (closestDateTime == null || fullDateTime.isBefore(closestDateTime))) {
            closestDateTime = fullDateTime;
          }
        }
      }
    }

    return closestDateTime;
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
