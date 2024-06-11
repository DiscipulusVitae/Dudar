/* КОНТРАГЕНТЫ */
select
     p._IDRRef                                   as "Партнер_Key"
    ,p._Code                                     as "КодКонтрагент"
    ,p._Description                              as "Контрагент"
    ,p._Fld19896RRef                             as "Категория_Key" /*231123 ДТ берём категорию из другого реквизита Дудар_Категория*/
    ,p._Fld982887RRef                            as "СетьКлиента_Key"
    ,s._Description                              as "Сеть"
    ,p._Fld19887                                 as "ПартнерШирота"
    ,p._Fld19888                                 as "ПартнерДолгота"
    ,k._IDRRef                                   as "Контрагент_Key"
from      "Center_2021".dbo."_Reference135"      as k /*"Спр_Контрагенты"*/ with (nolock)
left join "Center_2021".dbo."_Reference173"      as p /*Спр_Партнеры*/      with (nolock)
       on k._Fld3294RRef = p._IDRRef                  /*Партнер_Key*/
left join "Center_2021".dbo."_Reference982886"   as s /*Спр_СетьКлиентов*/  with (nolock)
       on p._Fld982887RRef = s._IDRRef                /*СетьКлиента_Key*/
where p._Marked=00--  and p._Code = 'ALM-7158'
;  
/* КОНТРАГЕНТЫ Категории */ 
select
     _IDRRef                                as "Категория_Key"
    ,_ParentIDRRef                          as "РодительКатегория_Key"
    ,_Folder                                as "_Folder"
    ,_Description                           as "КатегорияКонтрагент"
from "Center_2021".dbo."_Reference19893"    as "Спр_Категории" with (nolock);
select * from "Center_2021".dbo."_Reference19893"
where 1=1--_IDRRef = 0x80E9ECB1D783C19E11E723EA67849600
  and _IDRRef = 0x8137ECB1D783C19E11E9A917EFE29E5id2; --Категория_Key
/* БРЕНДЫ */
select distinct
    _IDRRef
    ,_Description
from Center_2021.dbo._Reference141          as "Спр_Марки"         with (nolock)              
order by 2;
/* ТОВАРЫ Номенклатура */
select
     _IDRRef                                as "Номенклатура_Key"
    ,_ParentIDRRef                          as "Parent_Key"
    ,_Folder                                as "IsFolder" /*00 - папка, 01 - не папка*/
    ,_Code                                  as "Code"
    ,_Description                           as "Товар"
    ,_Fld3594RRef                           as "Марка_Key"
    ,_Fld3609RRef                           as "ТоварнаяКатегория_Key"
    ,_Fld20638RRef                          as "СтатусТовара_Key"
from Center_2021.dbo._Reference150          as "Спр_Номенклатура" with (nolock)
--where _Code = '00-00001217'
order by "Code";
/* ТОВАРЫ ЦеныНоменклатуры */
select coalesce(cnp."Period",cn."Period")                     as "Period"
      ,coalesce(cnp."Номенклатура_Key",cn."Номенклатура_Key") as "Номенклатура_Key"
      ,"ЦенаПоставщика"
      ,"ЦенаБазовая"
from            (select _Period                      as "Period"
                       ,_Fld17503RRef                as "Номенклатура_Key"
                       ,_Fld17506                    as "ЦенаПоставщика"                     
                       ,row_number() over (partition by _Fld17503RRef /*Номенклатура_Key*/ order by _Period desc) as rn
                 from Center_2021.dbo._InfoRg17500   as РС_ЦеныНоменклатурыПоставщиков with (nolock)
                 where _Period <= datefromparts(4023,12,31)
                ) cnp
full outer join (select _Period                      as "Period"
                       ,_Fld17488RRef                as "Номенклатура_Key"
                       ,_Fld17491                    as "ЦенаБазовая"
                       ,row_number() over (partition by _Fld17488RRef /*Номенклатура_Key*/ order by _Period desc) as rn
                 from Center_2021.dbo._InfoRg17487 as РС_ЦеныНоменклатуры with (nolock)    
                 where _Period <= datefromparts(4023,12,31)
                   and _Fld17489RRef /*ВидЦены_Key*/ = 0xBA8A00025B01233611E5C644810DC6C8 /*ВидЦены = Базовая*/
                ) cn
on cnp.[Номенклатура_Key] = cn.[Номенклатура_Key] and cnp.rn = 1 and cn.rn = 1; /* rn = 1 самая свежая цена*/;
/* ТОВАРЫ СтатусТовара */
select _IDRRef                                as "СтатусТовара_Key"
      ,_Description                           as "СтатусТовара"
