-- DHARA Template Studio — seed data
-- Satisfies TS-08: migrates DHARA's 4 existing hardcoded drafts into the
-- template engine as real seed templates (EN only for now — HI/MR variants
-- are a content task, not a schema task, see TS-11).
--
-- IMPORTANT — these load as status='draft', not 'published'. The body text
-- below is a real, usable first draft (written 2026-11-22, legal-basis
-- citations checked against current law as of that date), but it has NOT
-- been reviewed by a lawyer. Per this product's own lifecycle (see
-- ADR-001 and the Admin API's /review and /publish endpoints), nothing may
-- reach a real citizen until it passes legal review — these rows are the
-- starting point for that review, not a shortcut around it.
--
-- Run after schema.sql. Idempotent: safe to re-run.

-- 1. Cheque bounce (Section 138, Negotiable Instruments Act, 1881 — still
-- the governing provision; unchanged as of 2026-11-22)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'cheque-bounce-notice',
  'Cheque Bounce — Legal Notice',
  'Consumer Disputes',
  'Negotiable Instruments Act, 1881, Section 138',
  'free', 'guided_self_serve',
  '[
    {"key":"sender_name","label":"Your full name","type":"text","required":true},
    {"key":"sender_address","label":"Your address","type":"textarea","required":true},
    {"key":"recipient_name","label":"Cheque issuer''s full name","type":"text","required":true},
    {"key":"recipient_address","label":"Cheque issuer''s address","type":"textarea","required":true},
    {"key":"cheque_number","label":"Cheque number","type":"text","required":true},
    {"key":"cheque_date","label":"Cheque date","type":"date","required":true},
    {"key":"cheque_amount","label":"Cheque amount (INR)","type":"number","required":true},
    {"key":"bank_name","label":"Bank name","type":"text","required":true},
    {"key":"bounce_reason","label":"Reason stated by bank","type":"text","required":true},
    {"key":"bounce_date","label":"Date cheque was returned","type":"date","required":true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 2. Security deposit refund demand
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'deposit-refund-notice',
  'Security Deposit Refund — Demand Letter',
  'Property & Tenancy',
  'Transfer of Property Act, 1882; the applicable state Rent Control / Tenancy Act',
  'free', 'guided_self_serve',
  '[
    {"key":"tenant_name","label":"Your full name","type":"text","required":true},
    {"key":"tenant_address","label":"Your current address","type":"textarea","required":true},
    {"key":"landlord_name","label":"Landlord''s full name","type":"text","required":true},
    {"key":"property_address","label":"Rented property address","type":"textarea","required":true},
    {"key":"deposit_amount","label":"Deposit amount (INR)","type":"number","required":true},
    {"key":"tenancy_start_date","label":"Tenancy start date","type":"date","required":true},
    {"key":"vacate_date","label":"Date you vacated","type":"date","required":true},
    {"key":"deduction_dispute","label":"Any deductions you are disputing","type":"textarea","required":false}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 3. Unpaid salary demand notice — legal basis updated 2026-11-22. The old
-- Payment of Wages Act 1936 is superseded: the Code on Wages, 2019 came
-- into force 21 Nov 2025, with its Central Rules notified 8 May 2026.
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'unpaid-salary-notice',
  'Unpaid Salary — Demand Notice',
  'Employment & Labour',
  'Code on Wages, 2019 (in force from 21 Nov 2025) and the Code on Wages (Central) Rules, 2026 — supersedes the Payment of Wages Act, 1936',
  'free', 'guided_self_serve',
  '[
    {"key":"employee_name","label":"Your full name","type":"text","required":true},
    {"key":"employee_address","label":"Your address","type":"textarea","required":true},
    {"key":"employer_name","label":"Employer / company name","type":"text","required":true},
    {"key":"employer_address","label":"Employer''s registered address","type":"textarea","required":true},
    {"key":"designation","label":"Your designation","type":"text","required":true},
    {"key":"unpaid_months","label":"Month(s) salary is unpaid for","type":"text","required":true},
    {"key":"unpaid_amount","label":"Total unpaid amount (INR)","type":"number","required":true},
    {"key":"last_working_date","label":"Last working date (if applicable)","type":"date","required":false}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 4. Police complaint (non-FIR written complaint) — legal basis updated
-- 2026-11-22. CrPC Section 154 was replaced by BNSS Section 173 on
-- 1 July 2024; citing only BNSS now.
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'police-complaint-letter',
  'Written Police Complaint',
  'Civil Notices',
  'Bharatiya Nagarik Suraksha Sanhita, 2023, Section 173 (replaced Section 154 of the CrPC, 1973, on 1 July 2024)',
  'free', 'advocate_reviewed',
  '[
    {"key":"complainant_name","label":"Your full name","type":"text","required":true},
    {"key":"complainant_address","label":"Your address","type":"textarea","required":true},
    {"key":"police_station","label":"Police station name","type":"text","required":true},
    {"key":"incident_date","label":"Date of incident","type":"date","required":true},
    {"key":"incident_location","label":"Location of incident","type":"text","required":true},
    {"key":"incident_description","label":"Describe what happened","type":"textarea","required":true},
    {"key":"accused_details","label":"Details of accused (if known)","type":"textarea","required":false}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- Give each seed template a version 1, loaded as DRAFT — not published.
-- A reviewer (or you, logged in as admin) must run these through
-- POST /admin/templates/{id}/review and then /publish before they are
-- ever visible to a real citizen. See the Admin dashboard page.
do $$
declare
  t record;
  v_id uuid;
begin
  for t in
    select templates.id as id, seeded.content_seed as content_seed
    from (
      values
        ('cheque-bounce-notice', $body$
LEGAL NOTICE

To,
{{recipient_name}}
{{recipient_address}}

From,
{{sender_name}}
{{sender_address}}

Subject: Legal notice under Section 138 of the Negotiable Instruments Act, 1881, regarding dishonour of cheque

Dear {{recipient_name}},

Under instructions from {{sender_name}}, I serve upon you this legal notice as follows:

1. You had issued cheque number {{cheque_number}} dated {{cheque_date}}, drawn on {{bank_name}}, for a sum of INR {{cheque_amount}}, in favour of {{sender_name}}, towards discharge of a legally enforceable debt or liability.

2. The said cheque was presented for payment through proper banking channels but was returned unpaid on {{bounce_date}}, for the reason stated by the bank as: "{{bounce_reason}}".

3. You are hereby called upon to pay the said sum of INR {{cheque_amount}} to {{sender_name}} within fifteen (15) days from the date of receipt of this notice.

4. Please note that failure to make payment within the stipulated period of 15 days shall leave {{sender_name}} with no option but to initiate criminal proceedings against you under Section 138 of the Negotiable Instruments Act, 1881, besides pursuing civil remedies for recovery of the amount, entirely at your risk, cost, and consequences.

A copy of this notice is retained for record and may be produced before the competent court if required.

Yours faithfully,
{{sender_name}}
$body$::text),
        ('deposit-refund-notice', $body$
To,
{{landlord_name}}

From,
{{tenant_name}}
{{tenant_address}}

Subject: Demand for refund of security deposit

Dear {{landlord_name}},

I was a tenant at {{property_address}} under a tenancy that commenced on {{tenancy_start_date}}. I vacated the said premises on {{vacate_date}}, after handing over vacant and peaceful possession along with the keys.

At the commencement of the tenancy, I had paid you a sum of INR {{deposit_amount}} as a refundable security deposit. Despite a reasonable period having passed since I vacated the premises, this deposit has not been refunded to me.

{{deduction_dispute}}

I hereby call upon you to refund the security deposit of INR {{deposit_amount}}, after adjusting only such lawful deductions as are supported by documentary proof, within fifteen (15) days of receipt of this letter.

Please note that in the absence of a refund within the stipulated period, I shall be constrained to pursue appropriate legal remedies available to me, including proceedings before the competent Rent Authority, Consumer Forum, or Civil Court, entirely at your cost and risk.

Yours faithfully,
{{tenant_name}}
$body$::text),
        ('unpaid-salary-notice', $body$
To,
{{employer_name}}
{{employer_address}}

From,
{{employee_name}}
{{employee_address}}

Subject: Demand notice for payment of unpaid wages under the Code on Wages, 2019

Dear Sir/Madam,

I, {{employee_name}}, was employed with {{employer_name}} in the capacity of {{designation}}.

Despite rendering due service, my wages for the period {{unpaid_months}}, amounting to INR {{unpaid_amount}}, remain unpaid as on the date of this notice.

This is in violation of the timely-payment-of-wages obligations under the Code on Wages, 2019, and the Code on Wages (Central) Rules, 2026.

I hereby call upon you to release the outstanding wages of INR {{unpaid_amount}} within seven (7) days of receipt of this notice.

Please note that failure to pay the said amount within the stipulated period shall leave me with no option but to approach the jurisdictional labour authority and/or the competent court for recovery of the unpaid wages, together with applicable compensation, entirely at your cost, risk, and consequences.

Yours faithfully,
{{employee_name}}
{{designation}}
$body$::text),
        ('police-complaint-letter', $body$
To,
The Station House Officer,
{{police_station}}

Subject: Written complaint regarding an incident dated {{incident_date}}

Respected Sir/Madam,

I, {{complainant_name}}, residing at {{complainant_address}}, wish to lodge this complaint regarding an incident that occurred on {{incident_date}} at {{incident_location}}.

Details of the incident:
{{incident_description}}

{{accused_details}}

I request that this complaint be registered and investigated in accordance with law, including Section 173 of the Bharatiya Nagarik Suraksha Sanhita, 2023, which provides for mandatory registration of information disclosing a cognisable offence.

I am available to provide any further information or assistance that may be required for the investigation.

Yours faithfully,
{{complainant_name}}
$body$::text)
    ) as x(slug, body_text)
    join templates on templates.slug = x.slug
    cross join lateral (select jsonb_build_object('body', x.body_text) as content_seed) seeded
  loop
    if not exists (select 1 from template_versions where template_id = t.id) then
      insert into template_versions (template_id, version_number, content, status)
      values (t.id, 1, t.content_seed, 'draft')
      returning id into v_id;

      insert into template_variants (version_id, locale, rendered_content, status)
      values (v_id, 'en', t.content_seed, 'draft');
    end if;
  end loop;
end $$;
