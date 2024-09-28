import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String title;
  final String content;
  final List<String> tags;
  final Timestamp date;

  Article({
    required this.title,
    required this.content,
    required this.tags,
    required this.date,
  });

  factory Article.fromDocument(DocumentSnapshot doc) {
    return Article(
      title: doc['title'],
      content: doc['content'],
      tags: List<String>.from(doc['tags']),
      date: doc['date'],
    );
  }
}
