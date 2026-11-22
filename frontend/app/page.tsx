import Link from "next/link";

export default function Home() {
  return (
    <div className="container">
      <div className="card">
        <h1>DHARA Template Studio</h1>
        <p className="muted">
          Browse advocate-reviewed Indian legal document templates, fill them in, preview, and download —
          in minutes.
        </p>
        <Link className="btn" href="/browse">
          Browse templates
        </Link>
      </div>
    </div>
  );
}
