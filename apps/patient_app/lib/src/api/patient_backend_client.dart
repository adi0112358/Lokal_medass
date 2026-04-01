import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lokal_health_shared/lokal_health_shared.dart';

class PatientSession {
  const PatientSession({
    required this.token,
    required this.patient,
  });

  final String token;
  final PatientProfile patient;
}

class AppointmentItem {
  const AppointmentItem({
    required this.appointmentId,
    required this.consultationId,
    required this.doctorId,
    required this.date,
    required this.slot,
    required this.clinicName,
    required this.status,
  });

  final String appointmentId;
  final String consultationId;
  final String doctorId;
  final String date;
  final String slot;
  final String clinicName;
  final String status;
}

class ChatThread {
  const ChatThread({
    required this.conversationId,
    required this.title,
    required this.updatedAt,
    required this.messages,
  });

  final String conversationId;
  final String title;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
}

class PrescriptionItem {
  const PrescriptionItem({
    required this.prescriptionId,
    required this.consultationId,
    required this.doctorId,
    required this.advice,
    required this.medicines,
  });

  final String prescriptionId;
  final String consultationId;
  final String doctorId;
  final String advice;
  final List<Map<String, dynamic>> medicines;
}

class FeedbackItem {
  const FeedbackItem({
    required this.feedbackId,
    required this.consultationId,
    required this.doctorId,
    required this.rating,
    required this.note,
  });

  final String feedbackId;
  final String consultationId;
  final String doctorId;
  final int rating;
  final String note;
}

class PatientChatReply {
  const PatientChatReply({
    required this.conversationId,
    required this.assistantMessage,
    required this.riskLevel,
    required this.careMode,
    required this.redFlagDetected,
    required this.doctorSummary,
    required this.followUpQuestions,
  });

  final String? conversationId;
  final String assistantMessage;
  final String riskLevel;
  final String careMode;
  final bool redFlagDetected;
  final String doctorSummary;
  final List<String> followUpQuestions;

