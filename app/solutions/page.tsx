import Link from "next/link";
import { Navbar } from "@/components/navbar";
import { Reveal } from "@/components/reveal";

const solutions = [
  {
    title: "AI-guided intake",
    body:
      "Capture concerns in everyday language, structure the conversation, and prepare patients for the next right step."
  },
  {
    title: "Consultation orchestration",
    body:
      "Route people to the right clinician or care pathway with better context and lower administrative overhead."
  },
  {
    title: "Continuity after the appointment",
    body:
      "Support medication adherence, follow-up planning, reminders, and post-visit engagement from a unified layer."
  }
];

export default function SolutionsPage() {
  return (
    <main className="shell">
      <Navbar />

      <Reveal as="section" className="subpage-hero panel reveal-scale">
        <p className="eyebrow">Solutions</p>
        <h1>Three layers that turn medical access into a better operating system.</h1>
        <p className="lede">
          MedBuddy is designed to improve the moments before, during, and after care. Each solution
          fits together so the patient experience does not fracture between tools and teams.
        </p>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="solution-grid">
          {solutions.map((solution, index) => (
            <Reveal key={solution.title} className="panel solution-card reveal-rise" delay={index * 100}>
              <h3>{solution.title}</h3>
              <p>{solution.body}</p>
            </Reveal>
          ))}
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="platform-split panel ambient-grid">
          <div>
            <p className="section-tag">Who it is for</p>
            <h2>Flexible enough for startups. Structured enough for clinical teams.</h2>
          </div>
          <div className="outcome-list">
            <Reveal className="reveal-slide" delay={0}>
              <strong>Digital clinics</strong>
              <p>Improve intake quality and reduce repetitive triage work.</p>
            </Reveal>
            <Reveal className="reveal-slide" delay={90}>
              <strong>Multi-doctor practices</strong>
              <p>Create more consistent handoffs and follow-up systems.</p>
            </Reveal>
            <Reveal className="reveal-slide" delay={180}>
              <strong>Emerging health platforms</strong>
              <p>Launch a care journey that feels intelligent from day one.</p>
            </Reveal>
          </div>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="closing-cta panel ambient-cta">
          <p className="section-tag">See the company vision</p>
          <h2>Solutions are only useful when they fit a larger healthcare philosophy.</h2>
          <div className="action-row">
            <Link href="/company" className="cta">
              Visit company page
            </Link>
            <Link href="/careers" className="cta secondary-link">
              Meet the team we want to build
            </Link>
          </div>
        </div>
      </Reveal>
    </main>
  );
}
