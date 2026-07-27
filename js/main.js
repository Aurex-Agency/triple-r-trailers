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
        el.style.transform = 'translateY(' + (-mid * f).toFixed(1) + 'px)' + (s === '1' ? '' : ' scale(' + s + ')');
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

  /* ---------- Footer year ---------- */
  var yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());
})();
