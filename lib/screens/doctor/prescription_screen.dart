import 'dart:convert';
import 'dart:typed_data';

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
    penStrokeWidth: 3,
    penColor: const Color(0xFF1E293B),
    exportBackgroundColor: Colors.transparent,
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
    if (mounted) {
      setState(() => _doctorName = 'Dr. ${doc['firstName']} ${doc['lastName']}');
    }
  }

  void _addMedication() =>
      setState(() => _medControllers.add(TextEditingController()));

  void _removeMedication(int idx) {
    if (_medControllers.length > 1) {
      _medControllers[idx].dispose();
      setState(() => _medControllers.removeAt(idx));
    } else {
      _medControllers[0].clear();
    }
  }

  Future<void> _generateAndSave() async {
    final medications = _medControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    
    if (medications.isEmpty) {
      _showErrorSnackBar('Veuillez ajouter au moins un médicament');
      return;
    }
    
    if (_instructionsController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez ajouter des instructions ou posologie');
      return;
    }
    
    if (_signatureController.points.isEmpty) {
      _showErrorSnackBar('La signature du médecin est obligatoire');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pdfBytes = await PrescriptionService.generatePrescriptionPdf(
        doctorName: _doctorName,
        patientName: widget.patientName,
        date: DateTime.now(),
        medications: medications,
        instructions: _instructionsController.text.trim(),
        signatureController: _signatureController,
      );

      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      final String signatureBase64 = signatureBytes != null ? base64Encode(signatureBytes) : '';

      await PrescriptionStorageService().savePrescription(
        doctorId: FirebaseAuth.instance.currentUser!.uid,
        doctorName: _doctorName,
        patientId: widget.patientId,
        patientName: widget.patientName,
        medications: medications,
        instructions: _instructionsController.text.trim(),
        signatureUrl: '',
        pdfBytes: pdfBytes,
        signatureBase64: signatureBase64,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Ordonnance signée, enregistrée et PDF généré avec succès !'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Une erreur est survenue lors de la génération : $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Rédiger une Ordonnance',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF10B981), // Emerald/Green theme for prescriptions
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Banner info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient : ${widget.patientName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Médecin prescripteur : $_doctorName',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Medications Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Médicaments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addMedication,
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                      label: const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Medications fields list
                ..._medControllers.asMap().entries.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              controller: e.value,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                              decoration: InputDecoration(
                                hintText: 'Ex: Paracétamol 500mg (1 boîte)',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.medication_outlined, color: Color(0xFF10B981), size: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                          ),
                          child: IconButton(
                            onPressed: () => _removeMedication(e.key),
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Instructions Section
                const Text(
                  'Instructions / Posologie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _instructionsController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                    decoration: const InputDecoration(
                      hintText: 'Ex: Prendre 1 comprimé matin et soir pendant 5 jours au moment des repas...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Signature Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Signature du médecin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _signatureController.clear(),
                      icon: const Icon(Icons.clear_all, size: 16, color: Color(0xFF64748B)),
                      label: const Text(
                        'Effacer',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF047857)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateAndSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Signer et Enregistrer l\'Ordonnance',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Full screen loading indicator modal overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.55),
              alignment: Alignment.center,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF10B981)),
                      const SizedBox(height: 20),
                      const Text(
                        'Génération en cours...',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Signature et conversion en PDF officiel en cours de traitement sécurisé.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
