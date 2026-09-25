/* Triple R Trailers */
(function () {
  'use strict';

  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var refreshScrollFx = null;

  /* ---------- Header scroll state ---------- */
  var header = document.getElementById('header');
  var lastScrolled = false;
  function onScrollHeader() {
    var scrolled = window.scrollY > 24;
    if (scrolled !== lastScrolled) {
      header.classList.toggle('scrolled', scrolled);
      lastScrolled = scrolled;
    }
  }
  window.addEventListener('scroll', onScrollHeader, { passive: true });
  onScrollHeader();

  /* ---------- Mobile drawer ---------- */
  var burger = document.getElementById('burger');
  var drawer = document.getElementById('drawer');

  function setDrawer(open) {
    burger.classList.toggle('open', open);
    drawer.classList.toggle('open', open);
    document.body.classList.toggle('no-scroll', open);
    burger.setAttribute('aria-expanded', String(open));
    burger.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    drawer.setAttribute('aria-hidden', String(!open));
  }
  burger.addEventListener('click', function () {
    setDrawer(!drawer.classList.contains('open'));
  });
  drawer.addEventListener('click', function (e) {
    if (e.target.closest('a')) setDrawer(false);
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && drawer.classList.contains('open')) setDrawer(false);
  });

  /* ---------- Counters ---------- */
  function formatNum(n, plain) {
    if (plain) return String(n);
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }
  function runCounter(el) {
    var target = parseInt(el.getAttribute('data-count'), 10);
    var start = parseInt(el.getAttribute('data-start') || '0', 10);
    var plain = el.hasAttribute('data-plain');
    if (reducedMotion) { el.textContent = formatNum(target, plain); return; }
    var duration = 1400;
    var t0 = null;
    function step(t) {
      if (!t0) t0 = t;
      var p = Math.min((t - t0) / duration, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = formatNum(Math.round(start + (target - start) * eased), plain);
      if (p < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }

  /* ---------- Reveal observer ---------- */
  var revealTargets = document.querySelectorAll('.rev, .line, .stamp, .draw');
  if ('IntersectionObserver' in window && !reducedMotion) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var el = entry.target;
        if (el.classList.contains('draw')) {
          el.classList.add('drawn');
        } else {
          el.classList.add('in');
          el.querySelectorAll('[data-count]').forEach(function (c) {
            if (!c.hasAttribute('data-counted')) {
              c.setAttribute('data-counted', '');
              runCounter(c);
            }
          });
        }
        io.unobserve(el);
      });
    }, { threshold: 0.18, rootMargin: '0px 0px -6% 0px' });
    revealTargets.forEach(function (el) { io.observe(el); });
  } else {
    revealTargets.forEach(function (el) {
      el.classList.add(el.classList.contains('draw') ? 'drawn' : 'in');
    });
    document.querySelectorAll('[data-count]').forEach(function (c) {
      c.textContent = formatNum(parseInt(c.getAttribute('data-count'), 10), c.hasAttribute('data-plain'));
    });
  }

  /* ---------- Scroll effects: ghost type + photo parallax ---------- */
  var ghost = document.querySelector('.hero__ghost');
  var plxEls = Array.prototype.slice.call(document.querySelectorAll('[data-plx]'));
  if (!reducedMotion && (ghost || plxEls.length)) {
    var fxTicking = false;
    var applyScrollFx = function () {
      var y = window.scrollY;
      var vh = window.innerHeight;
      if (ghost && y < vh * 1.4) {
        ghost.style.transform = 'translateY(' + y * 0.18 + 'px)';
      }
      plxEls.forEach(function (el) {
        var host = el.parentElement;
        var r = host.getBoundingClientRect();
        if (r.bottom < -vh || r.top > vh * 2) return;
        var mid = r.top + r.height / 2 - vh / 2;
        var f = parseFloat(el.getAttribute('data-plx')) || 0.05;
        var s = el.getAttribute('data-plx-scale') || '1.12';
        var shift = -mid * f;
        // The scale is what buys the photo room to move inside an
        // overflow:hidden box. Past that room the edge of the photo comes
        // back inside the box and the panel behind it shows as a hard line
        // along the top or bottom of the picture. It is worst as a tile
        // enters the viewport, which is exactly when .rev reveals it, so it
        // reads as the photo animating in with a seam down it.
        //
        // Short boxes have the least room and the same travel, so a 4:3
        // gallery tile runs out well before a 3:4 one does. Clamp to what
        // the scale actually paid for and the seam cannot happen at any
        // viewport height. The clamp only engages when the tile is already
        // at the very edge of the screen, where the parallax is not doing
        // visible work anyway.
        var room = r.height * (parseFloat(s) - 1) / 2;
        if (shift > room) shift = room;
        else if (shift < -room) shift = -room;
        el.style.transform = 'translate3d(0,' + shift.toFixed(1) + 'px,0)' + (s === '1' ? '' : ' scale(' + s + ')');
      });
      fxTicking = false;
    };
    refreshScrollFx = applyScrollFx;
    window.addEventListener('scroll', function () {
      if (!fxTicking) { fxTicking = true; requestAnimationFrame(applyScrollFx); }
    }, { passive: true });
    window.addEventListener('resize', function () { requestAnimationFrame(applyScrollFx); }, { passive: true });
    applyScrollFx();
  }

  /* ---------- Featured tabs ---------- */
  var tablist = document.querySelector('.tabs');
  if (tablist) {
    var tabs = Array.prototype.slice.call(tablist.querySelectorAll('.tab'));

    function activateTab(tab, focus) {
      tabs.forEach(function (t) {
        var active = t === tab;
        t.classList.toggle('is-active', active);
        t.setAttribute('aria-selected', String(active));
        t.tabIndex = active ? 0 : -1;
        var panel = document.getElementById(t.getAttribute('aria-controls'));
        if (panel) {
          panel.classList.toggle('is-active', active);
          if (active) {
            panel.removeAttribute('hidden');
            /* position parallax photos before first paint so nothing jumps */
            if (refreshScrollFx) refreshScrollFx();
            /* replay the line-art draw */
            var art = panel.querySelector('.draw');
            if (art && !reducedMotion) {
              art.classList.remove('drawn');
              void art.getBoundingClientRect();
              art.classList.add('drawn');
            }
          } else {
            panel.setAttribute('hidden', '');
          }
        }
      });
      if (focus) tab.focus();
    }

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () { activateTab(tab, false); });
    });
    tablist.addEventListener('keydown', function (e) {
      var i = tabs.indexOf(document.activeElement);
      if (i === -1) return;
      var next = null;
      if (e.key === 'ArrowRight') next = tabs[(i + 1) % tabs.length];
      if (e.key === 'ArrowLeft') next = tabs[(i - 1 + tabs.length) % tabs.length];
      if (e.key === 'Home') next = tabs[0];
      if (e.key === 'End') next = tabs[tabs.length - 1];
      if (next) { e.preventDefault(); activateTab(next, true); }
    });
  }

  /* ---------- Soft fade-in for lazy-loaded photos ---------- */
  Array.prototype.forEach.call(document.querySelectorAll('.blend img'), function (img) {
    if (img.complete) return;
    img.style.opacity = '0';
    img.addEventListener('load', function () {
      img.style.transition = 'opacity 0.6s ease';
      img.style.opacity = '1';
    }, { once: true });
  });

  /* ---------- Public forms ----------
     These used to open the visitor's email app and wait for them to press send
     themselves, which on a phone with no mail app set up did nothing at all
     and lost the lead without anybody knowing. Now the submission goes to the
     factory directly. If that call cannot be made, for any reason, the old
     mail app route is still there as a fallback, so a lead is never dropped on
     the floor. */
  var LEAD_CFG = window.TRIPLE_R_PORTAL || {};
  var LEAD_READY = LEAD_CFG.SUPABASE_URL && LEAD_CFG.SUPABASE_URL.indexOf('http') === 0 &&
    LEAD_CFG.SUPABASE_ANON_KEY && LEAD_CFG.SUPABASE_ANON_KEY.indexOf('PASTE') !== 0;

  /* Keep lead measurement small and free of personal information. GA4 is
     loaded in the page head; this guard keeps the site working if a visitor
     blocks Analytics. */
  function trackEvent(name, params) {
    if (typeof window.gtag === 'function') window.gtag('event', name, params || {});
  }

  document.addEventListener('click', function (e) {
    var link = e.target.closest ? e.target.closest('a[href]') : null;
    if (!link) return;
    var href = link.getAttribute('href') || '';
    var context = link.closest('header, footer, .drawer, .pagehero, .bandcta');
    var location = context ? (context.className || context.tagName).toString() : 'page';
    var params = { link_location: location, page_path: window.location.pathname };
    var dealerId = link.getAttribute('data-dealer-id');
    if (dealerId && /^[a-z0-9-]{1,100}$/.test(dealerId)) params.dealer_id = dealerId;
    if (href.indexOf('tel:') === 0) {
      params.contact_role = dealerId ? 'dealer' : 'factory';
      trackEvent('phone_click', params);
    } else if (href.indexOf('mailto:') === 0) {
      trackEvent('email_click', { link_location: location, page_path: window.location.pathname });
    } else if (href.indexOf('find-a-dealer.html') !== -1) {
      trackEvent('dealer_finder_click', { link_location: location, page_path: window.location.pathname });
    } else if (dealerId && href.indexOf('https://www.google.com/maps/') === 0) {
      trackEvent('dealer_map_click', params);
    } else if (dealerId && href.indexOf('https://') === 0) {
      trackEvent('dealer_website_click', params);
    } else if (/^(?:\/)?contact\.html(?:[?#]|$)/.test(href)) {
      trackEvent('quote_cta_click', params);
    }
  });

  function attributionFields() {
    return window.TRIPLE_R_ATTRIBUTION ? window.TRIPLE_R_ATTRIBUTION.getFields() : {};
  }

  function mailFallback(form, subject) {
    var lines = [];
    Array.prototype.forEach.call(form.elements, function (el) {
      if (el.name && el.value && el.name !== 'trr_hp') {
        lines.push(el.name + ': ' + el.value);
      }
    });
    var sourceFields = attributionFields();
    Object.keys(sourceFields).forEach(function (key) { lines.push(key + ': ' + sourceFields[key]); });
    trackEvent('lead_fallback_opened', {
      lead_type: subject,
      page_path: window.location.pathname
    });
    window.location.href = 'mailto:triplertrailers@gmail.com' +
      '?subject=' + encodeURIComponent(subject + ' from triplertrailers.com') +
      '&body=' + encodeURIComponent(lines.join('\n'));
  }

  function formNote(form) {
    var note = form.querySelector('.form__note');
    if (!note) {
      note = document.createElement('p');
      note.className = 'form__note';
      form.appendChild(note);
    }
    return note;
  }

  Array.prototype.forEach.call(document.querySelectorAll('form[data-mailform]'), function (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var subject = form.getAttribute('data-mailform');

      if (!LEAD_READY) { mailFallback(form, subject); return; }

      var fields = {};
      var trap = '';
      Array.prototype.forEach.call(form.elements, function (el) {
        if (!el.name || !el.value) return;
        if (el.name === 'trr_hp') { trap = el.value; return; }
        fields[el.name] = el.value;
      });
      // Kept in the existing lead JSON and office email, never sent to GA4.
      Object.assign(fields, attributionFields());

      var btn = form.querySelector('button[type=submit]');
      var note = formNote(form);
      var oldLabel = btn ? btn.textContent : '';
      if (btn) { btn.disabled = true; btn.textContent = 'Sending...'; }
      note.textContent = '';
      note.style.color = '';

      var done = false;
      /* Never leave somebody staring at a spinner. If the network hangs, hand
         them the mail app rather than nothing. */
      var giveUp = setTimeout(function () {
        if (done) return;
        done = true;
        if (btn) { btn.disabled = false; btn.textContent = oldLabel; }
        mailFallback(form, subject);
      }, 12000);

      fetch(LEAD_CFG.SUPABASE_URL + '/rest/v1/rpc/submit_lead', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          apikey: LEAD_CFG.SUPABASE_ANON_KEY,
          Authorization: 'Bearer ' + LEAD_CFG.SUPABASE_ANON_KEY
        },
        body: JSON.stringify({
          payload: {
            kind: subject,
            page: window.location.pathname.replace(/^\//, ''),
            trr_hp: trap,
            fields: fields
          }
        })
      }).then(function (res) {
        return res.json().then(function (body) { return { ok: res.ok, body: body }; });
      }).then(function (r) {
        if (done) return;
        done = true;
        clearTimeout(giveUp);
        if (btn) { btn.disabled = false; btn.textContent = oldLabel; }

        if (!r.ok || !r.body || r.body.ok !== true) {
          /* P0001 is our own message, written for the visitor, so show it.
             Anything else is the database or the connection having a problem,
             and a visitor should never be shown that. Hand them the mail app
             instead, which is the whole reason the fallback exists. */
          if (r.body && r.body.code === 'P0001' && r.body.message) {
            note.textContent = r.body.message;
            note.style.color = 'var(--red-bright)';
          } else {
            mailFallback(form, subject);
          }
          return;
        }
        form.reset();
        // The server deliberately acknowledges duplicates and trapped bots.
        // Neither is a second qualified inquiry in Analytics.
        if (!trap && !r.body.duplicate) {
          var leadParams = {
            lead_type: subject,
            page_path: window.location.pathname
          };
          // Product selection is an allowlisted category, never customer text.
          var product = fields['Trailer type'];
          if (['Utility', 'Enclosed cargo', 'Dump', 'Car hauler', 'Equipment', 'Gooseneck', 'Custom build', 'Parts or service'].indexOf(product) !== -1) {
            leadParams.trailer_type = product;
          }
          trackEvent('generate_lead', leadParams);
        }
        note.textContent = r.body.duplicate ?
          'We already received that request. Need to add something? Call (662) 728-7975.' :
          'Your request has been saved for the office in Booneville. Need it sooner? Call (662) 728-7975.';
        note.style.color = 'var(--bone)';
      }).catch(function () {
        if (done) return;
        done = true;
        clearTimeout(giveUp);
        if (btn) { btn.disabled = false; btn.textContent = oldLabel; }
        mailFallback(form, subject);
      });
    });
  });


  /* ---------- Yard clips ----------
     Muted phone footage, so nothing here needs sound and none of the files
     carry an audio track. A clip only starts once it is actually on screen
     and only after the browser has been told to fetch it, which is why the
     markup ships preload="none" and no src until this runs.

     Under prefers-reduced-motion nothing starts on its own. The poster stays
     and the visitor gets a button, because a looping video is motion whether
     or not we call it decoration. */
  var clips = [].slice.call(document.querySelectorAll('[data-clip]'));
  if (clips.length) {
    var loadClip = function (video) {
      if (video.dataset.loaded) return;
      video.dataset.loaded = '1';
      [].slice.call(video.querySelectorAll('source[data-src]')).forEach(function (src) {
        src.src = src.dataset.src;
      });
      video.load();
    };

    var play = function (fig) {
      var video = fig.querySelector('video');
      if (!video) return;
      loadClip(video);
      var started = video.play();
      if (started && started.catch) {
        // Autoplay can still be refused (Low Power Mode, for one). Fall back
        // to the button rather than leaving a frozen poster and no way in.
        started.catch(function () { fig.classList.add('is-manual'); });
      }
      fig.classList.add('is-playing');
    };

    clips.forEach(function (fig) {
      var btn = fig.querySelector('.clip__play');
      if (btn) {
        btn.addEventListener('click', function () {
          fig.classList.remove('is-manual');
          play(fig);
        });
      }
      if (reducedMotion) { fig.classList.add('is-manual'); }
    });

    if (!reducedMotion && 'IntersectionObserver' in window) {
      var clipIo = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          var fig = entry.target;
          var video = fig.querySelector('video');
          if (!video) return;
          if (entry.isIntersecting) {
            play(fig);
          } else if (fig.classList.contains('is-playing')) {
            // Off screen is wasted decode work and wasted battery.
            video.pause();
            fig.classList.remove('is-playing');
          }
        });
      }, { rootMargin: '100px 0px', threshold: 0.25 });
      clips.forEach(function (fig) { clipIo.observe(fig); });
    } else if (!reducedMotion) {
      clips.forEach(play);
    }
  }

  /* ---------- Footer year ---------- */
  var yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());
})();
