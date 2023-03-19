import json
import uuid
from logging import getLogger, CRITICAL

import jsons
from flask import Flask, send_file, abort, request, session
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database

from .db import AppSettings, Poll, Option
from .error_handlers import register_handlers
from .log import log_warning


class WebGUI:
    """
    Contains the implementation of the entire web GUI
    """

    _SECRET_KEY = "b0928e1a460370d300c864856520f265"

    API_V1_PREFIX = "/api/v1"

    def __init__(self, db: SQLAlchemy, drop_db_and_insert_test_data: bool = False):
        """
        Implementation of the WebGUI and all endpoints using Flask
        @param db: database where all data is persisted
        """
        self.web = Flask(__name__)
        getLogger('werkzeug').setLevel(CRITICAL)
        # Database configuration
        self.web.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:1234@localhost:5432/flasksqlTest'
        self.web.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True

        engine = create_engine(self.web.config['SQLALCHEMY_DATABASE_URI'])
        if not database_exists(engine.url):
            create_database(engine.url)

        db.init_app(self.web)
        self.web.app_context().push()
        # Set the secret key for the Flask sessions
        self.web.secret_key = self._SECRET_KEY
        # Initialize database
        Migrate(self.web, db)
        if drop_db_and_insert_test_data:
            db.drop_all()
            db.create_all()
            self._insert_test_data()
        db.create_all()
        # Load app settings from the database
        if not AppSettings.is_initialized():
            AppSettings.init()  # To restore default settings, run unconditionally
        self.settings = AppSettings.query.first()
        # Warn about the default password if needed
        if self.settings.is_password_correct(AppSettings.DEFAULT_ADMIN_PASSWORD):
            log_warning(f"Admin password is set to default: {AppSettings.DEFAULT_ADMIN_PASSWORD}\n"
                        "          Please change it from the GUI")

        # Register error handlers
        register_handlers(self.web)

        # Web GUI (frontend) endpoints
        @self.web.route("/")
        @self.web.route("/login")
        @self.web.route("/poll/<poll_id>")
        def dashboard(poll_id=None):
            return send_file("gui/index.html")

        @self.web.route('/assets/<filename>')
        def asset(filename):
            try:
                while '../' in filename:
                    filename = filename.replace('../', '')
                return send_file(f"gui/assets/{filename}")
            except FileNotFoundError:
                abort(404, "Asset not found")

        # API endpoints
        @self.web.route(f"{self.API_V1_PREFIX}/login", methods=['GET', 'POST'])
        def login():
            # TODO replace by Kong API Gateway
            try:
                if request.method == "POST":
                    if self.settings.is_password_correct(request.json['password']):
                        session["admin"] = True
                    else:
                        return "Incorrect password", 401
                return json.dumps({
                    "is_admin": self.is_admin_logged_in(),
                    "session_id": get_or_create_session_id()
                })  # if self.is_logged_in() else 401
            except KeyError as e:
                return "Missing password " + str(e), 400

        def get_or_create_session_id():
            if "id" not in session or session["id"] is None:
                session["id"] = str(uuid.uuid4())
            return session["id"]

        @self.web.route(f"{self.API_V1_PREFIX}/password", methods=['POST'])
        def change_password():
            if not request.form['old'] or len(request.form['new'] or '') < 5 or len(request.form['repeat'] or '') < 5 \
                    or request.form['new'] != request.form['repeat']:
                abort(400, "Incomplete request")
            if not self.settings.is_password_correct(request.form['old']):
                abort(401, "Old password is incorrect")
            self.settings.set(request.form['new'])
            return "", 200

        @self.web.route(f"{self.API_V1_PREFIX}/logout")
        def logout():
            session.pop("admin", None)
            session.pop("id", None)
            return "", 200

        @self.web.route(f"{self.API_V1_PREFIX}/polls/", methods=['GET', 'POST'])
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

        @self.web.route(f"{self.API_V1_PREFIX}/poll/<poll_id>", methods=['GET', 'POST', 'DELETE'])
        def poll_actions(poll_id=None):
            try:
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
                    return "", 200
                elif request.method == 'DELETE':
                    poll.delete()
                    return "", 200
            except ValueError:
                abort(400, "Invalid request")
            except NotFoundException:
                abort(404, "Poll not found")

        @self.web.route(f"{self.API_V1_PREFIX}/poll/<poll_id>/options", methods=['GET', 'POST'])
        def options_actions(poll_id):
            try:
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
            except ValueError:
                abort(400, "Invalid request")
            except NotFoundException:
                abort(404, "Poll not found")

        @self.web.route(f"{self.API_V1_PREFIX}/option/<option_id>", methods=['GET', 'POST', 'DELETE'])
        def option_actions(option_id):
            try:
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
                    return "", 200
                elif request.method == 'DELETE':
                    option.delete()
                    return "", 200
            except ValueError:
                abort(400, "Invalid request")
            except NotFoundException:
                abort(404, "Poll not found")
                
        @self.web.route(f"{self.API_V1_PREFIX}/option/<option_id>/answers",
                        methods=['POST', 'DELETE'])
        def answers_actions(option_id):
            try:
                option = Option.get(int(option_id))
                session_id = self.get_or_create_session_id()
                if request.method == 'POST':
                    result = option.vote(str(session_id))
                    if result is None:
                        abort(409, "You have already voted!")
                    return "Vote successful. Thank you for your participation!", 200
                elif request.method == 'DELETE':
                    answer = option.remove_vote(str(session_id))
                    return "", 200
            except ValueError:
                abort(400, "Invalid request")
            except NotFoundException:
                abort(404, "Poll not found")

    # noinspection PyMethodMayBeStatic
    def is_logged_in(self, session_id=None) -> bool:
        """
        Checks if the user has started a session by entering the password
        @return: True if the user is logged in
        """
        return session.get("admin") is True or (session_id is not None and self.get_or_create_session_id() == session_id)

    def _insert_test_data(self):
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