  factory PatientChatReply.fromJson(Map<String, dynamic> json) {
    return PatientChatReply(
      conversationId: json['conversationId'] as String?,
      assistantMessage: json['assistantMessage'] as String? ?? '',
      riskLevel: json['riskLevel'] as String? ?? 'low',
      careMode: json['careMode'] as String? ?? 'self_care',
      redFlagDetected: json['redFlagDetected'] as bool? ?? false,
      doctorSummary: json['doctorSummary'] as String? ?? '',
      followUpQuestions: (json['followUpQuestions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class PatientBackendClient {
  PatientBackendClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'PATIENT_API_BASE_URL',
              defaultValue: 'http://10.0.2.2:8080',
            );

  final http.Client _httpClient;
  final String _baseUrl;

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Language _parseLanguage(String value) {
    switch (value.toLowerCase()) {
      case 'hindi':
        return Language.hindi;
      case 'marathi':
        return Language.marathi;
      default:
        return Language.english;
    }
  }

  PatientMetadata _parseMetadata(Map<String, dynamic>? json) {
    final source = json ?? const <String, dynamic>{};
    return PatientMetadata(
      heightCm: (source['heightCm'] as num?)?.toDouble(),
      weightKg: (source['weightKg'] as num?)?.toDouble(),
      bloodGroup: source['bloodGroup'] as String?,
      allergies: (source['allergies'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      currentMedications:
          (source['currentMedications'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      chronicConditions:
          (source['chronicConditions'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      emergencyContactName: source['emergencyContactName'] as String?,
      emergencyContactPhone: source['emergencyContactPhone'] as String?,
      lastUpdated: DateTime.tryParse(source['lastUpdated'] as String? ?? ''),
    );
  }

  ConsultationVideoSession? _parseVideoSession(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return ConsultationVideoSession(
      sessionId: json['sessionId'] as String,
      provider: json['provider'] as String? ?? 'jitsi',
      roomName: json['roomName'] as String? ?? '',
      joinUrl: json['joinUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'READY',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
    );
  }

  PatientProfile _parsePatient(Map<String, dynamic> json) {
    final language = (json['preferredLanguage'] as String? ?? 'English').toLowerCase();
    return PatientProfile(
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      age: (json['age'] as num?)?.toInt() ?? 0,
      sex: json['sex'] as String? ?? 'Other',
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0,
      city: json['city'] as String? ?? '',
      preferredLanguage: _parseLanguage(language),
      medicalHistory: (json['medicalHistory'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      reports: (json['reports'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      previousConsultations: (json['previousConsultations'] as num?)?.toInt() ?? 0,
      metadata: _parseMetadata(json['metadata'] as Map<String, dynamic>?),
    );
  }

  DoctorProfile _parseDoctor(Map<String, dynamic> json) {
    return DoctorProfile(
      doctorId: json['doctorId'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      languages: (json['languages'] as List<dynamic>? ?? const [])
          .map((item) => _parseLanguage(item.toString()))
          .toList(),
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      fee: (json['fee'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      online: json['online'] as bool? ?? false,
      queueCount: (json['queueCount'] as num?)?.toInt() ?? 0,
      consultationsCompleted: (json['consultationsCompleted'] as num?)?.toInt() ?? 0,
      patientsAttended: (json['patientsAttended'] as num?)?.toInt() ?? 0,
      prescriptionsIssued: (json['prescriptionsIssued'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
      nextPayoutEligible: (json['nextPayoutEligible'] as num?)?.toInt() ?? 0,
    );
  }

  ConsultationRecord _parseConsultation(Map<String, dynamic> json) {
    ConsultationStatus parseStatus(String raw) {
      switch (raw.toUpperCase()) {
        case 'AWAITING_PAYMENT':
          return ConsultationStatus.awaitingPayment;
        case 'QUEUED':
          return ConsultationStatus.queued;
        case 'IN_CALL':
          return ConsultationStatus.inCall;
        case 'FOLLOW_UP':
          return ConsultationStatus.followUp;
        case 'COMPLETED':
          return ConsultationStatus.completed;
        default:
          return ConsultationStatus.aiGuided;
      }
    }

    final appointment = json['appointment'] as Map<String, dynamic>?;
    final prescription = json['prescription'] as Map<String, dynamic>?;

    return ConsultationRecord(
      id: json['consultationId'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      concern: json['concern'] as String? ?? '',
      recommendedMode: json['recommendedMode'] as String? ?? 'AI',
      status: parseStatus(json['status'] as String? ?? 'AI_GUIDED'),
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
      patientName: json['patientName'] as String?,
      patientAge: (json['patientAge'] as num?)?.toInt(),
      patientSex: json['patientSex'] as String?,
      patientCity: json['patientCity'] as String?,
      patientMedicalHistory:
          (json['patientMedicalHistory'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      patientCurrentMedications:
          (json['patientCurrentMedications'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      doctorName: json['doctorName'] as String?,
      prescription: prescription?['advice'] as String?,
      clinicVisitDate: appointment?['date'] as String?,
      clinicVisitSlot: appointment?['slot'] as String?,
      videoSession: _parseVideoSession(json['videoSession'] as Map<String, dynamic>?),
    );
  }

  ChatMessage _parseChatMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      sender: json['sender'] as String? ?? 'assistant',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  ChatThread _parseChatThread(Map<String, dynamic> json) {
    return ChatThread(
      conversationId: json['conversationId'] as String,
      title: json['title'] as String? ?? 'Conversation',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      messages: (json['messages'] as List<dynamic>? ?? const [])
          .map((item) => _parseChatMessage(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<PatientSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/patient/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Login failed');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PatientSession(
      token: json['token'] as String,
      patient: _parsePatient(json['patient'] as Map<String, dynamic>),
    );
  }

  Future<PatientProfile> fetchMe(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/patient/me'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Patient fetch failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parsePatient(json['patient'] as Map<String, dynamic>);
  }

  Future<PatientProfile> updateProfile({
    required String token,
    required PatientProfile patient,
  }) async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/api/patient/profile'),
      headers: _headers(token: token),
      body: jsonEncode({
        'name': patient.name,
        'city': patient.city,
        'preferredLanguage': languageLabel(patient.preferredLanguage),
        'bmi': patient.bmi,
        'medicalHistory': patient.medicalHistory,
        'reports': patient.reports,
        'metadata': {
          'heightCm': patient.metadata.heightCm,
          'weightKg': patient.metadata.weightKg,
          'bloodGroup': patient.metadata.bloodGroup,
          'allergies': patient.metadata.allergies,
          'currentMedications': patient.metadata.currentMedications,
          'chronicConditions': patient.metadata.chronicConditions,
          'emergencyContactName': patient.metadata.emergencyContactName,
          'emergencyContactPhone': patient.metadata.emergencyContactPhone,
        },
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Profile update failed');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parsePatient(json['patient'] as Map<String, dynamic>);
  }

  Future<List<DoctorProfile>> fetchDoctors() async {
    final response = await _httpClient.get(Uri.parse('$_baseUrl/api/doctors'));
    if (response.statusCode >= 400) {
      throw Exception('Doctor list failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['doctors'] as List<dynamic>? ?? const [])
        .map((item) => _parseDoctor(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConsultationRecord>> fetchBookings(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/patient/bookings'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Bookings failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['consultations'] as List<dynamic>? ?? const [])
        .map((item) => _parseConsultation(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatThread>> fetchChats(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/patient/chats'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Chats failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['conversations'] as List<dynamic>? ?? const [])
        .map((item) => _parseChatThread(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppointmentItem>> fetchAppointments(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/patient/appointments'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Appointments failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['appointments'] as List<dynamic>? ?? const [])
        .map(
          (item) => AppointmentItem(
            appointmentId: item['appointmentId'] as String,
            consultationId: item['consultationId'] as String,
            doctorId: item['doctorId'] as String,
            date: item['date'] as String,
            slot: item['slot'] as String,
            clinicName: item['clinicName'] as String,
            status: item['status'] as String,
          ),
        )
        .toList();
  }

  Future<List<PrescriptionItem>> fetchPrescriptions(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/patient/prescriptions'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Prescriptions failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['prescriptions'] as List<dynamic>? ?? const [])
        .map(
          (item) => PrescriptionItem(
            prescriptionId: item['prescriptionId'] as String,
            consultationId: item['consultationId'] as String,
            doctorId: item['doctorId'] as String,
            advice: item['advice'] as String? ?? '',
            medicines: (item['medicines'] as List<dynamic>? ?? const [])
                .map((medicine) => Map<String, dynamic>.from(medicine as Map))
                .toList(),
          ),
        )
        .toList();
  }

  Future<ConsultationRecord> createBooking({
    required String token,
    required String doctorId,
    required String concern,
    String recommendedMode = 'VIDEO_CALL',
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/patient/bookings'),
      headers: _headers(token: token),
      body: jsonEncode({
        'doctorId': doctorId,
        'concern': concern,
        'recommendedMode': recommendedMode,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Booking failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseConsultation(json['consultation'] as Map<String, dynamic>);
  }

  Future<ConsultationRecord> prepareVideoSession({
    required String token,
    required String consultationId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/patient/consultations/$consultationId/join-video'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Video session failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseConsultation(json['consultation'] as Map<String, dynamic>);
  }

  Future<AppointmentItem> createAppointment({
    required String token,
    required String consultationId,
    required String doctorId,
    required String date,
    required String slot,
    required String clinicName,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/patient/appointments'),
      headers: _headers(token: token),
      body: jsonEncode({
        'consultationId': consultationId,
        'doctorId': doctorId,
        'date': date,
        'slot': slot,
        'clinicName': clinicName,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Appointment failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final item = json['appointment'] as Map<String, dynamic>;
    return AppointmentItem(
      appointmentId: item['appointmentId'] as String,
      consultationId: item['consultationId'] as String,
      doctorId: item['doctorId'] as String,
      date: item['date'] as String,
      slot: item['slot'] as String,
      clinicName: item['clinicName'] as String,
      status: item['status'] as String,
    );
  }

  Future<void> submitFeedback({
    required String token,
    required String consultationId,
    required String doctorId,
    required int rating,
    required String note,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/patient/feedback'),
      headers: _headers(token: token),
      body: jsonEncode({
        'consultationId': consultationId,
        'doctorId': doctorId,
        'rating': rating,
        'note': note,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Feedback failed');
    }
  }

  Future<PatientChatReply> sendChat({
    required String token,
    required String message,
    required PatientProfile patient,
    String? conversationId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/patient/chat'),
      headers: _headers(token: token),
      body: jsonEncode({
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        'patient': {
          'patientId': patient.patientId,
          'name': patient.name,
          'age': patient.age,
          'sex': patient.sex,
          'bmi': patient.bmi,
          'city': patient.city,
          'preferredLanguage': languageLabel(patient.preferredLanguage),
          'medicalHistory': patient.medicalHistory,
          'reports': patient.reports,
          'metadata': {
            'allergies': patient.metadata.allergies,
            'currentMedications': patient.metadata.currentMedications,
            'chronicConditions': patient.metadata.chronicConditions,
          }
        }
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Patient backend failed with status ${response.statusCode}');
    }

    return PatientChatReply.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
