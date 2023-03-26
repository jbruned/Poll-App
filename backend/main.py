import os
from sys import argv

from pollapp import PollApp

BACKEND_PORT = os.environ['BACKEND_PORT']
# Instantiate PollApp and run it, using the specified listen address
PollApp().run(argv[1] if len(argv) > 1 else f"127.0.0.1:{BACKEND_PORT}")
