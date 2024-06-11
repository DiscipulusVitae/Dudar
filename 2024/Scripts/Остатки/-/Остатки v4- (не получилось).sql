--РегистрНакопления_СвободныеОстатки_v4
refresh materialized view "Остатки_v4";
drop materialized view if exists "Остатки_v4";
create materialized view "Остатки_v4" as
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series(('2023-12-28'::date),
                         (select max("Дата") from erp."Док_Реализация"), --Документ.РеализацияТоваровУслуг
                         '1 day'::interval)  as series(date))
,pt /* Список уникальных пар "Склад_Key", "Номенклатура_Key" из продаж */ as (
    select distinct "Склад_Key"
                   ,"Номенклатура_Key"
    from erp."Док_Реализация.Товары") --Документ.РеализацияТоваровУслуг.Товары
,o1 /*СвободныеОстатки_v4*/ as (
    select       
        "ВидДвижения"
       ,"ВНаличии"
       ,"ВРезервеПодЗаказ"
       ,"ВРезервеСоСклада"
       ,"Номенклатура_Key"
       ,"НомерСтроки"
       ,"Период"                                      as "Дата"
       ,"Регистратор_Key"
       ,"Регистратор_Tbl"
       ,"Склад_Key"
    from erp."РН_СвободныеОстатки") -- "РегистрНакопления_СвободныеОстатки"
,o2 /* Движения остатков */ as (
    select -- 314 511
           o1."Дата"
          ,o1."Склад_Key"
          ,o1."Номенклатура_Key"
          ,(case "ВидДвижения" when 0 then 1
                               when 1 then -1 end)*"ВНаличии" as "Остатки.ШтукиДвижение"
          ,"ВРезервеСоСклада"
    from pt
    left join o1 on pt."Склад_Key"        = o1."Склад_Key"
                and pt."Номенклатура_Key" = o1."Номенклатура_Key")
,o3 /* Движения остатков на день */ as (
    select "Дата" -- 112 590
          ,"Склад_Key"
          ,"Номенклатура_Key"
          ,sum(coalesce("Остатки.ШтукиДвижение",0))    as "Остатки.ШтукиДвижениеЗаДень"
          ,sum(coalesce("ВРезервеСоСклада",0))        as "ВРезервеСоСклада"          
    from o2
    group by "Дата"
            ,"Склад_Key"
            ,"Номенклатура_Key")
,o4 /* Остатки_v4 с ценами */ as (
    select k."Дата" -- 112 590
          ,pt."Склад_Key"
          ,pt."Номенклатура_Key"
          ,o3."Остатки.ШтукиДвижениеЗаДень"
          ,sum(coalesce("Остатки.ШтукиДвижениеЗаДень",0)) over (partition by pt."Склад_Key", pt."Номенклатура_Key" order by k."Дата" rows unbounded preceding) as "Остатки.Штуки"
          ,"ВРезервеСоСклада"
          ,first_value("ВРезервеСоСклада")               over (partition by pt."Склад_Key", pt."Номенклатура_Key" order by k."Дата" rows unbounded preceding) as "Остатки.ШтукиВРезерве"
          ,cn."ЦенаБазовая"
    from k
    cross join pt --список уникальных пар "Склад_Key" "Номенклатура_Key"
    left join o3 on o3."Дата"             = k."Дата"
                and o3."Склад_Key"        = pt."Склад_Key"
                and o3."Номенклатура_Key" = pt."Номенклатура_Key"
    left join "mvЦеныНаДату" cn on cn."Дата" = k."Дата"
                                and cn."Номенклатура_Key" = pt."Номенклатура_Key"
    )
select current_timestamp                              as "ДатаЗагрузки"
      ,*
      ,n."Код"                                        as "Остатки.ТоварКод"
      ,n."Наименование"                               as "Остатки.Товар"
      ,"Остатки.Штуки"*"ЦенаБазовая"                  as "Остатки_v4.Сумма"
      ,"Остатки.ШтукиВРезерве"*"ЦенаБазовая"          as "Остатки_v4.СуммаВРезерве"      
--into "Остатки_v4"
from o4
left join erp."Спр_Номенклатура" n on o4."Номенклатура_Key" = n."Ссылка_Key"
where true
--  and "Остатки_v4.Штуки" >= 0
--  and "Склад_Key"        = decode('ADBBC46E1F03138D11E5E03D46C8771C','hex')
--  and "Номенклатура_Key" = decode('814BECB1D783C19E11EA4323E1520579','hex')
order by "Склад_Key", "Номенклатура_Key", "Дата"
;

select "Дата"
	  ,"Номенклатура_Key"
--      ,"Склад_Key"      
--      ,"Остатки_v4.ШтукиДвижениеЗаДень"
      ,sum("Остатки_v4.Штуки")
--      ,"ВРезервеСоСклада"
--      ,"Остатки_v4.ШтукиВРезерве"
      ,max("ЦенаБазовая")
      ,sum("Остатки_v4.Сумма")
--      ,"Остатки_v4.СуммаВРезерве"      
from "Остатки_v4"
where true
  and "Остатки_v4"."Дата" = '2024-04-24'
  and "Номенклатура_Key" = decode('80CCECB1D783C19E11E69CD5CF9866AF','hex')
--  and "Номенклатура_Key" = decode('A9AD00155D02290611EE5CEAB173889E','hex')
--  and "Остатки_v4.ШтукиДвижениеЗаДень" is not null
group by 1,2
order by 1 desc,2
;
select *
from "Остатки_v4"
where true
  and "Остатки_v4"."Дата" >= date_trunc('month', current_date)
  and "Остатки_v4"."Дата" <= current_date
order by "Дата" desc
;