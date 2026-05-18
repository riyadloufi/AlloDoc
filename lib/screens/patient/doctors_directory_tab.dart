import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../widgets/doctor_card.dart';
import 'book_appointment_screen.dart';

class DoctorsDirectoryTab extends StatefulWidget {
  final String firstName;
  const DoctorsDirectoryTab({super.key, required this.firstName});

  @override
  State<DoctorsDirectoryTab> createState() => _DoctorsDirectoryTabState();
}

class _DoctorsDirectoryTabState extends State<DoctorsDirectoryTab> {
  String _searchQuery = '';
  String _selectedSpecialty = 'Tous';
  final List<String> _specialties = [
    'Tous',
    'Généraliste',
    'Pédiatre',
    'Cardiologue',
    'Dentiste',
    'Dermatologue',
    'Ophtalmologue',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Premium Patient Header (Gradient Banner)
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.firstName.isNotEmpty ? '👋 Bonjour ${widget.firstName} !' : '👋 Bonjour !',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Trouvez un médecin praticien et prenez rendez-vous en quelques secondes.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
                style: const TextStyle(color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Rechercher un médecin...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Specialty Selector Chips
        Container(
          height: 40,
          margin: const EdgeInsets.only(top: 14),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _specialties.length,
            itemBuilder: (context, index) {
              final spec = _specialties[index];
              final isSelected = _selectedSpecialty == spec;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(spec),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1A73E8),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedSpecialty = spec);
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Subtitle
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Médecins Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ),

        // Doctor List Stream builder
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'doctor')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final doctors = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final doctor = UserModel.fromMap(data);

                final name = '${doctor.firstName} ${doctor.lastName}'.toLowerCase();
                final matchesSearch = name.contains(_searchQuery);

                final matchesSpecialty = _selectedSpecialty == 'Tous' ||
                    doctor.specialty == _selectedSpecialty;

                return matchesSearch && matchesSpecialty;
              }).toList();

              if (doctors.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final data = doctors[index].data() as Map<String, dynamic>;
                  final doctor = UserModel.fromMap(data);
                  return DoctorCard(
                    doctor: doctor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookAppointmentScreen(doctor: doctor),
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
              'Aucun médecin disponible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez vérifier votre recherche ou réessayer plus tard.',
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
