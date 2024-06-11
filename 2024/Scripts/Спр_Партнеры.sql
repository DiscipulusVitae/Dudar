drop materialized view if exists "Спр_Партнеры";
refresh materialized view "Спр_Партнеры";
create materialized view "Спр_Партнеры" as -- Справочник.Партнеры
with recursive cte as (
  select _ParentIDRRef
        ,_IDRRef
        ,_Code                                   as "ПартнерКод"
        ,1                                       as _Depth -- начальный уровень глубины
        ,_Description::text                      as _Description_Path -- начальный путь
        ,_Description::text                      as "Партнер"
        ,_Fld57389RRef /*Дудар_Категория*/       as "Категория_Key"
  from erp._Reference380 --Спр_Партнеры
  where _ParentIDRRef = decode('00000000000000000000000000000000','hex') -- корневой узел
    and not (_Marked)
  union all
  select r._ParentIDRRef
        ,r._IDRRef
        ,r._Code
        ,cte._Depth + 1 -- увеличение уровня глубины
        ,(cte._Description_Path || '➡️' || r._Description)::text -- добавление к пути
        ,_Description::text
        ,_Fld57389RRef /*Дудар_Категория*/
  from erp._Reference380 r
  join cte on r._ParentIDRRef = cte._IDRRef
  where not (r._Marked)
)
select _IDRRef                                   as "Партнер_Key"
      ,_Depth      
      ,"ПартнерКод"      
      ,case when _Depth <= 2 then split_part(_Description_Path, '➡️', 1)
                             else split_part(_Description_Path, '➡️', _Depth - 2)
       end                                       as "ПартнерГруппа"
      ,case when _Depth <= 1 then split_part(_Description_Path, '➡️', 1)
                             else split_part(_Description_Path, '➡️', _Depth - 1)
       end                                       as "ПартнерПодгруппа"
      ,"Партнер"
      ,"Категория_Key"
      ,sz."Ссылка_Key"                           as "Сеть_Key"
      ,sz."Наименование"                         as "Сеть"
      /* следующие regexp сначала удаляют всё кроме цифр, точек и запятых, а затем последний символ если это точка или запятая */
      ,replace(regexp_replace(regexp_replace( "pdШирота"."Значение_S"::text, '[^0-9\.,]+', '', 'g'), '[,.]$','', 'g'),'.',',') as "ПартнерШирота"
      ,replace(regexp_replace(regexp_replace("pdДолгота"."Значение_S"::text, '[^0-9\.,]+', '', 'g'), '[,.]$','', 'g'),'.',',') as "ПартнерДолгота"
from cte as p
left join erp."Спр_Партнеры.ДопРеквизиты"        as "pdШирота"  on  "pdШирота"."Ссылка_Key"   = p._IDRRef
                                                               and  "pdШирота"."Свойство_Key" = decode('A8C100155D02290611ED25F8D2B92BF9','hex') --Широта
left join erp."Спр_Партнеры.ДопРеквизиты"        as "pdДолгота" on "pdДолгота"."Ссылка_Key"   = p._IDRRef
                                                               and "pdДолгота"."Свойство_Key" = decode('A8C100155D02290611ED25F8D2B92BFA','hex') --Долгота
left join erp."Спр_Партнеры.ДопРеквизиты"        as "pdСеть"    on  p._IDRRef                 is not null
                                                               and  p._IDRRef                 = "pdСеть"."Ссылка_Key"
                                                               and "pdСеть"."Свойство_Key"    = decode('A3A5AC1F6B3C78CA11EE2F63C4EDCBFF','hex') -- Сеть
                                                               and "pdСеть"."Значение_Key"    is not null
left join erp."Спр_ЗначенияСвойствОбъектов"      as sz          on sz."Владелец_Key"          = "pdСеть"."Свойство_Key"
                                                               and sz."Ссылка_Key"            = "pdСеть"."Значение_Key"
