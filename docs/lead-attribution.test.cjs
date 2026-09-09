const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const attribution = require('../js/lead-attribution.js');
function environment(pathname='/6x12-vs-7x16-enclosed-trailer.html', storage=new Map(), now=1000) {
  return {location:{pathname,hostname:'triplertrailers.com',search:''},document:{referrer:'https://www.google.com/search?q=private'},Date:{now:()=>now},sessionStorage:{getItem:k=>storage.get(k)||null,setItem:(k,v)=>storage.set(k,v)}};
}
test('article landing survives navigation to a quote; full referrer and queries are not retained',()=>{
  const store=new Map(), env=environment(undefined,store);
  env.location.search='?utm_source=newsletter&utm_medium=email&utm_campaign=fall-2026&email=private@example.com';
  attribution(env);
  const next=environment('/contact.html',store);next.document.referrer='https://triplertrailers.com/6x12-vs-7x16-enclosed-trailer.html';
  assert.deepEqual(attribution(next).getFields(),{'Website landing page':'/6x12-vs-7x16-enclosed-trailer.html','Website referrer host':'www.google.com','Website campaign source':'newsletter','Website campaign medium':'email','Website campaign':'fall-2026'});
  assert(!JSON.stringify([...store.values()]).includes('private'));
});
test('expired and malformed storage are replaced; unavailable storage does not break forms',()=>{
  const store=new Map();attribution(environment(undefined,store));
  assert.equal(attribution(environment('/contact.html',store,2000000)).getFields()['Website landing page'],'/contact.html');
  store.set('trr_inquiry_source_v1','not json');assert.equal(attribution(environment('/contact.html',store)).getFields()['Website landing page'],'/contact.html');
  const env=environment();env.sessionStorage={getItem(){throw Error('blocked');},setItem(){throw Error('blocked');}};
  assert.equal(attribution(env).getFields()['Website landing page'],env.location.pathname);
});
test('portal paths, unknown routes and unsafe campaign tokens are excluded',()=>{
  assert.deepEqual(attribution(environment('/dealer-set-password.html')).getFields(),{});
  assert.deepEqual(attribution(environment('/customer/jane')).getFields(),{});
  const env=environment();env.location.search='?utm_campaign=private%40example.com';
  assert.equal(attribution(env).getFields()['Website campaign'],undefined);
});
test('a form left open past the attribution window stops using the old entry',()=>{
  const env=environment();let now=1000;env.Date.now=()=>now;
  const context=attribution(env);now+=30*60*1000;
  assert.deepEqual(context.getFields(),{});
});
function formHarness({body={ok:true},status=true,trap='',configured=true,reject=false}={}) {
  const events=[],payloads=[],docHandlers={};let handler;
  const stub={classList:{toggle(){},add(){},remove(){}},addEventListener(){},setAttribute(){},querySelectorAll(){return [];}};
  const note={style:{},textContent:''},button={textContent:'Send'}, form={
    elements:[{name:'Name',value:'Test Person'},{name:'Email',value:'test@example.test'},{name:'trr_hp',value:trap}],
    addEventListener(type,fn){handler=fn;},getAttribute(){return 'Quote Request';},
    querySelector(s){return s==='button[type=submit]'?button:note;},reset(){this.resetCalled=true;}
  };
  const document={getElementById:id=>['header','burger','drawer'].includes(id)?stub:null,querySelector:()=>null,querySelectorAll:s=>s==='form[data-mailform]'?[form]:[],addEventListener:(t,f)=>{docHandlers[t]=f;}};
  const window={matchMedia:()=>({matches:true}),addEventListener(){},location:{pathname:'/contact.html',href:''},scrollY:0,gtag:(...args)=>events.push(args),TRIPLE_R_ATTRIBUTION:{getFields:()=>({'Website landing page':'/6x12-vs-7x16-enclosed-trailer.html'})},TRIPLE_R_PORTAL:configured?{SUPABASE_URL:'https://test.invalid',SUPABASE_ANON_KEY:'test-key'}:{}};
  const context={window,document,setTimeout:()=>1,clearTimeout(){},fetch:async(url,options)=>{payloads.push(JSON.parse(options.body));if(reject)throw Error('offline');return {ok:status,json:async()=>body};}};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../js/main.js'),'utf8'),context);
  return {events,payloads,note,button,form,window,docHandlers,async submit(){handler({preventDefault(){}});await new Promise(resolve=>setImmediate(resolve));}};
}
test('confirmed submission preserves acquisition in office payload and counts one lead without personal Analytics fields',async()=>{
  const h=formHarness();await h.submit();assert.equal(h.payloads[0].payload.fields['Website landing page'],'/6x12-vs-7x16-enclosed-trailer.html');
  assert.equal(h.events.filter(e=>e[1]==='generate_lead').length,1);assert(h.form.resetCalled);assert(!JSON.stringify(h.events).includes('test@example'));
});
test('duplicates and honeypot acknowledgements are not counted as fresh leads',async()=>{
  for(const opts of [{body:{ok:true,duplicate:true}},{trap:'bot'}]){const h=formHarness(opts);await h.submit();assert(!h.events.some(e=>e[1]==='generate_lead'));}
});
test('network failures, invalid acknowledgements and missing configuration use the existing email fallback with acquisition context',async()=>{
  for(const opts of [{reject:true},{body:{}},{configured:false}]){const h=formHarness(opts);await h.submit();assert(h.window.location.href.startsWith('mailto:'));assert(decodeURIComponent(h.window.location.href).includes('Website landing page'));assert(!h.events.some(e=>e[1]==='generate_lead'));}
});
test('server validation stays on the form and dealer phone clicks retain the destination ID',async()=>{
  const h=formHarness({status:false,body:{code:'P0001',message:'Please leave a phone number.'}});await h.submit();assert.equal(h.note.textContent,'Please leave a phone number.');assert.equal(h.window.location.href,'');assert.equal(h.button.disabled,false);
  const link={getAttribute:key=>({'href':'tel:+19014908205','data-dealer-id':'vista-trailers-llc'})[key],closest:()=>null};
  h.docHandlers.click({target:{closest:()=>link}});assert.equal(h.events[0][2].dealer_id,'vista-trailers-llc');
});
