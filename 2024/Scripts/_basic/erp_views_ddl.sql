--💾 views save
SELECT * --'CREATE OR REPLACE VIEW ' || quote_ident(schemaname) || '.' || quote_ident(viewname) || ' AS ' || view_definition || ';'
FROM information_schema.views
WHERE schemaname = 'erp';

--📖 views read
DO $$
DECLARE
    view_ddl TEXT;
BEGIN
    FOR view_ddl IN SELECT view_definition FROM public.erp_views_ddl
    LOOP
        BEGIN
            EXECUTE view_ddl;
        EXCEPTION
            WHEN others THEN
                RAISE NOTICE 'Error executing view definition: %', view_ddl;
        END;
    END LOOP;
END $$;

--select *
--from erp_views_ddl ev
--where ev.view_definition like '%_chrc2332._fld50088%'
--;

/*
create or replace view erp."ПВХ_ДопРеквизитыИСведения" as  SELECT _chrc2332._description AS "Наименование",
    _chrc2332._fld2367 AS "ОбластьДанныхОсновныеДанные",
    _chrc2332._fld50073 AS "Виден",
    _chrc2332._fld50075 AS "ВыводитьВВидеГиперссылки",
    _chrc2332._fld50076 AS "ДополнительныеЗначенияИспользую",
    _chrc2332._fld50077 AS "ДополнительныеЗначенияСВесом",
    _chrc2332._fld50078 AS "Доступен",
    _chrc2332._fld50079 AS "Заголовок",
    _chrc2332._fld50080 AS "ЗаголовокФормыВыбораЗначения",
    _chrc2332._fld50081 AS "ЗаголовокФормыЗначения",
    _chrc2332._fld50082 AS "ЗаполнятьОбязательно",
    _chrc2332._fld50083 AS "Имя",
    _chrc2332._fld50084 AS "Комментарий",
    _chrc2332._fld50085 AS "МногострочноеПолеВвода",
    _chrc2332._fld50087 AS "Подсказка",
--    _chrc2332._fld50088 AS "УдалитьСклоненияПредмета",
    _chrc2332._fld50089 AS "ФорматСвойства",
    _chrc2332._fld50090 AS "ЭтоДополнительноеСведение",
    _chrc2332._idrref AS "Ссылка_Key",
    _chrc2332._marked AS "ПометкаУдаления",
    _chrc2332._predefinedid AS "ИмяПредопределенныхДанных",
    _chrc2332._type AS "ТипЗначения",
    _chrc2332._version AS "ВерсияДанных"
   FROM erp._chrc2332;;*/