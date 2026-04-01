import 'models.dart';

String _id(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch.toString().substring(7)}';

String languageLabel(Language language) {
  switch (language) {
    case Language.english:
      return 'English';
    case Language.hindi:
      return 'Hindi';
    case Language.marathi:
      return 'Marathi';
  }
}

class DemoRepository {
  PatientAppState initialPatientState() {
    return PatientAppState(
      patient: const PatientProfile(
        patientId: 'PAT-20451',
        name: 'Suman Verma',
        age: 33,
        sex: 'Female',
        bmi: 24.1,
        city: 'Kanpur',
        preferredLanguage: Language.hindi,
        medicalHistory: ['Seasonal allergies', 'Mild anemia in 2024'],
        reports: ['CBC Report - Jan 2026', 'Vitamin Panel - Feb 2026'],
        previousConsultations: 14,
        metadata: PatientMetadata(
          heightCm: 162,
          weightKg: 63,
          bloodGroup: 'B+',
          allergies: ['Dust', 'Pollen'],
          currentMedications: ['Iron supplement'],
          chronicConditions: ['Acidity episodes'],
          emergencyContactName: 'Rahul Verma',
          emergencyContactPhone: '+91 9000000000',
        ),
      ),
      doctors: const [
        DoctorProfile(
          doctorId: 'DOC-1101',
          name: 'Dr. Meera Sharma',
          specialty: 'General Physician',
          languages: [Language.hindi, Language.english],
          experienceYears: 11,
          fee: 399,
          rating: 4.8,
          online: true,
          queueCount: 2,
          consultationsCompleted: 1860,
          patientsAttended: 1540,
          prescriptionsIssued: 1302,
          walletBalance: 28450,
          nextPayoutEligible: 12000,
        ),
        DoctorProfile(
          doctorId: 'DOC-1102',
          name: 'Dr. Rajesh Iyer',
          specialty: 'Internal Medicine',
          languages: [Language.english, Language.hindi, Language.marathi],
          experienceYears: 14,
          fee: 549,
          rating: 4.7,
          online: false,
          queueCount: 0,
          consultationsCompleted: 2240,
          patientsAttended: 1998,
          prescriptionsIssued: 1708,
          walletBalance: 36100,
          nextPayoutEligible: 22000,
        ),
        DoctorProfile(
          doctorId: 'DOC-1103',
          name: 'Dr. Farah Khan',
          specialty: 'Dermatology',
          languages: [Language.hindi, Language.english],
          experienceYears: 8,
          fee: 449,
          rating: 4.6,
          online: true,
          queueCount: 1,
          consultationsCompleted: 980,
          patientsAttended: 920,
          prescriptionsIssued: 760,
          walletBalance: 18900,
          nextPayoutEligible: 8900,
        ),
      ],
      consultations: [
        ConsultationRecord(
          id: 'CONS-7601',
          patientId: 'PAT-20451',
          doctorId: 'DOC-1101',
          concern: 'Recurring acidity and bloating after meals',
          recommendedMode: 'VIDEO_CALL',
          status: ConsultationStatus.followUp,
          scheduledAt: DateTime(2026, 3, 23, 10, 30),
          amountPaid: 399,
          patientName: 'Suman Verma',
          patientAge: 33,
          patientSex: 'Female',
          patientCity: 'Kanpur',
          patientMedicalHistory: ['Seasonal allergies', 'Mild anemia in 2024'],
          patientCurrentMedications: ['Iron supplement'],
          doctorName: 'Dr. Meera Sharma',
          prescription:
              'Take antacid syrup after meals for 5 days. Avoid oily food. Schedule a physical check if pain increases.',
          followUpRequired: true,
          clinicVisitDate: '2026-03-29',
          clinicVisitSlot: '11:30 AM',
          videoSession: ConsultationVideoSession(
            sessionId: 'VID-2001',
            provider: 'jitsi',
            roomName: 'lokal-cons-7601',
            joinUrl: 'https://meet.jit.si/lokal-cons-7601',
            status: 'LIVE',
            startedAt: DateTime(2026, 3, 23, 10, 30),
          ),
        ),
        ConsultationRecord(
          id: 'CONS-7602',
          patientId: 'PAT-20451',
          doctorId: 'DOC-1103',
          concern: 'Mild skin rash with itching',
          recommendedMode: 'AI',
          status: ConsultationStatus.completed,
          scheduledAt: DateTime(2026, 3, 19, 8, 0),
          amountPaid: 0,
          patientName: 'Suman Verma',
          patientAge: 33,
          patientSex: 'Female',
          patientCity: 'Kanpur',
          patientMedicalHistory: ['Seasonal allergies', 'Mild anemia in 2024'],
          patientCurrentMedications: ['Iron supplement'],
          doctorName: 'Dr. Farah Khan',
          prescription:
              'Use calamine lotion twice daily and keep the area dry.',
          followUpRequired: false,
        ),
      ],
      chat: [
        ChatMessage(
          id: 'MSG-1',
          sender: 'assistant',
          text:
              'Namaste. I can help with symptom guidance, medication reminders, and deciding whether you need a doctor call or clinic visit.',
          createdAt: DateTime(2026, 3, 26, 10, 0),
        )
      ],
      feedback: [
        FeedbackRecord(
          consultationId: 'CONS-7601',
          patientId: 'PAT-20451',
          doctorId: 'DOC-1101',
          rating: 5,
          note: 'Doctor explained the diet plan very clearly in Hindi.',
          createdAt: DateTime(2026, 3, 23, 11, 20),
        )
      ],
    );
  }

