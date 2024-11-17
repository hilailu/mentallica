import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(article.date.toDate()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: article.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xFF8BACA5),
                  labelStyle: const TextStyle(color: Colors.white),
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                article.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
