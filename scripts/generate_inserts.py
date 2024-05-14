from sqlalchemy import create_engine, func, MetaData, Table, Column, Integer, String, Date, Boolean, Numeric, ForeignKey
from sqlalchemy.sql import func
import psycopg2
from faker import Faker
import random

connect = psycopg2.connect(
    database="my_project",
    user="postgres",
    password="2120",
    host="127.0.0.1",
    port="5432",
)

engine = create_engine(
    'postgresql://postgres:2120@127.0.0.1:5432/my_project')

metadata = MetaData()

bank_table = Table('bank', metadata,
                   Column('bank_id', Integer, primary_key=True,
                          autoincrement=True),
                   Column('bank_nm', String(300), nullable=False),
                   Column('address_txt', String(300), nullable=False)
                   )

account_type_table = Table('account_type', metadata,
                           Column('acc_type_id', Integer,
                                  primary_key=True, autoincrement=True),
                           Column('bank_id', Integer, ForeignKey(
                               'bank.bank_id'), nullable=False),
                           Column('start_dt', Date, nullable=False),
                           Column('end_dt', Date),
                           Column('acc_type_txt', String(300), nullable=False),
                           Column('replenishment_flg',
                                  Boolean, nullable=False),
                           Column('transfer_flg', Boolean, nullable=False),
                           Column('withdrawal_flg', Boolean, nullable=False),
                           Column('comission_amt', Numeric, nullable=False),
                           Column('min_balance_amt', Numeric, nullable=False)
                           )

account_table = Table('account', metadata,
                      Column('account_id', Integer,
                             primary_key=True, autoincrement=True),
                      Column('acc_type_id', Integer, ForeignKey(
                          'account_type.acc_type_id'), nullable=False),
                      Column('cur_balance_amt', Numeric, nullable=False)
                      )

passport_table = Table('passport', metadata,
                       Column('passport_id', Integer,
                              primary_key=True, autoincrement=True),
                       Column('passport_no', String(30), nullable=False),
                       Column('passport_series', String(30), nullable=False),
                       Column('first_nm', String(300), nullable=False),
                       Column('second_nm', String(300), nullable=False),
                       Column('third_nm', String(300), nullable=False),
                       Column('birth_dt', Date, nullable=False),
                       Column('issue_dt', Date, nullable=False)
                       )

user_table = Table('users', metadata,
                   Column('user_id', Integer, primary_key=True,
                          autoincrement=True),
                   Column('passport_id', Integer, ForeignKey(
                       'passport.passport_id'), nullable=False),
                   Column('phone_num', String(30), nullable=False),
                   Column('email_txt', String(300), nullable=False)
                   )

registry_table = Table('registry', metadata,
                       Column('reg_id', Integer, primary_key=True,
                              autoincrement=True),
                       Column('user_id', Integer, ForeignKey(
                           'users.user_id'), nullable=False),
                       Column('account_id', Integer, ForeignKey(
                           'account.account_id'), nullable=False),
                       Column('open_dt', Date, nullable=False),
                       Column('close_dt', Date)
                       )

try:
    for table in metadata.tables.values():
        table.create(engine)
except Exception as e:
    print(f'Таблицы уже есть: {e}')
    pass

print("Генерация")

fake = Faker("ru_RU")


def populate_tables():
    cursor = connect.cursor()

    passport_ids = []
    for _ in range(1000):
        passport_data = {
            'passport_no': fake.pystr(min_chars=10, max_chars=10),
            'passport_series': fake.pystr(min_chars=10, max_chars=10),
            'first_nm': fake.first_name(),
            'second_nm': fake.first_name(),
            'third_nm': fake.first_name(),
            'birth_dt': fake.date_between(start_date='-50y', end_date='-20y'),
            'issue_dt': fake.date_between(start_date='-10y', end_date='today')
        }

        cursor.execute(
            "INSERT INTO passport (passport_no, passport_series, first_nm, second_nm, third_nm, birth_dt, issue_dt) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING passport_id",
            (passport_data['passport_no'], passport_data['passport_series'], passport_data['first_nm'],
             passport_data['second_nm'], passport_data['third_nm'], passport_data['birth_dt'], passport_data['issue_dt'])
        )
        passport_ids.append(cursor.fetchone()[0])

    user_ids = []
    for passport_id in passport_ids:
        user_data = {
            'passport_id': passport_id,
            'phone_num': fake.phone_number(),
            'email_txt': fake.email()
        }

        cursor.execute(
            "INSERT INTO users (passport_id, phone_num, email_txt) VALUES (%s, %s, %s) RETURNING user_id",
            (user_data['passport_id'],
             user_data['phone_num'], user_data['email_txt'])
        )
        user_ids.append(cursor.fetchone()[0])

    bank_ids = []
    account_ids = []
    for _ in range(20):
        bank_data = {
            'bank_nm': fake.company(),
            'address_txt': fake.address()
        }

        cursor.execute(
            "INSERT INTO bank (bank_nm, address_txt) VALUES (%s, %s) RETURNING bank_id",
            (bank_data['bank_nm'], bank_data['address_txt'])
        )
        bank_ids.append(cursor.fetchone()[0])

        for _ in range(10):
            account_type_data = {
                'bank_id': bank_ids[-1],
                'start_dt': fake.date_between(start_date='-10y', end_date='today'),
                'end_dt': fake.date_between(start_date='today', end_date='+10y'),
                'acc_type_txt': fake.word(),
                'replenishment_flg': fake.boolean(),
                'transfer_flg': fake.boolean(),
                'withdrawal_flg': fake.boolean(),
                'comission_amt': fake.random_number(digits=5),
                'min_balance_amt': fake.random_number(digits=6)
            }

            cursor.execute(
                "INSERT INTO account_type (bank_id, start_dt, end_dt, acc_type_txt, replenishment_flg, transfer_flg, withdrawal_flg, comission_amt, min_balance_amt) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING acc_type_id",
                (account_type_data['bank_id'], account_type_data['start_dt'], account_type_data['end_dt'],
                 account_type_data['acc_type_txt'], account_type_data['replenishment_flg'],
                 account_type_data['transfer_flg'], account_type_data['withdrawal_flg'],
                 account_type_data['comission_amt'], account_type_data['min_balance_amt'])
            )
            acc_type_id = cursor.fetchone()[0]

            for _ in range(5):
                account_data = {
                    'acc_type_id': acc_type_id,
                    'cur_balance_amt': fake.random_number(digits=7)
                }

                cursor.execute(
                    "INSERT INTO account (acc_type_id, cur_balance_amt) VALUES (%s, %s) RETURNING account_id",
                    (account_data['acc_type_id'],
                     account_data['cur_balance_amt'])
                )
                account_ids.append(cursor.fetchone()[0])

    for account_id in account_ids:
        user_id = random.choice(user_ids)

        open_dt = fake.date_between(start_date='-5y', end_date='today')
        close_dt = fake.date_between(start_date=open_dt, end_date='+5y')

        cursor.execute(
            "INSERT INTO registry (user_id, account_id, open_dt, close_dt) VALUES (%s, %s, %s, %s)",
            (user_id, account_id, open_dt, close_dt)
        )

    connect.commit()
    cursor.close()
    connect.close()


populate_tables()
