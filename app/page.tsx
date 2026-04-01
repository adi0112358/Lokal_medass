import Link from "next/link";
import { Navbar } from "@/components/navbar";
import { Reveal } from "@/components/reveal";

function LinkedInIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M6.94 8.5V19H3.52V8.5h3.42ZM5.23 3C6.4 3 7.35 3.95 7.35 5.12A2.12 2.12 0 0 1 5.23 7.23 2.11 2.11 0 0 1 3.12 5.12C3.12 3.95 4.07 3 5.23 3Zm5.51 5.5h3.28v1.44h.05c.46-.86 1.58-1.77 3.25-1.77 3.48 0 4.12 2.29 4.12 5.27V19h-3.42v-4.93c0-1.18-.02-2.69-1.64-2.69-1.64 0-1.89 1.28-1.89 2.6V19h-3.75V8.5Z" />
    </svg>
  );
}

function InstagramIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M7.5 3h9A4.5 4.5 0 0 1 21 7.5v9a4.5 4.5 0 0 1-4.5 4.5h-9A4.5 4.5 0 0 1 3 16.5v-9A4.5 4.5 0 0 1 7.5 3Zm0 1.8A2.7 2.7 0 0 0 4.8 7.5v9a2.7 2.7 0 0 0 2.7 2.7h9a2.7 2.7 0 0 0 2.7-2.7v-9a2.7 2.7 0 0 0-2.7-2.7h-9Zm9.55 1.35a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2ZM12 7.5A4.5 4.5 0 1 1 7.5 12 4.5 4.5 0 0 1 12 7.5Zm0 1.8A2.7 2.7 0 1 0 14.7 12 2.7 2.7 0 0 0 12 9.3Z" />
    </svg>
  );
}

function MailIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M4 5h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Zm0 2v.2l8 5.33 8-5.33V7H4Zm16 10V9.6l-7.45 4.97a1 1 0 0 1-1.1 0L4 9.6V17h16Z" />
    </svg>
  );
}

const outcomes = [
  "Reduce intake friction with AI-guided first contact",
  "Help clinicians start from structured patient context",
  "Extend care beyond the appointment with follow-through tools"
];

const solutionCards = [
  {
    label: "Patients",
    title: "A calmer front door to care",
    body:
      "Patients describe concerns in plain language, receive guided next steps, and reach the right kind of consultation faster."
  },
  {
    label: "Clinics",
    title: "Better flow across every consultation",
    body:
      "MedBuddy helps teams manage demand, reduce repetitive intake, and create smoother handoffs between AI assistance and clinical judgment."
  },
  {
    label: "Healthcare networks",
    title: "A scalable care access layer",
    body:
      "Standardize intake quality, continuity, and patient communication across multiple doctors, locations, and service lines."
  }
];

const careJourney = [
  {
    step: "01",
    title: "Signal capture",
    body: "Patients describe symptoms, concerns, and context in natural language without getting trapped in rigid forms."
  },
  {
    step: "02",
    title: "Clinical preparation",
    body: "MedBuddy structures the information, highlights urgency patterns, and makes the next handoff more useful."
  },
  {
    step: "03",
    title: "Consultation flow",
    body: "Care teams move faster because they enter each interaction with better context and clearer patient intent."
  },
  {
    step: "04",
    title: "Continuity loop",
    body: "Follow-ups, care plans, reminders, and recovery guidance keep the experience active after the appointment."
  }
];

const faqs = [
  {
    question: "Is MedBuddy replacing doctors?",
    answer:
      "No. The platform is designed to reduce friction before and after the consultation while keeping licensed clinical judgment central."
  },
  {
    question: "Who is the platform built for?",
    answer:
      "MedBuddy is aimed at startups, clinics, multi-doctor practices, and healthcare operators building more modern patient journeys."
  },
  {
    question: "Why a three-layer model?",
    answer:
      "Because care breaks at different points. Intake, consultation readiness, and continuity each need their own product quality and workflow design."
  }
];

