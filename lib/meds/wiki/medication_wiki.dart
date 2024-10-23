import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationWiki {
  final String name;
  final String description;
  final List<String> tags;

  MedicationWiki({
    required this.name,
    required this.description,
    required this.tags,
  });

  factory MedicationWiki.fromDocument(DocumentSnapshot doc) {
    return MedicationWiki(
      name: doc['name'],
      description: doc['description'],
      tags: List<String>.from(doc['tags']),
    );
  }
}
