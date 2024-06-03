import os
import pytest
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Database connection parameters
DB_PARAMS = {
    'dbname': 'dbname',
    'user': 'postgres',
    'password': 'password',
    'host': '127.0.0.1',
    'port': '5432',
}


@pytest.fixture(scope='session')
def db_connection():
    conn = psycopg2.connect(**DB_PARAMS)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    yield conn
    conn.close()
