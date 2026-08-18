/* Triple R Trailers dealer portal configuration.
   After creating the Supabase project (see docs/DEALER-PORTAL-SETUP.md),
   paste the Project URL and anon public key below. The anon key is safe to
   publish; all security is enforced server side by Supabase policies.
   Dealer pricing is NOT in this file. It lives in the database, behind login. */
window.TRIPLE_R_PORTAL = {
  SUPABASE_URL: "PASTE_PROJECT_URL_HERE",
  SUPABASE_ANON_KEY: "PASTE_ANON_PUBLIC_KEY_HERE",
  DOCS_BUCKET: "dealer-docs",
  ORDER_EMAIL: "triplertrailers@gmail.com"
};
