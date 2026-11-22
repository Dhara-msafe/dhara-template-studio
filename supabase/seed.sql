-- DHARA Template Studio — seed data
-- 20 templates: DHARA's 4 original drafts (TS-08) plus 16 added 2026-11-22, in the
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

-- ===== Templates 5-20, added 2026-11-22 (see docs/TEMPLATE_RESEARCH.md) =====

-- 5. RTI Application — Request for Information
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'rti-application',
  'RTI Application — Request for Information',
  'Government & RTI',
  'Right to Information Act, 2005, Section 6(1); Right to Information Rules, 2012 (Central fee Rs 10 — State fees differ)',
  'free', 'guided_self_serve',
  '[
    {"key": "applicant_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "applicant_address", "label": "Your postal address", "type": "textarea", "required": true},
    {"key": "applicant_phone", "label": "Your phone number or email", "type": "text", "required": false},
    {"key": "public_authority_name", "label": "Department / office you are asking", "type": "text", "required": true},
    {"key": "public_authority_address", "label": "Address of that office", "type": "textarea", "required": true},
    {"key": "information_sought", "label": "Information you want (number each point)", "type": "textarea", "required": true},
    {"key": "period_of_information", "label": "Period the information relates to (e.g. April 2024 to March 2026)", "type": "text", "required": true},
    {"key": "fee_payment_details", "label": "How you paid the fee (e.g. IPO number and date, or ''BPL — fee exempt'')", "type": "text", "required": true},
    {"key": "application_date", "label": "Date of application", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 6. RTI First Appeal
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'rti-first-appeal',
  'RTI First Appeal',
  'Government & RTI',
  'Right to Information Act, 2005, Section 19(1) (first appeal within 30 days; to be decided within 30–45 days under Section 19(6))',
  'free', 'guided_self_serve',
  '[
    {"key": "appellant_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "appellant_address", "label": "Your postal address", "type": "textarea", "required": true},
    {"key": "public_authority_name", "label": "Department / office you applied to", "type": "text", "required": true},
    {"key": "public_authority_address", "label": "Address of that office", "type": "textarea", "required": true},
    {"key": "rti_application_date", "label": "Date of your RTI application", "type": "date", "required": true},
    {"key": "rti_reference_number", "label": "RTI registration / reference number (if any)", "type": "text", "required": false},
    {"key": "pio_reply_details", "label": "PIO''s reply and its date — or write ''No reply received within 30 days''", "type": "text", "required": true},
    {"key": "information_sought", "label": "Information you had asked for", "type": "textarea", "required": true},
    {"key": "grounds_of_appeal", "label": "Why you are appealing (no reply / refused / incomplete / wrong)", "type": "textarea", "required": true},
    {"key": "appeal_date", "label": "Date of this appeal", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 7. Consumer Complaint — Legal Notice to Seller / Service Provider
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'consumer-legal-notice',
  'Consumer Complaint — Legal Notice to Seller / Service Provider',
  'Consumer Disputes',
  'Consumer Protection Act, 2019 — Sections 2(7), 2(10), 2(11), 2(47) and 35; limitation of two years under Section 69',
  'free', 'guided_self_serve',
  '[
    {"key": "consumer_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "consumer_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "company_name", "label": "Seller / service provider name", "type": "text", "required": true},
    {"key": "company_address", "label": "Their registered or office address", "type": "textarea", "required": true},
    {"key": "product_or_service", "label": "Product or service purchased", "type": "text", "required": true},
    {"key": "purchase_date", "label": "Date of purchase / booking", "type": "date", "required": true},
    {"key": "invoice_number", "label": "Invoice / order number", "type": "text", "required": true},
    {"key": "amount_paid", "label": "Amount paid (INR)", "type": "number", "required": true},
    {"key": "problem_description", "label": "What went wrong, and what you did about it", "type": "textarea", "required": true},
    {"key": "relief_demanded", "label": "What you want (refund / replacement / repair / compensation)", "type": "textarea", "required": true},
    {"key": "notice_date", "label": "Date of notice", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 8. Consumer Complaint — District Commission (Section 35)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'consumer-complaint-district-commission',
  'Consumer Complaint — District Commission (Section 35)',
  'Consumer Disputes',
  'Consumer Protection Act, 2019 — Sections 34, 35, 38 and 69; Consumer Protection (Jurisdiction of the District Commission, the State Commission and the National Commission) Rules, 2021 (District Commission: consideration paid up to Rs 50 lakh); filed online on e-Jagriti',
  'free', 'advocate_reviewed',
  '[
    {"key": "district_commission_place", "label": "District of the Commission (where you live or work, or where the opposite party is)", "type": "text", "required": true},
    {"key": "complainant_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "complainant_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "opposite_party_name", "label": "Opposite party (seller / service provider)", "type": "text", "required": true},
    {"key": "opposite_party_address", "label": "Opposite party''s address", "type": "textarea", "required": true},
    {"key": "product_or_service", "label": "Product or service purchased", "type": "text", "required": true},
    {"key": "transaction_date", "label": "Date of purchase / booking", "type": "date", "required": true},
    {"key": "amount_paid", "label": "Amount paid as consideration (INR)", "type": "number", "required": true},
    {"key": "facts_of_case", "label": "Facts, in date order", "type": "textarea", "required": true},
    {"key": "cause_of_action_date", "label": "Date the problem arose", "type": "date", "required": true},
    {"key": "notice_details", "label": "Notice / complaints already sent and the response (with dates)", "type": "textarea", "required": true},
    {"key": "compensation_claimed", "label": "Compensation claimed (INR)", "type": "number", "required": true},
    {"key": "other_relief", "label": "Other relief (refund / replacement / repair)", "type": "textarea", "required": true},
    {"key": "documents_list", "label": "Documents you are attaching (number each)", "type": "textarea", "required": true},
    {"key": "filing_date", "label": "Date of filing", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 9. Residential Rent Agreement (11 Months)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'residential-rent-agreement',
  'Residential Rent Agreement (11 Months)',
  'Property & Tenancy',
  'Transfer of Property Act, 1882, Sections 105–108; Registration Act, 1908, Section 17(1)(d) (leases over one year must be registered); Indian Stamp Act, 1899 / State stamp law; applicable State rent or tenancy law',
  'free', 'guided_self_serve',
  '[
    {"key": "agreement_date", "label": "Date of agreement", "type": "date", "required": true},
    {"key": "agreement_place", "label": "City where the agreement is signed", "type": "text", "required": true},
    {"key": "landlord_name", "label": "Landlord''s full name", "type": "text", "required": true},
    {"key": "landlord_address", "label": "Landlord''s address", "type": "textarea", "required": true},
    {"key": "tenant_name", "label": "Tenant''s full name", "type": "text", "required": true},
    {"key": "tenant_permanent_address", "label": "Tenant''s permanent address", "type": "textarea", "required": true},
    {"key": "property_address", "label": "Full address of the rented premises", "type": "textarea", "required": true},
    {"key": "monthly_rent", "label": "Monthly rent (INR)", "type": "number", "required": true},
    {"key": "rent_due_day", "label": "Day of the month rent is due (e.g. 5th)", "type": "text", "required": true},
    {"key": "security_deposit", "label": "Security deposit (INR)", "type": "number", "required": true},
    {"key": "start_date", "label": "Tenancy start date", "type": "date", "required": true},
    {"key": "end_date", "label": "Tenancy end date (11 months from start)", "type": "date", "required": true},
    {"key": "notice_period", "label": "Notice period for either side (e.g. one month)", "type": "text", "required": true},
    {"key": "witness_1_name", "label": "Witness 1 — name and address", "type": "text", "required": true},
    {"key": "witness_2_name", "label": "Witness 2 — name and address", "type": "text", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 10. Notice to Tenant to Vacate (Termination of Tenancy)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'tenant-vacate-notice',
  'Notice to Tenant to Vacate (Termination of Tenancy)',
  'Property & Tenancy',
  'Transfer of Property Act, 1882, Section 106 (month-to-month tenancy terminable by fifteen days'' written notice) and Section 111(h); subject to the applicable State rent-control / tenancy law',
  'free', 'advocate_reviewed',
  '[
    {"key": "landlord_name", "label": "Your full name (landlord)", "type": "text", "required": true},
    {"key": "landlord_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "tenant_name", "label": "Tenant''s full name", "type": "text", "required": true},
    {"key": "property_address", "label": "Address of the rented premises", "type": "textarea", "required": true},
    {"key": "monthly_rent", "label": "Monthly rent (INR)", "type": "number", "required": true},
    {"key": "reason_for_termination", "label": "Reason for ending the tenancy", "type": "textarea", "required": true},
    {"key": "rent_arrears", "label": "Unpaid rent, if any (INR and months) — or ''Nil''", "type": "text", "required": true},
    {"key": "notice_date", "label": "Date of notice", "type": "date", "required": true},
    {"key": "vacate_by_date", "label": "Date by which the tenant must vacate (at least 15 days after the tenant receives the notice)", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 11. Recovery of Money — Legal Notice (Loan / Dues)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'money-recovery-notice',
  'Recovery of Money — Legal Notice (Loan / Dues)',
  'Civil Notices',
  'Indian Contract Act, 1872 (Section 73); Limitation Act, 1963 (three years for recovery of money lent); Code of Civil Procedure, 1908, Order XXXVII (summary suit on a written contract)',
  'free', 'guided_self_serve',
  '[
    {"key": "lender_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "lender_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "borrower_name", "label": "Name of the person who owes you money", "type": "text", "required": true},
    {"key": "borrower_address", "label": "Their address", "type": "textarea", "required": true},
    {"key": "loan_amount", "label": "Amount given (INR)", "type": "number", "required": true},
    {"key": "loan_date", "label": "Date the money was given", "type": "date", "required": true},
    {"key": "payment_mode", "label": "How it was paid (bank transfer / cheque / UPI — with reference)", "type": "text", "required": true},
    {"key": "agreed_repayment_date", "label": "Date by which repayment was promised", "type": "date", "required": true},
    {"key": "amount_repaid", "label": "Amount repaid so far (INR; 0 if none)", "type": "number", "required": true},
    {"key": "outstanding_amount", "label": "Amount still outstanding (INR)", "type": "number", "required": true},
    {"key": "interest_terms", "label": "Agreed interest, if any — or ''No interest was agreed''", "type": "text", "required": true},
    {"key": "notice_date", "label": "Date of notice", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 12. Promissory Note (Payable on Demand)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'demand-promissory-note',
  'Promissory Note (Payable on Demand)',
  'Money & Lending',
  'Negotiable Instruments Act, 1881, Section 4; Indian Stamp Act, 1899, Schedule I, Article 49 (must be stamped at or before signing — an unstamped note cannot be admitted in evidence, Section 35)',
  'free', 'guided_self_serve',
  '[
    {"key": "place", "label": "Place of signing", "type": "text", "required": true},
    {"key": "note_date", "label": "Date", "type": "date", "required": true},
    {"key": "borrower_name", "label": "Borrower''s full name", "type": "text", "required": true},
    {"key": "borrower_address", "label": "Borrower''s address", "type": "textarea", "required": true},
    {"key": "lender_name", "label": "Lender''s full name", "type": "text", "required": true},
    {"key": "lender_address", "label": "Lender''s address", "type": "textarea", "required": true},
    {"key": "principal_amount", "label": "Amount (INR, in figures)", "type": "number", "required": true},
    {"key": "amount_in_words", "label": "Amount in words (e.g. Rupees Fifty Thousand only)", "type": "text", "required": true},
    {"key": "interest_rate", "label": "Interest rate per year (e.g. 12)", "type": "number", "required": true},
    {"key": "payment_mode", "label": "How the borrower received the money (bank transfer / cheque — with reference)", "type": "text", "required": true},
    {"key": "witness_1_name", "label": "Witness 1 — name and address", "type": "text", "required": true},
    {"key": "witness_2_name", "label": "Witness 2 — name and address", "type": "text", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 13. Affidavit for Change of Name
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'name-change-affidavit',
  'Affidavit for Change of Name',
  'Affidavits & Declarations',
  'Sworn affidavit under the Oaths Act, 1969, attested under the Notaries Act, 1952; first step of the Gazette of India (Part IV) change-of-name procedure of the Department of Publication',
  'free', 'guided_self_serve',
  '[
    {"key": "new_name", "label": "Your new name (exactly as you want it)", "type": "text", "required": true},
    {"key": "old_name", "label": "Your old name (exactly as in your documents)", "type": "text", "required": true},
    {"key": "parent_or_spouse_name", "label": "Father''s / mother''s / spouse''s name", "type": "text", "required": true},
    {"key": "age", "label": "Your age (years)", "type": "number", "required": true},
    {"key": "address", "label": "Your full address", "type": "textarea", "required": true},
    {"key": "reason_for_change", "label": "Reason for the change (e.g. marriage, spelling correction, personal choice)", "type": "text", "required": true},
    {"key": "place", "label": "Place where the affidavit is sworn", "type": "text", "required": true},
    {"key": "affidavit_date", "label": "Date", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 14. General Power of Attorney (Management — No Sale)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'general-power-of-attorney',
  'General Power of Attorney (Management — No Sale)',
  'Property & Tenancy',
  'Powers-of-Attorney Act, 1882, Sections 1A and 2; Indian Contract Act, 1872, Chapter X (agency); stamp duty under State stamp law; a power of attorney does not transfer title — Suraj Lamp & Industries v. State of Haryana (Supreme Court, 2011)',
  'free', 'advocate_reviewed',
  '[
    {"key": "execution_place", "label": "Place of signing", "type": "text", "required": true},
    {"key": "execution_date", "label": "Date", "type": "date", "required": true},
    {"key": "principal_name", "label": "Your full name (the person giving the power)", "type": "text", "required": true},
    {"key": "principal_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "attorney_name", "label": "Full name of the person you are authorising", "type": "text", "required": true},
    {"key": "attorney_address", "label": "Their address", "type": "textarea", "required": true},
    {"key": "relationship", "label": "Their relationship to you (e.g. brother, spouse)", "type": "text", "required": true},
    {"key": "property_description", "label": "Property / matters covered (full description)", "type": "textarea", "required": true},
    {"key": "reason", "label": "Why you need an attorney (e.g. living abroad, ill health)", "type": "text", "required": true},
    {"key": "additional_powers", "label": "Any additional specific power — or ''None''", "type": "textarea", "required": true},
    {"key": "witness_1_name", "label": "Witness 1 — name and address", "type": "text", "required": true},
    {"key": "witness_2_name", "label": "Witness 2 — name and address", "type": "text", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 15. Simple Will
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'simple-will',
  'Simple Will',
  'Family & Succession',
  'Indian Succession Act, 1925, Sections 59 and 63 (signed by the testator and attested by at least two witnesses); registration optional under the Registration Act, 1908, Section 18; Section 213 (mandatory probate) omitted by the Repealing and Amending Act, 2025',
  'free', 'advocate_reviewed',
  '[
    {"key": "testator_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "testator_parent_name", "label": "Your father''s / mother''s name", "type": "text", "required": true},
    {"key": "testator_age", "label": "Your age (years)", "type": "number", "required": true},
    {"key": "testator_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "executor_name", "label": "Executor — name and address (the person who will carry out the Will)", "type": "text", "required": true},
    {"key": "alternate_executor_name", "label": "Alternate executor — name and address", "type": "text", "required": true},
    {"key": "bequests", "label": "Who gets what — list each asset and the person receiving it", "type": "textarea", "required": true},
    {"key": "residuary_beneficiary", "label": "Who gets everything not listed above (name and relationship)", "type": "text", "required": true},
    {"key": "will_place", "label": "Place of signing", "type": "text", "required": true},
    {"key": "will_date", "label": "Date", "type": "date", "required": true},
    {"key": "witness_1_details", "label": "Witness 1 — name and address (must not be a beneficiary)", "type": "text", "required": true},
    {"key": "witness_2_details", "label": "Witness 2 — name and address (must not be a beneficiary)", "type": "text", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 16. Bank / NBFC Grievance — Written Complaint (before RBI Ombudsman)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'bank-grievance-complaint',
  'Bank / NBFC Grievance — Written Complaint (before RBI Ombudsman)',
  'Banking & Finance',
  'Reserve Bank – Integrated Ombudsman Scheme, 2026 (in force from 1 July 2026, replacing the 2021 Scheme): written complaint to the regulated entity first; escalation to the RBI Ombudsman if rejected, unsatisfactory, or unanswered for 30 days — cms.rbi.org.in',
  'free', 'guided_self_serve',
  '[
    {"key": "customer_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "customer_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "customer_contact", "label": "Your phone number and email", "type": "text", "required": true},
    {"key": "bank_name", "label": "Bank / NBFC / payment company name", "type": "text", "required": true},
    {"key": "branch_address", "label": "Branch or grievance office address", "type": "textarea", "required": true},
    {"key": "account_reference", "label": "Account / card / loan reference — LAST 4 DIGITS ONLY", "type": "text", "required": true},
    {"key": "issue_date", "label": "Date the problem happened", "type": "date", "required": true},
    {"key": "transaction_reference", "label": "Transaction reference number(s), if any", "type": "text", "required": false},
    {"key": "amount_involved", "label": "Amount involved (INR), if any", "type": "number", "required": false},
    {"key": "complaint_details", "label": "What happened, in date order", "type": "textarea", "required": true},
    {"key": "resolution_sought", "label": "What you want the bank to do", "type": "textarea", "required": true},
    {"key": "complaint_date", "label": "Date of this complaint", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 17. Cyber Financial Fraud — Police Complaint
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'cyber-fraud-complaint',
  'Cyber Financial Fraud — Police Complaint',
  'Cyber Crime',
  'Bharatiya Nagarik Suraksha Sanhita, 2023, Section 173 (registration of FIR); Bharatiya Nyaya Sanhita, 2023, Sections 318 and 319 (cheating; cheating by personation); Information Technology Act, 2000, Sections 66C and 66D; report first on helpline 1930 / cybercrime.gov.in',
  'free', 'guided_self_serve',
  '[
    {"key": "complainant_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "complainant_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "complainant_phone", "label": "Your phone number and email", "type": "text", "required": true},
    {"key": "police_station", "label": "Cyber crime police station / local police station", "type": "text", "required": true},
    {"key": "fraud_date", "label": "Date of the fraud", "type": "date", "required": true},
    {"key": "fraud_time", "label": "Approximate time", "type": "text", "required": true},
    {"key": "amount_lost", "label": "Total amount lost (INR)", "type": "number", "required": true},
    {"key": "bank_name", "label": "Your bank / wallet / UPI app", "type": "text", "required": true},
    {"key": "account_reference", "label": "Your account / card — LAST 4 DIGITS ONLY", "type": "text", "required": true},
    {"key": "transaction_details", "label": "Each fraudulent transaction: date, time, amount, reference number, receiving account / UPI ID", "type": "textarea", "required": true},
    {"key": "fraud_description", "label": "How the fraud happened, step by step", "type": "textarea", "required": true},
    {"key": "suspect_details", "label": "Fraudster''s phone numbers, links, UPI IDs, names used", "type": "textarea", "required": true},
    {"key": "ncrp_acknowledgement", "label": "1930 / cybercrime.gov.in acknowledgement number — or ''Not yet filed''", "type": "text", "required": true},
    {"key": "complaint_date", "label": "Date of this complaint", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 18. Defamation — Legal Notice
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'defamation-notice',
  'Defamation — Legal Notice',
  'Civil Notices',
  'Bharatiya Nyaya Sanhita, 2023, Section 356 (defamation; replaced Sections 499–500 of the Indian Penal Code, 1860); civil action for damages under the law of torts; Limitation Act, 1963, Article 75 (one year)',
  'free', 'advocate_reviewed',
  '[
    {"key": "sender_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "sender_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "recipient_name", "label": "Name of the person who made the statement", "type": "text", "required": true},
    {"key": "recipient_address", "label": "Their address", "type": "textarea", "required": true},
    {"key": "statement_date", "label": "Date the statement was made / published", "type": "date", "required": true},
    {"key": "statement_medium", "label": "Where it was made (e.g. Facebook post, WhatsApp group, newspaper, spoken at a meeting)", "type": "text", "required": true},
    {"key": "defamatory_statement", "label": "The exact words used, as closely as you can give them", "type": "textarea", "required": true},
    {"key": "why_false", "label": "Why the statement is false", "type": "textarea", "required": true},
    {"key": "harm_caused", "label": "How it has harmed your reputation", "type": "textarea", "required": true},
    {"key": "compensation_demanded", "label": "Compensation demanded (INR)", "type": "number", "required": true},
    {"key": "notice_date", "label": "Date of notice", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 19. Workplace Sexual Harassment — Complaint to Internal Committee
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'posh-complaint',
  'Workplace Sexual Harassment — Complaint to Internal Committee',
  'Employment & Labour',
  'Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013, Section 9 (written complaint within three months of the last incident, extendable by three months) and Section 12 (interim relief); Rules, 2013, Rule 7; may also be filed on the SHe-Box portal',
  'free', 'guided_self_serve',
  '[
    {"key": "complainant_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "complainant_designation", "label": "Your designation and department", "type": "text", "required": true},
    {"key": "complainant_contact", "label": "Your phone number and email", "type": "text", "required": true},
    {"key": "employer_name", "label": "Employer / organisation name", "type": "text", "required": true},
    {"key": "workplace_address", "label": "Workplace address", "type": "textarea", "required": true},
    {"key": "respondent_name", "label": "Name of the person you are complaining against", "type": "text", "required": true},
    {"key": "respondent_designation", "label": "Their designation and department", "type": "text", "required": true},
    {"key": "incident_dates", "label": "Date(s) of the incident(s) — give the most recent date too", "type": "text", "required": true},
    {"key": "incident_location", "label": "Where it happened", "type": "text", "required": true},
    {"key": "incident_description", "label": "What happened, in date order, in your own words", "type": "textarea", "required": true},
    {"key": "witnesses", "label": "Names of witnesses, if any — or ''None''", "type": "textarea", "required": true},
    {"key": "supporting_documents", "label": "Messages, emails, photos or other material you are attaching — or ''None''", "type": "textarea", "required": true},
    {"key": "interim_relief", "label": "Interim relief you want during the inquiry (e.g. transfer of the respondent, leave) — or ''None''", "type": "textarea", "required": true},
    {"key": "complaint_date", "label": "Date of this complaint", "type": "date", "required": true}
  ]'::jsonb
)
on conflict (slug) do nothing;

-- 20. Delay in Possession — Legal Notice to Builder (RERA)
insert into templates (slug, title, category, legal_basis, tier, mode, field_schema)
values (
  'rera-delay-notice',
  'Delay in Possession — Legal Notice to Builder (RERA)',
  'Property & Tenancy',
  'Real Estate (Regulation and Development) Act, 2016, Section 18(1) (refund with interest, or interest for every month of delay) and Section 31 (complaint to the Authority); interest rate as prescribed by the State RERA Rules',
  'free', 'guided_self_serve',
  '[
    {"key": "allottee_name", "label": "Your full name", "type": "text", "required": true},
    {"key": "allottee_address", "label": "Your address", "type": "textarea", "required": true},
    {"key": "promoter_name", "label": "Builder / promoter company name", "type": "text", "required": true},
    {"key": "promoter_address", "label": "Builder''s registered address", "type": "textarea", "required": true},
    {"key": "project_name", "label": "Project name and location", "type": "text", "required": true},
    {"key": "rera_registration_number", "label": "Project RERA registration number — or ''Not known''", "type": "text", "required": true},
    {"key": "unit_details", "label": "Flat / unit number, tower, floor", "type": "text", "required": true},
    {"key": "agreement_date", "label": "Date of agreement for sale / allotment letter", "type": "date", "required": true},
    {"key": "total_consideration", "label": "Total price (INR)", "type": "number", "required": true},
    {"key": "amount_paid", "label": "Amount you have paid so far (INR)", "type": "number", "required": true},
    {"key": "promised_possession_date", "label": "Possession date promised in the agreement", "type": "date", "required": true},
    {"key": "relief_sought", "label": "What you want: (A) possession plus interest for every month of delay, OR (B) withdraw and full refund with interest", "type": "textarea", "required": true},
    {"key": "notice_date", "label": "Date of notice", "type": "date", "required": true}
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
$body$::text),
        ('rti-application', $body$
To,
The Public Information Officer,
{{public_authority_name}}
{{public_authority_address}}

Date: {{application_date}}

Subject: Application for information under Section 6(1) of the Right to Information Act, 2005

Sir/Madam,

I, {{applicant_name}}, am a citizen of India. Under Section 6(1) of the Right to Information Act, 2005, I request the following information.

1. Information sought:
{{information_sought}}

2. Period to which the information relates: {{period_of_information}}

3. Form of information: Please provide certified copies of the relevant records by post at my address given below.

4. Application fee: {{fee_payment_details}}

5. If the information requested is held by, or is more closely connected with, another public authority, please transfer this application or the relevant part of it to that authority under Section 6(3) of the Act within five days, and inform me of the transfer.

6. If any further fee is payable for providing the information, please intimate the amount and its calculation to me under Section 7(3) of the Act. I undertake to pay any fee lawfully due.

7. If any part of this request is refused, please state the reasons for refusal, the period within which an appeal may be made, and the particulars of the First Appellate Authority, as required by Section 7(8) of the Act.

Applicant's details:
Name: {{applicant_name}}
Address: {{applicant_address}}
Phone / email: {{applicant_phone}}

Yours faithfully,
{{applicant_name}}
$body$::text),
        ('rti-first-appeal', $body$
To,
The First Appellate Authority,
{{public_authority_name}}
{{public_authority_address}}

Date: {{appeal_date}}

Subject: First appeal under Section 19(1) of the Right to Information Act, 2005

Sir/Madam,

1. Appellant: {{appellant_name}}, {{appellant_address}}

2. Particulars of the RTI application:
Date of application: {{rti_application_date}}
Reference number: {{rti_reference_number}}
Public Information Officer of: {{public_authority_name}}

3. Reply of the Public Information Officer: {{pio_reply_details}}

4. Information that was sought:
{{information_sought}}

5. Grounds of appeal:
{{grounds_of_appeal}}

6. This appeal is filed within the period allowed by Section 19(1) of the Act. If there is any delay, I request that it be condoned, as I was prevented by sufficient cause from filing the appeal in time.

7. Relief sought:
(a) A direction to the Public Information Officer to provide the complete information sought, free of charge under Section 7(6) of the Act, since it was not provided within the time limit laid down in Section 7(1);
(b) An opportunity of being heard before this appeal is decided; and
(c) Any other order that is just and proper.

8. I declare that the facts stated above are true to the best of my knowledge and belief.

Enclosures:
(i) Copy of the RTI application dated {{rti_application_date}} with proof of fee
(ii) Copy of the reply of the Public Information Officer, if any

Yours faithfully,
{{appellant_name}}
$body$::text),
        ('consumer-legal-notice', $body$
LEGAL NOTICE

Date: {{notice_date}}

To,
{{company_name}}
{{company_address}}

From,
{{consumer_name}}
{{consumer_address}}

Subject: Notice of defect / deficiency in service under the Consumer Protection Act, 2019 — Invoice / Order No. {{invoice_number}}

Sir/Madam,

1. On {{purchase_date}}, I purchased / availed from you {{product_or_service}} against Invoice / Order No. {{invoice_number}}, and paid you a sum of INR {{amount_paid}} as consideration. I am therefore a consumer within the meaning of Section 2(7) of the Consumer Protection Act, 2019.

2. The facts giving rise to this notice are as follows:
{{problem_description}}

3. The above amounts to a defect in goods and/or a deficiency in service and/or an unfair trade practice within the meaning of Sections 2(10), 2(11) and 2(47) of the Consumer Protection Act, 2019, for which you are liable.

4. I therefore call upon you to do the following within fifteen (15) days of receiving this notice:
{{relief_demanded}}

5. If you fail to comply within the above period, I shall be constrained to file a complaint before the District Consumer Disputes Redressal Commission having jurisdiction under Section 35 of the Consumer Protection Act, 2019, seeking refund, compensation for loss, harassment and mental agony, interest, and the costs of the proceedings, entirely at your risk as to costs and consequences.

6. This notice is issued without prejudice to all other rights and remedies available to me in law. A copy of this notice has been retained for record.

Yours faithfully,
{{consumer_name}}
$body$::text),
        ('consumer-complaint-district-commission', $body$
BEFORE THE DISTRICT CONSUMER DISPUTES REDRESSAL COMMISSION AT {{district_commission_place}}

Consumer Complaint No. ________ of ________

IN THE MATTER OF:

{{complainant_name}}
{{complainant_address}}
... Complainant

VERSUS

{{opposite_party_name}}
{{opposite_party_address}}
... Opposite Party

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT, 2019

The Complainant respectfully submits as follows:

1. The Complainant is a consumer within the meaning of Section 2(7) of the Consumer Protection Act, 2019, having purchased / availed {{product_or_service}} from the Opposite Party on {{transaction_date}} for a consideration of INR {{amount_paid}}.

2. Facts of the case:
{{facts_of_case}}

3. The conduct of the Opposite Party described above amounts to a defect in goods and/or deficiency in service and/or unfair trade practice within the meaning of the Consumer Protection Act, 2019.

4. Steps taken before filing this complaint:
{{notice_details}}

5. Cause of action: The cause of action arose on {{cause_of_action_date}} and is continuing, as the grievance of the Complainant remains unresolved.

6. Jurisdiction: The value of the goods / services paid as consideration is INR {{amount_paid}}, which is within the pecuniary jurisdiction of this Commission. This Commission has territorial jurisdiction under Section 34(2) of the Act.

7. Limitation: This complaint is filed within two years from the date on which the cause of action arose and is within the period prescribed by Section 69 of the Act.

8. The Complainant has not filed any other complaint or proceeding on the same cause of action before any other Commission, court or forum.

PRAYER

The Complainant therefore prays that this Commission may be pleased to:
(a) Direct the Opposite Party as follows: {{other_relief}}
(b) Direct the Opposite Party to pay INR {{compensation_claimed}} as compensation for loss, harassment and mental agony;
(c) Award interest on the amounts due and the costs of this complaint; and
(d) Pass any other order that this Commission considers just and proper.

LIST OF DOCUMENTS
{{documents_list}}

Place: {{district_commission_place}}
Date: {{filing_date}}

{{complainant_name}}
Complainant

VERIFICATION

I, {{complainant_name}}, the Complainant above named, verify that the contents of paragraphs 1 to 8 of this complaint are true to my knowledge and belief, and that nothing material has been concealed.

Verified at {{district_commission_place}} on {{filing_date}}.

{{complainant_name}}
Complainant
$body$::text),
        ('residential-rent-agreement', $body$
RENT AGREEMENT

This Rent Agreement is made at {{agreement_place}} on {{agreement_date}}

BETWEEN

{{landlord_name}}, residing at {{landlord_address}} (the "Landlord"), of the one part;

AND

{{tenant_name}}, permanently residing at {{tenant_permanent_address}} (the "Tenant"), of the other part.

The Landlord is the owner of, and is entitled to let out, the residential premises at {{property_address}} (the "Premises"). The Tenant has asked to take the Premises on rent for residential use, and the Landlord has agreed, on the following terms:

1. Term. The tenancy is for a period of eleven (11) months, from {{start_date}} to {{end_date}}. It may be renewed for a further period only by a fresh written agreement between the parties.

2. Rent. The Tenant shall pay a monthly rent of INR {{monthly_rent}}, in advance, on or before the {{rent_due_day}} day of each month. The Landlord shall give a receipt for every payment.

3. Security deposit. The Tenant has paid the Landlord an interest-free refundable security deposit of INR {{security_deposit}}. The Landlord shall refund it when the Tenant hands back vacant possession of the Premises, after deducting only unpaid rent, unpaid utility charges, and the cost of repairing damage beyond normal wear and tear, with an account of any deduction.

4. Utilities. The Tenant shall pay electricity, water, gas and other consumption charges for the Premises for the period of the tenancy, according to the bills raised. Property tax and other owner's dues shall be paid by the Landlord.

5. Use. The Premises shall be used only as a private residence by the Tenant and the Tenant's family. The Tenant shall not carry on any unlawful, commercial or hazardous activity in the Premises.

6. No sub-letting. The Tenant shall not sub-let, assign or part with possession of the Premises or any part of it without the Landlord's prior written consent.

7. Care of the Premises. The Tenant shall keep the Premises, its fittings and fixtures in good condition, and shall not make structural additions or alterations without the Landlord's prior written consent. Day-to-day minor repairs shall be done by the Tenant; major and structural repairs shall be done by the Landlord.

8. Inspection. The Landlord or an authorised representative may enter the Premises for inspection or repairs at a reasonable time, after giving the Tenant reasonable prior notice.

9. Termination. Either party may end this tenancy before the end of the term by giving the other {{notice_period}} written notice. If the Tenant fails to pay rent for two consecutive months, or breaches a term of this Agreement and does not remedy it after written notice, the Landlord may terminate the tenancy.

10. Handing back possession. When the tenancy ends, the Tenant shall hand back vacant and peaceful possession of the Premises to the Landlord in the condition in which it was received, normal wear and tear excepted.

11. Stamp duty and registration. This Agreement shall be executed on stamp paper of the value required by the stamp law of the State in which the Premises are situated, and shall be registered where the law of that State so requires. The parties shall bear these costs equally unless they agree otherwise in writing.

12. Jurisdiction. Any dispute arising out of this Agreement shall be subject to the courts and authorities having jurisdiction at the place where the Premises are situated.

IN WITNESS WHEREOF the parties have signed this Agreement on the date and at the place first written above.

LANDLORD: {{landlord_name}}

TENANT: {{tenant_name}}

WITNESSES:
1. {{witness_1_name}}
2. {{witness_2_name}}
$body$::text),
        ('tenant-vacate-notice', $body$
LEGAL NOTICE

Date: {{notice_date}}

To,
{{tenant_name}}
{{property_address}}

From,
{{landlord_name}}
{{landlord_address}}

Subject: Notice terminating tenancy under Section 106 of the Transfer of Property Act, 1882, in respect of the premises at {{property_address}}

Dear {{tenant_name}},

1. I am the owner and landlord of the premises at {{property_address}} (the "Premises"), of which you are a tenant on a month-to-month basis at a monthly rent of INR {{monthly_rent}}.

2. I do not wish to continue your tenancy, for the following reason:
{{reason_for_termination}}

3. Arrears of rent outstanding as on the date of this notice: {{rent_arrears}}

4. By this notice, given under Section 106 of the Transfer of Property Act, 1882, I terminate your tenancy of the Premises. Your tenancy shall stand terminated on {{vacate_by_date}}, which is more than fifteen days from the receipt of this notice by you.

5. You are called upon to hand over vacant and peaceful possession of the Premises to me on or before {{vacate_by_date}}, and to pay all arrears of rent and utility charges up to the date of handing over possession. Your security deposit will be settled in accordance with our agreement when possession is handed back.

6. If you fail to vacate by the above date, your occupation of the Premises after that date will be unauthorised, and I shall be constrained to file proceedings for your eviction and for recovery of arrears and damages / mesne profits for use and occupation, entirely at your risk as to costs and consequences.

7. This notice is issued without prejudice to my other rights and remedies in law.

Yours faithfully,
{{landlord_name}}
$body$::text),
        ('money-recovery-notice', $body$
LEGAL NOTICE

Date: {{notice_date}}

To,
{{borrower_name}}
{{borrower_address}}

From,
{{lender_name}}
{{lender_address}}

Subject: Legal notice for recovery of INR {{outstanding_amount}}

Dear {{borrower_name}},

1. At your request, I advanced you a sum of INR {{loan_amount}} on {{loan_date}}. The amount was paid to you by: {{payment_mode}}.

2. You promised to repay the said amount on or before {{agreed_repayment_date}}. Interest terms: {{interest_terms}}.

3. Out of the said amount you have so far repaid INR {{amount_repaid}}. Despite my repeated requests and reminders, a sum of INR {{outstanding_amount}} remains due and payable by you.

4. Your failure to repay the amount is a breach of your agreement with me, and you are liable to repay the outstanding amount together with interest and to compensate me for the loss caused by the breach.

5. I therefore call upon you to pay me INR {{outstanding_amount}}, together with interest as stated above, within fifteen (15) days of receiving this notice.

6. If you fail to pay within the above period, I shall be constrained to file a suit for recovery of the amount, with interest and costs, before the competent civil court, and to take such other proceedings as are available to me in law, entirely at your risk as to costs and consequences.

7. This notice is issued without prejudice to all my other rights and remedies. A copy of this notice has been retained for record.

Yours faithfully,
{{lender_name}}
$body$::text),
        ('demand-promissory-note', $body$
PROMISSORY NOTE

INR {{principal_amount}}

Place: {{place}}
Date: {{note_date}}

ON DEMAND, I, {{borrower_name}}, residing at {{borrower_address}}, promise to pay {{lender_name}}, residing at {{lender_address}}, or order, the sum of INR {{principal_amount}} ({{amount_in_words}}), together with interest at {{interest_rate}} per cent per annum from the date of this note until payment, for value received.

I acknowledge that I have today received the said sum of INR {{principal_amount}} from {{lender_name}} by: {{payment_mode}}.

(Signature of the borrower across the revenue stamp)

{{borrower_name}}
Borrower

WITNESSES:
1. {{witness_1_name}}
2. {{witness_2_name}}
$body$::text),
        ('name-change-affidavit', $body$
AFFIDAVIT FOR CHANGE OF NAME

I, {{new_name}} (old name {{old_name}}), son / daughter / spouse of {{parent_or_spouse_name}}, aged {{age}} years, residing at {{address}}, do hereby solemnly affirm and declare as follows:

1. That I am a citizen of India and am competent to swear this affidavit.

2. That my name is recorded as {{old_name}} in my educational, identity and other records.

3. That I have changed my name from {{old_name}} to {{new_name}}. The reason for the change is: {{reason_for_change}}.

4. That {{old_name}} and {{new_name}} are the names of one and the same person, namely myself.

5. That from now on I shall be known as {{new_name}} for all purposes, and I shall use this name in all my records, dealings and documents.

6. That I am making this change of name in good faith, and not to evade any debt, liability, or civil or criminal proceeding.

7. That I shall publish this change of name in a daily newspaper and take the further steps required for its notification in the Official Gazette.

8. That I am making this affidavit to be produced before the authorities concerned for recording the change of my name.

DEPONENT
{{new_name}}

VERIFICATION

Verified at {{place}} on {{affidavit_date}} that the contents of paragraphs 1 to 8 of this affidavit are true and correct to my knowledge and belief, that no part of it is false, and that nothing material has been concealed.

DEPONENT
{{new_name}}
$body$::text),
        ('general-power-of-attorney', $body$
GENERAL POWER OF ATTORNEY

KNOW ALL PERSONS BY THESE PRESENTS that I, {{principal_name}}, residing at {{principal_address}} (the "Principal"), do hereby appoint {{attorney_name}}, residing at {{attorney_address}}, who is my {{relationship}} (the "Attorney"), as my true and lawful attorney, to act for me and in my name as set out below.

WHEREAS I am unable to attend personally to the matters described below because: {{reason}}.

AND WHEREAS this Power of Attorney relates to the following property / matters:
{{property_description}}

NOW I AUTHORISE my Attorney to do the following acts on my behalf:

1. To manage, maintain and look after the above property and to take all steps necessary for its upkeep and protection.

2. To let out the above property on rent or licence on reasonable terms for periods not exceeding eleven months at a time, to sign rent agreements, to collect rent and other dues, and to give valid receipts.

3. To pay property tax, maintenance charges, electricity, water and other outgoings in respect of the above property, and to obtain receipts.

4. To appear and represent me before any government, municipal, revenue, electricity, water, housing society or other authority in connection with the above property, and to sign and submit applications, forms and declarations for that purpose.

5. To engage advocates, to sign and verify pleadings, applications and vakalatnamas, and to represent me in any court, tribunal or authority in proceedings relating to the above property.

6. To do all other acts that are necessary for and incidental to the powers given above.

7. Additional specific power: {{additional_powers}}

I DECLARE THAT:

(a) This Power of Attorney does NOT authorise my Attorney to sell, gift, mortgage, exchange or otherwise transfer the ownership of the above property, or to sign any agreement to do so.

(b) My Attorney shall keep true accounts of all money received and spent on my behalf and shall hand over to me all sums received, on demand.

(c) I may revoke this Power of Attorney at any time by notice in writing to my Attorney. It shall also come to an end on my death.

(d) I agree to ratify and confirm all acts lawfully done by my Attorney under this Power of Attorney.

IN WITNESS WHEREOF I have signed this Power of Attorney at {{execution_place}} on {{execution_date}}.

PRINCIPAL: {{principal_name}}

ACCEPTED BY ATTORNEY: {{attorney_name}}

WITNESSES:
1. {{witness_1_name}}
2. {{witness_2_name}}
$body$::text),
        ('simple-will', $body$
LAST WILL AND TESTAMENT

I, {{testator_name}}, son / daughter of {{testator_parent_name}}, aged {{testator_age}} years, residing at {{testator_address}}, make this my last Will at {{will_place}} on {{will_date}}.

1. Revocation. I revoke all Wills, codicils and testamentary writings made by me before this date. This is my last Will.

2. Declaration. I am of sound mind and in good health, and I am making this Will of my own free will, without any pressure, coercion or undue influence from anyone. The property dealt with in this Will is my own, and I am fully entitled to dispose of it.

3. Executor. I appoint {{executor_name}} as the Executor of this Will. If that person is unable or unwilling to act, I appoint {{alternate_executor_name}} as the Executor.

4. Debts and expenses. My Executor shall first pay my funeral expenses, my lawful debts, and the costs of carrying out this Will, out of my estate.

5. Bequests. I give my property as follows:
{{bequests}}

6. Residue. All the rest of my property, movable and immovable, of whatever kind and wherever situated, which I own at the time of my death and which is not specifically dealt with above, I give to {{residuary_beneficiary}}.

7. If any person named above dies before me, the share of that person shall go to {{residuary_beneficiary}}, unless I have stated otherwise above.

IN WITNESS WHEREOF I have signed this Will on the date and at the place first written above, in the presence of the two witnesses named below, who have signed as witnesses in my presence and in the presence of each other.

TESTATOR
{{testator_name}}

ATTESTATION

We, the two witnesses named below, state that the above-named Testator signed this Will in our presence, both of us being present at the same time, and that each of us has signed this Will as a witness in the presence of the Testator and of each other. The Testator appeared to us to be of sound mind and to be acting of free will.

WITNESS 1: {{witness_1_details}}
Signature:

WITNESS 2: {{witness_2_details}}
Signature:
$body$::text),
        ('bank-grievance-complaint', $body$
Date: {{complaint_date}}

To,
The Nodal Officer / Grievance Redressal Officer,
{{bank_name}}
{{branch_address}}

Subject: Formal written complaint of deficiency in service — account / card / loan ending {{account_reference}}

Sir/Madam,

1. I am your customer, holding the account / card / loan ending {{account_reference}}. I am making this formal written complaint about a deficiency in your service.

2. Date of the incident: {{issue_date}}
Transaction reference: {{transaction_reference}}
Amount involved: INR {{amount_involved}}

3. Details of the complaint:
{{complaint_details}}

4. Resolution I am asking for:
{{resolution_sought}}

5. Please acknowledge this complaint in writing, give me a complaint reference number, and resolve it at the earliest.

6. Please note that if this complaint is rejected wholly or partly, or if I do not receive a satisfactory reply within 30 days of your receiving it, I shall file a complaint with the RBI Ombudsman under the Reserve Bank – Integrated Ombudsman Scheme, 2026, through the Reserve Bank's Complaint Management System, and shall seek compensation for my loss, time, expenses and mental agony in addition to the resolution above.

My contact details:
Name: {{customer_name}}
Address: {{customer_address}}
Phone / email: {{customer_contact}}

Yours faithfully,
{{customer_name}}
$body$::text),
        ('cyber-fraud-complaint', $body$
Date: {{complaint_date}}

To,
The Station House Officer,
{{police_station}}

Subject: Complaint of online financial fraud of INR {{amount_lost}} on {{fraud_date}} — request to register an FIR

Respected Sir/Madam,

1. I, {{complainant_name}}, residing at {{complainant_address}} (contact: {{complainant_phone}}), am the victim of an online financial fraud and request you to register a First Information Report and investigate.

2. Date and time of the fraud: {{fraud_date}}, at about {{fraud_time}}
Total amount lost: INR {{amount_lost}}
My bank / wallet / UPI app: {{bank_name}}, account / card ending {{account_reference}}

3. How the fraud took place:
{{fraud_description}}

4. Details of the fraudulent transactions:
{{transaction_details}}

5. Details of the suspect(s) known to me:
{{suspect_details}}

6. National Cyber Crime Reporting Portal / Helpline 1930 acknowledgement number: {{ncrp_acknowledgement}}

7. The above facts disclose the commission of cognizable offences, including cheating and cheating by personation under Sections 318 and 319 of the Bharatiya Nyaya Sanhita, 2023, and identity theft and cheating by personation using a computer resource under Sections 66C and 66D of the Information Technology Act, 2000.

8. I request you to:
(a) Register an FIR under Section 173 of the Bharatiya Nagarik Suraksha Sanhita, 2023, and give me a copy free of cost;
(b) Immediately write to the banks and payment intermediaries concerned to freeze the receiving accounts and hold the amount; and
(c) Investigate the matter and take action against the offenders according to law.

9. I am enclosing copies of my bank statement showing the transactions, screenshots of the messages / calls / links, and my identity proof. I shall give any further information needed for the investigation.

Yours faithfully,
{{complainant_name}}
$body$::text),
        ('defamation-notice', $body$
LEGAL NOTICE

Date: {{notice_date}}

To,
{{recipient_name}}
{{recipient_address}}

From,
{{sender_name}}
{{sender_address}}

Subject: Legal notice for defamation

Dear {{recipient_name}},

1. On {{statement_date}}, you made / published the following statement about me through {{statement_medium}}:
{{defamatory_statement}}

2. The above statement is false, for the following reasons:
{{why_false}}

3. You made and published the statement to third persons knowing it to be false, or without taking any care to find out whether it was true, intending to harm, or knowing that it would harm, my reputation.

4. The statement has lowered my reputation in the eyes of others and has caused me harm, as follows:
{{harm_caused}}

5. Your act amounts to defamation, which is an offence punishable under Section 356 of the Bharatiya Nyaya Sanhita, 2023, and is also a civil wrong for which you are liable to pay me damages.

6. I therefore call upon you, within fifteen (15) days of receiving this notice, to:
(a) Stop making or publishing the above or any similar statement about me;
(b) Withdraw the statement and remove it from every place where it has been published;
(c) Give me a written and unconditional apology, and publish it in the same manner and through the same medium as the original statement; and
(d) Pay me INR {{compensation_demanded}} as compensation for the harm caused to my reputation.

7. If you fail to comply within the above period, I shall be constrained to file a criminal complaint for defamation and a civil suit for damages and injunction against you, entirely at your risk as to costs and consequences.

8. This notice is issued without prejudice to all my other rights and remedies. A copy has been retained for record.

Yours faithfully,
{{sender_name}}
$body$::text),
        ('posh-complaint', $body$
CONFIDENTIAL

Date: {{complaint_date}}

To,
The Presiding Officer,
Internal Committee,
{{employer_name}}
{{workplace_address}}

Subject: Complaint of sexual harassment at the workplace under Section 9 of the Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013

Madam,

1. Complainant: {{complainant_name}}, {{complainant_designation}}
Contact: {{complainant_contact}}

2. Respondent: {{respondent_name}}, {{respondent_designation}}

3. Date(s) of the incident(s): {{incident_dates}}
Place of the incident(s): {{incident_location}}

4. Details of the incident(s):
{{incident_description}}

5. Witnesses:
{{witnesses}}

6. Supporting documents and material enclosed:
{{supporting_documents}}

7. The conduct of the Respondent described above was unwelcome and amounts to sexual harassment within the meaning of Section 2(n) read with Section 3 of the Act.

8. This complaint is made within the period allowed by Section 9 of the Act, counted from the date of the last incident.

9. Interim relief requested under Section 12 of the Act while the inquiry is pending:
{{interim_relief}}

10. I request the Committee to:
(a) Take this complaint on record and inquire into it in accordance with the Act and the Rules;
(b) Grant the interim relief requested above;
(c) Keep my identity and the contents of this complaint confidential as required by Section 16 of the Act; and
(d) Recommend appropriate action against the Respondent on completion of the inquiry.

11. I declare that the contents of this complaint are true to the best of my knowledge and belief.

Yours faithfully,
{{complainant_name}}
$body$::text),
        ('rera-delay-notice', $body$
LEGAL NOTICE

Date: {{notice_date}}

To,
{{promoter_name}}
{{promoter_address}}

From,
{{allottee_name}}
{{allottee_address}}

Subject: Notice for delay in handing over possession — {{unit_details}}, {{project_name}} — under Section 18 of the Real Estate (Regulation and Development) Act, 2016

Sir/Madam,

1. I am the allottee of {{unit_details}} in your project {{project_name}} (RERA registration number: {{rera_registration_number}}), under the agreement for sale / allotment dated {{agreement_date}}.

2. The total consideration for the unit is INR {{total_consideration}}, out of which I have paid you INR {{amount_paid}} according to the payment schedule.

3. Under the agreement, you undertook to hand over possession of the unit on or before {{promised_possession_date}}. You have failed to hand over possession by that date, and the unit has not been handed over to me till today.

4. Under Section 18(1) of the Real Estate (Regulation and Development) Act, 2016, where the promoter fails to give possession in accordance with the agreement for sale, the allottee is entitled either to withdraw from the project and receive back the amount paid with interest and compensation, or to continue in the project and be paid interest for every month of delay until possession is handed over, at the rate prescribed.

5. I therefore call upon you to do the following within thirty (30) days of receiving this notice:
{{relief_sought}}

6. If you fail to comply within the above period, I shall be constrained to file a complaint against you before the Real Estate Regulatory Authority under Section 31 of the Act, and to claim compensation before the Adjudicating Officer under Section 71 of the Act, entirely at your risk as to costs and consequences.

7. This notice is issued without prejudice to all my other rights and remedies, including under the Consumer Protection Act, 2019. A copy has been retained for record.

Yours faithfully,
{{allottee_name}}
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
