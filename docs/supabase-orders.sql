-- Triple R Trailers: dealer catalog and order requests.
-- Run this ONCE in the Supabase SQL Editor, then run docs/catalog-seed.sql.
-- Safe to re-run: everything is created "if not exists" and policies are replaced.
--
-- What this sets up:
--   * A private catalog only signed-in dealers can read
--   * Order requests scoped so each dealership sees only its own
--   * Server-side pricing, so a submitted request cannot carry made-up prices
--   * An email to the factory the moment a request is submitted

-- pg_net is what sends the order email. If it cannot be enabled here, the rest
-- of this script still installs and orders still save; only the email is
-- skipped. Enable it later under Database -> Extensions and it starts working.
do $$
begin
  execute 'create extension if not exists pg_net with schema extensions';
exception when others then
  raise notice 'pg_net not enabled (%). Everything else installs; order emails stay off until you enable it.', sqlerrm;
end $$;

-- ===========================================================================
-- 1. Who is who
-- ===========================================================================

create table if not exists dealers (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  city        text,
  state       text,
  phone       text,
  email       text,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Links a Supabase login to a dealership. One dealership can have several logins.
create table if not exists dealer_members (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  dealer_id  uuid not null references dealers (id) on delete cascade,
  full_name  text,
  created_at timestamptz not null default now()
);
create index if not exists dealer_members_dealer_idx on dealer_members (dealer_id);

-- Anyone listed here is Triple R office staff and can see every request.
create table if not exists staff_users (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  full_name  text,
  created_at timestamptz not null default now()
);

-- Private key/value store. RLS on with no policy means only the service role
-- (the Supabase dashboard) can read it. The email key lives here.
create table if not exists app_settings (
  key   text primary key,
  value text not null
);

create or replace function public.current_dealer_id()
returns uuid language sql stable security definer set search_path = public as $$
  select dealer_id from dealer_members where user_id = auth.uid() limit 1;
$$;

create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from staff_users where user_id = auth.uid());
$$;

-- ===========================================================================
-- 2. The catalog (filled by docs/catalog-seed.sql)
-- ===========================================================================

create table if not exists catalog_categories (
  slug text primary key,
  name text not null,
  page text,
  sort int not null default 0
);

create table if not exists catalog_lines (
  id        text primary key,
  category  text not null references catalog_categories (slug) on delete cascade,
  name      text not null,
  blurb     text,
  standards text[] not null default '{}',
  variants  jsonb  not null default '[]',
  sort      int    not null default 0
);

create table if not exists catalog_models (
  id        text primary key,
  line_id   text not null references catalog_lines (id) on delete cascade,
  label     text not null,
  size      text,
  length_ft int,
  prices    jsonb not null default '{}',
  sort      int   not null default 0
);
create index if not exists catalog_models_line_idx on catalog_models (line_id);

-- Options offered across a whole category.
create table if not exists catalog_options (
  id         text primary key,
  group_name text not null,
  label      text not null,
  applies_to text[] not null default '{}',
  price_type text not null check (price_type in ('flat', 'ltf', 'perft', 'band', 'call')),
  price      numeric(10,2),
  bands      jsonb,
  sort       int not null default 0
);

-- Options that belong to one product line only.
create table if not exists catalog_line_options (
  id      text primary key,
  line_id text not null references catalog_lines (id) on delete cascade,
  label   text not null,
  price   numeric(10,2) not null,
  sort    int not null default 0
);
create index if not exists catalog_line_options_line_idx on catalog_line_options (line_id);

-- ===========================================================================
-- 3. Order requests
-- ===========================================================================

create sequence if not exists order_no_seq start 1001;

create table if not exists orders (
  id            uuid primary key default gen_random_uuid(),
  order_no      text unique not null default 'TRR-' || nextval('order_no_seq'),
  dealer_id     uuid not null references dealers (id) on delete restrict,
  submitted_by  uuid references auth.users (id) on delete set null,
  status        text not null default 'submitted'
                check (status in ('submitted', 'confirmed', 'in_build', 'ready', 'delivered', 'cancelled')),
  contact_name  text,
  contact_phone text,
  contact_email text,
  po_number     text,
  needed_by     date,
  notes         text,
  item_count    int not null default 0,
  subtotal      numeric(12,2) not null default 0,
  has_quote_items boolean not null default false,
  created_at    timestamptz not null default now()
);
create index if not exists orders_dealer_idx on orders (dealer_id, created_at desc);

