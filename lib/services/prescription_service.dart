import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';

class PrescriptionService {
  // Génère un PDF à partir des données et de la signature
  static Future<Uint8List> generatePrescriptionPdf({
    required String doctorName,
    required String patientName,
    required DateTime date,
    required List<String> medications,
    required String instructions,
    required SignatureController signatureController,
  }) async {
    final pdf = pw.Document();

    // Capturer la signature sous forme d'image
    final signatureImage = await signatureController.toImage();
    final signatureBytes = await signatureImage?.toByteData(
      format: ImageByteFormat.png,
    );

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
              if (signatureBytes != null)
                pw.Image(
                  pw.MemoryImage(signatureBytes.buffer.asUint8List()),
                  width: 150,
                  height: 80,
                ),
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
