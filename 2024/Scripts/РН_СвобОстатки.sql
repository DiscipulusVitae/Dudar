with o as
    (select
        _Active                                     as "Активность"
       ,_RecordKind                                 as "ВидДвижения"
       ,_Fld48717                                   as "ВНаличии"
       ,_Fld48719                                   as "ВРезервеПодЗаказ"
       ,_Fld48718                                   as "ВРезервеСоСклада"
       ,_Fld48714RRef                               as "Номенклатура_Key"
       ,_LineNo                                     as "НомерСтроки"
       ,_Fld2367                                    as "ОбластьДанныхОсновныеДанные"
       ,_Period                                     as "Период"
       ,_RecorderRRef                               as "_RecorderRRef"
       ,_RecorderTRef                               as "_RecorderTRef"
       ,_Fld48716RRef                               as "Склад"
       ,_Fld48715RRef                               as "Характеристика"
    from erp._AccumRg48713 as "РегистрНакопления.СвободныеОстатки")
,non_zero_avail as (
  select distinct "Номенклатура_Key"
  from o
  where "ВНаличии" <> 0
), non_zero_reserve as (
  select distinct "Номенклатура_Key"
  from o
  where "ВРезервеСоСклада" <> 0
), combined_keys as (
  select "Номенклатура_Key"
  from non_zero_avail
  intersect
  select "Номенклатура_Key"
  from non_zero_reserve
)
select o."Номенклатура_Key"
      ,"Период"      
      ,(case "ВидДвижения" when 0 then 1 when 1 then -1 end)*o."ВНаличии" as "ОстатокШтукиДвижение"
      ,"ВРезервеСоСклада"
from o
join combined_keys ck on o."Номенклатура_Key" = ck."Номенклатура_Key"
where true
--  and "_RecorderTRef" = decode('000003AD','hex')
--  and "ВРезервеСоСклада" <> 0 --3 415 3 378
--  and "ВНаличии" > 0 -- 362 494, 276 065
--group by 1
order by 1,2
;

--РегистрНакопления_СвободныеОстатки
with k /* Календарь */ as (
    select series.date::date as "Дата" 
    from generate_series(('2023-12-28'::date),
                         (select max(_Date_Time) from erp._Document1206 /*Документ.РеализацияТоваровУслуг*/),
                         '1 day'::interval)  as series(date))
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
    from erp._AccumRg48713
    where true
      and _Fld48714RRef/*"Номенклатура_Key"*/ = decode('A8F600155D02290611EDC6F30F072F97','hex')
    ) -- "РегистрНакопления_СвободныеОстатки"
,o2 /* Движения остатков */ as (
    select -- 314 511
           o1."Дата"
          ,o1."Склад_Key"
          ,o1."Номенклатура_Key"
          ,(case "ВидДвижения" when 0 then 1 when 1 then -1 end)*"ВНаличии"         as "ОстатокШтукиДвижение"
          ,"ВРезервеСоСклада"
          ,"_RecorderTRef"
          ,"_RecorderRRef"
    from o1)
,o3 /* Движения остатков на день */ as (
    select "Дата" -- 112 590
          ,"Склад_Key"
          ,"Номенклатура_Key"
          ,sum(coalesce("ОстатокШтукиДвижение",0)) as "ОстатокШтукиДвижениеЗаДень"
          ,sum(coalesce("ВРезервеСоСклада",0))     as "ВРезервеСоСклада"
    from o2
    group by "Дата"
            ,"Склад_Key"
            ,"Номенклатура_Key")
,o4 /* Остатки с ценами */ as (
    select "Дата" -- 112 590
          ,"Склад_Key"
          ,"Номенклатура_Key"
          ,"ОстатокШтукиДвижениеЗаДень"
          ,sum(coalesce("ОстатокШтукиДвижениеЗаДень",0)) over (partition by "Номенклатура_Key" order by "Дата" rows unbounded preceding) as "ОстатокШтуки"
          ,"ВРезервеСоСклада"          
    from o3
    )
select *
from o1
order by "Номенклатура_Key","Дата"