create table if not exists order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references orders (id) on delete cascade,
  line_id       text,
  line_name     text not null,
  model_id      text,
  model_label   text not null,
  variant_key   text,
  variant_label text,
  size          text,
  base_price    numeric(10,2),
  options       jsonb not null default '[]',
  options_total numeric(10,2) not null default 0,
  unit_price    numeric(10,2),
  qty           int not null default 1 check (qty > 0 and qty <= 99),
  line_total    numeric(12,2),
  needs_quote   boolean not null default false,
  notes         text,
  sort          int not null default 0
);
create index if not exists order_items_order_idx on order_items (order_id);

create table if not exists order_events (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid not null references orders (id) on delete cascade,
  status     text not null,
  note       text,
  actor      uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);
create index if not exists order_events_order_idx on order_events (order_id, created_at);

-- ===========================================================================
-- 4. Row level security
-- ===========================================================================

alter table dealers              enable row level security;
alter table dealer_members       enable row level security;
alter table staff_users          enable row level security;
alter table app_settings         enable row level security;
alter table catalog_categories   enable row level security;
alter table catalog_lines        enable row level security;
alter table catalog_models       enable row level security;
alter table catalog_options      enable row level security;
alter table catalog_line_options enable row level security;
alter table orders               enable row level security;
alter table order_items          enable row level security;
alter table order_events         enable row level security;

