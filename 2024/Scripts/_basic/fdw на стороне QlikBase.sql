-- !Нужен superuser!
-- Установка расширения postgres_fdw, если оно еще не установлено
create extension if not exists postgres_fdw;

-- Создание FDW сервера для представления базы данных enterprise2kz
create server enterprise2kz_fdw
foreign data wrapper postgres_fdw
options (dbname 'enterprise2kz', host 'localhost', port '5432'); -- Замените 'localhost' на реальный адрес сервера, если нужно

-- Создание user mapping для текущего пользователя PostgreSQL для доступа к enterprise2kz
create user mapping for "QlikAnalytics"
server enterprise2kz_fdw
options (user 'QlikAnalytics', password 'Kurw21M_8GM£9>p'); -- Замените 'username' и 'password' на ваши реальные учетные данные

-- Создание схемы enterprise2kz в текущей базе данных QlikBase перед импортом таблиц
drop schema erp cascade;
create schema if not exists erp;
-- Права в базе данных QlikBase
grant all on schema erp to "QlikAnalytics";
grant select on all tables in schema erp to "QlikAnalytics";
alter default privileges in schema erp grant select on tables to "QlikAnalytics"; -- Для новых таблиц

-- Без этого экстеншена импорт не сработает из-за отсутствия типов данных для совместимости с Microsoft SQL Server (MS SQL)
create extension if not exists mchar
;

-- Импорт схемы public из enterprise2kz в текущую базу данных QlikBase в схему erp
-- Вы можете изменить название целевой схемы в QlikBase, если нужно
import foreign schema public
from server enterprise2kz_fdw
into erp; -- Схема в QlikBase, куда будут импортированы таблицы

-- Пример запроса к импортированной таблице
-- Предположим, что в схеме public базы enterprise2kz есть таблица example_table
-- Теперь вы можете обращаться к ней следующим образом:
select * from erp._document787
;

-- 240422 Пропал доступ к таблицам erp.* (на примере _Reference380 - Партнёры)
-- Пересоздал схему QlikBase.erp. Повторил репликацию. Не помогло. Оказалось исчезло право на select в enterprise2kz. Почему - не знаю.