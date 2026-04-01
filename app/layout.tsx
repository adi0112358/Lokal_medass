import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "MedBuddy",
  description:
    "MedBuddy is an AI-assisted personalized three-layer medical assistance and consultation platform."
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
