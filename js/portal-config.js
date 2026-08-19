/* Triple R Trailers dealer portal configuration.
   The anon key is designed to be public. Every table is protected by row
   level security, so this key alone reads nothing it should not.
   The service_role key is the master key and must NEVER appear in this file.
   Dealer pricing is not here either. It lives in the database, behind login.
   Setup steps: docs/DEALER-PORTAL-SETUP.md */
window.TRIPLE_R_PORTAL = {
  SUPABASE_URL: "https://pqjztgmvzsryknuylyod.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxanp0Z212enNyeWtudXlseW9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcxNjc5NDYsImV4cCI6MjEwMjc0Mzk0Nn0.0tLltj9ZJMzzxz4VPv1LxtBOEBdh9MLqWGl8mUTi_48",
  DOCS_BUCKET: "dealer-docs",
  ORDER_EMAIL: "triplertrailers@gmail.com"
};
