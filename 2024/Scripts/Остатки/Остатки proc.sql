do $$
declare
  v_last_date date;
  v_last_price numeric;
  v_nomenklatura_key bytea;
  v_current_date date := '2024-01-01'; -- замените на актуальную начальную дату
  v_end_date date := '2024-01-02'; -- замените на актуальную конечную дату
begin
  -- Создаем временную таблицу
  drop table if exists temp_prices;
  create temp table temp_prices as
  select
    _Period as "Дата",
    _Fld44643RRef as "Номенклатура_Key",
    _Fld44646 as "ЦенаБазовая"
  from erp._InfoRg44642
  where 1=0;
  -- Получаем уникальные ключи номенклатуры
  for v_nomenklatura_key in
      select distinct _Fld44643RRef from erp._InfoRg44642
  loop
    v_last_date := null;
    v_last_price := null;    
    for v_current_date in
        select generate_series(min(_Period), max(_Period), interval '1 day')::date from erp._InfoRg44642
    loop
      -- Проверяем, существует ли запись для текущей даты и ключа номенклатуры
      select into v_last_date, v_last_price _Period, _Fld44646
      from erp._InfoRg44642
      where _Fld44643RRef = v_nomenklatura_key and _Period <= v_current_date
      order by _Period desc
      limit 1;
      if v_last_date is not null and v_last_date != v_current_date then
        -- Вставляем пропущенные даты с последней доступной ценой
        insert into temp_prices ("Дата", "Номенклатура_Key", "ЦенаБазовая")
        values (v_current_date, v_nomenklatura_key, v_last_price);
      elsif v_last_date is null then
        -- Если нет данных вообще, можно решить, что делать: пропустить или вставить с нулевой/плейсхолдерной ценой
        -- insert into temp_prices ("Дата", "Номенклатура_Key", "ЦенаБазовая")
        -- values (v_current_date, v_nomenklatura_key, 0); -- или другое решение
      end if;
    end loop;
  end loop;
end$$;

select *
from temp_prices
;
