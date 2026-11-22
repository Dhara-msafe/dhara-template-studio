# Template library — research note (25 templates)

Checked on 22 November 2026. Covers the 4 original DHARA drafts and the 16
templates added that day (21 in all). Every template loads as `draft` (see
`supabase/seed.sql`); none is published.

**What this note is.** A record of which law each template rests on, where
that was checked, and what a qualified advocate still has to confirm before
publishing. It is not a legal opinion. The drafting and the checking were done
by an AI assistant, not a lawyer. No government body "approves" private legal
notices or agreements, so there is no official approval to obtain for most of
these; what was checked is that each one cites law that is in force and follows
the procedure the official source describes.

## Law that changed recently (and is reflected in the templates)

| Change | Effect on the library |
|---|---|
| Code on Wages, 2019 in force 21 Nov 2025; Central Rules notified 8 May 2026 | `unpaid-salary-notice` cites the Code, not the Payment of Wages Act, 1936 |
| BNSS 2023 replaced the CrPC on 1 July 2024; BNS 2023 replaced the IPC | Police and cyber complaints cite BNSS s.173; defamation cites BNS s.356 (not IPC 499/500) |
| Reserve Bank – Integrated Ombudsman Scheme, 2026 in force 1 July 2026, replacing the 2021 Scheme | `bank-grievance-complaint` cites the 2026 Scheme |
| Repealing and Amending Act, 2025 (assent 20 Dec 2025) omitted s.213 of the Indian Succession Act | `simple-will` legal basis notes probate is no longer a precondition; execution rules in s.63 are unchanged |
| e-Jagriti replaced e-Daakhil for consumer filing (1 Jan 2025) | Consumer templates refer to e-Jagriti |
| SHe-Box portal relaunched 29 Aug 2024 | `posh-complaint` legal basis mentions SHe-Box as a filing route |
| Motor Vehicles Act s.166(3) six-month limit under challenge; Supreme Court interim order, Nov 2025 | `motor-accident-claim-application` legal basis flags it. **Re-check before publishing** |
| Draft Registration Bill, 2025 (to replace the Registration Act, 1908) | Still a draft when last seen (early 2026). Templates cite the 1908 Act. **Re-check before publishing** the rent agreement, power of attorney and will |

## The 25 templates

Mode: G = guided self-serve, A = advocate-reviewed.

