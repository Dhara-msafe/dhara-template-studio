import "./globals.css";
import Link from "next/link";

export const metadata = {
  title: "DHARA Template Studio",
  description: "Indian legal document templates — browse, fill, download.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <nav className="nav">
          <Link href="/" className="brand">
            DHARA Template Studio
          </Link>
          <Link href="/browse">Browse</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/account">My Drafts</Link>
          <Link href="/admin">Admin</Link>
          <Link href="/login" className="cta">
            Sign in
          </Link>
        </nav>
        {children}
      </body>
    </html>
  );
}
