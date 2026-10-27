# October SEO and dealer-discovery release

Four complete buyer articles cover landscaping loads, enclosed rear-door choices, an equipment-fit worksheet and dealer stock versus orders. They use the current site layout, unique metadata, Article/Breadcrumb schema, crawlable category/guide links and sitemap entries. No new model specifications, inventory, prices, lead times or dealer policies are invented. Publication dates use the preparation date, October 27, 2026; align visible and structured dates if publication is later.

The dealer map now gives each marker its business name and location as its accessible name. Its count distinguishes 48 mapped dealers out of 57 listed dealers from the separate factory marker. All existing directory entries are retained. Addresses and current inventory still need confirmation before travel. This does not claim the August roster has been reverified by the office.

Category hero links identify the appropriate dealer journey. New articles are added to the existing public-route attribution allowlist so an accepted quote retains the original article landing. Existing accepted-request, duplicate/honeypot, fallback and intent-event behavior is preserved and tested. No database, portal access or email delivery configuration changes are included.

## Checks

- `python3 docs/stamp-assets.py` checks deploy references and updates asset hashes.
- `python3 docs/check-seo.py` checks 95 pages / 88 public sitemap URLs, metadata, schema, links, fragments and new-article discovery.
- `node --test docs/*.test.cjs` covers 15 lead/attribution, quote-context and map accessibility cases.
- `node --check` on every first-party JavaScript file.
- New GitHub Site checks workflow runs those checks on PRs and main; asset stamping must leave no diff.
- Local browser review uses a preview server that removes the remote Google tag. No test requests were submitted to the office.

## Separate account and business follow-up

This PR does not change GA4 key-event configuration, submit sitemaps, update GBP/Bing profiles or verify office sales. Reconcile accepted quote, parts and dealer applications with aggregate office records; phone, map and dealer-site clicks remain intent signals. Preserve those distinctions in reports.

Current dealer activation, street addresses, model sheets and warranty terms require office evidence before adding more specific claims. Query-specific country/device exports should precede broader title changes; the homepage manufacturer positioning is preserved. The two crawled exclusions need URL-level inspection rather than a blanket redirect or noindex change.

After merge, verify production article routes, canonical/sitemap behavior and dealer handoffs. Compare relevant organic query/page cohorts and qualified inquiries after 30 and 60 days. No ranking or lead improvement has yet been measured.
