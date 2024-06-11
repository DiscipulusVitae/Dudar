--РегистрНакопления_СвободныеОстатки
refresh materialized view "Остатки";
drop materialized view if exists "Остатки";
create materialized view "Остатки" as
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series(('2023-12-28'::date),
                         (select max(_Date_Time) from erp._Document1206 /*Документ.РеализацияТоваровУслуг*/),
                         '1 day'::interval)  as series(date))
,pt /* Список уникальных пар "Склад_Key", "Номенклатура_Key" из продаж */ as (
    select distinct _Fld29834RRef               as "Склад_Key"
                   ,_Fld29816RRef               as "Номенклатура_Key"
    from erp._Document1206_VT29814) --Документ.РеализацияТоваровУслуг.Товары
,o1 /*СвободныеОстатки*/ as (
    select       
        _RecordKind                                 as "ВидДвижения"
       ,_Fld48717                                   as "ВНаличии"
       ,_Fld48719                                   as "ВРезервеПодЗаказ"
       ,_Fld48718                                   as "ВРезервеСоСклада"
       ,_Fld48714RRef                               as "Номенклатура_Key"
       ,_LineNo                                     as "НомерСтроки"
       ,_Period::date                               as "Дата"
       ,_RecorderRRef                               as "_RecorderRRef"
       ,_RecorderTRef                               as "_RecorderTRef"
       ,_Fld48716RRef                               as "Склад_Key"
    from erp._AccumRg48713) -- "РегистрНакопления_СвободныеОстатки"
,o2 /* Движения остатков */ as (
    select -- 314 511
           o1."Дата"
          ,o1."Склад_Key"
          ,o1."Номенклатура_Key"
          ,(case "ВидДвижения" when 0 then 1 when 1 then -1 end)*"ВНаличии"         as "ОстатокШтукиДвижение"
          ,"ВРезервеСоСклада"
    from pt
    left join o1 on pt."Склад_Key"        = o1."Склад_Key"
                and pt."Номенклатура_Key" = o1."Номенклатура_Key")
,o3 /* Движения остатков на день */ as (
    select "Дата" -- 112 590
          ,"Склад_Key"
          ,"Номенклатура_Key"
          ,sum(coalesce("ОстатокШтукиДвижение",0))         as "ОстатокШтукиДвижениеЗаДень"
          ,sum(coalesce("ВРезервеСоСклада",0))             as "ВРезервеСоСклада"          
    from o2
    group by "Дата"
            ,"Склад_Key"
            ,"Номенклатура_Key")
,o4 /* Остатки с ценами */ as (
    select k."Дата" -- 112 590
          ,pt."Склад_Key"
          ,pt."Номенклатура_Key"
          ,o3."ОстатокШтукиДвижениеЗаДень"
          ,sum(coalesce("ОстатокШтукиДвижениеЗаДень",0)) over (partition by pt."Склад_Key", pt."Номенклатура_Key" order by k."Дата" rows unbounded preceding) as "ОстатокШтуки"
          ,"ВРезервеСоСклада"
          ,first_value("ВРезервеСоСклада")               over (partition by pt."Склад_Key", pt."Номенклатура_Key" order by k."Дата" rows unbounded preceding) as "ОстатокШтукиВРезерве"
          ,cn."ЦенаБазовая"
    from k
    cross join pt --список уникальных пар "Склад_Key" "Номенклатура_Key"
    left join o3 on o3."Дата"             = k."Дата"
                and o3."Склад_Key"        = pt."Склад_Key"
                and o3."Номенклатура_Key" = pt."Номенклатура_Key"
    left join "ЦеныНаДату" cn on cn."Дата" = k."Дата"
                                and cn."Номенклатура_Key" = pt."Номенклатура_Key"
    )
select current_timestamp as "ДатаЗагрузки"
      ,*
      ,"ОстатокШтуки"*"ЦенаБазовая"         as "ОстатокСумма"
      ,"ОстатокШтукиВРезерве"*"ЦенаБазовая" as "ОстатокСуммаВРезерве"
--into "Остатки"
from o4
where true
--  and "ОстатокШтуки" >= 0
--  and "Склад_Key"        = decode('ADBBC46E1F03138D11E5E03D46C8771C','hex')
--  and "Номенклатура_Key" = decode('814BECB1D783C19E11EA4323E1520579','hex')
order by "Склад_Key", "Номенклатура_Key", "Дата"
;

select "Дата"
	  ,"Номенклатура_Key"
--      ,"Склад_Key"      
--      ,"ОстатокШтукиДвижениеЗаДень"
      ,sum("ОстатокШтуки")
--      ,"ВРезервеСоСклада"
--      ,"ОстатокШтукиВРезерве"
      ,max("ЦенаБазовая")
      ,sum("ОстатокСумма")
--      ,"ОстатокСуммаВРезерве"      
from "Остатки"
where true
  and "Остатки"."Дата" = '2024-04-24'
  and "Номенклатура_Key" = decode('80CCECB1D783C19E11E69CD5CF9866AF','hex')
--  and "Номенклатура_Key" = decode('A9AD00155D02290611EE5CEAB173889E','hex')
--  and "ОстатокШтукиДвижениеЗаДень" is not null
group by 1,2
order by 1 desc,2
;
select *
from "Остатки"
where true
  and "Остатки"."Дата" >= date_trunc('month', current_date)
  and "Остатки"."Дата" <= current_date
--  and "ОстатокСуммаВРезерве" is not null
order by "Дата" desc
;