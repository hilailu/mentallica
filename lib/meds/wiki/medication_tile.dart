import 'package:flutter/material.dart';
import 'medication_wiki.dart';
import 'medication_detail.dart';

class MedicationTile extends StatelessWidget {
  final MedicationWiki medication;

  const MedicationTile({super.key, required this.medication});

  void _navigateToMedicationDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailPage(medication: medication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToMedicationDetail(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                medication.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: medication.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
