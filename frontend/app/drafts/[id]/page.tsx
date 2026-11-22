"use client";

import { useEffect, useRef, useState } from "react";
import { useParams } from "next/navigation";
import { api } from "@/lib/api";

export default function DraftFillPage() {
  const { id } = useParams<{ id: string }>();
  const [draft, setDraft] = useState<any>(null);
  const [template, setTemplate] = useState<any>(null);
  const [fields, setFields] = useState<Record<string, string>>({});
  const [error, setError] = useState<string | null>(null);
  const saveTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    api
      .getDraft(id)
      .then(async (d) => {
        setDraft(d);
        setFields(d.fields || {});
        const t = await api.getTemplate(d.template_id);
        setTemplate(t);
      })
      .catch((err) => setError(err.message));
  }, [id]);

  function onFieldChange(key: string, value: string) {
    const next = { ...fields, [key]: value };
    setFields(next);
    if (saveTimer.current) clearTimeout(saveTimer.current);
    // Debounced autosave (~2s), matching the Fill & Preview page's build notes.
    saveTimer.current = setTimeout(() => {
      api.updateDraft(id, next).catch((err) => setError(err.message));
    }, 2000);
  }

  function voiceFill(key: string) {
    const SpeechRecognition = (window as any).webkitSpeechRecognition || (window as any).SpeechRecognition;
    if (!SpeechRecognition) {
      setError("Voice input isn't supported in this browser.");
      return;
    }
    const recognizer = new SpeechRecognition();
    recognizer.lang = "en-IN";
    recognizer.onresult = (e: any) => onFieldChange(key, e.results[0][0].transcript);
    recognizer.start();
  }

  if (error && !draft) return <div className="container error">{error}</div>;
  if (!draft || !template) return <div className="container muted">Loading…</div>;

  return (
    <div className="container">
      <h1>{template.title}</h1>
      {error && <div className="error">{error}</div>}
      <div className="grid" style={{ gridTemplateColumns: "1fr 1fr", alignItems: "start" }}>
        <div className="card">
          <h3>Fill in your details</h3>
          {template.field_schema.map((f: any) => (
            <div key={f.key}>
              <label>
                {f.label} {f.required && "*"}
              </label>
              <div className="row">
                <input
                  type={f.type === "number" ? "number" : f.type === "date" ? "date" : "text"}
                  value={fields[f.key] || ""}
                  onChange={(e) => onFieldChange(f.key, e.target.value)}
                />
                <button type="button" className="secondary" onClick={() => voiceFill(f.key)} title="Fill by voice">
                  🎙
                </button>
              </div>
            </div>
          ))}
        </div>
        <div className="card">
          <h3>Preview</h3>
          <p className="muted">
            Live preview renders here as you type. Final formatted document is generated on export.
          </p>
          <pre style={{ whiteSpace: "pre-wrap", fontSize: 13 }}>
            {Object.entries(fields)
              .map(([k, v]) => `${k}: ${v}`)
              .join("\n")}
          </pre>
          <div className="row">
            <a className="btn" href={api.exportDraftUrl(id, "pdf")}>
              Download PDF
            </a>
            <a className="btn secondary" href={api.exportDraftUrl(id, "docx")}>
              Download Word
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
