-- 1) Средний баланса счета для каждого типа счета, если он больше 800, 
--    упорядоченные по убыванию.
SELECT acc_type_id, ROUND(AVG(cur_balance_amt::NUMERIC), 1) AS avg_balance
FROM cbr.account
GROUP BY acc_type_id
HAVING AVG(cur_balance_amt::NUMERIC) > 800
ORDER BY AVG(cur_balance_amt::NUMERIC) DESC;

-- 2) Количества клиентов с числом счетов больше 1, упорядоченные
--    по убыванию числа счутов
SELECT user_id, COUNT(account_id) AS num_accounts
FROM cbr.registry
GROUP BY user_id
HAVING COUNT(account_id) > 1
ORDER BY COUNT(account_id) DESC;

-- 3) Добавление колонки с ранжированием 
--    по балансу счета внутри каждого типа счета,
--    и с числом пользователей,
--    для счетов с хотя бы двумя пользователями

SELECT *,
       RANK() OVER(PARTITION BY acc_type_id ORDER BY cur_balance_amt DESC) AS balance_rank,
       COUNT(*) OVER(PARTITION BY acc_type_id) AS num_users
FROM (
    SELECT *,
       COUNT(*) OVER(PARTITION BY acc_type_id) as cnt
    FROM cbr.account
) AS T 
WHERE cnt >= 2;

-- 4) Добавление колонки с суммарным балансом 
--    для каждого типа счета, упорядоченного по убыванию суммарного баланса:
SELECT acc_type_id,
       SUM(cur_balance_amt) OVER(PARTITION BY acc_type_id) AS total_balance
FROM cbr.account
ORDER BY total_balance DESC;

-- 5) Вывод самого высокого баланса счета для каждого типа счета:
SELECT *,
       MAX(cur_balance_amt) OVER(PARTITION BY acc_type_id) AS max_balance
FROM cbr.account;

-- 6) Вывод номера телефона клиента с самым большим числом 
--    счетов, упорядоченным по убыванию количества счетов:
SELECT phone_num, COUNT(cbr.registry.account_id) AS num_accounts,
       ROW_NUMBER() OVER(ORDER BY COUNT(cbr.registry.account_id) DESC) AS phone_rank
FROM cbr.registry
JOIN cbr.user ON cbr.registry.user_id = cbr.user.user_id
GROUP BY phone_num
ORDER BY num_accounts DESC;

