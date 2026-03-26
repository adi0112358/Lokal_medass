import { Navbar } from "@/components/navbar";
import { PatientExperience } from "@/components/patient-experience";

export default function PatientPage() {
  return (
    <main className="shell">
      <Navbar />
      <PatientExperience />
    </main>
  );
}
