-- 1. Создание БД "QlikBase" для подготовки данных Qlik Sense
create database "QlikBase"
    with owner = "QlikAnalytics"
    encoding = 'UTF8'
    lc_collate = 'ru_RU.UTF-8'
    lc_ctype = 'ru_RU.UTF-8'
    template = template0
    connection limit = -1;
-- 2. Создание метасхемы 1С:ERP
-- 2.1 Удаление "1C_ERP_Metadata"
drop table if exists public."1C_ERP_Metadata";
-- 2.2 Создание "1C_ERP_Metadata"
create table public."1C_ERP_Metadata" (    
        id serial primary key,
        "№" int,
        "1С Тип метаданных" text,
        "1C Метаданные" text,
        "1C Объект назначение" text,
        "1C Объект" text,        
        "1С Поле" text,
        "SQL Объект" text,
        "SQL Поле" text,
        "1С Поле подсказка" text
    );
-- 2.2 Создание полного индекса "1C_ERP_Metadata"
create index idx_1C_ERP_Metadata_on_fields on public."1C_ERP_Metadata" (id,
                                                               "1С Тип метаданных",
                                                               "1C Метаданные",
                                                               "1C Объект назначение",
                                                               "1C Объект",                                                               
                                                               "1С Поле",
                                                               "SQL Объект",
                                                               "SQL Поле",
                                                               "1С Поле подсказка"
                                                               );
-- 3. 2024-01-18 Импорт из csv через DBeaver
-- 4. Метасхема, выборки:
select id
      ,"1С Тип метаданных"
--      ,"1C Объект назначение"
      ,"1C Метаданные"      
      ,"1C Объект"      
      ,"1С Поле"
      ,"SQL Объект"
      ,"SQL Поле"
      ,"1С Поле подсказка"
from public."1C_ERP_Metadata"
where 1=1
--  and "1C Метаданные" like '%Документ.ПланПродажПоБрендам%'
  and "1C Метаданные" like '%Документ.РеализацияТоваровУслуг%' -- _Document1206
--  and "1C Метаданные" like '%РегистрНакопления.ЗаказыКлиентов%' -- _AccumRg46212
--  and "1C Метаданные" like '%Справочник.СкидкиНаценки%' -- _Reference530
--  and "1C Метаданные" like '%Справочник.Категории' --_Reference244
--  and "1C Метаданные" like '%Справочник.Контрагенты%' --_Reference277
--  and "1C Метаданные" like '%Справочник.Партнеры' --_Reference380
--  and "1C Метаданные" like '%Сеть%' -- нету
--  and "1C Метаданные" like '%Справочник.Пользователи' --_Reference425
--  and "1C Метаданные" like '%Справочник.ПодразделенияОрганизаций%'
--  and "1C Метаданные" like '%Справочник.СтруктураПредприятия%' --_Reference620
--  and "1C Метаданные" like '%Справочник.Склады' --_Reference537
--  and "1C Метаданные" like '%Справочник.ФизическиеЛица' --_Reference725
--  and "1C Объект" like '%Подразделение%'
--  and "1C Объект" like '%ЗаказКл%'
--  and "SQL Объект" like '%_Document1206%'
--  and "SQL Поле" like '%TRef%'
--  and "1С Поле" like '%ДокументОснование%'
order by "1C Метаданные"
        ,"1С Поле"
;