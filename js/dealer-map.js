/* Triple R Trailers dealer map */
(function () {
  'use strict';

  var mapEl = document.getElementById('dealermap');
  if (!mapEl || typeof L === 'undefined') return;

  var FACTORY = [34.6579, -88.5667];
  var dealers = window.TRIPLE_R_DEALERS || [];
  var pinned = dealers.filter(function (d) { return d.lat != null && d.lng != null; });

  var map = L.map(mapEl, { scrollWheelZoom: false }).setView([34.9, -88.9], 6);
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);
  map.on('focus click', function () { map.scrollWheelZoom.enable(); });

  function icon(isFactory) {
    return L.divIcon({
      className: 'dpin-wrap',
      html: '<span class="dpin' + (isFactory ? ' dpin--factory' : '') + '">R</span>',
      iconSize: [34, 40],
      iconAnchor: [17, 38],
      popupAnchor: [0, -36]
    });
  }

  var markers = [];
  pinned.forEach(function (d) {
    var m = L.marker([d.lat, d.lng], { icon: icon(!!d.factory) }).addTo(map);
    var lines = ['<strong>' + d.name + '</strong>'];
    if (d.city) lines.push(d.city + (d.state ? ', ' + d.state : ''));
    if (d.phone) lines.push('<a href="tel:+1' + d.phone.replace(/\D/g, '') + '">' + d.phone + '</a>');
    lines.push('<a target="_blank" rel="noopener" href="https://www.google.com/maps/dir/?api=1&destination=' + d.lat + ',' + d.lng + '">Directions</a>');
    m.bindPopup(lines.join('<br>'));
    markers.push({ data: d, marker: m });
  });

  /* ---------- Nearest list panel ---------- */
  var listEl = document.getElementById('dmap-list');
  var countEl = document.getElementById('dmap-count');
  if (countEl) {
    countEl.textContent = pinned.length + ' of ' + dealers.length + ' locations pinned so far. More added as dealers confirm their details.';
  }

  function dist(a, b, c, d) {
    var toRad = function (x) { return x * Math.PI / 180; };
    var R = 3959;
    var dLat = toRad(c - a), dLng = toRad(d - b);
    var h = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(toRad(a)) * Math.cos(toRad(c)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return R * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
  }

  function renderList(from) {
    if (!listEl) return;
    var rows = markers.map(function (m) {
      return { m: m, miles: from ? dist(from[0], from[1], m.data.lat, m.data.lng) : null };
    });
    if (from) rows.sort(function (a, b) { return a.miles - b.miles; });
    listEl.innerHTML = '';
    rows.forEach(function (r) {
      var li = document.createElement('li');
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'dmap-item';
      var meta = [r.m.data.city && r.m.data.state ? r.m.data.city + ', ' + r.m.data.state : '',
                  r.miles != null ? Math.round(r.miles) + ' mi' : ''].filter(Boolean).join(' &middot; ');
      btn.innerHTML = '<span class="dmap-item__name">' + r.m.data.name + '</span>' +
        (meta ? '<span class="dmap-item__meta">' + meta + '</span>' : '');
      btn.addEventListener('click', function () {
        map.setView(r.m.marker.getLatLng(), 10);
        r.m.marker.openPopup();
      });
      li.appendChild(btn);
      listEl.appendChild(li);
    });
  }
  renderList(null);

  /* ---------- Search by city or zip ---------- */
  var form = document.getElementById('dmap-search');
  var input = document.getElementById('dmap-q');
  var status = document.getElementById('dmap-status');

  function setStatus(msg) { if (status) status.textContent = msg || ''; }

  function goTo(lat, lng, label) {
    map.setView([lat, lng], 8);
    renderList([lat, lng]);
    setStatus(label ? 'Showing dealers nearest ' + label : '');
  }

  if (form && input) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var q = input.value.trim();
      if (!q) return;
      setStatus('Searching...');
      fetch('https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=us&q=' + encodeURIComponent(q))
        .then(function (r) { return r.json(); })
        .then(function (res) {
          if (res && res.length) {
            goTo(parseFloat(res[0].lat), parseFloat(res[0].lon), q);
          } else {
            setStatus('Could not find that spot. Try a city and state, or call (662) 728-7975.');
          }
        })
        .catch(function () {
          setStatus('Search is unavailable right now. Call (662) 728-7975 and we will point you to your dealer.');
        });
    });
  }

  var locateBtn = document.getElementById('dmap-locate');
  if (locateBtn && 'geolocation' in navigator) {
    locateBtn.addEventListener('click', function () {
      setStatus('Finding you...');
      navigator.geolocation.getCurrentPosition(function (pos) {
        goTo(pos.coords.latitude, pos.coords.longitude, 'your location');
      }, function () {
        setStatus('Could not get your location. Type your city or zip instead.');
      });
    });
  } else if (locateBtn) {
    locateBtn.style.display = 'none';
  }
})();
