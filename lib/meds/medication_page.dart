import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'medication_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MedicationForm extends StatefulWidget {
  final String id;
  final String name;
  final String dose;
  final String type;
  final String measurement;
  final DateTime startDate;
  final DateTime endDate;
  final String timeRelation;
  final int reminderOffset;
  final List<String> daysTaken;
  final List<String> schedules;

  MedicationForm({
    required this.id,
    required this.name,
    required this.dose,
    required this.type,
    required this.measurement,
    required this.startDate,
    required this.endDate,
    required this.timeRelation,
    required this.reminderOffset,
    required this.daysTaken,
    required this.schedules,
  });

  MedicationForm.empty()
      : id = '',
        name = 'New Medication',
        dose = '0.5',
        type = 'Pill',
        measurement = 'mg',
        startDate = DateTime.now(),
        endDate = DateTime.now().add(Duration(days: 14)),
        timeRelation = 'before meals',
        reminderOffset = 5,
        daysTaken = ['Tue','Thu','Sat'],
        schedules = ['12:00'];

  @override
  _MedicationFormState createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  late String _name = 'New Medication';
  late String _medicationType = 'Pill';
  late String _dose = '0.5';
  late String _measurement = 'mg';
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now().add(Duration(days: 14));
  late String _timeRelation = 'before meals';
  late List<String> _schedules = ['12:00'];
  late int _reminderOffset = 5;
  late List<String> _daysTaken = ['Tue','Thu','Sat'];
  late String _medicationId;

  final List<MedicationType> medicationTypes = [
    MedicationType(name: 'Pill', icon: PhosphorIcons.pill()),
    MedicationType(name: 'Drops', icon: PhosphorIcons.eyedropper()),
    MedicationType(name: 'Shot', icon: PhosphorIcons.syringe()),
    MedicationType(name: 'Spray', icon: PhosphorIcons.sprayBottle()),
    MedicationType(name: 'Mixture', icon: PhosphorIcons.testTube()),
    MedicationType(name: 'Other', icon: PhosphorIcons.drop()),
  ];

  final List<String> measurements = ['mg', 'ml', 'pieces'];
  final List<String> mealTimes = [
    'after meals',
    'before meals',
    'with food',
    'nevermind'
  ];
  final List<String> days = ['Mon', 'Tue', 'Wen', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _medicationId = widget.id;
    _name = widget.name;
    _dose = widget.dose;
    _medicationType = widget.type;
    _measurement = widget.measurement;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _timeRelation = widget.timeRelation;
    _schedules = widget.schedules;
    _daysTaken = widget.daysTaken;
    _reminderOffset = widget.reminderOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Medication')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
              builder: (context, constraints) {
                double daysChipWidth = (constraints.maxWidth -
                    (days.length - 1) * 8) / days.length;

                return ListView(
                  children: [
                    Text('Name'),
                    TextFormField(
                      initialValue: _name,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Type'),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 4.0,
                      alignment: WrapAlignment.spaceBetween,
                      children: medicationTypes.map((medication) {
                        return SizedBox(
                          width: 56,
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(medication.icon, size: 24),
                                SizedBox(height: 4),
                              ],
                            ),
                            selected: _medicationType == medication.name,
                            selectedColor: const Color(0xFF8BACA5),
                            onSelected: (selected) {
                              setState(() {
                                _medicationType = medication.name;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Single dose'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _dose,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _dose = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _measurement,
                          onChanged: (newValue) {
                            setState(() {
                              _measurement = newValue!;
                            });
                          },
                          items: measurements.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    SizedBox(height: 20),

                    Text('When to take it'),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 4.0,
                      children: mealTimes.map((time) {
                        return SizedBox(
                          width: 90,
                          child: ChoiceChip(
                            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
                            showCheckmark: false,
                            selectedColor: const Color(0xFF8BACA5),
                            label: Center(
                              child: Text(
                                time,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            selected: _timeRelation == time,
                            onSelected: (selected) {
                              setState(() {
                                _timeRelation = time;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // Schedule selection
                    Text('Schedule'),
                    Column(
                      children: _schedules
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        String time = entry.value;
                        return ListTile(
                          title: Text('Dose ${index + 1}'),
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
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _schedules.add(
                              '12:00');
                        });
                      },
                      child: Text('+ Add Dose'),
                    ),
                    SizedBox(height: 20),
                    Text('Reminder'),
                    ListTile(
                      title: Text('Reminder time'),
                      trailing: Text('in $_reminderOffset min'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Set Reminder Time'),
                              content: TextFormField(
                                initialValue: _reminderOffset.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _reminderOffset = int.parse(value);
                                  });
                                },
                              ),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Course duration'),
                    Wrap(
                      spacing: 8.0,
                      children: days.map((day) {
                        bool selected = _daysTaken.contains(day);
                        return SizedBox(
                          width: daysChipWidth,
                          child: ChoiceChip(
                            padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
                            showCheckmark: false,
                            selectedColor: const Color(0xFF8BACA5),
                            label: Center(
                              child: Text(
                                day,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            selected: selected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _daysTaken.add(day);
                                } else {
                                  _daysTaken.remove(day);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      title: Text('Start'),
                      trailing: Text(
                          DateFormat('yyyy-MM-dd').format(_startDate)),
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _startDate = selectedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text('End'),
                      trailing: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _endDate = selectedDate;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () {
                            MedicationService().deleteMedication(id: _medicationId);
                            Navigator.pop(context);
                          },
                          child: Text('Delete'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            MedicationService().saveMedication(
                              medicationId: _medicationId,
                              name: _name,
                              dose: _dose,
                              measurement: _measurement,
                              type: _medicationType,
                              timeRelation: _timeRelation,
                              schedules: _schedules,
                              reminderOffset: _reminderOffset,
                              daysTaken: _daysTaken,
                              startDate: _startDate,
                              endDate: _endDate,
                            );
                            Navigator.pop(context);
                          },
                          child: Text('Save'),
                        ),
                      ],
                    )
                  ],
                );
              }),
        ));
  }
}

class MedicationType {
  final String name;
  final PhosphorIconData icon;

  MedicationType({required this.name, required this.icon});
}
