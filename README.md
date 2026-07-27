# Triple R Trailers

Marketing website for Triple R Trailers of Booneville, Mississippi. Heavy-duty trailer manufacturer, building since 1997, sold through dealers across the Mid-South.

## Status

The homepage is built and sets the design system for the rest of the site. Remaining pages (Trailers, Find a Dealer, Become a Dealer, Parts & Service, About, Contact, Dealer Login, location landing pages, SEO articles) will follow the same system.

## Stack

Hand-built static site. No frameworks, no build step. Deployable to any static host.

- `index.html` is the homepage
- `css/styles.css` holds the full design system (tokens, type, components, sections)
- `js/main.js` drives the animations (scroll reveals, self-drawing line art, counters, tabs, mobile drawer)
- `assets/fonts/` self-hosted woff2 fonts (Ultra, Barlow, Barlow Condensed)
- `assets/img/` brand logos and favicons

## Design notes

- Type: Ultra for display (matches the wedge-serif letterforms in the logo), Barlow Condensed for labels and navigation, Barlow for body copy
- Palette: charcoal ink, bone, steel gray, and the deep logo red
- Texture: film grain overlay, hazard-stripe accents, blueprint grid, outlined ghost type
- Animations: slat headline reveals, rubber-stamp badge entrance, self-drawing SVG trailer line art, angled marquee, count-up stats. All gated behind `prefers-reduced-motion`

## Placeholders to replace before launch

- Phone number `(662) 555-0134` (appears in the header, drawer, CTA, and footer, plus `tel:` links)
- Street address (footer shows city/state/zip only)
- Facebook page URL in the footer
