-- 1) Банки и типы их типы счетов
SELECT
    b.bank_nm,
    b.bank_id,
    at.acc_type_txt,
    at.acc_type_id
FROM
    cbr.account_type AS at
    INNER JOIN cbr.bank AS b ON at.bank_id = b.bank_id
ORDER BY
    b.bank_nm;

-- 2) Средний баланс и банк каждого типа счета, если среднее
--    больше 800, упорядоченные по убыванию среднего.
SELECT
    a.acc_type_id,
    b.bank_nm,
    ROUND(AVG(a.cur_balance_amt::NUMERIC), 1) AS avg_balance
FROM
    cbr.account a
    INNER JOIN cbr.account_type at ON at.acc_type_id = a.acc_type_id
    INNER JOIN cbr.bank b ON b.bank_id = at.bank_id
GROUP BY
    a.acc_type_id,
    b.bank_nm
HAVING
    AVG(a.cur_balance_amt::NUMERIC) > 800
ORDER BY
    AVG(a.cur_balance_amt::NUMERIC) DESC;

-- 3) Почта и количество счетов тех клиентов, у которых
--    счетов хотя бы 2
SELECT
    r.user_id,
    u.email_txt,
    COUNT(r.account_id) AS num_accounts
FROM
    cbr.registry r
    INNER JOIN cbr.user u ON u.user_id = r.user_id
GROUP BY
    r.user_id,
    u.email_txt
HAVING
    COUNT(r.account_id) > 1
ORDER BY
    COUNT(r.account_id) DESC;

-- 4) Информация о счетах пользователей с наибольшим балансом из каждого типа счета,
--    при условии, что количество пользователей на этом типе счета хотя бы два.
SELECT
    subquery.bank_nm,
    u.email_txt,
    subquery.acc_type_id,
    subquery.num_users,
    subquery.balance_rank
FROM
    (
        SELECT
            b.bank_nm,
            at.acc_type_txt,
            at.acc_type_id,
            a.account_id,
            RANK() OVER (
                PARTITION BY
                    a.acc_type_id
                ORDER BY
                    a.cur_balance_amt DESC
            ) AS balance_rank,
            COUNT(*) OVER (
                PARTITION BY
                    a.acc_type_id
            ) AS num_users
        FROM
            cbr.account AS a
            INNER JOIN cbr.account_type AS at ON at.acc_type_id = a.acc_type_id
            INNER JOIN cbr.bank AS b ON b.bank_id = at.bank_id
    ) AS subquery
    INNER JOIN cbr.registry AS r ON r.account_id = subquery.account_id
    INNER JOIN cbr.user AS u ON u.user_id = r.user_id
    INNER JOIN cbr.passport AS p ON p.passport_id = u.passport_id
WHERE
    subquery.num_users >= 2
ORDER BY
    subquery.num_users;

-- 5) Найти пользователей с самым большим суммарном балансом на счетах,
--    большем 3000, отсортировать по убыванию
SELECT
    u.user_id,
    u.email_txt,
    SUM(a.cur_balance_amt) as summary_balance
FROM
    cbr.user u
    INNER JOIN cbr.registry r ON r.user_id = u.user_id
    INNER JOIN cbr.account a ON a.account_id = r.account_id
GROUP BY
    u.user_id
HAVING
    SUM(a.cur_balance_amt::NUMERIC) >= 3000
ORDER BY
    SUM(a.cur_balance_amt) DESC;

-- 6) Для каждого счета дополнительно вывести максимальный баланс
--    на этом типе счета, упорядоченные по убыванию максимума
SELECT
    bank_nm,
    acc_type_txt,
    cur_balance_amt,
    MAX(cur_balance_amt) OVER (
        PARTITION BY
            acc_type_id
        ORDER BY
            cur_balance_amt
    ) AS max_balance
FROM
    account_info
ORDER BY
    max_balance DESC;

-- 7) Получение списка всех банков и их общего количества клиентов, 
-- отсортированного по количеству клиентов по убыванию:
SELECT
    b.bank_nm,
    b.address_txt,
    COUNT(*) as client_amount,
    SUM(a.cur_balance_amt) sum_balance
FROM
    cbr.bank b
    INNER JOIN cbr.account_type at ON at.bank_id = b.bank_id
    INNER JOIN cbr.account a ON a.acc_type_id = at.acc_type_id
    INNER JOIN cbr.registry r ON r.account_id = a.account_id
    INNER JOIN cbr.user u on u.user_id = r.user_id
    INNER JOIN cbr.passport p on p.passport_id = u.passport_id
