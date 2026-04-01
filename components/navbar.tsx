"use client";

import type { Route } from "next";
import Link from "next/link";
import { useState } from "react";

const navItems = [
  { href: "/", label: "Home" },
  { href: "/solutions", label: "Solutions" },
  { href: "/company", label: "Company" },
  { href: "/careers", label: "Careers" }
] satisfies Array<{ href: Route; label: string }>;

export function Navbar() {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <>
      <header className="topbar">
        <Link href="/" className="brand">
          Med<span>Buddy</span>
        </Link>

        <button
          type="button"
          className={`menu-trigger${menuOpen ? " is-open" : ""}`}
          aria-expanded={menuOpen}
          aria-label="Toggle site menu"
          onClick={() => setMenuOpen((value) => !value)}
        >
          <span />
          <span />
          <span />
        </button>
      </header>

      <div className={`menu-overlay${menuOpen ? " is-open" : ""}`}>
        <div className="menu-backdrop" onClick={() => setMenuOpen(false)} />
        <aside className="menu-panel">
          <div className="menu-panel-left">
            <p className="menu-kicker">Navigate MedBuddy</p>
            <div className="menu-links">
              {navItems.map((item) => (
                <Link key={item.href} href={item.href} onClick={() => setMenuOpen(false)}>
                  {item.label}
                </Link>
              ))}
            </div>
          </div>

          <div className="menu-panel-right">
            <div className="menu-panel-head">
              <p className="section-tag">Platform snapshot</p>
              <button type="button" className="menu-close" onClick={() => setMenuOpen(false)}>
                Close
              </button>
            </div>

            <div className="menu-insight">
              <h3>Healthcare navigation should feel structured before the consult starts.</h3>
              <p>
                MedBuddy combines AI-assisted intake, cleaner clinical handoffs, and continuity
                after the visit into a more modern care experience.
              </p>
            </div>

            <div className="menu-mini-grid">
              <div>
                <strong>AI intake</strong>
                <p>Understand symptoms early and organize context.</p>
              </div>
              <div>
                <strong>Solutions</strong>
                <p>Designed for clinics, operators, and digital health teams.</p>
              </div>
              <div>
                <strong>Careers</strong>
                <p>For builders who care about both systems and people.</p>
              </div>
            </div>
          </div>
        </aside>
      </div>
    </>
  );
}
