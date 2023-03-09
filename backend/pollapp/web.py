import hashlib
import json
import uuid
from logging import getLogger, CRITICAL

from flask import Flask, send_file, abort, request, redirect, session, url_for
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy

from .db import AppSettings, Poll, Option, Answer, NotFoundException
from .log import log_warning


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
        self.web.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///pollapp.db?check_same_thread=False'
        self.web.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
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
        def dashboard():
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
            if self.settings.is_password_correct(request.form['password']):
                session["admin"] = True
                session["id"] = uuid.uuid4()
            return json.dumps(self.is_logged_in()), 200 if self.is_logged_in() else 401

        @self.web.route(f"{self.API_V1_PREFIX}/password", methods=['POST'])
        def change_password():
            if not request.form['old'] or len(request.form['new'] or '') < 5 or len(request.form['repeat'] or '') < 5 \
                    or request.form['new'] != request.form['repeat']:
                return "Request is incomplete", 400
            if not self.settings.is_password_correct(request.form['old']):
                return "Old password is incorrect", 401
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
                return json.dumps(Poll.get_polls(), default=str)
            elif request.method == 'POST':
                data = request.form
                if not data['title']:
                    return "Missing title", 400
                return json.dumps(
                    Poll.insert(title=data['title'], author=data['author'] or None)
                ), 200

        @self.web.route(f"{self.API_V1_PREFIX}/poll/<poll_id>", methods=['GET', 'POST', 'DELETE'])
        def poll_actions(poll_id=None):
            try:
                poll = Poll.get(int(poll_id))
                if request.method == 'GET':
                    return json.dumps(poll.get_info(), default=str)
                if not self.is_logged_in(poll.author):
                    return "Unauthorized", 401
                if request.method == 'POST':
                    data = request.form
                    if not data['title']:
                        return "Missing title", 400
                    poll.update(title=data['title'], author=data['author'] or None)
                    return "", 200
                elif request.method == 'DELETE':
                    poll.delete()
                    return "", 200
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Poll not found", 404

        @self.web.route(f"{self.API_V1_PREFIX}/poll/<poll_id>/options", methods=['GET', 'POST'])
        def options_actions(poll_id):
            try:
                poll = Poll.get(int(poll_id))
                if request.method == 'GET':
                    return json.dumps(poll.get_options(), default=str)
                if not self.is_logged_in(poll.author):
                    return "Unauthorized", 401
                if request.method == 'POST':
                    data = request.form
                    if not data['text']:
                        return "Missing text", 400
                    return json.dumps(
                        Option.insert(text=data['text'], poll_id=poll.id)
                    ), 200
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Poll not found", 404

        @self.web.route(f"{self.API_V1_PREFIX}/option/<option_id>", methods=['GET', 'POST', 'DELETE'])
        def option_actions(option_id):
            try:
                option = Option.get(int(option_id))
                if request.method == 'GET':
                    return json.dumps(option, default=str)
                if not self.is_logged_in(option.poll.author):
                    return "Unauthorized", 401
                if request.method == 'POST':
                    data = request.form
                    if not data['text']:
                        return "Missing text", 400
                    option.update(text=data['text'])
                    return "", 200
                elif request.method == 'DELETE':
                    option.delete()
                    return "", 200
            except ValueError:
                return "Invalid request", 400
            except NotFoundException:
                return "Poll not found", 404

    # noinspection PyMethodMayBeStatic
    def is_logged_in(self, session_id = None) -> bool:
        """
        Checks if the user has started a session by entering the password
        @return: True if the user is logged in
        """
        return session.get("admin") is True or (session_id is not None and session.get("session_id") == session_id)
