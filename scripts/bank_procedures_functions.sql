-- 1) Добавление нового клиента с открытием счета:
CREATE OR REPLACE PROCEDURE cbr.add_user_with_account (
  IN p_passport_no VARCHAR(30),
  IN p_passport_series VARCHAR(30),
  IN p_first_nm VARCHAR(300),
  IN p_second_nm VARCHAR(300),
  IN p_third_nm VARCHAR(300),
  IN p_birth_dt DATE,
  IN p_issue_dt DATE,
  IN p_phone_num VARCHAR(30),
  IN p_email_txt VARCHAR(300),
  IN p_bank_id BIGINT,
  IN p_acc_type_id BIGINT,
  IN p_cur_balance_amt MONEY
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_passport_id BIGINT;
  v_user_id BIGINT;
  v_account_id BIGINT;
  v_open_dt DATE := CURRENT_DATE;
BEGIN
  -- Вставляем данные паспорта и получаем ID
  INSERT INTO cbr.passport (passport_no, passport_series, first_nm, second_nm, third_nm, birth_dt, issue_dt)
  VALUES (p_passport_no, p_passport_series, p_first_nm, p_second_nm, p_third_nm, p_birth_dt, p_issue_dt)
  RETURNING passport_id INTO v_passport_id;

  -- Вставляем данные пользователя и получаем ID
  INSERT INTO cbr.user (passport_id, phone_num, email_txt)
  VALUES (v_passport_id, p_phone_num, p_email_txt)
  RETURNING user_id INTO v_user_id;

  -- Вставляем данные счета и получаем ID
  INSERT INTO cbr.account (acc_type_id, cur_balance_amt)
  VALUES (p_acc_type_id, p_cur_balance_amt)
  RETURNING account_id INTO v_account_id;

  -- Добавляем запись в реестр
  INSERT INTO cbr.registry (user_id, account_id, open_dt)
  VALUES (v_user_id, v_account_id, v_open_dt);
END;
$$;


-- 2) Добавление банка в базу данных:
CREATE OR REPLACE PROCEDURE cbr.add_bank (
  IN p_bank_nm VARCHAR(300),
  IN p_address_txt VARCHAR(300),
  OUT p_new_bank_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO cbr.bank (bank_nm, address_txt)
    VALUES (p_bank_nm, p_address_txt)
    RETURNING bank_id INTO p_new_bank_id;
END;
$$;

-- 3) Открытие счёта клиента:
CREATE OR REPLACE PROCEDURE cbr.open_account (
  IN p_user_id BIGINT,
  IN p_bank_id BIGINT,
  IN p_acc_type_id BIGINT,
  IN p_cur_balance_amt MONEY,
  OUT p_new_account_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_account_id BIGINT;
  v_open_dt DATE := CURRENT_DATE;
BEGIN
  -- Вставляем данные счета и получаем ID
  INSERT INTO cbr.account (acc_type_id, cur_balance_amt)
  VALUES (p_acc_type_id, p_cur_balance_amt)
  RETURNING account_id INTO v_account_id;

  -- Добавляем запись в реестр
  INSERT INTO cbr.registry (user_id, bank_id, account_id, open_dt)
  VALUES (p_user_id, p_bank_id, v_account_id, v_open_dt)
  RETURNING account_id INTO p_new_account_id;
END;
$$;

-- 4) Закрытие счёта пользователя:
CREATE OR REPLACE PROCEDURE cbr.close_user_account (
  IN p_user_id BIGINT,
  IN p_account_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Обновляем дату закрытия счета
  UPDATE cbr.registry
  SET close_dt = CURRENT_DATE
  WHERE user_id = p_user_id AND account_id = p_account_id;
END;
$$;


-- 5) Подсчёт суммарного баланса всех счетов клиента
CREATE OR REPLACE FUNCTION cbr.get_total_balance(
    IN p_user_id BIGINT
)
RETURNS MONEY
AS $$
DECLARE
    v_total_balance MONEY;
BEGIN
    SELECT COALESCE(SUM(acc.cur_balance_amt), 0)
    INTO v_total_balance
    FROM cbr.registry AS reg
    JOIN cbr.account AS acc ON reg.account_id = acc.account_id
    WHERE reg.user_id = p_user_id;

    RETURN v_total_balance;
END;
$$ LANGUAGE plpgsql;

-- 6) Подсчет общего количества открытых аккаунтов клиента
CREATE OR REPLACE FUNCTION cbr.get_active_accounts_count(
    IN p_bank_id BIGINT
)
RETURNS INTEGER
AS $$
DECLARE
    v_active_count INTEGER;
BEGIN
    -- Получаем количество активных счетов для указанного банка
    SELECT COUNT(*)
    INTO v_active_count
    FROM cbr.registry AS reg
    JOIN cbr.account AS acc ON reg.account_id = acc.account_id
    JOIN cbr.account_type AS acct ON acc.acc_type_id = acct.acc_type_id
    WHERE reg.close_dt IS NULL
    AND acct.bank_id = p_bank_id;

    RETURN v_active_count;
END;
$$ LANGUAGE plpgsql;


-- 7) Возвращает таблицу с банками
CREATE OR REPLACE FUNCTION cbr.get_all_banks()
RETURNS TABLE (
    bank_id BIGINT,
    bank_nm VARCHAR(300),
    address_txt VARCHAR(300)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bank_id, bank_nm, address_txt
    FROM cbr.bank;
END;
$$ LANGUAGE plpgsql;






