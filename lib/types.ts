export type Language = "English" | "Hindi" | "Marathi";

export type PatientProfile = {
  patientId: string;
  name: string;
  age: number;
  sex: "Male" | "Female" | "Other";
  bmi: number;
  city: string;
  preferredLanguage: Language;
  medicalHistory: string[];
  reports: string[];
  previousConsultations: number;
};

export type Feedback = {
  consultationId: string;
  patientId: string;
  doctorId: string;
  rating: number;
  note: string;
  createdAt: string;
};

export type DoctorProfile = {
  doctorId: string;
  name: string;
  specialty: string;
  languages: Language[];
  experienceYears: number;
  fee: number;
  rating: number;
  online: boolean;
  queueCount: number;
  consultationsCompleted: number;
  patientsAttended: number;
  prescriptionsIssued: number;
  walletBalance: number;
  nextPayoutEligible: number;
};

export type ConsultationStatus =
  | "AI_GUIDED"
  | "AWAITING_PAYMENT"
  | "QUEUED"
  | "IN_CALL"
  | "FOLLOW_UP"
  | "COMPLETED";

export type ConsultationRecord = {
  id: string;
  patientId: string;
  doctorId: string;
  concern: string;
  recommendedMode: "AI" | "VIDEO_CALL" | "PHYSICAL_VISIT";
  status: ConsultationStatus;
  scheduledAt: string;
  amountPaid: number;
  prescription?: string;
  followUpRequired: boolean;
  clinicVisit?: {
    date: string;
    slot: string;
  };
};

export type ChatMessage = {
  id: string;
  sender: "patient" | "assistant";
  text: string;
  createdAt: string;
};

export type JobApplication = {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  team: string;
  location: string;
  portfolio?: string;
  experienceLevel: "0-2 years" | "3-5 years" | "6-9 years" | "10+ years";
  coverNote: string;
  createdAt: string;
};

export type DemoStore = {
  patient: PatientProfile;
  doctors: DoctorProfile[];
  consultations: ConsultationRecord[];
  feedback: Feedback[];
  chat: ChatMessage[];
  applications: JobApplication[];
};
