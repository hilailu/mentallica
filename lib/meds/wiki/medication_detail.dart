import 'package:flutter/material.dart';
import 'medication_wiki.dart';

class MedicationDetailPage extends StatelessWidget {
  final MedicationWiki medication;

  const MedicationDetailPage({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medication.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: medication.tags
                  .map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 16)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              medication.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
