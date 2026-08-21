-- Triple R Trailers: the dealer gets a copy of what they sent.
-- Run AFTER docs/supabase-orders.sql and docs/supabase-parts.sql. Safe to re-run.
--
-- Until now only the factory got an email. The dealer clicked send, saw a
-- confirmation on screen, and had nothing in their inbox to point at. This
-- sends them their own copy: the request number, everything they specced, and
-- what happens next. Replies go to the office.
--
-- It hangs off the event row that submit_order() and submit_part_request()
-- write when a request comes in, which is the moment every line item and the
-- totals are already saved. Nothing in those two functions changes.

do $$
begin
  if to_regclass('public.order_events') is null then
    raise exception 'Run docs/supabase-orders.sql first, then this file.';
  end if;
  if to_regclass('public.part_request_events') is null then
    raise exception 'Run docs/supabase-parts.sql first, then this file.';
  end if;
end $$;

-- ===========================================================================
-- 1. Settings
-- ===========================================================================
--
-- site_url is used for the link back to My Requests. dealer_receipt is an off
-- switch if the office ever decides these are noise; leave it alone and the
-- receipts are on.

insert into app_settings (key, value) values
  ('site_url', 'https://triplertrailers.com')
on conflict (key) do nothing;

-- ===========================================================================
-- 2. Anything a dealer typed goes back out as text, not as markup
-- ===========================================================================

