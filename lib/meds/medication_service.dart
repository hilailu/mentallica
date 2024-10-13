import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth.dart';

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save medication for current user
  Future<void> saveMedication({
    String? medicationId, // Optional ID for updating an existing medication
    required String name,
    required String dose,
    required String measurement,
    required String type,
    required String timeRelation,
    required List<String> schedules,
    required int reminderOffset,
    required List<String> daysTaken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get current user ID from Auth class
      String? patientId = Auth().userId;

      if (patientId == null) {
        throw 'No logged-in user';
      }

      Map<String, dynamic> medicationData = {
        'patientId': patientId, // Save current user's ID
        'name': name,
        'dose': dose,
        'measurement': measurement,
        'type': type,
        'timeRelation': timeRelation,
        'schedules': schedules,
        'reminderOffset': reminderOffset,
        'daysTaken': daysTaken,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
      };

      if (medicationId != '') {
        // If medicationId is provided, update the existing document
        await _db.collection('medications').doc(medicationId).update(medicationData);
      } else {
        // If no medicationId, add a new document
        await _db.collection('medications').add(medicationData);
      }
    } catch (e) {
      print('Error saving/updating medication: $e');
    }
  }

  Future<void> deleteMedication({required String id}) async {
    try {
      await _db.collection('medications').doc(id).delete();
    } catch (e) {
      print('Error deleting medication: $e');
    }
  }

  Stream<QuerySnapshot> fetchMedications(String patientId, bool isCompleted) {
    DateTime now = DateTime.now();

    Query<Map<String, dynamic>> medications = _db.collection('medications')
        .where('patientId', isEqualTo: patientId);

    if (isCompleted) {
      // Fetch completed medications (endDate <= now)
      return medications
          .where('endDate', isLessThanOrEqualTo: now)
          .snapshots();
    } else {
      // Fetch ongoing medications (startDate <= now and endDate > now)
      return medications
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .snapshots();
    }
  }
}
