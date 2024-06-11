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
create index idx_dn_date_nomenclature on dn ("Дата", "Номенклатура_Key")
;
--select * from dn
--order by "Дата" desc
--;
drop table if exists dnc /* Дата+Номенклатура+Цена */
;
select "Период"                                       as "Дата"
      ,"Номенклатура_Key"                             as "Номенклатура_Key"
      ,"Цена"                                         as "ЦенаБазовая"
into temp dnc
from erp."РС_ЦеныНоменклатуры"
;
create index idx_dnc_date_nomenclature on dnc ("Дата", "Номенклатура_Key")
;
--select * from dnc
--order by "Дата" --desc
--;
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
select dc."Дата", dc."Номенклатура_Key", n."Наименование", dc."ЦенаБазовая", dc."ДатаЗагрузки" 
from "ЦеныНаДату" dc
left join erp."Спр_Номенклатура" n on dc."Номенклатура_Key" = n."Ссылка_Key"
where true
--  and dc."Номенклатура_Key" = decode('80CCECB1D783C19E11E69CD5CF9866AF','hex') --Wash&Go шампунь 200мл против перхоти
--  and dc."Номенклатура_Key" = decode('80D6ECB1D783C19E11E6C68ADE434CAA','hex') -- Igora Royal Highlifts 12-4 краситель спец. блонд бежевый 60мл
  and dc."Номенклатура_Key" = decode('80DAECB1D783C19E11E6E84E1FDDAE3F','hex') -- UNICUM Жироудалитель Гризли 500 мл
--  and dc."Номенклатура_Key" = decode('','hex') -- 
order by
	 "ДатаЗагрузки" desc
	,"Дата" desc
	,"Номенклатура_Key"
;