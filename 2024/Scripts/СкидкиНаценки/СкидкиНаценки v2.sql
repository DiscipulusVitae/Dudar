select zt."Документы_Key"                            as "Документы_Key"
      ,sk."Наименование"                             as "СкидкаНаценка"
      ,zs."Сумма"                                    as "СкидкаНаценка_Сумма"      
from          "Док_Заказ"                            as zt
left join erp."Док_ЗаказКлиента.СкидкиНаценки"       as zs on zs."Ссылка_Key" = zt."Док_Заказ_Key"       
                                                          and zs."КлючСвязи"  =  zt."КлючСвязи"
left join erp."Спр_СкидкиНаценки"                    as sk on sk."Ссылка_Key" = zs."СкидкаНаценка_Key"                     
where sk."Ссылка_Key" <> decode('896A00155D781E3211EEAA26E5D8324E','hex') -- Округление суммы документа, точность 1
;

/*20240227 рабочий вариант старого подхода: 
 [СкидкиНаценки]:
load dual([Док_Заказ_Key]&'_'&[ЗаказСтрока],AutoNumberHash256([Док_Заказ_Key],[ЗаказСтрока]))                            as [ЗаказСтрока_Key]
	,[СкидкаНаценка]
    ,[СкидкаНаценка_Сумма];    
select z._IDRRef                                     as "Док_Заказ_Key"
      ,zt._Fld14465                                  as "ЗаказСтрока"
      ,sk._Description                               as "СкидкаНаценка"
      ,zs._Fld14489                                  as "СкидкаНаценка_Сумма"      
from      erp._Document1206                          as p   --Документ.РеализацияТоваровУслуг
left join erp._Document1206_VT29814                  as pt  --Документ.РеализацияТоваровУслуг.Товары
       on p._IDRRef = pt._Document1206_IDRRef
left join erp._Document941                           as z   --Документ.ЗаказКлиента
       on z._IDRRef = p._Fld29746_RRRef
left join erp._Document941_VT14446                   as zt  --Документ.ЗаказКлиента.Товары
       on zt._Document941_IDRRef  = pt._Fld29837_RRRef      --Документ.РеализацияТоваровУслуг.Товары.ЗаказКлиента_ID*
      and zt._Fld14449RRef        = pt._Fld29816RRef        --Номенклатура_Key
left join erp._Document941_VT14485                   as zs  --Документ.ЗаказКлиента.СкидкиНаценки  
       on zs._Document941_IDRRef  = zt._Document941_IDRRef  --Документ.ЗаказКлиента.ID
      and zs._Fld14487            = zt._Fld14467            --КлючСвязи
left join erp._Reference530                          as sk  --Спр_СкидкиНаценки
       on sk._IDRRef = zs._Fld14488RRef                     
where true
  and p._Marked = false and z._Marked = false
  and p._Date_Time >= '2024-01-01' and z._Date_Time >= '2024-01-01'
  and sk._IDRRef <> decode('896A00155D781E3211EEAA26E5D8324E','hex') -- Округление суммы документа, точность 1
order by p._Date_Time, pt._Fld29833
;*/