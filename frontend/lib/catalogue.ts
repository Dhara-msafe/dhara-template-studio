// The 25 templates in supabase/seed.sql, in short form for the home page.
// "advocate" = an advocate checks your filled document before you get it.
export type CatalogueItem = { title: string; category: string; law: string; advocate?: boolean };

export const CATALOGUE: CatalogueItem[] = [
  { title: "Cheque bounce notice", category: "Money", law: "Negotiable Instruments Act, section 138" },
  { title: "Money recovery notice", category: "Money", law: "Indian Contract Act, 1872" },
  { title: "Promissory note", category: "Money", law: "Negotiable Instruments Act, section 4" },
  { title: "Bank or NBFC complaint", category: "Money", law: "RBI Ombudsman Scheme, 2026" },
  { title: "Insurance claim representation", category: "Money", law: "Insurance Ombudsman Rules, 2017" },
  { title: "Rent agreement, 11 months", category: "Home and property", law: "Transfer of Property Act, 1882" },
  { title: "Security deposit refund letter", category: "Home and property", law: "Transfer of Property Act, 1882" },
  { title: "Notice to tenant to vacate", category: "Home and property", law: "Transfer of Property Act, section 106", advocate: true },
  { title: "Builder delay notice", category: "Home and property", law: "RERA, section 18" },
  { title: "Agreement to sell", category: "Home and property", law: "Transfer of Property Act, section 54", advocate: true },
  { title: "Power of attorney, no sale", category: "Home and property", law: "Powers-of-Attorney Act, 1882", advocate: true },
  { title: "Consumer notice to a seller", category: "Consumer", law: "Consumer Protection Act, 2019" },
  { title: "Consumer complaint, District Commission", category: "Consumer", law: "Consumer Protection Act, section 35", advocate: true },
  { title: "Unpaid salary notice", category: "Work", law: "Code on Wages, 2019" },
  { title: "Workplace harassment complaint", category: "Work", law: "POSH Act, 2013, section 9" },
  { title: "RTI application", category: "Government", law: "Right to Information Act, section 6" },
  { title: "RTI first appeal", category: "Government", law: "Right to Information Act, section 19" },
  { title: "Name change affidavit", category: "Government", law: "Gazette of India procedure" },
  { title: "Police complaint", category: "Police and courts", law: "BNSS, 2023, section 173", advocate: true },
  { title: "Cyber fraud complaint", category: "Police and courts", law: "BNSS section 173; IT Act, 2000" },
  { title: "Defamation notice", category: "Police and courts", law: "Bharatiya Nyaya Sanhita, section 356", advocate: true },
  { title: "Motor accident claim", category: "Police and courts", law: "Motor Vehicles Act, section 166", advocate: true },
  { title: "Simple will", category: "Family", law: "Indian Succession Act, section 63", advocate: true },
  { title: "Legal heir affidavit", category: "Family", law: "Oaths Act, 1969" },
  { title: "Maintenance notice", category: "Family", law: "BNSS, 2023, section 144", advocate: true },
];

export const CATEGORIES = Array.from(new Set(CATALOGUE.map((c) => c.category)));
