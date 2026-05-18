import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/prescription_model.dart';
import 'prescription_service.dart';

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
    required String signatureBase64,
  }) async {
    final String prescriptionId = _firestore
        .collection('prescriptions')
        .doc()
        .id;

    // Upload du PDF avec fallback si Storage n'est pas configuré
    String pdfDownloadUrl = '';
    try {
      final ref = _storage.ref().child('prescriptions/$prescriptionId.pdf');
      await ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      pdfDownloadUrl = await ref.getDownloadURL();
    } catch (e) {
      print('Firebase Storage non disponible, enregistrement Firestore uniquement : $e');
    }

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
      pdfUrl: pdfDownloadUrl,
      signatureBase64: signatureBase64,
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
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => PrescriptionModel.fromMap(doc.id, doc.data()))
                .toList();
            list.sort((a, b) => b.date.compareTo(a.date));
            return list;
          },
        );
  }

  // Récupérer toutes les ordonnances d'un médecin
  Stream<List<PrescriptionModel>> getDoctorPrescriptions(String doctorId) {
    return _firestore
        .collection('prescriptions')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => PrescriptionModel.fromMap(doc.id, doc.data()))
                .toList();
            list.sort((a, b) => b.date.compareTo(a.date));
            return list;
          },
        );
  }

  // Générer et afficher localement le PDF (évite Storage de Firebase et le téléchargement)
  static Future<void> openPrescriptionPdfLocally(PrescriptionModel pres) async {
    try {
      Uint8List? signatureBytes;
      if (pres.signatureBase64.isNotEmpty) {
        signatureBytes = base64Decode(pres.signatureBase64);
      }
      
      final pdfBytes = await PrescriptionService.generatePrescriptionPdfFromBytes(
        doctorName: pres.doctorName,
        patientName: pres.patientName,
        date: pres.date,
        medications: pres.medications,
        instructions: pres.instructions,
        signatureBytes: signatureBytes,
      );
      
      await openPdfFromBytes(pdfBytes);
    } catch (e) {
      print('Erreur lors de la génération locale du PDF : $e');
    }
  }

  // Ouvrir le PDF à partir d'octets bruts (impression native sur tous supports)
  static Future<void> openPdfFromBytes(Uint8List bytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  // Télécharger et ouvrir un PDF depuis Firebase Storage (si existant)
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
