class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String specialty;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.specialty = 'Généraliste',
  });

  // Convertir Firestore → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: map['role'] ?? '',
      specialty: map['specialty'] ?? 'Généraliste',
    );
  }

  // Convertir UserModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'specialty': specialty,
    };
  }

  // Obtenir le nom du médecin formaté et nettoyé (évite les doublons Dr. Dr.)
  String get formattedDoctorName {
    return cleanDoctorName('$firstName $lastName');
  }

  // Nettoyer n'importe quelle chaîne pour s'assurer qu'elle commence par "Dr. " sans doublon
  static String cleanDoctorName(String name) {
    String temp = name.trim();
    while (true) {
      if (temp.toLowerCase().startsWith('dr.')) {
        temp = temp.substring(3).trim();
      } else if (temp.toLowerCase().startsWith('dr ')) {
        temp = temp.substring(3).trim();
      } else if (temp.toLowerCase() == 'dr') {
        temp = '';
        break;
      } else {
        break;
      }
    }
    return 'Dr. $temp';
  }
}
