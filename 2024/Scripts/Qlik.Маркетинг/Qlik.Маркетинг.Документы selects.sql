/* ПРОДАЖИ Заказ */
select *
from "Док_Заказ" zt
where true
  and zt."Док_Key" = decode('BC3700074333BE5811EEB456A65406E6','hex')  
;
--20240220
select
	   upper(encode(zt."Ссылка_Key",'hex'))--|| '_' || to_char(zt."НомерСтроки",'FM000') || '_' || upper(encode(zt."Номенклатура_Key",'hex'))
	  ,zt."НомерСтроки" -- || '_' || upper(encode(zt."Номенклатура_Key",'hex'))
--	   z."Док_Key"
--	  ,count(rt.*)
	  ,upper(encode(rt."Ссылка_Key",'hex')) || '_' || to_char(rt."НомерСтроки",'FM000')
--	  ,string_agg(upper(encode(rt."Ссылка_Key",'hex')) || '_' || to_char(rt."НомерСтроки",'FM000'),',')
--	  ,string_agg(rt."Номер"::text || '_' || to_char(rt."КодСтроки",'FM000'),',')
	  ,r."ПометкаУдаления" 
from      erp."Док_ЗаказКлиента.Товары" zt
left join erp."Док_Реализация.Товары"   rt on rt."ЗаказКлиента_Key" = zt."Ссылка_Key" 
                                          and rt."НомерСтроки" = zt."НомерСтроки"
left join erp."Док_Реализация" p on rt."Ссылка_Key" = r."Ссылка_Key"
--                         and zt."Номенклатура_Key"  = r.t"Номенклатура_Key"
where rt."Ссылка_Key" is not null
  and zt."Ссылка_Key" = decode('BC3700074333BE5811EEB456A65406E6','hex')
--group by 1,2
--order by 3 desc, 1, 2
;
--20240221
select distinct
	   zt."Док_Заказ_Key" --|| '_' || to_char(zt."КодСтроки",'FM000') -- || '_' || upper(encode(zt."Номенклатура_Key",'hex'))
--	   rt."Док_Реализация_Key"
--	  ,zt."КодСтроки"
--	   z."Док_Key"
	  ,count(distinct rt."Док_Реализация_Key")
--	  ,string_agg(upper(encode(rt."Док_Key",'hex')) || '_' || to_char(rt."КодСтроки",'FM000'),',')
--	  ,string_agg(upper(encode(rt."Док_Key",'hex')),',')
--	  ,string_agg(rt."КодСтроки"::text,',')
--	  ,string_agg(rt."Номер"::text || '_' || to_char(rt."КодСтроки",'FM000'),',')	  
from      "Док_Заказ" zt
left join "Док_Реализация"   rt on zt."Док_Заказ_Key"   = rt."Док_Заказ_Key"
--                           and zt."КодСтроки" = rt."КодСтроки"
--                         and zt."Номенклатура_Key"  = r.t"Номенклатура_Key"
--where rt."Док_Key" is not null
--  and zt."Док_Key" = decode('FE695415B2D2872D4FE117E83533957E','hex')
group by 1
order by 2 desc--, 1,2
;
/* ПРОДАЖИ Реализация */
select 
	--r."ЗаказКлиента_Key", 
	rt."ЗаказКлиента_Key", rt."КодСтроки"  
from      erp."Док_Реализация.Товары" rt
--left join erp."Док_Реализация" p on rt."Ссылка_Key" = r."Ссылка_Key"
--left join "Док_Заказ" z on z."Док_Key" = r."Заказ_Key"
where true
--and z."Док_Key" is null
--  and rt."ЗаказКлиента_Key" = decode('BC3700074333BE5811EEB522FE0999E1','hex')
--  and rt."ЗаказКлиента_Key" = decode('BC3700074333BE5811EEB456A65406E6','hex')
  and rt."Ссылка_Key" in (decode('8DE100155D781E3211EEAFA021983454','hex'),decode('8DE100155D781E3211EEAFA021983454','hex'),decode('8DE100155D781E3211EEAFA021983454','hex'))
--order by 1
;
select 	 
	r."Док_Заказ_Key"
	, r."КодСтроки"
from "Док_Реализация" r
where true
  and r."Док_Key" = decode('8DE100155D781E3211EEAFA021983454','hex')
--  and "Заказ_Key" = decode('BC3800074333BE5811EEC0BA5572BC64','hex')
;
select distinct
	   rt."Док_Реализация_Key"
	  ,rt."ДокНомер"
	  ,count(distinct vt."Док_Возврат_Key")	  
	  ,string_agg(distinct vt."ДокНомер"::text,',')
from      "Док_Реализация" rt
left join "Док_Возврат"    vt on vt."Док_Реализация_Key"   = rt."Док_Реализация_Key"
group by 1,2
order by 3 desc--, 1,2
;

-- ПРОДАЖИ проверка сколько записей на _RRRef
select r._IDRRef
    ,count(rt.*) as cnt_rt
    ,count(rs.*) as cnt_rs
    ,count(rs.*) > count(rt.*) as alarm
from      erp._Document1206                          as r                                         /*Док_РеализацияТоваровУслуг*/
left join erp._Document1206_VT29814                  as rt on r._IDRRef = rt._Document1206_IDRRef /*Док_РеализацияТоваровУслуг.Товары*/
left join erp._Document1206_VT29847                  as rs on r._IDRRef = rs._Document1206_IDRRef /*Док_РеализацияТоваровУслуг.СкидкиНаценки*/
                                               --       and rt._Keyfield = rs._Keyfield
where r._Marked = false
--  and r._Date_Time >= '2024-01-19'
group by r._IDRRef;

select z."Док_Заказ_Key"
	  ,z."НомерСтроки"
      ,count(distinct r."Док_Реализация_Key") as кол_реализаций
      ,count(distinct v."Док_Возврат_Key")    as кол_возвратов
from      "Док_Заказ"               as z
left join "Док_Реализация"          as r on r."Док_Заказ_Key" = z."Док_Заказ_Key"
									    and r."НомерСтроки"   = z."НомерСтроки"
left join "Док_Возврат"             as v on v."Док_Реализация_Key"  = r."Док_Реализация_Key"
                                        and v."НомерСтроки"   = r."НомерСтроки"
group by 1,2
order by 3 desc
       , 4 desc
;

select "ДокТип"
	  ,count("Документы_Key")
from "Док_ЗаказРеализацияВозврат"                            as zt
where "Дата" = '2024-03-01'
group by 1
;

select *
from "Док_ЗаказРеализацияВозврат"
where true 
  and "Док_ЗаказРеализацияВозврат"."Документы_Key" like 'Реализация_BC3800074333BE5811EEC7378E49AA3E_%'
;

select
	distinct r."Док_Реализация_Key"
	,u."КодТорговогоАгента"
--	,r."ДокНомер"
	,r."Дата"
	,p."Код"
	,p."Наименование"	
	,sum(r."Сумма") over (partition by u."КодТорговогоАгента")
from "Док_Реализация" r
left join erp."Спр_Партнеры" p on p."Ссылка_Key" = r."Партнер_Key"
left join erp."Спр_Пользователи" u on u."Ссылка_Key" = r."ТорговыйАгент_Key"
where true
  and p."Код" = 'AST-5553'
--  and u."КодТорговогоАгента" = 'AST-5553'
;
select *
from erp."Спр_Партнеры"
where true
  and true
;