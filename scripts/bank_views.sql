-- Представление, маскирующее поля passport_no и passport_series
CREATE VIEW
    cbr.passport_masked AS
SELECT
    'xxxx' || RIGHT(passport_no, 2) AS masked_passport_no,
    'x' || RIGHT(passport_series, 1) AS masked_passport_series,
    first_nm,
    second_nm,
    issue_dt
FROM
    cbr.passport;

-- Представление, маскирующее номера телефонов и адреса электронной почты и выводящее ФИО владельцев к ним
CREATE VIEW
    cbr.user_masked_contacts AS
SELECT
    u.user_id,
    CONCAT(p.first_nm, ' ', p.second_nm, ' ', p.third_nm) AS full_name,
    '+xxxxxx' || RIGHT(u.phone_num, 6) AS masked_phone_num,
    LEFT(u.email_txt, 1) || '*****' || SUBSTRING(u.email_txt, POSITION('@' IN u.email_txt)) AS masked_email
FROM
    cbr.user u
    JOIN cbr.passport p ON u.passport_id = p.passport_id;

-- Представление, объединяющее таблицы cbr.account_type и cbr.bank
-- с краткой информацией о всех предложениях банков
DROP VIEW cbr.account_types_with_bank_clean;

CREATE VIEW
    cbr.account_types_with_bank_clean AS
SELECT
    b.bank_nm,
    act.acc_type_txt,
    act.start_dt,
    act.end_dt
FROM
    cbr.account_type AS act
    JOIN cbr.bank b ON act.bank_id = b.bank_id;

-- Представление для получения статистики продаж/частоты обращения клиента
CREATE VIEW
    cbr.sales_statistics AS
SELECT
    u.user_id,
    u.phone_num,
    COUNT(r.reg_id) AS total_transactions
FROM
    cbr.user u
    LEFT JOIN cbr.registry r ON u.user_id = r.user_id
GROUP BY
    u.user_id,
    u.phone_num;

-- Представление для получения сводной таблицы с информацией о банке, типе счета и балансе
CREATE VIEW
    cbr.account_summary AS
SELECT
    u.user_id,
    u.phone_num,
    a.account_id,
    at.acc_type_txt,
    a.cur_balance_amt
FROM
    cbr.user u
    INNER JOIN cbr.registry r ON u.user_id = r.user_id
    INNER JOIN cbr.account a ON r.account_id = a.account_id
    INNER JOIN cbr.account_type at ON a.acc_type_id = at.acc_type_id;

-- Представление для получения статистики счетов по банкам
CREATE VIEW
    cbr.account_by_bank_summary AS
SELECT
    b.bank_nm,
    COUNT(a.account_id) AS total_accounts,
    SUM(a.cur_balance_amt) AS total_balance
FROM
    cbr.bank b
    JOIN cbr.account_type at ON b.bank_id = at.bank_id
    JOIN cbr.account a ON at.acc_type_id = a.acc_type_id
GROUP BY
    b.bank_nm;

-- Представление для общей статистики пользователей
CREATE VIEW
    cbr.total_cbr_statistics AS
SELECT
    COUNT(u.user_id) AS total_users,
    COUNT(DISTINCT r.account_id) AS total_accounts,
    COUNT(DISTINCT r.reg_id) AS total_registries
FROM
    cbr.user u
    LEFT JOIN cbr.registry r ON u.user_id = r.user_id;