/* БРЕНДЫ */
select
 	 Спр_Марки._IDRRef                               as "Бренд_Key"
    ,Спр_Марки._Description                          as "Бренд"
from erp._Reference281                               as "Спр_Марки"
order by 2;
/* ТОВАРЫ Номенклатура */ /* другая структура справочника */
select 
     _IDRRef                                         as "Номенклатура_Key"
    ,_ParentIDRRef                                   as "Parent_Key"
    ,not(_Folder)                                    as "IsFolder" /*00 - папка, 01 - не папка*/
    ,_Code                                           as "Code"
    ,_Description                                    as "Товар"
    ,_Fld55757RRef                                   as "Марка_Key"
    ,_Fld55771RRef                                   as "ТоварнаяКатегория_Key"
    ,_Fld67181RRef                                   as "СтатусТовара_Key"
from erp._Reference315                               as "Спр_Номенклатура"
where 1=1
 and not (_Folder) /*"IsFolder"*/
--  and _idrref = decode('BCAD386077DF642C11E5A9660CA54341', 'hex')
--  and _Code like '%0000008949%' -- BCAD386077DF642C11E5A9662CE61C56 UNICUM Жироудалитель Gold, 500 мл
order by _IDRRef
;

/* ТОВАРЫ ЦеныНоменклатуры */
select coalesce(cnp."Period",cn."Period")                     as "Period"
      ,coalesce(cnp."Номенклатура_Key",cn."Номенклатура_Key") as "Номенклатура_Key"
      ,"ЦенаПоставщика"
      ,"ЦенаБазовая"
from            (select distinct on (_Fld44575RRef /*Номенклатура_Key*/)
                     _Period                          as "Period"
                    ,_Fld44575RRef                    as "Номенклатура_Key"
                    ,_Fld44578                        as "ЦенаПоставщика"
                from _InfoRg44572                     as РС_ЦеныНоменклатурыПоставщиков
                where _Period >= '2024-01-01'
                order by _Fld44575RRef /*Номенклатура_Key*/, _Period desc
                ) cnp
full outer join (select distinct on (_Fld44643RRef /*Номенклатура_Key*/)
                      _Period                         as "Period"
                     ,_Fld44643RRef                   as "Номенклатура_Key"
                     ,_Fld44646                       as "ЦенаБазовая"
                 from _InfoRg44642 as РС_ЦеныНоменклатуры
                 where _Period >= '2024-01-01'
                   and _Fld44645RRef /*ВидЦены_Key*/ = decode('BA8A00025B01233611E5C644810DC6C8','hex')
                 order by _Fld44643RRef /*Номенклатура_Key*/, _Period desc
                ) cn
on cnp."Номенклатура_Key" = cn."Номенклатура_Key";
/* ТОВАРЫ СтатусТовара */
select _IDRRef                                        as "СтатусТовара_Key"
      ,_Description                                   as "СтатусТовара"
from erp._Reference67178 as Спр_СтатусТовара;
/* СКЛАДЫ */
select 
     s._IDRRef                                        as "Склад_Key"
    ,s._Description                                   as "Склад"
    ,case
        when s._Description like '%основно%'   then 'Основной'
        when s._Description like '%стикер%'    then 'Стикеровка'
        when s._Description like '%распродаж%' then 'Распродажа'
        when s._Description like '%реклам%'    then 'Реклама'
                                               else 'Другие'
    end                                               as "КатегорияСклада"
    ,case when sp._Description like '%_Структурное подразделение'
            or s._Fld65807RRef = decode('00000000000000000000000000000000','hex')
            or s._Fld65807RRef is null
          then s._Fld61164RRef /*"Подразделение_Key"*/ /*при маппинге заменится на Организация_Key, который был в УТ*/
          else s._Fld65807RRef /*Дудар_Организация_Key*/
    end                                               as "Организация_Key"
    ,s._Fld61164RRef  as "Подразделение_Key"
    ,s._Fld65807RRef  as "Дудар_Организация_Key"
