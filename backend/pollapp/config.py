import os


class Config:
    DEBUG_ON = os.getenv("DEBUG_ON", 'False').lower() in ('true', '1', 't')
    USE_POSTGRES = os.getenv("USE_POSTGRES", 'True').lower() in ('true', '1', 't')
    DB_HOST = os.getenv("DB_HOST") if USE_POSTGRES else None
    DB_PORT = os.getenv("DB_PORT") if USE_POSTGRES else None
    DB_NAME = os.getenv("DB_NAME") if USE_POSTGRES else None
    DB_USER = os.getenv("DB_USER") if USE_POSTGRES else None
    DB_PASSWORD = os.getenv("DB_PASSWORD") if USE_POSTGRES else None
    DROP_DB_AND_INSERT_TEST_DATA = os.getenv(
        "DROP_DB_AND_INSERT_TEST_DATA",
        "True" if DEBUG_ON else "False"
    ).lower() in ('true', '1', 't')
    LOG_FILENAME = os.getenv("LOG_FILENAME", "pollapp.log")
