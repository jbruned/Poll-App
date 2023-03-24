import logging

from waitress import serve

from .db import db
from .log import log_info
from .web import WebGUI


class PollApp:
    """
    This class runs the entire PollApp program
    """

    def __init__(self):
        """
        PollApp constructor, creates the Flask instance and loads the database
        """
        self.gui = WebGUI(db, drop_db_and_insert_test_data=True)

    def run(self, web_addr_port: str = "127.0.0.1:80", debug: bool = False):
        """
        Runs the web GUI in its own thread
        :param web_addr_port: The IP address and port where to listen for the web GUI
                              Accepted format is "IP:PORT"
                              IP can be "0.0.0.0" to listen in all interfaces
        :param debug: Run Flask in debug mode
        """
        try:
            logging.getLogger('waitress').setLevel(logging.DEBUG if debug else logging.ERROR)
            # noinspection HttpUrlsUsage
            log_info(f"Starting web interface at http://{web_addr_port}")
            serve(self.gui, listen=web_addr_port)
        except KeyboardInterrupt:
            log_info("\nTerminating PollApp...")


def _instantiate_flask_app():
    """
    Instantiates the Flask app
    Intended to auto-generate the Postman collection
    @return: The Flask app
    """
    return PollApp().gui
