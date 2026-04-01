import { DemoStore } from "@/lib/types";

export const demoStore: DemoStore = {
  patient: {
    patientId: "PAT-20451",
    name: "Suman Verma",
    age: 33,
    sex: "Female",
    bmi: 24.1,
    city: "Kanpur",
    preferredLanguage: "Hindi",
    medicalHistory: ["Seasonal allergies", "Mild anemia in 2024"],
    reports: ["CBC Report - Jan 2026", "Vitamin Panel - Feb 2026"],
    previousConsultations: 14
  },
  doctors: [
    {
      doctorId: "DOC-1101",
      name: "Dr. Meera Sharma",
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
  consultations: [
    {
      id: "CONS-7601",
      patientId: "PAT-20451",
      doctorId: "DOC-1101",
      concern: "Recurring acidity and bloating after meals",
      recommendedMode: "VIDEO_CALL",
      status: "FOLLOW_UP",
      scheduledAt: "2026-03-23T10:30:00.000Z",
      amountPaid: 399,
      prescription:
        "Take antacid syrup after meals for 5 days. Avoid oily food. Schedule a physical check if pain increases.",
      followUpRequired: true,
      clinicVisit: {
        date: "2026-03-29",
        slot: "11:30 AM"
      }
    },
    {
      id: "CONS-7602",
      patientId: "PAT-20451",
      doctorId: "DOC-1103",
      concern: "Mild skin rash with itching",
      recommendedMode: "AI",
      status: "COMPLETED",
      scheduledAt: "2026-03-19T08:00:00.000Z",
      amountPaid: 0,
      prescription: "Use calamine lotion twice daily and keep the area dry.",
      followUpRequired: false
    }
  ],
  feedback: [
    {
      consultationId: "CONS-7601",
      patientId: "PAT-20451",
      doctorId: "DOC-1101",
      rating: 5,
      note: "Doctor explained the diet plan very clearly in Hindi.",
      createdAt: "2026-03-23T11:20:00.000Z"
    }
  ],
  chat: [
    {
      id: "MSG-1",
      sender: "assistant",
      text:
        "Namaste. I can help with symptom guidance, medication reminders, and deciding whether you need a doctor call or clinic visit.",
      createdAt: "2026-03-26T10:00:00.000Z"
    }
  ],
  applications: []
};
