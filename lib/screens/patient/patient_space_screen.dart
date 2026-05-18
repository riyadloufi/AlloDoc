import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../services/appointment_service.dart';

class PatientSpaceScreen extends StatefulWidget {
  final bool isTab;
  const PatientSpaceScreen({super.key, this.isTab = false});

  @override
  State<PatientSpaceScreen> createState() => _PatientSpaceScreenState();
}

class _PatientSpaceScreenState extends State<PatientSpaceScreen> {
  final String patientId = FirebaseAuth.instance.currentUser!.uid;
  final AppointmentService _service = AppointmentService();
  int _selectedTab = 0; // 0: à venir, 1: passés

  @override
  Widget build(BuildContext context) {
    final bodyContent = Column(
        children: [
          // Styled Premium Tab Selector
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildTab('À venir', 0),
                _buildTab('Passés', 1),
              ],
            ),
          ),

          // Appointment List Stream builder
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _service.getPatientAppointments(patientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final now = DateTime.now();
                final filtered = _selectedTab == 0
                    ? snapshot.data!
                        .where(
                          (a) => a.date.isAfter(
                            now.subtract(const Duration(days: 1)),
                          ),
                        )
                        .toList()
                    : snapshot.data!
                        .where((a) => a.date.isBefore(now))
                        .toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
                    final isConfirmed = app.status == 'confirmed';
                    final isCancelled = app.status == 'cancelled';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  UserModel.cleanDoctorName(app.doctorName),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    fontSize: 16,
                                  ),
                                ),
                                // State Capsule Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isConfirmed
                                        ? const Color(0xFFDCFCE7)
                                        : (isCancelled ? const Color(0xFFFEE2E2) : const Color(0xFFFEF9C3)),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isConfirmed
                                            ? Icons.check_circle
                                            : (isCancelled ? Icons.cancel : Icons.info),
                                        size: 14,
                                        color: isConfirmed
                                            ? Colors.green[700]
                                            : (isCancelled ? Colors.red[700] : Colors.orange[700]),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        app.status == 'confirmed'
                                            ? 'Confirmé'
                                            : (app.status == 'cancelled' ? 'Annulé' : 'En attente'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isConfirmed
                                              ? Colors.green[800]
                                              : (isCancelled ? Colors.red[800] : Colors.orange[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Date and Slot Row
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  '${app.date.day}/${app.date.month}/${app.date.year}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  app.timeSlot,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Medical Reason Row
                            Row(
                              children: [
                                const Icon(Icons.healing, size: 14, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  app.reason,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Notes details (symptoms description)
                            if (app.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FD),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  'Note : ${app.description}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],

                            // Action cancel button row
                            if ((isConfirmed || app.status == 'pending') && app.date.isAfter(DateTime.now())) ...[
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await _service.cancelAppointment(app.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('✅ Rendez-vous annulé'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text(
                                    'Annuler le RDV',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Color(0xFFFECDD3)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
    );

    if (widget.isTab) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Mon Espace',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: bodyContent,
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A73E8) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1A73E8).withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedTab == 0 ? 'Aucun rendez-vous à venir' : 'Aucun rendez-vous passé',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 0
                  ? 'Vos rendez-vous confirmés s\'afficheront ici.'
                  : 'L\'historique de vos rendez-vous s\'affichera ici.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
