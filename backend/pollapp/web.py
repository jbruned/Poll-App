"""
This package contains the web GUI
"""
import json
import traceback
import uuid
from logging import getLogger, CRITICAL, DEBUG

from flask import Flask, send_file, abort, request, session
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database
from werkzeug.exceptions import Unauthorized, Forbidden, \
    NotFound, Conflict, InternalServerError

from .config import Config
from .db import AppSettings, Poll, Option, NotFoundException, \
    AlreadyVotedException, insert_test_data


class WebGUI(Flask):
    """
    Contains the implementation of the entire web GUI in Flask
    """

    _SECRET_KEY = "b0928e1a460370d300c864856520f265"
    API_V1_PREFIX = "/api/v1"

    def __init__(self, database: SQLAlchemy):
        """
        Implementation of the WebGUI and all endpoints using Flask
        @param database: database where all data is persisted
        """
        super().__init__(
            __name__,
            static_folder="gui/static",
            static_url_path="/static"
        )

        # Set debug mode and logging level
        if Config.DEBUG_ON:
            self.config['DEBUG'] = True
            self.config['TESTING'] = True
            self.config['ENV'] = 'development'
        getLogger('werkzeug').setLevel(DEBUG if Config.DEBUG_ON else CRITICAL)

        # Push the app context to the current thread
        self.app_context().push()

        # Initialize the app
        self.init_db(database)
        self.settings = self.load_settings()
        self.init_gui()
        self.init_api()
        self.init_error_handler()

        # Set the secret key for the Flask sessions
        self.secret_key = self._SECRET_KEY

    def init_db(self, database: SQLAlchemy):
        """
        Initializes the database
        """
        self.config['SQLALCHEMY_DATABASE_URI'] = Config.DB_URI
        self.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

        # Create database if it doesn't exist
        if Config.USE_POSTGRES:
            engine = create_engine(self.config['SQLALCHEMY_DATABASE_URI'])
            if not database_exists(engine.url):
                create_database(engine.url)

        # Initialize database
        database.init_app(self)
        Migrate(self, database)
        if Config.DROP_DB_AND_INSERT_TEST_DATA:
            database.drop_all()
            database.create_all()
            insert_test_data()
        database.create_all()

    @staticmethod
    def load_settings():
        """
        Loads the app settings from the database
        """
        if not AppSettings.is_initialized():
            AppSettings.init()
        return AppSettings.query.first()

    def init_gui(self):
        """
        Initializes the GUI (frontend) endpoints
        """

        @self.route("/")
        @self.route("/polls/<poll_id>")
        @self.route("/polls/<poll_id>/results")
        def dashboard(poll_id=None):  # pylint: disable=unused-argument
            return send_file("gui/index.html")

        @self.route('/<any("favicon.ico", "manifest.json", "robots.txt",'
                    '"logo192.png", "logo512.png"):filename>')
        def other_static_files(filename):
            return send_file(f"gui/{filename}")

    def init_api(self):  # pylint: disable=too-many-statements
        """
        Initializes the API endpoints
        """

        @self.route(f"{self.API_V1_PREFIX}/polls/", methods=['GET', 'POST'])
        def polls_actions():
            if request.method == 'GET':
                return json.dumps(Poll.get_polls(as_dict=True), default=str)
            if request.method == 'POST':
                data = self.get_request_body(request)
                if not data['title']:
                    abort(400, "Missing title")
                return json.dumps(
                    Poll.insert(title=data['title'],
                                author=data['author'] or None)
                    .get_info(self.get_or_create_session_id()), default=str
                ), 200
            return abort(405, "Method not allowed")

        @self.route(f"{self.API_V1_PREFIX}/poll/<poll_id>",
                    methods=['GET', 'POST', 'DELETE'])
        def poll_actions(poll_id=None):
            poll = Poll.get(int(poll_id))
            if request.method == 'GET':
                return json.dumps(poll.get_info(), default=str)
            if request.method == 'POST':
                data = self.get_request_body(request)
                if not data['title']:
                    abort(400, "Missing title")
                poll.update(title=data['title'],
                            author=data['author'] or None)
                return self.success()
            if request.method == 'DELETE':
                poll.delete()
                return self.success()
            return abort(405, "Method not allowed")

        @self.route(f"{self.API_V1_PREFIX}/poll/<poll_id>/options",
                    methods=['GET', 'POST'])
        def options_actions(poll_id):
            poll = Poll.get(int(poll_id))
            if request.method == 'GET':
                options = poll.get_options()
                return json.dumps([option.to_dict() for option in options],
                                  default=str)
            if request.method == 'POST':
                data = self.get_request_body(request)
                if not data['text']:
                    abort(400, "Missing text")
                return json.dumps(
                    Option.insert(text=data['text'], poll_id=poll.id).to_dict()
                ), 200
            return abort(405, "Method not allowed")

        @self.route(f"{self.API_V1_PREFIX}/option/<option_id>",
                    methods=['GET', 'POST', 'DELETE'])
        def option_actions(option_id):
            option = Option.get(int(option_id))
            if request.method == 'GET':
                return json.dumps(option.to_dict())
            if request.method == 'POST':
                data = self.get_request_body(request)
                if not data['text']:
                    abort(400, "Missing text")
                option.update(text=data['text'])
                return self.success()
            if request.method == 'DELETE':
                option.delete()
                return self.success()
            return abort(405, "Method not allowed")

        @self.route(f"{self.API_V1_PREFIX}/vote/<option_id>",
                    methods=['POST', 'DELETE'])
        def votes_actions(option_id):
            option = Option.get(int(option_id))
            session_id = self.get_or_create_session_id()
            if request.method == 'POST':
                result = option.vote(str(session_id))
                if result is None:
                    abort(409, "You have already voted!")
                return self.success()
            if request.method == 'DELETE':
                option.remove_vote(str(session_id))
                return self.success()
            return abort(405, "Method not allowed")

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
                traceback.print_exc()
            if message is not None and isinstance(code_or_exception, int):
                return (
                    json.dumps({"error": message})
                    if self.API_V1_PREFIX in request.url
                    else message, code_or_exception
                )

            if isinstance(code_or_exception, int):
                try:
                    return handle_error(code_or_exception,
                                        self.HTTP_ERRORS[code_or_exception])
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
        """
        Manage the user's session ID
        """
        if "id" not in session or session["id"] is None:
            session["id"] = str(uuid.uuid4())
        return session["id"]

    @staticmethod
    def success(message=True):
        """
        Default success response
        """
        return json.dumps({
            "success": message
        }), 200

    @staticmethod
    def get_request_body(req):
        """
        Gets the request body
        @param req: request
        @return: the data contained in the request body
        """
        return req.json if req.is_json else req.form
