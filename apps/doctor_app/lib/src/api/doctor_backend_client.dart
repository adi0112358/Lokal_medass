import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lokal_health_shared/lokal_health_shared.dart';

class DoctorSession {
  const DoctorSession({
    required this.token,
    required this.doctor,
  });

  final String token;
  final DoctorProfile doctor;
}

class DoctorBackendClient {
  DoctorBackendClient({
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

  DoctorProfile _parseDoctor(Map<String, dynamic> json) {
    Language parseLanguage(String value) {
      switch (value.toLowerCase()) {
        case 'hindi':
          return Language.hindi;
        case 'marathi':
          return Language.marathi;
        default:
          return Language.english;
      }
    }

    return DoctorProfile(
      doctorId: json['doctorId'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      languages: (json['languages'] as List<dynamic>? ?? const [])
          .map((item) => parseLanguage(item.toString()))
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

    return ConsultationRecord(
      id: json['consultationId'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      concern: json['concern'] as String? ?? '',
      recommendedMode: json['recommendedMode'] as String? ?? 'VIDEO_CALL',
      status: parseStatus(json['status'] as String? ?? 'QUEUED'),
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
      prescription: null,
      clinicVisitDate: null,
      clinicVisitSlot: null,
    );
  }

  Future<DoctorSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/doctor/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Doctor login failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DoctorSession(
      token: json['token'] as String,
      doctor: _parseDoctor(json['doctor'] as Map<String, dynamic>),
    );
  }

  Future<DoctorProfile> fetchMe(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/doctor/me'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Doctor fetch failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseDoctor(json['doctor'] as Map<String, dynamic>);
  }

  Future<List<ConsultationRecord>> fetchQueue(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/doctor/queue'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Queue fetch failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['consultations'] as List<dynamic>? ?? const [])
        .map((item) => _parseConsultation(item as Map<String, dynamic>))
        .toList();
  }

  Future<DoctorProfile> setAvailability({
    required String token,
    required bool online,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/doctor/availability'),
      headers: _headers(token: token),
      body: jsonEncode({'online': online}),
    );
    if (response.statusCode >= 400) {
      throw Exception('Availability update failed');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseDoctor(json['doctor'] as Map<String, dynamic>);
  }

  Future<void> startConsultation({
    required String token,
    required String consultationId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/doctor/consultations/$consultationId/start'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Start consultation failed');
    }
  }

  Future<void> requestVisit({
    required String token,
    required String consultationId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/doctor/consultations/$consultationId/request-visit'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 400) {
      throw Exception('Request visit failed');
    }
  }

  Future<void> completeConsultation({
    required String token,
    required String consultationId,
    required String prescription,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/doctor/consultations/$consultationId/complete'),
      headers: _headers(token: token),
      body: jsonEncode({'prescription': prescription}),
    );
    if (response.statusCode >= 400) {
      throw Exception('Complete consultation failed');
    }
  }
}
