import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import '../auth/auth.dart';
import 'journal_entry_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime?, List> _events = {};
  List<Map<String, dynamic>> _futureAppointments = [];
  DateTime _selectedDay = DateTime.now();
  final DateTime _focusedDay = DateTime.now();

  final DateTime _firstDay = DateTime(2024, 1, 1);
  final DateTime _lastDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadFutureAppointments();
  }

  Future<void> _loadEvents() async {
    String patientId = Auth().userId;

    if (patientId == '') return;

    FirebaseFirestore.instance
        .collection('journal_entries')
        .where('patientId', isEqualTo: patientId)
        .get()
        .then((snapshot) {
      Map<DateTime?, List> events = {};
      for (var doc in snapshot.docs) {
        DateTime? date = (doc['date'] as Timestamp).toDate();
        events[date] = [doc['mood']];
      }
      setState(() {
        _events = events;
      });
    });
  }

  Future<void> _loadFutureAppointments() async {
    String patientId = Auth().userId;

    if (patientId == '') return;

    FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get()
        .then((snapshot) {
      List<Map<String, dynamic>> appointments = [];

      for (var doc in snapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        String timeSlot = doc['timeSlot'];
        String contactId = doc['contactId'];

        if (date.isAfter(DateTime.now())) {
          FirebaseFirestore.instance
              .collection('contacts')
              .doc(contactId)
              .get()
              .then((contactDoc) {
            if (contactDoc.exists) {
              String contactName = contactDoc['name'];
              appointments.add({
                'date': date,
                'timeSlot': timeSlot,
                'contactName': contactName,
              });

              appointments.sort((a, b) => a['date'].compareTo(b['date']));

              setState(() {
                _futureAppointments = appointments;
              });
            }
          });
        }
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Journal'),
      ),
      body: Column(
        children: [
          TableCalendar(
            rowHeight: 80,
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            eventLoader: (day) => _events[day] ?? [],
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focusedDay) {
              if (selectedDay.isAfter(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Cannot create a note for future days!')),
                );
              } else {
                setState(() {
                  _selectedDay = selectedDay;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalEntryPage(date: selectedDay),
                  ),
                ).then((_) => _loadEvents());
              }
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                DateTime? matchingDate = _events.keys.firstWhere(
                      (date) => isSameDay(date, day),
                  orElse: () => null,
                );

                if (matchingDate != null) {
                  var mood = _events[matchingDate]?.first;

                  if (mood != null) {
                    return Positioned(
                      bottom: 1,
                      child: Image.asset(
                        'assets/images/$mood.png',
                        width: 20,
                        height: 20,
                      ),
                    );
                  }
                }
                return null;
              },
            ),
          ),
          ..._events[_selectedDay]?.map((mood) =>
              ListTile(title: Text(mood))) ?? [],

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Scheduled Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          // Scrollable appointment cards
          Expanded(
            child: _futureAppointments.isNotEmpty
                ? ListView.builder(
              itemCount: _futureAppointments.length,
              itemBuilder: (context, index) {
                final appointment = _futureAppointments[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.all(6.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(appointment['date'])}, ${appointment['timeSlot']}',
                          style: const TextStyle(fontSize: 16,),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment['contactName'],
                          style: const TextStyle(fontSize: 16,),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No upcoming appointments',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}