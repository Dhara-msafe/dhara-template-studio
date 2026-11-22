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
      <h1>My Drafts</h1>
      {error && <div className="error">{error}</div>}
      <div className="card">
        {drafts.length === 0 && <p className="muted">No drafts yet — start one from the Browse page.</p>}
        {drafts.map((d) => (
          <div key={d.id} className="row" style={{ justifyContent: "space-between", padding: "8px 0" }}>
            <Link href={`/drafts/${d.id}`}>Draft — updated {new Date(d.updated_at).toLocaleString()}</Link>
            <div className="row">
              <button className="secondary" onClick={() => api.duplicateDraft(d.id).then(refresh)}>
                Duplicate
              </button>
              <button className="secondary" onClick={() => api.deleteDraft(d.id).then(refresh)}>
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>

      <h2>Account</h2>
      <div className="card">
        {account && (
          <>
            <p>
              Plan: <b>{account.plan}</b>
            </p>
            <p>
              Advocate verification: <b>{account.advocate_verification}</b>
            </p>
          </>
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
