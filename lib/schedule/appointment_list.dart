import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/auth.dart';


class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Приемы',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF8BACA5),
          bottom: const TabBar(
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Будущие'),
              Tab(text: 'Завершенные'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AppointmentsTab(isCompleted: false),
            AppointmentsTab(isCompleted: true),
          ],
        ),
      ),
    );
  }
}


class AppointmentsTab extends StatefulWidget {
  final bool isCompleted;

  const AppointmentsTab({super.key, required this.isCompleted});

  @override
  _AppointmentsTabState createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  String doctorId = Auth().userId;

  Stream<QuerySnapshot> fetchAppointments(String doctorId, bool isCompleted) {
    final DateTime now = DateTime.now();

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isGreaterThanOrEqualTo: widget.isCompleted ? null : now)
        .where('date', isLessThan: widget.isCompleted ? now : null)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchAppointments(doctorId, widget.isCompleted),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Приемов не найдено.'));
          }

          List<DocumentSnapshot> appointments = snapshot.data!.docs;

          appointments.sort((a, b) {
            DateTime aDate = (a['date'] as Timestamp).toDate();
            DateTime bDate = (b['date'] as Timestamp).toDate();

            if (aDate.isAtSameMomentAs(bDate)) {
              String aTime = a['timeSlot'];
              String bTime = b['timeSlot'];

              DateTime aTimeDate = DateFormat.jm('ru_RU').parse(aTime);
              DateTime bTimeDate = DateFormat.jm('ru_RU').parse(bTime);

              return aTimeDate.compareTo(bTimeDate);
            } else {
              return aDate.compareTo(bDate);
            }
          });

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              var appointmentDate = (appointment['date'] as Timestamp).toDate();
              var timeSlot = appointment['timeSlot'];
              var patientId = appointment['patientId'];

              final DateFormat dateFormatter = DateFormat("d MMM yyyy", 'ru_RU');
              String formattedDate = dateFormatter.format(appointmentDate);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var patientName = userSnapshot.data!['name'];

                  return AppointmentCard(
                    date: formattedDate,
                    time: timeSlot,
                    patientName: patientName,
                    onTap: () {
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String date;
  final String time;
  final String patientName;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.date,
    required this.time,
    required this.patientName,
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
                '$date, $time',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                patientName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
