import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/auth.dart';
import 'contact.dart';

class ContactDetailsPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailsPage({required this.contact, super.key});

  @override
  _ContactDetailsPageState createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  List<String> _availableSlots = [];
  List<String> _bookedSlots = [];
  DateTime _selectedDate =  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String? _selectedSlot;
  bool _loadingSlots = false;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _fetchDoctorIdAndSchedule();
  }

  Future<void> _fetchDoctorIdAndSchedule() async {
    setState(() {
      _loadingSlots = true;
    });

    QuerySnapshot scheduleQuery = await FirebaseFirestore.instance
        .collection('schedules')
        .where('contactId', isEqualTo: widget.contact.id)
        .get();

    if (scheduleQuery.docs.isNotEmpty) {
      DocumentSnapshot scheduleDoc = scheduleQuery.docs.first;
      Map<String, dynamic> scheduleData = scheduleDoc.data() as Map<
          String,
          dynamic>;

      _doctorId = scheduleData['doctorId'];
      List<String> workingDays = List<String>.from(scheduleData['workingDays']);
      List<String> schedules = List<String>.from(scheduleData['schedules']);
      List<String> lunchBreak = List<String>.from(scheduleData['lunchBreak']);

      String selectedDay = DateFormat('EEE').format(_selectedDate);
      if (workingDays.contains(selectedDay)) {
        _availableSlots = _generateTimeSlots(schedules, lunchBreak);
        await _fetchBookedSlots();
      } else {
        _availableSlots = [];
      }
    }

    setState(() {
      _loadingSlots = false;
    });
  }

  Future<void> _fetchBookedSlots() async {
    if (_doctorId == null) return;

    QuerySnapshot appointmentQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: _doctorId)
        .where('date', isEqualTo: _selectedDate)
        .get();

    _bookedSlots = appointmentQuery.docs
        .map((doc) =>
    (doc.data() as Map<String,
        dynamic>)['timeSlot'] as String)
        .toList();
  }

  List<String> _generateTimeSlots(List<String> schedules,
      List<String> lunchBreak) {
    List<String> slots = [];
    TimeOfDay start = _parseTime(schedules[0]);
    TimeOfDay end = _parseTime(schedules[1]);
    TimeOfDay lunchStart = _parseTime(lunchBreak[0]);
    TimeOfDay lunchEnd = _parseTime(lunchBreak[1]);

    while (start.hour < end.hour ||
        (start.hour == end.hour && start.minute < end.minute)) {
      if ((start.hour < lunchStart.hour || (start.hour == lunchStart.hour &&
          start.minute < lunchStart.minute)) ||
          (start.hour >= lunchEnd.hour && start.minute >= lunchEnd.minute)) {
        slots.add(start.format(context));
      }

      start = TimeOfDay(hour: start.hour + 1, minute: start.minute);
    }

    return slots;
  }

  TimeOfDay _parseTime(String time) {
    final format = DateFormat.jm('ru_RU');
    DateTime dateTime = format.parse(time);
    return TimeOfDay.fromDateTime(dateTime);
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Пожалуйста, выберите время.")));
      return;
    }

    if (_doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Данные врача недоступны.")));
      return;
    }

    String patientId = Auth().userId;
    if (patientId == '') {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Пожалуйста, войдите в профиль перед записью.")));
      return;
    }

    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': _doctorId,
      'patientId': Auth().userId,
      'date': _selectedDate,
      'timeSlot': _selectedSlot,
      'contactId': widget.contact.id,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Запись на прием создана успешно.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Детали контакта',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contact.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.contact.address,
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.contact.location.latitude,
                      widget.contact.location.longitude),
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.contact.name),
                    position: LatLng(widget.contact.location.latitude,
                        widget.contact.location.longitude),
                    infoWindow: InfoWindow(
                      title: widget.contact.name,
                      snippet: widget.contact.address,
                    ),
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Выберите дату', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _fetchDoctorIdAndSchedule();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BACA5),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: const TextStyle(color: Colors.white),),
              ),
            ),
            const SizedBox(height: 16),
            Text('Доступное время', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            if (_loadingSlots)
              const CircularProgressIndicator()
            else if (_availableSlots.isEmpty)
              const Text(
                'Нет доступных слотов',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _availableSlots.map((slot) {
                  bool isBooked = _bookedSlots.contains(slot);
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(
                      slot,
                      style: const TextStyle(color: Colors.black),
                    ),
                    selected: _selectedSlot == slot,
                    onSelected: isBooked
                        ? null
                        : (selected) {
                      setState(() {
                        _selectedSlot = selected ? slot : null;
                      });
                    },
                    selectedColor: const Color(0xFF8BACA5),
                    disabledColor: const Color(0xFFc8cfcd),
                    labelStyle: TextStyle(
                      color: isBooked ? Colors.grey : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSlot == null ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BACA5),
                  disabledBackgroundColor: const Color(0xFFc8cfcd),
                ),
                child: const Text('Записаться на прием', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
