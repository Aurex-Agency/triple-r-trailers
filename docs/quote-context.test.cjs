const {test} = require('node:test');
const assert = require('node:assert/strict');
const prefill = require('../js/quote-context.js');
test('a product quote link preselects only a valid product', () => {
  for (const product of ['Dump','Utility','Enclosed cargo']) {
    const select = {value:''};
    prefill({getElementById:()=>select}, '?trailer='+encodeURIComponent(product));
    assert.equal(select.value, product);
  }
});
test('untrusted query text and unavailable fields have no effect', () => {
  for (const query of ['?trailer=private@example.com','?trailer=%3Cscript%3E','?trailer=Unknown','']) {
    const select={value:''}; prefill({getElementById:()=>select},query); assert.equal(select.value,'');
  }
  assert.doesNotThrow(()=>prefill({getElementById:()=>null},'?trailer=Dump'));
});
test('prefill preserves a visitor selection restored by the browser', () => {
  const select={value:'Equipment'};prefill({getElementById:()=>select},'?trailer=Dump');assert.equal(select.value,'Equipment');
});
