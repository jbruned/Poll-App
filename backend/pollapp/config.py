"""
This package contains the poll app configuration
"""

import os


class Config:  # pylint: disable=too-few-public-methods
    """
    App configuration
    """
    BACKEND_PORT = int(os.getenv("BACKEND_PORT", '9000'))
    DEBUG_ON = os.getenv("DEBUG_ON", 'False').lower() in ('true', '1', 't')
    USE_POSTGRES = os.getenv("USE_POSTGRES", 'False') \
        .lower() in ('true', '1', 't')
    DB_HOST = os.getenv("DB_HOST") if USE_POSTGRES else None
    DB_PORT = os.getenv("DB_PORT") if USE_POSTGRES else None
    DB_NAME = os.getenv("DB_NAME") if USE_POSTGRES else None
    DB_USER = os.getenv("DB_USER") if USE_POSTGRES else None
    DB_PASSWORD = os.getenv("DB_PASSWORD") if USE_POSTGRES else None
    if USE_POSTGRES and not all([
        DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
    ]):
        raise ValueError("Invalid DB config in ENV variables")
    DROP_DB_AND_INSERT_TEST_DATA = os.getenv(
        "DROP_DB_AND_INSERT_TEST_DATA",
        "True" if DEBUG_ON else "False"
    ).lower() in ('true', '1', 't')
    LOG_FILENAME = os.getenv("LOG_FILENAME", "pollapp.log")
    SQLITE_URI = "sqlite:///flasksqlTest.db"
    POSTGRES_URI = "postgresql://" + \
        f"{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    DB_URI = POSTGRES_URI if USE_POSTGRES else SQLITE_URI
