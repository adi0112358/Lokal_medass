import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import { attachPatientAuth, authenticateDoctor, authenticatePatient, hashPassword, issueDoctorToken, issuePatientToken, sanitizeDoctor, sanitizePatient, verifyPassword } from "./src/auth.js";
import { readStore, updateStore, getStorePath } from "./src/store.js";
import { createId, createPatientId, nowIso, titleFromMessage } from "./src/utils.js";

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 8080);
const model = process.env.OPENROUTER_MODEL || "openrouter/free";

if (!process.env.OPENROUTER_API_KEY) {
  console.warn("OPENROUTER_API_KEY is missing. Patient AI chat will not work until it is set.");
}

const emergencyPatterns = [
  /chest pain/i,
  /difficulty breathing/i,
  /shortness of breath/i,
  /heavy bleeding/i,
  /unconscious/i,
  /seizure/i,
  /stroke/i
];

app.use(cors());
app.use(express.json());

function resolvePatient(request, response) {
  const store = readStore();

  if (request.auth?.sub) {
    const patient = store.patients.find((item) => item.patientId === request.auth.sub);
    if (!patient) {
      response.status(404).json({ error: "patient_not_found" });
      return null;
    }
    return { patient, store };
  }

  if (request.body?.patient?.patientId) {
    const patient = store.patients.find(
      (item) => item.patientId === request.body.patient.patientId
    );
    if (patient) {
      return { patient, store };
    }
  }

  response.status(401).json({ error: "patient_context_required" });
  return null;
}

async function generateTriageResponse({ patient, message }) {
  const language = patient?.preferredLanguage || "English";

  if (emergencyPatterns.some((pattern) => pattern.test(message))) {
    return {
      assistantMessage:
        language === "Hindi"
          ? "Yeh emergency ho sakta hai. Kripya turant nearest hospital ya emergency care se sampark kijiye. App consultation ka wait mat kijiye."
          : "This may be an emergency. Please contact the nearest hospital or emergency care immediately instead of waiting for an app consultation.",
      riskLevel: "emergency",
      careMode: "emergency",
      redFlagDetected: true,
      doctorSummary: "Emergency red flags detected in symptom message.",
      followUpQuestions: []
    };
  }

  if (!process.env.OPENROUTER_API_KEY) {
    throw new Error("OPENROUTER_API_KEY is not configured");
  }

  const completionResponse = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "http://localhost:8080",
      "X-Title": "Lokal MedAssist Patient Backend"
    },
    body: JSON.stringify({
      model,
      response_format: {
        type: "json_object"
      },
      messages: [
        {
          role: "system",
          content:
            "You are a medical guidance assistant for patients in tier 2 and tier 3 Indian cities. You are not a doctor. Do not claim diagnosis certainty. Always prioritize patient safety, identify when a doctor or emergency care is needed, keep language simple, and adapt the reply to the patient's preferred language when possible. Return only valid JSON with keys assistantMessage, riskLevel, careMode, redFlagDetected, doctorSummary, followUpQuestions. riskLevel must be one of low, medium, high, emergency. careMode must be one of self_care, doctor_call, physical_visit, emergency. followUpQuestions must be an array of strings."
        },
        {
          role: "user",
          content: JSON.stringify({
            patient,
            message
          })
        }
      ]
    })
  });

  const completionJson = await completionResponse.json();
  const rawContent = completionJson?.choices?.[0]?.message?.content;

  if (!completionResponse.ok || !rawContent) {
    console.error("OpenRouter chat failed", completionJson);
    throw new Error("patient_chat_failed");
  }

  return JSON.parse(rawContent);
}

app.get("/health", (_request, response) => {
  response.json({
    status: "ok",
    service: "patient-backend",
    model,
    storePath: getStorePath(),
    date: nowIso()
  });
});