export default function HomePage() {
  return (
    <main className="shell">
      <Navbar />

      <section className="marketing-hero">
        <Reveal className="marketing-copy reveal-rise" delay={40}>
          <p className="eyebrow">AI-assisted personalized medical support</p>
          <h1>The healthcare front door built for faster, more human care journeys.</h1>
          <p className="lede">
            MedBuddy is a three-layer medical assistance and consultation platform that blends
            intelligent guidance, clinician matching, and continuous care into one modern
            experience.
          </p>
          <div className="action-row">
            <Link href="/solutions" className="cta">
              Explore solutions
            </Link>
            <Link href="/company" className="cta secondary-link">
              About MedBuddy
            </Link>
          </div>
          <div className="marketing-trust">
            <span>AI-assisted intake</span>
            <span>Clinical handoff readiness</span>
            <span>Continuous care layer</span>
          </div>
        </Reveal>

        <Reveal className="marketing-frame panel reveal-scale" delay={140}>
          <p className="section-tag">Three-layer care model</p>
          <div className="frame-stack">
            <div>
              <span>Layer 01</span>
              <strong>AI assistance</strong>
              <p>Symptom capture, urgency patterns, and structured patient briefs.</p>
            </div>
            <div>
              <span>Layer 02</span>
              <strong>Consultation routing</strong>
              <p>Cleaner clinician matching and more informed appointments.</p>
            </div>
            <div>
              <span>Layer 03</span>
              <strong>Post-care continuity</strong>
              <p>Plans, reminders, follow-ups, and next-step adherence support.</p>
            </div>
          </div>
        </Reveal>
      </section>

      <Reveal as="section" className="marketing-band reveal-fade" delay={60}>
        <p>Designed for digital-first clinics, ambitious healthcare operators, and modern care teams.</p>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="section-heading">
          <p className="section-tag">What MedBuddy solves</p>
          <h2>Healthcare access often breaks before the consultation even begins.</h2>
          <p className="lede">
            Delayed intake, incomplete context, inconsistent follow-up, and overloaded staff create
            a fragmented patient experience. MedBuddy brings those steps into a single coordinated
            system.
          </p>
        </div>
        <div className="problem-solution-grid">
          <article className="panel story-card">
            <p className="section-tag">Before</p>
            <h3>Patients repeat themselves. Teams triage manually. Follow-ups get lost.</h3>
            <p>
              Too much effort is spent collecting context, interpreting urgency, and reconnecting
              the dots after a visit.
            </p>
          </article>
          <article className="panel story-card story-card-accent">
            <p className="section-tag">After</p>
            <h3>One care layer from first concern to next best action.</h3>
            <p>
              MedBuddy coordinates intake, consultation prep, and continuity so patients and
              clinicians can move with more confidence.
            </p>
          </article>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="section-heading">
          <p className="section-tag">Solutions</p>
          <h2>Built for the people delivering and receiving care.</h2>
        </div>
        <div className="solution-grid">
          {solutionCards.map((card, index) => (
            <Reveal key={card.label} className="panel solution-card reveal-rise" delay={index * 110}>
              <p className="section-tag">{card.label}</p>
              <h3>{card.title}</h3>
              <p>{card.body}</p>
            </Reveal>
          ))}
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="platform-split panel ambient-grid">
          <div>
            <p className="section-tag">Platform detail</p>
            <h2>MedBuddy turns a consultation into a coordinated care workflow.</h2>
          </div>
          <div className="outcome-list">
            {outcomes.map((item, index) => (
              <Reveal key={item} className="reveal-slide" delay={index * 90}>
                <strong>{item}</strong>
              </Reveal>
            ))}
          </div>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="section-heading">
          <p className="section-tag">Journey design</p>
          <h2>A longer care story needs more than a hero statement.</h2>
          <p className="lede">
            MedBuddy is designed as a sequence of better decisions and smoother transitions, not as
            a single feature or one isolated consultation moment.
          </p>
        </div>
        <div className="journey-long-grid">
          {careJourney.map((item, index) => (
            <Reveal key={item.step} className="panel journey-long-card reveal-rise" delay={index * 90}>
              <span className="journey-step">{item.step}</span>
              <h3>{item.title}</h3>
              <p>{item.body}</p>
            </Reveal>
          ))}
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="deep-story-grid">
          <Reveal className="panel deep-story-card ambient-grid reveal-scale" delay={0}>
            <p className="section-tag">For operators</p>
            <h2>Build a care experience that feels deliberate at scale.</h2>
            <p>
              The strongest healthcare brands are not only trusted for clinical outcomes. They are
              also trusted for how clearly they guide people through uncertainty.
            </p>
          </Reveal>
          <Reveal className="panel deep-story-card reveal-scale" delay={120}>
            <p className="section-tag">For teams</p>
            <h2>Reduce repeat work and create better starting points.</h2>
            <p>
              Better summaries, better routing, and better continuity create leverage across product,
              operations, and clinician time.
            </p>
          </Reveal>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="section-heading">
          <p className="section-tag">Company</p>
          <h2>We’re building the infrastructure layer for more responsive healthcare experiences.</h2>
        </div>
        <div className="company-grid">
          <Reveal className="panel company-card reveal-rise" delay={0}>
            <h3>Mission</h3>
            <p>
              Make high-quality medical access feel more immediate, personalized, and continuous
              across every stage of care.
            </p>
          </Reveal>
          <Reveal className="panel company-card reveal-rise" delay={100}>
            <h3>Approach</h3>
            <p>
              Pair safe AI assistance with human clinical judgment instead of treating them like
              competing systems.
            </p>
          </Reveal>
          <Reveal className="panel company-card reveal-rise" delay={200}>
            <h3>Where we’re headed</h3>
            <p>
              A healthcare layer that helps startups, clinics, and networks operate with less
              friction and stronger patient trust.
            </p>
          </Reveal>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="section-heading">
          <p className="section-tag">System in motion</p>
          <h2>How the MedBuddy workflow moves from concern to continuous care.</h2>
          <p className="lede">
            The platform works as a connected workflow: a patient starts with a concern, MedBuddy
            structures the request, routes the next step, and keeps care active afterward.
          </p>
        </div>
        <Reveal className="panel layer-diagram reveal-scale" delay={80}>
          <div className="workflow-diagram">
            <article className="workflow-box">
              <span className="diagram-label">Start</span>
              <h3>Patient concern</h3>
              <p>The patient opens MedBuddy and describes symptoms, pain points, or uncertainty.</p>
            </article>
            <div className="workflow-arrow" aria-hidden="true">
              <span />
            </div>
            <article className="workflow-box">
              <span className="diagram-label">Layer 01</span>
              <h3>AI intake</h3>
              <p>MedBuddy captures symptoms, urgency, history, and relevant context in a structured way.</p>
            </article>
            <div className="workflow-arrow" aria-hidden="true">
              <span />
            </div>
            <article className="workflow-box">
              <span className="diagram-label">Layer 02</span>
              <h3>Care routing</h3>
              <p>The case is directed toward guidance, the right clinician, or the best next care path.</p>
            </article>
            <div className="workflow-arrow" aria-hidden="true">
              <span />
            </div>
            <article className="workflow-box">
              <span className="diagram-label">Layer 03</span>
              <h3>Consult and continue</h3>
              <p>Consultation, reminders, prescriptions, and follow-up support keep the journey active.</p>
            </article>
          </div>
        </Reveal>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="section-heading">
          <p className="section-tag">Frequently asked</p>
          <h2>The kind of questions people ask when the vision starts to feel real.</h2>
        </div>
        <div className="faq-list">
          {faqs.map((item, index) => (
            <Reveal key={item.question} className="panel faq-card reveal-slide" delay={index * 90}>
              <h3>{item.question}</h3>
              <p>{item.answer}</p>
            </Reveal>
          ))}
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="closing-cta panel ambient-cta">
          <p className="section-tag">Join the next wave of care delivery</p>
          <h2>Bright tech, brighter living.</h2>
          <p className="lede">
            MedBuddy is creating a more thoughtful healthcare experience with modern technology,
            clearer care journeys, and a more human sense of support.
          </p>
          <div className="action-row">
            <Link href="/solutions" className="cta">
              View solutions
            </Link>
            <Link href="/careers" className="cta secondary-link">
              View careers
            </Link>
          </div>
        </div>
      </Reveal>

      <Reveal as="footer" className="marketing-footer reveal-fade">
        <div>
          <p className="section-tag">MedBuddy</p>
          <p>AI-assisted personalized medical assistance and consultation platform.</p>
        </div>
        <div>
          <p className="section-tag">Pages</p>
          <div className="footer-links">
            <Link href="/solutions">Solutions</Link>
            <Link href="/company">Company</Link>
            <Link href="/careers">Careers</Link>
          </div>
        </div>
        <div>
          <p className="section-tag">Focus</p>
          <p>Intake quality, consultation readiness, and continuity across the care journey.</p>
        </div>
        <div>
          <p className="section-tag">Connect</p>
          <div className="footer-socials">
            <a
              className="footer-social-link"
              href="https://www.linkedin.com/company/themedbuddy/"
              target="_blank"
              rel="noreferrer"
              aria-label="TheMedBuddy on LinkedIn"
            >
              <LinkedInIcon />
            </a>
            <a
              className="footer-social-link"
              href="https://www.instagram.com/the_medbuddy/"
              target="_blank"
              rel="noreferrer"
              aria-label="TheMedBuddy on Instagram"
            >
              <InstagramIcon />
            </a>
            <a
              className="footer-social-link"
              href="mailto:adi001247@gmail.com"
              aria-label="Email TheMedBuddy"
            >
              <MailIcon />
            </a>
          </div>
        </div>
      </Reveal>
    </main>
  );
}
