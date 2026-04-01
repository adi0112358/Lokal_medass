import Link from "next/link";

export default function NotFound() {
  return (
    <main className="marketing-shell">
      <section className="page-hero">
        <div className="eyebrow">Page not found</div>
        <h1>This page does not exist.</h1>
        <p>
          The link may be outdated, or the page may have moved somewhere else in
          the MedBuddy site.
        </p>
        <div className="hero-actions">
          <Link className="primary-button" href="/">
            Back to home
          </Link>
          <Link className="secondary-button" href="/solutions">
            View solutions
          </Link>
        </div>
      </section>
    </main>
  );
}
