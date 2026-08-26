/* Triple R Trailers: where an invite or a reset link lands.
   Drives dealer-set-password.html.

   Every email Supabase sends a dealer ends up here: the first invite, the
   "send it again" from the office, and the sign-in link on the login page.
   All three arrive with a one-time token in the address bar, which Supabase
   turns into a signed-in session as soon as this page loads. What that session
   cannot do on its own is give them a password, so until this page existed a
   dealer got in once and then had nothing to type the next morning.

   The token in the address is a real key for as long as it lasts, so it comes
   off the address bar the moment it has been used, and this is the one page on
   the site with no analytics tag on it, because an analytics tag reports the
   address it was loaded on, token and all. */
(function () {
  'use strict';

  var cfg = window.TRIPLE_R_PORTAL || {};
  var configured = cfg.SUPABASE_URL && cfg.SUPABASE_URL.indexOf('http') === 0 &&
    cfg.SUPABASE_ANON_KEY && cfg.SUPABASE_ANON_KEY.indexOf('PASTE') !== 0;

  var root = document.getElementById('sp-root');
  if (!root) return;

  var notice = document.getElementById('portal-unconfigured');
  function el(id) { return document.getElementById(id); }

  function breakDown(msg) {
    if (notice) {
      notice.style.display = '';
      notice.innerHTML = msg;
    }
    var checking = el('sp-checking');
    if (checking) checking.style.display = 'none';
  }

  if (!configured) {
    breakDown('<strong>The portal is being connected.</strong> Call the office at ' +
      '<a href="tel:+16627287975" style="color: var(--bone); font-weight:600;">(662) 728-7975</a>.');
    return;
  }

  if (!window.supabase || !window.supabase.createClient) {
    breakDown('<strong>This page did not load properly.</strong> Refresh it. If it keeps ' +
      'happening, call the office at ' +
      '<a href="tel:+16627287975" style="color: var(--bone); font-weight:600;">(662) 728-7975</a>.');
    return;
  }

  /* Which of the three emails this was. Read before anything else touches the
     address bar, because Supabase clears it once it has used the token.
       invite     brand new, has no password at all
       recovery   has a login, forgot the password
       magiclink  signed in fine, just did not want to type a password */
  var linkType = (/[#&?]type=([a-z_]+)/.exec(window.location.hash + window.location.search) || [])[1] || '';

  var client = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);

  /* Supabase reads the token out of the address as soon as it starts up. Once
     it has, the address should not keep carrying it: not into history, not
     into a bookmark, and not into anything the browser hands on. */
  function scrubAddress() {
    if (!window.history || !window.history.replaceState) return;
    if (!window.location.hash && !window.location.search) return;
    try {
      window.history.replaceState(null, '', window.location.pathname);
    } catch (e) {}
  }

  function setStatus(id, msg, bad) {
    var node = el(id);
    if (!node) return;
    node.textContent = msg || '';
    node.className = bad ? 'ob-status is-bad' : 'ob-status';
  }

  /* ------------------------------------------------------- the two outcomes */

  function showForm(session) {
    scrubAddress();
    el('sp-checking').style.display = 'none';
    el('sp-ready').hidden = false;
    el('sp-email').textContent = session.user.email;

    /* Somebody who came in on a sign-in link is already where they wanted to
       be, so setting a password is an offer, not a toll gate. Somebody who
       came in on an invite or a reset has nothing to fall back on, so for
       them it is the whole point of the page. */
    if (linkType !== 'invite' && linkType !== 'recovery') {
      el('sp-skipwrap').hidden = false;
      el('sp-skip').addEventListener('click', function () {
        window.location.href = 'dealer-portal.html';
      });
    }

    el('sp-see').addEventListener('change', function () {
      var type = this.checked ? 'text' : 'password';
      el('sp-pw').type = type;
      el('sp-pw2').type = type;
    });

    el('sp-form').addEventListener('submit', function (e) {
      e.preventDefault();
      var pw = el('sp-pw').value;
      var pw2 = el('sp-pw2').value;
      if (pw.length < 8) {
        setStatus('sp-status', 'Make it at least 8 characters long.', true);
        return;
      }
      if (pw !== pw2) {
        setStatus('sp-status', 'Those two do not match. Tick the box below them to see what you typed.', true);
        return;
      }
      var btn = el('sp-save');
      btn.disabled = true;
      setStatus('sp-status', 'Saving...');
      client.auth.updateUser({ password: pw }).then(function (r) {
        if (r.error) {
          btn.disabled = false;
          setStatus('sp-status', r.error.message + ' If this keeps happening, call (662) 728-7975.', true);
          return;
        }
        setStatus('sp-status', 'Done. Taking you to your documents...');
        setTimeout(function () { window.location.href = 'dealer-portal.html'; }, 1200);
      });
    });
  }

  function showExpired() {
    scrubAddress();
    el('sp-checking').style.display = 'none';
    el('sp-expired').hidden = false;

    el('sp-again').addEventListener('submit', function (e) {
      e.preventDefault();
      var email = el('sp-again-email').value.trim();
      if (!email) return;
      setStatus('sp-again-status', 'Sending...');
      client.auth.resetPasswordForEmail(email, {
        redirectTo: window.location.origin + window.location.pathname
      }).then(function (r) {
        if (r.error) {
          setStatus('sp-again-status', 'Could not send that: ' + r.error.message +
            ' Call the office at (662) 728-7975 and we will do it for you.', true);
          return;
        }
        /* Deliberately says the same thing whether or not that address has a
           login, so this page cannot be used to find out who is a dealer. */
        setStatus('sp-again-status', 'If ' + email + ' has a login with us, a fresh link is ' +
          'on its way. Give it a minute, and check junk mail.');
      });
    });
  }

  /* ------------------------------------------------------------------ boot */

  /* The token is turned into a session while this file is still loading, so
     the session is usually there on the first look. Usually is not always:
     on a slow phone the exchange can still be in flight. So watch for it, and
     only call the link dead once it has had a fair chance. */
  var settled = false;
  function settle(session) {
    if (settled) return;
    settled = true;
    if (session) { showForm(session); } else { showExpired(); }
  }

  client.auth.onAuthStateChange(function (event, session) {
    if (session) settle(session);
  });

  client.auth.getSession().then(function (res) {
    if (res.data.session) { settle(res.data.session); return; }
    /* Nothing yet. If the address still carries a token, the exchange has not
       finished; give it a moment before saying the link is dead. */
    var waiting = window.location.hash.indexOf('access_token') > 0 ||
                  window.location.hash.indexOf('error') > 0 ||
                  window.location.search.indexOf('code=') > 0;
    setTimeout(function () {
      if (settled) return;
      client.auth.getSession().then(function (again) {
        settle(again.data.session || null);
      });
    }, waiting ? 2500 : 400);
  });
})();
