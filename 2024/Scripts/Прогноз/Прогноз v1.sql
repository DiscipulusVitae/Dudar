call _calendar_refresh()
;
show client_min_messages 
;
select current_timestamp
;
create or replace procedure _calendar_refresh() as $$
begin
	-- Изменяем уровень логирования, чтобы notice-сообщения не отправлялись клиенту
	set client_min_messages to warning;
	-- 1. Создание таблицы _calendar с диапазоном дат текущего года и определением типа дня
--	drop table if exists _calendar cascade;
	create table if not exists _calendar as
	with date_series as (
	    select generate_series(date_trunc('year', current_date), 
	                           date_trunc('year', current_date) + interval '1 year' - interval '1 day', 
	                           '1 day')::date as _date
	),
	date_types as (
	    select
	        _date,
	        case
		        when _date = date_trunc('month', _date + interval '1 month') - interval '1 day' then 'EOM'
	            when extract(dow from _date) = 6 then 'Saturday'            
	            when extract(dow from _date) = 0 then 'Sunday'
	            else 'Workday'
	        end as _day_type
	    from date_series
	)
	select _date
	      ,_day_type
	      ,case _day_type when 'EOM'      then 'SaturdayEOM'
	                     when 'Saturday' then 'Sunday' --'SaturdayEOM' -- 240506 Александра Голядкина: почему Вы считаете вообще субботы? у торговых же везде 5ти дневка сейчас
	                     when 'Sunday'   then 'Sunday'
	                     when 'Workday'  then 'Workday'
	       end as _day_type_forecast
	from date_types
	order by _date;
	-- 2. Добавляем праздники вручную. Обновление значений _day_type и _day_type_forecast для конкретных дат
	update _calendar
	set _day_type         = v._day_type_new,
	    _day_type_forecast = v._day_type_forecast_new
	from (values  ('2024-03-08', 'Holiday', 'SaturdayEOM')
	             ,('2024-03-09', 'Holiday', 'Sunday')
	             ,('2024-03-22', 'Holiday', 'SaturdayEOM')
	             ,('2024-03-23', 'Holiday', 'Sunday')
	             --,('2024-05-01', 'Holiday', 'Sunday') -- 240506
	             --,('2024-05-04', 'Holiday', 'Workday') -- 240506
	             --,('2024-05-05', 'Holiday', 'Sunday')-- 240506	             
	             ,('2024-05-07', 'Holiday', 'Sunday')
	             --,('2024-05-08', 'Holiday', 'Sunday') -- 240506
	             --,('2024-05-09', 'Holiday', 'Sunday') -- 240506	             
	) as v(_date, _day_type_new, _day_type_forecast_new)
	where _calendar._date = v._date::date;
	-- 3. Прошлые у будущие даты разбиваем по разным колонкам
--	drop view if exists _calendar_forecast cascade;
	create or replace view _calendar_forecast as
		select _date              as "Дата"
			  ,null               as "Дата.Прогноз"
			  ,_day_type_forecast as "Дата.ТипДня"
		from _calendar
		where _date >= current_date::date - interval '30 day'
		  and _date <= current_date::date - interval '1 day'
		union
		select null               as "Дата"
			  ,_date              as "Дата.Прогноз"
			  ,_day_type_forecast as "Дата.ТипДня"
		from _calendar
		where _date >= current_date::date
		  and _date <= date_trunc('month', current_date + interval '1 month') - interval '1 day'
		order by 1,2;
	-- 4. Подсчитываем дни каждого типа, для дальнейшего присвоения переменным Qlik Sense
--	drop view if exists _calendar_days_count cascade;
	create or replace view _forecast_pp_days_count as -- pp = past period	
		select sum(case when "Дата.ТипДня" = 'Workday' then 1 else 0 end)     as pp_wd_cnt --workday_count    
			      ,sum(case when "Дата.ТипДня" = 'SaturdayEOM' then 1 else 0 end) as pp_se_cnt --saturdayeom_count
			      ,sum(case when "Дата.ТипДня" = 'Sunday' then 1 else 0 end)      as pp_sd_cnt --sunday_count     
			from _calendar_forecast
			where "Дата" is not null
	;
	create or replace view _forecast_fp_days_count as -- fp = future/forecast period
		select sum(case when "Дата.ТипДня" = 'Workday' then 1 else 0 end)     as fp_wd_cnt --workday_count
		      ,sum(case when "Дата.ТипДня" = 'SaturdayEOM' then 1 else 0 end) as fp_se_cnt --saturdayeom_count
		      ,sum(case when "Дата.ТипДня" = 'Sunday' then 1 else 0 end)      as fp_sd_cnt --sunday_count  
		from _calendar_forecast
		where "Дата.Прогноз" is not null
	;
	-- Сброс настроек логирования после выполнения запроса, если это необходимо
	reset client_min_messages;
