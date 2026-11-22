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
      <div className="eyebrow">Reviewer / admin</div>
      <h1>Review dashboard</h1>
      <p className="lede">
        Requires a reviewer or admin role, set on <code>profiles.role</code> in Supabase. Nothing a citizen sees
        skips this queue.
      </p>

      <div className="row" style={{ marginBottom: 20 }}>
        {STATUS_FILTERS.map((s) => (
          <button
            key={s}
            className={"pill-filter " + (statusFilter === s ? "active" : "")}
            onClick={() => setStatusFilter(s)}
          >
            {s ? s.replace(/_/g, " ") : "All"}
          </button>
        ))}
      </div>
      {error && <div className="error">{error}</div>}

      <div className="card">
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>Category</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {items.map((t) => (
              <tr key={t.id}>
                <td style={{ fontWeight: 600 }}>{t.title}</td>
                <td className="muted">{t.category}</td>
                <td>
                  <span className="badge">{t.status.replace(/_/g, " ")}</span>
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
