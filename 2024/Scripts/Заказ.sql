--select distinct "ВариантОбеспечения"
select z."Номер"
    ,z."Статус_Key"
     --sum(zt."СуммаАвтоматическойСкидки")
from erp."Док_ЗаказКлиента.Товары" zt
join erp."Док_ЗаказКлиента" z on z."Ссылка_Key" = zt."Ссылка_Key"
--from erp."Док_ЗаказКлиента" z
--join erp."Док_ЗаказКлиента.Товары" zt on z."Ссылка_Key" = zt."Ссылка_Key"
where true 
  and z."ПометкаУдаления" is false
  and z."Ссылка_Key" = decode('BC3800074333BE5811EEC0BA5572BC64','hex')
  and z."Статус_Key" = decode('B58F438FD9FB9FCB4711D9E217F46797','hex') --К выполнению
--  and z._Number = 'SHIDU-0000291'
  and zt."ВариантОбеспечения_Key" = decode('A297247D05C45D2F40B1862FCD44CEBD','hex') --Резервировать на складе
;

select z."Статус_Key", count(*)
from erp."Док_ЗаказКлиента" z
join erp."Док_ЗаказКлиента.Товары" zt on z."Ссылка_Key" = zt."Ссылка_Key"
where true
  and z."ПометкаУдаления" is false
group by 1