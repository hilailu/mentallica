import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../auth/auth.dart';
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
  late String _name = 'Лекарство';
  late String _medicationType = 'Pill';
  late String _dose = '0.5';
  late String _measurement = 'мг';
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  late String _timeRelation = 'до еды';
  late List<String> _schedules = ['11:00'];
  late int _reminderOffset = 5;
  late List<String> _daysTaken = ['Вт','Чт','Сб'];
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

  final List<String> measurements = ['мг', 'мл', 'шт.'];
  final List<String> mealTimes = [
    'после еды',
    'до еды',
    'во время',
    'не важно'
  ];
  final List<String> days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

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
          "Лекарства",
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
                  Text('Название', style: _sectionTitleStyle()),
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
                  Text('Тип', style: _sectionTitleStyle()),
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
                  Text('Дозировка', style: _sectionTitleStyle()),
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
              Text('Прием с едой', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 13.0,
                children: mealTimes.map((time) {
                  final words = time.split(' ');
                  return SizedBox(
                    width: 76,
                    child: ChoiceChip(
                      padding: const EdgeInsets.symmetric(horizontal: -4.0, vertical: 4.0),
                      showCheckmark: false,
                      selectedColor: const Color(0xFF8BACA5),
                      label: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              words[0],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (words.length > 1)
                              Text(
                                words[1],
                                style: const TextStyle(fontSize: 14),
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
              Text('Расписание', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              Column(
                children: _schedules
                    .asMap()
                    .entries
                    .map((entry) {
                  int index = entry.key;
                  String time = entry.value;
                  return ListTile(
                    title: Text('Доза ${index + 1}'),
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
                      '- Удалить',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  // Add Dose Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _schedules.add('11:00');
                      });
                    },
                    child: const Text('+ Добавить'),
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
                  Text('Уведомление', style: _sectionTitleStyle()),
                  ListTile(
                    title: const Text('Время напоминания'),
                    trailing: Text('за $_reminderOffset мин'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Установить время напоминания'),
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
                                child: const Text('ОК'),
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
                  Text('Длительность курса', style: _sectionTitleStyle()),
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
                    title: const Text('Начало'),
                    trailing: Text(DateFormat('yyyy-MM-dd', 'ru_RU').format(_startDate)),
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
                    title: const Text('Конец'),
                    trailing: Text(DateFormat('yyyy-MM-dd', 'ru_RU').format(_endDate)),
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
                  label: const Text("Удалить"),
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    final user = Auth().currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Сначала войдите в аккаунт."),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    await MedicationService().saveMedication(
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
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Сохранить"),
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
