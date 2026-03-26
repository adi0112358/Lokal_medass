import Link from "next/link";

export function Navbar() {
  return (
    <header className="topbar">
      <Link href="/" className="brand">
        Lokal <span>MedAssist</span>
      </Link>
      <nav className="navlinks">
        <Link href="/patient">Patient App</Link>
        <Link href="/doctor">Doctor Workspace</Link>
      </nav>
    </header>
  );
}
