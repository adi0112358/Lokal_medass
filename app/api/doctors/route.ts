import { NextResponse } from "next/server";
import { demoStore } from "@/lib/mock-data";

export async function GET() {
  return NextResponse.json(demoStore.doctors);
}
