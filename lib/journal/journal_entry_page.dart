import 'package:another_audio_recorder/another_audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JournalEntryPage extends StatefulWidget {
  final DateTime date;

  const JournalEntryPage({super.key, required this.date});

  @override
  _JournalEntryPageState createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final List<String> _moods = ['Happy', 'Sad', 'Angry', 'Excited', 'Neutral'];
  final List<String> _symptoms = ['Anxiety', 'Fatigue', 'Headache', 'Insomnia'];
  final List<String> _positives = ['Exercise', 'Family time', 'Hobby', 'Meditation'];

  String _selectedMood = 'Happy';
  int _currentMoodIndex = 0;
  Set<String> _selectedSymptoms = {};
  Set<String> _selectedPositives = {};
  final TextEditingController _descriptionController = TextEditingController();
  AnotherAudioRecorder? _recorder;
  Recording? _recording;
  File? _audioFile;

  @override
  void initState() {
    super.initState();
    _loadEntry();
    _initRecorder();
  }

  Future<void> _loadEntry() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(widget.date.toIso8601String())
        .get();
    if (snapshot.exists) {
      setState(() {
        _selectedMood = snapshot['mood'];
        _currentMoodIndex = _moods.indexOf(_selectedMood);
        _selectedSymptoms = Set.from(snapshot['symptoms']);
        _selectedPositives = Set.from(snapshot['positives']);
        _descriptionController.text = snapshot['description'];
        // Load audio file if exists
      });
    }
  }

  Future<void> _initRecorder() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDir.path}/${widget.date.toIso8601String()}.aac';
    _recorder = AnotherAudioRecorder(filePath, audioFormat: AudioFormat.AAC);
    await _recorder!.initialized;
    setState(() {});
  }

  Future<void> _startRecording() async {
    await _recorder!.start();
    Recording? recording = await _recorder!.current();
    setState(() {
      _recording = recording;
    });
  }

  Future<void> _stopRecording() async {
    Recording? recording = await _recorder!.stop();
    File file = File(recording!.path!);
    setState(() {
      _recording = recording;
      _audioFile = file;
    });
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
      // Save audio file URL if exists
    });

    if (_audioFile != null) {
      // Upload audio file to Firebase Storage and save URL
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('How do you feel today?', style: Theme.of(context).textTheme.headlineSmall),
            CarouselSlider(
              options: CarouselOptions(
                height: 100.0,
                enlargeCenterPage: true,
                autoPlay: false,
                aspectRatio: 2.0,
                initialPage: _currentMoodIndex,
                viewportFraction: 0.3,
                onPageChanged: (index, reason) {
                  setState(() {
                    _selectedMood = _moods[index];
                    _currentMoodIndex = index;
                  });
                },
              ),
              items: _moods.map((mood) {
                return Builder(
                  builder: (BuildContext context) {
                    return Column(
                      children: [
                        Image.asset('assets/images/$mood.png', height: 60),
                        Text(mood),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Symptoms', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              children: _symptoms.map((symptom) {
                return FilterChip(
                  label: Text(symptom),
                  selected: _selectedSymptoms.contains(symptom),
                  onSelected: (bool selected) {
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
            const SizedBox(height: 16),
            Text('Positive Moments', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              children: _positives.map((positive) {
                return FilterChip(
                  label: Text(positive),
                  selected: _selectedPositives.contains(positive),
                  onSelected: (bool selected) {
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
            const SizedBox(height: 16),
            Text('Describe your day', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _recording == null || _recording!.status == RecordingStatus.Stopped
                ? ElevatedButton(
              onPressed: _startRecording,
              child: const Text('Start Recording'),
            )
                : ElevatedButton(
              onPressed: _stopRecording,
              child: const Text('Stop Recording'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
