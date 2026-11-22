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
      <h1>Documents</h1>
      <p className="lede">Search by name or narrow by category, then open one to see what it asks you.</p>

      <input placeholder="Search documents" aria-label="Search documents" value={search} onChange={(e) => setSearch(e.target.value)} />
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

      <div className="register">
        <div className="register-row register-head">
          <span>Document</span>
          <span>Category</span>
          <span>Access</span>
        </div>
        {templates.map((t) => (
          <Link key={t.id} href={`/templates/${t.id}`} className="register-row">
            <span className="doc">{t.title}</span>
            <span className="law">{t.category}</span>
            <span className={"who" + (t.mode !== "guided_self_serve" ? " advocate" : "")}>
              {t.tier === "pro" ? "Pro" : "Free"}
              {t.mode === "advocate_only" ? ", advocates only" : t.mode !== "guided_self_serve" ? ", advocate check" : ""}
            </span>
          </Link>
        ))}
        {loaded && templates.length === 0 && !error && (
          <div className="register-row">
            <span className="law">No document matches. Clear the search or pick another category.</span>
          </div>
        )}
      </div>
    </div>
  );
}