end;
$$ language plpgsql;

with pp0 as (
	select /*distinct c._date 
		  ,c._day_type_forecast
		  ,o."Наименование" as "Организация"
		  ,count(zt."Документы_Key") as "Документов"	  
		  ,*/count(distinct case when c._day_type_forecast = 'Workday' then c._date end)     as pp_wd_cnt
		  ,sum(case when c._day_type_forecast = 'Workday' then zt."Сумма" else 0 end)        as pp_wd_sum
		  ,count(distinct case when c._day_type_forecast = 'SaturdayEOM' then c._date end)   as pp_se_cnt
		  ,sum(case when c._day_type_forecast = 'SaturdayEOM' then zt."Сумма" else 0 end)    as pp_se_sum
		  ,count(distinct case when c._day_type_forecast = 'Sunday' then c._date end)      as pp_sd_cnt
		  ,sum(case when c._day_type_forecast = 'Sunday' then zt."Сумма" else 0 end)         as pp_sd_sum
	from _calendar c
	left join "Док_ЗаказРеализацияВозврат"           as zt on zt."Дата" = c._date
	                                                      and zt."ДокТип" = 'Реализация'
	left join erp."Спр_Склады"                       as s  on s."Ссылка_Key" = zt."Склад_Key"
	left join erp."Спр_Организации"                  as o  on o."Ссылка_Key" = s."Дудар_Организация_Key"
	where true
	  and c._date >= current_date - interval '30 days'
	  and c._date < current_date
	--  and zt."ДокТип" = 'Реализация'
	--group by 1 --,2,3
	--order by 1
)
,pp as (
	select
		   pp_wd_cnt
		  ,pp_wd_sum
		  ,pp_wd_sum/pp_wd_cnt                    as pp_wd_avg
		  ,pp_se_cnt
		  ,pp_se_sum
		  ,pp_se_sum/pp_se_cnt                    as pp_se_avg
		  ,pp_sd_cnt
		  ,pp_sd_sum
		  ,pp_sd_sum/pp_wd_cnt                    as pp_sd_avg
	from pp0
)
,pp_fp as (
	select
		   pp.*
		  ,fp_wd_cnt
		  ,fp_wd_cnt*pp_wd_avg                    as fp_wd_sum
		  ,pp_wd_avg                              as fp_wd_avg
		  ,fp_se_cnt
		  ,fp_se_cnt*pp_se_avg                    as fp_se_sum
		  ,pp_se_avg                              as fp_se_avg
		  ,fp_sd_cnt
		  ,fp_sd_cnt*pp_sd_avg                    as fp_sd_sum
		  ,pp_sd_avg                              as fp_sd_avg
	from pp
	cross join _forecast_fp_days_count fp
)
select pp_wd_sum+pp_se_sum+pp_sd_sum as "Продажи", fp_wd_sum+fp_se_sum+fp_sd_sum as "прогноз", *
from pp_fp
;

with future_period_ratios as (
  select
    sum(case when "Дата.ТипДня" = 'Workday' then 1.0 else 0 end) / count(*) as fp_wd_ratio,
    sum(case when "Дата.ТипДня" = 'SaturdayEOM' then 1.0 else 0 end) / count(*) as fp_se_ratio,
    sum(case when "Дата.ТипДня" = 'Sunday' then 1.0 else 0 end) / count(*) as fp_sd_ratio
  from _calendar_forecast
		where "Дата.Прогноз" is not null  
),
sales_ratios as (
  select
    (select fp_wd_ratio from future_period_ratios) * pp_wd_sum as pp_wd_forecast,
    (select fp_se_ratio from future_period_ratios) * pp_se_sum as pp_se_forecast,
    (select fp_sd_ratio from future_period_ratios) * pp_sd_sum as pp_sd_forecast
)
select
  (pp_wd_forecast + pp_se_forecast + pp_sd_forecast) as total_forecast
from sales_ratios
;
-----------------------------------------------------------------------------------------------------------------------------------------------
select
	--count(*)
	*
from "_calendar" c
where "_date" >= '2024-05-01'
and "_date" <= '2024-05-31'
--and "_day_type_forecast" = 'Workday'
order by "_date"
;