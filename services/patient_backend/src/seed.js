import { hashPassword } from "./auth.js";

export const initialStore = {
  patients: [
    {
      patientId: "PAT-20451",
      name: "Suman Verma",
      email: "suman.verma@lokal.demo",
      passwordHash: hashPassword("Pass@123"),
      age: 33,
      sex: "Female",
      bmi: 24.1,
      city: "Kanpur",
      preferredLanguage: "Hindi",
      medicalHistory: ["Seasonal allergies", "Mild anemia in 2024"],
      reports: ["CBC Report - Jan 2026", "Vitamin Panel - Feb 2026"],
      metadata: {
        heightCm: 162,
        weightKg: 63,
        bloodGroup: "B+",
        allergies: ["Dust", "Pollen"],
        currentMedications: ["Iron supplement"],
        chronicConditions: ["Acidity episodes"],
        emergencyContactName: "Rahul Verma",
        emergencyContactPhone: "+91 9000000000",
        lastUpdated: "2026-03-24T08:00:00.000Z"
      },
      previousConsultations: 14,
      createdAt: "2026-03-20T09:00:00.000Z"
    }
  ],
  doctors: [
    {
      doctorId: "DOC-1101",
      name: "Dr. Meera Sharma",
      email: "meera.sharma@lokal.demo",
      passwordHash: hashPassword("Doc@123"),
      specialty: "General Physician",
      languages: ["Hindi", "English"],
      experienceYears: 11,
      fee: 399,
      rating: 4.8,
      online: true,
      queueCount: 2,
      consultationsCompleted: 1860,
      patientsAttended: 1540,
      prescriptionsIssued: 1302,
      walletBalance: 28450,
      nextPayoutEligible: 12000
    },
    {
      doctorId: "DOC-1102",
      name: "Dr. Rajesh Iyer",
      email: "rajesh.iyer@lokal.demo",
      passwordHash: hashPassword("Doc@123"),
      specialty: "Internal Medicine",
      languages: ["English", "Hindi", "Marathi"],
      experienceYears: 14,
      fee: 549,
      rating: 4.7,
      online: false,
      queueCount: 0,
      consultationsCompleted: 2240,
      patientsAttended: 1998,
      prescriptionsIssued: 1708,
      walletBalance: 36100,
      nextPayoutEligible: 22000
    },
    {
      doctorId: "DOC-1103",
      name: "Dr. Farah Khan",
      email: "farah.khan@lokal.demo",
      passwordHash: hashPassword("Doc@123"),
      specialty: "Dermatology",
      languages: ["Hindi", "English"],
      experienceYears: 8,
      fee: 449,
      rating: 4.6,
      online: true,
      queueCount: 1,
      consultationsCompleted: 980,
      patientsAttended: 920,
      prescriptionsIssued: 760,
      walletBalance: 18900,
      nextPayoutEligible: 8900
    }
  ],
  conversations: [
    {
      conversationId: "CHAT-1001",
      patientId: "PAT-20451",
      title: "General symptom guidance",
      createdAt: "2026-03-26T10:00:00.000Z",
      updatedAt: "2026-03-26T10:00:00.000Z",
      messages: [
        {
          id: "MSG-1",
          sender: "assistant",
          text: "Namaste. I can help with symptom guidance, medication reminders, and deciding whether you need a doctor call or clinic visit.",
          createdAt: "2026-03-26T10:00:00.000Z"
        }
      ]
    }
  ],
  videoSessions: [
    {
      sessionId: "VID-2001",
      consultationId: "CONS-7601",
      provider: "jitsi",
      roomName: "lokal-cons-7601",
      joinUrl: "https://meet.jit.si/lokal-cons-7601",
      status: "LIVE",
      createdAt: "2026-03-23T10:25:00.000Z",
      startedAt: "2026-03-23T10:30:00.000Z",
      expiresAt: null
    }
  ],
  consultations: [
    {
      consultationId: "CONS-7601",
      patientId: "PAT-20451",
      doctorId: "DOC-1101",
      concern: "Recurring acidity and bloating after meals",
      recommendedMode: "VIDEO_CALL",
      status: "FOLLOW_UP",
      scheduledAt: "2026-03-23T10:30:00.000Z",
      amountPaid: 399,
      prescriptionId: "RX-4001",
      appointmentId: "APT-5001",
      followUpRequired: true,
      createdAt: "2026-03-23T10:20:00.000Z"
    },
    {
      consultationId: "CONS-7602",
      patientId: "PAT-20451",
      doctorId: "DOC-1103",
      concern: "Mild skin rash with itching",
      recommendedMode: "AI",
      status: "COMPLETED",
      scheduledAt: "2026-03-19T08:00:00.000Z",
      amountPaid: 0,
      prescriptionId: "RX-4002",
      appointmentId: null,
      followUpRequired: false,
      createdAt: "2026-03-19T08:00:00.000Z"
    }
  ],
  appointments: [
    {
      appointmentId: "APT-5001",
      consultationId: "CONS-7601",
      patientId: "PAT-20451",
      doctorId: "DOC-1101",
      date: "2026-03-29",
      slot: "11:30 AM",
      clinicName: "Lokal Health Clinic - Kanpur Central",
      status: "BOOKED",
      createdAt: "2026-03-23T11:00:00.000Z"
    }
  ],
  prescriptions: [
    {
      prescriptionId: "RX-4001",
      consultationId: "CONS-7601",
      patientId: "PAT-20451",
      doctorId: "DOC-1101",
      medicines: [
        {
          name: "Antacid syrup",
          dosage: "10 ml after meals",
          frequency: "Twice daily",
          duration: "5 days"
        }
      ],
      advice: "Avoid oily food. Schedule a physical check if pain increases.",
      createdAt: "2026-03-23T10:50:00.000Z"
    },
    {
      prescriptionId: "RX-4002",
      consultationId: "CONS-7602",
      patientId: "PAT-20451",
      doctorId: "DOC-1103",
      medicines: [
        {
          name: "Calamine lotion",
          dosage: "Apply locally",
          frequency: "Twice daily",
          duration: "5 days"
        }
      ],
      advice: "Keep the affected area dry.",
      createdAt: "2026-03-19T08:20:00.000Z"
    }
  ],
  feedback: [
    {
      feedbackId: "FDB-3001",
      consultationId: "CONS-7601",
      patientId: "PAT-20451",
      doctorId: "DOC-1101",
      rating: 5,
      note: "Doctor explained the diet plan very clearly in Hindi.",
      createdAt: "2026-03-23T11:20:00.000Z"
    }
  ]
};
