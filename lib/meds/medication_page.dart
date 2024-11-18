import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'medication_service.dart';
import 'package:intl/intl.dart';

import 'medication_taken_page.dart';

class MedicationForm extends StatefulWidget {
  final String id;

  const MedicationForm({super.key, 
    required this.id,
  });

  MedicationForm.empty({super.key})
      : id = '';

  @override
  _MedicationFormState createState() => _MedicationFormState();
}


class _MedicationFormState extends State<MedicationForm> {
  late String _name = 'New Medication';
  late String _medicationType = 'Pill';
  late String _dose = '0.5';
  late String _measurement = 'mg';
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  late String _timeRelation = 'before meals';
  late List<String> _schedules = ['9:00 AM'];
  late int _reminderOffset = 5;
  late List<String> _daysTaken = ['Tue','Thu','Sat'];
  late String _medicationId = '';
  late Map<String, Map<String, bool>> _wasTaken = {};
  bool _isLoading = true;

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
    'doesn\'t matter'
  ];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _fetchMedicationData();
  }

  Future<void> _fetchMedicationData() async {
    if (widget.id == '') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('medications')
        .doc(widget.id)
        .get();

    setState(() {
      _medicationId = widget.id;
      _name = doc['name'];
      _dose = doc['dose'];
      _medicationType = doc['type'];
      _measurement = doc['measurement'];
      _startDate = (doc['startDate'] as Timestamp).toDate();
      _endDate = (doc['endDate'] as Timestamp).toDate();
      _timeRelation = doc['timeRelation'];
      _schedules = List<String>.from(doc['schedules']);
      _daysTaken = List<String>.from(doc['daysTaken']);
      _reminderOffset = doc['reminderOffset'];

      _wasTaken = (doc['wasTaken'] as Map<String, dynamic>).map((key, value) {
        return MapEntry(
            key,
            (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v as bool))
        );
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Medication",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BACA5),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MedicationTrackingPage(
                        medicationId: _medicationId,
                        name: _name,
                        schedules: List<String>.from(_schedules),
                        daysTaken: _daysTaken,
                        wasTaken: _wasTaken,
                        startDate: _startDate,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Name Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _name,
                    keyboardType: TextInputType.text,
                    decoration: _roundedInputDecoration(),
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Type Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4.0,
                    alignment: WrapAlignment.spaceBetween,
                    children: medicationTypes.map((medication) {
                      return SizedBox(
                        width: 54,
                        child: ChoiceChip(
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 10.0),
                          label: Icon(medication.icon, size: 24),
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
                ],
              ),
            ),

            // Single Dose Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Single dose', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _dose,
                          keyboardType: TextInputType.number,
                          decoration: _roundedInputDecoration(),
                          onChanged: (value) {
                            setState(() {
                              _dose = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
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
                      ),
                    ],
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
              Text('When to take it', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 13.0,
                children: mealTimes.map((time) {
                  final words = time.split(' '); // Split the time into two words
                  return SizedBox(
                    width: 76, // Ensure each chip has the same width
                    child: ChoiceChip(
                      padding: const EdgeInsets.symmetric(horizontal: -4.0, vertical: 4.0),
                      showCheckmark: false,
                      selectedColor: const Color(0xFF8BACA5),
                      label: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
                          crossAxisAlignment: CrossAxisAlignment.center, // Center the text horizontally
                          children: [
                            Text(
                              words[0], // First word on the first row
                              style: const TextStyle(fontSize: 14), // Larger font size for the first word
                              overflow: TextOverflow.ellipsis, // Handles overflow if the text is too long
                            ),
                            if (words.length > 1) // Only show the second word if it exists
                              Text(
                                words[1], // Second word on the second row
                                style: const TextStyle(fontSize: 14), // Slightly smaller font size for the second word
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
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
              )
            ],
          ),
        ),
        // Schedule Section
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
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
                          _schedules[index] = selectedTime.format(context);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delete Dose Button
                  TextButton(
                    onPressed: () {
                      if (_schedules.isNotEmpty) {
                        setState(() {
                          _schedules.removeLast();
                        });
                      }
                    },
                    child: const Text(
                      '- Remove Dose',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  // Add Dose Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _schedules.add('9:00 AM');
                      });
                    },
                    child: const Text('+ Add Dose'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Reminder Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reminder', style: _sectionTitleStyle()),
                  ListTile(
                    title: const Text('Reminder time'),
                    trailing: Text('in $_reminderOffset min'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Set Reminder Time'),
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
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
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
                  Text('Course duration', style: _sectionTitleStyle()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6.0,
                    children: days.map((day) {
                      bool selected = _daysTaken.contains(day);
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
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Start'),
                    trailing: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
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
                    title: const Text('End'),
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
                ],
              ),
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    MedicationService().deleteMedication(id: _medicationId);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Delete"),
                ),

                ElevatedButton.icon(
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
                      wasTaken: _wasTaken,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme
                        .of(context)
                        .primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save"),
                ),
              ],
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

  InputDecoration _roundedInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }
}

class MedicationType {
  final String name;
  final PhosphorIconData icon;

  MedicationType({required this.name, required this.icon});
}
