import json
import uuid
from logging import getLogger, CRITICAL

import jsons
from flask import Flask, send_file, abort, request, session
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database

from .db import AppSettings, Poll, Option, NotFoundException
from .log import log_warning


def placeholder_exception_handler(e):
    return "{} - {}".format(e.__class__.__name__, e)


class WebGUI:
    """
    Contains the implementation of the entire web GUI
    """

    _SECRET_KEY = "b0928e1a460370d300c864856520f265"

    API_V1_PREFIX = "/api/v1"

    def __init__(self, db: SQLAlchemy):
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
        db.create_all()
        # Load app settings from the database
        if not AppSettings.is_initialized():
            AppSettings.init()  # To restore default settings, run unconditionally
        self.settings = AppSettings.query.first()
        # Warn about the default password if needed
        if self.settings.is_password_correct(AppSettings.DEFAULT_ADMIN_PASSWORD):
            log_warning(f"Admin password is set to default: {AppSettings.DEFAULT_ADMIN_PASSWORD}\n"
                        "          Please change it from the GUI")

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
                abort(404)

        # API endpoints
        @self.web.route(f"{self.API_V1_PREFIX}/login", methods=['POST'])
        def login():
            try:
                if self.settings.is_password_correct(request.form['password']):
                    session["admin"] = True
                    session["id"] = uuid.uuid4()
                return jsons.dumps(self.is_logged_in()), 200 if self.is_logged_in() else 401
            except Exception as e:
                return "{} - {}".format(e.__class__.__name__, e)

        @self.web.route(f"{self.API_V1_PREFIX}/password", methods=['POST'])
        def change_password():
            if not request.form['old'] or len(request.form['new'] or '') < 5 or len(request.form['repeat'] or '') < 5 \
                    or request.form['new'] != request.form['repeat']:
                return "Request is incomplete", 400
            if not self.settings.is_password_correct(request.form['old']):
                return "Old password is incorrect", 401
            self.settings.set(request.form['new'])
            return "Success", 200

        @self.web.route(f"{self.API_V1_PREFIX}/logout")
        def logout():
            session.pop("admin", None)
            session.pop("id", None)
            return "Logged out", 200

        @self.web.route(f"{self.API_V1_PREFIX}/polls/", methods=['GET', 'POST'])
        def polls_actions():
            try:
                if request.method == 'GET':
                    polls = Poll.get_polls()
                    result = [poll.get_info() for poll in polls]
                    return jsons.dumps(result, default=str)

                elif request.method == 'POST':
                    data = request.form
                    if not data['title']:
                        return "Missing title", 400
                    inserted = Poll.insert(title=data['title'], author=data['author'] or None)
                    return jsons.dumps(
                        inserted.get_info()
                    ), 200
            except Exception as e:
                return placeholder_exception_handler(e)

        @self.web.route(f"{self.API_V1_PREFIX}/poll/<poll_id>", methods=['GET', 'POST', 'DELETE'])
        def poll_actions(poll_id=None):
            try:
                poll = Poll.get(int(poll_id))
                if request.method == 'GET':
                    return jsons.dumps(poll.get_info(), default=str)
                if not self.is_logged_in(poll.author):
                    return "Unauthorized", 401
                if request.method == 'POST':
                    data = request.form
                    if not data['title']:
                        return "Missing title", 400
                    poll.update(title=data['title'], author=data['author'] or None)
                    return "Update successful", 200
                elif request.method == 'DELETE':
                    poll.delete()
                    return "Success", 200
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Poll not found", 404
            except Exception as e:
                return placeholder_exception_handler(e)

        @self.web.route(f"{self.API_V1_PREFIX}/poll/<poll_id>/options", methods=['GET', 'POST'])
        def options_actions(poll_id):
            try:
                poll = Poll.get(int(poll_id))
                if request.method == 'GET':
                    options = poll.get_options()
                    result = [option.get_info() for option in options]
                    return json.dumps(result, default=str)
                if not self.is_logged_in(poll.author):
                    return "Unauthorized", 401
                if request.method == 'POST':
                    data = request.form
                    if not data['text']:
                        return "Missing text", 400
                    return jsons.dumps(
                        Option.insert(text=data['text'], poll_id=poll.id).get_info()
                    ), 200
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Poll not found", 404
            except Exception as e:
                return placeholder_exception_handler(e)

        @self.web.route(f"{self.API_V1_PREFIX}/option/<option_id>", methods=['GET', 'POST', 'DELETE'])
        def option_actions(option_id):
            try:
                option = Option.get(int(option_id))
                if request.method == 'GET':
                    return json.dumps(option.get_info())
                if not self.is_logged_in(option.poll.author):
                    return "Unauthorized", 401
                if request.method == 'POST':
                    data = request.form
                    if not data['text']:
                        return "Missing text", 400
                    option.update(text=data['text'])
                    return "Update successful", 200
                elif request.method == 'DELETE':
                    option.delete()
                    return "Success", 200
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Option not found", 404
            except Exception as e:
                return placeholder_exception_handler(e)

        @self.web.route(f"{self.API_V1_PREFIX}/option/<option_id>/answers",
                        methods=['GET', 'POST', 'DELETE'])
        def answers_actions(option_id):
            try:
                option = Option.get(int(option_id))
                if request.method == 'GET':
                    answers = option.answers
                    result = [answer.get_info() for answer in answers]
                    return json.dumps(result, default=str)
                if not self.is_logged_in(option.poll.author):
                    return "Unauthorized", 401
                session_id = session.get("id")
                if request.method == 'POST':
                    result = option.vote(str(session_id))
                    if result is None:
                        return "Vote unsuccessful, you have already voted", 409
                    return "Vote successful. Thank you for your participation!", 200
                elif request.method == 'DELETE':
                    try:
                        option.remove_vote(str(session_id))
                        return "Vote removed", 200
                    except NotFoundException:
                        return "Answer not found", 404
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Option not found", 404
            except Exception as e:
                return placeholder_exception_handler(e)

    # noinspection PyMethodMayBeStatic
    def is_logged_in(self, session_id=None) -> bool:
        """
        Checks if the user has started a session by entering the password
        @return: True if the user is logged in
        """
        return session.get("admin") is True or (session_id is not None and session.get("id") == session_id)