app.post("/api/patient/auth/register", (request, response) => {
  const {
    name,
    email,
    password,
    age,
    sex,
    bmi,
    city,
    preferredLanguage = "English"
  } = request.body ?? {};

  if (!name || !email || !password || !age || !sex || !city) {
    return response.status(400).json({ error: "missing_required_fields" });
  }

  const normalizedEmail = String(email).trim().toLowerCase();
  const nextStore = updateStore((store) => {
    if (store.patients.some((patient) => patient.email === normalizedEmail)) {
      throw new Error("patient_email_exists");
    }

    const patientId = createPatientId(store.patients);
    const patient = {
      patientId,
      name: String(name).trim(),
      email: normalizedEmail,
      passwordHash: hashPassword(String(password)),
      age: Number(age),
      sex: String(sex),
      bmi: bmi ? Number(bmi) : 0,
      city: String(city).trim(),
      preferredLanguage: String(preferredLanguage),
      medicalHistory: [],
      reports: [],
      previousConsultations: 0,
      createdAt: nowIso()
    };

    return {
      ...store,
      patients: [...store.patients, patient]
    };
  });

  const patient = nextStore.patients.find((item) => item.email === normalizedEmail);
  const token = issuePatientToken(patient);

  return response.status(201).json({
    token,
    patient: sanitizePatient(patient)
  });
});

app.post("/api/patient/auth/login", (request, response) => {
  const { email, password } = request.body ?? {};
  if (!email || !password) {
    return response.status(400).json({ error: "missing_credentials" });
  }

  const store = readStore();
  const patient = store.patients.find(
    (item) => item.email === String(email).trim().toLowerCase()
  );

  if (!patient || !verifyPassword(String(password), patient.passwordHash)) {
    return response.status(401).json({ error: "invalid_credentials" });
  }

  return response.json({
    token: issuePatientToken(patient),
    patient: sanitizePatient(patient)
  });
});

app.post("/api/doctor/auth/login", (request, response) => {
  const { email, password } = request.body ?? {};
  if (!email || !password) {
    return response.status(400).json({ error: "missing_credentials" });
  }

  const store = readStore();
  const doctor = store.doctors.find(
    (item) => item.email === String(email).trim().toLowerCase()
  );

  if (!doctor || !verifyPassword(String(password), doctor.passwordHash)) {
    return response.status(401).json({ error: "invalid_credentials" });
  }

  return response.json({
    token: issueDoctorToken(doctor),
    doctor: sanitizeDoctor(doctor)
  });
});

app.get("/api/doctor/me", authenticateDoctor, (request, response) => {
  const store = readStore();
  const doctor = store.doctors.find((item) => item.doctorId === request.auth.sub);
  if (!doctor) {
    return response.status(404).json({ error: "doctor_not_found" });
  }

  return response.json({
    doctor: sanitizeDoctor(doctor)
  });
});

app.get("/api/patient/me", authenticatePatient, (request, response) => {
  const store = readStore();
  const patient = store.patients.find((item) => item.patientId === request.auth.sub);
  if (!patient) {
    return response.status(404).json({ error: "patient_not_found" });
  }

  return response.json({
    patient: sanitizePatient(patient)
  });
});

app.get("/api/patient/chats", authenticatePatient, (request, response) => {
  const store = readStore();
  const conversations = store.conversations
    .filter((item) => item.patientId === request.auth.sub)
    .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt));

  return response.json({ conversations });
});

app.get("/api/patient/chats/:conversationId", authenticatePatient, (request, response) => {
  const store = readStore();
  const conversation = store.conversations.find(
    (item) =>
      item.conversationId === request.params.conversationId &&
      item.patientId === request.auth.sub
  );

  if (!conversation) {
    return response.status(404).json({ error: "conversation_not_found" });
  }

  return response.json({ conversation });
});

