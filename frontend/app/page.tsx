"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";
import { CATALOGUE, CATEGORIES } from "@/lib/catalogue";

gsap.registerPlugin(useGSAP, ScrollTrigger);

const REASONS = ["Funds insufficient", "Account closed", "Payment stopped by drawer", "Signature differs"];
const PLEDGE = "No template goes live until an advocate has read it, line by line, against the law as it stands today.";

function Blank({ value, hint }: { value: string; hint: string }) {
  // key={value} remounts the span so the highlight replays on each change
  return value ? (
    <span key={value} className="blank changed">{value}</span>
  ) : (
    <span className="blank empty">{hint}</span>
  );
}

function Notice({ you, them, rupees, reason }: { you: string; them: string; rupees: string; reason: string }) {
  return (
    <div className="sheet-body">
      <p className="doc-title">LEGAL NOTICE</p>
      <p>
        To,<br />
        <Blank value={them} hint="name of the person who gave the cheque" />
      </p>
      <p>Subject: Notice under Section 138 of the Negotiable Instruments Act, 1881, regarding dishonour of cheque</p>
      <p>
        1. You had issued a cheque for a sum of INR <Blank value={rupees} hint="amount" /> in favour of{" "}
        <Blank value={you} hint="your name" />, towards discharge of a legally enforceable debt.
      </p>
      <p>
        2. The said cheque was presented for payment but was returned unpaid, for the reason stated by the bank
        as: &ldquo;<Blank value={reason} hint="reason" />&rdquo;.
      </p>
      <p>
        3. You are hereby called upon to pay the said sum of INR <Blank value={rupees} hint="amount" /> within
        fifteen (15) days from the date of receipt of this notice.
      </p>
      <p>
        Yours faithfully,<br />
        <Blank value={you} hint="your name" />
      </p>
    </div>
  );
}

