// The keeper. It sits between the world and the line, and is not on any page.
//
// While the line is up it does nothing but watch: everything asked for is fetched fresh,
// as before, and a copy of whatever comes back is put in a drawer. When the line is down
// it opens the drawer. What comes out is the world as it was when last seen, which is the
// only world anyone has ever been shown.
//
// It never prefers the drawer. A world that is added to by the hour should not be
// remembered in place of being looked at.

var DRAWER = 'drawer';

// What a visitor is given to begin with, so that a first visit is enough to keep the world by.
var KEPT = ['./', 'forecast.html', 'phrasebook.html', 'ashore.html', 'customs.html', 'below.html',
            'exam.html', 'search.html', 'departures.html', 'shanty.html', 'sky.svg', 'kit.svg',
            'pattern.txt', 'almanac.ics', 'voyage.gpx', 'world.sh', 'icon.svg', 'pocket.webmanifest'];

self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(DRAWER).then(function (drawer) {
    // One at a time, and a missing one is not a disaster; the rest are still worth having.
    return Promise.all(KEPT.map(function (what) {
      return drawer.add(what).catch(function () {});
    }));
  }).then(function () { return self.skipWaiting(); }));
});

self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (names) {
    return Promise.all(names.map(function (name) {
      if (name !== DRAWER) return caches.delete(name);
    }));
  }).then(function () { return self.clients.claim(); }));
});

self.addEventListener('fetch', function (e) {
  var req = e.request;
  if (req.method !== 'GET') return;
  var url = new URL(req.url);
  if (url.origin !== self.location.origin) return;   // Elsewhere is not kept.

  e.respondWith(fetch(req).then(function (res) {
    // Only what was really there goes in the drawer. The edge of the world is not worth remembering.
    if (res && res.ok && res.type === 'basic') {
      var copy = res.clone();
      caches.open(DRAWER).then(function (drawer) { drawer.put(req, copy); });
    }
    return res;
  }).catch(function () {
    return caches.match(req, { ignoreSearch: true }).then(function (kept) {
      if (kept) return kept;
      // Asked, with the line down, for a page that was never seen: the world itself will have to do.
      if (req.mode === 'navigate') return caches.match('./');
      return Response.error();
    });
  }));
});
