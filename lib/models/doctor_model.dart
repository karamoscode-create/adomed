class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String specialization;
  final String licenseNumber;
  final String university;
  final int graduationYear;
  final String profileImage;
  final String bio;
  final List<String> languages;
  final List<String> certifications;
  final Map<String, dynamic> availability;
  final double consultationPrice;
  final double rating;
  final int totalConsultations;
  final bool isVerified;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime lastActive;
  final Map<String, dynamic> location;
  final List<String> acceptedInsurance;
  final Map<String, dynamic> paymentMethods;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.specialization,
    required this.licenseNumber,
    required this.university,
    required this.graduationYear,
    this.profileImage = '',
    this.bio = '',
    this.languages = const ['Français'],
    this.certifications = const [],
    this.availability = const {},
    this.consultationPrice = 0.0,
    this.rating = 0.0,
    this.totalConsultations = 0,
    this.isVerified = false,
    this.isOnline = false,
    required this.createdAt,
    required this.lastActive,
    this.location = const {},
    this.acceptedInsurance = const [],
    this.paymentMethods = const {},
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      specialization: json['specialization'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      university: json['university'] ?? '',
      graduationYear: json['graduationYear'] ?? 0,
      profileImage: json['profileImage'] ?? '',
      bio: json['bio'] ?? '',
      languages: List<String>.from(json['languages'] ?? ['Français']),
      certifications: List<String>.from(json['certifications'] ?? []),
      availability: json['availability'] ?? {},
      consultationPrice: (json['consultationPrice'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalConsultations: json['totalConsultations'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? {},
      acceptedInsurance: List<String>.from(json['acceptedInsurance'] ?? []),
      paymentMethods: json['paymentMethods'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'university': university,
      'graduationYear': graduationYear,
      'profileImage': profileImage,
      'bio': bio,
      'languages': languages,
      'certifications': certifications,
      'availability': availability,
      'consultationPrice': consultationPrice,
      'rating': rating,
      'totalConsultations': totalConsultations,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'location': location,
      'acceptedInsurance': acceptedInsurance,
      'paymentMethods': paymentMethods,
    };
  }

  String get fullName => '$firstName $lastName';
  String get displayName => 'Dr. $lastName';
  String get specializationDisplay => specialization.isNotEmpty ? specialization : 'Médecin généraliste';
}


