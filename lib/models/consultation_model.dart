enum ConsultationStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  rejected
}

enum ConsultationType {
  audio,
  video,
  chat,
  inPerson
}

class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String patientImage;
  final String doctorImage;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final ConsultationStatus status;
  final ConsultationType type;
  final String symptoms;
  final String? diagnosis;
  final String? prescription;
  final String? notes;
  final double price;
  final String? paymentStatus;
  final String? meetingLink;
  final String? recordingUrl;
  final Map<String, dynamic>? patientVitals;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    this.patientImage = '',
    this.doctorImage = '',
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.status,
    required this.type,
    required this.symptoms,
    this.diagnosis,
    this.prescription,
    this.notes,
    required this.price,
    this.paymentStatus,
    this.meetingLink,
    this.recordingUrl,
    this.patientVitals,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorName: json['doctorName'] ?? '',
      patientImage: json['patientImage'] ?? '',
      doctorImage: json['doctorImage'] ?? '',
      scheduledAt: DateTime.parse(json['scheduledAt'] ?? DateTime.now().toIso8601String()),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ConsultationStatus.pending,
      ),
      type: ConsultationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ConsultationType.video,
      ),
      symptoms: json['symptoms'] ?? '',
      diagnosis: json['diagnosis'],
      prescription: json['prescription'],
      notes: json['notes'],
      price: (json['price'] ?? 0.0).toDouble(),
      paymentStatus: json['paymentStatus'],
      meetingLink: json['meetingLink'],
      recordingUrl: json['recordingUrl'],
      patientVitals: json['patientVitals'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'patientImage': patientImage,
      'doctorImage': doctorImage,
      'scheduledAt': scheduledAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'notes': notes,
      'price': price,
      'paymentStatus': paymentStatus,
      'meetingLink': meetingLink,
      'recordingUrl': recordingUrl,
      'patientVitals': patientVitals,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Consultation copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    String? patientImage,
    String? doctorImage,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    ConsultationStatus? status,
    ConsultationType? type,
    String? symptoms,
    String? diagnosis,
    String? prescription,
    String? notes,
    double? price,
    String? paymentStatus,
    String? meetingLink,
    String? recordingUrl,
    Map<String, dynamic>? patientVitals,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      patientImage: patientImage ?? this.patientImage,
      doctorImage: doctorImage ?? this.doctorImage,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      type: type ?? this.type,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      notes: notes ?? this.notes,
      price: price ?? this.price,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      meetingLink: meetingLink ?? this.meetingLink,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      patientVitals: patientVitals ?? this.patientVitals,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());
  bool get isToday => scheduledAt.day == DateTime.now().day && 
                     scheduledAt.month == DateTime.now().month && 
                     scheduledAt.year == DateTime.now().year;
  bool get canStart => status == ConsultationStatus.accepted && 
                      scheduledAt.isBefore(DateTime.now().add(Duration(minutes: 15)));
  bool get isCompleted => status == ConsultationStatus.completed;
  bool get isCancelled => status == ConsultationStatus.cancelled;
}


