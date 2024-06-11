-- Блок генерирует динамический SQL для создания view и комментов к каждому полю
do $$
declare
    i_object_1c text := 
    'Справочник.Марки'
    ;
    object_1c       text;
    object_1c_short text;
    object_sql      text;
    query_main      text;
    query_comments  text;
begin
    -- Выборка основной информации из метаданных для формирования query_mainа
    select "SQL Объект"
          ,"1C Объект"
          ,left(substring("1C Объект" from 1 for position('.' in "1C Объект")), 3) ||   '_' || -- Обрезаем первый элемент до трёх символов и заменяем первую точку на подчёркивание
           substring("1C Объект" from position('.' in "1C Объект") + 1)                        -- Добавляем оставшуюся часть строки после первой точки
    into object_sql, object_1c, object_1c_short from public."1C_ERP_Metadata"
    where "1C Объект" like i_object_1c and "1С Поле" <> '' and "SQL Поле" <> ''
    order by "1С Поле", "SQL Поле" limit 1;
    -- Формирование динамического запроса
    select 'select\n    ' || substring(string_agg(
        format(E'   ,%s%s as "%s"', "SQL Поле", rpad('', 43 - length("SQL Поле"), ' '), case when length("1С Поле")<=27 then "1С Поле" else "SQL Поле" end ||
            case right("SQL Поле", 4)
                when 'RRef' then '_Key'
                when 'TRef' then '_Tbl'
                when 'TYPE' then '_Type'
                else ''
            end
              ), '\n'
    order by "1С Поле", "SQL Поле"
    ), 5) || E'\nfrom erp.' || object_sql /*|| ' as "' || object_1c ||  '"'*/ || '\n;'
    into query_main
    from public."1C_ERP_Metadata"
    where "1C Объект" = i_object_1c and "1С Поле" <> '' and "SQL Поле" <> '';    
    -- Формирование комментариев для полей
    select string_agg(format(
        E'comment on column erp."%s"."%s" is ''%s'';', object_1c_short, case when length("1С Поле")<=27 then "1С Поле" else "SQL Поле" end ||
            case right("SQL Поле", 4)
                when 'RRef' then '_Key'
                when 'TRef' then '_Tbl'
                when 'TYPE' then '_Type'
                else ''
            end, case when length("1С Поле")<=27 then "SQL Поле" else "1С Поле" end), '\n')
    into query_comments
    from public."1C_ERP_Metadata"
    where "1C Объект" = i_object_1c and "1С Поле" <> '' and "SQL Поле" <> '';
    -- Вывод сформированного query_mainа вместе с комментариями
    raise notice '%', '--drop view if exists erp."' || object_1c_short || '";\n' ||
                      'create or replace view erp."' || object_1c_short || '" as -- ' || object_1c || '\n'
                  || query_main || '\n' || query_comments || '\n\nselect *\nfrom erp."' || object_1c_short || '"\n;';
end $$;

select --*
	   "1C Метаданные"
      ,"1C Объект"      
      ,"1С Поле"
      ,"SQL Объект"
      ,"SQL Поле"
      ,"1С Поле подсказка"
from public."1C_ERP_Metadata"
where 1=1
--  and "SQL Объект" like '_Document1206%'        -- 'Документ.РеализацияТоваровУслуг%'
--  and "SQL Объект" like '_Document1206_VT29814' -- 'Документ.РеализацияТоваровУслуг.Товары'
--  and "SQL Объект" like '_Document1206_VT29847' -- 'Документ.РеализацияТоваровУслуг.СкидкиНаценки'  
--  and "SQL Объект" like '_Document787'          -- 'Документ.ВозвратТоваровОтКлиента%
--  and "SQL Объект" like '_Document941%'         -- Документ.ЗаказКлиента
--  and "SQL Объект" like '_Reference530'         -- 'Справочник.СкидкиНаценки'
--  and "SQL Объект" like '_Reference620%'        -- Справочник.СтруктураПредприятия
--  and "SQL Объект" like '_Reference537'         -- Справочник.Склады
--  and "SQL Объект" like '_Reference315%'        -- Справочник.Номенклатура
--  and "SQL Объект" like '_Reference380%'        -- Справочник.Партнеры
--  and "SQL Объект" like '_Reference730%'        -- Справочник.Категории
--  and "SQL Объект" like '%_AccumRg49254%'       -- РегистрНакопления.ТоварыНаСкладах
--  and "SQL Объект" like '%_AccumRgT49264%'      -- РегистрНакопления.ТоварыНаСкладах.Итоги
--  and "SQL Объект" like '%_AccumRg48713%'       -- РегистрНакопления.СвободныеОстатки
--  and "SQL Объект" like '%VT29814%' -- Документ.ПланПродажПоБрендам.Бренды  
  and "1C Метаданные" like '%оставщик%' --
--  and lower("1С Поле") like '%адрес%'
--  and lower("1C Объект") like '%документ.реализ%'
--  and "1С Поле" not like '%Отпуск%'
--  and "1C Объект" like '%беспечени%' --_AccumRg49254
--  and "1С Поле подсказка" like '%скидк%'
order by "1C Объект"
        ,"1С Поле"
--        ,"SQL Объект"
;