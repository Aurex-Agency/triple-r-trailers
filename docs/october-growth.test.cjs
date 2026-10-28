const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const attribution = require('../js/lead-attribution.js');
const routes = require('./october-growth-routes.json');
test('new guide entries survive navigation to the quote without retaining queries', () => {
  for (const route of routes) {
    const storage = new Map();
    const env = {location:{pathname:'/'+route,hostname:'triplertrailers.com',search:'?email=private@example.test'},document:{referrer:'https://www.google.com/search?q=private'},Date:{now:()=>1000},sessionStorage:{getItem:k=>storage.get(k)||null,setItem:(k,v)=>storage.set(k,v)}};
    attribution(env);
    env.location.pathname='/contact.html';env.document.referrer='https://triplertrailers.com/'+route;
    assert.equal(attribution(env).getFields()['Website landing page'],'/'+route);
    assert(!JSON.stringify([...storage.values()]).includes('private'));
  }
});
test('map markers identify the dealer to keyboard and screen reader users; counts exclude the factory', () => {
  const markers=[];
  const count={textContent:''};
  const document={getElementById:id=>id==='dealermap'?{}:id==='dmap-count'?count:null};
  const data={window:{}};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../js/dealers.js'),'utf8'),data);
  const map={setView(){return this;},on(){},scrollWheelZoom:{enable(){}}};
  const L={map:()=>map,tileLayer:()=>({addTo(){}}),divIcon:x=>x,marker:(coords,opts)=>{
    const attrs={};const marker={addTo(){return this;},getElement:()=>({setAttribute:(k,v)=>attrs[k]=v}),bindPopup(){}};
    markers.push({attrs,opts});return marker;
  }};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../js/dealer-map.js'),'utf8'),{document,L,window:data.window,navigator:{}});
  assert.equal(markers.length,49);
  assert(markers.every(m=>m.attrs['aria-label']===m.opts.title && m.attrs['aria-label'].length>5));
  assert.match(count.textContent,/48 of 57 listed dealers mapped, plus the Booneville factory/);
  assert.match(count.textContent,/approximate town locations/);
});
