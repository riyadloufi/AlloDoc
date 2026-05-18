import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/prescription_model.dart';
import '../../models/user_model.dart';
import '../../services/prescription_storage_service.dart';

class PatientPrescriptionsScreen extends StatefulWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  State<PatientPrescriptionsScreen> createState() =>
      _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState
    extends State<PatientPrescriptionsScreen> {
  final String patientId = FirebaseAuth.instance.currentUser!.uid;
  final PrescriptionStorageService _service = PrescriptionStorageService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PrescriptionModel>>(
      stream: _service.getPatientPrescriptions(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_information, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Aucune ordonnance reçue'),
              ],
            ),
          );
        }
        final prescriptions = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prescriptions.length,
          itemBuilder: (context, index) {
            final pres = prescriptions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1A73E8),
                  child: Icon(Icons.description, color: Colors.white),
                ),
                title: Text(UserModel.cleanDoctorName(pres.doctorName)),
                subtitle: Text(
                  '${pres.date.day}/${pres.date.month}/${pres.date.year}',
                ),
                trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
                onTap: () => _showDetails(pres),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetails(PrescriptionModel pres) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Détails de l\'ordonnance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Médecin'),
                    subtitle: Text(UserModel.cleanDoctorName(pres.doctorName)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(
                      '${pres.date.day}/${pres.date.month}/${pres.date.year}',
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Médicaments',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...pres.medications.map(
                    (med) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('• $med'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Instructions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(pres.instructions),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await PrescriptionStorageService.openPrescriptionPdfLocally(pres);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Voir le PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