from      erp._Reference537  /*"Спр_Склады"*/             as s 
left join erp._Reference620  /*Спр_СтруктураПредприятия*/ as sp on sp._IDRRef = s._Fld61164RRef /*"Подразделение_Key"*/
where true
  and s._IDRRef not in (select distinct _ParentIDRRef from erp._Reference537) -- Исключаем "папки"
--  and s._IDRRef = decode('ADBBC46E1F03138D11E5E03AAED10278','hex')
order by 2;
/* СКИДКИ СкидкиНаценки */
select 
--pt._Document1206_IDRRef                   as "Документ_Key"
       p._Number      
      ,pt._Fld29833                                   as "pt.ИдентификаторСтроки"
      ,pt._Fld29833                                   as "pt.КлючСвязи"
      ,pt._LineNo29815                                as "pt.НомерСтроки"
      ,pt._Fld29828                                   as "pt.КодСтроки"
      ,zt._Fld14465                                   as "zt.КодСтроки"
--            ,zs._Fld14487                                   as "zt.КлючСвязи"
      ,sk._Description                                as "СкидкаНаценка"
      ,zs._Fld14489                                   as "СкидкаНаценка_Сумма"
      ,_Fld29837_RTRef
--      ,p._IDRRef                  
from      erp._Document1206                           as p       --Документ.РеализацияТоваровУслуг
left join erp._Document1206_VT29814                   as pt      --Документ.РеализацияТоваровУслуг.Товары
       on p._IDRRef = pt._Document1206_IDRRef
left join erp._Document941                            as z       --Документ.ЗаказКлиента
       on z._IDRRef = p._Fld29746_RRRef
left join erp._Document941_VT14446                    as zt                                        --Документ.ЗаказКлиента.Товары
       on zt._Document941_IDRRef  = pt._Fld29837_RRRef      --Документ.РеализацияТоваровУслуг.Товары.ЗаказКлиента_ID*
      and zt._Fld14449RRef        = pt._Fld29816RRef        --Номенклатура_Key
left join erp._Document941_VT14485                    as zs      --Документ.ЗаказКлиента.СкидкиНаценки  
       on zs._Document941_IDRRef  = zt._Document941_IDRRef  --Документ.ЗаказКлиента.ID
      and zs._Fld14487            = zt._Fld14467            --КлючСвязи
left join erp._Reference530                           as sk      --Спр_СкидкиНаценки
       on sk._IDRRef = zs._Fld14488RRef --СкидкиНаценки_Key
where true
  and p._Marked = false and z._Marked = false
  and p._Date_Time >= '2024-01-01' and z._Date_Time >= '2024-01-01'
  and sk._IDRRef /*СкидкаНаценка_Key*/ <> decode('896A00155D781E3211EEAA26E5D8324E','hex') -- Округление суммы документа, точность 1
--  and p._IDRRef = decode('BC3700074333BE5811EEB5204EB0A989','hex') --ALMDU-0005330
--  and p._IDRRef = decode('BC3700074333BE5811EEB526877620F1','hex')
--  and pt._Document1206_IDRRef = decode('BC3800074333BE5811EEB9D780920459','hex') --TARDU-0000841
--  and zs._Document941_IDRRef = decode('04FCFA737495D2054071F7E83E82D346','hex')
;
/* ОСТАТКИ ТоварыНаСкладах_Итоги */
--select
--     _Fld49258RRef                                    as "Склад_Key"
--    ,_Fld49255RRef                                    as "Номенклатура_Key"
--    ,_Fld49261                                        as "ОстатокШтуки" /*в 1С: ВНаличии*/
--    ,_Period
--from erp. _AccumRgT49264                              as "РН_ТоварыНаСкладах_Итоги"
--where 1=1
--  and _Period > current_date::date
--  and _Fld49258RRef = decode('ADBBC46E1F03138D11E5E03AAED10278','hex') --Основной склад Талдыкорган
--  and _Fld49255RRef = decode('BCAD386077DF642C11E5A9662CE61C56','hex') --
--РегистрНакопления_СвободныеОстатки
drop table if exists "Остатки"
;
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
        _RecordKind                                   as "ВидДвижения"
       ,_Fld48717                                     as "ВНаличии"
       ,_Fld48719                                     as "ВРезервеПодЗаказ"
       ,_Fld48718                                     as "ВРезервеСоСклада"
       ,_Fld48714RRef                                 as "Номенклатура_Key"
       ,_LineNo                                       as "НомерСтроки"
       ,_Period::date                                 as "Дата"
       ,_RecorderRRef                                 as "_RecorderRRef"
       ,_RecorderTRef                                 as "_RecorderTRef"
       ,_Fld48716RRef                                 as "Склад_Key"
    from erp._AccumRg48713) -- "РегистрНакопления_СвободныеОстатки"
