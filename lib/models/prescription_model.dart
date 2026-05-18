import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final DateTime date;
  final List<String> medications;
  final String instructions;
  final String signatureUrl;
  final String pdfUrl;
  final String signatureBase64;

  PrescriptionModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.medications,
    required this.instructions,
    required this.signatureUrl,
    required this.pdfUrl,
    required this.signatureBase64,
  });

  factory PrescriptionModel.fromMap(String id, Map<String, dynamic> map) {
    return PrescriptionModel(
      id: id,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      medications: List<String>.from(map['medications'] ?? []),
      instructions: map['instructions'] ?? '',
      signatureUrl: map['signatureUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      signatureBase64: map['signatureBase64'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'date': Timestamp.fromDate(date),
      'medications': medications,
      'instructions': instructions,
      'signatureUrl': signatureUrl,
      'pdfUrl': pdfUrl,
      'signatureBase64': signatureBase64,
    };
  }
}
