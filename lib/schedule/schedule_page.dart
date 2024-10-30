import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../auth/auth.dart';

class ScheduleForm extends StatefulWidget {
  final List<String> schedules;
  final List<String> lunchBreak;
  final List<String> workingDays;

  const ScheduleForm({super.key,
    required this.schedules,
    required this.lunchBreak,
    required this.workingDays,
  });

  ScheduleForm.empty({super.key})
      : schedules = ['9:00 AM', '5:00 PM'],
        lunchBreak = ['1:00 PM', '2:00 PM'],
        workingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}


class _ScheduleFormState extends State<ScheduleForm> {
  late List<String> _schedules = ['9:00 AM', '5:00 PM'];
  late List<String> _lunchBreak = ['1:00 PM', '2:00 PM'];
  late List<String> _workingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Map<String, dynamic> _selectedContact = {};
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _schedules = widget.schedules;
    _lunchBreak = widget.lunchBreak;
    _workingDays = widget.workingDays;
    _loadContacts();
    _fetchScheduleForDoctor();
  }

  Future<void> _loadContacts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('contacts').get();
    setState(() {
      _contacts = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'],
        'address': doc['address'],
      }).toList();
      _filteredContacts = _contacts;
    });
  }

  Future<void> _fetchScheduleForDoctor() async {
    final doctorId = Auth().userId;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final scheduleDoc = snapshot.docs.first;
      String contactId = scheduleDoc['contactId'];

      DocumentSnapshot<Map<String, dynamic>> contact = await FirebaseFirestore.instance
          .collection('contacts')
          .doc(contactId)
          .get();

      setState(() {
        _schedules = List<String>.from(scheduleDoc['schedules']);
        _lunchBreak = List<String>.from(scheduleDoc['lunchBreak']);
        _workingDays = List<String>.from(scheduleDoc['workingDays']);
        _selectedContact = {
          'id': contactId,
          'name': contact['name'],
          'address': contact['address']
        };
      });
    }
  }

  Future<void> _saveOrUpdateSchedule() async {
    final doctorId = Auth().userId;
    final contactId = _selectedContact['id'];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final scheduleDocId = snapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleDocId)
          .update({
        'schedules': _schedules,
        'lunchBreak': _lunchBreak,
        'workingDays': _workingDays,
        'contactId': contactId,
      });
    } else {
      await FirebaseFirestore.instance.collection('schedules').add({
        'doctorId': doctorId,
        'contactId': contactId,
        'schedules': _schedules,
        'lunchBreak': _lunchBreak,
        'workingDays': _workingDays,
      });
    }
  }

  void _showContactSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Search Contact'),
                onChanged: (value) {
                  setState(() {
                    _filteredContacts = _contacts
                        .where((contact) =>
                    contact['name'].toLowerCase().contains(value.toLowerCase()) ||
                        contact['address'].toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return ListTile(
                      title: Text(contact['name']),
                      subtitle: Text(contact['address']),
                      onTap: () {
                        setState(() {
                          _selectedContact = contact;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Schedule'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
              builder: (context, constraints) {
                double daysChipWidth = (constraints.maxWidth -
                    (days.length - 1) * 8) / days.length;

                return ListView(
                  children: [
                    const Text('Workplace'),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showContactSearch,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Select Location',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedContact['name'] ?? 'Tap to select a contact'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Working Days'),
                    Wrap(
                      spacing: 8.0,
                      children: days.map((day) {
                        bool selected = _workingDays.contains(day);
                        return SizedBox(
                          width: daysChipWidth,
                          child: ChoiceChip(
                            padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
                            showCheckmark: false,
                            selectedColor: const Color(0xFF8BACA5),
                            label: Center(
                              child: Text(
                                day,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            selected: selected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _workingDays.add(day);
                                } else {
                                  _workingDays.remove(day);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Schedule'),
                    Column(
                      children: _schedules
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        String time = entry.value;
                        return ListTile(
                          title: Text(index == 0 ? 'Start' : 'End'),
                          trailing: Text(time),
                          onTap: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _schedules[index] =
                                    selectedTime.format(context);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Lunch Break'),
                    Column(
                      children: _lunchBreak
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        String time = entry.value;
                        return ListTile(
                          title: Text(index == 0 ? 'Start' : 'End'),
                          trailing: Text(time),
                          onTap: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _lunchBreak[index] =
                                    selectedTime.format(context);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _saveOrUpdateSchedule();
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              }),
        ));
  }
}