,o2 /* Движения остатков */ as (
    select -- 314 511
           o1."Дата"
          ,o1."Склад_Key"
          ,o1."Номенклатура_Key"
          ,(case "ВидДвижения" when 0 then 1 when 1 then -1 end)*"ВНаличии"    as "ОстатокШтукиДвижение"
    from pt
    left join o1 on pt."Склад_Key"        = o1."Склад_Key"
                and pt."Номенклатура_Key" = o1."Номенклатура_Key")
,o3 /* Движения остатков на день */ as (
    select "Дата" -- 112 590
          ,"Склад_Key"
          ,"Номенклатура_Key"
          ,sum(coalesce("ОстатокШтукиДвижение",0))      as "ОстатокШтукиДвижениеЗаДень"          
    from o2
    group by "Дата"
            ,"Склад_Key"
            ,"Номенклатура_Key")
,o5 /* Остатки с ценами */ as (
    select k."Дата" -- 112 590
          ,pt."Склад_Key"
          ,pt."Номенклатура_Key"
          ,o3."ОстатокШтукиДвижениеЗаДень"
          ,sum(coalesce("ОстатокШтукиДвижениеЗаДень",0)) over (partition by pt."Склад_Key", pt."Номенклатура_Key" order by k."Дата" rows unbounded preceding) as "ОстатокШтуки"
          ,cn."ЦенаБазовая"
    from k
    cross join pt --список уникальных пар "Склад_Key" "Номенклатура_Key"
    left join o3 on o3."Дата"             = k."Дата"
                and o3."Склад_Key"        = pt."Склад_Key"
                and o3."Номенклатура_Key" = pt."Номенклатура_Key"
    left join "ЦеныЕжедневно" cn on cn."Дата" = k."Дата"
                                and cn."Номенклатура_Key" = pt."Номенклатура_Key"
    )
select current_timestamp as "ДатаЗагрузки"
      ,*
      ,"ОстатокШтуки"*"ЦенаБазовая" as "ОстатокСумма"
into "Остатки"
from o5
order by "Склад_Key", "Номенклатура_Key", "Дата"
;
;
/* ФИЛИАЛЫ */
select distinct
     _IDRRef                                          as "Организация_Key"
    ,_Description                                     as "Филиал"
from erp._Reference339                                as "Спр_Организации"
order by 2;
select *-- _IDRRef                                   as "Структура_Key"
--      ,_ParentIDRRef                                 as "СтруктураРодитель_Key"      
--      ,_Description                                  as "Структура"
from erp._Reference620
where _Description like '%_Структурное подразделение%';
/* ТОРГОВЫЕ АГЕНТЫ */
select distinct
     u._IDRRef                                        as "ТорговыйАгент_Key"
    ,u._Fld65835                                      as "Район" /*в 1С: КодТорговогоАгента*/
    ,u._Description                                   as "Торговый агент"
    ,u._Fld58675RRef                                  as "Подразделение_Key"    
    ,s._Description                                   as "Подразделение"
    ,s._Fld62905RRef                                  as "ТекущийРуководитель_Key"
    ,f._Description                                   as "Руководитель"
from      erp._Reference425                           as u /*"Спр_Пользователи"*/
left join erp._Reference620                           as s /*Спр_СтруктураПредприятия*/ 
       on u._Fld58675RRef = s._IDRRef     /*Подразделение_Key*/ 
left join erp._Reference682                           as f /*Спр_ФизическиеЛица*/
       on s._Fld62905RRef = f._IDRRef    /*ТекущийРуководитель_Key*/
order by 2;