where _IDRRef not in (select distinct _ParentIDRRef from erp._Reference380 where _ParentIDRRef is not null) -- Исключаем "папки"
order by _Description_Path
;
create index idx_СпрПартнеры_ПартнерKey on "Спр_Партнеры" ("Партнер_Key");
create index idx_СпрПартнеры_ПартнерКод on "Спр_Партнеры" ("ПартнерКод");
--create index idx_СпрПартнеры_Категория_Key on "Спр_Партнеры" ("Категория_Key");
--create index idx_СпрПартнеры_ГруппаПодгруппа on "Спр_Партнеры" ("ПартнерГруппа", "ПартнерПодгруппа");
--create index idx_СпрПартнеры_СетьКлиентаKey on "Спр_Партнеры" ("СетьКлиента_Key");
--create index idx_СпрПартнеры_ШиротаДолгота on "Спр_Партнеры" ("ПартнерШирота", "ПартнерДолгота");

select *
from "Спр_Партнеры"
where true
  and  "ПартнерКод" = 'SHI-4172'
;

select p."Партнер_Key"
      ,p."ПартнерКод"
      ,p."ПартнерГруппа"
      ,p."ПартнерПодгруппа"
      ,p."Партнер"
      ,p."Категория_Key" 
      ,sz."Ссылка_Key"   as "ПартнерСеть_Key"
      ,sz."Наименование" as "ПартнерСеть"
from          "Спр_Партнеры" as p
left join erp."Спр_Партнеры.ДопРеквизиты" as   pd on   p."Партнер_Key"   = pd."Ссылка_Key"
left join erp."ПВХ_ДопРеквизитыИСведения" as  pvh on  pd."Свойство_Key" = pvh."Ссылка_Key"
                                                 and pvh."Имя"          = 'СетьКлиента_4d5b8a3afece4781811d5879421fab9a'
left join erp."Спр_ЗначенияСвойствОбъектов" as sz on  sz."Владелец_Key" = pd."Свойство_Key"
                                                 and  sz."Ссылка_Key"   = pd."Значение_Key"
--A3A5AC1F6B3C78CA11EE2F63C4EDCBFF
where pvh."Ссылка_Key" is not null
;

drop view if exists erp."ПВХ_ДопРеквизитыИСведения";
create or replace view erp."ПВХ_ДопРеквизитыИСведения" as --ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения
select
    _Description as "Наименование"
    ,_Fld2367 as "ОбластьДанныхОсновныеДанные"
    ,_Fld50073 as    "Виден"
    --,_Fld50074 as    "ВладелецДополнительныхЗначений"
    ,_Fld50075 as    "ВыводитьВВидеГиперссылки"
    ,_Fld50076 as    "ДополнительныеЗначенияИспользуются"
    ,_Fld50077 as    "ДополнительныеЗначенияСВесом"
    ,_Fld50078 as    "Доступен"
    ,_Fld50079 as    "Заголовок"
    ,_Fld50080 as    "ЗаголовокФормыВыбораЗначения"
    ,_Fld50081 as    "ЗаголовокФормыЗначения"
    ,_Fld50082 as    "ЗаполнятьОбязательно"
    ,_Fld50083 as    "Имя"
    ,_Fld50084 as    "Комментарий"
    ,_Fld50085 as    "МногострочноеПолеВвода"
    --,_Fld50086 as    "НаборСвойств"
    ,_Fld50087 as    "Подсказка"
    ,_Fld50088 as    "УдалитьСклоненияПредмета"
    ,_Fld50089 as    "ФорматСвойства"
    ,_Fld50090 as    "ЭтоДополнительноеСведение"
    ,_IDRRef as  "Ссылка_Key"
    ,_Marked as  "ПометкаУдаления"
    ,_PredefinedID as    "ИмяПредопределенныхДанных"
    ,_Type as    "ТипЗначения"
    ,_Version as "ВерсияДанных"
from erp._Chrc2332 --ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения
;
select *
from erp."ПВХ_ДопоРеквизитыИСведения"
;