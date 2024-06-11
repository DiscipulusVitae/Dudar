--10 минут+
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series((select min(_Date_Time) from _Document1206 /*Документ.РеализацияТоваровУслуг*/),
                         (select max(_Date_Time) from _Document1206 /*Документ.РеализацияТоваровУслуг*/),
                         '1 day'::interval)  as series(date))
,cn /* Цены */ as (
    select _Period                                       as "Дата"
          ,_Fld44643RRef                                 as "Номенклатура_Key"
          ,_Fld44646                                     as "ЦенаБазовая"
    from _InfoRg44642                                    as "РС_ЦеныНоменклатуры")
,cnp /* Цены поставщиков */ as (
    select _Period                                       as "Дата"
          ,_Fld44575RRef                                 as "Номенклатура_Key"
          ,_Fld44578                                     as "ЦенаПоставщика"
    from _InfoRg44572                                    as "РС_ЦеныНоменклатурыПоставщиков")
select count(*)      
from k
cross join (select distinct _Fld29816RRef as "Номенклатура_Key" from _Document1206_VT29814) as pt
left join lateral (select cn."ЦенаБазовая"
                         from cn
                        where cn."Номенклатура_Key" = pt."Номенклатура_Key"
                          and cn."Дата" <= k."Дата"
                        order by cn."Дата" desc
                        limit 1) cn on true
--left join lateral (select cnp."ЦенаПоставщика"
--                         from cnp
--                        where cnp."Номенклатура_Key" = pt."Номенклатура_Key"
--                          and cnp."Дата" <= k."Дата"
--                        order by cnp."Дата" desc
--                        limit 1) cnp on true
--where true
--  and "Номенклатура_Key" = decode('814BECB1D783C19E11EA4323E1520579','hex')
;
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series(('2023-12-28'::date),
                         (select max(_Date_Time) from _Document1206 /*Документ.РеализацияТоваровУслуг*/),
                         '1 day'::interval)  as series(date))
,kpt /* Дата-Номенклатура */ as (
    select *
    from k
    cross join (select distinct _Fld29816RRef as "Номенклатура_Key" from _Document1206_VT29814) as pt
)
--,cn /* Цены */ as (
--    select _Period                                       as "Дата"
--          ,_Fld44643RRef                                 as "Номенклатура_Key"
--          ,_Fld44646                                     as "ЦенаБазовая"
--    from _InfoRg44642                                    as "РС_ЦеныНоменклатуры")
--,cnp /* Цены поставщиков */ as (
--    select _Period                                       as "Дата"
--          ,_Fld44575RRef                                 as "Номенклатура_Key"
--          ,_Fld44578                                     as "ЦенаПоставщика"
--    from _InfoRg44572                                    as "РС_ЦеныНоменклатурыПоставщиков")
select *
from kpt
left join lateral (select _Fld44646 as "ЦенаБазовая"
                     from _InfoRg44642 /*"РС_ЦеныНоменклатуры"*/
                    where _Fld44643RRef /*"Номенклатура_Key"*/ = kpt."Номенклатура_Key"
                      and _Period <= kpt."Дата"
                    order by _Period desc
                    limit 1) cn on true
--left join lateral (select cnp."ЦенаПоставщика"
--                         from cnp
--                        where cnp."Номенклатура_Key" = pt."Номенклатура_Key"
--                          and cnp."Дата" <= k."Дата"
--                        order by cnp."Дата" desc
--                        limit 1) cnp on true
order by "Дата"  
;