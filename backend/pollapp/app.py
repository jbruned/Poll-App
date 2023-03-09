import logging
from threading import Thread

from waitress import serve

from .db import db
from .web import WebGUI
from .log import log_info


class PollApp:
    """
    This class runs the entire PollApp program
    """

    def __init__(self):
        """
        PollApp constructor, creates the Flask instance and loads the database
        """
        self.gui = WebGUI(db)

    def run(self, web_addr_port: str = "127.0.0.1:80"):
        """
        Runs the web GUI in its own thread
        @param web_addr_port: The IP address and port where to listen for the web GUI
                              Accepted format is "IP:PORT"
                              IP can be "0.0.0.0" to listen in all interfaces
        """
        try:
            logging.getLogger('waitress').setLevel(logging.ERROR)
            # web_thread = Thread(target=lambda: serve(self.gui.web, listen=web_addr_port))
            # web_thread.daemon = True
            # web_thread.start()
            log_info(f"Starting web interface at http://{web_addr_port}")
            serve(self.gui.web, listen=web_addr_port)
        except KeyboardInterrupt:
            log_info("\nTerminating PollApp...")
