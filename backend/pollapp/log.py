"""
This package is used for logging
"""
from sys import stdout, stderr

from .config import Config

# Constants
LOG_LEVEL_NOTHING = 0
LOG_LEVEL_ERROR = 1
LOG_LEVEL_WARNING = 2
LOG_LEVEL_INFO = 3
LOG_LEVEL_DEBUG = 4

# Configurable settings
LOG_LEVEL = LOG_LEVEL_INFO
PRINT_TO_CONSOLE = Config.DEBUG_ON  # If false, logs are only saved in the file
LOG_FILENAME = Config.LOG_FILENAME
SHOW_DEBUG = Config.DEBUG_ON  # Debug exceptions to the console

# Open the log file
# pylint: disable=consider-using-with
log_file = open(LOG_FILENAME, 'a', encoding='utf-8') \
    if LOG_LEVEL > LOG_LEVEL_NOTHING and LOG_FILENAME is not None \
    else None


def _log(message: str, log_type: str = "Log", console_file=stdout):
    """
    Internal function to print and/or save logs to the log file
    @param message: message to log (string)
    @param log_type: Error/Warning/Info
    @param console_file: stdout by default, stderr can be used for errors
    """
    message = f"[{log_type}] {message}"
    if PRINT_TO_CONSOLE:
        print(message, file=console_file)
    if log_file is not None:
        log_file.write(message + '\n')
        log_file.flush()


def log_error(message: str):
    """
    Log an error to the console and/or log file (depending on LOG_LEVEL)
    @param message: error message to log
    """
    if LOG_LEVEL >= LOG_LEVEL_ERROR:
        _log(message, "Error", stderr)


def log_warning(message: str):
    """
    Log a warning to the console and/or log file (depending on LOG_LEVEL)
    @param message: warning message to log
    """
    if LOG_LEVEL >= LOG_LEVEL_WARNING:
        _log(message, "Warning")


def log_info(message: str):
    """
    Log an info to the console and/or log file (depending on LOG_LEVEL)
    @param message: info message to log
    """
    if LOG_LEVEL >= LOG_LEVEL_INFO:
        _log(message, "Info")


def log_debug(message: str):
    """
    Log a debug to the console and/or log file (depending on LOG_LEVEL)
    @param message: debug message to log
    """
    if LOG_LEVEL >= LOG_LEVEL_DEBUG:
        _log(message, "Debug")
