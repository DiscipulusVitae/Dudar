--РегистрНакопления_ТоварыНаСкладах
with o as (
    select
        _RecordKind                                 as "ВидДвижения"
       ,_Fld49261                                   as "ВНаличии"
       ,_Fld49263                                   as "КонтролироватьОстатки"
       ,_Fld49262                                   as "КОтгрузке"
       ,_Fld49257RRef                               as "Назначение"
       ,_Fld49255RRef                               as "Номенклатура"
       ,_LineNo                                     as "НомерСтроки"
       ,_Period                                     as "Период"
       ,_Fld49259RRef                               as "Помещение"
       ,_RecorderRRef                               as "_RecorderRRef"
       ,_RecorderTRef                               as "_RecorderTRef"
       ,_Fld49260RRef                               as "Серия"
       ,_Fld49258RRef                               as "Склад"
    from _AccumRg49254) -- "РегистрНакопления_ТоварыНаСкладах"
select -- 314 511
    "_RecorderTRef"
    ,count("_RecorderTRef")
from o
where true
group by "_RecorderTRef"
order by 1
;
--РегистрНакопления_СвободныеОстатки
with o as (
    select       
        _RecordKind                                 as "ВидДвижения"
       ,_Fld48717                                   as "ВНаличии"
       ,_Fld48719                                   as "ВРезервеПодЗаказ"
       ,_Fld48718                                   as "ВРезервеСоСклада"
       ,_Fld48714RRef                               as "Номенклатура"
       ,_LineNo                                     as "НомерСтроки"
       ,_Period::date                               as "Период"
       ,_RecorderRRef                               as "_RecorderRRef"
       ,_RecorderTRef                               as "_RecorderTRef"
       ,_Fld48716RRef                               as "Склад"
    from _AccumRg48713) -- "РегистрНакопления_СвободныеОстатки"
select -- 314 511
    "_RecorderTRef"
    ,count("_RecorderTRef")
from o
where true
--  and "Активность" is true
group by "_RecorderTRef"
order by 1
--    desc
;

--РегистрНакопления_СвободныеОстатки
with o1 as (
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
    from _AccumRg48713) -- "РегистрНакопления_СвободныеОстатки"
,pt as (select distinct _Fld29834RRef               as "Склад_Key"
                       ,_Fld29816RRef               as "Номенклатура_Key"
          from _Document1206_VT29814) --Документ.РеализацияТоваровУслуг.Товары
,o2 as (
    select -- 314 511
           o1."Дата"
          ,o1."Склад_Key"
          ,o1."Номенклатура_Key"
          ,(case "ВидДвижения" when 0 then 1 when 1 then -1 end)*"ВНаличии"    as "ОстатокШтукиДвижение"
    from pt
    left join o1 on pt."Склад_Key"        = o1."Склад_Key"
                and pt."Номенклатура_Key" = o1."Номенклатура_Key")
,o3 as (
    select "Дата"
          ,"Склад_Key"
          ,"Номенклатура_Key"
          ,sum(coalesce("ОстатокШтукиДвижение",0))      as "ОстатокШтукиДвижениеЗаДень"
    from o2
    group by "Дата"
            ,"Склад_Key"
            ,"Номенклатура_Key")
,k as (select series.date::date as "Дата"
       from generate_series((select min("Дата") from o3),
                            (select max("Дата") from o3),
                            '1 day'::interval)  as series(date))
select k."Дата"
      ,pt."Склад_Key"
      ,pt."Номенклатура_Key"
      ,o3."ОстатокШтукиДвижениеЗаДень"
--      ,sum(coalesce("ОстатокШтукиДвижениеЗаДень",0)) over (partition by "Склад_Key", "Номенклатура_Key" order by "Дата" rows unbounded preceding) as "ОстатокШтуки"
from k
cross join pt --список уникальных пар "Склад_Key" "Номенклатура_Key"
left join o3 on o3."Дата"             = k."Дата" 
            and o3."Склад_Key"        = pt."Склад_Key"
            and o3."Номенклатура_Key" = pt."Номенклатура_Key"
where true
--  and "Склад_Key"        = decode('ADBBC46E1F03138D11E5E03337BA7AA9','hex')
--  and "Номенклатура_Key" = decode('80F2ECB1D783C19E11E76072D7D07D35','hex')
order by 1
--    desc
;
