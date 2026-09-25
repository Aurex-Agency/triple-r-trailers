/* Only approved product names may prefill the quote. No free-text URL data. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory;
  else factory(root.document, root.location.search);
})(typeof window !== 'undefined' ? window : this, function (document, search) {
  'use strict';
  var select = document.getElementById('ct-type');
  if (!select || select.value) return;
  var requested = new URLSearchParams(search || '').get('trailer');
  var allowed = ['Utility', 'Enclosed cargo', 'Dump', 'Car hauler', 'Equipment', 'Gooseneck', 'Custom build', 'Parts or service'];
  if (allowed.indexOf(requested) !== -1) select.value = requested;
});
