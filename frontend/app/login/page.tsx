"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { supabase } from "@/lib/supabase";

export default function LoginPage() {
  const router = useRouter();
  const [mode, setMode] = useState<"login" | "signup">("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      if (mode === "signup") {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
      }
      router.push("/browse");
    } catch (err: any) {
      setError(err.message || "Something went wrong");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container narrow">
      <div className="eyebrow">{mode === "login" ? "Welcome back" : "Create your account"}</div>
      <h1 style={{ fontSize: 28, marginBottom: 24 }}>
        {mode === "login" ? "Sign in" : "Join Template Studio"}
      </h1>
      <div className="card">
        <div className="row" style={{ marginBottom: 18 }}>
          <button className={"pill-filter " + (mode === "login" ? "active" : "")} onClick={() => setMode("login")}>
            Sign in
          </button>
          <button className={"pill-filter " + (mode === "signup" ? "active" : "")} onClick={() => setMode("signup")}>
            Create account
          </button>
        </div>
        <form onSubmit={handleSubmit}>
          <label>Email</label>
          <input type="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
          <label>Password</label>
          <input
            type="password"
            required
            minLength={8}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          {error && <div className="error">{error}</div>}
          <button type="submit" disabled={loading} style={{ width: "100%" }}>
            {loading ? "Please wait…" : mode === "login" ? "Sign in" : "Create account"}
          </button>
        </form>
        <div className="divider" />
        <p className="muted" style={{ textAlign: "center" }}>
          <a href="/browse">Continue as guest →</a>
        </p>
      </div>
    </div>
  );
}
