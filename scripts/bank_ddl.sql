CREATE SCHEMA cbr;

CREATE TABLE
   cbr.bank (
      bank_id BIGINT NOT NULL,
      bank_nm VARCHAR(300) NOT NULL,
      address_txt VARCHAR(300) NOT NULL,
      CONSTRAINT PK_bank_id PRIMARY KEY (bank_id)
   );

CREATE TABLE
   cbr.account_type (
      acc_type_id BIGINT NOT NULL,
      bank_id BIGINT NOT NULL,
      start_dt DATE NOT NULL,
      end_dt DATE,
      acc_type_txt VARCHAR(300) NOT NULL,
      replenishment_flg BOOLEAN NOT NULL,
      transfer_flg BOOLEAN NOT NULL,
      withdrawal_flg BOOLEAN NOT NULL,
      comission_amt MONEY NOT NULL,
      min_balance_amt MONEY NOT NULL,
      CONSTRAINT PK_acc_type_id PRIMARY KEY (acc_type_id),
      CONSTRAINT FK_bank_id FOREIGN KEY (bank_id) REFERENCES cbr.bank (bank_id)
   );

CREATE TABLE
   cbr.account (
      account_id BIGINT NOT NULL,
      acc_type_id BIGINT NOT NULL,
      cur_balance_amt MONEY NOT NULL,
      CONSTRAINT PK_account_id PRIMARY KEY (account_id),
      CONSTRAINT FK_acc_type_id FOREIGN KEY (acc_type_id) REFERENCES cbr.account_type (acc_type_id)
   );

CREATE TABLE
   cbr.passport (
      passport_id BIGINT NOT NULL,
      passport_no VARCHAR(30) NOT NULL,
      passport_series VARCHAR(30) NOT NULL,
      first_nm VARCHAR(300) NOT NULL,
      second_nm VARCHAR(300) NOT NULL,
      third_nm VARCHAR(300) NOT NULL,
      birth_dt DATE NOT NULL,
      issue_dt DATE NOT NULL,
      CONSTRAINT PK_passport_id PRIMARY KEY (passport_id)
   );

CREATE TABLE
   cbr.user (
      user_id BIGINT NOT NULL,
      passport_id BIGINT NOT NULL,
      phone_num VARCHAR(30) NOT NULL,
      email_txt VARCHAR(300) NOT NULL,
      CONSTRAINT PK_user_id PRIMARY KEY (user_id),
      CONSTRAINT FK_passport_id FOREIGN KEY (passport_id) REFERENCES cbr.passport (passport_id)
   );

CREATE TABLE
   cbr.registry (
      reg_id BIGINT NOT NULL,
      user_id BIGINT NOT NULL,
      account_id BIGINT NOT NULL,
      open_dt DATE NOT NULL,
      close_dt DATE,
      CONSTRAINT PK_registry PRIMARY KEY (reg_id),
      CONSTRAINT FK_user_id FOREIGN KEY (user_id) REFERENCES cbr.user (user_id)
   );

-- Данные индексы могут улучшить производительность операций,
-- в которых используется эти внешние отношения
CREATE INDEX idx_bank_id ON cbr.account_type (bank_id);

CREATE INDEX idx_acc_type_id ON cbr.account (acc_type_id);

CREATE INDEX idx_passport_id ON cbr.user (passport_id);

CREATE INDEX idx_user_id ON cbr.registry (user_id);