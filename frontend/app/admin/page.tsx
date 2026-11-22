"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

const STATUS_FILTERS = ["", "draft", "in_legal_review", "in_language_review", "approved", "published"];

export default function AdminPage() {
  const [items, setItems] = useState<any[]>([]);
  const [statusFilter, setStatusFilter] = useState("");
  const [error, setError] = useState<string | null>(null);

  function refresh() {
    api
      .adminListTemplates(statusFilter || undefined)
      .then((r) => setItems(r.items))
      .catch((err) => setError(err.message));
  }

  useEffect(refresh, [statusFilter]);

  return (
    <div className="container">
      <h1>Admin &amp; Review Dashboard</h1>
      <p className="muted">
        Requires a reviewer or admin role — set via <code>profiles.role</code> in Supabase. Nothing a citizen
        sees skips this queue (publish-gate, TS-07).
      </p>
      <div className="row" style={{ marginBottom: 16, flexWrap: "wrap" }}>
        {STATUS_FILTERS.map((s) => (
          <button key={s} className={statusFilter === s ? "" : "secondary"} onClick={() => setStatusFilter(s)}>
            {s || "All"}
          </button>
        ))}
      </div>
      {error && <div className="error">{error}</div>}
      <div className="card">
        <table style={{ width: "100%", borderCollapse: "collapse" }}>
          <thead>
            <tr>
              <th style={{ textAlign: "left" }}>Title</th>
              <th style={{ textAlign: "left" }}>Category</th>
              <th style={{ textAlign: "left" }}>Status</th>
            </tr>
          </thead>
          <tbody>
            {items.map((t) => (
              <tr key={t.id}>
                <td>{t.title}</td>
                <td>{t.category}</td>
                <td>
                  <span className="badge">{t.status}</span>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td colSpan={3} className="muted">
                  No templates match this filter.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
