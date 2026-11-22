"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api } from "@/lib/api";

export default function AccountPage() {
  const [drafts, setDrafts] = useState<any[]>([]);
  const [account, setAccount] = useState<any>(null);
  const [barId, setBarId] = useState("");
  const [error, setError] = useState<string | null>(null);

  function refresh() {
    api.listMyDrafts().then((r) => setDrafts(r.items)).catch((err) => setError(err.message));
    api.getAccount().then(setAccount).catch((err) => setError(err.message));
  }

  useEffect(refresh, []);

  async function applyAsAdvocate(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.requestAdvocateVerification(barId);
      refresh();
    } catch (err: any) {
      setError(err.message);
    }
  }

  return (
    <div className="container">
      <div className="eyebrow">Your account</div>
      <h1>My Drafts</h1>
      {error && <div className="error">{error}</div>}

      <div className="card">
        {drafts.length === 0 && <p className="muted">No drafts yet — start one from the Browse page.</p>}
        {drafts.map((d, i) => (
          <div key={d.id}>
            <div className="row between" style={{ padding: "10px 0" }}>
              <Link href={`/drafts/${d.id}`} style={{ fontWeight: 600 }}>
                Draft — updated {new Date(d.updated_at).toLocaleString()}
              </Link>
              <div className="row">
                <button className="secondary" onClick={() => api.duplicateDraft(d.id).then(refresh)}>
                  Duplicate
                </button>
                <button className="secondary" onClick={() => api.deleteDraft(d.id).then(refresh)}>
                  Delete
                </button>
              </div>
            </div>
            {i < drafts.length - 1 && <div className="divider" />}
          </div>
        ))}
      </div>

      <h2 style={{ marginTop: 36 }}>Account</h2>
      <div className="card">
        {account && (
          <div className="row" style={{ marginBottom: 14 }}>
            <span className={"badge " + (account.plan === "pro" ? "tier-pro" : "tier-free")}>
              {account.plan === "pro" ? "Pro plan" : "Free plan"}
            </span>
            <span className="badge">Advocate: {account.advocate_verification}</span>
          </div>
        )}
        {account?.advocate_verification === "none" && (
          <form onSubmit={applyAsAdvocate}>
            <label>Bar ID (apply as a verified advocate)</label>
            <input value={barId} onChange={(e) => setBarId(e.target.value)} required />
            <button type="submit">Submit for review</button>
          </form>
        )}
        {account?.advocate_verification === "pending" && (
          <p className="muted">Pending review — an admin will act on this shortly.</p>
        )}
      </div>
    </div>
  );
}
