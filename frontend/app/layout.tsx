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
            Dhara <small>Template Studio</small>
          </Link>
          <Link href="/browse">Documents</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/account">My drafts</Link>
          <Link href="/admin">Admin</Link>
          <Link href="/login" className="cta">
            Sign in
          </Link>
        </nav>
        {children}
        <footer className="footer">
          <p>Dhara Template Studio is not a law firm and does not give legal advice. A template helps you prepare a document; it does not replace an advocate for your situation.</p>
          <p>Made in India.</p>
        </footer>
      </body>
    </html>
  );
}
