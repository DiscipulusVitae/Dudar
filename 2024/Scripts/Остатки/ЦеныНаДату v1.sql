drop table if exists kpt
;
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series((select max("Дата") from "ЦеныНаДату") + interval '1 day',
                         (select max(_Date_Time) from erp._Document1206 /*Документ.РеализацияТоваровУслуг*/),
                         '1 day'::interval)  as series(date))
select *
into temp kpt
from k
cross join (select distinct _Fld29816RRef as "Номенклатура_Key" from erp._Document1206_VT29814
            union
            select distinct "Номенклатура_Key" from "ЦеныНаДату") as pt
;
create index idx_kpt_date_nomenclature on kpt ("Дата", "Номенклатура_Key")
;
select * from kpt
order by "Дата" --desc
;
drop table if exists cn
;
select _Period                                       as "Дата"
      ,_Fld44643RRef                                 as "Номенклатура_Key"
      ,_Fld44646                                     as "ЦенаБазовая"
into temp cn
from erp._InfoRg44642                                as "РС_ЦеныНоменклатуры"
;
create index idx_cn_date_nomenclature on cn ("Дата", "Номенклатура_Key")
;
select * from cn
order by "Дата" --desc
;
--select *     
--into "ЦеныНаДату"
--from kpt
--left join lateral (select "ЦенаБазовая"
--                     from cn
--                    where cn."Номенклатура_Key" = kpt."Номенклатура_Key"
--                      and cn."Дата" <= kpt."Дата"
--                    order by cn."Дата" desc
--                    limit 1) cn on true
--;
--create index idx_knc_date_nomenclature on "ЦеныНаДату" ("Дата", "Номенклатура_Key")
--;
--alter table public."ЦеныНаДату" add "ДатаЗагрузки" timestamptz null
--;
--alter table public."ЦеныНаДату" add constraint "ЦеныНаДату_pk" primary key ("Дата","Номенклатура_Key")
;
delete from "ЦеныНаДату"
where "Дата"::date >= '2024-02-21' --"ДатаЗагрузки"::date
;
insert into "ЦеныНаДату"
select "Дата"
      ,"Номенклатура_Key"
      ,"ЦенаБазовая"
      ,current_timestamp as "ДатаЗагрузки"
from kpt
left join lateral (select "ЦенаБазовая"
                     from cn
                    where cn."Номенклатура_Key" = kpt."Номенклатура_Key"
                      and cn."Дата" <= kpt."Дата"
                    order by cn."Дата" desc
                    limit 1) cn on true
;
select *
from "ЦеныНаДату"
where true
  and "Номенклатура_Key" = decode('80CCECB1D783C19E11E69CD5CF9866AF','hex')
order by 2, "Дата" desc
;
select *
from "Остатки"
where true
  and "Номенклатура_Key" = decode('8152ECB1D783C19E11EA7D7BB8E138B4','hex')
order by "Дата" desc
