drop materialized view if exists "Номенклатура" cascade;
create materialized view "Номенклатура" as
    with recursive cte as (
      select _ParentIDRRef
            ,_IDRRef
            ,not(_Folder)                            as "IsFolder"
            ,_Code                                   as "ТоварКод"
            ,1 as depth -- начальный уровень глубины
            ,_Description::text as _Description_Path -- начальный путь
            ,_Description                            as "Товар"
            ,_Fld55757RRef                           as "Бренд_Key"
            ,_Fld67181RRef                           as "СтатусТовара_Key"
      from erp._Reference315 --Спр_Номенклатура
      where _ParentIDRRef = decode('00000000000000000000000000000000','hex') -- корневой узел
        and not (_Marked)
      union all
      select r._ParentIDRRef
            ,r._IDRRef
            ,not(r._Folder)                          as "IsFolder"
            ,r._Code                                 as "ТоварКод"
            ,cte.depth + 1 -- увеличение уровня глубины
            ,(cte._Description_Path || '➡️' || r._Description)::text -- добавление к пути
            ,_Description                            as "Товар"
            ,_Fld55757RRef                           as "Бренд_Key"
            ,_Fld67181RRef                           as "СтатусТовара_Key"
      from _Reference315 r
      join cte on r._ParentIDRRef = cte._IDRRef
      where 1=1
        and not (r._Marked)
    )
    select _IDRRef                                   as "Номенклатура_Key"
          ,"ТоварКод"
          ,"Товар"
          ,case when depth > 1 then split_part(_Description_Path, '➡️', depth - 1) else _Description_Path end as "ТоварГруппа"
          ,case when depth > 0 then split_part(_Description_Path, '➡️', depth)     else null              end as "ТоварПодгруппа"
          ,"Бренд_Key"
          ,"СтатусТовара_Key"
    from cte
    where "IsFolder" is false  
    order by "ТоварКод"
;
select *
from "Номенклатура" n
where true
  and n."ТоварКод" = '00000004255'
;
/*v1 */
with recursive cte as (
  select _ParentIDRRef
        ,_IDRRef                                 as "Товар_Key"
        ,not(_Folder)                            as "IsFolder"
        ,_Code                                   as "ТоварКод"
--        ,_Description::text as _Description1 -- описание корневого узла
--        ,null::text as _Description2 -- описание второго уровня
--        ,null::text as _Description3 -- описание третьего уровня
        ,1 as depth -- начальный уровень глубины
        ,_Description::text as _Description_Path -- начальный путь
        ,_Description                            as "Товар"
        ,_Fld55757RRef                           as "Марка_Key"
        ,_Fld67181RRef                           as "СтатусТовара_Key"
  from _Reference315
  where _ParentIDRRef = decode('00000000000000000000000000000000','hex') -- корневой узел
  union all
  select r._ParentIDRRef
        ,r._IDRRef                               as "Товар_Key"
        ,not(r._Folder)                          as "IsFolder"
        ,r._Code                                 as "ТоварКод"
--        ,cte._Description1 -- передача описания корневого узла
--        ,case
--          when cte.depth = 1 then r._Description::text
--          else cte._Description2
--        end as _Description2 -- задаем/передаем описание второго уровня
--        ,case when cte.depth = 2 then r._Description::text
--                                 else cte._Description3
--        end as _Description3 -- задаем/передаем описание третьего уровня
        ,cte.depth + 1 -- увеличение уровня глубины
        ,(cte._Description_Path || '➡️' || r._Description)::text -- добавление к пути
        ,_Description                            as "Товар"
        ,_Fld55757RRef                           as "Марка_Key"
        ,_Fld67181RRef                           as "СтатусТовара_Key"
  from _Reference315 r
  join cte on r._ParentIDRRef = cte._IDRRef
)
select _IDRRef as "Номенклатура_Key"
      ,_Code      
--      ,_Description1
--      ,_Description2
--      ,_Description3
--      ,depth
--      ,"IsFolder"
--      ,_Description_Path
      ,case when depth > 1 then split_part(_Description_Path, '➡️', depth - 1) else _Description_Path end as "ТоварГруппа"
      ,case when depth > 0 then split_part(_Description_Path, '➡️', depth)     else null             end as "ТоварПодгруппа"
from cte;