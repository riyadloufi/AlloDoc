import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _specialties = [
    'Généraliste',
    'Pédiatre',
    'Cardiologue',
    'Dentiste',
    'Dermatologue',
    'Ophtalmologue',
  ];
  String _role = '';
  String _selectedSpecialty = 'Généraliste';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null) {
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _role = data['role'] ?? '';
      _selectedSpecialty = data['specialty'] ?? 'Généraliste';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez remplir tous les champs'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    
    final Map<String, dynamic> updateData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
    };
    if (_role == 'doctor') {
      updateData['specialty'] = _selectedSpecialty;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(updateData);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon Profil')),
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Header Card
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 3),
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                  child: Icon(
                    _role == 'doctor' ? Icons.medical_services_rounded : Icons.person_rounded,
                    size: 54,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Email detail box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 20, color: Color(0xFF64748B)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adresse email (non modifiable)',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          FirebaseAuth.instance.currentUser!.email!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Form inputs
            const Text(
              'Prénom',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Nom',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),

            if (_role == 'doctor') ...[
              const SizedBox(height: 20),
              const Text(
                'Spécialité médicale',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.stars_outlined),
                ),
                items: _specialties.map((spec) {
                  return DropdownMenuItem<String>(
                    value: spec,
                    child: Text(spec),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSpecialty = val);
                  }
                },
              ),
            ],

            const SizedBox(height: 40),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
