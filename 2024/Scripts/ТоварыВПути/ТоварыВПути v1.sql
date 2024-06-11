drop view if exists "Док_ТоварыВПути";
create or replace view "Док_ТоварыВПути" as -- Справочник.Номенклатура
    with "ТоварыВПути.ЗаказыПоставщику"           as (
        select 'Док_ЗаказПоставщику'             as "ДокТип"
              ,zp."Ссылка_Key"                   as "Док_Key"
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
            left join erp."Док_ЗаказПоставщику.Товары" zpt on zp."Ссылка_Key" = zpt."Ссылка_Key"            
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
              ,zp."Ссылка_Key"                   as "Док_Key"
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
            where zp."Проведен"
            group by zp."Ссылка_Key", zpt."Номенклатура_Key"
        ) t on zp."Ссылка_Key" = t."Ссылка_Key"
        where not so."Наименование" like '%товары в пути%'
          and pot."Ссылка_Key" is null
          and zp."Проведен"
    )
    , "ТоварыВПути" as (select *
                        from "ТоварыВПути.ЗаказыПоставщику"
                        union all
                        select *
                        from "ТоварыВПути.Перемещения")
    select "ДокТип" || '_' ||
           upper(encode("Док_Key",'hex')) || '_' ||
           coalesce(upper(encode("СкладОтправитель_Key",'hex')),'') || '_' ||
           coalesce(upper(encode("СкладПолучатель_Key",'hex')),'') as "ТоварыВПути_Key"
          ,*
    from "ТоварыВПути"
;

select "ТоварыВПути_Key"
      ,'СкладОтправитель' as "СкладРоль"
      ,"СкладОтправитель_Key" as "Склад_Key"
from "Док_ТоварыВПути"
union
select "ТоварыВПути_Key"
      ,'СкладПолучатель' as "СкладРоль"
      ,"СкладПолучатель_Key" as "Склад_Key"
from "Док_ТоварыВПути"
;