-- Triple R Trailers dealer portal: storage setup
-- Run once in the Supabase SQL Editor. Safe to re-run.

-- Private bucket for dealer documents
insert into storage.buckets (id, name, public)
values ('dealer-docs', 'dealer-docs', false)
on conflict (id) do nothing;

-- Signed-in dealers can read documents in the bucket.
-- Nobody can upload, change, or delete through the website;
-- the office manages files from the Supabase dashboard.
drop policy if exists "Dealers can read dealer docs" on storage.objects;
create policy "Dealers can read dealer docs"
on storage.objects for select
to authenticated
using (bucket_id = 'dealer-docs');
