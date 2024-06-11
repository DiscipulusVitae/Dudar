--[ПредзагрузкаНоменклатуры]:
--// ERP (+создание иерархии)
--hierarchy([Номенклатура_Key],[Parent_Key],[Товар])
select
     _IDRRef                        as "Номенклатура_Key"
    ,_IDRRef                        as "Номенклатура_Key_Tmp"
    ,_ParentIDRRef                  as "Parent_Key"    
    ,case when _Folder is true
          then '01' else '00' end   as "IsFolder" /*00 - папка, 01 - не папка*/
    ,_Code                          as "Code"
    ,_Description                   as "Товар"
    ,_Fld55757RRef                  as "Марка_Key"
    ,_Fld55771RRef                  as "ТоварнаяКатегория_Key"
    ,_Fld67181RRef                  as "СтатусТовара_Key"
from erp._Reference315              as "Спр_Номенклатура"
where not _Marked;
--// УТ (Иерархия уже есть в QVD)
--// Из УТ грузим только тех, кого нет в ERP
--concatenate([ПредзагрузкаНоменклатуры])
--load * from 'lib://Data:DataFiles/2020_2023/Спр_Номенклатура.qvd' (qvd)
--where not exists ([Номенклатура_Key_Tmp])
--// /* 240417 */ and not /* 240417 Игнорировать "подпапки" бренда Batiste */
--//	(match([Марка_Key],'8126ECB1D783C19E11E8D772742938C2','8126ECB1D783C19E11E8D772742938C3') /*Batiste*/
--  //    and ([Parent_Key] <> '8126ECB1D783C19E11E8D7722A3B6C7A' /*корневая папка Batiste*/)) 
--;
--drop field [Номенклатура_Key_Tmp]; //удаляем временное поле
--// 3. Формируем из иерархии группы и подгруппы товаров
--[Номенклатура]:
--load 
--	[Номенклатура_Key],
--    [Товар],
--    [СтатусТовара_Key],
--    if(Товар=Товар2,Товар1,Товар2) as [ГруппаТовара],
--    if(Товар=Товар3,Null(),Товар3) as [ПодгруппаТовара],
--    [Марка_Key],
--	[Code] as [ТоварКод],
--	num(num#(Code)) as [ТоварКодNum] //временный дубль без ведущих нулей, нужен будет для ГруппыКатегорииА
--resident [ПредзагрузкаНоменклатуры]
--where [IsFolder] = 01 /*00 - папка, 01 - не папка*/
--  and not ([Товар1] = 'Удаленный товар' and [Товар2] = 'Batiste') /* 240417 */
--;
--// if vEnableStoreToGD = True() then
-- 	store [ПредзагрузкаНоменклатуры] into 'lib://GDT/1_nq7Dc3ROB_w-VVh6yzqUUAo5B8CIupA/Qlik.Продажи.Товары.ПредзагрузкаНоменклатуры.$(vCurrentTimestamp).csv' (txt);
--// end if;
--drop table [ПредзагрузкаНоменклатуры];
--////////////////////////////////////////////////////////////////////////////////////////////////////////////
--[НоменклатураЦены]:
--// 1. УТ
--load * from 'lib://Data:DataFiles/2020_2023/НоменклатураЦены.qvd' (qvd);
--// 2. ERP
--concatenate([НоменклатураЦены])
with c as (
	select coalesce(cnp."Period",cn."Period")                     as "Period"	      
	      ,coalesce(cnp."Номенклатура_Key",cn."Номенклатура_Key") as "Номенклатура_Key"
	      ,"ЦенаПоставщика"
	      ,"ЦенаБазовая"
	from            (select distinct on (_Fld44575RRef /*Номенклатура_Key*/)
	                     _Period                           as "Period"
	                    ,_Fld44575RRef                     as "Номенклатура_Key"
	                    ,_Fld44578                         as "ЦенаПоставщика"
	                from  erp._InfoRg44572                 as РС_ЦеныНоменклатурыПоставщиков
	                where _Period >= '2024-01-01'
	                order by _Fld44575RRef /*Номенклатура_Key*/, _Period desc
	                ) cnp
	full outer join (select distinct on (_Fld44643RRef /*Номенклатура_Key*/)
	                      _Period                          as "Period"
	                     ,_Fld44643RRef                    as "Номенклатура_Key"
	                     ,_Fld44646                        as "ЦенаБазовая"
	                 from  erp._InfoRg44642                as РС_ЦеныНоменклатуры
	                 where _Period >= '2024-01-01'
	                   and _Fld44645RRef /*ВидЦены_Key*/ = decode('BA8A00025B01233611E5C644810DC6C8','hex')
	                 order by _Fld44643RRef /*Номенклатура_Key*/, _Period desc
	                ) cn
	on cnp."Номенклатура_Key" = cn."Номенклатура_Key"
)
select n."Наименование", c.*
from c
left join erp."Спр_Номенклатура" n on n."Ссылка_Key" = c."Номенклатура_Key"
order by n."Наименование";
--// 3. Добавляем к Номенклатуре наиболее свежие 1) базовую цену 2) цену поставщика
--left join ([Номенклатура])
--load [Номенклатура_Key]
--	,firstvalue([ЦенаБазовая])    as [ЦенаБазовая]
--    ,firstvalue([ЦенаПоставщика]) as [ЦенаПоставщика]
--resident [НоменклатураЦены]
--group by [Номенклатура_Key]
--order by [Period] desc;
--// 4. Удаляем таблицу предзагрузки
--drop table [НоменклатураЦены];
--////////////////////////////////////////////////////////////////////////////////////////////////////////////
--[СтатусТовара]:
--// 1. ERP
select _IDRRef                         as "СтатусТовара_Key"
      ,_Description                    as "СтатусТовара"
from erp._Reference67178 as Спр_СтатусТовара;
--// 2. УТ
--// concatenate ([СтатусТовара])
--// load [СтатусТовара_Key]
--// 	,[СтатусТовара]
--// from 'lib://Data:DataFiles/2020_2023/Спр_СтатусТовара.qvd' (qvd);
--// store [СтатусТовара] into 'lib://GDT/1_nq7Dc3ROB_w-VVh6yzqUUAo5B8CIupA/Qlik.Продажи.СтатусТовара.$(vCurrentTimestamp).csv' (txt);
--// 3. Добавляем объединение ERP и УТ в Номенклатуру
--left join ([Номенклатура])
--load * resident [СтатусТовара];
--drop field [СтатусТовара_Key];
--drop table [СтатусТовара];