create or replace function public.html_escape(s text)
returns text language sql immutable as $$
  select replace(replace(replace(replace(coalesce(s, ''),
    '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;');
$$;

-- ===========================================================================
-- 3. The trailer order receipt
-- ===========================================================================

create or replace function public.notify_order_receipt(p_order uuid)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare
  v_key text; v_from text; v_office text; v_site text; v_on text;
  o orders%rowtype; d dealers%rowtype;
  v_to text; v_rows text; v_html text;
begin
  select value into v_on from app_settings where key = 'dealer_receipt';
  if lower(coalesce(v_on, 'on')) in ('off', 'false', 'no', '0') then return; end if;

  select value into v_key    from app_settings where key = 'resend_api_key';
  select value into v_from   from app_settings where key = 'order_email_from';
  select value into v_office from app_settings where key = 'order_email_to';
  select value into v_site   from app_settings where key = 'site_url';
  if v_key is null then return; end if;
  v_from := coalesce(v_from, 'Triple R Trailers <onboarding@resend.dev>');
  v_site := coalesce(v_site, 'https://triplertrailers.com');

  select * into o from orders  where id = p_order;
  select * into d from dealers where id = o.dealer_id;

  -- Where it goes: whoever they said to call back, then the dealership on file.
  v_to := coalesce(nullif(trim(coalesce(o.contact_email, '')), ''),
                   nullif(trim(coalesce(d.email, '')), ''));
  if v_to is null then return; end if;

  select string_agg(
    '<tr><td style="padding:9px 10px;border-bottom:1px solid #e2e2e2;">' ||
      '<strong>' || i.qty || ' x ' || html_escape(coalesce(i.line_name, '')) || ' ' ||
        html_escape(i.model_label) || '</strong>' ||
      case when i.variant_label is not null and i.variant_label <> 'Standard'
           then ' <em>(' || html_escape(i.variant_label) || ')</em>' else '' end ||
      case when jsonb_array_length(i.options) > 0 then
        '<br><span style="font-size:13px;color:#555;">' ||
        (select string_agg(html_escape(coalesce(x->>'label', '')) ||
                 case when x->>'qty' is not null then ' x' || html_escape(x->>'qty') else '' end,
                 '<br>')
           from jsonb_array_elements(i.options) x) || '</span>'
        else '' end ||
      case when i.notes is not null
           then '<br><span style="font-size:13px;color:#555;">Your note: ' ||
                html_escape(i.notes) || '</span>'
           else '' end ||
    '</td><td style="padding:9px 10px;border-bottom:1px solid #e2e2e2;text-align:right;white-space:nowrap;">' ||
      case when i.line_total is not null
           then '$' || to_char(i.line_total, 'FM999,999.00')
           else 'We will quote it' end ||
    '</td></tr>', '' order by i.sort)
    into v_rows from order_items i where i.order_id = p_order;

  v_html :=
    '<div style="font-family:Arial,Helvetica,sans-serif;max-width:680px;color:#111;">' ||
    '<p style="margin:0 0 6px;font-size:13px;letter-spacing:1px;text-transform:uppercase;color:#c1121f;">' ||
      'Triple R Trailers</p>' ||
    '<h2 style="margin:0 0 6px;">We have your request, ' || o.order_no || '</h2>' ||
    '<p style="margin:0 0 20px;font-size:15px;line-height:1.6;color:#333;">Thanks ' ||
      html_escape(coalesce(split_part(o.contact_name, ' ', 1), 'for the order')) ||
      '. This came into the factory on ' ||
      to_char(o.created_at at time zone 'America/Chicago', 'Mon DD, YYYY at HH12:MI AM') ||
      ' Central. Nothing has been charged. Somebody from the office will call you to confirm the ' ||
      'build and the lead time before anything gets welded.</p>' ||

    '<table style="width:100%;border-collapse:collapse;font-size:14px;">' ||
    '<tr><td style="padding:4px 0;width:120px;"><strong>Dealership</strong></td><td>' ||
      html_escape(coalesce(d.name, '')) || '</td></tr>' ||
    case when o.po_number is not null then
      '<tr><td style="padding:4px 0;"><strong>Your PO</strong></td><td>' ||
      html_escape(o.po_number) || '</td></tr>' else '' end ||
    case when o.needed_by is not null then
      '<tr><td style="padding:4px 0;"><strong>Needed by</strong></td><td>' ||
      to_char(o.needed_by, 'Mon DD, YYYY') || '</td></tr>' else '' end ||
    '</table>' ||

    '<table style="width:100%;border-collapse:collapse;margin-top:20px;font-size:14px;">' ||
    '<tr><th align="left" style="border-bottom:2px solid #111;padding:6px 10px;">What you asked for</th>' ||
    '<th align="right" style="border-bottom:2px solid #111;padding:6px 10px;">Your price</th></tr>' ||
    coalesce(v_rows, '') ||
    '<tr><td style="padding:12px 10px;text-align:right;"><strong>Subtotal</strong></td>' ||
    '<td style="padding:12px 10px;text-align:right;"><strong>$' ||
      to_char(o.subtotal, 'FM999,999.00') || '</strong></td></tr>' ||
    '</table>' ||

    case when o.has_quote_items then
      '<p style="font-size:14px;color:#333;">Some of this needs a factory quote, so the subtotal ' ||
      'covers the priced items only. The quoted pieces come back on the callback.</p>'
      else '' end ||
    case when o.notes is not null then
      '<p style="font-size:14px;color:#333;"><strong>The note you left</strong><br>' ||
      html_escape(o.notes) || '</p>' else '' end ||

    '<p style="font-size:14px;line-height:1.6;color:#333;margin-top:22px;">' ||
    'You can see where this stands any time at <a href="' || v_site ||
      '/dealer-requests.html" style="color:#c1121f;">your requests page</a>. ' ||
    'Questions before then, call the office at (662) 728-7975, Monday to Friday, 7:00 to 3:30, ' ||
    'and give them ' || o.order_no || '.</p>' ||

    '<p style="font-size:12px;color:#888;margin-top:24px;border-top:1px solid #e2e2e2;padding-top:14px;">' ||
    'Prices shown are your dealer pricing from the current price list. This is a request, not a ' ||
    'purchase, and nothing is final until the office confirms it. Triple R Trailers, ' ||
    '82 County Road 1111, Booneville, MS 38829.</p></div>';

  perform net.http_post(
    url     := 'https://api.resend.com/emails',
    headers := jsonb_build_object('Content-Type', 'application/json',
                                  'Authorization', 'Bearer ' || v_key),
    body    := jsonb_build_object(
                 'from', v_from,
                 'to', array[v_to],
                 -- If they hit reply, it should reach the office, not a robot.
                 'reply_to', coalesce(split_part(v_office, ',', 1), 'triplertrailers@gmail.com'),
                 'subject', 'We have your order request ' || o.order_no || ' | Triple R Trailers',
                 'html', v_html));
end $$;

revoke all on function public.notify_order_receipt(uuid) from public, anon, authenticated;

-- ===========================================================================
-- 4. The parts receipt
-- ===========================================================================

create or replace function public.notify_part_receipt(p_req uuid)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare
  v_key text; v_from text; v_office text; v_site text; v_on text;
  r part_requests%rowtype; d dealers%rowtype;
  v_to text; v_rows text; v_html text;
begin
  select value into v_on from app_settings where key = 'dealer_receipt';
  if lower(coalesce(v_on, 'on')) in ('off', 'false', 'no', '0') then return; end if;

  select value into v_key    from app_settings where key = 'resend_api_key';
  select value into v_from   from app_settings where key = 'order_email_from';
  select value into v_office from app_settings where key = 'order_email_to';
  select value into v_site   from app_settings where key = 'site_url';
  if v_key is null then return; end if;
  v_from := coalesce(v_from, 'Triple R Trailers <onboarding@resend.dev>');
  v_site := coalesce(v_site, 'https://triplertrailers.com');

  select * into r from part_requests where id = p_req;
  select * into d from dealers       where id = r.dealer_id;

  v_to := coalesce(nullif(trim(coalesce(r.contact_email, '')), ''),
                   nullif(trim(coalesce(d.email, '')), ''));
  if v_to is null then return; end if;

  select string_agg(
    '<tr><td style="padding:9px 10px;border-bottom:1px solid #e2e2e2;white-space:nowrap;">' ||
      '<strong>' || i.qty || '</strong></td>' ||
    '<td style="padding:9px 10px;border-bottom:1px solid #e2e2e2;">' ||
      html_escape(i.description) ||
      case when i.trailer_ref is not null
           then '<br><span style="font-size:13px;color:#555;">For: ' ||
                html_escape(i.trailer_ref) || '</span>'
           else '' end ||
      case when i.notes is not null
           then '<br><span style="font-size:13px;color:#555;">Your note: ' ||
                html_escape(i.notes) || '</span>'
           else '' end ||
    '</td></tr>', '' order by i.sort)
    into v_rows from part_request_items i where i.request_id = p_req;

  v_html :=
    '<div style="font-family:Arial,Helvetica,sans-serif;max-width:680px;color:#111;">' ||
    '<p style="margin:0 0 6px;font-size:13px;letter-spacing:1px;text-transform:uppercase;color:#c1121f;">' ||
      'Triple R Trailers</p>' ||
    '<h2 style="margin:0 0 6px;">We have your parts request, ' || r.req_no || '</h2>' ||
    '<p style="margin:0 0 20px;font-size:15px;line-height:1.6;color:#333;">Thanks ' ||
      html_escape(coalesce(split_part(r.contact_name, ' ', 1), 'for the request')) ||
      '. This came into the parts desk on ' ||
      to_char(r.created_at at time zone 'America/Chicago', 'Mon DD, YYYY at HH12:MI AM') ||
      ' Central. Parts are not priced in the portal, so the office confirms the part and the ' ||
      'price with you, then ships it or holds it for pickup.</p>' ||

    '<table style="width:100%;border-collapse:collapse;font-size:14px;">' ||
    '<tr><td style="padding:4px 0;width:120px;"><strong>Dealership</strong></td><td>' ||
      html_escape(coalesce(d.name, '')) || '</td></tr>' ||
    case when r.po_number is not null then
      '<tr><td style="padding:4px 0;"><strong>Your PO</strong></td><td>' ||
      html_escape(r.po_number) || '</td></tr>' else '' end ||
    case when r.needed_by is not null then
      '<tr><td style="padding:4px 0;"><strong>Needed by</strong></td><td>' ||
      to_char(r.needed_by, 'Mon DD, YYYY') || '</td></tr>' else '' end ||
    '</table>' ||

    '<table style="width:100%;border-collapse:collapse;margin-top:20px;font-size:14px;">' ||
    '<tr><th align="left" style="border-bottom:2px solid #111;padding:6px 10px;">Qty</th>' ||
    '<th align="left" style="border-bottom:2px solid #111;padding:6px 10px;">What you asked for</th></tr>' ||
    coalesce(v_rows, '') || '</table>' ||

    case when r.notes is not null then
      '<p style="font-size:14px;color:#333;"><strong>The note you left</strong><br>' ||
      html_escape(r.notes) || '</p>' else '' end ||

    '<p style="font-size:14px;line-height:1.6;color:#333;margin-top:22px;">' ||
    'You can see where this stands any time at <a href="' || v_site ||
      '/dealer-requests.html" style="color:#c1121f;">your requests page</a>. ' ||
    'Need it sooner, call the shop at (662) 728-7975, Monday to Friday, 7:00 to 3:30, ' ||
    'and give them ' || r.req_no || '.</p>' ||

    '<p style="font-size:12px;color:#888;margin-top:24px;border-top:1px solid #e2e2e2;padding-top:14px;">' ||
    'Nothing here is a quote and nothing has been charged. Triple R Trailers, ' ||
    '82 County Road 1111, Booneville, MS 38829.</p></div>';

  perform net.http_post(
    url     := 'https://api.resend.com/emails',
    headers := jsonb_build_object('Content-Type', 'application/json',
                                  'Authorization', 'Bearer ' || v_key),
    body    := jsonb_build_object(
                 'from', v_from,
                 'to', array[v_to],
                 'reply_to', coalesce(split_part(v_office, ',', 1), 'triplertrailers@gmail.com'),
                 'subject', 'We have your parts request ' || r.req_no || ' | Triple R Trailers',
                 'html', v_html));
end $$;

revoke all on function public.notify_part_receipt(uuid) from public, anon, authenticated;

-- ===========================================================================
-- 5. When they go out
-- ===========================================================================
--
-- submit_order() writes a 'submitted' event as its last step, after every line
-- item and both totals are saved, so that row is the right moment to send. It
-- also means submit_order() itself does not have to change.
--
-- Only the first event on a request triggers a receipt. If the office ever
-- moves a status back to submitted, the dealer does not get a second copy.
--
-- The send is wrapped: a receipt that fails must never roll back an order that
-- is already saved.

create or replace function public.order_receipt_trigger()
returns trigger language plpgsql security definer set search_path = public, extensions as $$
begin
  if new.status <> 'submitted' then return new; end if;
  if exists (select 1 from order_events e
              where e.order_id = new.order_id and e.id <> new.id) then
    return new;
  end if;
  begin
    perform notify_order_receipt(new.order_id);
  exception when others then
    raise notice 'Order saved, but the dealer receipt failed: %', sqlerrm;
  end;
  return new;
end $$;

drop trigger if exists order_receipt on order_events;
create trigger order_receipt after insert on order_events
  for each row execute function order_receipt_trigger();

create or replace function public.part_receipt_trigger()
returns trigger language plpgsql security definer set search_path = public, extensions as $$
begin
  if new.status <> 'submitted' then return new; end if;
  if exists (select 1 from part_request_events e
              where e.request_id = new.request_id and e.id <> new.id) then
    return new;
  end if;
  begin
    perform notify_part_receipt(new.request_id);
  exception when others then
    raise notice 'Parts request saved, but the dealer receipt failed: %', sqlerrm;
  end;
  return new;
end $$;

drop trigger if exists part_receipt on part_request_events;
create trigger part_receipt after insert on part_request_events
  for each row execute function part_receipt_trigger();

-- ===========================================================================
-- 6. Turning them off, if it ever comes to that
-- ===========================================================================
--
--   insert into app_settings (key, value) values ('dealer_receipt', 'off')
--   on conflict (key) do update set value = excluded.value;
--
-- and 'on' to turn them back on. The factory email is unaffected either way.
