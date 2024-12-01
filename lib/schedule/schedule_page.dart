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
      : schedules = ['9:00', '17:00'],
        lunchBreak = ['13:00', '14:00'],
        workingDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}


class _ScheduleFormState extends State<ScheduleForm> {
  late List<String> _schedules = ['9:00', '17:00'];
  late List<String> _lunchBreak = ['13:00', '14:00'];
  late List<String> _workingDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];
  final List<String> days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

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
                decoration: InputDecoration(labelText: 'Поиск контакта'),
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Расписание',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BACA5)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Место работы', style: _sectionTitleStyle()),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showContactSearch,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Выбрать место',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_selectedContact['name'] ?? 'Нажмите, чтобы выбрать контакт'),
                    ),
                  ),
                ],
              ),
            ),

            // Course Duration Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Рабочие дни', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6.0,
                    children: days.map((day) {
                      bool selected = _workingDays.contains(day);
                      return SizedBox(
                        width: 44,
                        child: ChoiceChip(
                          padding: const EdgeInsets.symmetric(
                              horizontal: -2.0, vertical: 10.0),
                          label: Center(child: Text(
                              day, style: const TextStyle(fontSize: 12))),
                          showCheckmark: false,
                          selected: selected,
                          selectedColor: const Color(0xFF8BACA5),
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
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Рабочие часы', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  Column(
                    children: _schedules
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      String time = entry.value;
                      return ListTile(
                        title: Text(index == 0 ? 'Начало' : 'Конец'),
                        trailing: Text(time),
                        onTap: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _schedules[index] = selectedTime.format(context);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Обеденный перерыв', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  Column(
                    children: _lunchBreak
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      String time = entry.value;
                      return ListTile(
                        title: Text(index == 0 ? 'Начало' : 'Конец'),
                        trailing: Text(time),
                        onTap: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _lunchBreak[index] = selectedTime.format(context);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveOrUpdateSchedule();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BACA5),
              ),
              child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    );
  }

  TextStyle _sectionTitleStyle() {
    return const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
  }
}