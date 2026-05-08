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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '';
  String _selectedReason = 'consultation';
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

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choisissez un créneau')));
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
      status: 'confirmed',
    );
    await _service.createAppointment(appointment);
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Rendez-vous confirmé'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RDV - Dr. ${widget.doctor.firstName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1A73E8),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  'Dr. ${widget.doctor.firstName} ${widget.doctor.lastName}',
                ),
                subtitle: const Text('Médecin généraliste'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Motif',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _reasons
                  .map(
                    (reason) => ChoiceChip(
                      label: Text(reason),
                      selected: _selectedReason == reason,
                      selectedColor: const Color(0xFF1A73E8),
                      onSelected: (_) =>
                          setState(() => _selectedReason = reason),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _selectedSlot = '';
                  });
                  _loadBookedSlots();
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Créneau',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSlots.map((slot) {
                final isBooked = _bookedSlots.contains(slot);
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: isBooked
                      ? null
                      : () => setState(() => _selectedSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey[300]
                          : (isSelected
                                ? const Color(0xFF1A73E8)
                                : Colors.white),
                      border: Border.all(
                        color: isBooked ? Colors.grey : const Color(0xFF1A73E8),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isBooked
                            ? Colors.grey
                            : (isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A73E8)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '✅ Confirmer',
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
