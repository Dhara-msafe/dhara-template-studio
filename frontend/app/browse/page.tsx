"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api, Template } from "@/lib/api";

export default function BrowsePage() {
  const [templates, setTemplates] = useState<Template[]>([]);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const t = setTimeout(() => {
      api
        .listTemplates({ search: search || undefined, category: category || undefined })
        .then((res) => setTemplates(res.items))
        .catch((err) => setError(err.message));
    }, 300);
    return () => clearTimeout(t);
  }, [search, category]);

  const categories = Array.from(new Set(templates.map((t) => t.category)));

  return (
    <div className="container">
      <h1>Browse templates</h1>
      <input placeholder="Search templates…" value={search} onChange={(e) => setSearch(e.target.value)} />
      <div className="row" style={{ marginBottom: 16, flexWrap: "wrap" }}>
        <button className={category === "" ? "" : "secondary"} onClick={() => setCategory("")}>
          All
        </button>
        {categories.map((c) => (
          <button key={c} className={category === c ? "" : "secondary"} onClick={() => setCategory(c)}>
            {c}
          </button>
        ))}
      </div>
      {error && <div className="error">{error}</div>}
      <div className="grid">
        {templates.map((t) => (
          <Link key={t.id} href={`/templates/${t.id}`} className="card" style={{ display: "block" }}>
            <span className="badge">{t.tier === "pro" ? "Pro" : "Free"}</span>
            {t.mode !== "guided_self_serve" && <span className="badge">{t.mode.replace("_", "-")}</span>}
            <h3 style={{ margin: "10px 0 4px" }}>{t.title}</h3>
            <div className="muted">{t.category}</div>
          </Link>
        ))}
        {templates.length === 0 && !error && <p className="muted">No templates match this filter.</p>}
      </div>
    </div>
  );
}
