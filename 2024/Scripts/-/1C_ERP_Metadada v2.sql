-- 1. Создание БД "QlikBase" для подготовки данных Qlik Sense
create database "QlikBase"
    with owner = "QlikAnalytics"
    encoding = 'UTF8'
    lc_collate = 'ru_RU.UTF-8'
    lc_ctype = 'ru_RU.UTF-8'
    template = template0
    connection limit = -1;
-- 2. Создание метасхемы 1С:ERP
begin
    drop table if exists "1C_Metadata"
    create table "1C_Metadata" (
        id serial primary key,
        column1 text,
        "1C Объект" text,
        column3 text,
        column4 text,
        column5 text,
        column6 text,
        column7 text,
        column8 text,
        "1C Синоним" text,
        column10 text,
        column11 text,
        column12 text,
        column13 text,
        column14 text,
        column15 text,
        "SQL Объект" text,
        column17 text,
        column18 text,
        column19 text,
        column20 text,
        column21 text,
        column22 text,
        column23 text
    )
    create index idx_1c_metadata_on_fields on public."1C_Metadata" (id, "SQL Объект", "1C Объект", "1C Синоним")
end;
-- 3. 24012 Импорт из csv через DBeaver
do $$
declare
    rec record;
    last_value text;
begin
    -- Создание временной таблицы для хранения обновленных данных
--    create temp table temp_table as select * from "1C_Metadata";
    -- Инициализация переменной для хранения последнего ненулевого значения
    last_value := null
    -- Перебор строк таблицы для "1C Объект"
    for rec in select id, "1C Объект" from "1C_Metadata" order by id loop
        if rec."1C Объект" is not null and rec."1C Объект" <> '' then
            last_value := rec."1C Объект"
        else
            update "1C_Metadata" set "1C Объект" = last_value where id = rec.id
        end if
    -- Перебор строк таблицы для "1C Синоним"
    last_value := null
    for rec in select id, "1C Синоним" from "1C_Metadata" order by id loop
        if rec."1C Синоним" is not null and rec."1C Синоним" <> '' then
            last_value := rec."1C Синоним"
        else
            update "1C_Metadata" set "1C Синоним" = last_value where id = rec.id
        end if
    end loop
    -- Опционально: заменить оригинальную таблицу обновленными данными
--    delete from "1C Объект";
--    insert into "1C Объект" select * from temp_table;
    -- Удаление временной таблицы
--    drop table temp_table;
end $$;
-- 4. Метасхема, выборки:
select id
      ,"1C Синоним"
      ,"1C Объект"      
      ,"SQL Объект"from "1C_Metadata"
where 1=1
--  and "1C_Metadata"."1C Синоним" like '%Документ.ПланПродажПоБрендам%'
--  and "1C_Metadata"."1C Синоним" like '%Документ.РеализацияТоваровУслуг' -- _Document1206
--  and "1C_Metadata"."1C Синоним" like '%РегистрНакопления.ЗаказыКлиентов%' -- _AccumRg46212
  and "1C_Metadata"."1C Синоним" like '%Справочник.СкидкиНаценки%' -- _Reference530
--  and "1C_Metadata"."1C Синоним" like '%Справочник.Категории' --_Reference244
--  and "1C_Metadata"."1C Синоним" like '%Справочник.Контрагенты%' --_Reference277
--  and "1C_Metadata"."1C Синоним" like '%Справочник.Партнеры' --_Reference380
--  and "1C_Metadata"."1C Синоним" like '%Сеть%' -- нету
--  and "1C_Metadata"."1C Синоним" like '%Справочник.Пользователи' --_Reference425
--  and "1C_Metadata"."1C Синоним" like '%Справочник.ПодразделенияОрганизаций%'
--  and "1C_Metadata"."1C Синоним" like '%Справочник.СтруктураПредприятия%' --_Reference620
--  and "1C_Metadata"."1C Синоним" like '%Справочник.Склады' --_Reference537
--  and "1C_Metadata"."1C Синоним" like '%Справочник.ФизическиеЛица' --_Reference725
--  and "1C Объект" like '%Подразделение%'
--  and "1C Объект" like '%ЗаказКл%'
--  and "SQL Объект" like '%_Document1206%'
order by "1C Синоним"
        ,"1C Объект"
;