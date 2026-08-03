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
- `assets/img/` brand logos, favicons, and real trailer photography from the yard

## Design notes

- Type: Ultra for display (matches the wedge-serif letterforms in the logo), Barlow Condensed for labels and navigation, Barlow for body copy
- Palette: charcoal ink, bone, steel gray, and the deep logo red
- Texture: film grain overlay, hazard-stripe accents, blueprint grid, outlined ghost type
- Animations: slat headline reveals, rubber-stamp badge entrance, self-drawing SVG trailer line art, angled marquee, count-up stats. All gated behind `prefers-reduced-motion`

## Before launch

- Facebook page URL in the footer is still generic (facebook.com)
- Forms open a prefilled email to triplertrailers@gmail.com; swap in a form service (Formspree, Netlify Forms, etc.) at launch for direct submissions
- Dealer map (Leaflet, self-hosted) is live on Find a Dealer with 42 of 58 locations pinned from public-listing research (city-level pins); have the office confirm the list in `js/dealers.js` and fill in the 16 remaining dealers that could not be confidently located
- Map tiles come from openstreetmap.org; swap the tile URL in `js/dealer-map.js` to a keyed provider (MapTiler, Stadia) if traffic grows
- Dealer portal is fully built on Supabase: real login at dealer-login.html, protected documents at dealer-portal.html. One-time connection steps (create project, paste two keys, upload PDFs, invite dealers) are in docs/DEALER-PORTAL-SETUP.md
- Canonical URLs point at https://triplertrailers.com with .html paths; adjust rewrites at hosting if clean URLs are preferred
