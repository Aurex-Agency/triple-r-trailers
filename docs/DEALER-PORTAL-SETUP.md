# Dealer Portal Setup (Supabase)

The site ships with a complete dealer portal front end: `dealer-login.html` (sign in)
and `dealer-portal.html` (protected documents). Security is enforced server side by
Supabase; the pages just talk to it. Follow these steps once and the portal is live.
Total time: about 30 minutes.

## 1. Create the Supabase project (5 min)

1. Go to https://supabase.com and sign up (free tier is plenty to start).
2. Create a new project. Name: `triple-r-trailers`. Region: `us-east-1` (closest to Mississippi).
3. Set a strong database password and store it somewhere safe (you rarely need it again).

## 2. Lock down sign ups (2 min, IMPORTANT)

By default anyone could create an account, which would let strangers into dealer pricing.

1. In the Supabase dashboard: **Authentication -> Sign In / Up**.
2. Turn **OFF** "Allow new users to sign up".
3. Result: only accounts you invite exist. This step is not optional.

## 3. Set the site URL (2 min)

1. **Authentication -> URL Configuration**.
2. Site URL: `https://triplertrailers.com` (or wherever the site is deployed).
3. Add `https://triplertrailers.com/dealer-portal.html` to Additional Redirect URLs.
   (Sign-in links and invite emails redirect here.)

## 4. Create the documents bucket and policy (5 min)

1. In the dashboard open the **SQL Editor**, paste the contents of
   `docs/supabase-setup.sql` (below in this repo), and click Run.
2. That creates a private `dealer-docs` storage bucket and a policy that lets
   signed-in dealers read files. Nobody else can, and nobody but you can upload.

## 5. Connect the website (3 min)

1. In the dashboard: **Project Settings -> API**.
2. Copy the **Project URL** and the **anon public** key
   (the anon key is designed to be public; policies do the protecting).
3. Open `js/portal-config.js` in the site code and paste both values.
4. Deploy the site. The login page goes live automatically; until this step the
   pages show a friendly "portal is being connected" notice.

## 6. Upload the dealer documents (5 min)

1. Dashboard: **Storage -> dealer-docs -> Upload file**.
2. Upload the current price list and options list PDFs. Use clean file names,
   they display as-is in the portal: `Triple R Price List August 2026.pdf`.
3. To update pricing later: upload the new file, delete the old one. Dealers
   always see the latest.

## 7. Invite the dealers (5 min for the first few)

1. Dashboard: **Authentication -> Users -> Invite user**.
2. Enter the dealer's email. They receive an email, click, set a password, done.
3. To cut a dealer off: same screen, delete or ban the user. Access ends instantly.
4. The website's "Request Access" form emails the office; verify the requester
   against the dealer list before inviting.

## Day-to-day for the office

- New dealer approved -> invite their email (step 7).
- Price list changes -> upload the new PDF (step 6).
- Dealer leaves the network -> delete their user.
- Dealer locked out -> Authentication -> Users -> send password recovery,
  or tell them to use "Email me a sign-in link" on the login page.

## What this foundation supports later

- **Pricing tiers**: add a `tier` field to each user, split documents into
  per-tier folders, and one policy change scopes each dealer to their folder.
- **Online ordering (the year-one goal)**: the same Supabase project adds a
  database for orders and inventory; dealer accounts are already in place.

## Notes

- The `service_role` key in the API settings is the master key. Never put it
  in the website code; it is only for the dashboard or trusted servers.
- Free tier limits (50,000 monthly active users, 1 GB storage) are far beyond
  what 57 dealers reading PDFs will use.