  ChatMessage patientMessage(String text) {
    return ChatMessage(
      id: _id('MSG'),
      sender: 'patient',
      text: text,
      createdAt: DateTime.now(),
    );
  }

  ChatMessage assistantMessage(String prompt, Language language) {
    final lower = prompt.toLowerCase();
    String reply;

    if (lower.contains('chest') ||
        lower.contains('breath') ||
        lower.contains('bleeding')) {
      reply = language == Language.hindi
          ? 'Yeh emergency ho sakta hai. Turant nearest hospital ya emergency care se sampark kijiye.'
          : 'This may be an emergency. Please contact the nearest hospital or emergency care immediately.';
    } else if (lower.contains('fever') ||
        lower.contains('cold') ||
        lower.contains('cough')) {
      reply = language == Language.hindi
          ? 'Yeh routine consultation case lag raha hai. Hydration rakhiye, temperature track kijiye, aur zarurat pade to doctor video call book kijiye.'
          : 'This looks suitable for routine consultation. Track temperature, stay hydrated, and book a doctor call if symptoms continue.';
    } else if (lower.contains('skin') ||
        lower.contains('rash') ||
        lower.contains('itch')) {
      reply = language == Language.hindi
          ? 'Affected area clean aur dry rakhiye. Agar rash fail raha hai to dermatologist video consultation book kijiye.'
          : 'Keep the affected area clean and dry. If the rash is spreading, book a dermatologist video consultation.';
    } else {
      reply = language == Language.hindi
          ? 'Main first-level medical assistant hoon. Main guide kar sakta hoon ki home care, doctor call, ya physical visit mein kya better rahega.'
          : 'I am a first-level medical assistant. I can guide whether home care, doctor call, or physical visit is the better next step.';
    }

    return ChatMessage(
      id: _id('MSG'),
      sender: 'assistant',
      text: reply,
      createdAt: DateTime.now(),
    );
  }

  PatientAppState bookDoctor(PatientAppState state, DoctorProfile doctor) {
    final concern =
        state.chat.isNotEmpty ? state.chat.last.text : 'General consultation requested';

    final consultation = ConsultationRecord(
      id: _id('CONS'),
      patientId: state.patient.patientId,
      doctorId: doctor.doctorId,
      concern: concern,
      recommendedMode: 'VIDEO_CALL',
      status: ConsultationStatus.queued,
      scheduledAt: DateTime.now(),
      amountPaid: doctor.fee,
      followUpRequired: false,
      patientName: state.patient.name,
      patientAge: state.patient.age,
      patientSex: state.patient.sex,
      patientCity: state.patient.city,
      patientMedicalHistory: state.patient.medicalHistory,
      patientCurrentMedications: state.patient.metadata.currentMedications,
      doctorName: doctor.name,
    );

    final doctors = state.doctors
        .map(
          (item) => item.doctorId == doctor.doctorId
              ? item.copyWith(
                  queueCount: item.queueCount + 1,
                  walletBalance: item.walletBalance + item.fee,
                  nextPayoutEligible: item.nextPayoutEligible + item.fee,
                )
              : item,
        )
        .toList();

    return state.copyWith(
      doctors: doctors,
      consultations: [consultation, ...state.consultations],
    );
  }

