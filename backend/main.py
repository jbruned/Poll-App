import os
from sys import argv

from pollapp.config import Config
from pollapp import PollApp

# Instantiate PollApp and run it, using the specified listen address
PollApp().run(argv[1] if len(argv) > 1 else f"127.0.0.1:{Config.BACKEND_PORT}")
