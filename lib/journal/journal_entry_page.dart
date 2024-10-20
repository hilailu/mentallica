import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:mentallica/auth/auth.dart';

class JournalEntryPage extends StatefulWidget {
  final DateTime date;

  const JournalEntryPage({super.key, required this.date});

  @override
  _JournalEntryPageState createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final List<String> _moods = ['Happy', 'Excited', 'Neutral', 'Sad', 'Angry'];
  final List<String> _symptoms = ['Anxiety', 'Irritability', 'Depression', 'Insomnia', 'Dissociation', 'Anger', 'Suicidal thoughts'];
  final List<String> _positives = ['Family', 'Romance', 'Friendship', 'Exercise', 'Relaxation', 'Games', 'Pets', 'Travel'];

  String _selectedMood = 'Happy';
  int _currentMoodIndex = 0;
  Set<String> _selectedSymptoms = {};
  Set<String> _selectedPositives = {};
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    String patientId = Auth().userId;

    if (patientId == '') {
      throw 'No logged-in user';
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('journal_entries')
        .where('date', isEqualTo: widget.date)
        .where('patientId', isEqualTo: patientId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      setState(() {
        _selectedMood = doc['mood'];
        _currentMoodIndex = _moods.indexOf(_selectedMood);
        _selectedSymptoms = Set.from(doc['symptoms']);
        _selectedPositives = Set.from(doc['positives']);
        _descriptionController.text = doc['description'];
      });
    }
  }

  Future<void> _saveEntry() async {
    await FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(widget.date.toIso8601String())
        .set({
      'date': widget.date,
      'mood': _selectedMood,
      'symptoms': _selectedSymptoms.toList(),
      'positives': _selectedPositives.toList(),
      'description': _descriptionController.text,
      'patientId': Auth().userId,
    });

    Navigator.pop(context);
  }

  Future<void> _removeEntry({required DateTime date}) async {
    String id = date.toIso8601String();
    await FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(id).delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat("d MMM ''yy");
    String formattedDate = formatter.format(widget.date);
    return Scaffold(
        appBar: AppBar(title: Text(formattedDate)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  children: [
                    Text('Mood', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 4.0,
                      alignment: WrapAlignment.spaceBetween,
                      children: _moods.map((mood) {
                        return SizedBox(
                          width: 72,
                          height: 70,
                          child: ChoiceChip(
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            showCheckmark: false,
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(height: 6),
                                Image.asset('assets/images/$mood.png', height: 36),
                                Text(mood, style: TextStyle(fontSize: 12),),
                                SizedBox(height: 6),
                              ],
                            ),
                            selected: _selectedMood == mood,
                            selectedColor: const Color(0xFF8BACA5),
                            onSelected: (selected) {
                              setState(() {
                                _selectedMood = mood;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Symptoms', style: Theme.of(context).textTheme.titleMedium),
                    Wrap(
                      spacing: 8.0,
                      children: _symptoms.map((symptom) {
                        bool selected = _selectedSymptoms.contains(symptom);
                        return ChoiceChip(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding if needed
                          showCheckmark: false,
                          selectedColor: const Color(0xFF8BACA5),
                          label: Text(
                            symptom,
                            style: TextStyle(fontSize: 12),
                          ),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Positive moments', style: Theme.of(context).textTheme.titleMedium),
                    Wrap(
                      spacing: 8.0,
                      children: _positives.map((positive) {
                        bool selected = _selectedPositives.contains(positive);
                        return ChoiceChip(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding if needed
                          showCheckmark: false,
                          selectedColor: const Color(0xFF8BACA5),
                          label: Text(
                            positive,
                            style: TextStyle(fontSize: 12),
                          ),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPositives.add(positive);
                              } else {
                                _selectedPositives.remove(positive);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Describe your day', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: 'Write about your day...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () { _removeEntry(date: widget.date); },
                          child: Text('Delete'),
                        ),
                        ElevatedButton(
                          onPressed: _saveEntry,
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
