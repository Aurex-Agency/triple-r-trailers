# Dealer Portal Setup (Supabase)

The site ships with a complete dealer portal front end: `dealer-login.html` (sign in),
`dealer-portal.html` (protected documents), `dealer-order.html` (build an order at
dealer pricing), and `dealer-requests.html` (what the dealership has sent in).
Security is enforced server side by Supabase; the pages just talk to it.

Steps 1 to 7 put login and documents live, about 30 minutes. Steps 8 and 9 turn on
ordering, about 25 more. They can be done on different days.

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

## 8. Turn on ordering (15 min)

Dealers can spec trailers at their own pricing and send the whole list to the
office. Nothing is charged. A request is a request until the office confirms it.

1. **SQL Editor -> New query.** Paste `docs/supabase-orders.sql`, Run.
   That builds the catalog tables, the order tables, and the security rules.
2. **SQL Editor -> New query.** Paste `docs/catalog-seed.sql`, Run.
   That loads the current price lists: 6 categories,
   21 model lines, 125 priced builds, 78 options.
3. **Add each dealership.** Table Editor -> `dealers` -> Insert row.
   Name, city, state, phone. Do this once per dealership, not per person.
4. **Link each login to its dealership.** Table Editor -> `dealer_members` ->
   Insert row: the user's id (from Authentication -> Users) and the dealer id.
   Until a login is linked, ordering tells them to call the office.
   Several people at one dealership can share a dealership; add a row each.
5. **Add yourself as staff.** Table Editor -> `staff_users` -> Insert row with
   your own user id. Staff see every request; dealers see only their own.

Dealers now have Build an Order and My Requests in the portal.

## 8b. Turn on parts requests (2 min)

Parts have no published dealer price list, so the portal collects what the
dealer needs and the office confirms the part and the price on the callback.

1. **SQL Editor -> New query.** Paste `docs/supabase-parts.sql`, Run.
2. That is all. A Parts tab appears in the portal for every dealer.

Requests land under Table Editor -> `part_request_summary`, and they use the
same email settings as trailer orders, so step 9 covers both.

## 9. Get the order emails (10 min)

Without this the requests still save and dealers still see them; only the
email is skipped. Check `order_summary` in the dashboard either way.

1. Sign up at https://resend.com (free tier is plenty) and create an API key.
2. Verify the sending domain, or start with their test sender.
3. SQL Editor, once:

```sql
insert into app_settings (key, value) values
  ('resend_api_key',   're_your_key_here'),
  ('order_email_to',   'triplertrailers@gmail.com'),
  ('order_email_from', 'Triple R Portal <orders@triplertrailers.com>')
on conflict (key) do update set value = excluded.value;
```

`order_email_to` takes a comma separated list if more than one person should
get them. Replies go back to the dealer who sent the request.

## Day-to-day for the office

- New dealer approved -> invite the email (step 7), add the dealership (step 8.3),
  link them (step 8.4).
- A request comes in -> it is emailed to you and listed under Table Editor ->
  `order_summary` for trailers, `part_request_summary` for parts, newest first.
- Moving a request along -> Table Editor -> `orders` -> change `status` to
  `confirmed`, `in_build`, `ready`, `delivered`, or `cancelled`. The dealer sees
  the new status on My Requests. Only staff can change it.
- Price list changes -> see below.
- Dealer leaves the network -> delete their user.

## Updating prices

The catalog is generated from the office price lists, not typed by hand. Send
the new price list and the seed file gets rebuilt; then paste the new
`docs/catalog-seed.sql` into the SQL Editor and Run. It replaces the catalog in
one transaction, so there is no window where a dealer sees half a price list.
Requests already sent keep the prices they were sent at.

## Questions for the office about the price lists

These came out of loading the current lists. Nothing is blocked, but each one
is worth a look, and any correction is a one line change to the seed:

1. Flat bed 82X16 on the 5 inch channel frame reads $1,733.00 while the 18ft is $2,837.00 and the 20ft is $2,878.00. Likely meant to be $2,733.00.
2. Enclosed tandem 7X24 reads $5,609.00 standard, which is lower than the 7X22 at $5,796.00. Every other step goes up with length.
3. Enclosed single axle 5X10 reads $2,516.00, three dollars under the 5X8 at $2,519.00.
4. Angle top rails on 16ft and 18ft appear on the equipment options list with no price.
5. Dump tarp ($165) and ramps ($160) sit under a Deductions heading, so they are loaded here as credits for deleting equipment that comes standard.
6. Pipe top rail pricing for equipment trailers is published for 16ft and 18ft only, not 20ft.
7. Goosenecks have no published price list, so the builder collects the spec and the office quotes it.
8. The tandem utility lines carry a flat 'add a gate' at $200 and 'add ramps' at $175, while the general options list prices gates by size ($202 to $277) and ramps by type ($107 to $336). Both are offered in the builder, grouped separately, so the office should confirm which applies when a dealer picks one.

## What this can grow into

- **Pricing tiers**: add a `tier` column to `dealers` and a tier price column to
  the catalog. The order function already prices on the server, so tiers become
  a pricing change, not a rebuild.
- **Freight**: today the office quotes it on the callback. A freight table by
  distance or zone would let the builder show it.
- **Payment**: if deposits are ever wanted, this is where Stripe would attach.
  Trailer orders on dealer terms do not need it now.

## Notes

- The `service_role` key in the API settings is the master key. Never put it
  in the website code; it is only for the dashboard or trusted servers.
- Dealer pricing is never in the website files. It lives in the database and
  loads only for a signed-in dealer. `docs/` is excluded from the deploy by
  `.vercelignore` so the seed file is never served.
- A submitted request cannot carry made up prices. The database looks every
  price up again from the catalog when the request is saved, so the totals the
  office sees are the factory's own numbers.
- Free tier limits (50,000 monthly active users, 500 MB database, 1 GB storage)
  are far beyond what 57 dealers ordering trailers will use.