export default function Home() {
  const root = useRef<HTMLDivElement>(null);
  const [you, setYou] = useState("Meera Iyer");
  const [them, setThem] = useState("Kiran Traders");
  const [amount, setAmount] = useState("75000");
  const [reason, setReason] = useState(REASONS[0]);
  const [category, setCategory] = useState("");

  const rupees = amount ? Number(amount).toLocaleString("en-IN") : "";
  const rows = category ? CATALOGUE.filter((c) => c.category === category) : CATALOGUE;

  useGSAP(
    () => {
      const mm = gsap.matchMedia();

      // All motion lives behind this query. With reduced motion, or if this
      // never runs, the page is complete and static.
      mm.add("(prefers-reduced-motion: no-preference)", () => {
        // 1. Opening: headline rises line by line, the sheet lifts in, the stamp lands.
        const intro = gsap.timeline({ defaults: { ease: "expo.out" } });
        intro
          // y: 0 clears the pixel offset GSAP reads from the pre-hide CSS transform
          .fromTo(".h-line > span", { yPercent: 112, y: 0 }, { yPercent: 0, y: 0, duration: 1.15, stagger: 0.09 })
          .fromTo("[data-in]", { autoAlpha: 0, y: 18 }, { autoAlpha: 1, y: 0, duration: 0.9, stagger: 0.08 }, 0.45)
          .fromTo(".stage", { autoAlpha: 0, y: 70 }, { autoAlpha: 1, y: 0, duration: 1.4 }, 0.1)
          .fromTo(
            ".hero-seal",
            { autoAlpha: 0, scale: 2.6, rotation: -34 },
            { autoAlpha: 0.9, scale: 1, rotation: -11, duration: 0.3, ease: "power4.in" },
            1.2
          )
          .to(".sheet-jolt", { y: 6, duration: 0.06, yoyo: true, repeat: 1, ease: "power1.inOut" }, ">");
        document.documentElement.classList.add("motion-ready");

        // 2. Sections ease in once as they arrive.
        gsap.utils.toArray<HTMLElement>(".reveal").forEach((el) => {
          gsap.from(el, {
            autoAlpha: 0, y: 30, duration: 1, ease: "expo.out",
            scrollTrigger: { trigger: el, start: "top 86%", once: true },
          });
        });

        // 3. The rule above the steps draws itself; the numerals follow.
        gsap.from(".steps-rule", {
          scaleX: 0, transformOrigin: "left center", ease: "none",
          scrollTrigger: { trigger: ".steps", start: "top 85%", end: "top 45%", scrub: true },
        });
        gsap.from(".step", {
          autoAlpha: 0, y: 26, duration: 0.9, stagger: 0.12, ease: "expo.out",
          scrollTrigger: { trigger: ".steps", start: "top 80%", once: true },
        });

        // 4. The pledge lights up word by word as you read down.
        gsap.fromTo(
          ".pledge-word",
          { opacity: 0.2 },
          {
            opacity: 1, stagger: 0.08, ease: "none",
            scrollTrigger: { trigger: ".pledge-text", start: "top 78%", end: "bottom 48%", scrub: true },
          }
        );
      });

      // Pointer tilt on the hero sheet: desktop with a mouse only.
      mm.add("(prefers-reduced-motion: no-preference) and (min-width: 901px) and (pointer: fine)", () => {
        const hero = root.current?.querySelector<HTMLElement>(".hero-night");
        if (!hero) return;
        gsap.set(".sheet3d", { rotationX: 9, rotationY: -15, rotationZ: 1.5 });
        const rx = gsap.quickTo(".sheet3d", "rotationX", { duration: 0.9, ease: "power3" });
        const ry = gsap.quickTo(".sheet3d", "rotationY", { duration: 0.9, ease: "power3" });
        const move = (e: PointerEvent) => {
          const r = hero.getBoundingClientRect();
          rx(9 - ((e.clientY - r.top) / r.height - 0.5) * 9);
          ry(-15 + ((e.clientX - r.left) / r.width - 0.5) * 12);
        };
        const leave = () => { rx(9); ry(-15); };
        hero.addEventListener("pointermove", move);
        hero.addEventListener("pointerleave", leave);
        return () => {
          hero.removeEventListener("pointermove", move);
          hero.removeEventListener("pointerleave", leave);
        };
      });
    },
    { scope: root }
  );

  const marquee = CATALOGUE.map((c) => c.title);

  return (
    <div ref={root}>
      <section className="hero-night">
        <div className="wrap hero-grid">
          <div>
            <h1 className="hero-title">
              <span className="h-line"><span>Answer in</span></span>
              <span className="h-line"><span>plain words.</span></span>
              <span className="h-line"><span>Leave with the</span></span>
              <span className="h-line"><span>legal document.</span></span>
            </h1>
            <p className="hero-lede" data-in>
              Notices, agreements, affidavits and complaints under Indian law, drafted from your answers and
              ready to print, sign and send.
            </p>
            <div className="row" data-in>
              <Link className="btn on-night" href="/browse">Browse 25 documents</Link>
              <a className="btn ghost-night" href="#try">Try one now</a>
            </div>
            <p className="hero-note" data-in>Free to start. Written for the 2023 criminal codes and the 2019 wage code.</p>
          </div>

          <div className="stage" aria-hidden="true">
            <div className="sheet-jolt">
              <div className="sheet3d">
                <div className="ghost-sheet g2" />
                <div className="ghost-sheet g1" />
                <div className="sheet lit">
                  <div className="sheet-band">
                    <span>Cheque bounce notice</span>
                    <span>Page 1 of 1</span>
                  </div>
                  <Notice you="Meera Iyer" them="Kiran Traders" rupees="75,000" reason="Funds insufficient" />
                  <div className="seal hero-seal">Sample<br />not for<br />sending</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="marquee" aria-hidden="true">
          <div className="marquee-track">
            {[...marquee, ...marquee].map((t, i) => (
              <span key={i}>{t}</span>
            ))}
          </div>
        </div>
      </section>

      <section className="band" id="try">
        <div className="wrap">
          <div className="section-head reveal">
            <h2>Change an answer. Watch the notice change.</h2>
            <p>This is the real thing, cut down to four questions. The full notice asks ten.</p>
          </div>
          <div className="try-grid reveal">
            <div className="ask">
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
            <div className="sheet" aria-live="polite">
              <div className="sheet-band">
                <span>Cheque bounce notice</span>
                <span>Live preview</span>
              </div>
              <Notice you={you} them={them} rupees={rupees} reason={reason} />
            </div>
          </div>
        </div>
      </section>

      <section className="band">
        <div className="wrap">
          <div className="section-head reveal">
            <h2>Twenty-five documents people actually need</h2>
            <p>Each one names the law it rests on. The ones marked in pink go to an advocate before they come back to you.</p>
          </div>
          <div className="row filters reveal">
            <button className={"pill-filter " + (category === "" ? "active" : "")} onClick={() => setCategory("")}>
              All
            </button>
            {CATEGORIES.map((c) => (
              <button key={c} className={"pill-filter " + (category === c ? "active" : "")} onClick={() => setCategory(c)}>
                {c}
              </button>
            ))}
          </div>
          <div className="register reveal">
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
        </div>
      </section>

      <section className="band">
        <div className="wrap">
          <div className="section-head reveal">
            <h2>From question to signed paper</h2>
          </div>
          <div className="steps">
            <div className="steps-rule" />
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
        </div>
      </section>

      <section className="night-band">
        <div className="wrap">
          <p className="pledge-text">
            {PLEDGE.split(" ").map((w, i) => (
              <span key={i} className="pledge-word">{w} </span>
            ))}
          </p>
          <ul className="pledge-list reveal">
            <li>Each template shows the Act and section it relies on</li>
            <li>Templates are checked again when the law changes</li>
            <li>We are not a law firm, and a template is not legal advice</li>
          </ul>
        </div>
      </section>

      <section className="band closing-band">
        <div className="wrap closing reveal">
          <h2>Start with the document you came for.</h2>
          <Link className="btn big" href="/browse">Browse 25 documents</Link>
        </div>
      </section>
    </div>
  );
}
