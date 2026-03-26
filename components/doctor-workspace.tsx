"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { readStore, updateConsultation, updateDoctorProfile } from "@/lib/storage";
import { ConsultationRecord, DemoStore, DoctorProfile } from "@/lib/types";

const ACTIVE_DOCTOR_ID = "DOC-1101";

export function DoctorWorkspace() {
  const [store, setStore] = useState<DemoStore | null>(null);
  const [selectedConsultation, setSelectedConsultation] = useState<ConsultationRecord | null>(null);
  const [prescription, setPrescription] = useState("");

  useEffect(() => {
    setStore(readStore());
  }, []);

  const doctor = useMemo(
    () => store?.doctors.find((entry) => entry.doctorId === ACTIVE_DOCTOR_ID) ?? null,
    [store]
  );

  const queue = useMemo(
    () =>
      store?.consultations.filter(
        (entry) =>
          entry.doctorId === ACTIVE_DOCTOR_ID &&
          (entry.status === "QUEUED" || entry.status === "IN_CALL" || entry.status === "FOLLOW_UP")
      ) ?? [],
    [store]
  );

  if (!store || !doctor) {
    return <div className="panel">Loading doctor workspace...</div>;
  }

  function toggleAvailability() {
    const updatedDoctor: DoctorProfile = {
      ...doctor,
      online: !doctor.online
    };
    updateDoctorProfile(updatedDoctor);
    setStore(readStore());
  }

  function startConsultation(record: ConsultationRecord) {
    updateConsultation({
      ...record,
      status: "IN_CALL"
    });
    setSelectedConsultation({
      ...record,
      status: "IN_CALL"
    });
    setPrescription(record.prescription ?? "");
    setStore(readStore());
  }

  function completeConsultation(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!selectedConsultation) {
      return;
    }

    updateConsultation({
      ...selectedConsultation,
      status: "COMPLETED",
      prescription,
      followUpRequired: selectedConsultation.followUpRequired
    });
    setSelectedConsultation(null);
    setPrescription("");
    setStore(readStore());
  }

  function requestClinicVisit(record: ConsultationRecord) {
    updateConsultation({
      ...record,
      status: "FOLLOW_UP",
      followUpRequired: true,
      prescription: record.prescription ?? "Physical examination advised before further medication.",
      clinicVisit: {
        date: "2026-03-31",
        slot: "04:00 PM"
      }
    });
    setStore(readStore());
  }

  return (
    <div className="workspace-grid">
      <section className="panel hero-panel">
        <p className="eyebrow">Doctor side</p>
        <h1>Queue, consultations, prescriptions, and wallet in one workspace</h1>
        <p className="lede">
          Doctors get one-by-one patient requests, time-bound consultations, e-prescription support,
          and wallet payouts directly into their bank account.
        </p>
        <div className="stat-row">
          <div>
            <strong>{doctor.doctorId}</strong>
            <span>Doctor ID</span>
          </div>
          <div>
            <strong>{doctor.rating}</strong>
            <span>Live rating</span>
          </div>
          <div>
            <strong>{doctor.queueCount}</strong>
            <span>Queue size</span>
          </div>
        </div>
      </section>

      <section className="panel">
        <div className="split-header">
          <div>
            <p className="section-tag">Availability</p>
            <h2>Consultation readiness</h2>
          </div>
          <span className={doctor.online ? "online-pill live" : "online-pill offline"}>
            {doctor.online ? "Accepting requests" : "Offline"}
          </span>
        </div>
        <div className="detail-list">
          <div>
            <span>Name and specialty</span>
            <strong>
              {doctor.name} • {doctor.specialty}
            </strong>
          </div>
          <div>
            <span>Languages</span>
            <strong>{doctor.languages.join(", ")}</strong>
          </div>
          <div>
            <span>Consultation fee</span>
            <strong>Rs {doctor.fee}</strong>
          </div>
        </div>
        <div className="action-row">
          <button type="button" onClick={toggleAvailability}>
            {doctor.online ? "Go offline" : "Go online"}
          </button>
        </div>
      </section>

      <section className="panel">
        <p className="section-tag">Patient traffic management</p>
        <h2>Attend requests one by one</h2>
        <div className="card-grid">
          {queue.length > 0 ? (
            queue.map((record) => (
              <article key={record.id} className="doctor-card">
                <h3>{record.id}</h3>
                <p>{record.concern}</p>
                <div className="metric-row">
                  <div>
                    <strong>{record.status}</strong>
                    <span>Status</span>
                  </div>
                  <div>
                    <strong>Rs {record.amountPaid}</strong>
                    <span>Paid amount</span>
                  </div>
                </div>
                <div className="dual-actions">
                  <button type="button" onClick={() => startConsultation(record)}>
                    Start call
                  </button>
                  <button type="button" className="secondary" onClick={() => requestClinicVisit(record)}>
                    Request visit
                  </button>
                </div>
              </article>
            ))
          ) : (
            <p className="empty-copy">No active queue right now. Patient requests will appear here in order.</p>
          )}
        </div>
      </section>

      <section className="panel">
        <p className="section-tag">E-prescription desk</p>
        <h2>Generate prescription after call</h2>
        <form onSubmit={completeConsultation} className="feedback-form">
          <textarea
            value={prescription}
            onChange={(event) => setPrescription(event.target.value)}
            placeholder="Write dosage, precautions, and follow-up instructions"
          />
          <button type="submit" disabled={!selectedConsultation}>
            Complete consultation
          </button>
        </form>
      </section>

      <section className="panel">
        <p className="section-tag">Doctor metadata and wallet</p>
        <div className="detail-list">
          <div>
            <span>Consultations completed</span>
            <strong>{doctor.consultationsCompleted}</strong>
          </div>
          <div>
            <span>Patients attended</span>
            <strong>{doctor.patientsAttended}</strong>
          </div>
          <div>
            <span>Prescriptions issued</span>
            <strong>{doctor.prescriptionsIssued}</strong>
          </div>
          <div>
            <span>Wallet balance</span>
            <strong>Rs {doctor.walletBalance}</strong>
          </div>
          <div>
            <span>Ready for bank transfer</span>
            <strong>Rs {doctor.nextPayoutEligible}</strong>
          </div>
        </div>
      </section>
    </div>
  );
}
