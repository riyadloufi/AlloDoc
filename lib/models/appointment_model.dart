import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final String timeSlot;
  final String reason;
  final String status;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.timeSlot,
    required this.reason,
    required this.status,
  });

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> map) {
    return AppointmentModel(
      id: id,
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      patientName: map['patientName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientName': patientName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'reason': reason,
      'status': status,
    };
  }
}
