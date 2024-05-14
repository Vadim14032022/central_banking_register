import os
import pytest
import psycopg2
from decimal import Decimal


def read_sql_query_from_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()


def test_first_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '-- 1) Банки и типы их типы счетов') + 1
        last_query_index = query_lines.index(
            '-- 2) Средний баланс и банк каждого типа счета, если среднее')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = [
            ('Альфа-Банк', 2, 'Клиентский', 18),
            ('Альфа-Банк', 2, 'Депозитный', 3),
            ('Альфа-Банк', 2, 'Сберегательный', 33),
            ('Банк Восточный', 11, 'Резервный', 27),
            ('Банк Восточный', 11, 'Студенческий', 12),
            ('Бинбанк', 14, 'Пенсионный', 15),
            ('Бинбанк', 14, 'Ипотечный', 30),
            ('ВТБ', 3, 'Депозитный', 34),
            ('ВТБ', 3, 'Специализированный', 19),
            ('ВТБ', 3, 'Текущий', 4),
            ('Газпромбанк', 5, 'Рассчетный', 21),
            ('Газпромбанк', 5, 'Инвестиционный', 6),
            ('Московский Кредитный Банк', 15, 'Депозитный', 31),
            ('Московский Кредитный Банк', 15, 'Текущий', 16),
            ('Открытие', 8, 'Кредитный', 24),
            ('Открытие', 8, 'Специализированный', 9),
            ('Промсвязьбанк', 13, 'Ипотечный', 14),
            ('Промсвязьбанк', 13, 'Кредитный', 29),
            ('Райффайзенбанк', 6, 'Зарплатный', 7),
            ('Райффайзенбанк', 6, 'Детский', 22),
            ('Росбанк', 7, 'Резервный', 8),
            ('Росбанк', 7, 'Инвестиционный', 23),
            ('Россельхозбанк', 9, 'Зарплатный', 25),
            ('Россельхозбанк', 9, 'Специальный', 10),
            ('Сбербанк', 1, 'Текущий', 1),
            ('Сбербанк', 1, 'Сберегательный', 2),
            ('Сбербанк', 1, 'Корпоративный', 17),
            ('Сбербанк', 1, 'Зарплатный', 32),
            ('Совкомбанк', 12, 'Льготный', 13),
            ('Совкомбанк', 12, 'Инвестиционный', 28),
            ('Тинькофф', 4, 'Текущий', 35),
            ('Тинькофф', 4, 'Текущий', 20),
            ('Тинькофф', 4, 'Кредитный', 5),
            ('ЮниКредит Банк', 10, 'Корпоративный', 26),
            ('ЮниКредит Банк', 10, 'Учебный', 11)
        ]

        assert results == expected_results


def test_second_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '--    больше 800, упорядоченные по убыванию среднего.') + 1
        last_query_index = query_lines.index(
            '-- 3) Почта и количество счетов тех клиентов, у которых')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = [
            (21, 'Газпромбанк', Decimal('8000.0')),
            (15, 'Бинбанк', Decimal('7000.3')),
            (6, 'Газпромбанк', Decimal('7000.3')),
            (3, 'Альфа-Банк', Decimal('3000.0')),
            (24, 'Открытие', Decimal('2500.8')),
            (1, 'Сбербанк', Decimal('2500.0')),
            (5, 'Тинькофф', Decimal('2000.0')),
            (14, 'Промсвязьбанк', Decimal('1800.5')),
            (34, 'ВТБ', Decimal('1800.5')),
            (12, 'Банк Восточный', Decimal('1650.3')),
            (30, 'Бинбанк', Decimal('1600.8')),
            (4, 'ВТБ', Decimal('1500.8')),
            (25, 'Россельхозбанк', Decimal('1500.0')),
            (10, 'Россельхозбанк', Decimal('1400.4')),
            (33, 'Альфа-Банк', Decimal('1300.0')),
            (22, 'Райффайзенбанк', Decimal('1200.5')),
            (8, 'Росбанк', Decimal('1200.0')),
            (28, 'Совкомбанк', Decimal('1100.0')),
            (27, 'Банк Восточный', Decimal('900.0')),
            (11, 'ЮниКредит Банк', Decimal('850.0')),
            (29, 'Промсвязьбанк', Decimal('800.5')),
            (9, 'Открытие', Decimal('800.5'))
        ]
        assert results == expected_results


