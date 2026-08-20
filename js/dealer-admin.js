/* Triple R Trailers office desk. Drives dealer-admin.html.

   Everything here is for the people in Booneville, not for dealers. The page
   checks with the database whether the signed-in account is office staff, and
   sends anyone else back to the normal portal. That check is only for looks:
   every function this page calls checks staff again on the server, so a dealer
   who works out the address still gets nothing. */
(function () {
  'use strict';

  var cfg = window.TRIPLE_R_PORTAL || {};
  var configured = cfg.SUPABASE_URL && cfg.SUPABASE_URL.indexOf('http') === 0 &&
    cfg.SUPABASE_ANON_KEY && cfg.SUPABASE_ANON_KEY.indexOf('PASTE') !== 0;

  var root = document.getElementById('ad-root');
  if (!root) return;

  var notice = document.getElementById('portal-unconfigured');

  if (!configured) {
    if (notice) notice.style.display = '';
    var shell0 = document.getElementById('portal-shell');
    if (shell0) shell0.style.display = 'none';
    return;
  }

  /* The Supabase library is vendored into assets/. If it ever fails to load,
     this page would otherwise sit there looking normal and quietly do nothing,
     which is how a broken deploy reads as "the login stopped working". Say so
     instead. */
  if (!window.supabase || !window.supabase.createClient) {
    if (notice) {
      notice.style.display = '';
      notice.innerHTML = '<strong>The portal did not load properly.</strong> ' +
        'Refresh the page. If it keeps happening, call the office at ' +
        '<a href="tel:+16627287975" style="color: var(--bone); font-weight:600;">(662) 728-7975</a>.';
    }
    var brokenShell = document.getElementById('portal-shell');
    if (brokenShell) brokenShell.style.display = 'none';
    return;
  }

  var client = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
  var PHONE = '(662) 728-7975';

  function esc(s) {
    return String(s === null || s === undefined ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
  function el(id) { return document.getElementById(id); }

  function money(n) {
    if (n === null || n === undefined || isNaN(n)) return '';
    return '$' + Number(n).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  function shortDate(s) {
    if (!s) return '';
    return new Date(s).toLocaleDateString('en-US',
      { year: 'numeric', month: 'short', day: 'numeric' });
  }

  var MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /* A needed-by date is a plain calendar date, not a moment in time. Reading
     it straight off the string keeps it from sliding a day either way. */
  function plainDate(s) {
    if (!s) return '';
    var bits = String(s).split('-');
    if (bits.length !== 3) return s;
    return MONTHS[parseInt(bits[1], 10) - 1] + ' ' + parseInt(bits[2], 10) + ', ' + bits[0];
  }

  function setStatus(id, msg, bad) {
    var node = el(id);
    if (!node) return;
    node.textContent = msg || '';
    node.className = bad ? 'ob-status is-bad' : 'ob-status';
  }

  var state = { dealers: [], unlinked: [], pending: null };

  /* -------------------------------------------------- what a status means */

  var TRAILER_STATUS = [
    ['submitted', 'Just came in'],
    ['confirmed', 'Confirmed'],
    ['in_build', 'In the shop'],
    ['ready', 'Ready'],
    ['delivered', 'Delivered'],
    ['cancelled', 'Cancelled']
  ];

  var PARTS_STATUS = [
    ['submitted', 'Just came in'],
    ['confirmed', 'Confirmed'],
    ['shipped', 'Shipped'],
    ['ready', 'Ready for pickup'],
    ['closed', 'Done'],
    ['cancelled', 'Cancelled']
  ];

  function statusOptions(kind, current) {
    var list = kind === 'parts' ? PARTS_STATUS : TRAILER_STATUS;
    return list.map(function (pair) {
      return '<option value="' + pair[0] + '"' +
        (pair[0] === current ? ' selected' : '') + '>' + esc(pair[1]) + '</option>';
    }).join('');
  }

  /* --------------------------------------------------------- the directory */

  function dealerOptions(selected) {
    return '<option value="">Add a new dealership</option>' +
      state.dealers.map(function (d) {
        var where = d.city ? ', ' + d.city + (d.state ? ', ' + d.state : '') : '';
        return '<option value="' + esc(d.id) + '"' + (d.id === selected ? ' selected' : '') +
          '>' + esc(d.name + where) + '</option>';
      }).join('');
  }

  function loadDirectory() {
    return client.rpc('admin_directory').then(function (r) {
      var wrap = el('ad-directory');
      if (r.error) {
        wrap.innerHTML = '<p class="ob-empty">Could not load the dealer list (' +
          esc(r.error.message) + ').</p>';
        return;
      }
      var data = r.data || {};
      state.dealers = data.dealers || [];
      state.unlinked = data.unlinked || [];

      var picker = el('ad-dealer');
      var keep = picker.value;
      picker.innerHTML = dealerOptions(keep);
      toggleNewDealer();

      var html = '';

      if (state.unlinked.length) {
        html += '<div class="ad-loose">' +
          '<h3 class="ad-loose__title">Logins with no dealership yet</h3>' +
          '<p class="ad-loose__note">These accounts exist but are not attached to a lot, so they cannot see pricing or order anything. Pick where each one belongs.</p>' +
          state.unlinked.map(function (u) {
            return '<div class="ad-loose__row" data-email="' + esc(u.email) + '">' +
              '<span class="ad-loose__who">' + esc(u.email) +
              '<em>' + (u.signed_in ? 'has signed in' : 'invite not opened yet') + '</em></span>' +
              '<select class="ad-loose__pick" aria-label="Dealership for ' + esc(u.email) + '">' +
                dealerOptions(null) + '</select>' +
              '<button type="button" class="ad-mini ad-mini--go" data-attach>Attach</button>' +
              '</div>';
          }).join('') +
          '</div>';
      }

      if (!state.dealers.length) {
        html += '<p class="ob-empty">No dealerships added yet. Use the form above and the first one gets created for you.</p>';
      } else {
        html += '<div class="ad-dealers">' + state.dealers.map(function (d) {
          var where = [d.city, d.state].filter(Boolean).join(', ');
          var logins = d.logins || [];
          return '<article class="ad-dealer">' +
            '<header class="ad-dealer__head">' +
              '<div><h3 class="ad-dealer__name">' + esc(d.name) + '</h3>' +
              '<p class="ad-dealer__meta">' +
                (where ? esc(where) : 'Town not on file') +
                (d.phone ? ' &middot; ' + esc(d.phone) : '') +
                ' &middot; ' + d.orders + (d.orders === 1 ? ' trailer order' : ' trailer orders') +
                ' &middot; ' + d.parts + (d.parts === 1 ? ' parts request' : ' parts requests') +
              '</p></div>' +
              '<button type="button" class="ad-mini" data-addlogin="' + esc(d.id) + '">Add a person</button>' +
            '</header>' +
            (logins.length
              ? '<ul class="ad-logins">' + logins.map(function (u) {
                  return '<li>' +
                    '<span class="ad-login__who">' + esc(u.full_name || u.email) +
                      (u.full_name ? '<em>' + esc(u.email) + '</em>' : '') + '</span>' +
                    '<span class="ad-login__seen">' +
                      (u.signed_in ? 'last in ' + shortDate(u.last_seen) : 'invite not opened yet') +
                    '</span>' +
                    '<button type="button" class="ad-mini ad-mini--off" data-unlink="' + esc(u.user_id) +
                      '" data-who="' + esc(u.email) + '">Remove access</button>' +
                    '</li>';
                }).join('') + '</ul>'
              : '<p class="ad-dealer__none">Nobody has a login here yet.</p>') +
            '</article>';
        }).join('') + '</div>';
      }

      wrap.innerHTML = html;
      wireDirectory();
    });
  }

  function wireDirectory() {
    var wrap = el('ad-directory');

    wrap.querySelectorAll('[data-addlogin]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var picker = el('ad-dealer');
        picker.value = btn.getAttribute('data-addlogin');
        toggleNewDealer();
        el('ad-new').scrollIntoView({ behavior: 'smooth', block: 'center' });
        setTimeout(function () { el('ad-name').focus(); }, 350);
      });
    });

    wrap.querySelectorAll('[data-unlink]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var who = btn.getAttribute('data-who');
        if (!window.confirm('Take away ' + who + '\'s access?\n\nThey keep their login but see no pricing, no documents, and cannot order until you attach them again.')) return;
        btn.disabled = true;
        btn.textContent = 'Removing...';
        client.rpc('admin_unlink_login', { p_user_id: btn.getAttribute('data-unlink') })
          .then(function (r) {
            if (r.error) {
              btn.disabled = false;
              btn.textContent = 'Remove access';
              window.alert('Could not remove that: ' + r.error.message);
              return;
            }
            loadDirectory();
          });
      });
    });

    wrap.querySelectorAll('[data-attach]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var row = btn.closest('.ad-loose__row');
        var dealerId = row.querySelector('.ad-loose__pick').value;
        if (!dealerId) {
          window.alert('Pick which dealership this person belongs to first. To create a brand new dealership, use the form at the top of the page.');
          return;
        }
        btn.disabled = true;
        btn.textContent = 'Attaching...';
        client.rpc('admin_link_login', {
          p_email: row.getAttribute('data-email'),
          p_dealer_id: dealerId,
          p_full_name: null
        }).then(function (r) {
          if (r.error) {
            btn.disabled = false;
            btn.textContent = 'Attach';
            window.alert('Could not attach that login: ' + r.error.message);
            return;
          }
          loadDirectory();
        });
      });
    });
  }

  /* ----------------------------------------------------------- the requests */

  function loadRequests() {
    return client.rpc('admin_recent_requests', { p_limit: 30 }).then(function (r) {
      var wrap = el('ad-requests');
      if (r.error) {
        wrap.innerHTML = '<p class="ob-empty">Could not load requests (' + esc(r.error.message) + ').</p>';
        return;
      }
      var rows = r.data || [];
      if (!rows.length) {
        wrap.innerHTML = '<p class="ob-empty">Nothing has come in yet. Dealer requests land here the moment they are sent, and you get the email at the same time.</p>';
        return;
      }
      wrap.innerHTML = '<div class="ad-reqs">' + rows.map(function (o) {
        var amount = o.kind === 'parts'
          ? 'Priced by the office'
          : (Number(o.total) === 0 && o.quote ? 'Factory quote'
             : money(o.total) + (o.quote ? ' plus quoted items' : ''));
        return '<article class="ad-req" data-kind="' + esc(o.kind) + '" data-id="' + esc(o.id) + '">' +
          '<div class="ad-req__id">' +
            '<span class="ad-req__tag ad-req__tag--' + esc(o.kind) + '">' +
              (o.kind === 'parts' ? 'Parts' : 'Trailer') + '</span>' +
            '<strong>' + esc(o.no) + '</strong>' +
            '<span class="ad-req__when">' + shortDate(o.created_at) + '</span>' +
          '</div>' +
          '<div class="ad-req__who">' +
            '<strong>' + esc(o.dealer) + '</strong>' +
            '<span>' + [o.contact, o.phone].filter(Boolean).map(esc).join(' &middot; ') + '</span>' +
          '</div>' +
          '<div class="ad-req__what">' +
            '<span>' + o.items + (o.items === 1 ? ' line' : ' lines') + '</span>' +
            '<strong>' + esc(amount) + '</strong>' +
            (o.needed_by ? '<span>needed by ' + esc(plainDate(o.needed_by)) + '</span>' : '') +
            (o.po ? '<span>PO ' + esc(o.po) + '</span>' : '') +
          '</div>' +
          '<div class="ad-req__set">' +
            '<label class="ad-req__label" for="st-' + esc(o.id) + '">Where it stands</label>' +
            '<select id="st-' + esc(o.id) + '" data-status>' + statusOptions(o.kind, o.status) + '</select>' +
            '<span class="ad-req__saved" aria-live="polite"></span>' +
          '</div>' +
          (o.notes ? '<p class="ad-req__note"><strong>Their note:</strong> ' + esc(o.notes) + '</p>' : '') +
          '</article>';
      }).join('') + '</div>';

      wrap.querySelectorAll('[data-status]').forEach(function (sel) {
        sel.addEventListener('change', function () {
          var card = sel.closest('.ad-req');
          var saved = card.querySelector('.ad-req__saved');
          sel.disabled = true;
          saved.textContent = 'Saving...';
          saved.className = 'ad-req__saved';
          client.rpc('admin_set_status', {
            p_kind: card.getAttribute('data-kind'),
            p_id: card.getAttribute('data-id'),
            p_status: sel.value
          }).then(function (res) {
            sel.disabled = false;
            if (res.error) {
              saved.textContent = res.error.message;
              saved.className = 'ad-req__saved is-bad';
              return;
            }
            saved.textContent = 'Saved. The dealer sees this now.';
            saved.className = 'ad-req__saved is-ok';
            setTimeout(function () { saved.textContent = ''; }, 4000);
          });
        });
      });
    });
  }

  /* --------------------------------------------------- setting a dealer up */

  function toggleNewDealer() {
    var isNew = !el('ad-dealer').value;
    var block = el('ad-newdealer');
    block.hidden = !isNew;
    el('ad-dname').required = isNew;
  }

  /* The one job the browser cannot do alone. Creating a login needs the
     project master key, which lives on Supabase and never here, so the ask
     goes to a small function over there. If that function has not been put in
     place yet, the page says exactly what to do instead. */
  function callCreateFunction(token, payload) {
    return fetch(cfg.SUPABASE_URL + '/functions/v1/create-dealer-login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        apikey: cfg.SUPABASE_ANON_KEY,
        Authorization: 'Bearer ' + token
      },
      body: JSON.stringify(payload)
    }).then(function (res) {
      return res.text().then(function (text) {
        var body = null;
        try { body = JSON.parse(text); } catch (e) {}
        return { status: res.status, body: body, raw: text };
      });
    });
  }

  function showManual(email, dealerId, dealerName) {
    state.pending = { email: email, dealer_id: dealerId };
    var box = el('ad-manual');
    box.hidden = false;
    box.innerHTML =
      '<strong>Almost there. One step by hand this time.</strong>' +
      '<p>The invite button is not switched on for this project yet, so the email has to go out from Supabase. ' +
      (dealerName ? esc(dealerName) + ' is saved already, so you will not lose it.' : '') + '</p>' +
      '<ol class="ad-manual__steps">' +
        '<li>Open Supabase, go to <strong>Authentication</strong>, then <strong>Users</strong>.</li>' +
        '<li>Click <strong>Invite user</strong> and paste in <strong>' + esc(email) + '</strong>.</li>' +
        '<li>Come back here and click the button below.</li>' +
      '</ol>' +
      '<button type="button" class="btn btn--red btn--sm" id="ad-finish">Finish setting up ' + esc(email) + '</button>' +
      '<p class="ob-status" id="ad-manualstatus"></p>';

    el('ad-finish').addEventListener('click', function () {
      var btn = el('ad-finish');
      btn.disabled = true;
      setStatus('ad-manualstatus', 'Attaching...');
      client.rpc('admin_link_login', {
        p_email: state.pending.email,
        p_dealer_id: state.pending.dealer_id,
        p_full_name: null
      }).then(function (r) {
        btn.disabled = false;
        if (r.error) {
          setStatus('ad-manualstatus', r.error.message, true);
          return;
        }
        box.hidden = true;
        setStatus('ad-status', 'Done. ' + state.pending.email + ' is attached and can sign in.', false);
        loadDirectory();
      });
    });
  }

  function wireForm() {
    el('ad-dealer').addEventListener('change', toggleNewDealer);
    toggleNewDealer();

    el('ad-new').addEventListener('submit', function (e) {
      e.preventDefault();
      var btn = el('ad-send');
      var email = el('ad-email').value.trim().toLowerCase();
      var fullName = el('ad-name').value.trim();
      var dealerId = el('ad-dealer').value;
      var dealer = {
        name: el('ad-dname').value.trim(),
        city: el('ad-dcity').value.trim(),
        state: el('ad-dstate').value,
        phone: el('ad-dphone').value.trim()
      };
      if (!dealerId && !dealer.name) {
        setStatus('ad-status', 'Give the dealership a name, or pick one from the list.', true);
        return;
      }

      el('ad-manual').hidden = true;
      btn.disabled = true;
      setStatus('ad-status', 'Setting them up...');

      client.auth.getSession().then(function (s) {
        var token = s.data.session && s.data.session.access_token;
        return callCreateFunction(token, {
          email: email,
          full_name: fullName,
          dealer_id: dealerId || null,
          dealer: dealerId ? null : dealer,
          redirect_to: window.location.origin + '/dealer-portal.html'
        });
      }).then(function (res) {
        btn.disabled = false;

        if (res.status === 404 || res.status === 502 || res.status === 503) {
          // The function is not deployed. Save the dealership anyway so the
          // office does not have to type it twice, then explain the one step.
          var save = dealerId
            ? Promise.resolve({ data: dealerId })
            : client.rpc('admin_save_dealer', {
                p_id: null, p_name: dealer.name, p_city: dealer.city,
                p_state: dealer.state, p_phone: dealer.phone, p_email: null, p_active: true
              });
          return Promise.resolve(save).then(function (r) {
            if (r.error) { setStatus('ad-status', r.error.message, true); return; }
            setStatus('ad-status', '');
            showManual(email, r.data, dealerId ? null : dealer.name);
            loadDirectory();
          });
        }

        if (!res.body || res.body.error) {
          setStatus('ad-status', (res.body && res.body.error) ||
            ('Something went wrong (' + res.status + '). Call the shop at ' + PHONE + ' if this keeps up.'), true);
          return;
        }

        setStatus('ad-status', res.body.already_had_login
          ? email + ' already had a login, so it is now attached to ' + (res.body.dealer || 'the dealership') + '. Nothing else to do.'
          : 'Sent. ' + email + ' has an email waiting with a button to set their password. They are attached to ' +
            (res.body.dealer || 'the dealership') + ' the moment they open it.', false);

        el('ad-new').reset();
        el('ad-dealer').value = '';
        toggleNewDealer();
        loadDirectory();
      }).catch(function (err) {
        btn.disabled = false;
        setStatus('ad-status', 'Could not reach Supabase (' + err.message + ').', true);
      });
    });
  }

  /* ------------------------------------------------------------------ boot */

  client.auth.getSession().then(function (res) {
    var session = res.data.session;
    if (!session) { window.location.href = 'dealer-login.html'; return; }

    var who = el('portal-user');
    if (who) who.textContent = session.user.email;
    var out = el('portal-signout');
    if (out) {
      out.addEventListener('click', function () {
        client.auth.signOut().then(function () { window.location.href = 'dealer-login.html'; });
      });
    }

    return client.rpc('is_staff').then(function (r) {
      if (r.error || r.data !== true) {
        window.location.href = 'dealer-portal.html';
        return;
      }
      var link = el('portal-officelink');
      if (link) link.hidden = false;
      el('ad-gate').hidden = true;
      el('ad-body').hidden = false;
      var dealerLine = el('portal-dealer');
      if (dealerLine) dealerLine.textContent = 'Triple R office';
      wireForm();
      loadDirectory();
      loadRequests();
    });
  });
})();
