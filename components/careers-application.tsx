"use client";

import { FormEvent, useEffect, useState } from "react";
import { submitJobApplication } from "@/lib/storage";
import { JobApplication } from "@/lib/types";

type RoleOption = {
  team: string;
  title: string;
};

type CareersApplicationProps = {
  roles: RoleOption[];
};

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 8)}`;
}

export function CareersApplication({ roles }: CareersApplicationProps) {
  const [selectedRole, setSelectedRole] = useState(roles[0]?.title ?? "");
  const [selectedTeam, setSelectedTeam] = useState(roles[0]?.team ?? "");
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    const match = roles.find((role) => role.title === selectedRole);
    if (match) {
      setSelectedTeam(match.team);
    }
  }, [roles, selectedRole]);

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);

    const application: JobApplication = {
      id: createId("APP"),
      name: String(formData.get("name") ?? ""),
      email: String(formData.get("email") ?? ""),
      phone: String(formData.get("phone") ?? ""),
      role: String(formData.get("role") ?? ""),
      team: selectedTeam,
      location: String(formData.get("location") ?? ""),
      portfolio: String(formData.get("portfolio") ?? ""),
      experienceLevel: formData.get("experienceLevel") as JobApplication["experienceLevel"],
      coverNote: String(formData.get("coverNote") ?? ""),
      createdAt: new Date().toISOString()
    };

    submitJobApplication(application);
    event.currentTarget.reset();
    setSelectedRole(roles[0]?.title ?? "");
    setSelectedTeam(roles[0]?.team ?? "");
    setSubmitted(true);
  }

  return (
    <section className="marketing-section">
      <div className="application-shell panel ambient-grid">
        <div className="application-copy">
          <p className="section-tag">Apply now</p>
          <h2>Send your details and be a part of the family.</h2>
        </div>

        <form className="application-form" onSubmit={handleSubmit}>
          <input name="name" placeholder="Full name" required />
          <input name="email" type="email" placeholder="Email address" required />
          <input name="phone" placeholder="Phone number" required />
          <select
            name="role"
            value={selectedRole}
            onChange={(event) => setSelectedRole(event.target.value)}
            required
          >
            {roles.map((role) => (
              <option key={role.title} value={role.title}>
                {role.title}
              </option>
            ))}
          </select>
          <input name="location" placeholder="Current city / location" required />
          <input name="portfolio" placeholder="Portfolio / LinkedIn / website" />
          <select name="experienceLevel" defaultValue="3-5 years" required>
            <option value="0-2 years">0-2 years</option>
            <option value="3-5 years">3-5 years</option>
            <option value="6-9 years">6-9 years</option>
            <option value="10+ years">10+ years</option>
          </select>
          <textarea
            name="coverNote"
            placeholder="Tell us why you want to work on MedBuddy"
            required
          />
          <div className="application-actions">
            <button type="submit">Submit application</button>
            {submitted ? <span className="application-success">Application saved to dashboard.</span> : null}
          </div>
        </form>
      </div>
    </section>
  );
}
