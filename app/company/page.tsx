import Link from "next/link";
import { Navbar } from "@/components/navbar";
import { Reveal } from "@/components/reveal";

const principles = [
  "AI should reduce friction, not replace clinical responsibility.",
  "Patient trust is earned through clarity, continuity, and care quality.",
  "Operational simplicity matters because great care journeys need reliable systems."
];

export default function CompanyPage() {
  return (
    <main className="shell">
      <Navbar />

      <Reveal as="section" className="subpage-hero panel reveal-scale">
        <p className="eyebrow">Company</p>
        <h1>MedBuddy is building a more responsive layer between people and care.</h1>
        <p className="lede">
          We believe healthcare should feel guided, modern, and coordinated from the first question
          to the final follow-up. That belief shapes the product, the brand, and the company we are
          building.
        </p>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="company-grid">
          <Reveal className="panel company-card reveal-rise" delay={0}>
            <h3>Vision</h3>
            <p>Make personalized healthcare access feel immediate without sacrificing trust.</p>
          </Reveal>
          <Reveal className="panel company-card reveal-rise" delay={100}>
            <h3>Mission</h3>
            <p>
              Build an AI-assisted consultation platform that improves how patients enter, move
              through, and stay connected to care.
            </p>
          </Reveal>
          <Reveal className="panel company-card reveal-rise" delay={200}>
            <h3>Culture</h3>
            <p>
              We care about rigor, empathy, and systems thinking because healthcare deserves more
              than surface-level software.
            </p>
          </Reveal>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="platform-split panel ambient-grid">
          <div>
            <p className="section-tag">Principles</p>
            <h2>The beliefs behind the product.</h2>
          </div>
          <div className="outcome-list">
            {principles.map((principle, index) => (
              <Reveal key={principle} className="reveal-slide" delay={index * 90}>
                <strong>{principle}</strong>
              </Reveal>
            ))}
          </div>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="closing-cta panel ambient-cta">
          <p className="section-tag">Work with us</p>
          <h2>We’re shaping the company as carefully as we’re shaping the product.</h2>
          <div className="action-row">
            <Link href="/careers" className="cta">
              Open careers
            </Link>
            <Link href="/solutions" className="cta secondary-link">
              Revisit solutions
            </Link>
          </div>
        </div>
      </Reveal>
    </main>
  );
}
