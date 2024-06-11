-- РЕАЛИЗАЦИЯ
select p."Ссылка_Key"                            as "Док_Key"
	  ,p."Номер"                                 as "ДокНомер"
      ,p."Дата"::date                            as "Дата" /*ДатаДокумента*/
      ,p."Подразделение_Key"                     as "Организация_Key" /*при маппинге заменится на Организация_Key, который был в УТ*/
      --,p."Подразделение_Key"                     as "Подразделение_Key"  
      ,p."Склад_Key"                             as "Склад_Key"
      ,p."Партнер_Key"                           as "Партнер_Key"
      ,p."Дудар_ТорговыйПредставитель_Key"       as "ТорговыйАгент_Key"
      ,pt."Номенклатура_Key"                     as "Номенклатура_Key"
      ,'Реализация'                              as "ВидДвижения"
      ,p."Ссылка_Key"                            as "ДокументДвижения"
      ,pt."ПроцентАвтоматическойСкидки"          as "ПроцентАвтоматическойСкидки"
      ,pt."ПроцентРучнойСкидки"                  as "ПроцентРучнойСкидки"
      ,pt."Цена"                                 as "Цена"
      ,pt."Количество"                           as "Количество"
      ,pt."Сумма"                                as "Сумма"
      ,pt."СуммаАвтоматическойСкидки"            as "СуммаАвтоматическойСкидки"
      ,pt."СуммаРучнойСкидки"                    as "СуммаРучнойСкидки"
      ,pt."ЗаказКлиента_Key"                     as "Заказ_Key"
      ,pt."КодСтроки"                            as "ЗаказСтрока"
from      erp."Док_Реализация"                   as p                                             --Док_РеализацияТоваровУслуг
left join erp."Док_Реализация.Товары"            as pt on p."Ссылка_Key"  = pt."Ссылка_Key"       --Док_РеализацияТоваровУслуг.Товары
left join erp."Спр_СтруктураПредприятия"         as sp on sp."Ссылка_Key" = p."Подразделение_Key"
where true
  and p."Дата" >= '2024-01-01'
  and not p."ПометкаУдаления"
order by p."Дата", pt."КлючСвязи"
;
/* На всякий случай бэкаплю из скрипта Ежедневная загрузка больших
 * 240425 */
select p._IDRRef                                 as "Док_Key"
	  ,p._Number                                 as "ДокНомер"
      ,p._date_time::date                        as "Дата" /*ДатаДокумента*/
      ,case when sp._Description like '%_Структурное подразделение'
            then p._Fld29753RRef /*"Подразделение_Key"*/ /*при маппинге заменится на Организация_Key, который был в УТ*/
            else p._Fld29747RRef /*Организация_Key*/
       end                                       as "Организация_Key"
      ,p._Fld29756RRef                           as "Склад_Key"
      ,p._Fld29752RRef                           as "Партнер_Key"
      ,p._Fld65837RRef                           as "ТорговыйАгент_Key"
      ,pt._Fld29816RRef                          as "Номенклатура_Key"
      ,'Реализация'                              as "ВидДвижения"
      ,p._IDRRef                                 as "ДокументДвижения"
      ,pt._Fld29832                              as "ПроцентАвтоматическойСкидки"
      ,pt._Fld29831                              as "ПроцентРучнойСкидки"
      ,pt._Fld29823                              as "Цена"
      ,pt._Fld29821                              as "Количество"
      ,pt._Fld29824                              as "Сумма"      
      ,pt._Fld29830                              as "СуммаАвтоматическойСкидки"
      ,pt._Fld29829                              as "СуммаРучнойСкидки"
      ,pt._Fld29837_RRRef                        as "Заказ_Key"
      ,pt._Fld29828                              as "ЗаказСтрока"
from      erp._Document1206                      as p                                         --Док_РеализацияТоваровУслуг
left join erp._Document1206_VT29814              as pt on p._IDRRef = pt._Document1206_IDRRef --Док_РеализацияТоваровУслуг.Товары
left join erp._Reference620                      as sp on sp._IDRRef = p._Fld29753RRef        --Спр_СтруктураПредприятия
where true
  and p._date_time >= '2024-01-01'
  and p._Marked = false
order by p._date_time, pt._Fld29833;
/* * */

-- ВОЗВРАТ
select vz."Ссылка_Key"                            as "Док_Key"
      ,vz."Номер"                                 as "ДокНомер"
      ,vz."Дата"                                  as "Дата" /*ДатаДокумента*/
      ,vz."Подразделение_Key"                     as "Организация_Key" /*при маппинге заменится на Организация_Key, который был в УТ*/
      ,vz."Подразделение_Key"                     as "Подразделение_Key"
      ,vz."Склад_Key"                             as "Склад_Key"
      ,vz."Партнер_Key"                           as "Партнер_Key"
      ,vz."Дудар_ТорговыйПредставитель_Key"       as "ТорговыйАгент_Key"
      ,vzt."Номенклатура_Key"                     as "Номенклатура_Key"
      ,'Возврат'                                  as "ВидДвижения"
      ,vz."ДокументРеализации_Key"                as "ДокументДвижения"
      ,vzt."Цена"                                 as "Цена"
      ,-vzt."Количество"                          as "Количество"
      ,-vzt."Сумма"                               as "Сумма"
from      erp."Док_Возврат"                       as vz
left join erp."Док_Возврат.Товары"                as vzt on vz."Ссылка_Key"  = vzt."Ссылка_Key"  --Док_РеализацияТоваровУслуг.Товары
left join erp."Спр_СтруктураПредприятия"          as sp on sp."Ссылка_Key" = vz."Подразделение_Key"        
where vz."Дата"  >= '2024-01-01'
  and not vz."ПометкаУдаления";