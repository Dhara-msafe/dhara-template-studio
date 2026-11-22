"use client";

import { useState } from "react";
import { api } from "@/lib/api";

export default function PricingPage() {
  const [cycle, setCycle] = useState<"monthly" | "annual">("monthly");
  const [error, setError] = useState<string | null>(null);

  // Illustrative only — real Pro pricing is still an open decision
  // (see docs/BUILD_PLAN.md).
  const proPrice = cycle === "monthly" ? "[YOUR PRICE] / month" : "[YOUR PRICE] / year";

  async function upgrade() {
    setError(null);
    try {
      const { checkout_url } = await api.subscribe("pro", cycle);
      window.location.href = checkout_url;
    } catch (err: any) {
      setError(err.message || "Could not start checkout");
    }
  }

  return (
    <div className="container">
      <div className="eyebrow">Pricing</div>
      <h1>Free to start. Pro when you need more.</h1>
      <p className="lede">Transparent, side by side — no surprises on a legal product.</p>

      <div className="row" style={{ marginBottom: 24 }}>
        <button className={"pill-filter " + (cycle === "monthly" ? "active" : "")} onClick={() => setCycle("monthly")}>
          Monthly
        </button>
        <button className={"pill-filter " + (cycle === "annual" ? "active" : "")} onClick={() => setCycle("annual")}>
          Annual
        </button>
      </div>
      {error && <div className="error">{error}</div>}

      <div className="grid cols-2">
        <div className="card">
          <div className="eyebrow">Free</div>
          <h2 style={{ fontSize: 26 }}>₹0</h2>
          <p className="muted" style={{ marginBottom: 18 }}>Guided, self-serve templates</p>
          <ul style={{ paddingLeft: 18 }}>
            <li>Browse the full catalogue</li>
            <li>Fill &amp; download Free-tier templates</li>
            <li>Save drafts to your account</li>
          </ul>
        </div>
        <div className="card dark">
          <div className="eyebrow">Pro</div>
          <h2 style={{ fontSize: 26 }}>{proPrice}</h2>
          <p className="muted" style={{ marginBottom: 18 }}>Everything in Free, plus the full catalogue</p>
          <ul style={{ paddingLeft: 18 }}>
            <li>All Free-tier benefits</li>
            <li>Access to Pro-tier templates</li>
            <li>Priority support</li>
          </ul>
          <button onClick={upgrade} style={{ width: "100%", marginTop: 8 }}>
            Upgrade to Pro
          </button>
        </div>
      </div>
    </div>
  );
}
