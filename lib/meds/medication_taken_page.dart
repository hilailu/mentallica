import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'medication_service.dart';

class MedicationTrackingPage extends StatefulWidget {
  final String medicationId;
  final String name;
  final List<String> schedules;
  final List<String> daysTaken;
  final Map<String, Map<String, bool>> wasTaken;
  final DateTime startDate;

  const MedicationTrackingPage({super.key,
    required this.medicationId,
    required this.name,
    required this.schedules,
    required this.daysTaken,
    required this.wasTaken,
    required this.startDate,
  });

  @override
  _MedicationTrackingPageState createState() => _MedicationTrackingPageState();
}

class _MedicationTrackingPageState extends State<MedicationTrackingPage> {
  Map<String, Map<String, bool>> updatedWasTaken = {};

  @override
  void initState() {
    super.initState();
    updatedWasTaken = Map.from(widget.wasTaken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: _buildTrackingList(),
      ),
    );
  }

  List<Widget> _buildTrackingList() {
    List<Widget> trackingItems = [];

    DateTime today = DateTime.now();
    List<DateTime> datesToShow = _generateDates(today);

    for (var date in datesToShow) {
      String formattedDate = DateFormat('EEE, MMM d').format(date);
      String weekDay = DateFormat('EEE').format(date);

      if (widget.daysTaken.contains(weekDay)) {
        trackingItems.add(
          _buildTrackingCard(
            formattedDate: formattedDate,
            schedules: widget.schedules,
          ),
        );
      } else {
        trackingItems.add(
          _buildNoMedsCard(formattedDate),
        );
      }
    }

    return trackingItems;
  }

  Widget _buildTrackingCard({
    required String formattedDate,
    required List<String> schedules,
  }) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: schedules.map((schedule) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    schedule,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  value: updatedWasTaken[formattedDate]?[schedule] ?? false,
                  onChanged: (bool? newValue) {
                    setState(() {
                      updatedWasTaken[formattedDate] ??= {};
                      updatedWasTaken[formattedDate]![schedule] = newValue ?? false;
                      _saveTracking();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMedsCard(String formattedDate) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'No meds for this day',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _generateDates(DateTime start) {
    List<DateTime> dates = [];

    DateTime today = DateTime.now();
    DateTime currentDate = today;

    while (currentDate.isAfter(widget.startDate) || currentDate.isAtSameMomentAs(widget.startDate)) {
      dates.add(currentDate);
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return dates;
  }

  Future<void> _saveTracking() async {
    await MedicationService().updateMedicationTracking(
      medicationId: widget.medicationId,
      wasTaken: updatedWasTaken,
    );
  }
}
