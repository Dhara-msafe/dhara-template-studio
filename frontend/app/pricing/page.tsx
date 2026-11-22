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
      <h1>Pricing</h1>
      <div className="row" style={{ marginBottom: 16 }}>
        <button className={cycle === "monthly" ? "" : "secondary"} onClick={() => setCycle("monthly")}>
          Monthly
        </button>
        <button className={cycle === "annual" ? "" : "secondary"} onClick={() => setCycle("annual")}>
          Annual
        </button>
      </div>
      {error && <div className="error">{error}</div>}
      <div className="grid">
        <div className="card">
          <h2>Free</h2>
          <p className="muted">Guided, self-serve templates</p>
          <ul>
            <li>Browse the full catalogue</li>
            <li>Fill &amp; download Free-tier templates</li>
            <li>Save drafts to your account</li>
          </ul>
        </div>
        <div className="card">
          <h2>Pro — {proPrice}</h2>
          <p className="muted">Everything in Free, plus Pro-tier templates</p>
          <ul>
            <li>All Free-tier benefits</li>
            <li>Access to Pro-tier templates</li>
            <li>Priority support</li>
          </ul>
          <button onClick={upgrade}>Upgrade to Pro</button>
        </div>
      </div>
    </div>
  );
}
