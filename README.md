# Triple R Trailers

Marketing website for Triple R Trailers of Booneville, Mississippi. Heavy-duty trailer manufacturer, building since 1997, sold through dealers across the Mid-South.

## Status

Full site built: homepage, trailers hub plus 6 category pages, Find a Dealer with interactive dealer map, Become a Dealer, Dealer Login, Parts & Service, About, Contact, 6 state landing pages, 50 city landing pages plus a service-area hub, and a guides hub with 7 SEO articles. sitemap.xml and robots.txt included. City pages are generated from scratchpad tooling with computed factory distances and nearest-dealer tables; regenerate by editing the city data and rerunning the generator (see git history).

## Stack

Hand-built static site. No frameworks, no build step. Deployable to any static host.

- `index.html` is the homepage
- `css/styles.css` holds the full design system (tokens, type, components, sections)
- `js/main.js` drives the animations (scroll reveals, self-drawing line art, counters, tabs, mobile drawer)
- `assets/fonts/` self-hosted woff2 fonts (Ultra, Barlow, Barlow Condensed)
- `assets/img/` brand logos and favicons; `assets/img/photos/` is the curated real-inventory photo library (34 shots) pulled from the owner's Google Drive, with a `strip/` subfolder of small versions for the rolling photo marquee

## Design notes

- Type: Ultra for display (matches the wedge-serif letterforms in the logo), Barlow Condensed for labels and navigation, Barlow for body copy
- Palette: charcoal ink, bone, steel gray, and the deep logo red
- Texture: film grain overlay, hazard-stripe accents, blueprint grid, outlined ghost type
- Animations: slat headline reveals, rubber-stamp badge entrance, self-drawing SVG trailer line art, angled marquee, count-up stats. All gated behind `prefers-reduced-motion`

## Before launch

- Facebook page URL in the footer is still generic (facebook.com)
- Forms open a prefilled email to triplertrailers@gmail.com; swap in a form service (Formspree, Netlify Forms, etc.) at launch for direct submissions
- Dealer map (Leaflet, self-hosted) is live on Find a Dealer with 49 of 58 locations pinned (city-level pins). Names, towns, and phones are checked against the official Triple R dealer sheet (August 2026); 9 dealers not on that sheet still need a town from the office before they can be pinned (see the bottom of `js/dealers.js`)
- Map tiles come from openstreetmap.org; swap the tile URL in `js/dealer-map.js` to a keyed provider (MapTiler, Stadia) if traffic grows
- Dealer portal is fully built on Supabase: login at dealer-login.html, protected documents at dealer-portal.html, order building at dealer-order.html, and request history at dealer-requests.html. Dealers spec trailers at their own pricing and send the list to the factory; nothing is charged and the office confirms every request. Dealers can also send parts requests at dealer-parts.html; parts have no published price list, so that flow collects what they need and the office prices it on the callback. One-time connection steps are in docs/DEALER-PORTAL-SETUP.md
- css and js URLs carry a `?v=<content hash>` stamp. A changed file becomes a changed URL, so no browser can serve a stale copy, no matter what it cached before. **Re-run `python3 docs/stamp-assets.py` after editing anything in `css/` or `js/`**, and after regenerating pages. It rewrites the stamp across all HTML and verifies every reference still resolves
- `vercel.json` redirects `/docs/*` away. Redirects are evaluated before static files are served, so it blocks the path even if a file reaches the deployment. It is the second lock behind `.vercelignore`, and it exists because `docs/` carries the dealer net price list. Note that `vercel.json` is validated strictly by Vercel: only `source`, `destination`, `permanent`, `statusCode`, `has`, `missing`, and `env` are allowed on a redirect, and JSON has no comments, so any explanation belongs here rather than in the file
- Dealer pricing lives only in the Supabase database, never in the website files. `docs/` (schema plus the price list seed) is kept out of the deploy by `.vercelignore`. The catalog is generated from the office price lists, so a price change is a regenerated `docs/catalog-seed.sql`, not hand editing
- Canonical URLs point at https://triplertrailers.com with .html paths; adjust rewrites at hosting if clean URLs are preferred
