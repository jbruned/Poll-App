from pollapp import PollApp
from sys import argv

# Instantiate PollApp and run it, using the specified listen address
PollApp().run(argv[1] if len(argv) > 1 else "127.0.0.1:9000")
