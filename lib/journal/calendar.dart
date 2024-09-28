import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import 'journal_entry_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List> _events = {};
  DateTime _selectedDay = DateTime.now();
  final DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    FirebaseFirestore.instance.collection('journal_entries').get().then((snapshot) {
      Map<DateTime, List> events = {};
      for (var doc in snapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        events[date] = [doc['mood']];
      }
      setState(() {
        _events = events;
      });
    });
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
            firstDay: DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
            lastDay: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
            focusedDay: _focusedDay,
            eventLoader: (day) => _events[day] ?? [],
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalEntryPage(date: selectedDay),
                ),
              ).then((_) => _loadEvents());
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          ),
          ..._events[_selectedDay]?.map((mood) => ListTile(title: Text(mood))) ?? [],
        ],
      ),
    );
  }
}