app.post("/api/patient/chat", attachPatientAuth, async (request, response) => {
  const { message, conversationId } = request.body ?? {};
  if (!message || typeof message !== "string") {
    return response.status(400).json({ error: "message_is_required" });
  }

  const resolved = resolvePatient(request, response);
  if (!resolved) {
    return;
  }

  const normalizedMessage = message.trim();

  try {
    const triage = await generateTriageResponse({
      patient: resolved.patient,
      message: normalizedMessage
    });

    const patientConversationId = conversationId || createId("CHAT");
    const updatedStore = updateStore((store) => {
      const patientMessage = {
        id: createId("MSG"),
        sender: "patient",
        text: normalizedMessage,
        createdAt: nowIso()
      };
      const assistantMessage = {
        id: createId("MSG"),
        sender: "assistant",
        text: triage.assistantMessage,
        createdAt: nowIso(),
        triage
      };

      const existingConversation = store.conversations.find(
        (item) =>
          item.conversationId === patientConversationId &&
          item.patientId === resolved.patient.patientId
      );

      let conversations;
      if (existingConversation) {
        conversations = store.conversations.map((item) =>
          item.conversationId === patientConversationId
            ? {
                ...item,
                updatedAt: nowIso(),
                messages: [...item.messages, patientMessage, assistantMessage]
              }
            : item
        );
      } else {
        conversations = [
          ...store.conversations,
          {
            conversationId: patientConversationId,
            patientId: resolved.patient.patientId,
            title: titleFromMessage(normalizedMessage),
            createdAt: nowIso(),
            updatedAt: nowIso(),
            messages: [patientMessage, assistantMessage]
          }
        ];
      }

      return {
        ...store,
        conversations
      };
    });

    const conversation = updatedStore.conversations.find(
      (item) =>
        item.patientId === resolved.patient.patientId &&
        item.messages.some((entry) => entry.text === normalizedMessage)
    );

    return response.json({
      conversationId: patientConversationId,
      ...triage
    });
  } catch (error) {
    console.error("Patient chat failed", error);
    return response.status(500).json({ error: "patient_chat_failed" });
  }
});

app.get("/api/doctors", (_request, response) => {
  const store = readStore();
  return response.json({
    doctors: store.doctors
  });
});

app.get("/api/doctors/:doctorId", (_request, response) => {
  const store = readStore();
  const doctor = store.doctors.find((item) => item.doctorId === request.params.doctorId);
  if (!doctor) {
    return response.status(404).json({ error: "doctor_not_found" });
  }

  return response.json({ doctor });
});

app.get("/api/doctor/queue", authenticateDoctor, (request, response) => {
  const store = readStore();
  const consultations = store.consultations
    .filter(
      (item) =>
        item.doctorId === request.auth.sub &&
        (item.status === "QUEUED" || item.status === "IN_CALL" || item.status === "FOLLOW_UP")
    )
    .sort((left, right) => right.createdAt.localeCompare(left.createdAt));

  return response.json({ consultations });
});

app.post("/api/doctor/availability", authenticateDoctor, (request, response) => {
  const { online } = request.body ?? {};
  if (typeof online !== "boolean") {
    return response.status(400).json({ error: "online_boolean_required" });
  }

  const updatedStore = updateStore((store) => ({
    ...store,
    doctors: store.doctors.map((item) =>
      item.doctorId === request.auth.sub ? { ...item, online } : item
    )
  }));

  const doctor = updatedStore.doctors.find((item) => item.doctorId === request.auth.sub);
  return response.json({ doctor: sanitizeDoctor(doctor) });
});

app.post("/api/doctor/consultations/:consultationId/start", authenticateDoctor, (request, response) => {
  const consultationId = request.params.consultationId;

  const updatedStore = updateStore((store) => ({
    ...store,
    consultations: store.consultations.map((item) =>
      item.consultationId === consultationId && item.doctorId === request.auth.sub
        ? { ...item, status: "IN_CALL" }
        : item
    ),
    doctors: store.doctors.map((item) =>
      item.doctorId === request.auth.sub
        ? { ...item, queueCount: item.queueCount > 0 ? item.queueCount - 1 : 0 }
        : item
    )
  }));

  const consultation = updatedStore.consultations.find(
    (item) => item.consultationId === consultationId && item.doctorId === request.auth.sub
  );

  if (!consultation) {
    return response.status(404).json({ error: "consultation_not_found" });
  }

  return response.json({ consultation });
});

app.post("/api/doctor/consultations/:consultationId/request-visit", authenticateDoctor, (request, response) => {
  const consultationId = request.params.consultationId;

  const updatedStore = updateStore((store) => ({
    ...store,
    consultations: store.consultations.map((item) =>
      item.consultationId === consultationId && item.doctorId === request.auth.sub
        ? { ...item, status: "FOLLOW_UP", followUpRequired: true }
        : item
    )
  }));

  const consultation = updatedStore.consultations.find(
    (item) => item.consultationId === consultationId && item.doctorId === request.auth.sub
  );

  if (!consultation) {
    return response.status(404).json({ error: "consultation_not_found" });
  }

  return response.json({ consultation });
});

