import json
import uuid
from logging import getLogger, CRITICAL, DEBUG

from flask import Flask, send_file, abort, request, session
from flask_cors import CORS
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database
from werkzeug.exceptions import Unauthorized, Forbidden, NotFound, Conflict, InternalServerError

from .db import AppSettings, Poll, Option, NotFoundException, AlreadyVotedException
from .log import log_warning


class WebGUI(Flask):
    """
    Contains the implementation of the entire web GUI in Flask
    """

    _SECRET_KEY = "b0928e1a460370d300c864856520f265"
    API_V1_PREFIX = "/api/v1"

    def __init__(self, db: SQLAlchemy, debug: bool = True, use_sqlite: bool = None,
                 drop_db_and_insert_test_data: bool = None):
        """
        Implementation of the WebGUI and all endpoints using Flask
        @param db: database where all data is persisted
        """
        super().__init__(__name__)
        CORS(self)

        # Set debug mode and logging level
        if debug:
            self.config['DEBUG'] = True
            self.config['TESTING'] = True
            self.config['ENV'] = 'development'
            if use_sqlite is None:
                use_sqlite = True
            if drop_db_and_insert_test_data is None:
                drop_db_and_insert_test_data = True
        getLogger('werkzeug').setLevel(DEBUG if debug else CRITICAL)

        # Push the app context to the current thread
        self.app_context().push()

        # Initialize the app
        self.init_db(db, use_sqlite, drop_db_and_insert_test_data)
        self.settings = self.load_settings()
        self.init_gui()
        self.init_api()
        self.init_error_handler()

        # Set the secret key for the Flask sessions
        self.secret_key = self._SECRET_KEY

    def init_db(self, db: SQLAlchemy, use_sqlite: bool = True, drop_db_and_insert_test_data: bool = False):
        """
        Initializes the database
        """
        # Database configuration
        # self.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///flasksqlTest.db' if use_sqlite else \
        #    'postgresql://postgres:1234@localhost:5432/flasksqlTest'
        self.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///flasksqlTest.db' if use_sqlite else \
            'postgresql://postgres:1234@database:5432/flasksqlTest'
        self.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        # Create PostgreSQL database if it doesn't exist
        if not use_sqlite:
            engine = create_engine(self.config['SQLALCHEMY_DATABASE_URI'])
            if not database_exists(engine.url):
                create_database(engine.url)
        # Initialize database
        db.init_app(self)
        Migrate(self, db)
        if drop_db_and_insert_test_data:
            db.drop_all()
            db.create_all()
            self._insert_test_data()
        db.create_all()
        # Load app settings from the database

    @staticmethod
    def load_settings():
        """
        Loads the app settings from the database
        """
        if not AppSettings.is_initialized():
            AppSettings.init()  # To restore default settings, run unconditionally
        settings = AppSettings.query.first()
        # Warn about the default password if needed
        if settings.is_password_correct(AppSettings.DEFAULT_ADMIN_PASSWORD):
            log_warning(f"Admin password is set to default: {AppSettings.DEFAULT_ADMIN_PASSWORD}\n"
                        "          Please change it from the GUI")
        return settings

    def init_gui(self):
        """
        Initializes the GUI (frontend) endpoints
        """

        @self.route("/")
        @self.route("/login")
        @self.route("/poll/<poll_id>")
        def dashboard():
            return send_file("gui/index.html")

        @self.route('/assets/<filename>')
        def asset(filename):
            try:
                while '../' in filename:
                    filename = filename.replace('../', '')
                return send_file(f"gui/assets/{filename}")
            except FileNotFoundError:
                abort(404, "Asset not found")

    def init_api(self):
        """
        Initializes the API endpoints
        """

        @self.route(f"{self.API_V1_PREFIX}/login", methods=['GET', 'POST'])
        def login():
            # TODO replace by Kong API Gateway
            if request.method == "POST":
                if self.settings.is_password_correct(request.json['password']):
                    session["admin"] = True
                else:
                    abort(401, "Incorrect password")
            return json.dumps({
                "is_admin": self.is_admin_logged_in(),
                "session_id": self.get_or_create_session_id()
            })

        @self.route(f"{self.API_V1_PREFIX}/password", methods=['POST'])
        def change_password():
            if not request.form['old'] or len(request.form['new'] or '') < 5 or len(request.form['repeat'] or '') < 5 \
                    or request.form['new'] != request.form['repeat']:
                abort(400, "Incomplete request")
            if not self.settings.is_password_correct(request.form['old']):
                abort(401, "Old password is incorrect")
            self.settings.set(request.form['new'])
            return self.success()

        @self.route(f"{self.API_V1_PREFIX}/logout")
        def logout():
            session.pop("admin", None)
            session.pop("id", None)
            return self.success()

        @self.route(f"{self.API_V1_PREFIX}/polls/", methods=['GET', 'POST'])
        def polls_actions():
            if request.method == 'GET':
                return json.dumps(Poll.get_polls(as_dict=True), default=str)
            elif request.method == 'POST':
                data = request.form
                if not data['title']:
                    abort(400, "Missing title")
                return json.dumps(
                    Poll.insert(title=data['title'], author=data['author'] or None)
                    .get_info(self.get_or_create_session_id())
                ), 200

        @self.route(f"{self.API_V1_PREFIX}/poll/<poll_id>", methods=['GET', 'POST', 'DELETE'])
        def poll_actions(poll_id=None):
            poll = Poll.get(int(poll_id))
            if request.method == 'GET':
                return json.dumps(poll.get_info(), default=str)
            if not self.is_admin_logged_in(poll.author):
                abort(401, "Not logged in")
            if request.method == 'POST':
                data = request.form
                if not data['title']:
                    abort(400, "Missing title")
                poll.update(title=data['title'], author=data['author'] or None)
                return self.success()
            elif request.method == 'DELETE':
                poll.delete()
                return self.success()

        @self.route(f"{self.API_V1_PREFIX}/poll/<poll_id>/options", methods=['GET', 'POST'])
        def options_actions(poll_id):
            poll = Poll.get(int(poll_id))
            if request.method == 'GET':
                return json.dumps(poll.get_options(), default=str)  # [option.get_info() for option in options]
            if not self.is_admin_logged_in(poll.author):
                abort(401, "Not logged in")
            if request.method == 'POST':
                data = request.form
                if not data['text']:
                    abort(400, "Missing text")
                return json.dumps(
                    Option.insert(text=data['text'], poll_id=poll.id).get_info()
                ), 200

        @self.route(f"{self.API_V1_PREFIX}/option/<option_id>", methods=['GET', 'POST', 'DELETE'])
        def option_actions(option_id):
            option = Option.get(int(option_id))
            if request.method == 'GET':
                return json.dumps(option.get_info())
            if not self.is_admin_logged_in(option.get_poll().author):
                abort(401, "Not logged in")
            if request.method == 'POST':
                data = request.form
                if not data['text']:
                    abort(400, "Missing text")
                option.update(text=data['text'])
                return self.success()
            elif request.method == 'DELETE':
                option.delete()
                return self.success()

        @self.route(f"{self.API_V1_PREFIX}/option/<option_id>/vote",
                    methods=['POST', 'DELETE'])
        def answers_actions(option_id):
            option = Option.get(int(option_id))
            session_id = self.get_or_create_session_id()
            if request.method == 'POST':
                result = option.vote(str(session_id))
                if result is None:
                    abort(409, "You have already voted!")
                return self.success()
            elif request.method == 'DELETE':
                option.remove_vote(str(session_id))
                return self.success()

    HTTP_ERRORS = {
        400: "Bad request",
        401: "Unauthorized",
        403: "Forbidden",
        404: "Not found",
        409: "Conflict",
        500: "Internal server error"
    }
    EXCEPTIONS = {
        NotFoundException: 404,
        ValueError: 400,
        AlreadyVotedException: 409,
        Exception: 500,
        Unauthorized: 401,
        Forbidden: 403,
        NotFound: 404,
        Conflict: 409,
        InternalServerError: 500
    }

    def init_error_handler(self):
        """
        Initializes the error handler
        """

        @self.errorhandler(Exception)
        def handle_error(code_or_exception=500, message=None, debug=False):
            """
            Handles errors
            """
            if debug:
                import traceback
                traceback.print_exc()
            if message is not None and isinstance(code_or_exception, int):
                return json.dumps({
                    "error": message
                }), code_or_exception
            if isinstance(code_or_exception, int):
                try:
                    return handle_error(code_or_exception, self.HTTP_ERRORS[code_or_exception])
                except KeyError:
                    return handle_error(500)
            if isinstance(code_or_exception, Exception):
                try:
                    return handle_error(
                        self.EXCEPTIONS[type(code_or_exception)],
                        str(code_or_exception) or "Unknown error"
                    )
                except KeyError:
                    return handle_error(500)
            return handle_error(500)

    @staticmethod
    def get_or_create_session_id():
        if "id" not in session or session["id"] is None:
            session["id"] = str(uuid.uuid4())
        return session["id"]

    @staticmethod
    def is_admin_logged_in(session_id=None) -> bool:
        """
        Checks if the user has started a session by entering the password
        @return: True if the user is logged in
        """
        return session.get("admin") is True or (
                session_id is not None and WebGUI.get_or_create_session_id() == session_id
        )

    @staticmethod
    def success(message=True):
        return json.dumps({
            "success": message
        }), 200

    @staticmethod
    def _insert_test_data():
        """
        Inserts some test data into the database
        """
        poll = Poll.insert(title="Test poll", author="admin")
        Option.insert(text="Option 1", poll_id=poll.id)
        Option.insert(text="Option 2", poll_id=poll.id)
        Option.insert(text="Option 3", poll_id=poll.id)

        poll = Poll.insert(title="Another poll", author="admin")
        option = Option.insert(text="Option 1", poll_id=poll.id)
        Option.insert(text="Option 2", poll_id=poll.id)
        Option.insert(text="Option 3", poll_id=poll.id)
        Option.insert(text="Option 4", poll_id=poll.id)
        Option.insert(text="Option 5", poll_id=poll.id)
        option.vote("test")

        poll = Poll.insert(title="Poll with votes", author=None)
        Option.insert(text="Option 1", poll_id=poll.id)
