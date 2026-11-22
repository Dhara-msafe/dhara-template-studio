"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api, Template } from "@/lib/api";

export default function BrowsePage() {
  const [templates, setTemplates] = useState<Template[]>([]);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => {
      api
        .listTemplates({ search: search || undefined, category: category || undefined })
        .then((res) => {
          setTemplates(res.items);
          setLoaded(true);
        })
        .catch((err) => setError(err.message));
    }, 300);
    return () => clearTimeout(t);
  }, [search, category]);

  const categories = Array.from(new Set(templates.map((t) => t.category)));

  return (
    <div className="container">
      <div className="eyebrow">Catalogue</div>
      <h1>Browse templates</h1>
      <p className="lede">Search or filter by category, then open a template to see its full detail.</p>

      <input placeholder="Search by title…" value={search} onChange={(e) => setSearch(e.target.value)} />
      <div className="row" style={{ marginBottom: 24 }}>
        <button className={"pill-filter " + (category === "" ? "active" : "")} onClick={() => setCategory("")}>
          All
        </button>
        {categories.map((c) => (
          <button
            key={c}
            className={"pill-filter " + (category === c ? "active" : "")}
            onClick={() => setCategory(c)}
          >
            {c}
          </button>
        ))}
      </div>

      {error && <div className="error">{error}</div>}

      <div className="grid">
        {templates.map((t) => (
          <Link key={t.id} href={`/templates/${t.id}`} className="card card-link">
            <span className={"badge " + (t.tier === "pro" ? "tier-pro" : "tier-free")}>
              {t.tier === "pro" ? "Pro" : "Free"}
            </span>
            {t.mode !== "guided_self_serve" && (
              <span className="badge">{t.mode === "advocate_only" ? "Advocate-only" : "Advocate-reviewed"}</span>
            )}
            <h3 style={{ fontSize: 18, margin: "10px 0 4px" }}>{t.title}</h3>
            <div className="muted">{t.category}</div>
          </Link>
        ))}
        {loaded && templates.length === 0 && !error && (
          <p className="muted">No templates match this filter yet.</p>
        )}
      </div>
    </div>
  );
}
