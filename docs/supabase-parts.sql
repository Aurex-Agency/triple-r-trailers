-- Triple R Trailers: dealer parts requests.
-- Run AFTER docs/supabase-orders.sql. Safe to re-run.
--
-- Parts have no published dealer price list, so this collects what the dealer
-- needs and routes it to the office, which confirms the part and the price on
-- the callback. Same security model as trailer orders: a dealership sees only
-- its own requests, only staff can change status, and rows are created solely
-- through submit_part_request().

create sequence if not exists part_req_no_seq start 500;

create table if not exists part_requests (
  id            uuid primary key default gen_random_uuid(),
  req_no        text unique not null default 'TRP-' || nextval('part_req_no_seq'),
  dealer_id     uuid not null references dealers (id) on delete restrict,
  submitted_by  uuid references auth.users (id) on delete set null,
  status        text not null default 'submitted'
                check (status in ('submitted', 'confirmed', 'shipped', 'ready', 'closed', 'cancelled')),
  contact_name  text,
  contact_phone text,
  contact_email text,
  po_number     text,
  needed_by     date,
  notes         text,
  item_count    int not null default 0,
  created_at    timestamptz not null default now()
);
create index if not exists part_requests_dealer_idx on part_requests (dealer_id, created_at desc);

create table if not exists part_request_items (
  id          uuid primary key default gen_random_uuid(),
  request_id  uuid not null references part_requests (id) on delete cascade,
  description text not null,
  trailer_ref text,
  qty         int not null default 1 check (qty > 0 and qty <= 999),
  notes       text,
  sort        int not null default 0
);
create index if not exists part_request_items_req_idx on part_request_items (request_id);

create table if not exists part_request_events (
  id         uuid primary key default gen_random_uuid(),
  request_id uuid not null references part_requests (id) on delete cascade,
  status     text not null,
  note       text,
  actor      uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);
create index if not exists part_request_events_req_idx on part_request_events (request_id, created_at);

-- ===========================================================================
-- Row level security
-- ===========================================================================

alter table part_requests       enable row level security;
alter table part_request_items  enable row level security;
alter table part_request_events enable row level security;

drop policy if exists "read own part requests" on part_requests;
create policy "read own part requests" on part_requests for select to authenticated
  using (dealer_id = current_dealer_id() or is_staff());

drop policy if exists "staff update part requests" on part_requests;
create policy "staff update part requests" on part_requests for update to authenticated
  using (is_staff()) with check (is_staff());

drop policy if exists "read own part items" on part_request_items;
create policy "read own part items" on part_request_items for select to authenticated
  using (exists (select 1 from part_requests r where r.id = request_id
                 and (r.dealer_id = current_dealer_id() or is_staff())));

drop policy if exists "read own part events" on part_request_events;
create policy "read own part events" on part_request_events for select to authenticated
  using (exists (select 1 from part_requests r where r.id = request_id
                 and (r.dealer_id = current_dealer_id() or is_staff())));

-- ===========================================================================
-- submit_part_request: the only way a parts request is created
-- ===========================================================================
--
-- {
--   "contact_name": "...", "contact_phone": "...", "contact_email": "...",
--   "po_number": "...", "needed_by": "2026-09-15", "notes": "...",
--   "items": [{"description": "Left fender, 7x16 enclosed",
--              "trailer_ref": "7X16 enclosed, 2024", "qty": 1, "notes": "black"}]
-- }

create or replace function public.submit_part_request(payload jsonb)
returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_dealer uuid := current_dealer_id();
  v_req    part_requests%rowtype;
  v_item   jsonb;
  v_desc   text;
  v_qty    int;
  v_sort   int := 0;
  v_count  int := 0;
begin
  if v_dealer is null then
    raise exception 'Your login is not linked to a dealership yet. Call the factory at (662) 728-7975.';
  end if;
  if payload->'items' is null or jsonb_array_length(payload->'items') = 0 then
    raise exception 'This request has no parts on it.';
  end if;
  if jsonb_array_length(payload->'items') > 40 then
    raise exception 'That is more than 40 lines. Send it in a couple of requests or call the office.';
  end if;

  insert into part_requests (dealer_id, submitted_by, contact_name, contact_phone,
                             contact_email, po_number, needed_by, notes)
  values (v_dealer, auth.uid(),
          nullif(trim(payload->>'contact_name'), ''),
          nullif(trim(payload->>'contact_phone'), ''),
          nullif(trim(payload->>'contact_email'), ''),
          nullif(trim(payload->>'po_number'), ''),
          nullif(payload->>'needed_by', '')::date,
          nullif(trim(payload->>'notes'), ''))
  returning * into v_req;

  for v_item in select * from jsonb_array_elements(payload->'items') loop
    v_desc := nullif(trim(v_item->>'description'), '');
    continue when v_desc is null;
    v_qty := greatest(1, least(999, coalesce((v_item->>'qty')::int, 1)));

    insert into part_request_items (request_id, description, trailer_ref, qty, notes, sort)
    values (v_req.id, left(v_desc, 400),
            left(nullif(trim(v_item->>'trailer_ref'), ''), 200),
            v_qty, left(nullif(trim(v_item->>'notes'), ''), 400), v_sort);

    v_count := v_count + 1;
    v_sort := v_sort + 10;
  end loop;

  if v_count = 0 then
    raise exception 'Every line was blank. Tell us at least one part you need.';
  end if;

  update part_requests set item_count = v_count where id = v_req.id returning * into v_req;

  insert into part_request_events (request_id, status, note, actor)
  values (v_req.id, 'submitted', 'Parts request sent from the dealer portal', auth.uid());

  -- A failing email must never lose the request.
  begin
    perform notify_part_request(v_req.id);
  exception when others then
    raise notice 'Request % saved, but the factory email failed: %', v_req.req_no, sqlerrm;
  end;

  return jsonb_build_object('id', v_req.id, 'req_no', v_req.req_no, 'item_count', v_req.item_count);
