import 'package:flutter/material.dart';
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
  final List<String> _moods = ['Радость', 'Энтузиазм', 'Спокойствие', 'Смущение', 'Усталость', 'Тревожность', 'Грусть', 'Злость'];
  final List<String> _symptoms = ['Тревога', 'Гнев', 'Уныние', 'Раздражительность', 'Суицидальные мысли', 'Бессонница', 'Диссоциация', 'Головная боль'];
  final List<String> _positives = ['Семья', 'Друзья', 'Любовь', 'Спорт', 'Отдых', 'Хобби', 'Питомцы', 'Путешествия'];

  String _selectedMood = 'Радость';
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
      return;
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
    final DateFormat formatter = DateFormat("d MMM ''yy", 'ru_RU');
    String formattedDate = formatter.format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionContainer(
              context,
              title: 'Настроение',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _moods.map((mood) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0), // Add spacing between chips
                      child: SizedBox(
                        width: 66,
                        child: ChoiceChip(
                          side: BorderSide.none,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: -4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          label: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 4),
                              Image.asset('assets/images/$mood.png', height: 40),
                              const SizedBox(height: 4),
                              Text(
                                mood,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _selectedMood == mood
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(
              context,
              title: 'Симптомы',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.start,
                    children: _symptoms.map((symptom) {
                      final isSelected = _selectedSymptoms.contains(symptom);
                      return ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          symptom,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        selected: isSelected,
                        selectedColor: const Color(0xFF8BACA5),
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
                ),
              ),

            ),
            const SizedBox(height: 20),
            _buildSectionContainer(
              context,
              title: 'Позитивные моменты',
              child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
    child: Wrap(
                spacing: 8.0,
                children: _positives.map((positive) {
                  final isSelected = _selectedPositives.contains(positive);
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(
                      positive,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    selected: isSelected,
                    selectedColor: const Color(0xFF8BACA5),
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
            ),),),
            const SizedBox(height: 20),
            _buildSectionContainer(
              context,
              title: 'Опишите свой день',
              child: TextField(
                controller: _descriptionController,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: 'Расскажите про свой день...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _removeEntry(date: widget.date),
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
                  onPressed: _saveEntry,
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
                  label: const Text("Сохранить"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
