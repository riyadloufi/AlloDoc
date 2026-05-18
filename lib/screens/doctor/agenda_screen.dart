import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appointment_card.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  final AppointmentService _service = AppointmentService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Mon Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              tooltip: 'Sélectionner une date',
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
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
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Elegant Header Banner for chosen Date
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              children: [
                Text(
                  _getWeekday(_selectedDate),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${_selectedDate.day} ${_getMonthName(_selectedDate)} ${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Agenda list view
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _service.getDoctorAppointments(doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final appointments = snapshot.data ?? [];
                final filtered = appointments
                    .where(
                      (app) =>
                          app.date.year == _selectedDate.year &&
                          app.date.month == _selectedDate.month &&
                          app.date.day == _selectedDate.day,
                    )
                    .toList()
                  ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

                if (filtered.isEmpty) {
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
                          const Text(
                            'Aucun rendez-vous ce jour',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Profitez de cette journée pour vous reposer !',
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

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => AppointmentCard(
                    appointment: filtered[index],
                    isDoctorView: true,
                    onCancel: () async {
                      final isConfirmed = filtered[index].status == 'confirmed';
                      String cancelReason = '';

                      if (isConfirmed) {
                        final List<String> cancelReasons = [
                          'Urgence médicale de dernière minute',
                          'Indisponibilité professionnelle imprévue',
                          'Problème personnel / Cas de force majeure',
                          'Modification exceptionnelle d\'emploi du temps',
                          'Congé maladie imprévu',
                        ];

                        final selectedReason = await _showReasonSelector(
                          context,
                          'Annuler le rendez-vous',
                          cancelReasons,
                        );

                        if (selectedReason == null) return;
                        cancelReason = selectedReason;
                      }

                      await _service.cancelAppointment(filtered[index].id, reason: cancelReason);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Rendez-vous annulé'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) => [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ][date.weekday - 1];

  String _getMonthName(DateTime date) => [
        'Janvier',
        'Février',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Août',
        'Septembre',
        'Octobre',
        'Novembre',
        'Décembre',
      ][date.month - 1];

  Future<String?> _showReasonSelector(BuildContext context, String title, List<String> reasons) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        String? tempSelected;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Veuillez sélectionner un motif obligatoire ci-dessous :',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map((reason) {
                    final isSelected = tempSelected == reason;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1A73E8).withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          reason,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF1E293B),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF1A73E8))
                            : null,
                        onTap: () {
                          setModalState(() => tempSelected = reason);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: tempSelected == null
                          ? null
                          : () => Navigator.pop(context, tempSelected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirmer le motif',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
