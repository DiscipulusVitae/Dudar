/* ПАРТНЕРЫ Категории */
with recursive cte as (
  select _ParentIDRRef
        ,_IDRRef
        ,_Code                                   as "КатегорияКод"
        ,not(_Folder)                           as "_IsFolder"
        ,1                                       as _Depth -- начальный уровень глубины
        ,_Description::text                      as _Description_Path -- начальный путь
        ,_Description::text                      as "Категория"        
  from _Reference730 --Спр_Категорияы
  where _ParentIDRRef = decode('00000000000000000000000000000000','hex') -- корневой узел
    and not (_Marked)
  union all
  select r._ParentIDRRef
        ,r._IDRRef
        ,r._Code
        ,not(_Folder)
        ,cte._Depth + 1 -- увеличение уровня глубины
        ,(cte._Description_Path || '➡️' || r._Description)::text -- добавление к пути
        ,_Description::text        
  from _Reference730 r
  join cte on r._ParentIDRRef = cte._IDRRef
  where 1=1
    and not (r._Marked)
)
select _Depth
      ,"КатегорияКод"
      ,_Description_Path
      ,case when _Depth <= 2 then split_part(_Description_Path, '➡️', 1)
                             else split_part(_Description_Path, '➡️', _Depth - 2)
       end as "КатегорияГруппа"
      ,case when _Depth <= 1 then split_part(_Description_Path, '➡️', 1)
                             else split_part(_Description_Path, '➡️', _Depth - 1)
       end as "КатегорияПодгруппа"
      ,"Категория"
     --_IDRRef                                   as "Категория_Key"
from cte as "Категорияы"
where "_IsFolder" is false -- Исключаем "папки"
  and _Description_Path <> ''
order by _Description_Path;