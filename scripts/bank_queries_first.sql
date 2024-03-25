-- 1) Добавление его паспорта (СОЗДАНИЕ)
INSERT INTO cbr.passport (passport_id, passport_no, passport_series, first_nm, second_nm, birth_dt, issue_dt)
VALUES (21, '987654', 'XY', 'Василий', 'Иванов', '1995-01-01', '2024-03-25');

-- 2) Добавление нового пользователя (СОЗДАНИЕ)
INSERT INTO cbr.user (user_id, passport_id, age_num, phone_num, email_txt)
VALUES (21, 21, '30', '+1234567890', 'ivanovvasiliy@example.com');

-- 3) Получение идентификатора нового пользователя (ЧТЕНИЕ)
SELECT user_id FROM cbr.user WHERE email_txt = 'ivanovvasiliy@example.com';

-- 4) Получение идентификатора нового паспорта (ЧТЕНИЕ)
SELECT passport_id FROM cbr.passport WHERE passport_no = '987654';

-- 5) Изменение возраста пользователя (ИЗМЕНЕНИЕ)
UPDATE cbr.user SET age_num = '35', phone_num = '+987654321' WHERE email_txt = 'ivanovvasiliy@example.com';

-- 6) Изменение инфоримени и фамилии в паспорте (ИЗМЕНЕНИЕ)
UPDATE cbr.passport SET first_nm = 'Петр', second_nm = 'Петров' WHERE passport_no = '987654';

-- 7) Пользователи старше 25 лет (ЧТЕНИЕ)
SELECT * FROM cbr.user WHERE age_num > '25';

-- 8) Паспорта, выданные позже определённой даты (ЧТЕНИЕ)
SELECT * FROM cbr.passport WHERE issue_dt > '2020-01-01'; 

-- 9) Типы счетов и соответствующие им банки (ЧТЕНИЕ)
SELECT 
    at.acc_type_id,
    at.acc_type_txt,
    at.bank_id,
    b.bank_nm
FROM 
    cbr.account_type AS at
INNER JOIN 
    cbr.bank AS b ON at.bank_id = b.bank_id;

-- 10) Список всех банков (ЧТЕНИЕ)
SELECT * FROM cbr.bank;

-- 11) Список всех счетов и их балансов (ЧТЕНИЕ)
SELECT account_id, acc_type_id, cur_balance_amt FROM cbr.account;

-- 12) Удаление информации о новом пользователе (УДАЛЕНИЕ)
DELETE FROM cbr.user WHERE email_txt = 'ivanovvasiliy@example.com';

-- 13) Удаление информации о паспорте (УДАЛЕНИЕ)
DELETE FROM cbr.passport WHERE passport_no = '987654';
