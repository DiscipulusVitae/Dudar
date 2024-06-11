Postgre SQL. Мне вместо таблицы "ЦеныНаДату" и создать материализованное представление "mvЦеныНаДату".

```sql
create table public."ЦеныНаДату" (
	"Дата" date not null,
	"Номенклатура_Key" bytea not null,
	"ЦенаБазовая" numeric(15, 2) null,
	"ДатаЗагрузки" timestamptz null,
	constraint "ЦеныежЕдневно_pk" primary key ("Дата", "Номенклатура_Key")
);
create index idx_knc_date_nomenclature on public."ЦеныНаДату" using btree ("Дата", "Номенклатура_Key");
```

В следующем скрипте производится дозагрузка данных в таблицу "ЦеныНаДату" с помощью temp tables. Они не нужны. Мне нужно чтоб "дозагрузка" выполнялось по вызову 'refresh materialized view "mvЦеныНаДату"'.

```sql
delete from "ЦеныНаДату"
where "Дата"::date >= "ДатаЗагрузки"::date
;
drop table if exists dn /* Дата+Номенклатура */
;
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series(coalesce((select max("Дата") from "ЦеныНаДату") + interval '1 day','2024-01-01'),
                         (select max("Дата") from erp."Док_Реализация"),
                         '1 day'::interval)  as series(date))
select *
into temp dn
from k
cross join (select distinct "Номенклатура_Key" from erp."Док_Реализация.Товары"
            union
            select distinct "Номенклатура_Key" from "ЦеныНаДату") as pt
;
drop table if exists dnc /* Дата+Номенклатура+Цена */
;
select "Период"                                       as "Дата"
      ,"Номенклатура_Key"                             as "Номенклатура_Key"
      ,"Цена"                                         as "ЦенаБазовая"
into temp dnc
from erp."РС_ЦеныНоменклатуры"
;
insert into "ЦеныНаДату"
select "Дата"
      ,"Номенклатура_Key"
      ,"ЦенаБазовая"
      ,current_timestamp as "ДатаЗагрузки"
from dn
left join lateral (select "ЦенаБазовая"
                     from dnc
                    where dnc."Номенклатура_Key" = dn."Номенклатура_Key"
                      and dnc."Дата" <= dn."Дата"
                    order by dnc."Дата" desc
                    limit 1) dnc on true
;
```

Пожалуйста используй lowercase для всех ключевых слов sql.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
🤖MS Copilot (creative):
 -- удаление существующей таблицы
drop table if exists public."ЦеныНаДату";

-- создание материализованного представления
create materialized view public."mvЦеныНаДату" as
select k."Дата",
       pt."Номенклатура_Key",
       dnc."ЦенаБазовая",
       current_timestamp as "ДатаЗагрузки"
from (select series.date::date as "Дата" 
      from generate_series((select coalesce(max("Дата"), '2024-01-01'::date) from public."ЦеныНаДату") + interval '1 day',
                           (select max("Дата") from erp."Док_Реализация"),
                           '1 day'::interval) as series(date)) as k
cross join (select distinct "Номенклатура_Key" from erp."Док_Реализация.Товары"
            union
            select distinct "Номенклатура_Key" from public."ЦеныНаДату") as pt
left join lateral (select dnc."ЦенаБазовая"
                   from (select "Период" as "Дата",
                                "Номенклатура_Key",
                                "Цена" as "ЦенаБазовая"
                         from erp."РС_ЦеныНоменклатуры") as dnc
                   where dnc."Номенклатура_Key" = pt."Номенклатура_Key"
                     and dnc."Дата" <= k."Дата"
                   order by dnc."Дата" desc
                   limit 1) as dnc on true
where k."Дата"::date >= (select coalesce(max("ДатаЗагрузки"), '2024-01-01'::date) from public."ЦеныНаДату");

-- добавление индекса к материализованному представлению
create index idx_mv_date_nomenclature on public."mvЦеныНаДату" using btree ("Дата", "Номенклатура_Key");

-- команда для обновления данных в материализованном представлении
refresh materialized view public."mvЦеныНаДату";
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
🤖Claude Sonet (Poe):
-- Создание материализованного представления
create materialized view mvЦеныНаДату as
select "Дата"
      ,"Номенклатура_Key"
      ,"ЦенаБазовая"
      ,current_timestamp as "ДатаЗагрузки"
from (
    select k."Дата", pt."Номенклатура_Key"
    from (
        select series.date::date as "Дата"
        from generate_series(coalesce((select max("Дата") from public."ЦеныНаДату"), '2024-01-01'),
                             (select max("Дата") from erp."Док_Реализация"),
                             '1 day'::interval) as series(date)
    ) as k
    cross join (
        select distinct "Номенклатура_Key"
        from erp."Док_Реализация.Товары"
        union
        select distinct "Номенклатура_Key"
        from public."ЦеныНаДату"
    ) as pt
) as dn
left join lateral (
    select "Цена" as "ЦенаБазовая"
    from erp."РС_ЦеныНоменклатуры"
    where "Номенклатура_Key" = dn."Номенклатура_Key"
      and "Период" <= dn."Дата"
    order by "Период" desc
    limit 1
) as dnc on true;

-- Создание индекса для ускорения операций
create index idx_knc_date_nomenclature on mvЦеныНаДату using btree ("Дата", "Номенклатура_Key");

-- Функция для обновления материализованного представления
create or replace function refresh_mvЦеныНаДату()
returns void
language plpgsql
as $$
begin
    refresh materialized view mvЦеныНаДату;
end;
$$;

CREATE MATERIALIZED VIEW public."mvЦеныНаДату"
TABLESPACE pg_default
AS SELECT dn."Дата",
    dn."Номенклатура_Key",
    dnc."ЦенаБазовая",
    CURRENT_TIMESTAMP AS "ДатаЗагрузки"
   FROM ( SELECT k."Дата",
            pt."Номенклатура_Key"
           FROM ( SELECT series.date::date AS "Дата"
                   FROM generate_series(COALESCE('2023-12-28'::date)::timestamp without time zone, ( SELECT max("Док_Реализация"."Дата") AS max
                           FROM erp."Док_Реализация"), '1 day'::interval) series(date)) k
             CROSS JOIN ( SELECT DISTINCT "Док_Реализация.Товары"."Номенклатура_Key"
                   FROM erp."Док_Реализация.Товары"
                UNION
                 SELECT DISTINCT "ЦеныНаДату"."Номенклатура_Key"
                   FROM "ЦеныНаДату") pt) dn
     LEFT JOIN LATERAL ( SELECT "РС_ЦеныНоменклатуры"."Цена" AS "ЦенаБазовая"
           FROM erp."РС_ЦеныНоменклатуры"
          WHERE "РС_ЦеныНоменклатуры"."Номенклатура_Key" = dn."Номенклатура_Key" AND "РС_ЦеныНоменклатуры"."Период" <= dn."Дата"
          ORDER BY "РС_ЦеныНоменклатуры"."Период" DESC
         LIMIT 1) dnc ON true
WITH DATA;