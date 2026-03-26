"use client";

import { FormEvent, useEffect, useMemo, useState, useTransition } from "react";
import { readStore, addConsultation, appendChatMessage, submitFeedback, updateConsultation } from "@/lib/storage";
import { ChatMessage, ConsultationRecord, DemoStore, DoctorProfile } from "@/lib/types";

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 8)}`;
}

export function PatientExperience() {
  const [store, setStore] = useState<DemoStore | null>(null);
  const [message, setMessage] = useState("");
  const [selectedDoctor, setSelectedDoctor] = useState<DoctorProfile | null>(null);
  const [feedbackNote, setFeedbackNote] = useState("");
  const [feedbackRating, setFeedbackRating] = useState(5);
  const [isPending, startTransition] = useTransition();

  useEffect(() => {
    setStore(readStore());
  }, []);

  const latestConsultation = useMemo(
    () => store?.consultations[0] ?? null,
    [store]
  );

  if (!store) {
    return <div className="panel">Loading patient workspace...</div>;
  }

  async function handleChatSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!message.trim()) {
      return;
    }

    const patientMessage: ChatMessage = {
      id: createId("MSG"),
      sender: "patient",
      text: message.trim(),
      createdAt: new Date().toISOString()
    };

    appendChatMessage(patientMessage);
    setStore(readStore());
    const prompt = message.trim();
    setMessage("");

    const response = await fetch("/api/chat", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ prompt, language: store.patient.preferredLanguage })
    });

    const data = (await response.json()) as { reply: string };
    appendChatMessage({
      id: createId("MSG"),
      sender: "assistant",
      text: data.reply,
      createdAt: new Date().toISOString()
    });
    setStore(readStore());
  }

  function handleDoctorBooking(doctor: DoctorProfile) {
    startTransition(() => {
      const record: ConsultationRecord = {
        id: createId("CONS"),
        patientId: store.patient.patientId,
        doctorId: doctor.doctorId,
        concern: store.chat.at(-1)?.text ?? "General consultation requested",
        recommendedMode: "VIDEO_CALL",
        status: "QUEUED",
        scheduledAt: new Date().toISOString(),
        amountPaid: doctor.fee,
        followUpRequired: false
      };

      addConsultation(record);
      setSelectedDoctor(doctor);
      setStore(readStore());
    });
  }

  function handleClinicFollowUp() {
    if (!latestConsultation) {
      return;
    }

    updateConsultation({
      ...latestConsultation,
      status: "FOLLOW_UP",
      followUpRequired: true,
      clinicVisit: {
        date: "2026-03-31",
        slot: "12:15 PM"
      }
    });
    setStore(readStore());
  }

  function handleFeedbackSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!latestConsultation || !feedbackNote.trim()) {
      return;
    }

    submitFeedback({
      consultationId: latestConsultation.id,
      patientId: store.patient.patientId,
      doctorId: latestConsultation.doctorId,
      rating: feedbackRating,
      note: feedbackNote.trim(),
      createdAt: new Date().toISOString()
    });
    setFeedbackNote("");
    setFeedbackRating(5);
    setStore(readStore());
  }

  return (
    <div className="workspace-grid">
      <section className="panel hero-panel">
        <p className="eyebrow">Patient side</p>
        <h1>Accessible medical help in the patient&apos;s local language</h1>
        <p className="lede">
          Patients log in once, receive a unique patient ID, and move from AI-guided triage
          to doctor video consultation and clinic follow-up in one flow.
        </p>
        <div className="stat-row">
          <div>
            <strong>{store.patient.patientId}</strong>
            <span>Unique patient ID</span>
          </div>
          <div>
            <strong>{store.patient.preferredLanguage}</strong>
            <span>Preferred language</span>
          </div>
          <div>
            <strong>{store.patient.previousConsultations}</strong>
            <span>Past consultations</span>
          </div>
        </div>
      </section>

      <section className="panel">
        <p className="section-tag">Profile and history</p>
        <div className="detail-list">
          <div>
            <span>Name</span>
            <strong>{store.patient.name}</strong>
          </div>
          <div>
            <span>Demographics</span>
            <strong>
              {store.patient.age} years, {store.patient.sex}, BMI {store.patient.bmi}
            </strong>
          </div>
          <div>
            <span>Medical history</span>
            <strong>{store.patient.medicalHistory.join(", ")}</strong>
          </div>
          <div>
            <span>Reports</span>
            <strong>{store.patient.reports.join(", ")}</strong>
          </div>
        </div>
      </section>

      <section className="panel chat-panel">
        <div className="split-header">
          <div>
            <p className="section-tag">AI medical assistant</p>
            <h2>Chat-first triage before a doctor call</h2>
          </div>
          <span className="status-chip">Safe guidance only</span>
        </div>
        <div className="chat-log">
          {store.chat.map((entry) => (
            <article
              key={entry.id}
              className={entry.sender === "assistant" ? "chat-bubble assistant" : "chat-bubble patient"}
            >
              <span>{entry.sender === "assistant" ? "AI guide" : "Patient"}</span>
              <p>{entry.text}</p>
            </article>
          ))}
        </div>
        <form onSubmit={handleChatSubmit} className="chat-form">
          <input
            value={message}
            onChange={(event) => setMessage(event.target.value)}
            placeholder="Describe the symptoms in English or Hindi"
          />
          <button type="submit">Ask AI</button>
        </form>
      </section>

      <section className="panel">
        <div className="split-header">
          <div>
            <p className="section-tag">Doctor handoff</p>
            <h2>Choose a doctor if AI guidance is not enough</h2>
          </div>
          <span className="status-chip">
            {isPending ? "Booking..." : selectedDoctor ? `Booked ${selectedDoctor.name}` : "Pay before consult"}
          </span>
        </div>
        <div className="card-grid">
          {store.doctors.map((doctor) => (
            <article key={doctor.doctorId} className="doctor-card">
              <div className="doctor-head">
                <div>
                  <h3>{doctor.name}</h3>
                  <p>{doctor.specialty}</p>
                </div>
                <span className={doctor.online ? "online-pill live" : "online-pill offline"}>
                  {doctor.online ? "Online" : "Offline"}
                </span>
              </div>
              <p className="doctor-meta">
                {doctor.languages.join(" / ")} • {doctor.experienceYears} yrs • {doctor.rating} rating
              </p>
              <div className="metric-row">
                <div>
                  <strong>Rs {doctor.fee}</strong>
                  <span>Consultation fee</span>
                </div>
                <div>
                  <strong>{doctor.queueCount}</strong>
                  <span>People in queue</span>
                </div>
              </div>
              <button type="button" disabled={!doctor.online || isPending} onClick={() => handleDoctorBooking(doctor)}>
                Pay and join queue
              </button>
            </article>
          ))}
        </div>
      </section>

      <section className="panel">
        <div className="split-header">
          <div>
            <p className="section-tag">Consultation record</p>
            <h2>Prescription, physical visit, and continuity</h2>
          </div>
          <span className="status-chip">{latestConsultation?.status ?? "No consultation yet"}</span>
        </div>
        {latestConsultation ? (
          <>
            <div className="detail-list">
              <div>
                <span>Concern</span>
                <strong>{latestConsultation.concern}</strong>
              </div>
              <div>
                <span>Mode</span>
                <strong>{latestConsultation.recommendedMode}</strong>
              </div>
              <div>
                <span>Prescription</span>
                <strong>{latestConsultation.prescription ?? "To be issued after consultation"}</strong>
              </div>
              <div>
                <span>Clinic visit</span>
                <strong>
                  {latestConsultation.clinicVisit
                    ? `${latestConsultation.clinicVisit.date} at ${latestConsultation.clinicVisit.slot}`
                    : "Not booked"}
                </strong>
              </div>
            </div>
            <div className="action-row">
              <button type="button" onClick={handleClinicFollowUp}>
                Book physical follow-up
              </button>
            </div>
          </>
        ) : (
          <p className="empty-copy">Consultations booked here will appear with payment, prescription, and follow-up details.</p>
        )}
      </section>

      <section className="panel">
        <p className="section-tag">Feedback loop</p>
        <h2>Rate the doctor after consultation</h2>
        <form onSubmit={handleFeedbackSubmit} className="feedback-form">
          <select value={feedbackRating} onChange={(event) => setFeedbackRating(Number(event.target.value))}>
            {[5, 4, 3, 2, 1].map((rating) => (
              <option key={rating} value={rating}>
                {rating} Star
              </option>
            ))}
          </select>
          <textarea
            value={feedbackNote}
            onChange={(event) => setFeedbackNote(event.target.value)}
            placeholder="Share what worked well in the consultation"
          />
          <button type="submit">Submit feedback</button>
        </form>
      </section>
    </div>
  );
}