def test_third_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '--    счетов хотя бы 2') + 1
        last_query_index = query_lines.index(
            '-- 4) Информация о счетах пользователей с наибольшим балансом из каждого типа счета,')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = [
            (2, 'petr@gmail.com', 4),
            (1, 'ivan@gmail.com', 4),
            (4, 'anna@gmail.com', 4),
            (5, 'dmitriy@gmail.com', 4),
            (3, 'maria@gmail.com', 4),
            (9, 'artem@gmail.com', 3),
            (7, 'alexey@gmail.com', 3),
            (6, 'elena@gmail.com', 3),
            (10, 'natalya@gmail.com', 3),
            (8, 'olga@gmail.com', 3),
        ]
        assert results == expected_results


def test_fourth_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '--    при условии, что количество пользователей на этом типе счета хотя бы два.') + 1
        last_query_index = query_lines.index(
            '-- 5) Найти пользователей с самым большим суммарном балансом на счетах,')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = [
            ('Сбербанк', 'ivan@gmail.com', 1, 2, 2),
            ('Сбербанк', 'petr@gmail.com', 2, 2, 2),
            ('Россельхозбанк', 'natalya@gmail.com', 10, 2, 2),
            ('ЮниКредит Банк', 'ivan@gmail.com', 11, 2, 1),
            ('Банк Восточный', 'petr@gmail.com', 12, 2, 1),
            ('Сбербанк', 'elena@gmail.com', 1, 2, 1),
            ('Сбербанк', 'alexey@gmail.com', 2, 2, 1),
            ('Россельхозбанк', 'olga@gmail.com', 10, 2, 1),
            ('ЮниКредит Банк', 'artem@gmail.com', 11, 2, 2),
            ('Банк Восточный', 'natalya@gmail.com', 12, 2, 2)
        ]

        assert results == expected_results


def test_fifth_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '--    большем 3000, отсортировать по убыванию') + 1
        last_query_index = query_lines.index(
            '-- 6) Для каждого счета дополнительно вывести максимальный баланс')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = [
            (6, 'elena@gmail.com', '11 700,50 ₽'),
            (5, 'dmitriy@gmail.com', '11 200,50 ₽'),
            (1, 'ivan@gmail.com', '10 700,00 ₽'),
            (4, 'anna@gmail.com', '7 602,50 ₽'),
            (3, 'maria@gmail.com', '4 900,00 ₽'),
            (8, 'olga@gmail.com', '4 500,00 ₽'),
            (2, 'petr@gmail.com', '3 901,00 ₽'),
            (10, 'natalya@gmail.com', '3 502,00 ₽')
        ]

        assert results == expected_results


def test_six_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '--    на этом типе счета, упорядоченные по убыванию максимума') + 1
        last_query_index = query_lines.index(
            '-- 7) Получение списка всех банков и их общего количества клиентов, ')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = query

        assert results == expected_results


def test_seventh_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '-- отсортированного по количеству клиентов по убыванию:') + 1
        last_query_index = query_lines.index(
            '-- 8) Получение списка банков с указанием количества счетов, закрывающихся')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = query

        assert results == expected_results


def test_eights_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '-- отсортированного по количеству клиентов по убыванию:') + 1
        last_query_index = query_lines.index(
            '-- 8) Получение списка банков с указанием количества счетов, закрывающихся')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = query

        assert results == expected_results


def test_ninghts_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '-- отсортированного по количеству клиентов по убыванию:') + 1
        last_query_index = query_lines.index(
            '-- 8) Получение списка банков с указанием количества счетов, закрывающихся')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = query

        assert results == expected_results


def test_tens_query(db_connection):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sql_file_path = os.path.join(
        BASE_DIR, 'scripts', 'bank_queries_second.sql')

    with db_connection.cursor() as cursor:
        query = read_sql_query_from_file(sql_file_path)

        query_lines = query.strip().split('\n')
        first_query_index = query_lines.index(
            '-- отсортированного по количеству клиентов по убыванию:') + 1
        last_query_index = query_lines.index(
            '-- 8) Получение списка банков с указанием количества счетов, закрывающихся')
        query = '\n'.join(query_lines[first_query_index:last_query_index])

        cursor.execute(query)
        results = cursor.fetchall()

        expected_results = query

        assert results == expected_results
