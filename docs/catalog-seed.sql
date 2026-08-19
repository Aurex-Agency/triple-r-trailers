-- Triple R Trailers dealer catalog seed.
-- Generated from the office price lists. Re-run any time to replace the catalog.
-- DEALER NET PRICING. This file is excluded from the deployed site (.vercelignore).
-- Run docs/supabase-orders.sql first; that creates the tables this fills.

begin;

delete from catalog_line_options;
delete from catalog_options;
delete from catalog_models;
delete from catalog_lines;
delete from catalog_categories;

-- Categories -------------------------------------------------------------
insert into catalog_categories (slug, name, page, sort) values ('utility', 'Utility Trailers', 'utility-trailers.html', 10);
insert into catalog_categories (slug, name, page, sort) values ('enclosed', 'Enclosed Cargo', 'enclosed-cargo-trailers.html', 20);
insert into catalog_categories (slug, name, page, sort) values ('dump', 'Dump Trailers', 'dump-trailers.html', 30);
insert into catalog_categories (slug, name, page, sort) values ('car-hauler', 'Car Haulers', 'car-hauler-trailers.html', 40);
insert into catalog_categories (slug, name, page, sort) values ('equipment', 'Equipment Trailers', 'equipment-trailers.html', 50);
insert into catalog_categories (slug, name, page, sort) values ('gooseneck', 'Gooseneck', 'gooseneck-trailers.html', 60);