-- Catalog: readable by a login attached to a dealership, and by office staff.
-- A login with no dealership attached sees nothing, which is what makes taking
-- a dealer off a dealership actually cut off dealer pricing. Writable by
-- nobody through the API.
do $$
declare t text;
begin
  foreach t in array array['catalog_categories', 'catalog_lines', 'catalog_models',
                           'catalog_options', 'catalog_line_options']
  loop
    execute format('drop policy if exists "read catalog" on %I', t);
    execute format('create policy "read catalog" on %I for select to authenticated
                    using (current_dealer_id() is not null or is_staff())', t);
  end loop;
end $$;

-- A dealer can read their own dealership record; staff read all.
drop policy if exists "read own dealership" on dealers;
create policy "read own dealership" on dealers for select to authenticated
  using (id = current_dealer_id() or is_staff());

drop policy if exists "read own membership" on dealer_members;
create policy "read own membership" on dealer_members for select to authenticated
  using (user_id = auth.uid() or is_staff());

drop policy if exists "read own staff row" on staff_users;
create policy "read own staff row" on staff_users for select to authenticated
  using (user_id = auth.uid());

-- Orders: a dealership sees only its own. Inserts go through submit_order()
-- below, never straight from the browser, so there is no insert policy here.
drop policy if exists "read own orders" on orders;
create policy "read own orders" on orders for select to authenticated
  using (dealer_id = current_dealer_id() or is_staff());

drop policy if exists "staff update orders" on orders;
create policy "staff update orders" on orders for update to authenticated
  using (is_staff()) with check (is_staff());

drop policy if exists "read own order items" on order_items;
create policy "read own order items" on order_items for select to authenticated
  using (exists (select 1 from orders o where o.id = order_id
                 and (o.dealer_id = current_dealer_id() or is_staff())));

drop policy if exists "read own order events" on order_events;
create policy "read own order events" on order_events for select to authenticated
  using (exists (select 1 from orders o where o.id = order_id
                 and (o.dealer_id = current_dealer_id() or is_staff())));

-- ===========================================================================
-- 5. Pricing, computed on the server
-- ===========================================================================

-- Picks the right price out of a banded option ("8-12", "14-16", "16", ...).
create or replace function public.band_price(bands jsonb, length_ft int)
returns numeric language plpgsql immutable as $$
declare k text; v numeric; lo int; hi int;
begin
  if bands is null or length_ft is null then return null; end if;
  for k, v in select key, value::numeric from jsonb_each_text(bands) loop
    if position('-' in k) > 0 then
      lo := split_part(k, '-', 1)::int;
      hi := split_part(k, '-', 2)::int;
    else
      lo := k::int; hi := lo;
    end if;
    if length_ft between lo and hi then return v; end if;
  end loop;
  return null;
end $$;

-- ===========================================================================
-- 6. submit_order: the only way an order request is created
-- ===========================================================================
--
-- Expects payload like:
-- {
--   "contact_name": "...", "contact_phone": "...", "contact_email": "...",
--   "po_number": "...", "needed_by": "2026-09-15", "notes": "...",
--   "items": [{
--      "model_id": "en-tandem--7x16", "variant_key": "blackout", "qty": 2,
--      "notes": "white",
--      "options":     [{"id": "opt--enclosed--interior--e-track-per-foot", "qty": 20}],
--      "line_options":[{"id": "dump--opt--spreader-gate"}]
--   }]
-- }
--
-- Prices are looked up here, not taken from the browser.

create or replace function public.submit_order(payload jsonb)
returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_dealer   uuid := current_dealer_id();
  v_order    orders%rowtype;
  v_item     jsonb;
  v_model    catalog_models%rowtype;
  v_line     catalog_lines%rowtype;
  v_opt      catalog_options%rowtype;
  v_lopt     catalog_line_options%rowtype;
  v_ref      jsonb;
  v_base     numeric;
  v_optsum   numeric;
  v_optlist  jsonb;
  v_price    numeric;
  v_qty      int;
  v_oqty     numeric;
  v_variant  text;
  v_vlabel   text;
  v_needs_q  boolean;
  v_sort     int := 0;
  v_total    numeric := 0;
  v_count    int := 0;
  v_anyquote boolean := false;
begin
  if v_dealer is null then
    raise exception 'Your login is not linked to a dealership yet. Call the factory at (662) 728-7975.';
  end if;
  if payload->'items' is null or jsonb_array_length(payload->'items') = 0 then
    raise exception 'This request has no trailers on it.';
  end if;
  if jsonb_array_length(payload->'items') > 40 then
    raise exception 'That is more than 40 line items. Send it in a couple of requests or call the office.';
  end if;

  insert into orders (dealer_id, submitted_by, contact_name, contact_phone,
                      contact_email, po_number, needed_by, notes)
  values (v_dealer, auth.uid(),
          nullif(trim(payload->>'contact_name'), ''),
          nullif(trim(payload->>'contact_phone'), ''),
          nullif(trim(payload->>'contact_email'), ''),
          nullif(trim(payload->>'po_number'), ''),
          nullif(payload->>'needed_by', '')::date,
          nullif(trim(payload->>'notes'), ''))
  returning * into v_order;

  for v_item in select * from jsonb_array_elements(payload->'items') loop
    select * into v_model from catalog_models where id = v_item->>'model_id';
    if not found then
      raise exception 'That trailer is no longer in the catalog. Refresh and try again.';
    end if;
    select * into v_line from catalog_lines where id = v_model.line_id;

    v_qty := greatest(1, least(99, coalesce((v_item->>'qty')::int, 1)));
    v_variant := coalesce(v_item->>'variant_key', 'std');
    v_vlabel  := coalesce((select x->>'label' from jsonb_array_elements(v_line.variants) x
                           where x->>'key' = v_variant limit 1), v_variant);

    v_base := nullif(v_model.prices->>v_variant, '')::numeric;
    v_needs_q := v_base is null;
    v_optsum := 0;
    v_optlist := '[]'::jsonb;

    -- category-wide options
    for v_ref in select * from jsonb_array_elements(coalesce(v_item->'options', '[]'::jsonb)) loop
      select * into v_opt from catalog_options where id = v_ref->>'id';
      continue when not found;
      if not (v_line.category = any (v_opt.applies_to)) then continue; end if;

      v_oqty := greatest(1, least(200, coalesce((v_ref->>'qty')::numeric, 1)));
      v_price := case v_opt.price_type
                   when 'flat'  then v_opt.price
                   when 'ltf'   then v_opt.price * coalesce(v_model.length_ft, 0)
                   when 'perft' then v_opt.price * v_oqty
                   when 'band'  then band_price(v_opt.bands, v_model.length_ft)
                   else null
                 end;
      if v_price is null then v_needs_q := true; else v_optsum := v_optsum + v_price; end if;
      v_optlist := v_optlist || jsonb_build_object(
        'id', v_opt.id, 'label', v_opt.label, 'group', v_opt.group_name,
        'qty', case when v_opt.price_type = 'perft' then v_oqty else null end,
        'price', v_price);
    end loop;

    -- options that belong to this product line
    for v_ref in select * from jsonb_array_elements(coalesce(v_item->'line_options', '[]'::jsonb)) loop
      select * into v_lopt from catalog_line_options
        where id = v_ref->>'id' and line_id = v_line.id;
      continue when not found;
      v_optsum := v_optsum + v_lopt.price;
      v_optlist := v_optlist || jsonb_build_object(
        'id', v_lopt.id, 'label', v_lopt.label, 'group', 'Line Options',
        'qty', null, 'price', v_lopt.price);
    end loop;

    insert into order_items (order_id, line_id, line_name, model_id, model_label,
                             variant_key, variant_label, size, base_price, options,
                             options_total, unit_price, qty, line_total, needs_quote,
                             notes, sort)
    values (v_order.id, v_line.id, v_line.name, v_model.id, v_model.label,
            v_variant, v_vlabel, v_model.size, v_base, v_optlist,
            v_optsum,
            case when v_needs_q then null else v_base + v_optsum end,
            v_qty,
            case when v_needs_q then null else (v_base + v_optsum) * v_qty end,
            v_needs_q,
            nullif(trim(v_item->>'notes'), ''), v_sort);

    if not v_needs_q then v_total := v_total + (v_base + v_optsum) * v_qty;
    else v_anyquote := true; end if;
    v_count := v_count + v_qty;
    v_sort := v_sort + 10;
  end loop;

  update orders set item_count = v_count, subtotal = v_total,
                    has_quote_items = v_anyquote
   where id = v_order.id returning * into v_order;

  insert into order_events (order_id, status, note, actor)
  values (v_order.id, 'submitted', 'Request sent from the dealer portal', auth.uid());

  -- A failing email must never lose a dealer's order. The request is already
  -- saved and visible in the dashboard either way.
  begin
    perform notify_order(v_order.id);
  exception when others then
    raise notice 'Request % saved, but the factory email failed: %', v_order.order_no, sqlerrm;
  end;

  return jsonb_build_object('id', v_order.id, 'order_no', v_order.order_no,
                            'subtotal', v_order.subtotal, 'item_count', v_order.item_count,
                            'has_quote_items', v_order.has_quote_items);
end $$;

revoke all on function public.submit_order(jsonb) from public, anon;
grant execute on function public.submit_order(jsonb) to authenticated;

-- ===========================================================================
-- 7. Email the factory when a request lands
-- ===========================================================================
-- Needs two rows in app_settings, added from the SQL Editor:
--   insert into app_settings (key, value) values
--     ('resend_api_key', 're_xxx'),
--     ('order_email_to', 'triplertrailers@gmail.com')
--   on conflict (key) do update set value = excluded.value;
-- Without them the order still saves; only the email is skipped.

create or replace function public.notify_order(p_order uuid)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare
  v_key text; v_to text; v_from text;
  o orders%rowtype; d dealers%rowtype;
  v_rows text; v_html text; v_subject text;
begin
  select value into v_key  from app_settings where key = 'resend_api_key';
  select value into v_to   from app_settings where key = 'order_email_to';
  select value into v_from from app_settings where key = 'order_email_from';
  if v_key is null or v_to is null then return; end if;
  v_from := coalesce(v_from, 'Triple R Portal <onboarding@resend.dev>');

  select * into o from orders where id = p_order;
  select * into d from dealers where id = o.dealer_id;

  select string_agg(
    '<tr><td style="padding:8px 10px;border-bottom:1px solid #ddd;">' ||
      '<strong>' || i.qty || ' x ' || coalesce(i.line_name, '') || ' ' || i.model_label || '</strong>' ||
      case when i.variant_label is not null and i.variant_label <> 'Standard'
           then ' <em>(' || i.variant_label || ')</em>' else '' end ||
      case when jsonb_array_length(i.options) > 0 then
        '<br><span style="font-size:13px;color:#555;">' ||
        (select string_agg(coalesce(x->>'label', '') ||
                 case when x->>'qty' is not null then ' x' || (x->>'qty') else '' end ||
                 case when x->>'price' is not null
                      then ' ($' || to_char((x->>'price')::numeric, 'FM999,999.00') || ')'
                      else ' (quote)' end, '<br>')
           from jsonb_array_elements(i.options) x) || '</span>'
        else '' end ||
      case when i.notes is not null
           then '<br><span style="font-size:13px;color:#a00;">Note: ' || i.notes || '</span>'
           else '' end ||
    '</td><td style="padding:8px 10px;border-bottom:1px solid #ddd;text-align:right;white-space:nowrap;">' ||
      case when i.line_total is not null
           then '$' || to_char(i.line_total, 'FM999,999.00')
           else 'Needs a quote' end ||
    '</td></tr>', '' order by i.sort)
    into v_rows from order_items i where i.order_id = p_order;

  v_subject := 'Dealer order request ' || o.order_no || ' from ' || coalesce(d.name, 'a dealer');

  v_html :=
    '<div style="font-family:Arial,Helvetica,sans-serif;max-width:680px;">' ||
    '<h2 style="margin:0 0 4px;">Order request ' || o.order_no || '</h2>' ||
    '<p style="margin:0 0 18px;color:#555;">Sent from the dealer portal on ' ||
      to_char(o.created_at at time zone 'America/Chicago', 'Mon DD, YYYY at HH12:MI AM') || ' Central.</p>' ||
    '<table style="width:100%;border-collapse:collapse;font-size:14px;">' ||
    '<tr><td style="padding:4px 0;"><strong>Dealer</strong></td><td>' || coalesce(d.name, '') ||
      case when d.city is not null then ', ' || d.city || ', ' || coalesce(d.state, '') else '' end || '</td></tr>' ||
    '<tr><td style="padding:4px 0;"><strong>Contact</strong></td><td>' ||
      coalesce(o.contact_name, '') || ' ' || coalesce(o.contact_phone, '') || ' ' ||
      coalesce(o.contact_email, '') || '</td></tr>' ||
    case when o.po_number is not null then
      '<tr><td style="padding:4px 0;"><strong>Dealer PO</strong></td><td>' || o.po_number || '</td></tr>' else '' end ||
    case when o.needed_by is not null then
      '<tr><td style="padding:4px 0;"><strong>Needed by</strong></td><td>' ||
      to_char(o.needed_by, 'Mon DD, YYYY') || '</td></tr>' else '' end ||
    '</table>' ||
    '<table style="width:100%;border-collapse:collapse;margin-top:18px;font-size:14px;">' ||
    '<tr><th align="left" style="border-bottom:2px solid #111;padding:6px 10px;">Build</th>' ||
    '<th align="right" style="border-bottom:2px solid #111;padding:6px 10px;">Dealer total</th></tr>' ||
    coalesce(v_rows, '') ||
    '<tr><td style="padding:10px;text-align:right;"><strong>Subtotal</strong></td>' ||
    '<td style="padding:10px;text-align:right;"><strong>$' ||
      to_char(o.subtotal, 'FM999,999.00') || '</strong></td></tr>' ||
    '</table>' ||
    case when o.has_quote_items then
      '<p style="color:#a00;font-size:14px;">Some items need a factory quote. The subtotal covers the priced items only.</p>'
      else '' end ||
    case when o.notes is not null then
      '<p style="font-size:14px;"><strong>Notes from the dealer</strong><br>' || o.notes || '</p>' else '' end ||
    '<p style="font-size:13px;color:#777;margin-top:22px;">Prices are dealer net from the current price list. ' ||
    'This is a request, not a confirmed order. Call the dealer to confirm the build and the lead time.</p></div>';

  perform net.http_post(
    url     := 'https://api.resend.com/emails',
    headers := jsonb_build_object('Content-Type', 'application/json',
                                  'Authorization', 'Bearer ' || v_key),
    body    := jsonb_build_object(
                 'from', v_from,
                 'to', string_to_array(v_to, ','),
                 'reply_to', coalesce(o.contact_email, d.email, split_part(v_to, ',', 1)),
                 'subject', v_subject,
                 'html', v_html));
end $$;

revoke all on function public.notify_order(uuid) from public, anon, authenticated;

-- ===========================================================================
-- 8. Convenience view for the office
-- ===========================================================================

-- security_invoker keeps row level security in force for whoever queries it.
create or replace view order_summary with (security_invoker = true) as
  select o.order_no, o.created_at, o.status, d.name as dealer,
         d.city, d.state, o.contact_name, o.contact_phone, o.po_number,
         o.needed_by, o.item_count, o.subtotal, o.has_quote_items, o.notes
    from orders o join dealers d on d.id = o.dealer_id
   order by o.created_at desc;
