import { supabase } from "./supabase";

const API_URL = process.env.NEXT_PUBLIC_API_URL!;

async function authHeader(): Promise<Record<string, string>> {
  const { data } = await supabase.auth.getSession();
  const token = data.session?.access_token;
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const headers = {
    "Content-Type": "application/json",
    ...(await authHeader()),
    ...(init.headers || {}),
  };
  const res = await fetch(`${API_URL}${path}`, { ...init, headers });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`${res.status} ${res.statusText}: ${body}`);
  }
  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}

// -------------------------------------------------------------- templates --
export type Template = {
  id: string;
  slug: string;
  title: string;
  category: string;
  legal_basis: string | null;
  tier: "free" | "pro";
  mode: "guided_self_serve" | "advocate_reviewed" | "advocate_only";
  status: string;
  field_schema: { key: string; label: string; type: string; required: boolean }[];
};

export const api = {
  listTemplates: (params: { category?: string; tier?: string; search?: string } = {}) => {
    const qs = new URLSearchParams(params as Record<string, string>).toString();
    return request<{ items: Template[] }>(`/templates${qs ? `?${qs}` : ""}`);
  },
  getTemplate: (id: string) => request<Template>(`/templates/${id}`),

  createDraft: (template_id: string, locale: "en" | "hi" | "mr" = "en") =>
    request(`/drafts`, { method: "POST", body: JSON.stringify({ template_id, locale }) }),
  listMyDrafts: () => request<{ items: any[] }>(`/drafts`),
  getDraft: (id: string) => request<any>(`/drafts/${id}`),
  updateDraft: (id: string, fields: Record<string, unknown>) =>
    request(`/drafts/${id}`, { method: "PATCH", body: JSON.stringify({ fields }) }),
  deleteDraft: (id: string) => request(`/drafts/${id}`, { method: "DELETE" }),
  duplicateDraft: (id: string) => request(`/drafts/${id}/duplicate`, { method: "POST" }),

  exportDraftUrl: (id: string, format: "pdf" | "docx") => `${API_URL}/drafts/${id}/export?format=${format}`,

  getAccount: () => request<any>(`/account`),
  updateAccount: (payload: { display_name?: string }) =>
    request(`/account`, { method: "PATCH", body: JSON.stringify(payload) }),
  requestAdvocateVerification: (bar_id: string, document_refs: string[] = []) =>
    request(`/account/advocate-verification`, {
      method: "POST",
      body: JSON.stringify({ bar_id, document_refs }),
    }),

  subscribe: (plan: "pro", billing_cycle: "monthly" | "annual") =>
    request<{ checkout_url: string }>(`/billing/subscribe`, {
      method: "POST",
      body: JSON.stringify({ plan, billing_cycle }),
    }),

  // ------------------------------------------------------------- admin ----
  adminListTemplates: (status?: string) =>
    request<{ items: any[] }>(`/admin/templates${status ? `?status=${status}` : ""}`),
  adminCreateTemplate: (payload: Record<string, unknown>) =>
    request(`/admin/templates`, { method: "POST", body: JSON.stringify(payload) }),
  adminAddVersion: (templateId: string, content: Record<string, unknown>) =>
    request(`/admin/templates/${templateId}/version`, { method: "POST", body: JSON.stringify({ content }) }),
  adminReview: (
    templateId: string,
    versionId: string,
    payload: { stage: "legal" | "language"; locale?: string; decision: "approved" | "rejected"; comment?: string }
  ) =>
    request(`/admin/templates/${templateId}/review?version_id=${versionId}`, {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  adminPublish: (templateId: string, versionId: string) =>
    request(`/admin/templates/${templateId}/publish?version_id=${versionId}`, { method: "POST" }),
};