| # | Slug | Mode | Rests on | Checked against | Advocate must confirm |
|---|---|---|---|---|---|
| 1 | cheque-bounce-notice | G | NI Act 1881, s.138 | Prior session | Notice must reach the drawer within 30 days of the bank's return memo; template does not enforce this |
| 2 | deposit-refund-notice | G | TPA 1882; State rent law | Prior session | State-specific deposit rules |
| 3 | unpaid-salary-notice | G | Code on Wages 2019; Central Rules 2026 | Prior session | Section numbers for the claim and authority; State rules |
| 4 | police-complaint-letter | A | BNSS 2023, s.173 | Prior session | — |
| 5 | rti-application | G | RTI Act 2005, s.6(1), 6(3), 7(3), 7(8); RTI Rules 2012 | DoPT / Dept of Legal Affairs fee page; Vikaspedia | Fee is Rs 10 for Central authorities only; State fee and payment mode vary and the form asks the user to state how they paid |
| 6 | rti-first-appeal | G | RTI Act 2005, s.19(1), 19(6), 7(6) | Government FAQ documents on first appeal | Para 6 pleads condonation in every appeal; reviewer may prefer it conditional |
| 7 | consumer-legal-notice | G | CPA 2019, s.2(7), 2(10), 2(11), 2(47), 35, 69 | India Code text of the Act | Notice is customary, not mandatory, before a complaint |
| 8 | consumer-complaint-district-commission | A | CPA 2019, s.34, 35, 38, 69; Jurisdiction Rules 2021 | PIB/press on the 2021 Rules; Supreme Court judgment of 29 Apr 2025 upholding consideration-based jurisdiction | Needs a supporting affidavit and fee per the 2020 Rules (nil up to Rs 5 lakh was reported; confirm current schedule); e-Jagriti's own form fields |
| 9 | residential-rent-agreement | G | TPA 1882, s.105–108; Registration Act 1908, s.17(1)(d); stamp law | Supreme Court judgment of 11 Apr 2019 on s.106/107 | **State variance is large.** Maharashtra requires registration of leave-and-licence agreements regardless of term; stamp duty differs by State; States that adopted a Model Tenancy Act-based law have their own rules. Consider State variants |
| 10 | tenant-vacate-notice | A | TPA 1882, s.106, 111(h) | Law Commission 181st Report; Supreme Court 2019 | Where a State rent-control Act protects the tenant, a s.106 notice alone does not entitle eviction — grounds under that Act are needed |
| 11 | money-recovery-notice | G | Contract Act 1872, s.73; Limitation Act 1963; CPC Order XXXVII | General | Three-year limitation is not checked by the form; cash loans above statutory limits raise income-tax issues |
| 12 | demand-promissory-note | G | NI Act 1881, s.4; Stamp Act 1899, Sch. I Art. 49, s.35 | Case law on Art. 49 | Correct stamp value today; whether witnesses are advisable in the user's State (attestation can attract different stamp treatment in some States) |
| 13 | name-change-affidavit | G | Oaths Act 1969; Notaries Act 1952; Gazette Part IV procedure | Department of Publication guidelines (s3waas.gov.in PDFs) | The Department's current list of documents and proforma; minors and government employees follow a different procedure |
| 14 | general-power-of-attorney | A | Powers-of-Attorney Act 1882, s.1A, 2; Contract Act Ch. X | Supreme Court, *Suraj Lamp* (2011); Delhi Revenue Dept FAQ | Stamp duty and registration by State; template deliberately excludes any power to sell |
| 15 | simple-will | A | Indian Succession Act 1925, s.59, 63; Registration Act s.18 | Supreme Court judgments on s.63; coverage of the 2025 amendment | **Does not suit every user:** the Act's will provisions do not govern Muslims, whose bequests follow personal law; Hindu coparcenary property has its own limits. Product should screen for this |
| 16 | bank-grievance-complaint | G | RB-IOS 2026 | RBI FAQ dated 1 July 2026 (rbi.org.in) | Time limit to escalate to the Ombudsman (banks' notices say 90 days — confirm against the Scheme text); compensation caps |
| 17 | cyber-fraud-complaint | G | BNSS s.173; BNS s.318, 319; IT Act s.66C, 66D | MHA / I4C material on 1930 and cybercrime.gov.in | Which BNS sub-sections fit depends on facts; product should tell users to call 1930 first, before drafting anything |
| 18 | defamation-notice | A | BNS 2023, s.356; tort; Limitation Act Art. 75 | Bare Act text of s.356 | Truth for public good and other exceptions; risk of counter-claim; one-year civil limitation |
| 19 | posh-complaint | G | SH Act 2013, s.2(n), 3, 9, 12, 16; Rules 2013, r.7 | PIB note of 12 Feb 2026; statutory text of s.9 | Six copies under r.7; Local Committee route where there is no IC or the complaint is against the employer; template addresses the IC only |
| 20 | rera-delay-notice | G | RERA 2016, s.18(1), 31, 71 | Statutory text of s.18; State RERA orders | Interest rate and complaint form differ by State |
| 21 | insurance-claim-grievance | G | Insurance Ombudsman Rules 2017 (amended to 9 Nov 2023), r.13, 14 | Council for Insurance Ombudsmen (cioins.co.in); text of r.14(3) | Rs 50 lakh cap and one-year limit are stated in the legal basis, not enforced by the form; para 6 asserts full disclosure and paid-up premium for every user — reviewer may want these as user-confirmed fields; life-claim repudiation has its own rules (Insurance Act s.45) |
| 22 | legal-heir-affidavit | G | Oaths Act 1969; State revenue rules for legal heir certificates; contrast Indian Succession Act Part X (s.370-390) | Bank and legal explainers on legal heir vs succession certificate; Madras High Court view that a Tahsildar's certificate is not a succession certificate | State-specific proforma and who must attest; banks often want their own indemnity format; this affidavit is evidence only, not authority to collect |
| 23 | maintenance-notice | A | BNSS 2023, s.144 | LiveLaw comparison of s.125 CrPC and s.144 BNSS; commentary on interim maintenance (60 days) | Notice is not a legal precondition; which statute suits the facts (personal law, DV Act 2005, Senior Citizens Act 2007); s.144 does not let a husband claim; safety screening where there is domestic violence |
| 24 | motor-accident-claim-application | A | MV Act 1988, s.165, 166, 168 | Supreme Court interim order of Nov 2025 on s.166(3) (LiveLaw, Bar & Bench); Delhi High Court text of s.166(3) | **Limitation is unsettled**: six-month limit challenged, interim order bars dismissal as time-barred; final ruling not seen. State MACT rules prescribe the form; hit-and-run and s.164 no-fault claims need different templates; pleads driver negligence for every user |
| 25 | agreement-to-sell | A | TPA 1882, s.54, 53A; Registration Act 1908, s.17(1A), 49; Specific Relief Act 1963 | Supreme Court (Jan 2025 and 13 Aug 2026) and High Court rulings on s.54 and s.17(1A) | Stamp duty and compulsory registration vary by State; forfeiture clause must be reasonable to be enforceable; tax-deduction clause left generic because the Income-tax Act, 2025 renumbered sections; RERA applies instead for builder sales |

## Sources

Official
- RBI, FAQ on the Reserve Bank – Integrated Ombudsman Scheme, 2026: https://www.rbi.org.in/commonman/Upload/English/FAQs/PDFs/RBIOS01072026.pdf
- Department of Legal Affairs, fee under the RTI Act: https://legalaffairs.gov.in/rti/fee-required-under-rti-act
- PIB, draft Registration Bill 2025: https://pib.gov.in/PressReleasePage.aspx?PRID=2131546
- PIB, SH Act 2013 and SHe-Box overview (12 Feb 2026): https://static.pib.gov.in/WriteReadData/specificdocs/documents/2026/feb/doc2026212787301.pdf
- Department of Publication, change-of-name guidelines: https://cdnbbsr.s3waas.gov.in/s3ea6b2efbdd4255a9f1b3bbc6399b58f4/uploads/2023/06/202312082035285613.pdf
- Supreme Court, judgment of 29 Apr 2025 (consumer pecuniary jurisdiction): https://api.sci.gov.in/supremecourt/2020/25636/25636_2020_11_1501_61287_Judgement_29-Apr-2025.pdf
- Supreme Court, judgment of 11 Apr 2019 (TPA s.106/107): https://api.sci.gov.in/supremecourt/2018/45428/45428_2018_Judgement_11-Apr-2019.pdf
- Law Commission of India, 181st Report (TPA s.106): https://delhihighcourt.nic.in/files/reports/181.pdf
- Bihar RERA, complaint instructions under s.31: https://rera.bihar.gov.in/public/login
- Council for Insurance Ombudsmen, complaint conditions: https://cioins.co.in/
- Consumer Protection Act, 2019 (India Code): https://www.indiacode.nic.in/bitstream/123456789/18964/1/cpa.pdf

Secondary (used where the official text was not directly retrievable)
- Bar & Bench and Khaitan & Co on the omission of s.213, Indian Succession Act
- LiveLaw on the Registration Bill, 2025 (Jan 2026)
- SCC Online on the PoSH complaint process

## Known gaps in the product, found while testing

- Dates print as `2026-11-22`. Legal documents should print `22 November 2026`.
- Optional fields left blank print as an empty value after their label.
- All 25 are tier `free`; which ones are Pro is a business decision not yet made.
- Hindi/Marathi PDF export needs a Devanagari font and text shaping.
