select *
from erp."Док_ЗаказПоставщику" zp
join erp."Док_ЗаказПоставщику.Товары" zpt on zp."Ссылка_Key" = zpt."Ссылка_Key"
where zp."Номер" = 'ALMDU-00370'
;

drop materialized view if exists "Док_ТоварыВПути" cascade;
create materialized view "Док_ТоварыВПути" as
select "ДокТип" || '_' ||  upper(encode("Док_ТоварыВПути_Key",'hex')) ||'_' ||  upper(encode("Номенклатура_Key",'hex')) as "Документы_Key"
      ,*
from (
    with "ТоварыВПути.ЗаказыПоставщику"           as (
        select 'Док_ЗаказПоставщику'             as "ДокТип"
              ,zp."Ссылка_Key"                   as "Док_ТоварыВПути_Key"
              ,zp."Номер"                        as "ДокНомер"
              ,zp."Дата"
              ,zp."Склад_Key"                    as "СкладОтправитель_Key"
              ,p."СкладПолучатель_Key"
              ,t."Номенклатура_Key"
              ,t."Количество"
        from erp."Док_ЗаказПоставщику" zp
        left join erp."Док_ПоступлениеТоваров" pt on zp."Ссылка_Key" = pt."Распоряжение_Key" and pt."Проведен"
        left join erp."Док_ПеремещениеТоваров" p on pt."Ссылка_Key" = p."ДокументОснование_Key" and p."Проведен"
        left join erp."Док_ПриходныйОрдерНаТовары" pot on p."Ссылка_Key" = pot."Распоряжение_Key" and pot."Проведен"
        left join (
            select zp."Ссылка_Key", zpt."Номенклатура_Key", sum(zpt."Количество") as "Количество"
            from erp."Док_ЗаказПоставщику" zp
            left join erp."Док_ЗаказПоставщику.Товары" zpt on  zp."Ссылка_Key" = zpt."Ссылка_Key"
                                                          and zpt."ПричинаОтмены_Key" = decode('00000000000000000000000000000000','hex') -- исключаем отменённые строки товара
            where zp."Проведен"
            group by zp."Ссылка_Key", zpt."Номенклатура_Key"
        ) t on zp."Ссылка_Key" = t."Ссылка_Key"
        left join erp."Спр_Номенклатура" n on t."Номенклатура_Key" = n."Ссылка_Key"
        where _IDRRef_To_GUID(zp."Статус_Key") = 'c22fc12c-7ec6-4da3-973a-5675ac6a17f6' -- 'Подтвержден' перечисление СтатусыЗаказовПоставщикам
          and zp."Проведен"
          and pot."Ссылка_Key" is null
          and _IDRRef_To_GUID(n."ТипНоменклатуры_Key") = '57507687-e857-4627-84a6-131b6dc5555a' -- 'Товар'
    ), "ТоварыВПути.Перемещения" as (
        select 'Док_ЗаказНаПеремещение'          as "ДокТип"
              ,zp."Ссылка_Key"                   as "Док_ТоварыВПути_Key"
              ,zp."Номер"                        as "ДокНомер"
              ,zp."Дата"
              ,zp."СкладОтправитель_Key"
              ,zp."СкладПолучатель_Key"
              ,t."Номенклатура_Key"
              ,t."Количество"
        from  erp."Док_ЗаказНаПеремещение" zp
        left join erp."Спр_Склады" so on zp."СкладОтправитель_Key" = so."Ссылка_Key"
        left join erp."Док_ПриходныйОрдерНаТовары" pot on zp."Ссылка_Key" = pot."Распоряжение_Key"
        left join (
            select zp."Ссылка_Key", zpt."Номенклатура_Key", sum(zpt."Количество") as "Количество"
            from erp."Док_ЗаказНаПеремещение" zp
            left join erp."Док_ЗаказНаПеремещение.Товары" zpt on zp."Ссылка_Key" = zpt."Ссылка_Key"
                                                             and zpt."Отменено" = false -- исключаем отменённые строки товара
            where zp."Проведен"              
            group by zp."Ссылка_Key", zpt."Номенклатура_Key"
        ) t on zp."Ссылка_Key" = t."Ссылка_Key"
        where not so."Наименование" like '%товары в пути%'
          and pot."Ссылка_Key" is null
          and zp."Проведен"
    )
    select *
    from "ТоварыВПути.ЗаказыПоставщику"
    union all
    select *
    from "ТоварыВПути.Перемещения"
) as "ТоварыВПути"
;
select "Документы_Key", "ДокТип", "Док_ТоварыВПути_Key", "ДокНомер", "Дата", "СкладОтправитель_Key", "СкладПолучатель_Key", "Номенклатура_Key", "Количество"
    ,n."Наименование"
    ,n."Код"
from "Док_ТоварыВПути" tp
left join erp."Спр_Номенклатура" n on n."Ссылка_Key" = tp."Номенклатура_Key"
where true
--  and "ДокНомер" = 'AKTDU-00019'
  and "ДокНомер" = 'ALMDU-00370'
--  and "Документы_Key" = 'Док_ЗаказПоставщику_8DE100155D781E3211EEAFB50E0E71F4_8148ECB1D783C19E11EA1BCD4FBE7145'
;
drop view if exists "Док_ТоварыВПути.Keys";
create or replace view "Док_ТоварыВПути.Keys" as
    select "Документы_Key"
          ,"ДокТип"
          ,"Дата"
          ,"СкладРоль"
          ,"Склад_Key"      
          ,"Номенклатура_Key"       
    from (
        select "Документы_Key"
              ,"ДокТип"
              ,"Дата"
              ,'СкладОтправитель'                        as "СкладРоль"
              ,"СкладОтправитель_Key"                    as "Склад_Key"              
              ,"Номенклатура_Key"
        from "Док_ТоварыВПути" where "СкладОтправитель_Key" is not null
        union
        select "Документы_Key"
              ,"ДокТип"              
              ,"Дата"
              ,'СкладПолучатель'                         as "СкладРоль"
              ,"СкладПолучатель_Key"                     as "Склад_Key"              
              ,"Номенклатура_Key"
        from "Док_ТоварыВПути" where "СкладПолучатель_Key" is not null) t
    where true
--      and "Документы_Key" = 'Док_ЗаказНаПеремещение_BC3800074333BE5811EECC9197DC024F_BCAD386077DF642C11E5A96646151C69'
    order by "Дата"    
;
select *
from "Док_ТоварыВПути.Keys"
where true
  and "Документы_Key" = 'Док_ЗаказПоставщику_8DE100155D781E3211EEAFB50E0E71F4_8148ECB1D783C19E11EA1BCD4FBE7145'