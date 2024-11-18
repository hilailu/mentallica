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
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.withOpacity(0.2),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                medication.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: medication.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xFF8BACA5),
                  labelStyle: const TextStyle(color: Colors.white),
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