GROUP BY
    b.bank_nm,
    b.address_txt
ORDER BY
    client_amount DESC;

-- 8) Получение списка банков с указанием количества счетов, закрывающихся
-- после 2024 года и суммарного баланса на этих счетах.
SELECT
    b.bank_id,
    b.bank_nm,
    COUNT(DISTINCT r.account_id) AS accounts_amount,
    SUM(a.cur_balance_amt) AS total_balance
FROM
    cbr.bank b
    INNER JOIN cbr.account_type at ON b.bank_id = at.bank_id
    INNER JOIN cbr.account a ON at.acc_type_id = a.acc_type_id
    INNER JOIN cbr.registry r ON a.account_id = r.account_id
WHERE
    at.end_dt >= '2024-01-01'
GROUP BY
    b.bank_id,
    b.bank_nm
ORDER BY
    total_balance DESC;

-- 9) Получение списка всех банков и максимального баланса каждого типа счета
--    на счетах клиентов, родившихся в промежутке 1970-1985 гг 
SELECT
    b.bank_nm,
    at.acc_type_txt as account_type,
    a.cur_balance_amt as balance,
    u.email_txt as email,
    MAX(a.cur_balance_amt) OVER (
        PARTITION BY
            a.acc_type_id
        ORDER BY
            a.cur_balance_amt DESC
    ) as max_type_balance
FROM
    cbr.bank b
    INNER JOIN cbr.account_type at ON at.bank_id = b.bank_id
    INNER JOIN cbr.account a ON a.acc_type_id = at.acc_type_id
    INNER JOIN cbr.registry r ON r.account_id = a.account_id
    INNER JOIN cbr.user u on u.user_id = r.user_id
    INNER JOIN cbr.passport p on p.passport_id = u.passport_id
WHERE
    p.birth_dt BETWEEN '1970-01-01' AND '1986-01-01';

-- 10) Получение списка всех банков и суммарного баланса каждого типа счета
--    клиентов, для типов счетов, которые можно пополнять с суммарным балансом больше 500
SELECT
    b.bank_nm,
    at.acc_type_txt as account_type,
    a.cur_balance_amt as balance,
    u.email_txt as email,
    MAX(a.cur_balance_amt) OVER (
        PARTITION BY
            a.acc_type_id
        ORDER BY
            a.cur_balance_amt DESC
    ) as summary_type_balance
FROM
    cbr.bank b
    INNER JOIN cbr.account_type at ON at.bank_id = b.bank_id
    INNER JOIN cbr.account a ON a.acc_type_id = at.acc_type_id
    INNER JOIN cbr.registry r ON r.account_id = a.account_id
    INNER JOIN cbr.user u on u.user_id = r.user_id
    INNER JOIN cbr.passport p on p.passport_id = u.passport_id
WHERE
    at.replenishment_flg IS TRUE
    AND a.cur_balance_amt::NUMERIC > 500
ORDER BY
    summary_type_balance DESC;

-- 11) Для каждого банка вывести все типы счетов, их минимальный возможный баланс,
--     максимальный мин баланс, возможность перевода с счета
SELECT
    b.bank_nm,
    at.acc_type_txt,
    at.min_balance_amt as min_bal,
    MAX(at.min_balance_amt) OVER (
        PARTITION BY
            b.bank_id
        ORDER BY
            at.min_balance_amt DESC
    ) as MAXIMUM_of_min_bal
FROM
    cbr.bank b
    INNER JOIN cbr.account_type at ON at.bank_id = b.bank_id
ORDER BY
    maximum_of_min_bal DESC;

-- 12) Для каждого банка вывести самый используемый счет
SELECT
    bank_nm,
    acc_type_txt,
    client_count
FROM
    (
        SELECT
            b.bank_nm,
            at.acc_type_txt,
            COUNT(*) AS client_count,
            ROW_NUMBER() OVER (
                PARTITION BY
                    b.bank_id
                ORDER BY
                    COUNT(*) DESC
            ) AS row_num
        FROM
            cbr.bank b
            INNER JOIN cbr.account_type at ON at.bank_id = b.bank_id
            INNER JOIN cbr.account a ON a.acc_type_id = at.acc_type_id
            INNER JOIN cbr.registry r ON r.account_id = a.account_id
            INNER JOIN cbr.user u ON u.user_id = r.user_id
        GROUP BY
            b.bank_nm,
            at.acc_type_txt,
            b.bank_id
    ) AS subquery
WHERE
    row_num = 1
ORDER BY
    client_count DESC;