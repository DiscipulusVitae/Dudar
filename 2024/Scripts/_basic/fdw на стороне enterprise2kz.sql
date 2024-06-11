-- !Нужен superuser!

-- Права в базе данных enterprise2kz
grant usage on schema public to "QlikAnalytics";
grant select on all tables in schema public to "QlikAnalytics";
alter default privileges in schema public grant select on tables to "QlikAnalytics"; -- Для новых таблиц
