select
	 o."Дата"
    ,o."Склад_Key"
    ,o."Номенклатура_Key"    
    ,o."ОстатокШтуки" /*в 1С: ВНаличии*/
    ,o.ОстатокСумма
from "Остатки" o
where o."Дата" >= current_date - 30
;