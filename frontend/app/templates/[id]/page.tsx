"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { api, Template } from "@/lib/api";

export default function TemplateDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [template, setTemplate] = useState<Template | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [starting, setStarting] = useState(false);

  useEffect(() => {
    api.getTemplate(id).then(setTemplate).catch((err) => setError(err.message));
  }, [id]);

  async function fillThisTemplate() {
    setStarting(true);
    setError(null);
    try {
      const draft: any = await api.createDraft(id);
      router.push(`/drafts/${draft.id}`);
    } catch (err: any) {
      // Backend returns 402 for Pro-gated, 403 for advocate-only — mirrors
      // the frontend gate so neither side can be bypassed.
      setError(err.message || "Could not start a draft");
    } finally {
      setStarting(false);
    }
  }

  if (error && !template) return <div className="container error">{error}</div>;
  if (!template) return <div className="container muted">Loading…</div>;

  return (
    <div className="container">
      <div className="grid cols-2">
        <div>
          <span className={"badge " + (template.tier === "pro" ? "tier-pro" : "tier-free")}>
            {template.tier === "pro" ? "Pro" : "Free"}
          </span>
          {template.mode !== "guided_self_serve" && (
            <span className="badge">
              {template.mode === "advocate_only" ? "Advocate-only" : "Advocate-reviewed"}
            </span>
          )}
          <h1 style={{ fontSize: 32 }}>{template.title}</h1>
          <p className="muted">{template.category}</p>
          {template.legal_basis && <p style={{ marginTop: 14 }}>{template.legal_basis}</p>}
        </div>

        <div className="card" style={{ position: "sticky", top: 90 }}>
          <h3>Fields you'll fill in</h3>
          <ul style={{ paddingLeft: 18, margin: "10px 0 18px" }}>
            {template.field_schema.map((f) => (
              <li key={f.key} style={{ marginBottom: 4 }}>
                {f.label} {f.required && <span className="muted">(required)</span>}
              </li>
            ))}
          </ul>
          {error && <div className="error">{error}</div>}
          <button onClick={fillThisTemplate} disabled={starting} style={{ width: "100%" }}>
            {starting ? "Starting…" : "Fill this template"}
          </button>
        </div>
      </div>
    </div>
  );
}
