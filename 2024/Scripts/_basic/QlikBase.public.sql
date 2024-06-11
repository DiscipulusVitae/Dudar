create or replace procedure refresh_all_materialized_views()
language plpgsql
as $$
declare
  r record;
begin
  for r in select matviewname from pg_matviews where schemaname = 'public'
  loop
    execute format('refresh materialized view public.%I', r.matviewname);
  end loop;
end;
$$
;
call refresh_all_materialized_views()
;