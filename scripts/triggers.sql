-- 1) Запрет закрытия счёта с ненулевым балансом
CREATE OR REPLACE FUNCTION check_close_account() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM cbr.account
        WHERE account_id = OLD.account_id
        AND cur_balance_amt > 0
    ) THEN
        RAISE EXCEPTION 'Невозможно закрыть счет с положительным балансом.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TRG_CloseAccount
BEFORE DELETE ON cbr.registry
FOR EACH ROW
EXECUTE FUNCTION check_close_account();

-- 2) Запрет удаления банка, с которым связаны счета
CREATE OR REPLACE FUNCTION check_delete_bank() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM cbr.account_type
        WHERE bank_id = OLD.bank_id
    ) THEN
        RAISE EXCEPTION 'Невозможно удалить банк, который связан со счетом.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TRG_RestrictDeleteBank
BEFORE DELETE ON cbr.bank
FOR EACH ROW
EXECUTE FUNCTION check_delete_bank();

-- 3) Запрет удаления типа счёта, для которого существуют счета
CREATE OR REPLACE FUNCTION check_delete_account_type() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM cbr.account
        WHERE acc_type_id = OLD.acc_type_id
    ) THEN
        RAISE EXCEPTION 'Невозможно удалить тип счета, для которого существуют счета.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TRG_RestrictDeleteAccountType
BEFORE DELETE ON cbr.account_type
FOR EACH ROW
EXECUTE FUNCTION check_delete_account_type();
