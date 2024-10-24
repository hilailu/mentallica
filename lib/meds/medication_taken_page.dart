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
          title: Text(widget.name),
        ),
        body: ListView(
          children: _buildTrackingList(),
        )
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
        trackingItems.add(ListTile(
          title: Text(formattedDate),
          subtitle: Column(
            children: widget.schedules.map((schedule) {
              return CheckboxListTile(
                title: Text(schedule),
                value: updatedWasTaken[formattedDate]?[schedule] ?? false,
                onChanged: (bool? newValue) {
                  setState(() {
                    updatedWasTaken[formattedDate] ??= {};
                    updatedWasTaken[formattedDate]![schedule] = newValue ?? false;
                    _saveTracking();
                  });
                },
              );
            }).toList(),
          ),
        ));
      } else {
        trackingItems.add(ListTile(
          title: Text(formattedDate),
          subtitle: const Text('No meds for this day'),
        ));
      }
    }

    return trackingItems.toList();
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
