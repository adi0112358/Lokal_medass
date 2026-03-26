import crypto from "crypto";

export function createId(prefix) {
  return `${prefix}-${crypto.randomBytes(4).toString("hex")}`;
}

export function createPatientId(existingPatients) {
  let nextId = "";
  do {
    nextId = `PAT-${Math.floor(10000 + Math.random() * 90000)}`;
  } while (existingPatients.some((patient) => patient.patientId === nextId));
  return nextId;
}

export function nowIso() {
  return new Date().toISOString();
}

export function titleFromMessage(message) {
  const trimmed = message.trim();
  return trimmed.length > 36 ? `${trimmed.slice(0, 36)}...` : trimmed;
}
