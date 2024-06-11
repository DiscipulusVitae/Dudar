--call refresh_all_materialized_views();
refresh materialized view "Док_Заказ";
refresh materialized view "Док_Реализация";
refresh materialized view "Док_Возврат";
refresh materialized view "Док_ЗаказРеализацияВозврат";
/* ЗАКАЗ */
drop materialized view if exists "Док_Заказ";
create materialized view "Док_Заказ" as
--select "ДокТип" || '_' || upper(encode("Док_Заказ_Key",'hex')) || '_' || to_char("КодСтроки",'FM000') as "Документы_Key"
--      ,*
--from (
    select 'Заказ'                                    as "ДокТип"
          ,z."Ссылка_Key"                             as "Док_Заказ_Key"
          ,null::bytea                                as "Док_Реализация_Key"
          ,null::bytea                                as "Док_Возврат_Key"
          ,z."Номер"                                  as "ДокНомер"
          ,z."Дата"::date                             as "Дата"          
          ,z."Дудар_ТорговыйПредставитель_Key"        as "ТорговыйАгент_Key"
          ,z."Партнер_Key"                            as "Партнер_Key"
          ,z."Склад_Key"                              as "Склад_Key"
          ,zt."Номенклатура_Key"                      as "Номенклатура_Key"
          ,zt."ПроцентАвтоматическойСкидки"           as "ПроцентАвтоматическойСкидки"
          ,zt."ПроцентРучнойСкидки"                   as "ПроцентРучнойСкидки"
          ,zt."Цена"                                  as "Цена"
          ,zt."Количество"                            as "Количество"
          ,zt."Сумма"                                 as "Сумма"
          ,zt."СуммаАвтоматическойСкидки"             as "СуммаАвтоматическойСкидки"
          ,zt."СуммаРучнойСкидки"                     as "СуммаРучнойСкидки"          
          ,zt."НомерСтроки"                           as "НомерСтроки"
          ,zt."КлючСвязи"                             as "КлючСвязи"
          ,zt."КодСтроки"                             as "КодСтроки"
          ,zt."ВариантОбеспечения_Key"                as "ВариантОбеспечения_Key"
    from      erp."Док_ЗаказКлиента"                  as z
    left join erp."Док_ЗаказКлиента.Товары"           as zt on zt."Ссылка_Key" = z."Ссылка_Key"
--    left join erp."Док_ЗаказКлиента.СкидкиНаценки"    as zs on zs."Ссылка_Key" = zt."Ссылка_Key"
--                                                           and zs."КлючСвязи"  = zt."КлючСвязи"
--    left join erp."Спр_СкидкиНаценки"                 as sk on sk."Ссылка_Key" = zs."СкидкаНаценка_Key"
--    left join erp."Док_Реализация"                    as r on r."ЗаказКлиента_Key" = z."Ссылка_Key"
--    left join erp."Док_Возврат"                       as v on v."ДокументРеализации_Key" = r."Ссылка_Key"
    where true
      and z."ПометкаУдаления" = false
      and z."Дата" >= '2024-01-01'
--      and sk."Ссылка_Key" <> decode('896A00155D781E3211EEAA26E5D8324E','hex') -- Округление суммы документа, точность 1
    order by z."Дата", zt."КодСтроки"
--) t
;
create unique index "pk_Док_Заказ_Key_НомерСтроки"    on "Док_Заказ"("Док_Заказ_Key", "НомерСтроки")
;
/* РЕАЛИЗАЦИЯ */
drop materialized view if exists "Док_Реализация" cascade;
create materialized view "Док_Реализация" as
--select "ДокТип" || '_' ||  upper(encode("Док_Реализация_Key",'hex')) || '_' || to_char("КодСтроки",'FM000') as "Документы_Key"
--      ,*
--from (
    select 'Реализация'                               as "ДокТип"
          ,r."ЗаказКлиента_Key"                       as "Док_Заказ_Key"
          ,r."Ссылка_Key"                             as "Док_Реализация_Key"
          ,null::bytea                                as "Док_Возврат_Key"
          ,r."Номер"                                  as "ДокНомер"
          ,r."Дата"::date                             as "Дата"
          ,r."Дудар_ТорговыйПредставитель_Key"        as "ТорговыйАгент_Key"
          ,r."Партнер_Key"                            as "Партнер_Key"                    
          ,rt."Склад_Key"                             as "Склад_Key"
          ,rt."Номенклатура_Key"                      as "Номенклатура_Key"
          ,rt."ПроцентАвтоматическойСкидки"           as "ПроцентАвтоматическойСкидки"
          ,rt."ПроцентРучнойСкидки"                   as "ПроцентРучнойСкидки"
          ,rt."Цена"                                  as "Цена"
          ,rt."Количество"                            as "Количество"
          ,rt."Сумма"                                 as "Сумма"
          ,rt."СуммаАвтоматическойСкидки"             as "СуммаАвтоматическойСкидки"
          ,rt."СуммаРучнойСкидки"                     as "СуммаРучнойСкидки"          
          ,rt."НомерСтроки"                           as "НомерСтроки"
          ,rt."КлючСвязи"                             as "КлючСвязи"
          ,rt."КодСтроки"                             as "КодСтроки"
          ,null::bytea                                as "ВариантОбеспечения_Key"
    from      erp."Док_Реализация"                    as r
    left join erp."Док_Реализация.Товары"             as rt on r."Ссылка_Key" = rt."Ссылка_Key"
--    left join erp."Док_ЗаказКлиента"                  as z on z."Ссылка_Key" = r."ЗаказКлиента_Key"
--    left join erp."Док_Возврат"                       as v on v."ДокументРеализации_Key" = r."Ссылка_Key"
    where true
      and r."Дата">= '2024-01-01'
      and r."ПометкаУдаления" = false
    order by r."Ссылка_Key"
--) t
;
create index if not exists "idx_Док_Реализация"       on "Док_Реализация"("Док_Заказ_Key","НомерСтроки","Док_Реализация_Key");
--create index if not exists idx_Док_Реализация_Key_НомерСтроки on "Док_Реализация"("Док_Заказ_Key","НомерСтроки");
/* ВОЗВРАТ */
drop materialized view if exists "Док_Возврат" cascade;
create materialized view "Док_Возврат" as
--select "ДокТип" || '_' ||  upper(encode("Док_Возврат_Key",'hex')) || '_' || to_char("НомерСтроки",'FM000') as "Документы_Key"
--      ,*
--from (
	  select 'Возврат'                                as "ДокТип"
             ,r."ЗаказКлиента_Key"                    as "Док_Заказ_Key"
             ,r."Ссылка_Key"                          as "Док_Реализация_Key"
             ,v."Ссылка_Key"                          as "Док_Возврат_Key"
             ,v."Номер"                               as "ДокНомер"
             ,v."Дата"::date                          as "Дата"             
             ,v."Дудар_ТорговыйПредставитель_Key"     as "ТорговыйАгент_Key"
             ,v."Партнер_Key"                         as "Партнер_Key"
             ,v."Склад_Key"                           as "Склад_Key"
             ,vt."Номенклатура_Key"                   as "Номенклатура_Key"
             ,null::numeric(5, 2)                     as "ПроцентАвтоматическойСкидки"
             ,null::numeric(5, 2)                     as "ПроцентРучнойСкидки"
             ,vt."Цена"                               as "Цена"
             ,-vt."Количество"                        as "Количество"
             ,-vt."Сумма"                             as "Сумма"
             ,null::numeric(15, 2)                    as "СуммаАвтоматическойСкидки"
	         ,null::numeric(15, 2)                    as "СуммаРучнойСкидки"	         
             ,vt."НомерСтроки"                        as "НомерСтроки"
             ,null::numeric(10)                       as "КлючСвязи"
             ,vt."КодСтроки"                          as "КодСтроки"
             ,null::bytea                             as "ВариантОбеспечения_Key"
       from      erp."Док_Возврат"                    as v
       left join erp."Док_Возврат.Товары"             as vt on v."Ссылка_Key" = vt."Ссылка_Key"       
       left join erp."Док_Реализация"                 as r on r."Ссылка_Key" = v."ДокументРеализации_Key"
--       left join erp."Док_ЗаказКлиента"                    as z on z."Ссылка_Key" = r."ЗаказКлиента_Key"
       where v."Дата" >= '2024-01-01'
         and v."ПометкаУдаления" = false
--) t
;
create index if not exists "idx_Док_Возврат"          on "Док_Возврат"("Док_Заказ_Key","НомерСтроки","Док_Реализация_Key","Док_Возврат_Key");
/* ЗАКАЗ+РЕАЛИЗАЦИЯ+ВОЗВРАТ */
drop materialized view if exists "Док_ЗаказРеализацияВозврат" cascade;
create materialized view "Док_ЗаказРеализацияВозврат" as
select d.*
	  ,sk."Наименование"                              as "СкидкаНаценка"
	  ,zs."Сумма"                                     as "СкидкаНаценка_Сумма"
from (select * from "Док_Заказ"
	  union all
	  select * from "Док_Реализация"
	  union all
	  select * from "Док_Возврат") d
left join erp."Док_ЗаказКлиента.СкидкиНаценки" zs on d."ДокТип" = 'Заказ'
                                                 and zs."Ссылка_Key" = d."Док_Заказ_Key"
                                                 and zs."КлючСвязи"  = d."КлючСвязи"
left join erp."Спр_СкидкиНаценки"              sk on sk."Ссылка_Key" = zs."СкидкаНаценка_Key"
                                                 and sk."Ссылка_Key" <> decode('896A00155D781E3211EEAA26E5D8324E','hex')
;
create index if not exists "idx_Док_ЗаказРеализацияВозврат"  on "Док_ЗаказРеализацияВозврат"("Документы_Key");
create index if not exists "idx_ДокТип"                      on "Док_ЗаказРеализацияВозврат"("ДокТип");
