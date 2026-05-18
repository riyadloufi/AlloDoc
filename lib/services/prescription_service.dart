import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';

class PrescriptionService {
  // Génère un PDF à partir des données et de la signature (via SignatureController)
  static Future<Uint8List> generatePrescriptionPdf({
    required String doctorName,
    required String patientName,
    required DateTime date,
    required List<String> medications,
    required String instructions,
    required SignatureController signatureController,
  }) async {
    final Uint8List? signatureBytes = await signatureController.toPngBytes();
    return generatePrescriptionPdfFromBytes(
      doctorName: doctorName,
      patientName: patientName,
      date: date,
      medications: medications,
      instructions: instructions,
      signatureBytes: signatureBytes,
    );
  }

  // Génère un PDF directement depuis les octets de la signature (parfait pour le rendu local)
  static Future<Uint8List> generatePrescriptionPdfFromBytes({
    required String doctorName,
    required String patientName,
    required DateTime date,
    required List<String> medications,
    required String instructions,
    required Uint8List? signatureBytes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ordonnance médicale',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Dr. $doctorName', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Patient : $patientName'),
              pw.Text('Date : ${date.day}/${date.month}/${date.year}'),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Médicaments prescrits :',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...medications.map((med) => pw.Text('• $med')),
              pw.SizedBox(height: 20),
              pw.Text(
                'Instructions :',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(instructions),
              pw.SizedBox(height: 40),
              if (signatureBytes != null && signatureBytes.isNotEmpty) ...[
                pw.Image(
                  pw.MemoryImage(signatureBytes),
                  width: 150,
                  height: 80,
                ),
                pw.SizedBox(height: 5),
              ],
              pw.Text(
                'Signature du médecin',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  // Affiche un aperçu et permet l'impression/partage
  static Future<void> showPrescriptionPreview(
    BuildContext context,
    Uint8List pdfBytes,
  ) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
