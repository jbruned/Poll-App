"""
This package contains the poll app configuration
"""

import os


class Config:  # pylint: disable=too-few-public-methods
    """
    App configuration
    """
    BACKEND_PORT = int(os.getenv("BACKEND_PORT", '80'))
    DEBUG_ON = os.getenv("DEBUG_ON", 'False').lower() in ('true', '1', 't')
    LOG_FILENAME = os.getenv("LOG_FILENAME", "pollapp.log")

    DB_HOST = os.getenv("DB_HOST", None)
    DB_PORT = os.getenv("DB_PORT", None)
    DB_NAME = os.getenv("DB_NAME", None)
    DB_USER = os.getenv("DB_USER", None)
    DB_PASSWORD = os.getenv("DB_PASSWORD", None)
    DB_TIMEOUT = int(os.getenv("DB_TIMEOUT", '5'))  # In seconds
    USE_POSTGRES = all([
        DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
    ])
    INSERT_TEST_DATA = os.getenv(
        "INSERT_TEST_DATA",
        "True" if DEBUG_ON else "False"
    ).lower() in ('true', '1', 't')

    SQLITE_URI = "sqlite:///flasksqlTest.db"
    POSTGRES_URI = "postgresql://" + \
        f"{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    DB_URI = POSTGRES_URI if USE_POSTGRES else SQLITE_URI
