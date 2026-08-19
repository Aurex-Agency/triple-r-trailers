/* Triple R Trailers dealer order builder.
   Drives dealer-order.html (browse, configure, request) and
   dealer-requests.html (past requests).

   Pricing shown here mirrors what the database computes on submit. The
   database is the authority: submit_order() looks every price up again, so a
   tampered cart cannot change what the factory is asked to honor. */
(function () {
  'use strict';

  var cfg = window.TRIPLE_R_PORTAL || {};
  var configured = cfg.SUPABASE_URL && cfg.SUPABASE_URL.indexOf('http') === 0 &&
    cfg.SUPABASE_ANON_KEY && cfg.SUPABASE_ANON_KEY.indexOf('PASTE') !== 0;

  var buildRoot = document.getElementById('ob-root');
  var reqRoot = document.getElementById('rq-root');
  if (!buildRoot && !reqRoot) return;

  var notice = document.getElementById('portal-unconfigured');
  if (!configured) {
    if (notice) notice.style.display = '';
    var shell = document.getElementById('portal-shell');
    if (shell) shell.style.display = 'none';
    return;
  }

  var client = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
  var ORDER_EMAIL = cfg.ORDER_EMAIL || 'triplertrailers@gmail.com';
  var PHONE = '(662) 728-7975';

  /* Real yard photography, so picking a category looks like a lot, not a form. */
  var CATEGORY_ART = {
    'utility': 'assets/img/photos/strip/utility-sunset.jpg',
    'enclosed': 'assets/img/photos/strip/enclosed-charcoal-34.jpg',
    'dump': 'assets/img/photos/strip/dump-bed-up.jpg',
    'car-hauler': 'assets/img/photos/strip/carhauler-wood-deck.jpg',
    'equipment': 'assets/img/photos/equipment-long-deck.jpg',
    'gooseneck': 'assets/img/photos/strip/gooseneck-rrr.jpg'
  };

  /* ------------------------------------------------------------------ util */

  function esc(s) {
    return String(s === null || s === undefined ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function money(n) {
    if (n === null || n === undefined || isNaN(n)) return '';
    var neg = n < 0;
    var s = '$' + Math.abs(n).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return neg ? '(' + s + ' credit)' : s;
  }

  function el(id) { return document.getElementById(id); }

  function setBusy(node, msg) {
    if (node) node.innerHTML = '<p class="ob-loading">' + esc(msg) + '</p>';
  }

  /* --------------------------------------------------------------- session */

  var state = {
    dealer: null, user: null,
    categories: [], lines: [], models: [], options: [], lineOptions: [],
    activeCategory: null, activeLine: null,
    cart: loadCart()
  };

  function cartKey() { return 'trr-cart-' + (state.user ? state.user.id : 'anon'); }

  function loadCart() {
    try {
      var raw = localStorage.getItem('trr-cart-pending');
      return raw ? JSON.parse(raw) : [];
    } catch (e) { return []; }
  }

  function saveCart() {
    try { localStorage.setItem('trr-cart-pending', JSON.stringify(state.cart)); } catch (e) {}
  }

  function requireSession() {
    return client.auth.getSession().then(function (res) {
      var session = res.data.session;
      if (!session) { window.location.href = 'dealer-login.html'; return null; }
      state.user = session.user;
      var who = el('portal-user');
      if (who) who.textContent = session.user.email;
      var out = el('portal-signout');
      if (out) {
        out.addEventListener('click', function () {
          client.auth.signOut().then(function () { window.location.href = 'dealer-login.html'; });
        });
      }
      return client.from('dealer_members')
        .select('dealer_id, full_name, dealers(name, city, state, phone)')
        .eq('user_id', session.user.id).maybeSingle()
        .then(function (r) {
          if (r.data && r.data.dealers) {
            state.dealer = r.data.dealers;
            state.dealer.id = r.data.dealer_id;
            state.dealer.contact = r.data.full_name;
            var dn = el('portal-dealer');
            if (dn) {
              dn.textContent = state.dealer.name +
                (state.dealer.city ? ', ' + state.dealer.city + ', ' + state.dealer.state : '');
            }
          }
          return session;
        });
    });
  }

  /* --------------------------------------------------------------- pricing */

  function bandPrice(bands, lengthFt) {
    if (!bands || !lengthFt) return null;
    for (var k in bands) {
      if (!Object.prototype.hasOwnProperty.call(bands, k)) continue;
      var lo, hi;
      if (k.indexOf('-') > -1) {
        lo = parseInt(k.split('-')[0], 10); hi = parseInt(k.split('-')[1], 10);
      } else { lo = hi = parseInt(k, 10); }
      if (lengthFt >= lo && lengthFt <= hi) return Number(bands[k]);
    }
    return null;
  }

  /* Returns {price: number|null, callFor: bool} for one option on one model. */
  function optionPrice(opt, model, qty) {
    if (opt.price_type === 'flat') return { price: Number(opt.price), callFor: false };
    if (opt.price_type === 'ltf') return { price: Number(opt.price) * (model.length_ft || 0), callFor: false };
    if (opt.price_type === 'perft') return { price: Number(opt.price) * (qty || 1), callFor: false };
    if (opt.price_type === 'band') {
      var p = bandPrice(opt.bands, model.length_ft);
      return { price: p, callFor: p === null };
    }
    return { price: null, callFor: true };
  }

  function byId(list, id) {
    for (var i = 0; i < list.length; i++) if (list[i].id === id) return list[i];
    return null;
  }

  function byId2(list, key, val) {
    for (var i = 0; i < list.length; i++) if (list[i][key] === val) return list[i];
    return null;
  }

  /* Resolves a cart entry into display data. */
  function priceItem(entry) {
    var model = byId(state.models, entry.modelId);
    if (!model) return null;
    var line = byId(state.lines, model.line_id);
    var base = model.prices ? model.prices[entry.variantKey] : null;
    base = (base === null || base === undefined || base === '') ? null : Number(base);
    var needsQuote = base === null;
    var optTotal = 0;
    var parts = [];

    (entry.options || []).forEach(function (ref) {
      var opt = byId(state.options, ref.id);
      if (!opt || opt.applies_to.indexOf(line.category) === -1) return;
      var p = optionPrice(opt, model, ref.qty);
      if (p.callFor || p.price === null) needsQuote = true; else optTotal += p.price;
      parts.push({ label: opt.label, group: opt.group_name, qty: opt.price_type === 'perft' ? (ref.qty || 1) : null, price: p.price });
    });

    (entry.lineOptions || []).forEach(function (id) {
      var lo = byId(state.lineOptions, id);
      if (!lo || lo.line_id !== line.id) return;
      optTotal += Number(lo.price);
      parts.push({ label: lo.label, group: 'Line Options', qty: null, price: Number(lo.price) });
    });

    var unit = needsQuote ? null : base + optTotal;
    var variant = null;
    (line.variants || []).forEach(function (v) { if (v.key === entry.variantKey) variant = v.label; });

    return {
      entry: entry, model: model, line: line, base: base, parts: parts,
      optTotal: optTotal, unit: unit, qty: entry.qty || 1,
      total: unit === null ? null : unit * (entry.qty || 1),
      needsQuote: needsQuote, variantLabel: variant || 'Standard'
    };
  }

  function cartTotals() {
    var sum = 0, count = 0, quote = false;
    state.cart.forEach(function (e) {
      var p = priceItem(e);
      if (!p) return;
      count += p.qty;
      if (p.total === null) quote = true; else sum += p.total;
    });
    return { subtotal: sum, count: count, needsQuote: quote };
  }

  /* --------------------------------------------------------------- catalog */

  function loadCatalog() {
    return Promise.all([
      client.from('catalog_categories').select('*').order('sort'),
      client.from('catalog_lines').select('*').order('sort'),
      client.from('catalog_models').select('*').order('sort'),
      client.from('catalog_options').select('*').order('sort'),
      client.from('catalog_line_options').select('*').order('sort')
    ]).then(function (r) {
      for (var i = 0; i < r.length; i++) {
        if (r[i].error) throw new Error(r[i].error.message);
      }
      state.categories = r[0].data || [];
      state.lines = r[1].data || [];
      state.models = r[2].data || [];
      state.options = r[3].data || [];
      state.lineOptions = r[4].data || [];
    });
  }

  /* ----------------------------------------------------------- build page */

  /* Marks how far along the build is, so the page reads as steps not a wall. */
  function renderSteps() {
    var wrap = el('ob-steps');
    if (!wrap) return;
    var t = cartTotals();
    var steps = [
      { n: '01', label: 'Category', done: !!state.activeCategory },
      { n: '02', label: 'Model', done: !!state.activeLine },
      { n: '03', label: 'Spec it', done: state.cart.length > 0 },
      { n: '04', label: 'Send', done: false }
    ];
    var active = state.cart.length ? 3 : (state.activeLine ? 2 : (state.activeCategory ? 1 : 0));
    wrap.innerHTML = steps.map(function (s, i) {
      var cls = 'ob-step' + (i === active ? ' is-on' : '') + (s.done && i < active ? ' is-done' : '');
      return '<li class="' + cls + '"><span class="ob-step__n">' + s.n + '</span>' +
        '<span class="ob-step__l">' + esc(s.label) + '</span></li>';
    }).join('');
    if (t.count) {
      wrap.setAttribute('data-count', t.count + (t.count === 1 ? ' trailer' : ' trailers'));
    } else {
      wrap.removeAttribute('data-count');
    }
  }

  function renderCategories() {
    var wrap = el('ob-cats');
    if (!wrap) return;
    wrap.innerHTML = state.categories.map(function (c) {
      var n = state.lines.filter(function (l) { return l.category === c.slug; }).length;
      var art = CATEGORY_ART[c.slug];
      return '<button type="button" class="ob-cat' + (c.slug === state.activeCategory ? ' is-on' : '') +
        '" data-cat="' + esc(c.slug) + '">' +
        (art ? '<img class="ob-cat__img" src="' + esc(art) + '" alt="" loading="lazy" width="280" height="170">' : '') +
        '<span class="ob-cat__body">' +
          '<span class="ob-cat__name">' + esc(c.name) + '</span>' +
          '<span class="ob-cat__meta">' + n + (n === 1 ? ' model line' : ' model lines') + '</span>' +
        '</span></button>';
    }).join('');
    Array.prototype.forEach.call(wrap.querySelectorAll('[data-cat]'), function (b) {
      b.addEventListener('click', function () {
        state.activeCategory = b.getAttribute('data-cat');
        state.activeLine = null;
        renderCategories(); renderLines(); renderConfig(); renderSteps();
      });
    });
  }

  function renderLines() {
    var wrap = el('ob-lines');
    if (!wrap) return;
    var lines = state.lines.filter(function (l) { return l.category === state.activeCategory; });
    if (!lines.length) { wrap.innerHTML = ''; return; }
    wrap.innerHTML = '<h2 class="ob-h"><span class="ob-h__n">02</span>Pick a model line</h2><div class="ob-linegrid">' +
      lines.map(function (l) {
        var models = state.models.filter(function (m) { return m.line_id === l.id; });
        var prices = [];
        models.forEach(function (m) {
          for (var k in m.prices) {
            if (m.prices[k] !== null && m.prices[k] !== undefined) prices.push(Number(m.prices[k]));
          }
        });
        var from = prices.length ? Math.min.apply(null, prices) : null;
        return '<button type="button" class="ob-line' + (state.activeLine === l.id ? ' is-on' : '') +
          '" data-line="' + esc(l.id) + '">' +
          '<span class="ob-line__head">' +
            '<span class="ob-line__name">' + esc(l.name) + '</span>' +
            (from !== null
              ? '<span class="ob-line__from"><em>from</em>' + money(from) + '</span>'
              : '<span class="ob-line__from ob-line__from--q">Quoted</span>') +
          '</span>' +
          '<span class="ob-line__blurb">' + esc(l.blurb || '') + '</span>' +
          '<span class="ob-line__meta">' + models.length + (models.length === 1 ? ' size' : ' sizes') +
          '<span class="ob-line__go">Spec it</span></span></button>';
      }).join('') + '</div>';
    Array.prototype.forEach.call(wrap.querySelectorAll('[data-line]'), function (b) {
      b.addEventListener('click', function () {
        state.activeLine = b.getAttribute('data-line');
        renderLines(); renderConfig(); renderSteps();
        var c = el('ob-config');
        if (c) c.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    });
  }

  /* Working configuration for the line on screen. */
  var draft = null;

  function renderConfig() {
    var wrap = el('ob-config');
    if (!wrap) return;
    if (!state.activeLine) { wrap.innerHTML = ''; return; }
    var line = byId(state.lines, state.activeLine);
    var models = state.models.filter(function (m) { return m.line_id === line.id; });
    var variants = line.variants && line.variants.length ? line.variants : [{ key: 'std', label: 'Standard' }];

    if (!draft || draft.lineId !== line.id) {
      draft = {
        lineId: line.id, modelId: models[0] ? models[0].id : null,
        variantKey: variants[0].key, qty: 1, notes: '',
        options: {}, lineOptions: {}
      };
    }

    var opts = state.options.filter(function (o) { return o.applies_to.indexOf(line.category) > -1; });
    var lopts = state.lineOptions.filter(function (o) { return o.line_id === line.id; });
    var groups = {};
    opts.forEach(function (o) { (groups[o.group_name] = groups[o.group_name] || []).push(o); });

    var model = byId(state.models, draft.modelId);

    var art = CATEGORY_ART[line.category];
    var catName = (function () {
      var c = byId2(state.categories, 'slug', line.category);
      return c ? c.name : line.category.replace('-', ' ');
    })();

    var html = '<div class="ob-panel">' +
      '<div class="ob-panel__head">' +
        (art ? '<img class="ob-panel__art" src="' + esc(art) + '" alt="" loading="lazy" width="200" height="140">' : '') +
        '<div class="ob-panel__headtext">' +
          '<p class="eyebrow"><span class="eyebrow__tick" aria-hidden="true"></span>' + esc(catName) + '</p>' +
          '<h2 class="ob-panel__title">' + esc(line.name) + '</h2>' +
          (line.blurb ? '<p class="ob-panel__blurb">' + esc(line.blurb) + '</p>' : '') +
        '</div>' +
      '</div>';

    if (line.standards && line.standards.length) {
      html += '<details class="ob-std"><summary>What comes standard</summary><ul>' +
        line.standards.map(function (s) { return '<li>' + esc(s) + '</li>'; }).join('') +
        '</ul></details>';
    }

    html += '<div class="ob-row"><div class="ob-field"><label for="ob-model">Size</label>' +
      '<select id="ob-model">' + models.map(function (m) {
        var p = m.prices ? m.prices[draft.variantKey] : null;
        return '<option value="' + esc(m.id) + '"' + (m.id === draft.modelId ? ' selected' : '') + '>' +
          esc(m.label) + (p ? '  ' + money(Number(p)) : '  quoted') + '</option>';
      }).join('') + '</select></div>';

    if (variants.length > 1) {
      html += '<div class="ob-field"><label for="ob-variant">Package</label><select id="ob-variant">' +
        variants.map(function (v) {
          return '<option value="' + esc(v.key) + '"' + (v.key === draft.variantKey ? ' selected' : '') + '>' +
            esc(v.label) + '</option>';
        }).join('') + '</select></div>';
    }

    html += '<div class="ob-field ob-field--qty"><label for="ob-qty">Quantity</label>' +
      '<input id="ob-qty" type="number" min="1" max="99" value="' + draft.qty + '"></div></div>';

    var groupNames = Object.keys(groups);
    if (groupNames.length || lopts.length) {
      html += '<div class="ob-opts"><h3 class="ob-h3">Options</h3>';
      if (lopts.length) {
        html += '<details class="ob-group" open><summary>For this model line</summary><div class="ob-optlist">' +
          lopts.map(function (o) {
            return '<label class="ob-opt"><input type="checkbox" data-lopt="' + esc(o.id) + '"' +
              (draft.lineOptions[o.id] ? ' checked' : '') + '><span class="ob-opt__label">' + esc(o.label) +
              '</span><span class="ob-opt__price">' + money(Number(o.price)) + '</span></label>';
          }).join('') + '</div></details>';
      }
      groupNames.forEach(function (g) {
        html += '<details class="ob-group"><summary>' + esc(g) + '</summary><div class="ob-optlist">' +
          groups[g].map(function (o) {
            var p = model ? optionPrice(o, model, draft.options[o.id] && draft.options[o.id].qty) : { price: null, callFor: true };
            var priceTxt = o.price_type === 'call' ? 'Call for pricing'
              : (p.price === null ? 'Not offered at this length' : money(p.price));
            var disabled = (o.price_type === 'band' && p.price === null) ? ' disabled' : '';
            var row = '<label class="ob-opt' + (disabled ? ' is-off' : '') + '">' +
              '<input type="checkbox" data-opt="' + esc(o.id) + '"' +
              (draft.options[o.id] ? ' checked' : '') + disabled + '>' +
              '<span class="ob-opt__label">' + esc(o.label) +
              (o.price_type === 'ltf' ? ' <em>(' + money(Number(o.price)) + ' per foot of deck)</em>' : '') +
              '</span><span class="ob-opt__price">' + priceTxt + '</span>';
            if (o.price_type === 'perft') {
              row += '<input class="ob-optqty" type="number" min="1" max="200" placeholder="ft" ' +
                'data-optqty="' + esc(o.id) + '" value="' +
                (draft.options[o.id] && draft.options[o.id].qty ? draft.options[o.id].qty : '') + '">';
            }
            return row + '</label>';
          }).join('') + '</div></details>';
      });
      html += '</div>';
    }

    html += '<div class="ob-field"><label for="ob-notes">Notes for this trailer</label>' +
      '<textarea id="ob-notes" rows="2" placeholder="Color, deck details, anything the shop should know.">' +
      esc(draft.notes) + '</textarea></div>';

    var live = draftPrice();
    html += '<div class="ob-live"><div class="ob-live__fig">' +
      '<span class="ob-live__label">Dealer price, each</span>' +
      '<strong class="ob-live__num">' + (live.unit === null ? 'Factory quote' : money(live.unit)) + '</strong>' +
      '<span class="ob-live__sub">' + (live.optTotal
        ? 'Base ' + money(live.base) + ' plus ' + money(live.optTotal) + ' in options'
        : 'Base price, no options added') + '</span>' +
      '</div><button type="button" class="btn btn--red" id="ob-add">Add to request</button></div>';

    html += '</div>';
    wrap.innerHTML = html;

    var m = el('ob-model'); if (m) m.addEventListener('change', function () { draft.modelId = m.value; renderConfig(); });
    var v = el('ob-variant'); if (v) v.addEventListener('change', function () { draft.variantKey = v.value; renderConfig(); });
    var q = el('ob-qty'); if (q) q.addEventListener('input', function () {
      draft.qty = Math.max(1, Math.min(99, parseInt(q.value, 10) || 1));
      var lv = draftPrice(); var n = wrap.querySelector('.ob-live__num');
      if (n) n.textContent = lv.unit === null ? 'Factory quote' : money(lv.unit);
    });
    var nt = el('ob-notes'); if (nt) nt.addEventListener('input', function () { draft.notes = nt.value; });

    Array.prototype.forEach.call(wrap.querySelectorAll('[data-opt]'), function (cb) {
      cb.addEventListener('change', function () {
        var id = cb.getAttribute('data-opt');
        if (cb.checked) draft.options[id] = { qty: draft.options[id] ? draft.options[id].qty : null };
        else delete draft.options[id];
        renderConfig();
      });
    });
    Array.prototype.forEach.call(wrap.querySelectorAll('[data-lopt]'), function (cb) {
      cb.addEventListener('change', function () {
        var id = cb.getAttribute('data-lopt');
        if (cb.checked) draft.lineOptions[id] = true; else delete draft.lineOptions[id];
        renderConfig();
      });
    });
    Array.prototype.forEach.call(wrap.querySelectorAll('[data-optqty]'), function (inp) {
      inp.addEventListener('input', function () {
        var id = inp.getAttribute('data-optqty');
        var val = Math.max(1, Math.min(200, parseInt(inp.value, 10) || 1));
        if (!draft.options[id]) draft.options[id] = {};
        draft.options[id].qty = val;
        var lv = draftPrice(); var n = wrap.querySelector('.ob-live__num');
        if (n) n.textContent = lv.unit === null ? 'Factory quote' : money(lv.unit);
      });
    });
    var add = el('ob-add');
    if (add) add.addEventListener('click', addDraftToCart);
  }

  function draftToEntry() {
    var options = [];
    for (var id in draft.options) {
      if (Object.prototype.hasOwnProperty.call(draft.options, id)) {
        options.push({ id: id, qty: draft.options[id] && draft.options[id].qty ? draft.options[id].qty : null });
      }
    }
    var lineOptions = [];
    for (var lid in draft.lineOptions) {
      if (draft.lineOptions[lid]) lineOptions.push(lid);
    }
    return {
      modelId: draft.modelId, variantKey: draft.variantKey, qty: draft.qty,
      notes: draft.notes, options: options, lineOptions: lineOptions
    };
  }

  function draftPrice() {
    var p = priceItem(draftToEntry());
    return p || { unit: null, base: null, optTotal: 0 };
  }

  function addDraftToCart() {
    if (!draft || !draft.modelId) return;
    state.cart.push(draftToEntry());
    saveCart();
    renderCart();
    var btn = el('ob-add');
    if (btn) {
      btn.textContent = 'Added';
      btn.classList.add('is-added');
      setTimeout(function () { btn.textContent = 'Add to request'; btn.classList.remove('is-added'); }, 1400);
    }
    var c = el('ob-cart');
    if (c && window.innerWidth < 900) c.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  function renderCart() {
    var wrap = el('ob-cartbody');
    if (!wrap) return;
    var t = cartTotals();
    var badge = el('ob-cartcount');
    if (badge) badge.textContent = t.count ? String(t.count) : '';
    var cbadge = el('ob-cartbadge');
    if (cbadge) cbadge.textContent = t.count ? String(t.count) : '';
    renderSteps();

    if (!state.cart.length) {
      wrap.innerHTML = '<div class="ob-empty">' +
        '<svg viewBox="0 0 48 30" width="60" height="38" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true">' +
        '<path d="M2 22h4M42 22h4M6 22a4 4 0 1 0 8 0 4 4 0 1 0-8 0M30 22a4 4 0 1 0 8 0 4 4 0 1 0-8 0"/>' +
        '<path d="M2 8h34v14M36 12h6l4 6v4"/></svg>' +
        '<p>Nothing on this request yet.</p>' +
        '<p class="ob-empty__sub">Pick a category, choose a model, spec it, and it stacks up here.</p>' +
        '</div>';
      var sb = el('ob-submitwrap'); if (sb) sb.style.display = 'none';
      return;
    }

    wrap.innerHTML = state.cart.map(function (e, i) {
      var p = priceItem(e);
      if (!p) return '';
      return '<div class="ob-ci">' +
        '<div class="ob-ci__top"><span class="ob-ci__qty">' + p.qty + ' x</span>' +
        '<span class="ob-ci__name">' + esc(p.line.name) + ' ' + esc(p.model.label) +
        (p.variantLabel !== 'Standard' ? ' <em>' + esc(p.variantLabel) + '</em>' : '') + '</span>' +
        '<button type="button" class="ob-ci__x" data-rm="' + i + '" aria-label="Remove this trailer">&times;</button></div>' +
        (p.parts.length ? '<ul class="ob-ci__opts">' + p.parts.map(function (o) {
          return '<li>' + esc(o.label) + (o.qty ? ' x' + o.qty : '') +
            '<span>' + (o.price === null ? 'quote' : money(o.price)) + '</span></li>';
        }).join('') + '</ul>' : '') +
        (e.notes ? '<p class="ob-ci__note">' + esc(e.notes) + '</p>' : '') +
        '<p class="ob-ci__total">' + (p.total === null ? 'Factory quote' : money(p.total)) + '</p>' +
        '</div>';
    }).join('');

    wrap.innerHTML += '<div class="ob-sum">' +
      '<div class="ob-sum__row"><span>Trailers</span><strong>' + t.count + '</strong></div>' +
      '<div class="ob-sum__row ob-sum__row--big"><span>Dealer subtotal</span><strong>' + money(t.subtotal) + '</strong></div>' +
      (t.needsQuote ? '<p class="ob-sum__note">Some items need a factory quote. The subtotal covers the priced items only.</p>' : '') +
      '<p class="ob-sum__note">Freight, taxes, and any options priced by call are not included. The office confirms everything before a build starts.</p>' +
      '</div>';

    Array.prototype.forEach.call(wrap.querySelectorAll('[data-rm]'), function (b) {
      b.addEventListener('click', function () {
        state.cart.splice(parseInt(b.getAttribute('data-rm'), 10), 1);
        saveCart(); renderCart();
      });
    });
    var sw = el('ob-submitwrap'); if (sw) sw.style.display = '';
  }

  /* ---------------------------------------------------------- submit flow */

  function buildPayload(form) {
    return {
      contact_name: form.name.value.trim(),
      contact_phone: form.phone.value.trim(),
      contact_email: form.email.value.trim(),
      po_number: form.po.value.trim(),
      needed_by: form.needed.value || null,
      notes: form.notes.value.trim(),
      items: state.cart.map(function (e) {
        return {
          model_id: e.modelId, variant_key: e.variantKey, qty: e.qty,
          notes: e.notes || null,
          options: (e.options || []).map(function (o) { return { id: o.id, qty: o.qty }; }),
          line_options: (e.lineOptions || []).map(function (id) { return { id: id }; })
        };
      })
    };
  }

  function plainTextSummary(orderNo) {
    var lines = [];
    lines.push('Order request ' + (orderNo || '') + ' from ' + (state.dealer ? state.dealer.name : ''));
    lines.push('');
    state.cart.forEach(function (e) {
      var p = priceItem(e);
      if (!p) return;
      lines.push(p.qty + ' x ' + p.line.name + ' ' + p.model.label +
        (p.variantLabel !== 'Standard' ? ' (' + p.variantLabel + ')' : '') +
        '  ' + (p.total === null ? 'needs a quote' : money(p.total)));
      p.parts.forEach(function (o) {
        lines.push('    - ' + o.label + (o.qty ? ' x' + o.qty : '') +
          (o.price === null ? ' (quote)' : ' ' + money(o.price)));
      });
      if (e.notes) lines.push('    note: ' + e.notes);
    });
    var t = cartTotals();
    lines.push('');
    lines.push('Dealer subtotal: ' + money(t.subtotal));
    return lines.join('\n');
  }

  function showConfirmation(result) {
    var shell = el('portal-shell');
    var summary = plainTextSummary(result.order_no);
    var mailto = 'mailto:' + ORDER_EMAIL +
      '?subject=' + encodeURIComponent('Order request ' + result.order_no + ' from ' + (state.dealer ? state.dealer.name : 'a dealer')) +
      '&body=' + encodeURIComponent(summary);
    if (!shell) return;
    shell.innerHTML =
      '<div class="ob-done">' +
      '<p class="eyebrow"><span class="eyebrow__tick" aria-hidden="true"></span>Request sent</p>' +
      '<h2 class="ob-done__title">' + esc(result.order_no) + ' is with the factory.</h2>' +
      '<p class="ob-done__lede">' + result.item_count + ' trailer' + (result.item_count === 1 ? '' : 's') +
      ', dealer subtotal ' + money(Number(result.subtotal)) + '. ' +
      (result.has_quote_items ? 'Some lines need a factory quote and are not in that number. ' : '') +
      'Somebody in Booneville will call to confirm the build and the lead time.</p>' +
      '<div class="ob-done__cta">' +
      '<a class="btn btn--red" href="dealer-requests.html">See your requests</a>' +
      '<a class="btn btn--ghost" href="dealer-order.html">Start another</a>' +
      '</div>' +
      '<p class="ob-done__mail">Want a copy in your own inbox? ' +
      '<a href="' + esc(mailto) + '">Email yourself this request</a>, or call the office at ' +
      '<a href="tel:+16627287975">' + PHONE + '</a>.</p>' +
      '</div>';
    state.cart = [];
    saveCart();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function wireSubmit() {
    var form = el('ob-submit');
    if (!form) return;
    if (state.dealer) {
      if (state.dealer.contact && !form.name.value) form.name.value = state.dealer.contact;
      if (state.dealer.phone && !form.phone.value) form.phone.value = state.dealer.phone;
    }
    if (state.user && !form.email.value) form.email.value = state.user.email;

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (!state.cart.length) return;
      var status = el('ob-status');
      var btn = el('ob-send');
      btn.disabled = true;
      status.textContent = 'Sending your request...';
      status.className = 'ob-status';
      client.rpc('submit_order', { payload: buildPayload(form) }).then(function (r) {
        if (r.error) {
          btn.disabled = false;
          status.textContent = r.error.message + ' If this keeps happening, call ' + PHONE + '.';
          status.className = 'ob-status is-bad';
          return;
        }
        showConfirmation(r.data);
      });
    });
  }

  /* ---------------------------------------------------- past requests page */

  var STATUS_LABEL = {
    submitted: 'With the factory', confirmed: 'Confirmed', in_build: 'In build',
    ready: 'Ready', delivered: 'Delivered', cancelled: 'Cancelled'
  };

  function renderRequests() {
    var wrap = el('rq-list');
    setBusy(wrap, 'Loading your requests...');
    client.from('orders')
      .select('id, order_no, created_at, status, po_number, needed_by, item_count, subtotal, has_quote_items, notes, order_items(*)')
      .order('created_at', { ascending: false })
      .then(function (r) {
        if (r.error) {
          wrap.innerHTML = '<p class="ob-empty">Could not load your requests (' + esc(r.error.message) +
            '). Call the office at ' + PHONE + '.</p>';
          return;
        }
        var rows = r.data || [];
        if (!rows.length) {
          wrap.innerHTML = '<p class="ob-empty">No requests yet. ' +
            '<a href="dealer-order.html">Build your first one</a>.</p>';
          return;
        }
        wrap.innerHTML = rows.map(function (o) {
          var items = (o.order_items || []).sort(function (a, b) { return a.sort - b.sort; });
          return '<article class="rq">' +
            '<header class="rq__head">' +
              '<div><h2 class="rq__no">' + esc(o.order_no) + '</h2>' +
              '<p class="rq__when">' + new Date(o.created_at).toLocaleDateString('en-US',
                { year: 'numeric', month: 'short', day: 'numeric' }) +
              (o.po_number ? ' &middot; PO ' + esc(o.po_number) : '') +
              (o.needed_by ? ' &middot; needed by ' + esc(o.needed_by) : '') + '</p></div>' +
              '<span class="rq__status rq__status--' + esc(o.status) + '">' +
              esc(STATUS_LABEL[o.status] || o.status) + '</span>' +
            '</header>' +
            '<ul class="rq__items">' + items.map(function (i) {
              return '<li><span class="rq__qty">' + i.qty + ' x</span>' +
                '<span class="rq__name">' + esc(i.line_name) + ' ' + esc(i.model_label) +
                (i.variant_label && i.variant_label !== 'Standard' ? ' <em>' + esc(i.variant_label) + '</em>' : '') +
                '</span>' +
                '<span class="rq__amt">' + (i.line_total === null ? 'Quote' : money(Number(i.line_total))) + '</span>' +
                ((i.options && i.options.length) ? '<span class="rq__opts">' +
                  i.options.map(function (x) { return esc(x.label); }).join(', ') + '</span>' : '') +
                (i.notes ? '<span class="rq__note">' + esc(i.notes) + '</span>' : '') +
                '</li>';
            }).join('') + '</ul>' +
            (o.notes ? '<p class="rq__ordernote"><strong>Your note:</strong> ' + esc(o.notes) + '</p>' : '') +
            '<footer class="rq__foot"><span>' + o.item_count + ' trailer' + (o.item_count === 1 ? '' : 's') + '</span>' +
            '<strong>' + (Number(o.subtotal) === 0 && o.has_quote_items
              ? 'Factory quote'
              : money(Number(o.subtotal)) + (o.has_quote_items ? ' plus quoted items' : '')) +
            '</strong></footer>' +
            '</article>';
        }).join('');
      });
  }

  /* ------------------------------------------------------------------ boot */

  requireSession().then(function (session) {
    if (!session) return;
    if (reqRoot) { renderRequests(); return; }
    setBusy(el('ob-lines'), 'Loading the current price list...');
    return loadCatalog().then(function () {
      state.activeCategory = state.categories.length ? state.categories[0].slug : null;
      renderCategories(); renderLines(); renderConfig(); renderCart(); renderSteps(); wireSubmit();
      var stamp = el('ob-stamp');
      if (stamp) stamp.textContent = state.models.length + ' builds on the current dealer price list.';
    }).catch(function (err) {
      var wrap = el('ob-lines');
      if (wrap) {
        wrap.innerHTML = '<p class="ob-empty">Could not load the catalog (' + esc(err.message) +
          '). Call the office at ' + PHONE + ' and we will take the order by phone.</p>';
      }
    });
  });
})();
