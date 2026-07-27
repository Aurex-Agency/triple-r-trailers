/* Triple R Trailers */
(function () {
  'use strict';

  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

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

  /* ---------- Hero ghost parallax ---------- */
  var ghost = document.querySelector('.hero__ghost');
  if (ghost && !reducedMotion) {
    var ticking = false;
    window.addEventListener('scroll', function () {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function () {
        var y = window.scrollY;
        if (y < window.innerHeight * 1.4) {
          ghost.style.transform = 'translateY(' + y * 0.18 + 'px)';
        }
        ticking = false;
      });
    }, { passive: true });
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

  /* ---------- Footer year ---------- */
  var yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());
})();