app.post("/api/doctor/consultations/:consultationId/complete", authenticateDoctor, (request, response) => {
  const consultationId = request.params.consultationId;
  const { prescription } = request.body ?? {};
  if (!prescription || typeof prescription !== "string") {
    return response.status(400).json({ error: "prescription_required" });
  }

  const updatedStore = updateStore((store) => {
    const consultation = store.consultations.find(
      (item) => item.consultationId === consultationId && item.doctorId === request.auth.sub
    );

    if (!consultation) {
      throw new Error("consultation_not_found");
    }

    const prescriptionId = consultation.prescriptionId || createId("RX");
    const prescriptionRecord = {
      prescriptionId,
      consultationId,
      patientId: consultation.patientId,
      doctorId: request.auth.sub,
      medicines: [
        {
          name: "Doctor note",
          dosage: prescription,
          frequency: "As advised",
          duration: "Per prescription"
        }
      ],
      advice: prescription,
      createdAt: nowIso()
    };

    const existingPrescription = store.prescriptions.find(
      (item) => item.prescriptionId === prescriptionId
    );

    return {
      ...store,
      consultations: store.consultations.map((item) =>
        item.consultationId === consultationId
          ? {
              ...item,
              status: "COMPLETED",
              prescriptionId
            }
          : item
      ),
      prescriptions: existingPrescription
        ? store.prescriptions.map((item) =>
            item.prescriptionId === prescriptionId ? prescriptionRecord : item
          )
        : [prescriptionRecord, ...store.prescriptions],
      doctors: store.doctors.map((item) =>
        item.doctorId === request.auth.sub
          ? {
              ...item,
              consultationsCompleted: item.consultationsCompleted + 1,
              patientsAttended: item.patientsAttended + 1,
              prescriptionsIssued: item.prescriptionsIssued + 1
            }
          : item
      )
    };
  });

  const consultation = updatedStore.consultations.find(
    (item) => item.consultationId === consultationId && item.doctorId === request.auth.sub
  );
  const prescriptionRecord = updatedStore.prescriptions.find(
    (item) => item.consultationId === consultationId && item.doctorId === request.auth.sub
  );

  return response.json({
    consultation,
    prescription: prescriptionRecord
  });
});

app.get("/api/doctor/wallet", authenticateDoctor, (request, response) => {
  const store = readStore();
  const doctor = store.doctors.find((item) => item.doctorId === request.auth.sub);
  if (!doctor) {
    return response.status(404).json({ error: "doctor_not_found" });
  }

  return response.json({
    walletBalance: doctor.walletBalance,
    nextPayoutEligible: doctor.nextPayoutEligible
  });
});

app.get("/api/patient/bookings", authenticatePatient, (request, response) => {
  const store = readStore();
  const consultations = store.consultations.filter(
    (item) => item.patientId === request.auth.sub
  );

  return response.json({ consultations });
});

app.post("/api/patient/bookings", authenticatePatient, (request, response) => {
  const { doctorId, concern, recommendedMode = "VIDEO_CALL" } = request.body ?? {};
  if (!doctorId || !concern) {
    return response.status(400).json({ error: "doctorId_and_concern_required" });
  }

  const updatedStore = updateStore((store) => {
    const doctor = store.doctors.find((item) => item.doctorId === doctorId);
    if (!doctor) {
      throw new Error("doctor_not_found");
    }

    const consultation = {
      consultationId: createId("CONS"),
      patientId: request.auth.sub,
      doctorId,
      concern: String(concern).trim(),
      recommendedMode,
      status: "QUEUED",
      scheduledAt: nowIso(),
      amountPaid: doctor.fee,
      prescriptionId: null,
      appointmentId: null,
      followUpRequired: false,
      createdAt: nowIso()
    };

    return {
      ...store,
      consultations: [consultation, ...store.consultations],
      doctors: store.doctors.map((item) =>
        item.doctorId === doctorId
          ? {
              ...item,
              queueCount: item.queueCount + 1,
              walletBalance: item.walletBalance + item.fee,
              nextPayoutEligible: item.nextPayoutEligible + item.fee
            }
          : item
      )
    };
  });

  const consultation = updatedStore.consultations[0];
  return response.status(201).json({ consultation });
});

