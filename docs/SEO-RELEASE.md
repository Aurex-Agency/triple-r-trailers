# SEO and dealer growth release

Branch: `seo/dealer-growth-and-buying-guides`

## Implemented in this branch

- Two complete articles in the existing site design: choosing a trailer manufacturer, and 6x12 versus 7x16 enclosed trailers. Each has article metadata, a canonical, accessible comparison table, contents navigation, real product photography, and buyer/dealer calls to action.
- New guide cards, contextual links from existing related pages, and sitemap entries.
- Manufacturer-focused homepage title and description. Dealer application and startup copy now request a location review instead of promising an unverified universal 60-mile territory. The startup article directs applicants to the dealer application.
- All 57 existing directory entries retained in initial HTML. Existing phone numbers are clickable; missing contact details lead to the factory. Stable dealer IDs attach to directory, map, and matching city-page phone links. No unverified dealer address, number, stock, or website was invented.
- Map links search for the actual business rather than route a visitor to a town-center coordinate. Map distances say straight-line. Same-day pickup promises removed from city copy and its FAQ structured data; missing-phone table entries now link to the factory.
- Enclosed and dump pages explain exact-build measurements, capacity, and itemized quoting. Overbroad towing and automatic upsizing advice corrected. Actual specifications remain subject to current factory data.
- Buyer location and dealer ZIP fields improve routing. Dealer contact name now uses the existing backend's `Name` key so it populates lead summaries correctly.
- Thirty-minute, per-tab attribution preserves the initial public landing page, external referrer hostname, and short UTM labels in the existing lead `fields` JSON and office email. No schema migration, new service, raw referring URL, search terms, or portal paths. Privacy copy reflects the change.
- Existing `generate_lead` events require a positive server acknowledgement and exclude acknowledged duplicates/honeypot submissions. Phone events can include a stable dealer ID. Map-search clicks are tracked separately from inquiries.
- Dealer account pages are `noindex, follow`; login removed from the public sitemap. Existing access controls are unchanged.
- Cache stamping works from any checkout, with updated asset hashes across all pages. Offline link/metadata and lead-flow tests are included.

## Required business inputs for the next phase

| Input | What to send | What it unlocks |
|---|---|---|
| Dealer policy | Current written territory policy, measurement method, exceptions/grandfathering, stocking minimums and support terms | More specific dealer offer and qualification copy |
| Dealer directory | Active/inactive status, verified street address, phone, website, hours, products handled, and current ordering contacts | Reliable directions, richer regional pages, dealer brand pages and referrals |
| Model sheets | 6x12 enclosed, 7x16 enclosed, 7x14 dump first: actual empty weight, GVWR, dimensions, door opening, ramp rating, brake configuration and options | Accurate comparison tables and dedicated model pages |
| Warranty documents | Current written terms by product category | Direct downloadable warranty links and precise coverage language |
| Growth priorities | First three expansion states, strongest-margin products, capacity/lead times and workable freight range | Prioritized regional content and dealer acquisition |
| Measurement access | Search Console and GA4 access or exports; office lead/order outcomes | Keyword baselines, validated conversions, revenue reporting |

Pricing should be public retail information authorized for use. Do not send dealer-only price lists for public publication. Keep confidential records outside this public repository.

## Review and launch

1. Review both articles and the revised dealer-program language on the branch/preview. Current copy does not guarantee territory approval, availability, margin, or a delivery date. Confirm the brand can use it as written.
2. Confirm the article publication dates match the actual launch date. Both new pages and their schema currently use September 9, 2026, the preparation date. If launch is later, update visible dates, article metadata/JSON-LD, and sitemap lastmod together.
3. Run `python3 docs/stamp-assets.py`, `python3 docs/check-seo.py`, and `node --test docs/lead-attribution.test.cjs`. Inspect the Vercel preview if one is created for the pull request.
4. Merge only after review. This branch does not change the production branch or run a deployment command. Whether merging deploys production depends on the existing Vercel Git integration settings.
5. After deployment, verify both URLs, mobile tables/CTAs, sitemap, indexability, and a controlled real inquiry in the office. Automated tests mock all submissions; no test inquiry was sent to production by this task.
6. In GA4, validate `generate_lead` and distinguish `lead_type` values. Register `dealer_id` as an event-scoped custom dimension if dealer referral reporting is desired. Phone/map clicks are engagement, not sales. Do not count duplicates across these event types as unique buyers.
7. In Search Console, submit the sitemap and inspect the two new article URLs. Review index status and query performance after data accumulates. Track qualified dealer applications, buyer quotes and resulting orders monthly.

## Scope of remaining work

The branch implements the website changes supported by available facts. Verified specification tables, new model pages, substantive regional expansions, dealer interviews, case studies, backlink outreach, account configuration, and ongoing reporting still require the inputs above. Existing city URLs are preserved; consolidation should follow Search Console/backlink analysis rather than guesswork. No rankings or traffic gains have yet been measured.

The full research plan is in `SEO-GROWTH-PLAN.md`. It is reference material, not a claim that every 90-day action is completed.
