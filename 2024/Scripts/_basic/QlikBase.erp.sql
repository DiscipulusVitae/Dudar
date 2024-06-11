create or replace function _IDRRef_To_GUID(idrref bytea)
returns text
language plpgsql
as $$
declare
  idrref_string text;
begin
  -- Преобразование бинарных данных в строку в hex формате
  idrref_string := encode(idrref, 'hex');

  -- Возвращаем строку в формате GUID, меняя порядок байтов в соответствии с форматом 1C
  return substring(idrref_string, 25, 8) || '-' ||
         substring(idrref_string, 21, 4) || '-' ||
         substring(idrref_string, 17, 4) || '-' ||
         substring(idrref_string, 1, 4)  || '-' ||
         substring(idrref_string, 5, 12);
end;
$$;
