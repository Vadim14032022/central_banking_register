-- Ряд элементарных запросов
-- 0) Вставка
INSERT INTO cbr.passport (passport_id, passport_no, passport_series, first_nm, second_nm, third_nm, birth_dt, issue_dt) 
VALUES 
(36, '937456', 'UW', 'Василий', 'Иванов', 'Сергеевич', '1981-01-01', '2025-01-01');

INSERT INTO cbr.user (user_id, passport_id, phone_num, email_txt) 
VALUES 
(36, 36, '+987654321', 'ivanovvasiliy@gmail.com');

-- 1) Получение идентификатора нового пользователя (ЧТЕНИЕ)
SELECT user_id FROM cbr.user WHERE email_txt = 'ivanovvasiliy@gmail.com';

-- 2) Получение идентификатора нового паспорта (ЧТЕНИЕ)
SELECT passport_id FROM cbr.passport WHERE passport_no = '937456';

-- 3) Изменение номера телефона пользователя (ИЗМЕНЕНИЕ)
UPDATE cbr.user SET phone_num = '+987654321' WHERE email_txt = 'ivanovvasiliy@gmail.com';

-- 4) Изменение инфоримени и фамилии в паспорте (ИЗМЕНЕНИЕ)
UPDATE cbr.passport SET first_nm = 'Петр', second_nm = 'Петров' WHERE passport_no = '987654';

-- 5) Удаление информации о новом пользователе (УДАЛЕНИЕ)
DELETE FROM cbr.user WHERE email_txt = 'ivanovvasiliy@gmail.com';

-- 6) Удаление информации о паспорте (УДАЛЕНИЕ)
DELETE FROM cbr.passport WHERE passport_no = '937456';

-- 7) Пользователи старше 25 лет (ЧТЕНИЕ)
SELECT * FROM cbr.passport WHERE cbr.passport.birth_dt > '1980-01-01';

-- 8) Паспорта, выданные в 2020 году и позже (ЧТЕНИЕ)
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

-- 12) Получить средний баланс для каждого типа счета:
SELECT at.acc_type_id, at.acc_type_txt, AVG(a.cur_balance_amt::NUMERIC) AS avg_balance
FROM cbr.account a
INNER JOIN cbr.account_type at ON a.acc_type_id = at.acc_type_id
GROUP BY at.acc_type_id, at.acc_type_txt;