import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

// Browser client — used for auth (sign up/in/out, session) and can also
// query tables directly if a page wants to skip the FastAPI hop; RLS in
// supabase/schema.sql governs what it's allowed to see either way.
export const supabase = createClient(supabaseUrl, supabaseAnonKey);
