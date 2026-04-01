"use client";

import { demoStore } from "@/lib/mock-data";
import {
  ChatMessage,
  ConsultationRecord,
  DemoStore,
  DoctorProfile,
  Feedback,
  JobApplication
} from "@/lib/types";

const STORAGE_KEY = "lokal-medassist-demo-store";

function canUseStorage() {
  return typeof window !== "undefined";
}

function normalizeStore(input: Partial<DemoStore> | null | undefined): DemoStore {
  return {
    ...demoStore,
    ...input,
    patient: input?.patient ?? demoStore.patient,
    doctors: Array.isArray(input?.doctors) ? input.doctors : demoStore.doctors,
    consultations: Array.isArray(input?.consultations) ? input.consultations : demoStore.consultations,
    feedback: Array.isArray(input?.feedback) ? input.feedback : demoStore.feedback,
    chat: Array.isArray(input?.chat) ? input.chat : demoStore.chat,
    applications: Array.isArray(input?.applications) ? input.applications : []
  };
}

export function readStore(): DemoStore {
  if (!canUseStorage()) {
    return demoStore;
  }

  const raw = window.localStorage.getItem(STORAGE_KEY);
  if (!raw) {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(demoStore));
    return demoStore;
  }

  try {
    const parsed = JSON.parse(raw) as Partial<DemoStore>;
    const normalized = normalizeStore(parsed);
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(normalized));
    return normalized;
  } catch {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(demoStore));
    return demoStore;
  }
}

export function writeStore(store: DemoStore) {
  if (!canUseStorage()) {
    return;
  }

  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
}

export function appendChatMessage(message: ChatMessage) {
  const store = readStore();
  writeStore({
    ...store,
    chat: [...store.chat, message]
  });
}

export function addConsultation(record: ConsultationRecord) {
  const store = readStore();
  const doctors = store.doctors.map((doctor) =>
    doctor.doctorId === record.doctorId
      ? {
          ...doctor,
          queueCount: doctor.queueCount + 1,
          walletBalance: doctor.walletBalance + record.amountPaid,
          nextPayoutEligible: doctor.nextPayoutEligible + record.amountPaid
        }
      : doctor
  );

  writeStore({
    ...store,
    doctors,
    consultations: [record, ...store.consultations]
  });
}

export function submitFeedback(feedback: Feedback) {
  const store = readStore();
  const doctorFeedback = [...store.feedback.filter((item) => item.doctorId === feedback.doctorId), feedback];
  const updatedRating =
    doctorFeedback.reduce((sum, item) => sum + item.rating, 0) / doctorFeedback.length;

  const doctors = store.doctors.map((doctor) =>
    doctor.doctorId === feedback.doctorId
      ? { ...doctor, rating: Number(updatedRating.toFixed(1)) }
      : doctor
  );

  writeStore({
    ...store,
    doctors,
    feedback: [feedback, ...store.feedback]
  });
}

export function updateConsultation(updated: ConsultationRecord) {
  const store = readStore();
  const previous = store.consultations.find((item) => item.id === updated.id);

  const doctors = store.doctors.map((doctor) => {
    if (doctor.doctorId !== updated.doctorId) {
      return doctor;
    }

    const queueDelta =
      previous && previous.status === "QUEUED" && updated.status !== "QUEUED" ? -1 : 0;
    const completionDelta = updated.status === "COMPLETED" && previous?.status !== "COMPLETED" ? 1 : 0;
    const prescriptionDelta = updated.prescription && !previous?.prescription ? 1 : 0;
    return {
      ...doctor,
      queueCount: Math.max(0, doctor.queueCount + queueDelta),
      consultationsCompleted: doctor.consultationsCompleted + completionDelta,
      patientsAttended: doctor.patientsAttended + completionDelta,
      prescriptionsIssued: doctor.prescriptionsIssued + prescriptionDelta
    };
  });

  writeStore({
    ...store,
    doctors,
    consultations: store.consultations.map((item) => (item.id === updated.id ? updated : item))
  });
}

export function updateDoctorProfile(updatedDoctor: DoctorProfile) {
  const store = readStore();
  writeStore({
    ...store,
    doctors: store.doctors.map((doctor) =>
      doctor.doctorId === updatedDoctor.doctorId ? updatedDoctor : doctor
    )
  });
}

export function submitJobApplication(application: JobApplication) {
  const store = readStore();
  writeStore({
    ...store,
    applications: [application, ...store.applications]
  });
}

export function readJobApplications() {
  return readStore().applications;
}
