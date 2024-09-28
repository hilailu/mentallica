import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final DateTime date;
  final String mood;
  final List<String> symptoms;
  final List<String> positives;
  final String description;
  final String? audioUrl;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.symptoms,
    required this.positives,
    required this.description,
    this.audioUrl,
  });

  factory JournalEntry.fromDocument(DocumentSnapshot doc) {
    return JournalEntry(
      date: (doc['date'] as Timestamp).toDate(),
      mood: doc['mood'],
      symptoms: List<String>.from(doc['symptoms']),
      positives: List<String>.from(doc['positives']),
      description: doc['description'],
      audioUrl: doc['audioUrl'],
    );
  }
}