  PatientAppState addChat(PatientAppState state, ChatMessage message) {
    return state.copyWith(chat: [...state.chat, message]);
  }

  PatientAppState scheduleFollowUp(PatientAppState state, ConsultationRecord record) {
    final consultations = state.consultations
        .map(
          (item) => item.id == record.id
              ? item.copyWith(
                  status: ConsultationStatus.followUp,
                  followUpRequired: true,
                  clinicVisitDate: '2026-03-31',
                  clinicVisitSlot: '12:15 PM',
                )
              : item,
        )
        .toList();
    return state.copyWith(consultations: consultations);
  }

  PatientAppState submitFeedback(
    PatientAppState state, {
    required ConsultationRecord consultation,
    required int rating,
    required String note,
  }) {
    final feedback = FeedbackRecord(
      consultationId: consultation.id,
      patientId: consultation.patientId,
      doctorId: consultation.doctorId,
      rating: rating,
      note: note,
      createdAt: DateTime.now(),
    );

    final doctorRatings = [
      ...state.feedback.where((item) => item.doctorId == consultation.doctorId),
      feedback,
    ];
    final average =
        doctorRatings.fold<int>(0, (sum, item) => sum + item.rating) / doctorRatings.length;

    final doctors = state.doctors
        .map(
          (doctor) => doctor.doctorId == consultation.doctorId
              ? doctor.copyWith(rating: double.parse(average.toStringAsFixed(1)))
              : doctor,
        )
        .toList();

    return state.copyWith(
      doctors: doctors,
      feedback: [feedback, ...state.feedback],
    );
  }

  DoctorProfile activeDoctor(PatientAppState state, String doctorId) {
    return state.doctors.firstWhere((doctor) => doctor.doctorId == doctorId);
  }

  PatientAppState toggleDoctorAvailability(PatientAppState state, String doctorId) {
    final doctors = state.doctors
        .map(
          (doctor) => doctor.doctorId == doctorId
              ? doctor.copyWith(online: !doctor.online)
              : doctor,
        )
        .toList();
    return state.copyWith(doctors: doctors);
  }

  List<ConsultationRecord> activeQueue(PatientAppState state, String doctorId) {
    return state.consultations
        .where(
          (item) =>
              item.doctorId == doctorId &&
              (item.status == ConsultationStatus.queued ||
                  item.status == ConsultationStatus.inCall ||
                  item.status == ConsultationStatus.followUp),
        )
        .toList();
  }

  PatientAppState startConsultation(PatientAppState state, ConsultationRecord record) {
    final consultations = state.consultations
        .map(
          (item) => item.id == record.id
              ? item.copyWith(status: ConsultationStatus.inCall)
              : item,
        )
        .toList();

    final doctors = state.doctors
        .map(
          (doctor) => doctor.doctorId == record.doctorId
              ? doctor.copyWith(queueCount: doctor.queueCount > 0 ? doctor.queueCount - 1 : 0)
              : doctor,
        )
        .toList();

    return state.copyWith(doctors: doctors, consultations: consultations);
  }

  PatientAppState completeConsultation(
    PatientAppState state, {
    required ConsultationRecord record,
    required String prescription,
  }) {
    final consultations = state.consultations
        .map(
          (item) => item.id == record.id
              ? item.copyWith(
                  status: ConsultationStatus.completed,
                  prescription: prescription,
                )
              : item,
        )
        .toList();

    final doctors = state.doctors
        .map(
          (doctor) => doctor.doctorId == record.doctorId
              ? doctor.copyWith(
                  consultationsCompleted: doctor.consultationsCompleted + 1,
                  patientsAttended: doctor.patientsAttended + 1,
                  prescriptionsIssued: doctor.prescriptionsIssued + 1,
                )
              : doctor,
        )
        .toList();

    return state.copyWith(doctors: doctors, consultations: consultations);
  }

  PatientAppState requestVisit(PatientAppState state, ConsultationRecord record) {
    final consultations = state.consultations
        .map(
          (item) => item.id == record.id
              ? item.copyWith(
                  status: ConsultationStatus.followUp,
                  followUpRequired: true,
                  prescription: item.prescription ??
                      'Physical examination advised before further medication.',
                  clinicVisitDate: '2026-03-31',
                  clinicVisitSlot: '04:00 PM',
                )
              : item,
        )
        .toList();
    return state.copyWith(consultations: consultations);
  }
}
