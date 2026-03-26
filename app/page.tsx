import Link from "next/link";
import { Navbar } from "@/components/navbar";

const highlights = [
  "AI-first symptom guidance in local language",
  "Doctor discovery with ratings and live status",
  "Pay-before-consult video calls and queue management",
  "Follow-up booking for physical clinic visits",
  "Prescription generation, history, and feedback loop",
  "Doctor wallet and payout visibility"
];

export default function HomePage() {
  return (
    <main className="shell">
      <Navbar />
      <section className="landing">
        <div className="landing-copy">
          <p className="eyebrow">Proposal for Lokal</p>
          <h1>Medical assistance built for tier 2 and tier 3 cities</h1>
          <p className="lede">
            This proposal demonstrates how Lokal can add a healthcare layer that reduces hospital
            crowding, shortens consultation delays, and improves access through AI guidance plus
            doctor video consultations.
          </p>
          <div className="action-row">
            <Link href="/patient" className="cta">
              Open patient journey
            </Link>
            <Link href="/doctor" className="cta secondary-link">
              Open doctor workspace
            </Link>
          </div>
        </div>
        <div className="proposal-card">
          <p className="section-tag">Core platform capabilities</p>
          <ul>
            {highlights.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </div>
      </section>

      <section className="problem-grid">
        <article className="panel">
          <p className="section-tag">Problem</p>
          <h2>Centralized hospitals, fixed doctor hours, delayed consultations</h2>
          <p>
            In smaller cities, many cases need guidance and timely consultation rather than emergency
            intervention. Physical visits consume time for both patients and doctors, creating
            queues that reduce efficiency.
          </p>
        </article>
        <article className="panel">
          <p className="section-tag">Solution</p>
          <h2>Lokal as a regional health access layer</h2>
          <p>
            Patients begin with AI-driven triage and move to a doctor only when needed. Doctors
            receive structured patient metadata, shorter diagnosis time, clearer queueing, and
            digital prescriptions with payment already collected.
          </p>
        </article>
      </section>
    </main>
  );
}