-- Product lines ----------------------------------------------------------
insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-single-aframe', 'utility', 'Single Axle A-Frame Utility', 'The everyday 3500 lb single axle. Pick your top rail material.',
   array['3500 lb single axle', 'A-frame tongue', 'Expanded metal or wood floors', '15 inch new wheels and tires'], '[{"key": "angle", "label": "Angle Top Rail"}, {"key": "sqtube", "label": "Square Tube Top Rail"}, {"key": "pipe", "label": "Pipe Top Rail"}]'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x8-a-frame', 'u-single-aframe', '5X8 A-Frame', '5x8', 8, '{"angle": 1273, "sqtube": 1329, "pipe": 1315}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x8-a-frame-w-4ft-gate', 'u-single-aframe', '5X8 A-Frame w/ 4ft Gate', '5x8', 8, '{"angle": 1400, "sqtube": 1451, "pipe": 1439}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x10-a-frame', 'u-single-aframe', '5X10 A-Frame', '5x10', 10, '{"angle": 1332, "sqtube": 1394, "pipe": 1416}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x10-a-frame-w-4ft-gate', 'u-single-aframe', '5X10 A-Frame w/ 4ft Gate', '5x10', 10, '{"angle": 1458, "sqtube": 1515, "pipe": 1536}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x12-a-frame', 'u-single-aframe', '5X12 A-Frame', '5x12', 12, '{"angle": 1356, "sqtube": 1418, "pipe": 1428}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x12-a-frame-w-4ft-gate', 'u-single-aframe', '5X12 A-Frame w/ 4ft Gate', '5x12', 12, '{"angle": 1483, "sqtube": 1540, "pipe": 1550}'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--5x14-a-frame-w-4ft-gate', 'u-single-aframe', '5X14 A-Frame w/ 4ft Gate', '5x14', 14, '{"angle": 1545, "sqtube": 1607, "pipe": 1619}'::jsonb, 60);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6x10-a-frame', 'u-single-aframe', '6X10 A-Frame', '6x10', 10, '{"angle": 1375, "sqtube": 1433, "pipe": 1443}'::jsonb, 70);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6x10-a-frame-w-4ft-gate', 'u-single-aframe', '6X10 A-Frame w/ 4ft Gate', '6x10', 10, '{"angle": 1532, "sqtube": 1585, "pipe": 1595}'::jsonb, 80);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6x12-a-frame', 'u-single-aframe', '6X12 A-Frame', '6x12', 12, '{"angle": 1437, "sqtube": 1506, "pipe": 1512}'::jsonb, 90);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6x12-a-frame-w-4ft-gate', 'u-single-aframe', '6X12 A-Frame w/ 4ft Gate', '6x12', 12, '{"angle": 1595, "sqtube": 1658, "pipe": 1663}'::jsonb, 100);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6x14-a-frame-w-4ft-gate', 'u-single-aframe', '6X14 A-Frame w/ 4ft Gate', '6x14', 14, '{"angle": 1647, "sqtube": 1712, "pipe": 1724}'::jsonb, 110);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6-1-2x10-a-frame', 'u-single-aframe', '6 1/2X10 A-Frame', '6.5x10', 10, '{"angle": 1402, "sqtube": 1485, "pipe": 1471}'::jsonb, 120);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6-1-2x10-a-frame-w-4ft-gate', 'u-single-aframe', '6 1/2X10 A-Frame w/ 4ft Gate', '6.5x10', 10, '{"angle": 1581, "sqtube": 1657, "pipe": 1644}'::jsonb, 130);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6-1-2x12-a-frame', 'u-single-aframe', '6 1/2X12 A-Frame', '6.5x12', 12, '{"angle": 1478, "sqtube": 1553, "pipe": 1553}'::jsonb, 140);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6-1-2x12-a-frame-w-4ft-gate', 'u-single-aframe', '6 1/2X12 A-Frame w/ 4ft Gate', '6.5x12', 12, '{"angle": 1657, "sqtube": 1725, "pipe": 1726}'::jsonb, 150);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-single-aframe--6-1-2x14-a-frame-w-4ft-gate', 'u-single-aframe', '6 1/2X14 A-Frame w/ 4ft Gate', '6.5x14', 14, '{"angle": 1729, "sqtube": 1742, "pipe": 1787}'::jsonb, 160);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-tandem-4ch', 'utility', 'All Angle Tandem, 4 inch Channel Wrap Tongue', 'Tandem axle workhorse on the 4 inch wrap tongue.',
   array['3500 lb tandem axle', '8K coupler', '4 inch channel wrap tongue', 'Treated wood floors', '15 inch new wheels and tires'], '[{"key": "std", "label": "Standard"}]'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--5x12', 'u-tandem-4ch', '5X12', '5x12', 12, '{"std": 1939}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--5x14', 'u-tandem-4ch', '5X14', '5x14', 14, '{"std": 2008}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--6x10', 'u-tandem-4ch', '6X10', '6x10', 10, '{"std": 1952}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--6x12', 'u-tandem-4ch', '6X12', '6x12', 12, '{"std": 2003}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--6x14', 'u-tandem-4ch', '6X14', '6x14', 14, '{"std": 2045}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--6-1-2x12', 'u-tandem-4ch', '6 1/2X12', '6.5x12', 12, '{"std": 2040}'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-4ch--6-1-2x14', 'u-tandem-4ch', '6 1/2X14', '6.5x14', 14, '{"std": 2107}'::jsonb, 60);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-4ch--opt--add-a-gate', 'u-tandem-4ch', 'Add a gate', 200, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-4ch--opt--add-ramps', 'u-tandem-4ch', 'Add ramps', 175, 10);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-tandem-5ch-angle', 'utility', 'All Angle Tandem, 5 inch Channel Wrap Tongue', 'The long-deck angle tandem, 16 to 20 feet.',
   array['3500 lb tandem axle', '8K coupler', '5 inch channel wrap tongue', 'Treated wood floors', '15 inch new wheels and tires'], '[{"key": "std", "label": "Standard"}]'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-angle--6-1-2x16', 'u-tandem-5ch-angle', '6 1/2X16', '6.5x16', 16, '{"std": 2179}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-angle--6-1-2x18', 'u-tandem-5ch-angle', '6 1/2X18', '6.5x18', 18, '{"std": 2262}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-angle--6-1-2x20', 'u-tandem-5ch-angle', '6 1/2X20', '6.5x20', 20, '{"std": 2378}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-angle--82x16', 'u-tandem-5ch-angle', '82X16', '82x16', 16, '{"std": 2202}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-angle--82x18', 'u-tandem-5ch-angle', '82X18', '82x18', 18, '{"std": 2287}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-angle--82x20', 'u-tandem-5ch-angle', '82X20', '82x20', 20, '{"std": 2367}'::jsonb, 50);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-5ch-angle--opt--add-a-gate', 'u-tandem-5ch-angle', 'Add a gate', 200, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-5ch-angle--opt--add-ramps', 'u-tandem-5ch-angle', 'Add ramps', 175, 10);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-tandem-5ch-pipe', 'utility', 'Pipe Top Rails, Angle Main Frame', 'Pipe top rail on the angle main frame, 5 inch wrap tongue.',
   array['3500 lb tandem axle', '8K coupler', '5 inch channel wrap tongue', 'Treated wood floors', '15 inch new wheels and tires'], '[{"key": "std", "label": "Standard"}]'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-pipe--6-1-2x16', 'u-tandem-5ch-pipe', '6 1/2X16', '6.5x16', 16, '{"std": 2291}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-pipe--6-1-2x18', 'u-tandem-5ch-pipe', '6 1/2X18', '6.5x18', 18, '{"std": 2363}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-pipe--6-1-2x20', 'u-tandem-5ch-pipe', '6 1/2X20', '6.5x20', 20, '{"std": 2426}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-pipe--82x16', 'u-tandem-5ch-pipe', '82X16', '82x16', 16, '{"std": 2304}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-pipe--82x18', 'u-tandem-5ch-pipe', '82X18', '82x18', 18, '{"std": 2388}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-pipe--82x20', 'u-tandem-5ch-pipe', '82X20', '82x20', 20, '{"std": 2470}'::jsonb, 50);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-5ch-pipe--opt--add-a-gate', 'u-tandem-5ch-pipe', 'Add a gate', 200, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-5ch-pipe--opt--add-ramps', 'u-tandem-5ch-pipe', 'Add ramps', 175, 10);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-tandem-5ch-sqtube', 'utility', 'Square Tube Top Rail, Angle Main Frame', 'Square tube top rail on the angle main frame, 5 inch wrap tongue.',
   array['3500 lb tandem axle', '8K coupler', '5 inch channel wrap tongue', 'Treated wood floors', '15 inch new wheels and tires'], '[{"key": "std", "label": "Standard"}]'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-sqtube--6-1-2x16', 'u-tandem-5ch-sqtube', '6 1/2X16', '6.5x16', 16, '{"std": 2284}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-sqtube--6-1-2x18', 'u-tandem-5ch-sqtube', '6 1/2X18', '6.5x18', 18, '{"std": 2373}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-sqtube--6-1-2x20', 'u-tandem-5ch-sqtube', '6 1/2X20', '6.5x20', 20, '{"std": 2491}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-sqtube--82x16', 'u-tandem-5ch-sqtube', '82X16', '82x16', 16, '{"std": 2306}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-sqtube--82x18', 'u-tandem-5ch-sqtube', '82X18', '82x18', 18, '{"std": 2397}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-tandem-5ch-sqtube--82x20', 'u-tandem-5ch-sqtube', '82X20', '82x20', 20, '{"std": 2511}'::jsonb, 50);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-5ch-sqtube--opt--add-a-gate', 'u-tandem-5ch-sqtube', 'Add a gate', 200, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('u-tandem-5ch-sqtube--opt--add-ramps', 'u-tandem-5ch-sqtube', 'Add ramps', 175, 10);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-econo-single', 'utility', 'Economy Single Axle', 'The budget single axle. Built black only.',
   array['3500 lb single axle', 'A-frame tongue', '2x8 wood floor', '15 inch new wheels and tires', 'Black only'], '[{"key": "std", "label": "Standard"}]'::jsonb, 60);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--5x8-a-frame-tilt', 'u-econo-single', '5X8 A-Frame Tilt', '5x8', 8, '{"std": 1202}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--5x8-a-frame-w-4ft-gate', 'u-econo-single', '5X8 A-Frame w/ 4ft Gate', '5x8', 8, '{"std": 1283}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--5x10-a-frame-tilt', 'u-econo-single', '5X10 A-Frame Tilt', '5x10', 10, '{"std": 1244}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--5x10-a-frame-w-4ft-gate', 'u-econo-single', '5X10 A-Frame w/ 4ft Gate', '5x10', 10, '{"std": 1325}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--5x12-a-frame-w-4ft-gate', 'u-econo-single', '5X12 A-Frame w/ 4ft Gate', '5x12', 12, '{"std": 1404}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--5x14-a-frame-w-4ft-gate', 'u-econo-single', '5X14 A-Frame w/ 4ft Gate', '5x14', 14, '{"std": 1464}'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--6x10-a-frame-tilt', 'u-econo-single', '6X10 A-Frame Tilt', '6x10', 10, '{"std": 1322}'::jsonb, 60);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--6x10-a-frame-w-4ft-gate', 'u-econo-single', '6X10 A-Frame w/ 4ft Gate', '6x10', 10, '{"std": 1460}'::jsonb, 70);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--6x12-a-frame-w-4ft-gate', 'u-econo-single', '6X12 A-Frame w/ 4ft Gate', '6x12', 12, '{"std": 1515}'::jsonb, 80);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-single--6x14-a-frame-w-4ft-gate', 'u-econo-single', '6X14 A-Frame w/ 4ft Gate', '6x14', 14, '{"std": 1566}'::jsonb, 90);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('u-econo-tandem', 'utility', 'Economy Tandem', '5000 lb economy tandem. Built black only.',
   array['5000 lb tandem axle', 'A-frame tongue', '2x8 wood floor', '15 inch new wheels and tires', 'Black only'], '[{"key": "std", "label": "Standard"}]'::jsonb, 70);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('u-econo-tandem--6-1-2x16-a-frame-tandem', 'u-econo-tandem', '6 1/2X16 A-Frame Tandem', '6.5x16', 16, '{"std": 1987}'::jsonb, 0);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('ch-dove', 'car-hauler', 'Car Hauler, Ramps and Holders in Dove', 'The classic 3x5 1/4 main frame car hauler with ramps stowed in the dove.',
   array['3x5 1/4 main frame', '3500 lb tandem axle', '8K coupler', '5 inch channel wrap tongue', 'Treated wood floor', '15 inch new wheels and tires', 'Ramps and holders in dove'], '[{"key": "std", "label": "Standard"}]'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-dove--6-1-2x16', 'ch-dove', '6 1/2X16', '6.5x16', 16, '{"std": 2666}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-dove--6-1-2x18', 'ch-dove', '6 1/2X18', '6.5x18', 18, '{"std": 2749}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-dove--6-1-2x20', 'ch-dove', '6 1/2X20', '6.5x20', 20, '{"std": 2841}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-dove--82x16', 'ch-dove', '82X16', '82x16', 16, '{"std": 2677}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-dove--82x18', 'ch-dove', '82X18', '82x18', 18, '{"std": 2763}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-dove--82x20', 'ch-dove', '82X20', '82x20', 20, '{"std": 2837}'::jsonb, 50);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('ch-angle', 'car-hauler', 'Car Hauler, Angle Uprights and Top Rails', 'Side-mounted ramps, 2x3 angle uprights and top rails.',
   array['3x5 1/4 main frame', '2x3 angle uprights and top rails', '5 inch channel wrap tongue', 'Treated wood floors', 'Ramps and holders on the side', '2-3500 lb or 2-5200 lb axles', '7K drop leg jack', '8 ply radial tires', 'Crossmembers on 2ft centers'], '[{"key": "std", "label": "Standard"}]'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-angle--82x16', 'ch-angle', '82X16', '82x16', 16, '{"std": 2814}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-angle--82x18', 'ch-angle', '82X18', '82x18', 18, '{"std": 2918}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-angle--82x20', 'ch-angle', '82X20', '82x20', 20, '{"std": 2985}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-angle--52x82x16', 'ch-angle', '52X82X16', '52x82x16', 16, '{"std": 3520}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-angle--52x82x18', 'ch-angle', '52X82X18', '52x82x18', 18, '{"std": 3612}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-angle--52x82x20', 'ch-angle', '52X82X20', '52x82x20', 20, '{"std": 3715}'::jsonb, 50);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('ch-pipe', 'car-hauler', 'Car Hauler, Angle Uprights and Pipe Top Rails', 'Side-mounted ramps, pipe top rails.',
   array['3x5 1/4 main frame', '2x3 angle uprights, pipe top rails', '5 inch channel wrap tongue', 'Treated wood floors', 'Ramps and holders on the side', '2-3500 lb or 2-5200 lb axles', '7K drop leg jack', '8 ply radial tires', 'Crossmembers on 2ft centers'], '[{"key": "std", "label": "Standard"}]'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-pipe--82x16', 'ch-pipe', '82X16', '82x16', 16, '{"std": 2874}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-pipe--82x18', 'ch-pipe', '82X18', '82x18', 18, '{"std": 2973}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-pipe--82x20', 'ch-pipe', '82X20', '82x20', 20, '{"std": 3063}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-pipe--52x82x16', 'ch-pipe', '52X82X16', '52x82x16', 16, '{"std": 3563}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-pipe--52x82x18', 'ch-pipe', '52X82X18', '52x82x18', 18, '{"std": 3677}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-pipe--52x82x20', 'ch-pipe', '52X82X20', '52x82x20', 20, '{"std": 3772}'::jsonb, 50);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('ch-sqtube', 'car-hauler', 'Car Hauler, Square Tube Uprights and Top Rails', 'Side-mounted ramps, square tube uprights and square top rails.',
   array['3x5 1/4 main frame', '2x3 square tube uprights and square top rails', '5 inch channel wrap tongue', 'Treated wood floors', 'Ramps and holders on the side', '2-3500 lb or 2-5200 lb axles', '7K drop leg jack', '8 ply radial tires', 'Crossmembers on 2ft centers'], '[{"key": "std", "label": "Standard"}]'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-sqtube--82x16', 'ch-sqtube', '82X16', '82x16', 16, '{"std": 2853}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-sqtube--82x18', 'ch-sqtube', '82X18', '82x18', 18, '{"std": 2964}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-sqtube--82x20', 'ch-sqtube', '82X20', '82x20', 20, '{"std": 3028}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-sqtube--52x82x16', 'ch-sqtube', '52X82X16', '52x82x16', 16, '{"std": 3611}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-sqtube--52x82x18', 'ch-sqtube', '52X82X18', '52x82x18', 18, '{"std": 3714}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-sqtube--52x82x20', 'ch-sqtube', '52X82X20', '52x82x20', 20, '{"std": 3831}'::jsonb, 50);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('ch-flatbed', 'car-hauler', 'Flat Bed with Stake Pockets, 5 inch Channel Main Frame', 'Open flat deck on the 5 inch channel frame with stake pockets.',
   array['5 inch channel main frame', '5 inch channel wrap tongue', 'Treated wood floor', 'Ramps and holders on the side', '2-3500 lb or 2-5200 lb axles', '7K drop leg jack', 'Crossmembers on 2ft centers'], '[{"key": "std", "label": "Standard"}]'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-flatbed--82x16', 'ch-flatbed', '82X16', '82x16', 16, '{"std": 1733}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-flatbed--82x18', 'ch-flatbed', '82X18', '82x18', 18, '{"std": 2837}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-flatbed--82x20', 'ch-flatbed', '82X20', '82x20', 20, '{"std": 2878}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-flatbed--52x82x16', 'ch-flatbed', '52X82X16', '52x82x16', 16, '{"std": 3458}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-flatbed--52x82x18', 'ch-flatbed', '52X82X18', '52x82x18', 18, '{"std": 3560}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-flatbed--52x82x20', 'ch-flatbed', '52X82X20', '52x82x20', 20, '{"std": 3632}'::jsonb, 50);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('ch-econo', 'car-hauler', 'Economy Car Hauler, 4 inch Channel', 'The value car hauler with ramps and holders.',
   array['4 inch channel', '2-3500 lb axles, 1 brake', 'Ramps and holders', 'Wood floor'], '[{"key": "std", "label": "Standard"}]'::jsonb, 60);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-econo--82x14plus2', 'ch-econo', '82X14+2', '82x14+2', 16, '{"std": 2241}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-econo--82x16plus2', 'ch-econo', '82X16+2', '82x16+2', 18, '{"std": 2350}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('ch-econo--82x18plus2', 'ch-econo', '82X18+2', '82x18+2', 20, '{"std": 2417}'::jsonb, 20);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('eq-6ch', 'equipment', 'Equipment Trailer, 6 inch Channel Main Frame', 'Skid steer and tractor duty on the 6 inch channel frame.',
   array['6 inch channel main frame', '3 inch crossmembers on 2ft centers', 'Two 7K axles, idler and brake', '7K jack', 'Diamond teardrop fenders', '10 ply radial tires', '2 5/16 inch adjustable bulldog coupler', 'Treated wood floors', '5ft stiff arm ramps', 'Sealed beam lights', '5/16 inch safety chains', 'Break-away kit', 'Stake pockets and rub rails'], '[{"key": "std", "label": "Standard"}]'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('eq-6ch--82x16x6ch', 'eq-6ch', '82X16X6CH', '82x16', 16, '{"std": 4307}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('eq-6ch--82x18x6ch', 'eq-6ch', '82X18X6CH', '82x18', 18, '{"std": 4405}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('eq-6ch--82x20x6ch', 'eq-6ch', '82X20X6CH', '82x20', 20, '{"std": 4504}'::jsonb, 20);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('eq-6ch--opt--pipe-top-rails-on-16ft', 'eq-6ch', 'Pipe top rails on 16ft', 261, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('eq-6ch--opt--pipe-top-rails-on-18ft', 'eq-6ch', 'Pipe top rails on 18ft', 276, 10);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('eq-8ch', 'equipment', 'Equipment Trailer, 8 inch Channel Main Frame', 'The heaviest open deck we build.',
   array['8 inch channel main frame', '3 inch crossmembers on 2ft centers', 'Two 7K axles, idler and brake', '7K jack', 'Diamond teardrop fenders', '10 ply radial tires', '2 5/16 inch adjustable bulldog coupler', 'Treated wood floors', '5ft stiff arm ramps', 'Sealed beam lights', '5/16 inch safety chains', 'Break-away kit', 'Stake pockets and rub rails'], '[{"key": "std", "label": "Standard"}]'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('eq-8ch--82x16x8ch', 'eq-8ch', '82X16X8CH', '82x16', 16, '{"std": 4704}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('eq-8ch--82x18x8ch', 'eq-8ch', '82X18X8CH', '82x18', 18, '{"std": 4850}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('eq-8ch--82x20x8ch', 'eq-8ch', '82X20X8CH', '82x20', 20, '{"std": 5023}'::jsonb, 20);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('eq-8ch--opt--pipe-top-rails-on-16ft', 'eq-8ch', 'Pipe top rails on 16ft', 261, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('eq-8ch--opt--pipe-top-rails-on-18ft', 'eq-8ch', 'Pipe top rails on 18ft', 276, 10);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('dump', 'dump', 'Dump Trailer', '7 foot dump body, 12 or 14 feet, with your choice of side height.',
   array['14,000 lb GVWR', 'Two 7000 lb brake axles', 'Roll tarp', 'Loading ramps', 'Spreader gate ready', 'Heavy-duty steel body and frame'], '[{"key": "std", "label": "Standard"}]'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('dump--7x12-with-2ft-sides', 'dump', '7X12 with 2ft Sides', '7x12', 12, '{"std": 7442}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('dump--7x12-with-3ft-sides', 'dump', '7X12 with 3ft Sides', '7x12', 12, '{"std": 7651}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('dump--7x12-with-4ft-sides', 'dump', '7X12 with 4ft Sides', '7x12', 12, '{"std": 7878}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('dump--7x14-with-2ft-sides', 'dump', '7X14 with 2ft Sides', '7x14', 14, '{"std": 7904}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('dump--7x14-with-3ft-sides', 'dump', '7X14 with 3ft Sides', '7x14', 14, '{"std": 8168}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('dump--7x14-with-4ft-sides', 'dump', '7X14 with 4ft Sides', '7x14', 14, '{"std": 8431}'::jsonb, 50);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('dump--opt--spare-tire-mount', 'dump', 'Spare tire mount', 12, 0);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('dump--opt--spare-tire', 'dump', 'Spare tire', 130, 10);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('dump--opt--spreader-gate', 'dump', 'Spreader gate', 200, 20);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('dump--opt--delete-tarp-credit', 'dump', 'Delete tarp (credit)', -165, 30);
insert into catalog_line_options (id, line_id, label, price, sort) values
  ('dump--opt--delete-ramps-credit', 'dump', 'Delete ramps (credit)', -160, 40);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('en-single', 'enclosed', 'Enclosed Cargo, Single Axle', 'V-nose single axle cargo, standard or Blackout package.',
   array['V nose front', '80 polycore sides', '16 inch center walls', '24 inch center roof', '16 inch crossmembers', '6ft 2in standard height', '3/4 plywood flooring', '3/8 plywood walls', 'Ramp door with flap', '2ft rock guard', 'LED lights', 'Roof vent or side vent', 'Side door with flush lock', '7 way plug', '15 inch radial tires', '2990 lb 4 inch drop axle', '2000 lb jack with jack foot', '2 inch coupler', 'Steel tube frame', 'Aluminum fender', 'Galvalume roofing', 'Black wheels'], '[{"key": "std", "label": "Standard"}, {"key": "blackout", "label": "Blackout Package"}]'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--5x8', 'en-single', '5X8', '5x8', 8, '{"std": 2519, "blackout": 2599}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--5x10', 'en-single', '5X10', '5x10', 10, '{"std": 2516, "blackout": 2616}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--6x10', 'en-single', '6X10', '6x10', 10, '{"std": 3054, "blackout": 3154}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--6x12', 'en-single', '6X12', '6x12', 12, '{"std": 3278, "blackout": 3398}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--6x14', 'en-single', '6X14', '6x14', 14, '{"std": 3574, "blackout": 3714}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--7x12', 'en-single', '7X12', '7x12', 12, '{"std": 3856, "blackout": 3976}'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-single--7x14', 'en-single', '7X14', '7x14', 14, '{"std": 4267, "blackout": 4407}'::jsonb, 60);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('en-tandem', 'enclosed', 'Enclosed Cargo, Tandem Axle', 'V-nose tandem cargo, standard or Blackout package.',
   array['V nose front', '80 polycore sides', '16 inch center walls', '24 inch center roof', '16 inch crossmembers', '6ft 2in standard height', '3/4 plywood flooring', '3/8 plywood walls', 'Ramp door with flap', '2ft rock guard', 'LED lights', 'Roof vent or side vent', 'Side door with flush lock', '7 way plug', '15 inch radial tires', '3500 lb 4 inch drop axles', 'LED dome light', '2 5/16 inch coupler', 'Steel tube frame', 'Aluminum fender', 'Galvalume roofing', 'Black wheels'], '[{"key": "std", "label": "Standard"}, {"key": "blackout", "label": "Blackout Package"}]'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--6x12', 'en-tandem', '6X12', '6x12', 12, '{"std": 4148, "blackout": 4268}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--6x14', 'en-tandem', '6X14', '6x14', 14, '{"std": 4304, "blackout": 4444}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x12', 'en-tandem', '7X12', '7x12', 12, '{"std": 4435, "blackout": 4555}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x14', 'en-tandem', '7X14', '7x14', 14, '{"std": 4784, "blackout": 4924}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x16', 'en-tandem', '7X16', '7x16', 16, '{"std": 5030, "blackout": 5190}'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x18', 'en-tandem', '7X18', '7x18', 18, '{"std": 5481, "blackout": 5661}'::jsonb, 50);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x20', 'en-tandem', '7X20', '7x20', 20, '{"std": 5698, "blackout": 5898}'::jsonb, 60);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x22', 'en-tandem', '7X22', '7x22', 22, '{"std": 5796, "blackout": 6016}'::jsonb, 70);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-tandem--7x24', 'en-tandem', '7X24', '7x24', 24, '{"std": 5609, "blackout": 5849}'::jsonb, 80);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('en-85-3500', 'enclosed', 'Enclosed Cargo, 8.5 Wide Tandem 3500 lb', '8.5 foot wide on 3500 lb axles. Inside height 6ft 6in.',
   array['8.5 foot wide, inside height 6ft 6in', 'V nose front', '80 polycore sides', '3500 lb axles', '3/4 plywood flooring', 'Ramp door with flap', 'LED lights', 'Side door with flush lock', 'Galvalume roofing', 'Black wheels'], '[{"key": "std", "label": "Standard"}, {"key": "blackout", "label": "Blackout Package"}]'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-3500--85x16', 'en-85-3500', '8.5X16', '8.5x16', 16, '{"std": 5985, "blackout": 6145}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-3500--85x18', 'en-85-3500', '8.5X18', '8.5x18', 18, '{"std": 6378, "blackout": 6558}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-3500--85x20', 'en-85-3500', '8.5X20', '8.5x20', 20, '{"std": 6770, "blackout": 6970}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-3500--85x22', 'en-85-3500', '8.5X22', '8.5x22', 22, '{"std": 7163, "blackout": 7383}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-3500--85x24', 'en-85-3500', '8.5X24', '8.5x24', 24, '{"std": 7381, "blackout": 7621}'::jsonb, 40);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('en-85-5200', 'enclosed', 'Enclosed Cargo, 8.5 Wide Tandem 5200 lb', '8.5 foot wide on 5200 lb axles for heavier payloads.',
   array['8.5 foot wide, inside height 6ft 6in', 'V nose front', '80 polycore sides', '5200 lb axles', '3/4 plywood flooring', 'Ramp door with flap', 'LED lights', 'Side door with flush lock', 'Galvalume roofing', 'Black wheels'], '[{"key": "std", "label": "Standard"}, {"key": "blackout", "label": "Blackout Package"}]'::jsonb, 40);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-5200--85x16', 'en-85-5200', '8.5X16', '8.5x16', 16, '{"std": 6685, "blackout": 6845}'::jsonb, 0);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-5200--85x18', 'en-85-5200', '8.5X18', '8.5x18', 18, '{"std": 6880, "blackout": 7060}'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-5200--85x20', 'en-85-5200', '8.5X20', '8.5x20', 20, '{"std": 7151, "blackout": 7351}'::jsonb, 20);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-5200--85x22', 'en-85-5200', '8.5X22', '8.5x22', 22, '{"std": 7314, "blackout": 7534}'::jsonb, 30);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('en-85-5200--85x24', 'en-85-5200', '8.5X24', '8.5x24', 24, '{"std": 7578, "blackout": 7818}'::jsonb, 40);

insert into catalog_lines (id, category, name, blurb, standards, variants, sort) values
  ('gn-custom', 'gooseneck', 'Gooseneck, Built to Order', 'Goosenecks are quoted per build. Tell us the deck, the axles, and the load.',
   array['Built to your spec', 'Quoted by the factory'], '[{"key": "std", "label": "Quote"}]'::jsonb, 10);
insert into catalog_models (id, line_id, label, size, length_ft, prices, sort) values
  ('gn-custom--specify-the-build-in-notes', 'gn-custom', 'Specify the build in notes', 'custom', 20, '{"std": null}'::jsonb, 0);

-- Options ----------------------------------------------------------------
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--raised-rails-raised-2ft', 'Rails and Sides', 'Raised rails, raised 2ft', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 159, "14-16": 194, "18-20": 207}'::jsonb, 0);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--raised-rails-raised-3ft', 'Rails and Sides', 'Raised rails, raised 3ft', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 218, "14-16": 259, "18-20": 279}'::jsonb, 10);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--raised-rails-raised-4ft', 'Rails and Sides', 'Raised rails, raised 4ft', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 262, "14-16": 310, "18-20": 338}'::jsonb, 20);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--expanded-metal-sides-standard-height', 'Rails and Sides', 'Expanded metal sides, standard height', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 161, "14-16": 218, "18-20": 273}'::jsonb, 30);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--expanded-metal-sides-raised-2ft', 'Rails and Sides', 'Expanded metal sides, raised 2ft', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 432, "14-16": 576, "18-20": 700}'::jsonb, 40);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--expanded-metal-sides-raised-3ft', 'Rails and Sides', 'Expanded metal sides, raised 3ft', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 614, "14-16": 792, "18-20": 902}'::jsonb, 50);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--rails-and-sides--expanded-metal-sides-raised-4ft', 'Rails and Sides', 'Expanded metal sides, raised 4ft', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"8-12": 755, "14-16": 913, "18-20": 1050}'::jsonb, 60);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--floor-and-frame--2x3x3-16-crossmembers-on-2ft-centers', 'Floor and Frame', '2x3x3/16 crossmembers on 2ft centers', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"16": 70, "18": 104, "20": 139}'::jsonb, 70);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--floor-and-frame--2x3x3-16-crossmembers-on-16in-centers', 'Floor and Frame', '2x3x3/16 crossmembers on 16in centers', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"16": 130, "18": 174, "20": 174}'::jsonb, 80);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--floor-and-frame--3in-channel-crossmembers-on-16in-centers', 'Floor and Frame', '3in channel crossmembers on 16in centers', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"16": 111, "18": 138, "20": 166}'::jsonb, 90);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--floor-and-frame--2ft-diamond-plate-runners', 'Floor and Frame', '2ft diamond plate runners', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"16": 346, "18": 414, "20": 481}'::jsonb, 100);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--floor-and-frame--solid-diamond-plate-floor', 'Floor and Frame', 'Solid diamond plate floor', array['utility', 'car-hauler', 'equipment'], 'band', null, '{"16": 612, "18": 703, "20": 793}'::jsonb, 110);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--pipe-jack-stands', 'Couplers and Jacks', 'Pipe jack stands', array['utility', 'car-hauler', 'equipment'], 'flat', 45, null, 120);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--2in-bulldog-coupler', 'Couplers and Jacks', '2in bulldog coupler', array['utility', 'car-hauler', 'equipment'], 'flat', 25, null, 130);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--2-5-16in-bulldog-coupler', 'Couplers and Jacks', '2 5/16in bulldog coupler', array['utility', 'car-hauler', 'equipment'], 'flat', 40, null, 140);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--adjustable-bulldog-coupler', 'Couplers and Jacks', 'Adjustable bulldog coupler', array['utility', 'car-hauler', 'equipment'], 'flat', 90, null, 150);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--upgrade-2k-jack-to-7k-drop-leg', 'Couplers and Jacks', 'Upgrade 2K jack to 7K drop leg', array['utility', 'car-hauler', 'equipment'], 'flat', 25, null, 160);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--upgrade-7k-drop-leg-to-10k-drop-leg', 'Couplers and Jacks', 'Upgrade 7K drop leg to 10K drop leg', array['utility', 'car-hauler', 'equipment'], 'flat', 80, null, 170);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--couplers-and-jacks--add-a-second-10k-jack', 'Couplers and Jacks', 'Add a second 10K jack', array['utility', 'car-hauler', 'equipment'], 'flat', 120, null, 180);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--add-one-3500-lb-axle-with-breakaway-kit', 'Axles and Tires', 'Add one 3500 lb axle with breakaway kit', array['utility', 'car-hauler', 'equipment'], 'flat', 145, null, 190);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--add-two-3500-lb-brake-axles', 'Axles and Tires', 'Add two 3500 lb brake axles', array['utility', 'car-hauler', 'equipment'], 'flat', 270, null, 200);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--add-one-5200-lb-brake', 'Axles and Tires', 'Add one 5200 lb brake', array['utility', 'car-hauler', 'equipment'], 'flat', 155, null, 210);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--add-one-7000-lb-brake', 'Axles and Tires', 'Add one 7000 lb brake', array['utility', 'car-hauler', 'equipment'], 'flat', 175, null, 220);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--spare-tire-holder-3500-lb', 'Axles and Tires', 'Spare tire holder, 3500 lb', array['utility', 'car-hauler', 'equipment'], 'flat', 15, null, 230);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--205-75-15-6-ply-radial', 'Axles and Tires', '205-75-15 6 ply radial', array['utility', 'car-hauler', 'equipment'], 'flat', 84, null, 240);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--225-75-15-8-ply-radial', 'Axles and Tires', '225-75-15 8 ply radial', array['utility', 'car-hauler', 'equipment'], 'flat', 110, null, 250);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--235-80-16-10-ply-radial-8-lug', 'Axles and Tires', '235-80-16 10 ply radial, 8 lug', array['utility', 'car-hauler', 'equipment'], 'flat', 131, null, 260);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--235-80-16-14-ply-radial-8-lug', 'Axles and Tires', '235-80-16 14 ply radial, 8 lug', array['utility', 'car-hauler', 'equipment'], 'flat', 205, null, 270);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--sealed-beam-tail-lights', 'Axles and Tires', 'Sealed beam tail lights', array['utility', 'car-hauler', 'equipment'], 'flat', 35, null, 280);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--axles-and-tires--diamond-plate-teardrop-fenders-in-place-of-standard', 'Axles and Tires', 'Diamond plate teardrop fenders in place of standard', array['utility', 'car-hauler', 'equipment'], 'flat', 100, null, 290);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--5ft-gate', 'Gates and Ramps', '5ft gate', array['utility', 'car-hauler', 'equipment'], 'flat', 202, null, 300);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--6ft-gate', 'Gates and Ramps', '6ft gate', array['utility', 'car-hauler', 'equipment'], 'flat', 221, null, 310);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--6-1-2ft-gate', 'Gates and Ramps', '6 1/2ft gate', array['utility', 'car-hauler', 'equipment'], 'flat', 268, null, 320);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--82in-gate', 'Gates and Ramps', '82in gate', array['utility', 'car-hauler', 'equipment'], 'flat', 277, null, 330);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--extra-uprights', 'Gates and Ramps', 'Extra uprights', array['utility', 'car-hauler', 'equipment'], 'flat', 14, null, 340);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--4x4-gate-on-the-side', 'Gates and Ramps', '4x4 gate on the side', array['utility', 'car-hauler', 'equipment'], 'flat', 187, null, 350);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--built-in-ramps', 'Gates and Ramps', 'Built in ramps', array['utility', 'car-hauler', 'equipment'], 'flat', 60, null, 360);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--spring-assist-on-gate', 'Gates and Ramps', 'Spring assist on gate', array['utility', 'car-hauler', 'equipment'], 'flat', 150, null, 370);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--add-mesh', 'Gates and Ramps', 'Add mesh', array['utility', 'car-hauler', 'equipment'], 'flat', 50, null, 380);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--4ft-ramps', 'Gates and Ramps', '4ft ramps', array['utility', 'car-hauler', 'equipment'], 'flat', 107, null, 390);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--5ft-ramps', 'Gates and Ramps', '5ft ramps', array['utility', 'car-hauler', 'equipment'], 'flat', 143, null, 400);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--4ft-stiff-arm-ramps', 'Gates and Ramps', '4ft stiff arm ramps', array['utility', 'car-hauler', 'equipment'], 'flat', 228, null, 410);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--5ft-stiff-arm-ramps', 'Gates and Ramps', '5ft stiff arm ramps', array['utility', 'car-hauler', 'equipment'], 'flat', 336, null, 420);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--4ft-slide-in-ramp-holders', 'Gates and Ramps', '4ft slide in ramp holders', array['utility', 'car-hauler', 'equipment'], 'flat', 40, null, 430);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--5ft-slide-in-ramp-holders', 'Gates and Ramps', '5ft slide in ramp holders', array['utility', 'car-hauler', 'equipment'], 'flat', 76, null, 440);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--gates-and-ramps--3in-channel-5ft-slide-in-ramps', 'Gates and Ramps', '3in channel 5ft slide in ramps', array['utility', 'car-hauler', 'equipment'], 'flat', 170, null, 450);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--paint--charcoal', 'Paint', 'Charcoal', array['utility', 'car-hauler', 'equipment'], 'flat', 20, null, 460);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--utility--paint--red', 'Paint', 'Red', array['utility', 'car-hauler', 'equipment'], 'flat', 40, null, 470);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--height-and-insulation--7ft-2in-interior-height', 'Height and Insulation', '7ft 2in interior height', array['enclosed'], 'ltf', 9, null, 480);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--height-and-insulation--6ft-8in-interior-height', 'Height and Insulation', '6ft 8in interior height', array['enclosed'], 'ltf', 6, null, 490);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--height-and-insulation--thermal-barrier', 'Height and Insulation', 'Thermal barrier', array['enclosed'], 'ltf', 5, null, 500);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--doors-and-security--bar-locks', 'Doors and Security', 'Bar locks', array['enclosed'], 'flat', 35, null, 510);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--doors-and-security--side-door-on-5ft-wide', 'Doors and Security', 'Side door on 5ft wide', array['enclosed'], 'flat', 195, null, 520);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--doors-and-security--concession-door', 'Doors and Security', 'Concession door', array['enclosed'], 'call', null, null, 530);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--interior--d-ring-floor-mount', 'Interior', 'D-ring floor mount', array['enclosed'], 'flat', 10, null, 540);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--interior--e-track-per-foot', 'Interior', 'E track, per foot', array['enclosed'], 'perft', 10, null, 550);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--interior--3ft-interior-strip-lights', 'Interior', '3ft interior strip lights', array['enclosed'], 'flat', 38, null, 560);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--interior--light-switch', 'Interior', 'Light switch', array['enclosed'], 'flat', 5, null, 570);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--interior--roof-vent-install', 'Interior', 'Roof vent install', array['enclosed'], 'flat', 30, null, 580);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--interior--a-c-bracket', 'Interior', 'A/C bracket', array['enclosed'], 'flat', 25, null, 590);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--diamond-plate-fenders', 'Exterior', 'Diamond plate fenders', array['enclosed'], 'flat', 35, null, 600);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--upgrade-to-atp-diamond-plate-fenders', 'Exterior', 'Upgrade to ATP diamond plate fenders', array['enclosed'], 'flat', 35, null, 610);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--slant-rock-guard-atp', 'Exterior', 'Slant rock guard, ATP', array['enclosed'], 'flat', 30, null, 620);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--spoiler', 'Exterior', 'Spoiler', array['enclosed'], 'flat', 200, null, 630);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--spoiler-with-lights', 'Exterior', 'Spoiler with lights', array['enclosed'], 'flat', 225, null, 640);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--extra-clearance-lights', 'Exterior', 'Extra clearance lights', array['enclosed'], 'flat', 5, null, 650);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--ladder-mill-finish', 'Exterior', 'Ladder, mill finish', array['enclosed'], 'flat', 100, null, 660);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--ladder-black', 'Exterior', 'Ladder, black', array['enclosed'], 'flat', 140, null, 670);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--roof-rack-mill-finish', 'Exterior', 'Roof rack, mill finish', array['enclosed'], 'flat', 110, null, 680);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--exterior--roof-rack-black', 'Exterior', 'Roof rack, black', array['enclosed'], 'flat', 155, null, 690);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--1ft-extended-tongue', 'Running Gear', '1ft extended tongue', array['enclosed'], 'flat', 100, null, 700);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--7k-drop-leg-jack', 'Running Gear', '7K drop leg jack', array['enclosed'], 'flat', 25, null, 710);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--upgrade-to-5200-lb-axles-and-tires', 'Running Gear', 'Upgrade to 5200 lb axles and tires', array['enclosed'], 'flat', 450, null, 720);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--2in-bulldog-coupler', 'Running Gear', '2in bulldog coupler', array['enclosed'], 'flat', 25, null, 730);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--2-5-16in-bulldog-coupler', 'Running Gear', '2 5/16in bulldog coupler', array['enclosed'], 'flat', 40, null, 740);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--5x45-spare-tire', 'Running Gear', '5x4.5 spare tire', array['enclosed'], 'flat', 100, null, 750);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--6-lug-5200-lb-spare-tire', 'Running Gear', '6 lug 5200 lb spare tire', array['enclosed'], 'flat', 115, null, 760);
insert into catalog_options (id, group_name, label, applies_to, price_type, price, bands, sort) values
  ('opt--enclosed--running-gear--spare-tire-mount-extended-tongue-only', 'Running Gear', 'Spare tire mount, extended tongue only', array['enclosed'], 'flat', 25, null, 770);

commit;
