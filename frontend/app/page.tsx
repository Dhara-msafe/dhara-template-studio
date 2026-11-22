import Link from "next/link";

export default function Home() {
  return (
    <div className="container">
      <div className="card dark" style={{ padding: "52px 44px" }}>
        <div className="eyebrow" style={{ color: "#e3c9a8" }}>
          DHARA Template Studio
        </div>
        <h1 style={{ fontSize: 38, color: "#f4f1e8", maxWidth: 620 }}>
          Every Indian legal document, ready in minutes.
        </h1>
        <p className="muted" style={{ maxWidth: 520, margin: "14px 0 26px" }}>
          Browse advocate-reviewed templates, fill them in by typing or voice, preview live, and download a
          finished document — no legal vocabulary required.
        </p>
        <Link className="btn" href="/browse" style={{ background: "#fff", color: "var(--ink)" }}>
          Browse templates →
        </Link>
      </div>

      <div className="grid" style={{ marginTop: 8 }}>
        <div className="card">
          <div className="eyebrow">For citizens</div>
          <h3>Fill, don't draft</h3>
          <p className="muted">Answer plain-language questions; we assemble the legal document for you.</p>
        </div>
        <div className="card">
          <div className="eyebrow">For advocates</div>
          <h3>Review, don't retype</h3>
          <p className="muted">Advocate-only templates and a review queue keep every document accountable.</p>
        </div>
        <div className="card">
          <div className="eyebrow">Free to start</div>
          <h3>Upgrade when you need more</h3>
          <p className="muted">Guided templates are free. Pro unlocks the full catalogue.</p>
        </div>
      </div>
    </div>
  );
}
