import { Navbar } from "@/components/navbar";
import { DoctorWorkspace } from "@/components/doctor-workspace";

export default function DoctorPage() {
  return (
    <main className="shell">
      <Navbar />
      <DoctorWorkspace />
    </main>
  );
}
