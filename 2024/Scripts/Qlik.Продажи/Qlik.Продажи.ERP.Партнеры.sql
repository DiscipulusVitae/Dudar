/* КОНТРАГЕНТЫ */
with p as (
select
     p._IDRRef                                   as "Партнер_Key"    
    ,p._Code                                     as "КодКонтрагент"
    ,p._Description                              as "Контрагент"
    ,p._Fld57389RRef                             as "Категория_Key" /*231123 ДТ берём категорию из другого реквизита Дудар_Категория*/
    ,k._IDRRef                                   as "Контрагент_Key"    
    ,sz."Ссылка_Key"                             as "СетьКлиента_Key"
    ,sz."Наименование"                           as "Сеть"
    /* следующие regexp сначала удаляют всё кроме цифр, точек и запятых, а затем последний символ если это точка или запятая */
    ,replace(regexp_replace(regexp_replace( "pdШирота"."Значение_S"::text, '[^0-9\.,]+', '', 'g'), '[,.]$','', 'g'),'.',',') as "ПартнерШирота"
    ,replace(regexp_replace(regexp_replace("pdДолгота"."Значение_S"::text, '[^0-9\.,]+', '', 'g'), '[,.]$','', 'g'),'.',',') as "ПартнерДолгота"
    ,p._Fld57381                                 as "КонтрагентДопИнфо"
from            erp._Reference380/*Партнеры*/    as p
full outer join erp._Reference277/*Контрагенты*/ as k    on  k._Fld54941RRef = p._IDRRef/*Партнер_Key*/
left join erp."Спр_Партнеры.ДопРеквизиты" as "pdШирота"  on  "pdШирота"."Ссылка_Key"   = p._IDRRef
                                                        and  "pdШирота"."Свойство_Key" = decode('A8C100155D02290611ED25F8D2B92BF9','hex') --Широта
left join erp."Спр_Партнеры.ДопРеквизиты" as "pdДолгота" on "pdДолгота"."Ссылка_Key"   = p._IDRRef
                                                        and "pdДолгота"."Свойство_Key" = decode('A8C100155D02290611ED25F8D2B92BFA','hex') --Долгота
left join erp."Спр_Партнеры.ДопРеквизиты" as "pdСеть"    on  p._IDRRef is not null
                                                        and  p._IDRRef        = "pdСеть"."Ссылка_Key"
                                                        and "pdСеть"."Свойство_Key" = decode('A3A5AC1F6B3C78CA11EE2F63C4EDCBFF','hex') -- Сеть
                                                        and "pdСеть"."Значение_Key" is not null
left join erp."Спр_ЗначенияСвойствОбъектов" as sz        on sz."Владелец_Key" = "pdСеть"."Свойство_Key"
                                                        and sz."Ссылка_Key"   = "pdСеть"."Значение_Key"
where p._Marked = false)
select *
from p
where true
--  and p."ПартнерШирота" <> ''
  and p."КодКонтрагент" like '%SHI%'
;
/* КОНТРАГЕНТЫ Категории */ 
select
     _IDRRef                                         as "Категория_Key"
    ,_ParentIDRRef                                   as "РодительКатегория_Key"
    ,case _Folder when true then '00' else '01' end  as "_Folder"
    ,_Description                                    as "КатегорияКонтрагент"
from erp._Reference730                               as "Спр_Категории"
where _Marked is false;
select * from erp._Reference730
where _IDRRef = decode('8137ECB1D783C19E11E9A917EFE29E52','hex');