enum Language { english, hindi, marathi }

enum ConsultationStatus {
  aiGuided,
  awaitingPayment,
  queued,
  inCall,
  followUp,
  completed,
}

class PatientProfile {
  const PatientProfile({
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.bmi,
    required this.city,
    required this.preferredLanguage,
    required this.medicalHistory,
    required this.reports,
    required this.previousConsultations,
  });

  final String patientId;
  final String name;
  final int age;
  final String sex;
  final double bmi;
  final String city;
  final Language preferredLanguage;
  final List<String> medicalHistory;
  final List<String> reports;
  final int previousConsultations;
}

class DoctorProfile {
  const DoctorProfile({
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.languages,
    required this.experienceYears,
    required this.fee,
    required this.rating,
    required this.online,
    required this.queueCount,
    required this.consultationsCompleted,
    required this.patientsAttended,
    required this.prescriptionsIssued,
    required this.walletBalance,
    required this.nextPayoutEligible,
  });

  final String doctorId;
  final String name;
  final String specialty;
  final List<Language> languages;
  final int experienceYears;
  final int fee;
  final double rating;
  final bool online;
  final int queueCount;
  final int consultationsCompleted;
  final int patientsAttended;
  final int prescriptionsIssued;
  final int walletBalance;
  final int nextPayoutEligible;

  DoctorProfile copyWith({
    String? doctorId,
    String? name,
    String? specialty,
    List<Language>? languages,
    int? experienceYears,
    int? fee,
    double? rating,
    bool? online,
    int? queueCount,
    int? consultationsCompleted,
    int? patientsAttended,
    int? prescriptionsIssued,
    int? walletBalance,
    int? nextPayoutEligible,
  }) {
    return DoctorProfile(
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      languages: languages ?? this.languages,
      experienceYears: experienceYears ?? this.experienceYears,
      fee: fee ?? this.fee,
      rating: rating ?? this.rating,
      online: online ?? this.online,
      queueCount: queueCount ?? this.queueCount,
      consultationsCompleted:
          consultationsCompleted ?? this.consultationsCompleted,
      patientsAttended: patientsAttended ?? this.patientsAttended,
      prescriptionsIssued: prescriptionsIssued ?? this.prescriptionsIssued,
      walletBalance: walletBalance ?? this.walletBalance,
      nextPayoutEligible: nextPayoutEligible ?? this.nextPayoutEligible,
    );
  }
}

class ConsultationRecord {
  const ConsultationRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.concern,
    required this.recommendedMode,
    required this.status,
    required this.scheduledAt,
    required this.amountPaid,
    required this.followUpRequired,
    this.prescription,
    this.clinicVisitDate,
    this.clinicVisitSlot,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String concern;
  final String recommendedMode;
  final ConsultationStatus status;
  final DateTime scheduledAt;
  final int amountPaid;
  final bool followUpRequired;
  final String? prescription;
  final String? clinicVisitDate;
  final String? clinicVisitSlot;

  ConsultationRecord copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? concern,
    String? recommendedMode,
    ConsultationStatus? status,
    DateTime? scheduledAt,
    int? amountPaid,
    bool? followUpRequired,
    String? prescription,
    String? clinicVisitDate,
    String? clinicVisitSlot,
  }) {
    return ConsultationRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      concern: concern ?? this.concern,
      recommendedMode: recommendedMode ?? this.recommendedMode,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      amountPaid: amountPaid ?? this.amountPaid,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      prescription: prescription ?? this.prescription,
      clinicVisitDate: clinicVisitDate ?? this.clinicVisitDate,
      clinicVisitSlot: clinicVisitSlot ?? this.clinicVisitSlot,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;
}

class FeedbackRecord {
  const FeedbackRecord({
    required this.consultationId,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    required this.note,
    required this.createdAt,
  });

  final String consultationId;
  final String patientId;
  final String doctorId;
  final int rating;
  final String note;
  final DateTime createdAt;
}

class PatientAppState {
  const PatientAppState({
    required this.patient,
    required this.doctors,
    required this.consultations,
    required this.chat,
    required this.feedback,
  });

  final PatientProfile patient;
  final List<DoctorProfile> doctors;
  final List<ConsultationRecord> consultations;
  final List<ChatMessage> chat;
  final List<FeedbackRecord> feedback;

  PatientAppState copyWith({
    PatientProfile? patient,
    List<DoctorProfile>? doctors,
    List<ConsultationRecord>? consultations,
    List<ChatMessage>? chat,
    List<FeedbackRecord>? feedback,
  }) {
    return PatientAppState(
      patient: patient ?? this.patient,
      doctors: doctors ?? this.doctors,
      consultations: consultations ?? this.consultations,
      chat: chat ?? this.chat,
      feedback: feedback ?? this.feedback,
    );
  }
}
