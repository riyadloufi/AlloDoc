import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Créer un RDV
  Future<void> createAppointment(AppointmentModel appointment) async {
    await _db.collection('appointments').add(appointment.toMap());
  }

  // ✅ Récupérer les RDV d'un patient
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => AppointmentModel.fromMap(doc.id, doc.data()))
                .toList();
            list.sort((a, b) => a.date.compareTo(b.date));
            return list;
          },
        );
  }

  // ✅ Récupérer les RDV d'un médecin
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => AppointmentModel.fromMap(doc.id, doc.data()))
                .toList();
            list.sort((a, b) => a.date.compareTo(b.date));
            return list;
          },
        );
  }

  // ✅ Annuler un RDV
  Future<void> cancelAppointment(String appointmentId, {String reason = ''}) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': 'cancelled',
      'cancelReason': reason,
    });
  }

  // ✅ Récupérer les créneaux déjà pris pour un médecin/date
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return snapshot.docs
        .where((doc) {
          final status = doc.data()['status'] ?? 'pending';
          return status != 'cancelled' && status != 'refused';
        })
        .map((doc) => doc.data()['timeSlot'] as String)
        .toList();
  }
}
