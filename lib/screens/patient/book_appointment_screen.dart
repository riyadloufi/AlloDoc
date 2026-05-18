import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../services/appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _service = AppointmentService();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '';
  String _selectedReason = 'consultation';
  String _selectedChronicIllness = 'Aucune';
  List<String> _bookedSlots = [];
  bool _isLoading = false;

  final List<String> _allSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
  ];
  final List<String> _reasons = ['consultation', 'urgence', 'suivi'];
  final List<String> _chronicIllnesses = [
    'Aucune',
    'Diabète',
    'Hypertension',
    'Asthme',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadBookedSlots() async {
    final booked = await _service.getBookedSlots(
      widget.doctor.uid,
      _selectedDate,
    );
    setState(() => _bookedSlots = booked);
  }

  Future<void> _confirmAppointment() async {
    if (_selectedSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir un créneau horaire'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser!;
    final appointment = AppointmentModel(
      id: '',
      patientId: currentUser.uid,
      doctorId: widget.doctor.uid,
      doctorName: '${widget.doctor.firstName} ${widget.doctor.lastName}',
      patientName: currentUser.email ?? '',
      date: _selectedDate,
      timeSlot: _selectedSlot,
      reason: _selectedReason,
      status: 'pending',
      description: _descriptionController.text.trim(),
      chronicIllness: _selectedChronicIllness,
    );
    await _service.createAppointment(appointment);
    setState(() => _isLoading = false);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Demande de rendez-vous envoyée !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Prendre RDV',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Doctor Premium Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Color(0xFF1A73E8),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dr. ${widget.doctor.firstName} ${widget.doctor.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Médecin Généraliste',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Motif Section
            _buildSectionHeader(Icons.assignment, 'Motif de consultation'),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: _reasons.map((reason) {
                  final isSelected = _selectedReason == reason;
                  return ChoiceChip(
                    label: Text(
                      reason[0].toUpperCase() + reason.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1A73E8),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
                      ),
                    ),
                    onSelected: (_) => setState(() => _selectedReason = reason),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Date Picker Section
            _buildSectionHeader(Icons.calendar_today, 'Date du rendez-vous'),
            const SizedBox(height: 12),
            Center(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF1A73E8),
                            onPrimary: Colors.white,
                            onSurface: Color(0xFF1E293B),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _selectedSlot = '';
                    });
                    _loadBookedSlots();
                  }
                },
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Time Slots Section
            _buildSectionHeader(Icons.access_time, 'Créneaux disponibles'),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _allSlots.map((slot) {
                  final isBooked = _bookedSlots.contains(slot);
                  final isSelected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: isBooked ? null : () => setState(() => _selectedSlot = slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isBooked
                            ? const Color(0xFFF1F5F9)
                            : (isSelected ? const Color(0xFF1A73E8) : Colors.white),
                        border: Border.all(
                          color: isBooked
                              ? const Color(0xFFE2E8F0)
                              : (isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isBooked
                              ? const Color(0xFF94A3B8)
                              : (isSelected ? Colors.white : const Color(0xFF1A73E8)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Extra Choice: Chronic Illnesses Section
            _buildSectionHeader(Icons.healing, 'Avez-vous une maladie chronique ?'),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: _chronicIllnesses.map((illness) {
                  final isSelected = _selectedChronicIllness == illness;
                  return ChoiceChip(
                    label: Text(
                      illness,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE11D48), // Medical accent color
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
                      ),
                    ),
                    onSelected: (_) => setState(() => _selectedChronicIllness = illness),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Description text field
            _buildSectionHeader(Icons.description, 'Description / Notes pour le médecin'),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Décrivez brièvement vos symptômes ou ajoutez une note...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Confirm Button
            Center(
              child: SizedBox(
                width: 260,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmer le rendez-vous',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
