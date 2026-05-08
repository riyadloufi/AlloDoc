import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../services/prescription_service.dart';
import '../../services/prescription_storage_service.dart';

class PrescriptionScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PrescriptionScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  final List<TextEditingController> _medControllers = [TextEditingController()];
  final TextEditingController _instructionsController = TextEditingController();
  String _doctorName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() => _doctorName = 'Dr. ${doc['firstName']} ${doc['lastName']}');
  }

  void _addMedication() =>
      setState(() => _medControllers.add(TextEditingController()));

  void _removeMedication(int idx) {
    _medControllers[idx].dispose();
    setState(() => _medControllers.removeAt(idx));
  }

  Future<void> _generateAndSave() async {
    final medications = _medControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (medications.isEmpty ||
        _instructionsController.text.trim().isEmpty ||
        _signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont requis')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final pdfBytes = await PrescriptionService.generatePrescriptionPdf(
      doctorName: _doctorName,
      patientName: widget.patientName,
      date: DateTime.now(),
      medications: medications,
      instructions: _instructionsController.text.trim(),
      signatureController: _signatureController,
    );
    await PrescriptionStorageService().savePrescription(
      doctorId: FirebaseAuth.instance.currentUser!.uid,
      doctorName: _doctorName,
      patientId: widget.patientId,
      patientName: widget.patientName,
      medications: medications,
      instructions: _instructionsController.text.trim(),
      signatureUrl: '',
      pdfBytes: pdfBytes,
    );
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ordonnance sauvegardée et PDF généré'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _signatureController.dispose();
    for (var c in _medControllers) c.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle ordonnance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF1A73E8)),
                title: Text('Patient : ${widget.patientName}'),
                subtitle: Text('Médecin : $_doctorName'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Médicaments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ..._medControllers.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Paracétamol 500mg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeMedication(e.key),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _addMedication,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un médicament'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions / Posologie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Prendre matin et soir...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Signature du médecin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all()),
              child: Signature(
                controller: _signatureController,
              ), // ✅ CORRECTION
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _signatureController.clear(),
                  child: const Text('Effacer'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sauvegarder et générer PDF',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
