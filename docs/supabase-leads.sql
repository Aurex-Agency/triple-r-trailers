-- Triple R Trailers: the public forms actually send.
-- Run AFTER docs/supabase-orders.sql. Safe to re-run.
--
-- Until now Get a Quote, Become a Dealer, Parts Request, and Request Access all
-- opened the visitor's email app with the message pre-filled and waited for
-- them to press send themselves. On a phone with no mail app set up, or a
-- desktop where mail lives in a browser tab, that does nothing at all, and the
-- lead is gone with nobody knowing it existed. This takes the submission
-- straight to the factory instead, and keeps a copy either way.
--
-- The address these go to is fixed in app_settings. Nothing a visitor types can
-- change where the mail is sent, so this cannot be turned into a way to send
-- mail to anyone else.

do $$
begin
  if to_regclass('public.app_settings') is null then
    raise exception 'Run docs/supabase-orders.sql first, then this file.';
  end if;
end $$;

-- Defined identically in docs/supabase-dealer-receipt.sql. Repeated here so
-- these two files can be run in either order.
create or replace function public.html_escape(s text)
returns text language sql immutable as $$
  select replace(replace(replace(replace(coalesce(s, ''),
    '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;');
$$;

-- ===========================================================================
-- 1. Every enquiry, kept
-- ===========================================================================
--
-- The email is what the office acts on. This table is the safety net: if a
-- send ever fails, or somebody deletes the wrong thing in a mailbox, the
-- enquiry is still here.

create table if not exists leads (
  id         uuid primary key default gen_random_uuid(),
  kind       text not null,
  name       text,
  email      text,
  phone      text,
  fields     jsonb not null default '{}',
  page       text,
  emailed    boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists leads_created_idx on leads (created_at desc);

alter table leads enable row level security;

-- Office staff can read them. Nobody can write through the API; the only way
-- in is submit_lead() below, which is what enforces the limits.
drop policy if exists "staff read leads" on leads;
create policy "staff read leads" on leads for select to authenticated
  using (is_staff());

-- ===========================================================================
-- 2. submit_lead: the only way an enquiry is created
-- ===========================================================================
--
-- {
--   "kind": "Quote Request",
--   "page": "contact.html",
--   "company_website": "",          <- honeypot, must stay empty
--   "fields": { "Name": "...", "Phone": "...", "Email": "...", "Message": "..." }
-- }

create or replace function public.submit_lead(payload jsonb)
returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_kind text; v_page text; v_fields jsonb; v_trap text;
  v_name text; v_email text; v_phone text;
  v_key text; v_to text; v_from text;
  v_rows text; v_html text; v_lead leads%rowtype;
begin
  v_kind := left(trim(coalesce(payload ->> 'kind', 'Website Enquiry')), 80);
  v_page := left(trim(coalesce(payload ->> 'page', '')), 120);
  v_trap := trim(coalesce(payload ->> 'company_website', ''));
  v_fields := coalesce(payload -> 'fields', '{}'::jsonb);

  -- A real visitor never sees the honeypot field, so anything in it came from
  -- a bot. Answer as if it worked and quietly drop it, rather than telling the
  -- bot what gave it away.
  if v_trap <> '' then
    return jsonb_build_object('ok', true);
  end if;

  if jsonb_typeof(v_fields) <> 'object' then
    raise exception 'That form did not come through right. Call the office at (662) 728-7975.';
  end if;

  -- Pull the three things the office needs at a glance. The form field names
  -- are the human labels, so match on those, case insensitively.
  select max(case when lower(k) = 'name' then left(v, 200) end),
         max(case when lower(k) = 'email' then left(v, 200) end),
         max(case when lower(k) = 'phone' then left(v, 60) end)
    into v_name, v_email, v_phone
    from jsonb_each_text(v_fields) as f(k, v);

  if coalesce(trim(coalesce(v_name, '')), '') = ''
     and coalesce(trim(coalesce(v_phone, '')), '') = ''
     and coalesce(trim(coalesce(v_email, '')), '') = '' then
    raise exception 'Please leave a name and a phone number or an email so we can get back to you.';
  end if;

  -- Something that is not an address should not end up in a reply-to header.
  if v_email is not null and v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then
    v_email := null;
  end if;

  -- Two limits, both cheap. The first stops a double tap on a slow phone from
  -- landing twice. The second stops anyone hammering the form from flooding
  -- the office or burning the email quota.
  if exists (select 1 from leads
              where created_at > now() - interval '45 seconds'
                and kind = v_kind
                and coalesce(lower(email), '') = coalesce(lower(v_email), '')
                and coalesce(phone, '') = coalesce(v_phone, '')) then
    return jsonb_build_object('ok', true, 'duplicate', true);
  end if;

  if (select count(*) from leads where created_at > now() - interval '1 minute') >= 12 then
    raise exception 'The form is busy right now. Please call the office at (662) 728-7975.';
  end if;

  insert into leads (kind, name, email, phone, fields, page)
  values (v_kind, v_name, v_email, v_phone,
          -- keep every answer, but never let one field run away
          (select coalesce(jsonb_object_agg(left(k, 80), left(v, 4000)), '{}'::jsonb)
             from jsonb_each_text(v_fields) as f(k, v)
            where trim(v) <> ''),
          nullif(v_page, ''))
  returning * into v_lead;

  -- ---- the email ---------------------------------------------------------
  select value into v_key  from app_settings where key = 'resend_api_key';
  select value into v_to   from app_settings where key = 'order_email_to';
  select value into v_from from app_settings where key = 'order_email_from';
  if v_key is null or v_to is null then
    return jsonb_build_object('ok', true, 'emailed', false);
  end if;
  v_from := coalesce(v_from, 'Triple R Trailers <onboarding@resend.dev>');

  select string_agg(
    '<tr><td style="padding:7px 12px 7px 0;border-bottom:1px solid #e2e2e2;vertical-align:top;white-space:nowrap;">' ||
      '<strong>' || html_escape(k) || '</strong></td>' ||
    '<td style="padding:7px 0;border-bottom:1px solid #e2e2e2;">' ||
      replace(html_escape(v), chr(10), '<br>') || '</td></tr>',
    '' order by k)
    into v_rows
    from jsonb_each_text(v_lead.fields) as f(k, v);

  v_html :=
    '<div style="font-family:Arial,Helvetica,sans-serif;max-width:640px;color:#111;">' ||
    '<h2 style="margin:0 0 4px;">' || html_escape(v_kind) || '</h2>' ||
    '<p style="margin:0 0 18px;color:#555;font-size:14px;">From the website on ' ||
      to_char(v_lead.created_at at time zone 'America/Chicago', 'Mon DD, YYYY at HH12:MI AM') ||
      ' Central' || case when v_page <> '' then ', on ' || html_escape(v_page) else '' end || '.</p>' ||
    '<table style="width:100%;border-collapse:collapse;font-size:14px;">' ||
      coalesce(v_rows, '') || '</table>' ||
    case when v_email is not null then
      '<p style="font-size:14px;margin-top:18px;">Hit reply and it goes straight back to them.</p>'
      else '<p style="font-size:14px;margin-top:18px;color:#a00;">No email address on this one. ' ||
           'Call them back on the number above.</p>' end ||
    '</div>';

  perform net.http_post(
    url     := 'https://api.resend.com/emails',
    headers := jsonb_build_object('Content-Type', 'application/json',
                                  'Authorization', 'Bearer ' || v_key),
    body    := jsonb_build_object(
                 'from', v_from,
                 -- fixed, from settings. A visitor cannot redirect this.
                 'to', string_to_array(v_to, ','),
                 'reply_to', coalesce(v_email, split_part(v_to, ',', 1)),
                 'subject', v_kind || ' from ' ||
                            coalesce(nullif(trim(coalesce(v_name, '')), ''), 'the website'),
                 'html', v_html));

  update leads set emailed = true where id = v_lead.id;
  return jsonb_build_object('ok', true, 'emailed', true);
end $$;

-- The whole point is that a visitor who is not signed in can use it.
revoke all on function public.submit_lead(jsonb) from public;
grant execute on function public.submit_lead(jsonb) to anon, authenticated;

-- ===========================================================================
-- 3. For the office
-- ===========================================================================

create or replace view lead_summary with (security_invoker = true) as
  select created_at, kind, name, phone, email, page, emailed, fields
    from leads
   order by created_at desc;
