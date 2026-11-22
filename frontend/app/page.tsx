"use client";

import { useState } from "react";
import Link from "next/link";
import { CATALOGUE, CATEGORIES } from "@/lib/catalogue";

const REASONS = ["Funds insufficient", "Account closed", "Payment stopped by drawer", "Signature differs"];

function Blank({ value, hint }: { value: string; hint: string }) {
  // key={value} remounts the span so the highlight animation replays on each change
  return value ? (
    <span key={value} className="blank changed">{value}</span>
  ) : (
    <span className="blank empty">{hint}</span>
  );
}

export default function Home() {
  const [you, setYou] = useState("Meera Iyer");
  const [them, setThem] = useState("Kiran Traders");
  const [amount, setAmount] = useState("75000");
  const [reason, setReason] = useState(REASONS[0]);
  const [category, setCategory] = useState("");

  const rupees = amount ? Number(amount).toLocaleString("en-IN") : "";
  const rows = category ? CATALOGUE.filter((c) => c.category === category) : CATALOGUE;

  return (
    <div className="container">
      <section className="hero">
        <div>
          <h1>Answer plain questions. Get the legal document.</h1>
          <p className="lede">
            Notices, agreements, affidavits and complaints under Indian law. Try it here: change an answer and
            watch the notice rewrite itself.
          </p>

          <div className="ask">
            <div className="ask-title">Cheque bounce notice, 4 of 10 questions</div>
            <label htmlFor="q-you">Your name</label>
            <input id="q-you" value={you} onChange={(e) => setYou(e.target.value)} />
            <label htmlFor="q-them">Who gave you the cheque?</label>
            <input id="q-them" value={them} onChange={(e) => setThem(e.target.value)} />
            <label htmlFor="q-amount">Cheque amount in rupees</label>
            <input id="q-amount" inputMode="numeric" value={amount} onChange={(e) => setAmount(e.target.value.replace(/\D/g, ""))} />
            <label htmlFor="q-reason">What did the bank say?</label>
            <select id="q-reason" value={reason} onChange={(e) => setReason(e.target.value)}>
              {REASONS.map((r) => (
                <option key={r}>{r}</option>
              ))}
            </select>
          </div>
          <div className="row hero-actions">
            <Link className="btn" href="/browse">Browse all 25 documents</Link>
            <Link className="btn secondary" href="/pricing">See what is free</Link>
          </div>
        </div>

        <div className="sheet" aria-live="polite">
          <div className="sheet-band">
            <span>Cheque bounce notice</span>
            <span>Page 1 of 1</span>
          </div>
          <div className="sheet-body">
            <p className="doc-title">LEGAL NOTICE</p>
            <p>
              To,<br />
              <Blank value={them} hint="name of the person who gave the cheque" />
            </p>
            <p>
              Subject: Notice under Section 138 of the Negotiable Instruments Act, 1881, regarding dishonour of
              cheque
            </p>
            <p>
              1. You had issued a cheque for a sum of INR <Blank value={rupees} hint="amount" /> in favour of{" "}
              <Blank value={you} hint="your name" />, towards discharge of a legally enforceable debt.
            </p>
            <p>
              2. The said cheque was presented for payment but was returned unpaid, for the reason stated by
              the bank as: &ldquo;<Blank value={reason} hint="reason" />&rdquo;.
            </p>
            <p>
              3. You are hereby called upon to pay the said sum of INR <Blank value={rupees} hint="amount" />{" "}
              within fifteen (15) days from the date of receipt of this notice.
            </p>
            <p>
              Yours faithfully,<br />
              <Blank value={you} hint="your name" />
            </p>
          </div>
          <div className="seal">Sample<br />not for<br />sending</div>
        </div>
      </section>

      <section className="section">
        <div className="section-head">
          <h2>Twenty-five documents people actually need</h2>
          <p>Each one names the law it rests on. The ones marked in pink go to an advocate before they come back to you.</p>
        </div>
        <div className="row filters">
          <button className={"pill-filter " + (category === "" ? "active" : "")} onClick={() => setCategory("")}>
            All
          </button>
          {CATEGORIES.map((c) => (
            <button key={c} className={"pill-filter " + (category === c ? "active" : "")} onClick={() => setCategory(c)}>
              {c}
            </button>
          ))}
        </div>
        <div className="register">
          <div className="register-row register-head">
            <span>Document</span>
            <span>Law it rests on</span>
            <span>Who checks it</span>
          </div>
          {rows.map((c) => (
            <Link key={c.title} href="/browse" className="register-row">
              <span className="doc">{c.title}</span>
              <span className="law">{c.law}</span>
              <span className={"who" + (c.advocate ? " advocate" : "")}>{c.advocate ? "Advocate" : "You"}</span>
            </Link>
          ))}
        </div>
      </section>

      <section className="section">
        <div className="section-head">
          <h2>From question to signed paper</h2>
        </div>
        <div className="steps">
          <div className="step">
            <h3>Pick the document</h3>
            <p>Search by what happened to you, not by the name of the law.</p>
          </div>
          <div className="step">
            <h3>Answer in your own words</h3>
            <p>Type or speak. Your answers save as you go, so you can stop and come back.</p>
          </div>
          <div className="step">
            <h3>Download and send</h3>
            <p>Take it as a PDF or a Word file, print it, sign it, and send it.</p>
          </div>
        </div>
      </section>

      <section className="section pledge">
        <div>
          <h2>No template goes live until an advocate has read it.</h2>
          <p>
            Every document starts as a draft. It is checked against the current law and signed off by an
            advocate before anyone can use it, and it is checked again when the law changes.
          </p>
        </div>
        <ul>
          <li>Written for the new criminal codes and the 2019 wage code</li>
          <li>Each template shows the Act and section it relies on</li>
          <li>We are not a law firm, and a template is not legal advice</li>
        </ul>
      </section>

      <section className="section closing">
        <h2>Start with the document you came for.</h2>
        <Link className="btn" href="/browse">Browse all 25 documents</Link>
      </section>
    </div>
  );
}
