with pl as (
/* ПЛАНЫ */
select p."НачалоПериода"::date /* _Fld32212 */             as "Дата"
     ,case when sp."Наименование" in ('Филиал г. Талдыкорган','Филиал г. Кокшетау','Филиал г.Жезказган') --like '%_Структурное подразделение'
           then  p."Подразделение_Key" /*_Fld32209RRef*/ /*при маппинге заменится на Организация_Key, который был в УТ*/
           else  u."Дудар_Организация_Key" /* _Fld67183RRef */
      end                                                  as "Организация_Key"
     ,p."Подразделение_Key" /*_Fld32209RRef*/
     ,pv."ТорговыйАгент_Key"
     ,pv."Бренд_Key"
     ,pv."Сумма"                                           as "План" /* В 1С: Cумма */     
from      erp."Док_ПланПродажПоБрендам.Бренды"             as pv
left join erp."Док_ПланПродажПоБрендам"                    as p  on pv."Ссылка_Key" = pv."Ссылка_Key" /*pv._Document1226_IDRRef = p._IDRRef*/
left join erp."Спр_Пользователи" /* _Reference425 */       as u  on u."Ссылка_Key" = pv."КодТорговогоАгента_Key" /* _Fld32244RRef */
left join erp."Спр_СтруктураПредприятия" /* Reference620 */as sp on sp."Ссылка_Key" = p."Подразделение_Key" /* _Fld32209RRef */ 
where p."НачалоПериода"  /* _Fld32212 */ >= '2024-01-01'
  and not p."ПометкаУдаления" /*_Marked*/
)
select	distinct
--	 u."КодТорговогоАгента"
	pl."Организация_Key"
	,pl."Подразделение_Key"
--	,pl.*	
from pl
left join erp."Спр_Пользователи" u on u."Ссылка_Key" = pl."ТорговыйАгент_Key"
where true
  and pl."Дата" = '2024-04-01'
  and u."КодТорговогоАгента" like 'tal_%'
--  and _Fld32244RRef = decode('00000000000000000000000000000000', 'hex')
--  and u._Fld67183RRef = decode('A39CAC1F6B3C78CA11EDFDFB246B0342', 'hex') --Алматы
--  and u._Fld67183RRef = decode('A3A5AC1F6B3C78CA11EE255793014822', 'hex') --'Филиал г. Тараз'  
--  and _Fld65835 like 'TAL_BC_A_1%'
order by 1;

select distinct
	 p."Подразделение_Key"
	,sp."Наименование"
	,u."Дудар_Организация_Key"
from      erp."Док_ПланПродажПоБрендам.Бренды"             as pv
left join erp."Док_ПланПродажПоБрендам"                    as p  on pv."Ссылка_Key" = pv."Ссылка_Key" /*pv._Document1226_IDRRef = p._IDRRef*/
left join erp."Спр_Пользователи" /* _Reference425 */       as u  on u."Ссылка_Key" = pv."КодТорговогоАгента_Key" /* _Fld32244RRef */
left join erp."Спр_СтруктураПредприятия" /* Reference620 */as sp on sp."Ссылка_Key" = p."Подразделение_Key" /* _Fld32209RRef */
where true
  and "Дата"::date = '2024-04-01'
;

select sp."Наименование"
	  ,sp."Ссылка_Key"
from erp."Спр_СтруктураПредприятия" sp
where true
 and sp."Ссылка_Key" = decode('A3A5AC1F6B3C78CA11EE25548C56EE06','hex')
--  and sp."Наименование" like 'Филиал%'
order by 1
;

--A3A5AC1F6B3C78CA11EE2554C89E64D8 Талдык

-- 240429 Старое.
with pl as (
/* ПЛАНЫ */
select p._Fld32212::date                         as "Дата" /*В 1С: НачалоПериода*/
     ,case when sp._Description in ('Филиал г. Талдыкорган','Филиал г. Кокшетау','Филиал г.Жезказган') --like '%_Структурное подразделение'
            then p._Fld32209RRef /*"Подразделение_Key"*/ /*при маппинге заменится на Организация_Key, который был в УТ*/
            else u._Fld67183RRef /*Дудар_Организация*/
       end                                       as "Организация_Key"
     --,p._Fld32209RRef                          as "Подразделение_Key"
     ,pv._Fld32244RRef                           as "ТорговыйАгент_Key"
     ,pv._Fld32234RRef                           as "Бренд_Key"
     ,pv._Fld32236                               as "План" /* В 1С: Cумма */
from      erp._Document1226_VT32232              as pv /*Документ.ПланПродажПоБрендам.ТабличнаяЧасть.Бренды*/
left join erp._Document1226 /*Документ.ПланПродажПоБрендам*/ as p on pv._Document1226_IDRRef = p._IDRRef
left join erp._Reference425 /*Спр_Пользователи */            as u on u._IDRRef = pv._Fld32244RRef /*КодТорговогоАгента*/       
left join erp._Reference620/*Спр_СтруктураПредприятия*/     as sp on sp._IDRRef = p._Fld32209RRef /*Подразделение_Key*/       
where p._Fld32212 /*НачалоПериода*/ >= '2024-01-01'
  and p._Marked=false
)
select	distinct
--	 u."КодТорговогоАгента"
	pl."Организация_Key"
--	,pl."Подразделение_Key"
--	,pl.*
	,sum(pl.План)
from pl
left join erp."Спр_Пользователи" u on u."Ссылка_Key" = pl."ТорговыйАгент_Key"
where true
  and "Дата"::date = '2024-04-01'
group by 1
;