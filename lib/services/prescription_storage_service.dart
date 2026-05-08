import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../models/prescription_model.dart';

class PrescriptionStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Sauvegarder une ordonnance (métadonnées + PDF)
  Future<void> savePrescription({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required List<String> medications,
    required String instructions,
    required String signatureUrl,
    required Uint8List pdfBytes,
  }) async {
    final String prescriptionId = _firestore
        .collection('prescriptions')
        .doc()
        .id;

    // Upload du PDF
    final ref = _storage.ref().child('prescriptions/$prescriptionId.pdf');
    await ref.putData(pdfBytes);
    final pdfDownloadUrl = await ref.getDownloadURL();

    final prescription = PrescriptionModel(
      id: prescriptionId,
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      patientName: patientName,
      date: DateTime.now(),
      medications: medications,
      instructions: instructions,
      signatureUrl: signatureUrl,
    );

    await _firestore.collection('prescriptions').doc(prescriptionId).set({
      ...prescription.toMap(),
      'pdfUrl': pdfDownloadUrl,
    });
  }

  // Récupérer toutes les ordonnances d'un patient
  Stream<List<PrescriptionModel>> getPatientPrescriptions(String patientId) {
    return _firestore
        .collection('prescriptions')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrescriptionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Récupérer toutes les ordonnances d'un médecin
  Stream<List<PrescriptionModel>> getDoctorPrescriptions(String doctorId) {
    return _firestore
        .collection('prescriptions')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrescriptionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Télécharger et ouvrir un PDF depuis Firebase Storage
  static Future<void> openPdf(String pdfUrl) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final File file = File(
        '$tempPath/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      final response = await http.get(Uri.parse(pdfUrl));
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(file.path);
    } catch (e) {
      print('Erreur ouverture PDF : $e');
    }
  }
}
