drop materialized view if exists public."mvЦеныНаДату"
;
refresh materialized view public."mvЦеныНаДату"
;
create materialized view public."mvЦеныНаДату" --🤖Claude Sonet (Poe):
tablespace pg_default
as select dn."Дата",
    dn."Номенклатура_Key",
    dnc."ЦенаБазовая",
    current_timestamp as "ДатаЗагрузки"
   from ( select k."Дата",
            pt."Номенклатура_Key"
           from ( select series.date::date as "Дата"
                   from generate_series(coalesce('2023-12-28'::date)::timestamp without time zone, ( select max("Док_Реализация"."Дата") as max
                           from erp."Док_Реализация"), '1 day'::interval) series(date)) k
             cross join ( select distinct "Док_Реализация.Товары"."Номенклатура_Key"
                   from erp."Док_Реализация.Товары"
                union
                 select distinct "ЦеныНаДату"."Номенклатура_Key"
                   from "ЦеныНаДату") pt) dn
     left join lateral ( select "РС_ЦеныНоменклатуры"."Цена" as "ЦенаБазовая"
           from erp."РС_ЦеныНоменклатуры"
          where "РС_ЦеныНоменклатуры"."Номенклатура_Key" = dn."Номенклатура_Key" and "РС_ЦеныНоменклатуры"."Период" <= dn."Дата"
          order by "РС_ЦеныНоменклатуры"."Период" desc
         limit 1) dnc on true
with data;

-- Создание индекса для ускорения операций
create index "idx_Дата_Номенклатура" on mvЦеныНаДату using btree ("Дата", "Номенклатура_Key");


--delete from "ЦеныНаДату"
--where "Дата"::date >= "ДатаЗагрузки"::date
--;
--drop table if exists dn /* Дата+Номенклатура */
--;
--with k /* Календарь */ as (
--    select series.date::date as "Дата" 
--    from generate_series(coalesce((select max("Дата") from "ЦеныНаДату") + interval '1 day','2024-01-01'),
--                         (select max("Дата") from erp."Док_Реализация"),
--                         '1 day'::interval)  as series(date))
--select *
--into temp dn
--from k
--cross join (select distinct "Номенклатура_Key" from erp."Док_Реализация.Товары"
--            union
--            select distinct "Номенклатура_Key" from "ЦеныНаДату") as pt
--;
--create index idx_dn_date_nomenclature on dn ("Дата", "Номенклатура_Key")
--;
--select * from dn
--order by "Дата" desc
--;
--drop table if exists dnc /* Дата+Номенклатура+Цена */
--;
--select "Период"                                       as "Дата"
--      ,"Номенклатура_Key"                             as "Номенклатура_Key"
--      ,"Цена"                                         as "ЦенаБазовая"
--into temp dnc
--from erp."РС_ЦеныНоменклатуры"
--;
--create index idx_dnc_date_nomenclature on dnc ("Дата", "Номенклатура_Key")
--;
--select * from dnc
--order by "Дата" --desc
--;
--insert into "ЦеныНаДату"
--select "Дата"
--      ,"Номенклатура_Key"
--      ,"ЦенаБазовая"
--      ,current_timestamp as "ДатаЗагрузки"
--from dn
--left join lateral (select "ЦенаБазовая"
--                     from dnc
--                    where dnc."Номенклатура_Key" = dn."Номенклатура_Key"
--                      and dnc."Дата" <= dn."Дата"
--                    order by dnc."Дата" desc
--                    limit 1) dnc on true
--;
--select *
--from "ЦеныНаДату"
--where true
--  and "Номенклатура_Key" = decode('80CCECB1D783C19E11E69CD5CF9866AF','hex')
--order by 2, "Дата" desc
--;