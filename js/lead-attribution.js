/* Per-tab acquisition context for the existing office inquiry record.
   No personal fields, query strings, search terms, fragments, or portal paths.
   This module never sends a request or emits an Analytics event. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory;
  else root.TRIPLE_R_ATTRIBUTION = factory(root);
})(typeof window !== 'undefined' ? window : this, function (env) {
  'use strict';
  var KEY = 'trr_inquiry_source_v1';
  var MAX_AGE = 30 * 60 * 1000;
  var PUBLIC_PAGES = ["/", "/6x12-vs-7x16-enclosed-trailer.html", "/about.html", "/become-a-dealer.html", "/buying-a-trailer-out-of-state.html", "/car-hauler-trailers.html", "/choosing-a-trailer-manufacturer.html", "/contact.html", "/dump-trailer-buying-guide.html", "/dump-trailers.html", "/enclosed-cargo-trailers.html", "/equipment-trailers.html", "/find-a-dealer.html", "/gooseneck-trailers.html", "/guides.html", "/how-to-become-a-trailer-dealer.html", "/how-to-spot-a-well-built-trailer.html", "/parts-service.html", "/privacy.html", "/service-area.html", "/trailer-maintenance-tips.html", "/trailers-alabama.html", "/trailers-amory-ms.html", "/trailers-arkansas.html", "/trailers-athens-al.html", "/trailers-batesville-ms.html", "/trailers-birmingham-al.html", "/trailers-bolivar-tn.html", "/trailers-booneville-ms.html", "/trailers-bowling-green-ky.html", "/trailers-cape-girardeau-mo.html", "/trailers-columbia-tn.html", "/trailers-columbus-ms.html", "/trailers-corinth-ms.html", "/trailers-cullman-al.html", "/trailers-decatur-al.html", "/trailers-dickson-tn.html", "/trailers-florence-al.html", "/trailers-fulton-ms.html", "/trailers-grenada-ms.html", "/trailers-hamilton-al.html", "/trailers-hattiesburg-ms.html", "/trailers-huntsville-al.html", "/trailers-iuka-ms.html", "/trailers-jackson-ms.html", "/trailers-jackson-tn.html", "/trailers-jonesboro-ar.html", "/trailers-kennett-mo.html", "/trailers-lawrenceburg-tn.html", "/trailers-little-rock-ar.html", "/trailers-louisiana.html", "/trailers-memphis-tn.html", "/trailers-mississippi.html", "/trailers-missouri.html", "/trailers-monroe-la.html", "/trailers-nashville-tn.html", "/trailers-new-albany-ms.html", "/trailers-oxford-ms.html", "/trailers-paducah-ky.html", "/trailers-paragould-ar.html", "/trailers-paris-tn.html", "/trailers-pontotoc-ms.html", "/trailers-poplar-bluff-mo.html", "/trailers-ripley-ms.html", "/trailers-russellville-al.html", "/trailers-ruston-la.html", "/trailers-savannah-tn.html", "/trailers-searcy-ar.html", "/trailers-selmer-tn.html", "/trailers-shreveport-la.html", "/trailers-sikeston-mo.html", "/trailers-southaven-ms.html", "/trailers-starkville-ms.html", "/trailers-tennessee.html", "/trailers-tupelo-ms.html", "/trailers-west-memphis-ar.html", "/trailers-west-plains-mo.html", "/trailers.html", "/utility-trailers.html", "/utility-vs-enclosed-trailer.html", "/what-size-trailer-do-i-need.html"]; // Filled from actual public routes at authoring time.
  var now = env.Date ? env.Date.now() : Date.now();
  var current = env.location.pathname === '/index.html' ? '/' : env.location.pathname;
  var isPublic = PUBLIC_PAGES.indexOf(current) !== -1;
  var fields = null;

  function cleanToken(value) {
    return typeof value === 'string' && /^[a-z0-9][a-z0-9_.-]{0,79}$/i.test(value) ? value : '';
  }
  function cleanHost(value) {
    return typeof value === 'string' && value.length <= 253 && /^[a-z0-9.-]+$/i.test(value) ? value : '';
  }
  function readEntry(value) {
    if (!value || typeof value.created !== 'number' || now < value.created || now - value.created >= MAX_AGE || PUBLIC_PAGES.indexOf(value.landing) === -1) return null;
    return { created: value.created, landing: value.landing, referrer: cleanHost(value.referrer),
      source: cleanToken(value.source), medium: cleanToken(value.medium), campaign: cleanToken(value.campaign) };
  }
  try { fields = readEntry(JSON.parse(env.sessionStorage.getItem(KEY))); } catch (e) { /* blocked or unavailable storage */ }
  if (isPublic && !fields) {
    var referrer = '';
    try {
      var ref = new URL(env.document.referrer);
      if (/^https?:$/.test(ref.protocol) && ref.hostname !== env.location.hostname) referrer = cleanHost(ref.hostname);
    } catch (e) { /* direct navigation */ }
    var query = new URLSearchParams(env.location.search || '');
    fields = { created: now, landing: current, referrer: referrer,
      source: cleanToken(query.get('utm_source')), medium: cleanToken(query.get('utm_medium')), campaign: cleanToken(query.get('utm_campaign')) };
    try { env.sessionStorage.setItem(KEY, JSON.stringify(fields)); } catch (e) { /* current-page attribution still works */ }
  }
  return {
    getFields: function () {
      if (!fields) return {};
      var timestamp = env.Date ? env.Date.now() : Date.now();
      if (timestamp - fields.created >= MAX_AGE || timestamp < fields.created) {
        fields = null;
        try { env.sessionStorage.removeItem(KEY); } catch (e) { /* unavailable storage */ }
        return {};
      }
      var result = { 'Website landing page': fields.landing };
      if (fields.referrer) result['Website referrer host'] = fields.referrer;
      if (fields.source) result['Website campaign source'] = fields.source;
      if (fields.medium) result['Website campaign medium'] = fields.medium;
      if (fields.campaign) result['Website campaign'] = fields.campaign;
      return result;
    }
  };
});
