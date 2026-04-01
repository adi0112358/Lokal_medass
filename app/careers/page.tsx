import Link from "next/link";
import { Navbar } from "@/components/navbar";
import { CareersApplication } from "@/components/careers-application";
import { Reveal } from "@/components/reveal";

const roles = [
  {
    team: "Product",
    title: "Founding Product Designer",
    detail: "Shape the public brand, core care flows, and the design language of an emerging healthcare company."
  },
  {
    team: "Engineering",
    title: "Frontend Engineer",
    detail: "Build polished patient and clinician experiences across the marketing site and product surfaces."
  },
  {
    team: "Marketing",
    title: "Growth Marketing Lead",
    detail: "Shape MedBuddy’s brand, acquisition narrative, campaigns, and audience growth strategy."
  },
  {
    team: "Product Development",
    title: "Product Development Manager",
    detail: "Translate insight into roadmap direction, feature definition, and launch coordination across teams."
  },
  {
    team: "Strategy",
    title: "Healthcare Strategy Associate",
    detail: "Work on market research, operating models, partnership thinking, and strategic expansion ideas."
  },
  {
    team: "Business",
    title: "Partnerships and Business Development Lead",
    detail: "Build relationships with clinics, operators, and health ecosystem partners to expand the platform."
  },
  {
    team: "Clinical Operations",
    title: "Care Operations Lead",
    detail: "Help define safe workflows, escalation paths, and continuity systems that make the platform credible."
  }
];

export default function CareersPage() {
  return (
    <main className="shell">
      <Navbar />

      <Reveal as="section" className="subpage-hero panel reveal-scale">
        <p className="eyebrow">Careers</p>
        <h1>Join a team building the next generation of medical assistance.</h1>
        <p className="lede">
          MedBuddy is for people who want to work on healthcare with real care, modern product
          standards, and high agency. We’re interested in builders who can move across ambiguity
          and quality at the same time.
        </p>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-rise">
        <div className="careers-grid">
          {roles.map((role, index) => (
            <Reveal key={role.title} className="panel career-card reveal-rise" delay={index * 100}>
              <p className="section-tag">{role.team}</p>
              <h3>{role.title}</h3>
              <p>{role.detail}</p>
            </Reveal>
          ))}
        </div>
      </Reveal>

      <CareersApplication roles={roles.map(({ team, title }) => ({ team, title }))} />

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="platform-split panel ambient-grid">
          <div>
            <p className="section-tag">What we value</p>
            <h2>People who care about both systems and humans tend to do well here.</h2>
          </div>
          <div className="outcome-list">
            <Reveal className="reveal-slide" delay={0}>
              <strong>Clarity</strong>
              <p>We make hard problems easier to understand and act on.</p>
            </Reveal>
            <Reveal className="reveal-slide" delay={90}>
              <strong>Ownership</strong>
              <p>We want teammates who can move ideas all the way to useful outcomes.</p>
            </Reveal>
            <Reveal className="reveal-slide" delay={180}>
              <strong>Care</strong>
              <p>Healthcare is sensitive work, so quality and empathy are part of the baseline.</p>
            </Reveal>
          </div>
        </div>
      </Reveal>

      <Reveal as="section" className="marketing-section reveal-scale">
        <div className="closing-cta panel ambient-cta">
          <p className="section-tag">Start with the story</p>
          <h2>If the mission resonates, the product should too.</h2>
          <div className="action-row">
            <Link href="/company" className="cta">
              Learn about the company
            </Link>
            <Link href="/solutions" className="cta secondary-link">
              Explore the platform
            </Link>
          </div>
        </div>
      </Reveal>
    </main>
  );
}
