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
          title: const Text(
            'Лекарства',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF8BACA5),
          bottom: const TabBar(
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Активные'),
              Tab(text: 'Завершенные'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MedicationTab(isCompleted: false),
            MedicationTab(isCompleted: true),
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
              return const Center(
                child: Text(
                  'Лекарств не найдено.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              );
            }

            List<DocumentSnapshot> meds = snapshot.data!.docs;

            return ListView.builder(
              itemCount: meds.length,
              itemBuilder: (context, index) {
                var med = meds[index];
                var medicationName = med['name'];
                var startDate = (med['startDate'] as Timestamp).toDate();
                var endDate = (med['endDate'] as Timestamp).toDate();

                final DateFormat formatter = DateFormat("d MMM yyyy", 'ru_RU');
                String formattedStartDate = formatter.format(startDate);
                String formattedEndDate = formatter.format(endDate);

                final totalDays = endDate.difference(startDate).inDays;
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
                        builder: (context) => MedicationForm(id: med.id),
                      ),
                    ).then((_) {
                      setState(() {});
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
              setState(() {});
            });
          },
          tooltip: 'Добавить лекарство',
          backgroundColor: const Color(0xFF8BACA5),
          child: const Icon(Icons.add, size: 28),
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
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$startDate - $endDate',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: LinearProgressIndicator(
                  value: progressDays / totalDays,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BACA5)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$progressDays из $totalDays дней пройдено',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