end $$;

revoke all on function public.submit_part_request(jsonb) from public, anon;
grant execute on function public.submit_part_request(jsonb) to authenticated;

-- ===========================================================================
-- Email the factory
-- ===========================================================================
-- Uses the same app_settings rows as trailer orders. Without them the request
-- still saves; only the email is skipped.

create or replace function public.notify_part_request(p_req uuid)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare
  v_key text; v_to text; v_from text;
  r part_requests%rowtype; d dealers%rowtype;
  v_rows text; v_html text;
begin
  select value into v_key  from app_settings where key = 'resend_api_key';
  select value into v_to   from app_settings where key = 'order_email_to';
  select value into v_from from app_settings where key = 'order_email_from';
  if v_key is null or v_to is null then return; end if;
  v_from := coalesce(v_from, 'Triple R Portal <onboarding@resend.dev>');

  select * into r from part_requests where id = p_req;
  select * into d from dealers where id = r.dealer_id;

  select string_agg(
    '<tr><td style="padding:8px 10px;border-bottom:1px solid #ddd;white-space:nowrap;"><strong>' ||
      i.qty || '</strong></td>' ||
    '<td style="padding:8px 10px;border-bottom:1px solid #ddd;">' || i.description ||
      case when i.trailer_ref is not null
           then '<br><span style="font-size:13px;color:#555;">For: ' || i.trailer_ref || '</span>'
           else '' end ||
      case when i.notes is not null
           then '<br><span style="font-size:13px;color:#a00;">Note: ' || i.notes || '</span>'
           else '' end ||
    '</td></tr>', '' order by i.sort)
    into v_rows from part_request_items i where i.request_id = p_req;

  v_html :=
    '<div style="font-family:Arial,Helvetica,sans-serif;max-width:680px;">' ||
    '<h2 style="margin:0 0 4px;">Parts request ' || r.req_no || '</h2>' ||
    '<p style="margin:0 0 18px;color:#555;">Sent from the dealer portal on ' ||
      to_char(r.created_at at time zone 'America/Chicago', 'Mon DD, YYYY at HH12:MI AM') || ' Central.</p>' ||
    '<table style="width:100%;border-collapse:collapse;font-size:14px;">' ||
    '<tr><td style="padding:4px 0;"><strong>Dealer</strong></td><td>' || coalesce(d.name, '') ||
      case when d.city is not null then ', ' || d.city || ', ' || coalesce(d.state, '') else '' end || '</td></tr>' ||
    '<tr><td style="padding:4px 0;"><strong>Contact</strong></td><td>' ||
      coalesce(r.contact_name, '') || ' ' || coalesce(r.contact_phone, '') || ' ' ||
      coalesce(r.contact_email, '') || '</td></tr>' ||
    case when r.po_number is not null then
      '<tr><td style="padding:4px 0;"><strong>Dealer PO</strong></td><td>' || r.po_number || '</td></tr>' else '' end ||
    case when r.needed_by is not null then
      '<tr><td style="padding:4px 0;"><strong>Needed by</strong></td><td>' ||
      to_char(r.needed_by, 'Mon DD, YYYY') || '</td></tr>' else '' end ||
    '</table>' ||
    '<table style="width:100%;border-collapse:collapse;margin-top:18px;font-size:14px;">' ||
    '<tr><th align="left" style="border-bottom:2px solid #111;padding:6px 10px;">Qty</th>' ||
    '<th align="left" style="border-bottom:2px solid #111;padding:6px 10px;">Part needed</th></tr>' ||
    coalesce(v_rows, '') || '</table>' ||
    case when r.notes is not null then
      '<p style="font-size:14px;"><strong>Notes from the dealer</strong><br>' || r.notes || '</p>' else '' end ||
    '<p style="font-size:13px;color:#777;margin-top:22px;">Parts are not priced in the portal. ' ||
    'Confirm the part and the price with the dealer, then ship it or hold it for pickup.</p></div>';

  perform net.http_post(
    url     := 'https://api.resend.com/emails',
    headers := jsonb_build_object('Content-Type', 'application/json',
                                  'Authorization', 'Bearer ' || v_key),
    body    := jsonb_build_object(
                 'from', v_from,
                 'to', string_to_array(v_to, ','),
                 'reply_to', coalesce(r.contact_email, d.email, split_part(v_to, ',', 1)),
                 'subject', 'Dealer parts request ' || r.req_no || ' from ' || coalesce(d.name, 'a dealer'),
                 'html', v_html));
end $$;

revoke all on function public.notify_part_request(uuid) from public, anon, authenticated;

-- ===========================================================================
-- Office view
-- ===========================================================================

create or replace view part_request_summary with (security_invoker = true) as
  select r.req_no, r.created_at, r.status, d.name as dealer, d.city, d.state,
         r.contact_name, r.contact_phone, r.po_number, r.needed_by,
         r.item_count, r.notes
    from part_requests r join dealers d on d.id = r.dealer_id
   order by r.created_at desc;
