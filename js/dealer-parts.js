/* Triple R Trailers dealer parts requests.
   Drives dealer-parts.html.

   Parts have no published dealer price list, so this collects what the dealer
   needs and sends it to the office. No prices are shown or implied; the office
   confirms the part and the price on the callback. */
(function () {
  'use strict';

  var cfg = window.TRIPLE_R_PORTAL || {};
  var configured = cfg.SUPABASE_URL && cfg.SUPABASE_URL.indexOf('http') === 0 &&
    cfg.SUPABASE_ANON_KEY && cfg.SUPABASE_ANON_KEY.indexOf('PASTE') !== 0;

  var root = document.getElementById('pr-root');
  if (!root) return;

  var notice = document.getElementById('portal-unconfigured');
  if (!configured) {
    if (notice) notice.style.display = '';
    var shell0 = document.getElementById('portal-shell');
    if (shell0) shell0.style.display = 'none';
    return;
  }

  var client = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
  var ORDER_EMAIL = cfg.ORDER_EMAIL || 'triplertrailers@gmail.com';
  var PHONE = '(662) 728-7975';

  function esc(s) {
    return String(s === null || s === undefined ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
  function el(id) { return document.getElementById(id); }

  var state = { user: null, dealer: null, rows: 0 };

  /* ------------------------------------------------------------- the lines */

  function addRow(focus) {
    var list = el('pr-rows');
    if (!list) return;
    var i = state.rows++;
    var row = document.createElement('div');
    row.className = 'pr-row';
    row.innerHTML =
      '<div class="ob-field pr-row__desc">' +
        '<label for="pr-desc-' + i + '">Part or service needed</label>' +
        '<input id="pr-desc-' + i + '" type="text" data-desc ' +
          'placeholder="Left fender, ramp spring, 7 way plug..." maxlength="400">' +
      '</div>' +
      '<div class="ob-field pr-row__for">' +
        '<label for="pr-for-' + i + '">For which trailer <span>optional</span></label>' +
        '<input id="pr-for-' + i + '" type="text" data-for ' +
          'placeholder="7X16 enclosed, 2024" maxlength="200">' +
      '</div>' +
      '<div class="ob-field pr-row__qty">' +
        '<label for="pr-qty-' + i + '">Qty</label>' +
        '<input id="pr-qty-' + i + '" type="number" min="1" max="999" value="1" data-qty>' +
      '</div>' +
      '<button type="button" class="pr-row__x" data-rm aria-label="Remove this line">&times;</button>';
    list.appendChild(row);
    row.querySelector('[data-rm]').addEventListener('click', function () {
      if (list.children.length > 1) { row.remove(); } else { clearRow(row); }
    });
    if (focus) row.querySelector('[data-desc]').focus();
  }

  function clearRow(row) {
    row.querySelector('[data-desc]').value = '';
    row.querySelector('[data-for]').value = '';
    row.querySelector('[data-qty]').value = '1';
  }

  function collectItems() {
    var out = [];
    Array.prototype.forEach.call(document.querySelectorAll('#pr-rows .pr-row'), function (row) {
      var d = row.querySelector('[data-desc]').value.trim();
      if (!d) return;
      out.push({
        description: d,
        trailer_ref: row.querySelector('[data-for]').value.trim() || null,
        qty: Math.max(1, Math.min(999, parseInt(row.querySelector('[data-qty]').value, 10) || 1))
      });
    });
    return out;
  }

  /* ------------------------------------------------------------ submission */

  function plainText(reqNo, items) {
    var lines = ['Parts request ' + (reqNo || '') + ' from ' + (state.dealer ? state.dealer.name : ''), ''];
    items.forEach(function (i) {
      lines.push(i.qty + ' x ' + i.description + (i.trailer_ref ? '  (for ' + i.trailer_ref + ')' : ''));
    });
    return lines.join('\n');
  }

  function showDone(result, items) {
    var shell = el('portal-shell');
    if (!shell) return;
    var mailto = 'mailto:' + ORDER_EMAIL +
      '?subject=' + encodeURIComponent('Parts request ' + result.req_no + ' from ' + (state.dealer ? state.dealer.name : 'a dealer')) +
      '&body=' + encodeURIComponent(plainText(result.req_no, items));
    shell.innerHTML =
      '<div class="ob-done">' +
      '<p class="eyebrow"><span class="eyebrow__tick" aria-hidden="true"></span>Request sent</p>' +
      '<h2 class="ob-done__title">' + esc(result.req_no) + ' is with the parts desk.</h2>' +
      '<p class="ob-done__lede">' + result.item_count +
      (result.item_count === 1 ? ' line' : ' lines') + ' on the way to Booneville. ' +
      'The office confirms the part and the price, then ships it or holds it for pickup. ' +
      'Parts are not priced in the portal, so nothing here is a quote.</p>' +
      '<div class="ob-done__cta">' +
      '<a class="btn btn--red" href="dealer-requests.html">See your requests</a>' +
      '<a class="btn btn--ghost" href="dealer-parts.html">Request more parts</a>' +
      '</div>' +
      '<p class="ob-done__mail">Want a copy for your own records? ' +
      '<a href="' + esc(mailto) + '">Email yourself this request</a>, or call the shop at ' +
      '<a href="tel:+16627287975">' + PHONE + '</a>.</p>' +
      '</div>';
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function wire() {
    var addBtn = el('pr-add');
    if (addBtn) addBtn.addEventListener('click', function () { addRow(true); });

    var form = el('pr-submit');
    if (!form) return;
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var items = collectItems();
      var status = el('pr-status');
      if (!items.length) {
        status.textContent = 'Add at least one part before sending.';
        status.className = 'ob-status is-bad';
        return;
      }
      var btn = el('pr-send');
      btn.disabled = true;
      status.textContent = 'Sending your request...';
      status.className = 'ob-status';

      client.rpc('submit_part_request', {
        payload: {
          contact_name: form.name.value.trim(),
          contact_phone: form.phone.value.trim(),
          contact_email: form.email.value.trim(),
          po_number: form.po.value.trim(),
          needed_by: form.needed.value || null,
          notes: form.notes.value.trim(),
          items: items
        }
      }).then(function (r) {
        if (r.error) {
          btn.disabled = false;
          status.textContent = r.error.message + ' If this keeps happening, call ' + PHONE + '.';
          status.className = 'ob-status is-bad';
          return;
        }
        showDone(r.data, items);
      });
    });
  }

  /* ------------------------------------------------------------------ boot */

  client.auth.getSession().then(function (res) {
    var session = res.data.session;
    if (!session) { window.location.href = 'dealer-login.html'; return; }
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
          state.dealer.contact = r.data.full_name;
          var dn = el('portal-dealer');
          if (dn) {
            dn.textContent = state.dealer.name +
              (state.dealer.city ? ', ' + state.dealer.city + ', ' + state.dealer.state : '');
          }
        }
        var form = el('pr-submit');
        if (form) {
          if (state.dealer && state.dealer.contact && !form.name.value) form.name.value = state.dealer.contact;
          if (state.dealer && state.dealer.phone && !form.phone.value) form.phone.value = state.dealer.phone;
          if (!form.email.value) form.email.value = session.user.email;
        }
        addRow(false); addRow(false); addRow(false);
        wire();
      });
  });
})();