from Center_2021.dbo._Reference20635        as Спр_СтатусТовара with (nolock);
/* СКЛАДЫ */
select 
     _IDRRef                                as "Склад_Key"
    ,_Description                           as "Склад"
    ,case
        when _Description like '%основно%'   then 'Основной'
        when _Description like '%стикер%'    then 'Стикеровка'
        when _Description like '%распродаж%' then 'Распродажа'
        when _Description like '%реклам%'    then 'Реклама'
                                             else 'Другие'
    end                                     as "КатегорияСклада"
    ,_Fld24480RRef                          as "Дудар_Организация_Key"
from Center_2021.dbo._Reference242          as "Спр_Склады"   with (nolock);
/* ПРОДАЖИ */
select dateadd(year,-2000,_Fld26723) as "Дата"
      ,_Fld25518RRef                 as "Организация_Key"
      ,_Fld25519RRef                 as "Партнер_Key"
      ,_Fld25524RRef                 as "Склад_Key"
      ,_Fld25526RRef                 as "ТорговыйАгент_Key"
      ,_Fld25531RRef                 as "Номенклатура_Key"
      ,_Fld25587_RTRef               as "ВидДвижения"
      ,_Fld25587_RRRef               as "ДокументДвижения"
      ,_Fld26606                     as "ПроцентАвтоматическойСкидки"
      ,_Fld26607                     as "ПроцентРучнойСкидки"
      ,_Fld26613                     as "Цена"
      ,_Fld25535                     as "Количество"
      ,_Fld26613*_Fld25535           as "СуммаБазовая"
      ,_Fld25536                     as "Сумма"
      ,_Fld26608                     as "СуммаАвтоматическойСкидки"
      ,_Fld26609                     as "СуммаРучнойСкидки"
--      ,_Fld26612RRef                as СкидкаНаценка_Key
from Center_2021.dbo._AccumRg25517 as РН_ДударПродажи with (nolock)
where _Fld26723 <= datefromparts(4023,12,31);
-- ПРОДАЖИ проверка сколько записей на _RRRef
select _Fld25587_RRRef, count(distinct _Fld26723) as cnt
from Center_2021.dbo._AccumRg25517 as РН_ДударПродажи with (nolock)
group by _Fld25587_RRRef;
/* ОСТАТКИ ТоварыНаСкладах_Итоги */
select
     _Fld19038RRef                          as "Склад_Key"
    ,_Fld19035RRef                          as "Номенклатура_Key"
    ,_Fld19041                              as "ОстатокШтуки" /*в 1С: ВНаличии*/
from Center_2021.dbo._AccumRgT19044         as "РН_ТоварыНаСкладах_Итоги" with (nolock)
where _Period > datefromparts(Year(sysdatetime())+2000, month(sysdatetime()), day(sysdatetime()));
/* ФИЛИАЛЫ */
select distinct
    _IDRRef
    ,_Description
from Center_2021.dbo._Reference159          as "Спр_Организации"   with (nolock)
order by 2;
select *-- _IDRRef                                   as "Структура_Key"
--      ,_ParentIDRRef                             as "СтруктураРодитель_Key"      
--      ,_Description                              as "Структура"
from  Center_2021.dbo._Reference260     as "Спр_СтруктураПредприятия";
select * from ods.vwСпр_СтруктураПредприятия;
/* ПЛАНЫ */
select convert(date,p._Fld528616)           as "Дата" /*В 1С: НачалоПериода*/
      , p._Fld528614RRef                    as "Организация_Key"
      ,pv._Fld528621RRef                    as "ТорговыйАгент_Key"
      ,pv._Fld528622RRef                    as "Бренд_Key"
      ,pv._Fld528623                        as "План" /* В 1С: сумма */
from      "Center_2021".dbo."_Document528613_VT528619"  pv /*Док_УстановкаПланаПродажТаблицаПланаПродаж*/ with (nolock)
left join "Center_2021".dbo."_Document528613"           p  /*Док_УстановкаПланаПродаж*/                   with (nolock)
       on pv._Document528613_IDRRef = p._IDRRef
where p._Fld528616 < '4024-01-01'
  and p._Marked=00;
/* ТОРГОВЫЕ АГЕНТЫ */
select 
     u._IDRRef                              as "ТорговыйАгент_Key"
    ,u._Fld25495                            as "Район" /*в 1С: КодТорговогоАгента*/
    ,u._Description                         as "Торговый агент"
    ,u._Fld4599RRef                         as "Подразделение_Key"
    ,s._Description                         as "Подразделение"
    ,s._Fld6294RRef                         as "ТекущийРуководитель_Key"
    ,f._Description                         as "Руководитель"    
from Center_2021.dbo._Reference184          as u /*"Спр_Пользователи"*/       with (nolock)
left join "Center_2021".dbo."_Reference260" as s /*Спр_СтруктураПредприятия*/ with (nolock) 
       on u._Fld4599RRef = s._IDRRef             /*Подразделение_Key*/ 
left join "Center_2021".dbo."_Reference286" as f /*Спр_ФизическиеЛица*/       with (nolock)
       on s._Fld6294RRef = f._IDRRef             /*ТекущийРуководитель_Key*/
order by 2;