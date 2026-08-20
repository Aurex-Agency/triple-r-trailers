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

create or replace function public.admin_recent_requests(p_limit int default 30)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_out jsonb; v_lim int := least(greatest(coalesce(p_limit, 30), 1), 200);
begin
  if not is_staff() then
    raise exception 'This page is for Triple R office staff only.' using errcode = '42501';
  end if;

  with trailers as (
    select jsonb_build_object(
             'kind', 'trailer', 'id', o.id, 'no', o.order_no, 'created_at', o.created_at,
             'status', o.status, 'dealer', d.name, 'city', d.city, 'state', d.state,
             'contact', o.contact_name, 'phone', o.contact_phone, 'email', o.contact_email,
             'po', o.po_number, 'needed_by', o.needed_by, 'items', o.item_count,
             'total', o.subtotal, 'quote', o.has_quote_items, 'notes', o.notes) as j,
           o.created_at
      from orders o join dealers d on d.id = o.dealer_id
     order by o.created_at desc
     limit v_lim
  ), parts as (
    select jsonb_build_object(
             'kind', 'parts', 'id', p.id, 'no', p.req_no, 'created_at', p.created_at,
             'status', p.status, 'dealer', d.name, 'city', d.city, 'state', d.state,
             'contact', p.contact_name, 'phone', p.contact_phone, 'email', p.contact_email,
             'po', p.po_number, 'needed_by', p.needed_by, 'items', p.item_count,
             'total', null, 'quote', false, 'notes', p.notes) as j,
           p.created_at
      from part_requests p join dealers d on d.id = p.dealer_id
     order by p.created_at desc
     limit v_lim
  )
  select coalesce(jsonb_agg(j order by created_at desc), '[]'::jsonb)
    into v_out
    from (select j, created_at from trailers
          union all
          select j, created_at from parts) both_kinds;

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
    'admin_recent_requests(int)',
    'admin_set_status(text, uuid, text)']
  loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
