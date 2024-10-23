import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentallica/meds/medication_service.dart';
import 'package:intl/intl.dart';

import '../auth/auth.dart';
import 'medication_page.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medications'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MedicationTab(isCompleted: false), // Active medications
            MedicationTab(isCompleted: true),  // Completed medications
          ],
        ),
      ),
    );
  }
}

class MedicationTab extends StatefulWidget {
  final bool isCompleted;

  const MedicationTab({super.key, required this.isCompleted});

  @override
  _MedicationTabState createState() => _MedicationTabState();
  }

  class _MedicationTabState extends State<MedicationTab> {

    int calculateDaysProgress(DateTime startDate, DateTime endDate) {
      final today = DateTime.now();
      final totalDays = endDate
          .difference(startDate)
          .inDays;
      final currentDays = today.isBefore(startDate) ? 0 : today
          .difference(startDate)
          .inDays;
      return currentDays > totalDays ? totalDays : currentDays;
    }

    @override
    Widget build(BuildContext context) {
      String patientId = Auth().userId;

      return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: MedicationService().fetchMedications(patientId, widget.isCompleted),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No medications found.'));
            }

            List<DocumentSnapshot> meds = snapshot.data!.docs;

            return ListView.builder(
              itemCount: meds.length,
              itemBuilder: (context, index) {
                var med = meds[index];
                var medicationName = med['name'];
                var startDate = (med['startDate'] as Timestamp).toDate();
                var endDate = (med['endDate'] as Timestamp).toDate();

                final DateFormat formatter = DateFormat("d MMM ''yy");
                String formattedStartDate = formatter.format(startDate);
                String formattedEndDate = formatter.format(endDate);

                final totalDays = endDate
                    .difference(startDate)
                    .inDays;
                final progressDays = calculateDaysProgress(startDate, endDate);

                return MedicationCard(
                  name: medicationName,
                  startDate: formattedStartDate,
                  endDate: formattedEndDate,
                  progressDays: progressDays,
                  totalDays: totalDays,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicationForm(
                              id: med.id,
                            ),
                      ),
                    ).then((_) {
                      setState(() {
                      });
                    });
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicationForm.empty(),
              ),
            ).then((_) {
              setState(() {
              });
            });
          },
          tooltip: 'Add Medication',
          child: const Icon(Icons.add),
        ),
      );
    }
  }


class MedicationCard extends StatelessWidget {
  final String name;
  final String startDate;
  final String endDate;
  final int progressDays;
  final int totalDays;
  final VoidCallback onTap;

  const MedicationCard({super.key, 
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.progressDays,
    required this.totalDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$startDate - $endDate',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Progress bar to show medication course progress
              LinearProgressIndicator(
                value: progressDays / totalDays, // Shows progress as a fraction
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                '$progressDays out of $totalDays days completed',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
