import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Lokal MedAssist",
  description:
    "A proposal-ready medical assistance platform for tier 2 and tier 3 cities with AI triage and doctor consultations."
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
