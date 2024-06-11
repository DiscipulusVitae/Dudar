select *
from erp."Док_РасчетСебестоимостиТоваров" as st
where true
  and st."Дата" = (select max("Дата") from erp."Док_РасчетСебестоимостиТоваров")
;

select *
from      erp."РС_СтоимостьТоваров" st
left join erp."Спр_Номенклатура" n on n."Ссылка_Key" = st."АналитикаУчетаНоменклатуры_Key"
;