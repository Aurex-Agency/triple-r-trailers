# Search growth and inquiry release — September 25, 2026

## Included

- Three complete buying guides: 14K dump payload, Ranger Crew trailer fit, and enclosed trailer pricing. Each has its own canonical, description, Article/Breadcrumb data, real existing photograph, contextual quote action, guide-index/home/product links, and sitemap entry.
- Mississippi title, description and H1 aligned with buying intent; a practical dealer contact table and one externally verified dealer address/inventory link.
- Targeted buying notes on Tupelo, Corinth, Florence, Memphis, and Southaven pages. Existing directory contacts are reused; these are not newly verified dealer relationships or inventory promises.
- Product-specific quote links on utility, dump, enclosed, and local pages. Contact form safely preselects approved product categories and preserves the visitor's selection. Browser autofill and accessible form feedback are improved.
- Removed unsupported five-ton dump payload and universal hitch-fit claims; kept the visible dump FAQ consistent with its structured data. No empty weights, ramps, prices, or stock were invented.
- Existing acquisition context now recognizes all three new article routes. Confirmed lead events include an allowlisted trailer category. Phone events distinguish factory/dealer, dealer website clicks are separate, and quote CTA clicks are separate from actual inquiry events.

## Sources and maintenance

Pricing article cites Jason Dietsch Midsouth's public listing for stock 026557 (2027 6x12 vendor door, $5,495) and enclosed inventory listing for stock 025796 (2026 7x16 rear ramp, $6,595), reviewed September 25. These are historical examples of different configurations, not factory MSRP or guaranteed current offers. Sources: https://jdtsmidsouth.com/unit/2027-triple-r-6x12-enclosed-cargo-with-vendor-door-1257069 and https://www.jdtsmidsouth.com/all-inventory/enclosed-cargo-trailers/ . Recheck monthly and replace sold examples when appropriate; retain clear review dates.

Dealer address/phone source: https://www.jdtsmidsouth.com/all-inventory/enclosed-cargo-trailers/ . Existing directory contacts need an owner-maintained active-dealer review; do not infer precise map coordinates from town pins.

Weight-rating explanation: https://www.natm.com/news/explaining-gross-vehicle-weight-ratings-to-customers . UTV transport source: https://www.polaris.com/en-us/off-road/owner-resources/help-center/article/KA-04472/ . The original pictured UTV is an example, not a universal fit certification. Obtain measured model/build specifications for a future fit table.

## Validation

Run `python3 docs/stamp-assets.py`, `python3 docs/check-seo.py`, and `node --test docs/lead-attribution.test.cjs docs/quote-context.test.cjs`.

Browser review: desktop dump article and quote-link prefill; mobile enclosed article and Mississippi page at a 390px viewport. Local visual visits can appear in Analytics unless hostname/internal-traffic filters exclude them. No production lead form was submitted.

Live redirect inspection on September 25: HTTP apex and HTTPS www each returned 308 to HTTPS apex; HTTPS apex returned 200. No redirect change is needed based on these checks. Historical Search Console HTTP traffic is not proof of an active redirect defect.

## Owner's calls and leads view

In GA4, use the Events report for the following measures over a consistent date window:

| Event | Meaning | Limitation |
|---|---|---|
| generate_lead | Server-acknowledged website inquiry, excluding acknowledged duplicates/bots | Reconcile with actual office inquiries; not necessarily a qualified buyer or sale |
| phone_click | Click on a phone link; contact_role separates factory/dealer | Not proof a call connected; typed/dialed numbers are not measured |
| dealer_finder_click | Visitor opened a dealer-finder link | Not a dealer contact or unique buyer |
| dealer_map_click | Dealer map link clicked | Not proof of a visit |
| dealer_website_click | Tagged dealer website/inventory link clicked | Not a sale on the dealer's site |
| quote_cta_click | Contact/quote link clicked | Not a submitted quote |

The code retains the existing office form delivery and source fields. Confirm the owner receives those existing notifications and follows up with each inquiry. This release does not change email recipients or deploy backend services.

GA4 configuration follow-up: inspect current key-event selection, counting method, and activation dates before changing anything. The reviewed period had 15 generate_lead events from 10 users versus four key events; do not assume either is the count of qualified leads. Register event-scoped dimensions for lead_type, trailer_type, dealer_id, contact_role, and link_location if absent. Avoid registering contact information. Use lead_type to separate dealer applications from retail inquiries. GA settings were not changed by this release.

For actual connected-call counts, duration, and attribution, the owner needs a call-tracking provider/number and an agreed routing setup. Phone-click measurement works without that service. No paid service or replacement phone number has been activated.

## After merge and deployment

1. Confirm the three new URLs return 200 on production, assets load, and the sitemap contains 84 public URLs.
2. Verify one clearly labeled owner-approved quote through the live delivery chain and reconcile its office receipt with Analytics. Check a real dealer application separately. Do not count these tests as business leads.
3. Review new pages in Search Console and request indexing where appropriate. Sitemap submission alone is not a ranking guarantee.
4. Review organic sessions, nonbranded search clicks, confirmed inquiries, and dealer actions at consistent 28-day intervals. Use the existing 373 organic sessions in August 28–September 24 as an initial reference, not a forecast.
5. Supply current build specification sheets, the active dealer directory, strongest-margin categories, and lead outcomes for the next improvement cycle. The business must maintain price examples, stock, contact accuracy, and prompt inquiry follow-up.

This release is a tested website/content increment. Regional authority, dealer participation, Google Business Profile work, verified specifications, and lead-to-sale reporting require continued operations. It does not guarantee rankings or a quantity of calls.
