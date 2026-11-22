-- DHARA Template Studio — seed data
-- Satisfies TS-08: migrates DHARA's 4 existing hardcoded drafts into the
-- template engine as real, published seed templates (EN only for now —
-- HI/MR variants are a content task, not a schema task, see TS-11).
--
-- Run after schema.sql. Idempotent: safe to re-run.

-- 1. Cheque bounce (Section 138, Negotiable Instruments Act)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'cheque-bounce-notice',
  'Cheque Bounce — Legal Notice',
  'Consumer Disputes',
  'Negotiable Instruments Act 1881, Section 138',
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
  'Transfer of Property Act 1882; applicable state Rent Control Act',
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

-- 3. Unpaid salary demand notice
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'unpaid-salary-notice',
  'Unpaid Salary — Demand Notice',
  'Employment & Labour',
  'Payment of Wages Act 1936; Code on Wages 2019',
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

-- 4. Police complaint (non-FIR written complaint)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'police-complaint-letter',
  'Written Police Complaint',
  'Civil Notices',
  'Code of Criminal Procedure / Bharatiya Nagarik Suraksha Sanhita 2023, Section 173',
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

-- Give each seed template a version 1 and publish it directly (seed data
-- only — real content always goes through the legal + language review
-- flow in reviews / the Admin API).
do $$
declare
  t record;
  v_id uuid;
begin
  for t in
    select templates.id as id, x.content_seed as content_seed
    from (
      values
        ('cheque-bounce-notice', '{"body":"[Seed content placeholder — replace with legally reviewed text before real launch]"}'::jsonb),
        ('deposit-refund-notice', '{"body":"[Seed content placeholder — replace with legally reviewed text before real launch]"}'::jsonb),
        ('unpaid-salary-notice', '{"body":"[Seed content placeholder — replace with legally reviewed text before real launch]"}'::jsonb),
        ('police-complaint-letter', '{"body":"[Seed content placeholder — replace with legally reviewed text before real launch]"}'::jsonb)
    ) as x(slug, content_seed)
    join templates on templates.slug = x.slug
  loop
    if not exists (select 1 from template_versions where template_id = t.id) then
      insert into template_versions (template_id, version_number, content, status, published_at)
      values (t.id, 1, t.content_seed, 'published', now())
      returning id into v_id;

      insert into template_variants (version_id, locale, rendered_content, status)
      values (v_id, 'en', t.content_seed, 'published');
    end if;
  end loop;
end $$;
