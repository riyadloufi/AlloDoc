import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'patient_file_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Mes Patients',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: Column(
        children: [
          // Elegant Search Bar Container
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
                filled: true,
                fillColor: const Color(0xFFF8F9FD),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Patients list stream builder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: doctorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final Set<String> patientIds = {};
                final Map<String, String> patientNames = {};
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['patientId'] != null) {
                    patientIds.add(data['patientId']);
                    patientNames[data['patientId']] = data['patientName'] ?? 'Inconnu';
                  }
                }

                final patientList = patientIds
                    .map(
                      (id) => {'id': id, 'name': patientNames[id] ?? 'Inconnu'},
                    )
                    .toList();

                final filtered = _searchQuery.isEmpty
                    ? patientList
                    : patientList
                        .where(
                          (p) => p['name']!.toLowerCase().contains(_searchQuery),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final patient = filtered[i];
                    final String firstLetter = patient['name']!.isNotEmpty
                        ? patient['name']![0].toUpperCase()
                        : '?';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      color: Colors.white,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientFileScreen(patientId: patient['id']!),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: ListTile(
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            title: Text(
                              patient['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                              ),
                            ),
                            subtitle: const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Dossier patient actif',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
                Icons.people_outline,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun patient trouvé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les patients s\'ajouteront automatiquement après leur première prise de rendez-vous.',
              style: TextStyle(
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
