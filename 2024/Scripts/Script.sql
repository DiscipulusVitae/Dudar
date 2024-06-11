--drop view if exists erp."Спр_Марки";
create or replace view erp."Спр_Марки" as -- Справочник.Марки
select
    _Version                                    as "ВерсияДанных"
   ,_PredefinedID                               as "ИмяПредопределенныхДанных"
   ,_Description                                as "Наименование"
   ,_Fld2367                                    as "ОбластьДанныхОсновныеДанные"
   ,_Marked                                     as "ПометкаУдаления"
   ,_Fld55063RRef                               as "Производитель_Key"
   ,_ParentIDRRef                               as "Родитель_Key"
   ,_IDRRef                                     as "Ссылка_Key"
   ,_Folder                                     as "ЭтоГруппа"
from erp._Reference281
;
comment on column erp."Спр_Марки"."Ссылка_Key" is '_IDRRef';
comment on column erp."Спр_Марки"."ВерсияДанных" is '_Version';
comment on column erp."Спр_Марки"."ПометкаУдаления" is '_Marked';
comment on column erp."Спр_Марки"."ИмяПредопределенныхДанных" is '_PredefinedID';
comment on column erp."Спр_Марки"."Родитель_Key" is '_ParentIDRRef';
comment on column erp."Спр_Марки"."ЭтоГруппа" is '_Folder';
comment on column erp."Спр_Марки"."Наименование" is '_Description';
comment on column erp."Спр_Марки"."Производитель_Key" is '_Fld55063RRef';
comment on column erp."Спр_Марки"."ОбластьДанныхОсновныеДанные" is '_Fld2367';

select *
from erp."Спр_Марки"
;
