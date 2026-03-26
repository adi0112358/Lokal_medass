import { NextResponse } from "next/server";
import { demoStore } from "@/lib/mock-data";

export async function GET() {
  return NextResponse.json({
    patient: demoStore.patient,
    doctors: demoStore.doctors.length,
    consultations: demoStore.consultations.length,
    feedbackEntries: demoStore.feedback.length
  });
}