app.get("/api/patient/appointments", authenticatePatient, (request, response) => {
  const store = readStore();
  const appointments = store.appointments.filter(
    (item) => item.patientId === request.auth.sub
  );
  return response.json({ appointments });
});

app.post("/api/patient/appointments", authenticatePatient, (request, response) => {
  const { consultationId, doctorId, date, slot, clinicName } = request.body ?? {};
  if (!consultationId || !doctorId || !date || !slot || !clinicName) {
    return response.status(400).json({ error: "missing_appointment_fields" });
  }

  const updatedStore = updateStore((store) => {
    const consultation = store.consultations.find(
      (item) =>
        item.consultationId === consultationId &&
        item.patientId === request.auth.sub
    );

    if (!consultation) {
      throw new Error("consultation_not_found");
    }

    const appointmentId = createId("APT");
    const appointment = {
      appointmentId,
      consultationId,
      patientId: request.auth.sub,
      doctorId,
      date,
      slot,
      clinicName,
      status: "BOOKED",
      createdAt: nowIso()
    };

    return {
      ...store,
      appointments: [appointment, ...store.appointments],
      consultations: store.consultations.map((item) =>
        item.consultationId === consultationId
          ? {
              ...item,
              appointmentId,
              followUpRequired: true,
              status: "FOLLOW_UP"
            }
          : item
      )
    };
  });

  return response.status(201).json({ appointment: updatedStore.appointments[0] });
});

app.get("/api/patient/prescriptions", authenticatePatient, (request, response) => {
  const store = readStore();
  const prescriptions = store.prescriptions.filter(
    (item) => item.patientId === request.auth.sub
  );
  return response.json({ prescriptions });
});

app.get("/api/patient/prescriptions/:prescriptionId", authenticatePatient, (request, response) => {
  const store = readStore();
  const prescription = store.prescriptions.find(
    (item) =>
      item.prescriptionId === request.params.prescriptionId &&
      item.patientId === request.auth.sub
  );

  if (!prescription) {
    return response.status(404).json({ error: "prescription_not_found" });
  }

  return response.json({ prescription });
});

app.get("/api/patient/feedback", authenticatePatient, (request, response) => {
  const store = readStore();
  const feedback = store.feedback.filter((item) => item.patientId === request.auth.sub);
  return response.json({ feedback });
});

app.post("/api/patient/feedback", authenticatePatient, (request, response) => {
  const { consultationId, doctorId, rating, note } = request.body ?? {};
  if (!consultationId || !doctorId || !rating || !note) {
    return response.status(400).json({ error: "missing_feedback_fields" });
  }

  const updatedStore = updateStore((store) => {
    const feedbackRecord = {
      feedbackId: createId("FDB"),
      consultationId,
      patientId: request.auth.sub,
      doctorId,
      rating: Number(rating),
      note: String(note).trim(),
      createdAt: nowIso()
    };

    const doctorFeedback = [
      ...store.feedback.filter((item) => item.doctorId === doctorId),
      feedbackRecord
    ];
    const averageRating =
      doctorFeedback.reduce((sum, item) => sum + item.rating, 0) / doctorFeedback.length;

    return {
      ...store,
      feedback: [feedbackRecord, ...store.feedback],
      doctors: store.doctors.map((item) =>
        item.doctorId === doctorId
          ? { ...item, rating: Number(averageRating.toFixed(1)) }
          : item
      )
    };
  });

  return response.status(201).json({
    feedback: updatedStore.feedback[0]
  });
});

app.get("/api/doctor/feedback", authenticateDoctor, (request, response) => {
  const store = readStore();
  const feedback = store.feedback.filter((item) => item.doctorId === request.auth.sub);
  return response.json({ feedback });
});

app.use((error, _request, response, _next) => {
  if (error?.message === "patient_email_exists") {
    return response.status(409).json({ error: "patient_email_exists" });
  }
  if (error?.message === "doctor_not_found") {
    return response.status(404).json({ error: "doctor_not_found" });
  }
  if (error?.message === "consultation_not_found") {
    return response.status(404).json({ error: "consultation_not_found" });
  }

  console.error("Unhandled backend error", error);
  return response.status(500).json({ error: "internal_server_error" });
});

app.listen(port, () => {
  console.log(`Patient backend listening on http://localhost:${port}`);
});
