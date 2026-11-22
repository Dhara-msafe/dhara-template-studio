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
      // the frontend gate so neither side can be bypassed (per build notes).
      setError(err.message || "Could not start a draft");
    } finally {
      setStarting(false);
    }
  }

  if (error && !template) return <div className="container error">{error}</div>;
  if (!template) return <div className="container muted">Loading…</div>;

  return (
    <div className="container">
      <div className="card">
        <span className="badge">{template.tier === "pro" ? "Pro" : "Free"}</span>
        {template.mode !== "guided_self_serve" && <span className="badge">{template.mode.replace("_", "-")}</span>}
        <h1>{template.title}</h1>
        <p className="muted">{template.category}</p>
        {template.legal_basis && <p>{template.legal_basis}</p>}
        <h3>Fields you'll fill in</h3>
        <ul>
          {template.field_schema.map((f) => (
            <li key={f.key}>
              {f.label} {f.required && <span className="muted">(required)</span>}
            </li>
          ))}
        </ul>
        {error && <div className="error">{error}</div>}
        <button onClick={fillThisTemplate} disabled={starting}>
          {starting ? "Starting…" : "Fill this template"}
        </button>
      </div>
    </div>
  );
}
