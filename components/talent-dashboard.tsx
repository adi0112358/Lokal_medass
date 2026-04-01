"use client";

import { useEffect, useState } from "react";
import { readJobApplications } from "@/lib/storage";
import { JobApplication } from "@/lib/types";

function formatDate(value: string) {
  return new Date(value).toLocaleString("en-IN", {
    dateStyle: "medium",
    timeStyle: "short"
  });
}

export function TalentDashboard() {
  const [applications, setApplications] = useState<JobApplication[]>([]);

  useEffect(() => {
    setApplications(readJobApplications());
  }, []);

  return (
    <div className="dashboard-shell">
      <section className="panel dashboard-hero">
        <p className="section-tag">Talent dashboard</p>
        <h1>Applications received for MedBuddy.</h1>
        <p className="lede">
          This dashboard is separate from the public-facing site and lists the application entries
          submitted through the careers form.
        </p>
      </section>

      <section className="dashboard-grid">
        <article className="panel dashboard-stat">
          <strong>{applications.length}</strong>
          <span>Total applications</span>
        </article>
        <article className="panel dashboard-stat">
          <strong>{new Set(applications.map((item) => item.role)).size}</strong>
          <span>Roles applied for</span>
        </article>
        <article className="panel dashboard-stat">
          <strong>{new Set(applications.map((item) => item.team)).size}</strong>
          <span>Teams represented</span>
        </article>
      </section>

      <section className="panel dashboard-list">
        <div className="split-header">
          <div>
            <p className="section-tag">Entry list</p>
            <h2>Candidate submissions</h2>
          </div>
        </div>

        {applications.length > 0 ? (
          <div className="dashboard-table">
            {applications.map((application) => (
              <article key={application.id} className="dashboard-row">
                <div>
                  <strong>{application.name}</strong>
                  <span>{application.email}</span>
                </div>
                <div>
                  <strong>{application.role}</strong>
                  <span>{application.team}</span>
                </div>
                <div>
                  <strong>{application.experienceLevel}</strong>
                  <span>{application.location}</span>
                </div>
                <div>
                  <strong>{application.phone}</strong>
                  <span>{application.portfolio || "No portfolio link"}</span>
                </div>
                <div className="dashboard-note">
                  <strong>Why MedBuddy</strong>
                  <p>{application.coverNote}</p>
                  <span>{formatDate(application.createdAt)}</span>
                </div>
              </article>
            ))}
          </div>
        ) : (
          <p className="empty-copy">No applications yet. Submit the careers form to see entries here.</p>
        )}
      </section>
    </div>
  );
}
