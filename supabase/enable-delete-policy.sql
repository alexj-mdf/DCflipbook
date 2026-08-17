-- Run this once in Supabase Dashboard → SQL Editor.
--
-- Diagnosis: the admin panel's new Delete/bulk-delete feature sends a correct
-- DELETE request, and Supabase returns HTTP 200 for it — but 0 rows actually
-- get deleted. This is Row Level Security silently blocking the delete: the
-- `quotes` table already has RLS policies letting the anon (publishable) key
-- SELECT/INSERT/UPDATE (that's how "hide" and saving quotes already work),
-- but no policy exists that allows DELETE for that role, so PostgREST filters
-- the delete down to zero matching rows before it can run — no error, just a
-- silent no-op.
--
-- This grants the same anon role a DELETE policy, matching the access level
-- the admin panel already effectively has for everything else. The admin
-- panel has no login of its own (it relies on the URL being unlisted), so
-- this doesn't reduce security beyond what's already true for hide/edit.

create policy "Allow anon delete on quotes"
on public.quotes
for delete
to anon
using (true);
