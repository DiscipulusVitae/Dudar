with base (idx, value) as (
    values (1, 100),
           (2, null),
           (3, null),
           (4, null),
           (5, null),
           (6, null),
           (7, null),
           (8, 200),
           (9, null)
)
select idx
     ,value
--     ,count(value) over (order by idx)
     ,json_agg(value) filter (where value notnull) over (order by idx) ->> -1
     ,(json_agg(value) filter (where value notnull) over (order by idx) ->> -1)::int
     ,(array_remove(array_agg(value) over (order by idx), null))
     ,(array_remove(array_agg(value) over (order by idx), null))[-1]
     ,(array_agg(value) filter (where value notnull) over (order by idx))
     ,(array_remove(array_agg(value) over (order by idx), null))[count(value) over (order by idx)]
     ,count(value) over (order by idx) as grp
     ,coalesce(value
              ,last_value(value) over (order by case when value is null then -1
                                                 else idx
                                                 end)) as value1
     ,last_value(value) over (order by idx rows unbounded preceding) as value2
     ,last_value(value) over (order by idx rows between unbounded preceding and current row) as value3
     ,first_value(value) over (order by idx desc rows unbounded preceding) as value4
     ,first_value(value) over (order by idx desc rows between unbounded preceding and current row) as value5
     ,(SELECT last_value(value) OVER (ORDER BY idx)
        FROM base b2
        WHERE b.idx = b2.idx AND b2.value IS NOT NULL) AS result
     ,COALESCE(value, (
           SELECT value
           FROM base b2
           WHERE b.idx = b2.idx AND b2.value IS NOT NULL
           ORDER BY b2.idx
           LIMIT 1
       )) AS result
from base b
order by idx
;
--answered Jun 24, 2019 at 4:51 Fact's user avatar
with base as (
select 1    as idx , 2    as value   union
select 2    as idx, -14   as value   union
select 3    as idx , null as value   union
select 4    as idx , null as value   union
select 5    as idx , 1    as value
)
select idx, value, first_value(value) over (partition by rn) as new_val
from(
select idx,value
    ,sum(case when value is not null then 1 end) over (order by idx) as rn
  from   base
) t
;
--
select version()