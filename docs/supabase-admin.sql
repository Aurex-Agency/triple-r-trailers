-- Triple R Trailers: the office screen.
-- Run AFTER docs/supabase-orders.sql and docs/supabase-parts.sql. Safe to re-run.
--
-- Everything the office needs to do day to day happens on dealer-admin.html:
-- add a dealership, send a dealer their login, attach a login to a dealership,
-- cut a dealer off, and move a request along. This file is what that page
-- talks to. No Table Editor, no copying user ids by hand.
--
-- Every function here refuses to run unless the caller is listed in
-- staff_users, so a dealer who finds the page gets nothing from it.

do $$
begin
  if to_regclass('public.orders') is null then
    raise exception 'Run docs/supabase-orders.sql first, then this file.';
  end if;
  if to_regclass('public.part_requests') is null then
    raise exception 'Run docs/supabase-parts.sql first, then this file.';
  end if;
end $$;

-- ===========================================================================
-- 1. Close the gap that made "remove access" only half true
-- ===========================================================================
--
-- Until now any signed-in account could read the catalog and the documents,
-- whether or not it belonged to a dealership. That meant taking a dealer off
-- a dealership left them still able to see dealer pricing. Now access follows
-- the dealership link: no link, nothing to see. Office staff still see all.

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

drop policy if exists "Dealers can read dealer docs" on storage.objects;
create policy "Dealers can read dealer docs"
on storage.objects for select
to authenticated
using (bucket_id = 'dealer-docs' and (current_dealer_id() is not null or is_staff()));

-- Staff need to create and edit dealerships and memberships from the page.
-- The writes all run through the functions below, which check staff first,
-- so there is deliberately no insert or update policy for the browser here.

-- ===========================================================================
-- 2. Who is on the network
-- ===========================================================================

-- One call fills the whole page: every dealership, the logins attached to it,
-- and any login that is not attached to anything yet.
create or replace function public.admin_directory()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_out jsonb;
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;

  select jsonb_build_object(
    'dealers', coalesce((
      select jsonb_agg(row_json order by row_json ->> 'name')
        from (
          select jsonb_build_object(
                   'id',     d.id,
                   'name',   d.name,
                   'city',   d.city,
                   'state',  d.state,
                   'phone',  d.phone,
                   'email',  d.email,
                   'active', d.active,
                   'logins', coalesce((
                     select jsonb_agg(jsonb_build_object(
                              'user_id',   u.id,
                              'email',     u.email,
                              'full_name', m.full_name,
                              'signed_in', (u.last_sign_in_at is not null),
                              'last_seen', u.last_sign_in_at) order by u.email)
                       from dealer_members m
                       join auth.users u on u.id = m.user_id
                      where m.dealer_id = d.id), '[]'::jsonb),
                   'orders', (select count(*) from orders o where o.dealer_id = d.id),
                   'parts',  (select count(*) from part_requests p where p.dealer_id = d.id)
                 ) as row_json
            from dealers d
        ) s), '[]'::jsonb),

    'unlinked', coalesce((
      select jsonb_agg(jsonb_build_object(
               'user_id',   u.id,
               'email',     u.email,
               'signed_in', (u.last_sign_in_at is not null),
               'created_at', u.created_at) order by u.created_at desc)
        from auth.users u
       where not exists (select 1 from dealer_members m where m.user_id = u.id)
         and not exists (select 1 from staff_users  s where s.user_id = u.id)
    ), '[]'::jsonb),

    'staff', coalesce((
      select jsonb_agg(jsonb_build_object(
               'user_id', u.id, 'email', u.email, 'full_name', s.full_name) order by u.email)
        from staff_users s join auth.users u on u.id = s.user_id
    ), '[]'::jsonb)
  ) into v_out;

  return v_out;
end $$;

-- ===========================================================================
-- 3. Dealerships
-- ===========================================================================

-- Pass a null id to add a dealership, or an existing id to correct one.
create or replace function public.admin_save_dealer(
  p_id    uuid    default null,
  p_name  text    default null,
  p_city  text    default null,
  p_state text    default null,
  p_phone text    default null,
  p_email text    default null,
  p_active boolean default true)
returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;
  if coalesce(trim(p_name), '') = '' then
    raise exception 'The dealership needs a name.';
  end if;

  if p_id is null then
    insert into dealers (name, city, state, phone, email, active)
    values (trim(p_name), nullif(trim(coalesce(p_city, '')), ''),
            upper(nullif(trim(coalesce(p_state, '')), '')),
            nullif(trim(coalesce(p_phone, '')), ''),
            lower(nullif(trim(coalesce(p_email, '')), '')),
            coalesce(p_active, true))
    returning id into v_id;
  else
    update dealers
       set name   = trim(p_name),
           city   = nullif(trim(coalesce(p_city, '')), ''),
           state  = upper(nullif(trim(coalesce(p_state, '')), '')),
           phone  = nullif(trim(coalesce(p_phone, '')), ''),
           email  = lower(nullif(trim(coalesce(p_email, '')), '')),
           active = coalesce(p_active, true)
     where id = p_id
    returning id into v_id;
    if v_id is null then
      raise exception 'That dealership is no longer on the list.';
    end if;
  end if;

  return v_id;
end $$;

-- ===========================================================================
-- 4. Logins
-- ===========================================================================

-- Attaches an existing login to a dealership. The login has to exist first,
-- which is what the Create dealer login button (or an invite from the
-- dashboard) takes care of.
create or replace function public.admin_link_login(
  p_email     text,
  p_dealer_id uuid,
  p_full_name text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_user uuid; v_dealer text;
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;

  select name into v_dealer from dealers where id = p_dealer_id;
  if v_dealer is null then
    raise exception 'Pick a dealership first.';
  end if;

  select id into v_user from auth.users
   where lower(email) = lower(trim(coalesce(p_email, ''))) limit 1;
  if v_user is null then
    raise exception 'There is no login for % yet. Send the invite first, then attach it.', p_email;
  end if;
  if exists (select 1 from staff_users where user_id = v_user) then
    raise exception '% is an office login, so it already sees everything.', p_email;
  end if;

  insert into dealer_members (user_id, dealer_id, full_name)
  values (v_user, p_dealer_id, nullif(trim(coalesce(p_full_name, '')), ''))
  on conflict (user_id) do update
    set dealer_id = excluded.dealer_id,
        full_name = coalesce(excluded.full_name, dealer_members.full_name);

  return jsonb_build_object('user_id', v_user, 'email', lower(trim(p_email)), 'dealer', v_dealer);
end $$;

-- Takes a login off a dealership. The account still exists, it just has
-- nothing to see: no pricing, no documents, no ordering. Reattach any time.
create or replace function public.admin_unlink_login(p_user_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;
  delete from dealer_members where user_id = p_user_id;
end $$;

-- ===========================================================================
-- 5. Requests
-- ===========================================================================

-- The office list is not an archive. What matters is what has not been dealt
-- with yet, so the default view is only that, and everything else is a click
-- away. Without this the page becomes a wall of old orders within a season.
--
--   new     just came in, nobody has picked it up
--   working confirmed, in the shop, ready, shipped
--   done    delivered, closed, cancelled
--   all     everything
--
-- p_search matches a request number or a dealership name, so the office can
-- find one they were called about without scrolling.

drop function if exists public.admin_recent_requests(int);

create or replace function public.admin_request_counts()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_out jsonb;
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;

  with every as (
    select status from orders
    union all
    select status from part_requests
  )
  select jsonb_build_object(
           'new',     count(*) filter (where status = 'submitted'),
           'working', count(*) filter (where status in ('confirmed', 'in_build', 'ready', 'shipped')),
           'done',    count(*) filter (where status in ('delivered', 'closed', 'cancelled')),
           'all',     count(*))
    into v_out from every;

  return v_out;
end $$;

create or replace function public.admin_recent_requests(
  p_bucket text default 'new',
  p_search text default null,
  p_limit  int  default 25,
  p_offset int  default 0)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_out jsonb;
  v_lim int := least(greatest(coalesce(p_limit, 25), 1), 200);
  v_off int := greatest(coalesce(p_offset, 0), 0);
  v_q text := nullif(trim(coalesce(p_search, '')), '');
  v_bucket text := lower(coalesce(p_bucket, 'new'));
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;
  if v_bucket not in ('new', 'working', 'done', 'all') then
    v_bucket := 'new';
  end if;

  with everything as (
    select o.id, o.order_no as no, o.created_at, o.status, d.name as dealer,
           'trailer' as kind, d.city, d.state, o.contact_name, o.contact_phone,
           o.contact_email, o.po_number, o.needed_by, o.item_count,
           o.subtotal as total, o.has_quote_items as quote, o.notes
      from orders o join dealers d on d.id = o.dealer_id
    union all
    select p.id, p.req_no, p.created_at, p.status, d.name,
           'parts', d.city, d.state, p.contact_name, p.contact_phone,
           p.contact_email, p.po_number, p.needed_by, p.item_count,
           null::numeric, false, p.notes
      from part_requests p join dealers d on d.id = p.dealer_id
  ), matching as (
    select * from everything
     where (v_bucket = 'all'
            or (v_bucket = 'new'     and status = 'submitted')
            or (v_bucket = 'working' and status in ('confirmed', 'in_build', 'ready', 'shipped'))
            or (v_bucket = 'done'    and status in ('delivered', 'closed', 'cancelled')))
       and (v_q is null
            or no ilike '%' || v_q || '%'
            or dealer ilike '%' || v_q || '%'
            or coalesce(contact_name, '') ilike '%' || v_q || '%')
  ), picked as (
    select * from matching order by created_at desc limit v_lim offset v_off
  )
  select jsonb_build_object(
           'bucket', v_bucket,
           'offset', v_off,
           'total',  (select count(*) from matching),
           -- Counted rather than guessed from a full page, so an exact
           -- multiple of the page size does not offer a Show more that
           -- turns out to be empty.
           'more',   (select count(*) from matching) > v_off + (select count(*) from picked),
           'rows', coalesce((
             select jsonb_agg(jsonb_build_object(
                      'kind', kind, 'id', id, 'no', no, 'created_at', created_at,
                      'status', status, 'dealer', dealer, 'city', city, 'state', state,
                      'contact', contact_name, 'phone', contact_phone, 'email', contact_email,
                      'po', po_number, 'needed_by', needed_by, 'items', item_count,
                      'total', total, 'quote', quote, 'notes', notes) order by created_at desc)
               from picked), '[]'::jsonb))
    into v_out;

  return v_out;
end $$;

-- What the request is waiting on. Changing it here is what the dealer sees on
-- My Requests, so the office never has to call to say "it is in the shop".
create or replace function public.admin_set_status(
  p_kind   text,
  p_id     uuid,
  p_status text)
returns text
language plpgsql security definer set search_path = public as $$
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;

  if p_kind = 'trailer' then
    if p_status not in ('submitted', 'confirmed', 'in_build', 'ready', 'delivered', 'cancelled') then
      raise exception 'That is not a status a trailer order can be in.';
    end if;
    update orders set status = p_status where id = p_id;
    if not found then raise exception 'That order is no longer on the list.'; end if;
    insert into order_events (order_id, status, actor) values (p_id, p_status, auth.uid());

  elsif p_kind = 'parts' then
    if p_status not in ('submitted', 'confirmed', 'shipped', 'ready', 'closed', 'cancelled') then
      raise exception 'That is not a status a parts request can be in.';
    end if;
    update part_requests set status = p_status where id = p_id;
    if not found then raise exception 'That parts request is no longer on the list.'; end if;
    insert into part_request_events (request_id, status, actor) values (p_id, p_status, auth.uid());

  else
    raise exception 'Unknown request type.';
  end if;

  return p_status;
end $$;

-- ===========================================================================
-- 6. Who can call what
-- ===========================================================================
--
-- Signed-in accounts may call these; the staff check inside each one is what
-- actually decides. Nothing here is open to the public or to logged-out
-- visitors.

do $$
declare f text;
begin
  foreach f in array array[
    'admin_directory()',
    'admin_save_dealer(uuid, text, text, text, text, text, boolean)',
    'admin_link_login(text, uuid, text)',
    'admin_unlink_login(uuid)',
    'admin_request_counts()',
    'admin_recent_requests(text, text, int, int)',
    'admin_set_status(text, uuid, text)']
  loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
