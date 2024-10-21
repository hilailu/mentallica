import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth.dart';

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveMedication({
    String? medicationId,
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
    required Map<String, Map<String, bool>> wasTaken,
  }) async {
    try {
      String? patientId = Auth().userId;

      Map<String, dynamic> medicationData = {
        'patientId': patientId,
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
        'wasTaken': wasTaken,
      };

      if (medicationId != '') {
        await _db.collection('medications').doc(medicationId).update(medicationData);
      } else {
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

  Future<void> updateMedicationTracking({
    required String medicationId,
    required Map<String, Map<String, bool>> wasTaken,
  }) async {
    try {
      await _db.collection('medications').doc(medicationId).update({
        'wasTaken': wasTaken,
      });
    } catch (e) {
      print('Error updating medication tracking: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> fetchMedications(String patientId, bool isCompleted) {
    DateTime now = DateTime.now();

    Query<Map<String, dynamic>> medications = _db.collection('medications')
        .where('patientId', isEqualTo: patientId);

    if (isCompleted) {
      return medications
          .where('endDate', isLessThanOrEqualTo: now)
          .snapshots();
    } else {
      return medications
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .snapshots();
    }
  }
}
