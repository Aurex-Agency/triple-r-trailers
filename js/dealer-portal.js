/* Triple R Trailers dealer portal: login + protected documents.
   Real security is enforced by Supabase (auth + storage policies).
   This script only drives the user interface around it. */
(function () {
  'use strict';

  var cfg = window.TRIPLE_R_PORTAL || {};
  var configured = cfg.SUPABASE_URL && cfg.SUPABASE_URL.indexOf('http') === 0 &&
    cfg.SUPABASE_ANON_KEY && cfg.SUPABASE_ANON_KEY.indexOf('PASTE') !== 0;

  var loginForm = document.getElementById('portal-login');
  var docsRoot = document.getElementById('portal-docs');
  var setupNotice = document.getElementById('portal-unconfigured');

  if (!configured) {
    if (setupNotice) setupNotice.style.display = '';
    if (loginForm) loginForm.style.display = 'none';
    if (docsRoot) {
      var backer = document.getElementById('portal-back');
      if (backer) backer.style.display = '';
    }
    return;
  }

  var client = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);

  function setStatus(id, msg, ok) {
    var el = document.getElementById(id);
    if (!el) return;
    el.textContent = msg || '';
    el.style.color = ok ? 'var(--bone)' : 'var(--red-bright)';
  }

  /* ---------------- Login page ---------------- */
  if (loginForm) {
    client.auth.getSession().then(function (res) {
      if (res.data.session) window.location.href = 'dealer-portal.html';
    });

    loginForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var email = document.getElementById('pl-email').value.trim();
      var password = document.getElementById('pl-password').value;
      setStatus('pl-status', 'Signing in...', true);
      client.auth.signInWithPassword({ email: email, password: password }).then(function (res) {
        if (res.error) {
          setStatus('pl-status', 'Sign in failed: ' + res.error.message + '. Need help? Call (662) 728-7975.');
        } else {
          window.location.href = 'dealer-portal.html';
        }
      });
    });

    var magicBtn = document.getElementById('pl-magic');
    if (magicBtn) {
      magicBtn.addEventListener('click', function () {
        var email = document.getElementById('pl-email').value.trim();
        if (!email) { setStatus('pl-status', 'Enter your email first, then tap this button.'); return; }
        setStatus('pl-status', 'Sending sign-in link...', true);
        client.auth.signInWithOtp({
          email: email,
          options: {
            shouldCreateUser: false,
            emailRedirectTo: window.location.origin + window.location.pathname.replace('dealer-login.html', 'dealer-portal.html')
          }
        }).then(function (res) {
          if (res.error) {
            setStatus('pl-status', 'Could not send the link: ' + res.error.message);
          } else {
            setStatus('pl-status', 'Check your email for a sign-in link. It may take a minute.', true);
          }
        });
      });
    }
  }

  /* ---------------- Portal page ---------------- */
  if (docsRoot) {
    client.auth.getSession().then(function (res) {
      var session = res.data.session;
      if (!session) { window.location.href = 'dealer-login.html'; return; }

      var who = document.getElementById('portal-user');
      if (who) who.textContent = session.user.email;

      /* The Office tab is for Triple R staff. is_staff() answers false for
         every dealer login, so for them the tab is never there at all. */
      var officeLink = document.getElementById('portal-officelink');
      if (officeLink) {
        /* Cosmetic only, and never allowed to stop the page rendering. */
        try {
          client.rpc('is_staff').then(function (r) {
            if (!r.error && r.data === true) officeLink.hidden = false;
          }, function () {});
        } catch (e) {}
      }

      /* Which dealership this login belongs to, shown under the email. */
      client.from('dealer_members')
        .select('dealers(name, city, state)')
        .eq('user_id', session.user.id).maybeSingle()
        .then(function (r) {
          var line = document.getElementById('portal-dealer');
          if (!line || !r.data || !r.data.dealers) return;
          var d = r.data.dealers;
          line.textContent = d.name + (d.city ? ', ' + d.city + ', ' + d.state : '');
        });

      var signout = document.getElementById('portal-signout');
      if (signout) {
        signout.addEventListener('click', function () {
          client.auth.signOut().then(function () { window.location.href = 'dealer-login.html'; });
        });
      }

      var bucket = cfg.DOCS_BUCKET || 'dealer-docs';
      client.storage.from(bucket).list('', { limit: 100, sortBy: { column: 'name', order: 'asc' } })
        .then(function (res2) {
          var listEl = document.getElementById('portal-doclist');
          if (res2.error) {
            docsRoot.querySelector('.portal-loading').textContent =
              'Could not load documents (' + res2.error.message + '). Call the office at (662) 728-7975.';
            return;
          }
          var files = (res2.data || []).filter(function (f) { return f.id !== null; });
          docsRoot.querySelector('.portal-loading').style.display = 'none';
          if (!files.length) {
            listEl.innerHTML = '<li class="portal-empty">No documents posted yet. The current price list is on its way; call the office if you need it today.</li>';
            return;
          }
          files.forEach(function (f) {
            client.storage.from(bucket).createSignedUrl(f.name, 3600).then(function (res3) {
              if (res3.error) return;
              var li = document.createElement('li');
              var kb = f.metadata && f.metadata.size ? Math.max(1, Math.round(f.metadata.size / 1024)) + ' KB' : '';
              var updated = f.updated_at ? new Date(f.updated_at).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) : '';
              li.innerHTML = '<a class="doclink" href="' + res3.data.signedUrl + '" target="_blank" rel="noopener">' +
                '<span class="doclink__name">' + f.name.replace(/&/g, '&amp;').replace(/</g, '&lt;') + '</span>' +
                '<span class="doclink__meta">' + [updated, kb].filter(Boolean).join(' &middot; ') + '</span>' +
                '</a>';
              listEl.appendChild(li);
            });
          });
        });
    });
  }
})();
